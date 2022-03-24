-- 1 
/*
Qual será a correlação de Pearson entre qtde de clientes por estado e qtde de sellers por estado ?
*/
SELECT CORR(QtdVendedores, QtdClientes) AS Correlacao
FROM (
        WITH Clientes AS (
                            SELECT COUNT(*) AS QtdClientes, 
                                        customer_state AS Estado
                            FROM  `polar-surfer-342122.Olist.Customers`
                            GROUP BY customer_state
                        )   

        SELECT  seller_state AS Estado,
                COUNT(*) AS QtdVendedores,
                SUM(QtdClientes) AS QtdClientes
        FROM  `polar-surfer-342122.Olist.Sellers` AS Vendedores
        INNER JOIN Clientes 
        ON Clientes.Estado = Vendedores.seller_state
        GROUP BY seller_state
    );

-- 2
/*
Qual será a correlação de Pearson entre o preço médio de um produto e quantidade de clientes que compraram esse produto?
*/

SELECT CORR(MediaPrecos, QtdClientes) AS Correlacao
FROM (
        SELECT DISTINCT Itens.product_id AS IdProduto, 
            AVG(Itens.price) OVER(PARTITION BY Itens.product_id) AS MediaPrecos,
            COUNT(Itens.product_id) OVER(PARTITION BY Pedidos.customer_id) AS QtdClientes
            
        FROM `polar-surfer-342122.Olist.Items` AS Itens 
        INNER JOIN `polar-surfer-342122.Olist.Orders` AS Pedidos
        ON Itens.order_id = Pedidos.order_id
    );

/* (RESOLUCAO)
with produtos as (
                    select 
                    avg(price) preco_medio,
                    count(distinct Clientes.customer_unique_id) clientes,
                    product_id
                    from `olist-342122.olist.OrdersItems` Items
                    inner join `olist-342122.olist.Orders` Pedidos on Items.order_id = Pedidos.order_id
                    inner join `olist-342122.olist.Customers` Clientes on Clientes.customer_id = Pedidos.customer_id
                    group by product_id)

select corr(preco_medio,clientes) correlacao from produtos;

*/

-- 3
/*
Encontre os valores máximo, mínimo, média, mediana, percentil 25 e 75, e desvio padrão da quantidade 
de clientes por cidade do estado de SP. Por exemplo, em média uma cidade tem quantos clientes?
*/
SELECT MAX(QtdClientes) OVER() AS MaxCliente, MIN(QtdClientes) OVER() AS MinCliente, 
        AVG(QtdClientes) OVER() AS MediaClientes, PERCENTILE_CONT(QtdClientes, 0.5) OVER()  AS MedianaClientes,
        PERCENTILE_CONT(QtdClientes, 0.25) OVER() AS Percentil25,
        PERCENTILE_CONT(QtdClientes, 0.75) OVER() AS Percentil75,
        STDDEV_POP(QtdClientes) OVER() AS DesvioPadrao
FROM (
    SELECT customer_city AS Cidade, COUNT(DISTINCT customer_unique_id) AS QtdClientes          
    FROM `polar-surfer-342122.Olist.Customers`
    WHERE customer_state = 'SP'
    GROUP BY Cidade
)
LIMIT 1;

--4 
/*
Encontre os valores máximo, mínimo, média, mediana percentil 25 e 75, 
e desvio padrão do valor médio de pagamentos por pedido. 
*/
SELECT MAX(MediaPag) OVER() AS MaxPag, MIN(MediaPag) OVER() AS MinPag, 
        AVG(MediaPag) OVER() AS MediaPag, PERCENTILE_CONT(MediaPag, 0.5) OVER() AS MedianaPag,
        PERCENTILE_CONT(MediaPag, 0.25) OVER() AS Percentil25,
        PERCENTILE_CONT(MediaPag, 0.75) OVER() AS Percentil75,
        STDDEV_POP(MediaPag) OVER() AS DesvioPadrao
FROM (
    SELECT (AVG(payment_value)) AS MediaPag       
    FROM `polar-surfer-342122.Olist.OrderPayments`
)
LIMIT 1;

--5
/*
Encontre os valores máximo, mínimo, média, mediana percentil 25 e 75, 
e desvio padrão da avaliação média por vendedor.
*/
SELECT MAX(MediaReview) OVER() AS MaxReview, MIN(MediaReview) OVER() AS MinReview, 
        AVG(MediaReview) OVER() AS MediaReview,
        PERCENTILE_CONT(MediaReview, 0.5) OVER() AS MedianaRevew, 
        PERCENTILE_CONT(MediaReview, 0.25) OVER() AS Percentil25,
        PERCENTILE_CONT(MediaReview, 0.75) OVER() AS Percentil75,
        STDDEV_POP(MediaReview) OVER() AS DesvioPadrao
FROM (
    SELECT DISTINCT Pedidos.seller_id AS IdVendedor, AVG(Avaliacoes.review_score) OVER(PARTITION BY Pedidos.seller_id) AS MediaReview        
    FROM `polar-surfer-342122.Olist.Reviews` AS Avaliacoes
    INNER JOIN `polar-surfer-342122.Olist.OrderItems` AS Pedidos
    ON Avaliacoes.order_id = Pedidos.order_id
)
LIMIT 1;

--6
/*
Qual será a correlação de Pearson entre a avaliação média de um vendedor 
e a quantidade de vendas desse vendedor?
*/
WITH VENDEDORES AS (
                        SELECT AVG(Avaliacoes.review_score) AS MediaAvaliacoes,
                                COUNT(DISTINCT Itens.order_id) AS Qtd_Vendas,
                                Itens.seller_id AS Vendedor
                        FROM `polar-surfer-342122.Olist.OrderItems` AS Itens
                        LEFT JOIN `polar-surfer-342122.Olist.Reviews` AS Avaliacoes
                        ON Itens.order_id = Avaliacoes.order_id
                        GROUP BY Vendedor
                )
SELECT CORR(MediaAvaliacoes, Qtd_Vendas) AS Correlacao
FROM VENDEDORES;
--7
/*
Quantas e quais cidades de MG são responsáveis por 80% das vendas? Faça a análise de pareto.
*/
WITH CIDADES AS (
                SELECT Vendedores.seller_city AS Cidade,
                        COUNT(DISTINCT Pedidos.order_id) AS Qtd_Vendas
                FROM `polar-surfer-342122.Olist.Sellers` AS Vendedores
                INNER JOIN `polar-surfer-342122.Olist.OrderItems` AS Pedidos
                ON Vendedores.seller_id = Pedidos.seller_id
                WHERE seller_state = 'MG'
                GROUP BY Cidade
                )
SELECT Cidade,
        SUM(Qtd_Vendas) OVER() AS TotalVendas,
        SUM(Qtd_Vendas) OVER(ORDER BY Qtd_Vendas DESC) AS VendasAcumuladas,
        ROW_NUMBER() OVER(ORDER BY Qtd_vendas DESC) AS Quantidade_Cidades,
        ROUND(SUM(Qtd_Vendas) OVER(ORDER BY Qtd_Vendas DESC) / SUM(Qtd_Vendas)
        OVER(), 2) AS PercentVendas,
        ROUND(ROW_NUMBER() OVER(ORDER BY Qtd_vendas DESC) / COUNT(DISTINCT Cidade) 
        OVER(), 2) AS PercentCidades
FROM CIDADES
