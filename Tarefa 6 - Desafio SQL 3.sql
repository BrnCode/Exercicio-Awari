-- Link para o BigQuery: https://console.cloud.google.com/bigquery?sq=42305503569:52920707052044a081a6022c8dc17acd


-- Exericio 1 - crie uma tabela analítica de todos os itens que foram vendidos, mostrando somente pedidos interestaduais. 
-- Queremos saber quantos dias os fornecedores demoram para postar o produto, se o produto chegou ou não no prazo.

CREATE VIEW `polar-surfer-342122.Olist.Tabela_Analitica_Pedidos` AS 
            SELECT  
                    Itens.product_id AS Produtos,
                    Clientes.customer_state AS EstadoCliente,
                    Vendedores.seller_state AS EstadoVendedor,
                    DATETIME_DIFF(Pedidos.order_delivered_carrier_date, Pedidos.order_approved_at, DAY) AS DiasAtePostar,
                    IF (order_estimated_delivery_date <= order_delivered_customer_date, 'Sim', 'Nao') AS EntreguePrazo
            FROM `polar-surfer-342122.Olist.Orders` as Pedidos
            INNER JOIN `polar-surfer-342122.Olist.Customers` as Clientes
            ON Pedidos.customer_id = Clientes.customer_id
            INNER JOIN `polar-surfer-342122.Olist.OrderItems` as Itens
            ON Pedidos.order_id = Itens.order_id
            INNER JOIN `polar-surfer-342122.Olist.Sellers` AS Vendedores
            on Vendedores.seller_id = Itens.seller_id
            WHERE Clientes.customer_state != Vendedores.seller_state 
            LIMIT 100;

-- Exericio 2 - retorne todos os pagamentos do cliente, com suas datas de aprovação, 
-- valor da compra e o valor total que o cliente já gastou em todas as suas compras, 
-- mostrando somente os clientes onde o valor da compra é diferente do valor total já gasto.

WITH Tabela AS (
                    SELECT
                            Clientes.customer_unique_id AS IdCliente,
                            Pagamentos.payment_value AS ValorCompra,
                            Pedidos.order_approved_at AS DataAprovacao,
                            SUM(Pagamentos.payment_value) OVER(PARTITION BY Clientes.customer_unique_id) AS TotalCompra
                    FROM `polar-surfer-342122.Olist.OrderPayments` as Pagamentos
                    INNER JOIN `polar-surfer-342122.Olist.Orders` as Pedidos
                    On Pagamentos.order_id = Pedidos.order_id
                    INNER JOIN `polar-surfer-342122.Olist.Customers` as Clientes
                    ON Clientes.customer_id = Pedidos.customer_id
                    )
SELECT 
        *
FROM 
    Tabela
WHERE ValorCompra != TotalCompra
ORDER BY TotalCompra DESC
LIMIT 100;

-- Exericio 3 - retorne as categorias válidas, suas somas totais dos valores de vendas, 
-- um ranqueamento de maior valor para menor valor junto com o somatório acumulado dos valores pela mesma regra do ranqueamento.

WITH Tabela AS(
                SELECT 
                        DISTINCT Produtos.product_category_name AS Categoria,
                        SUM(Itens.price) OVER(PARTITION BY product_category_name) AS TotalVendas,
                        RANK() OVER(ORDER BY SUM(Itens.price) DESC) AS Ranking
                FROM `polar-surfer-342122.Olist.Products` AS Produtos
                INNER JOIN `polar-surfer-342122.Olist.OrderItems` AS Itens
                ON Itens.product_id = Produtos.product_id
                WHERE Produtos.product_category_name IS NOT NULL
                GROUP BY Produtos.product_category_name, Itens.price
                ORDER BY TotalVendas DESC
                )
SELECT *,
    SUM(TotalVendas) OVER(ORDER BY TotalVendas DESC) AS SomaAcumulada
FROM Tabela
LIMIT 100;


















