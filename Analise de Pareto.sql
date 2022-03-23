WITH VENDAS AS (
                SELECT ROUND(SUM(Itens.price), 2) AS ValorVendas,
                    IFNULL(Produtos.product_category_name, 'Sem Categoria') AS Categoria

                FROM `polar-surfer-342122.Olist.OrderItems` AS Itens
                INNER JOIN `polar-surfer-342122.Olist.Products` AS Produtos 
                ON Itens.product_id = Produtos.product_id
                GROUP BY Categoria
                ORDER BY ValorVendas DESC
                )

SELECT Categoria, ValorVendas, 
        PercentualVendasAcumuladas,
        PercentualCategAcumulado
FROM (
        SELECT Categoria, ValorVendas, 
            SUM(ValorVendas) OVER() AS TotalVendas,
            SUM(ValorVendas) OVER(ORDER BY ValorVendas DESC) AS TotalVendasAcumuladas,
            ROUND((SUM(ValorVendas) OVER(ORDER BY ValorVendas DESC) / SUM(ValorVendas) 
            OVER())* 100, 2)  AS PercentualVendasAcumuladas,
            COUNT(Categoria) OVER() AS TotalCategorias,
            ROW_NUMBER() OVER(ORDER BY ValorVendas DESC) AS Qtd_Categ_Acumulado,
            ROUND((ROW_NUMBER() OVER(ORDER BY ValorVendas DESC) / COUNT(Categoria) 
            OVER()) * 100, 2) AS  PercentualCategAcumulado
        FROM VENDAS
    )