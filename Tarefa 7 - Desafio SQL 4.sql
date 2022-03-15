/*
Exericio 1 - Crie uma view (SELLER_STATS) para mostrar por fornecedor, a quantidade de itens enviados (orders/items), 
o tempo médio de postagem após a aprovação da compra(orders), a quantidade total de pedidos de cada Fornecedor(orders /items), 
note que trabalharemos na mesma query com 2 granularidades diferentes.
*/
CREATE VIEW `polar-surfer-342122.Olist.SELLER_STATS` AS 
                                                        SELECT 
                                                            Vendedores.seller_id as IdVendedores,
                                                            ROUND(AVG(DATETIME_DIFF(Pedidos.order_delivered_carrier_date, Pedidos.order_approved_at, DAY)), 2) AS TempoMedioPostagem, --Como eu faço pra colocar TempoMédio(Dias) ou coloco dia lá no resultado da query?
                                                            Count(*) as Qtd_Vendas,
                                                            COUNT(DISTINCT Pedidos.order_id) AS ItensVendidos,
                                                        FROM `polar-surfer-342122.Olist.Orders` AS Pedidos
                                                        INNER JOIN `polar-surfer-342122.Olist.Items` AS Itens
                                                        ON Pedidos.order_id = Itens.order_id
                                                        INNER JOIN `polar-surfer-342122.Olist.Sellers` as Vendedores
                                                        On Itens.seller_id = Vendedores.seller_id
                                                        GROUP BY IdVendedores
                                                        ORDER BY Qtd_Vendas DESC
                                                        LIMIT 100;

/*
Queremos dar um cupom de 10% do valor da última compra do cliente. 
Porém os clientes elegíveis a este cupom devem ter feito uma compra 
anterior a última (A partir da data de aprovação do pedido) 
que tenha sido maior ou igual o valor da última compra 
e também queremos saber os valores dos cupons para cada um dos clientes elegíveis.
*/
SELECT *
FROM (
        SELECT *,
            LAG(ValorPagamento) OVER (PARTITION BY IdCliente ORDER BY DataAprovacao) AS ValorPedidoAnterior,
            ValorPagamento*0.1 AS ValorCupom
        FROM (
                SELECT Clientes.customer_unique_id AS IdCliente,
                        Pedidos.order_id AS IdPedido,
                        Pedidos.order_approved_at AS DataAprovacao,
                        SUM(Pagamentos.payment_value) AS ValorPagamento,
                FROM `polar-surfer-342122.Olist.Customers` AS Clientes
                INNER JOIN `polar-surfer-342122.Olist.Orders` AS Pedidos
                ON Clientes.customer_id = Pedidos.customer_id
                INNER JOIN `polar-surfer-342122.Olist.OrderPayments` AS Pagamentos
                ON Pagamentos.order_id = Pedidos.order_id
                GROUP BY IdCliente, IdPedido, DataAprovacao
                ORDER BY IdCliente
            )
    )
WHERE ValorPedidoAnterior >= ValorPagamento
LIMIT 100;
