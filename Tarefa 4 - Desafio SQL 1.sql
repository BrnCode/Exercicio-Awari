SELECT * FROM olist_order_payments_dataset
limit 100;

-- Questão 1. selecione os dados da tabela de pagamentos onde só apareçam os tipos de pagamento “VOUCHER” e “BOLETO”.
SELECT *
from olist_order_payments_dataset
where payment_type IN ('boleto', 'voucher')
limit 100;

-- Questão 2. retorne os campos da tabela de produtos e calcule o volume de cada produto em um novo campo.
SELECT * FROM olist_products_dataset
limit 100;

SELECT *, COUNT(product_category_name) as volume_produto
FROM olist_products_dataset
GROUP by product_category_name
limit 100;

-- Tirando o NULL dos resultados
SELECT *, COUNT(product_category_name) as volume_produto
FROM olist_products_dataset
Where product_category_name is NOT NULL
GROUP by product_category_name
limit 100;

-- Questão 3. retorne somente os reviews que não tem comentários.
SELECT * FROM olist_order_reviews_dataset
limit 100;

SELECT * 
from olist_order_reviews_dataset
where review_comment_title is NULL
and review_comment_message is NULL
limit 100;

-- Tem como fazer isso de um jeito mais bonito? Sem precisar usar WHERE e AND, não consegui colocar duas condições dentro do WHERE 

-- Questão 4.retorne pedidos que foram feitos somente no ano de 2017. 
SELECT *
FROM olist_orders_dataset
WHERE order_purchase_timestamp LIKE '2017%'
ORDER BY order_purchase_timestamp DESC
LIMIT 100;

-- Questão 5. encontre os clientes do estado de SP e que não morem na cidade de São Paulo.
SELECT *
From olist_geolocation_dataset
limit 100;

SELECT *
From olist_geolocation_dataset
where geolocation_city LIKE '__o _aulo'
limit 100;

SELECT *
From olist_customers_dataset
Where customer_state = 'SP'
AND customer_city <> '__o _aulo'
GROUP BY customer_city
limit 100;
