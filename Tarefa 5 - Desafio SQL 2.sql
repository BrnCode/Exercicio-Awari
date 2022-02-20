-- Questão 1. retorne a quantidade de itens vendidos em cada categoria por estado em que o cliente se encontra, 
-- mostrando somente categorias que tenham vendido uma quantidade de items acima de 1000.

Select A.product_category_name, COUNT(B.product_id) as qtd_vendida
From olist_products_dataset AS A	
iNNER join olist_order_items_dataset as B 
on A.product_id = B.product_id
WHere A.product_category_name is Not NULL
group by A.product_category_name
HAVING COUNT(B.product_id) > 1000
limit 100;

SELECT C.order_id, D.customer_state
FROm olist_orders_dataset as C
inner join olist_customers_dataset as D
ON C.customer_id = D.customer_id
limit 100;

-- Não sei como juntas as duas queries pelos order_id do olist_order_items_dataset com do olist_orders_dataset 
-- que é onde eu imagino que tenha a relação das duas queries.

-- Questão 2. mostre os 5 clientes (customer_id) que gastaram mais dinheiro em compras, qual foi o valor total de todas as compras deles, 
-- quantidade de compras, e valor médio gasto por compras. Ordene os mesmos por ordem decrescente pela média do valor de compra.
SELECT *
FROm olist_customers_dataset
limit 100;

SELECT *
FROm olist_order_payments_dataset
limit 100;

select C.customer_id as cliente_id, count(B.order_id) as qtd_compras,
SUM(A.payment_value) as gasto_total, AVG(A.payment_value) as media_compras
from olist_order_payments_dataset as A	
left join olist_orders_dataset as B
	On A.order_id = B.order_id
left join olist_customers_dataset as C 
	On B.customer_id = C.customer_id
group by C.customer_id, B.order_id
order by media_compras desc 
limit 5;

-- Aparemente quem gastou mais fez uma compra só de valor imenso.


-- Questão 3. mostre o valor vendido total de cada vendedor (seller_id) em cada uma das categorias de produtos, 
-- somente retornando os vendedores que nesse somatório e agrupamento venderam mais de $1000. 
-- Desejamos ver a categoria do produto e os vendedores. Para cada uma dessas categorias, mostre seus valores de venda de forma decrescente.
SELECT SUM(A.price) as valor_total_vendido, A.seller_id as id_vendedor, 
B.product_category_name
from olist_order_items_dataset as A
LEFT join olist_products_dataset as B 
on A.product_id = B.product_id
WHere B.product_category_name is Not NULL
group by B.product_category_name
HAVING SUM(A.price) > 1000
order by B.product_category_name, SUM(price) desc 









