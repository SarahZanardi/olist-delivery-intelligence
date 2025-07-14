# 🚚 Olist Delivery Delay Prediction 📦

Projeto de análise e modelagem preditiva para identificar atrasos na entrega dos pedidos do Olist, utilizando Random Forest. 🌲

---

## 📋 Descrição

Este projeto tem como objetivo prever se um pedido terá atraso na entrega com base em variáveis relacionadas ao tempo de envio, categoria do produto, avaliação do cliente e estado do cliente. Utiliza o dataset do Olist, uma base pública de e-commerce, para treinar e testar um modelo de machine learning do tipo Random Forest.

---

## 🛠️ Tecnologias e Bibliotecas

- R (versão >= 4.0) 🐍
- tidyverse 🌐
- data.table 📊
- janitor 🧹
- lubridate 📅
- randomForest 🌲

---

## 📂 Estrutura do Projeto

- `olist_orders_dataset.csv` 📝: Dados dos pedidos.
- `olist_order_items_dataset.csv` 📦: Itens de cada pedido.
- `olist_order_reviews_dataset.csv` ⭐: Avaliações dos pedidos.
- `olist_products_dataset.csv` 🛍️: Informações dos produtos.
- `olist_customers_dataset.csv` 👥: Dados dos clientes.
- `modelo_random_forest_olist.rds` 💾: Modelo treinado salvo em disco.
- `script_modelagem.R` ⚙️: Script para pré-processamento, modelagem e avaliação.

---

## 🚀 Passos para rodar o projeto

1. Clone este repositório:

```bash
git clone https://github.com/sarah.zanardi/olist-delivery-delay-prediction.git
