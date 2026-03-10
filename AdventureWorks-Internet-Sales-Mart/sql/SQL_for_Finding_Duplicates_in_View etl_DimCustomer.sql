use AdventureWorks2019

WITH cte AS (
    SELECT 
        CustomerID, YearlyIncome,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CustomerID
            ORDER BY 
                CustomerID
        ) row_num
     FROM 
        dbo.etl_DimCustomer
)
select * from cte
WHERE row_num > 1;