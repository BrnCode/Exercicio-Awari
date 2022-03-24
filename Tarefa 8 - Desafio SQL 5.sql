/*
1 - Crie os índices apropriadaos para as atbelas do nosso modelo de dados com o intuito de melhorar a performance.
*/
SELECT ROW_NUMBER() OVER() AS Row_Identifier, *
FROM `polar-surfer-342122.Olist.Orders`

/*
2 - (Opcional) Crie índices cluesterizados. Lembre-se que, para isso, 
você deverá recriar a tabela para poder criar as Primary e Foreign Keys.
*/
SELECT ROW_NUMBER() OVER (PARTITION BY order_status ORDER BY order_approved_at) AS Line_Identifier, *
FROM `polar-surfer-342122.Olist.Orders`
