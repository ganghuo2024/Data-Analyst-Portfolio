/*Exploratory Database Analysis*/

USE AdventureWorks2019
GO
SELECT
 [Schema] =N0.Name,
 TableView = ISNULL (N2.Name, N3.Name),
 ObjectView =
 CASE
 WHEN N2.Name IS NOT NULL
 THEN 'Table'
 ELSE 'View'
 END,
 ColName = N1.Name
INTO #data
FROM sys.columns N1
LEFT JOIN sys.tables N2
	ON N1.OBJECT_ID = N2.OBJECT_ID
LEFT JOIN sys.views N3
 ON N1.OBJECT_ID = N3.OBJECT_ID
LEFT JOIN sys.schemas N0
 	ON N0.SCHEMA_ID=N2.SCHEMA_ID OR N0.SCHEMA_ID=N3.SCHEMA_ID
WHERE N2.OBJECT_ID IS NOT NULL
 OR N3.OBJECT_ID IS NOT NULL
ORDER BY [Schema],TableView,ObjectView;

SELECT *, ROW_NUMBER() OVER (PARTITION BY [Schema],TableView 
							ORDER BY [Schema],TableView) ColNum
FROM #data WHERE ObjectView='Table'
UNION
SELECT *, ROW_NUMBER() OVER (PARTITION BY [Schema],TableView 
							ORDER BY [Schema],TableView) ColNum
FROM #data WHERE ObjectView='View';