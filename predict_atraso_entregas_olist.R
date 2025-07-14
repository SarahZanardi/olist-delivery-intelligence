# Carregar bibliotecas
library(tidyverse)
library(lubridate)
library(data.table)
library(janitor)
library(randomForest)

# Leitura e limpeza dos datasets
orders <- fread("olist_orders_dataset.csv") %>% clean_names()
order_items <- fread("olist_order_items_dataset.csv") %>% clean_names()
reviews <- fread("olist_order_reviews_dataset.csv") %>% clean_names()
products <- fread("olist_products_dataset.csv") %>% clean_names()
customers <- fread("olist_customers_dataset.csv") %>% clean_names()

# Conversão de datas
orders <- orders %>%
  mutate(across(contains("date"), ~parse_date_time(., orders = c("ymd HMS", "ymd"))))

# Criar coluna de atraso na entrega
orders <- orders %>%
  mutate(atraso = if_else(order_delivered_customer_date > order_estimated_delivery_date, 1, 0, missing = 0))

# Review médio por pedido
reviews_media <- reviews %>%
  group_by(order_id) %>%
  summarise(review_score = mean(review_score, na.rm = TRUE))

# Juntar bases
base <- orders %>%
  left_join(order_items, by = "order_id") %>%
  left_join(products, by = "product_id") %>%
  left_join(reviews_media, by = "order_id") %>%
  left_join(customers, by = "customer_id")

# Criar variáveis de tempo
base <- base %>%
  mutate(
    dias_envio = as.numeric(difftime(order_delivered_customer_date, order_approved_at, units = "days")),
    dias_estimativa = as.numeric(difftime(order_estimated_delivery_date, order_purchase_timestamp, units = "days")),
    dias_real = as.numeric(difftime(order_delivered_customer_date, order_purchase_timestamp, units = "days"))
  )

# Selecionar colunas importantes
base_modelo <- base %>%
  select(order_id, atraso, dias_envio, dias_estimativa, dias_real,
         product_category_name, review_score, customer_state)

# Remover linhas com NA
base_modelo <- base_modelo %>%
  drop_na(atraso, dias_envio, dias_estimativa, dias_real, review_score, product_category_name, customer_state)

# Reduzir categorias de produto para as 20 mais frequentes
categorias_mais_frequentes <- base_modelo %>%
  count(product_category_name, sort = TRUE) %>%
  top_n(20, n) %>%
  pull(product_category_name)

# Substituir categorias menos frequentes por "outros"
base_modelo <- base_modelo %>%
  mutate(product_category_name = if_else(product_category_name %in% categorias_mais_frequentes,
                                         product_category_name,
                                         "outros")) %>%
  mutate(product_category_name = as.factor(product_category_name))

# Transformar variáveis categóricas
base_modelo <- base_modelo %>%
  mutate(
    atraso = factor(atraso),
    customer_state = as.factor(customer_state)
  )

# Divisão treino/teste
set.seed(123)
indices <- sample(1:nrow(base_modelo), 0.7 * nrow(base_modelo))
treino <- base_modelo[indices, ]
teste <- base_modelo[-indices, ]

# Treinamento do modelo Random Forest
modelo_rf <- randomForest(
  atraso ~ dias_envio + dias_estimativa + dias_real + review_score + product_category_name + customer_state,
  data = treino,
  ntree = 100,
  importance = TRUE
)

# Exibir resultado do modelo
print(modelo_rf)

# Plotar importância das variáveis
varImpPlot(modelo_rf)

# Prever no conjunto de teste
predicoes <- predict(modelo_rf, newdata = teste)

# Matriz de confusão
confusao <- table(Predito = predicoes, Real = teste$atraso)
print(confusao)

# Calcular acurácia
acuracia <- sum(diag(confusao)) / sum(confusao)
cat("Acurácia no conjunto de teste:", round(acuracia * 100, 2), "%\n")

# Salvar modelo em disco
saveRDS(modelo_rf, "modelo_random_forest_olist.rds")
