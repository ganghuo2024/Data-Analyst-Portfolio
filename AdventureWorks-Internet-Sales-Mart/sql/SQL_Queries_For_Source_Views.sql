--Source for View DimCustomerDemographics
use AdventureWorks2019
go


CREATE VIEW dbo.etl_vCustomerDemographics AS

SELECT        p.[BusinessEntityID], x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        TotalPurchaseYTD[1]', 'money') AS [TotalPurchaseYTD], 
                         CONVERT(datetime, REPLACE(x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        DateFirstPurchase[1]', 'nvarchar(20)'), 'Z', ''), 101) 
                         AS [DateFirstPurchase], CONVERT(datetime, REPLACE(x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        BirthDate[1]', 
                         'nvarchar(20)'), 'Z', ''), 101) AS [BirthDate], x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        MaritalStatus[1]', 'nvarchar(1)') 
                         AS [MaritalStatus], x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        YearlyIncome[1]', 'nvarchar(30)') AS [YearlyIncome], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Gender[1]', 'nvarchar(1)') AS [Gender], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        TotalChildren[1]', 'integer') AS [TotalChildren], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        NumberChildrenAtHome[1]', 'integer') AS [NumberChildrenAtHome], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Education[1]', 'nvarchar(30)') AS [Education], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Occupation[1]', 'nvarchar(30)') AS [Occupation], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        HomeOwnerFlag[1]', 'bit') AS [HomeOwnerFlag], 
                         x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        NumberCarsOwned[1]', 'integer') AS [NumberCarsOwned],
						x.XmlCol.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        CommuteDistance[1]', 'nvarchar(15)') AS [CommuteDistance]

FROM            [Sales].[vIndividualCustomer] p CROSS APPLY p.[Demographics].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; /IndividualSurvey') x(XmlCol);


-- Soucre for View DimProduct
USE AdventureWorks2019
GO 
CREATE VIEW dbo.etl_DimProduct AS	
SELECT        ppm.Name AS ModelName, pp.DiscontinuedDate, pp.SellEndDate, pp.SellStartDate, pp.ProductModelID, 
                         pp.ProductSubcategoryID, pp.Style, pp.Class, pp.ProductLine, pp.DaysToManufacture, pp.Weight, 
                         pp.WeightUnitMeasureCode, pp.SizeUnitMeasureCode, pp.Size,
				CASE WHEN pp.Size='38' OR pp.Size='39' OR pp.Size='40'  THEN '38-40 CM'
					WHEN pp.Size='42' OR pp.Size='43' OR pp.Size='44' OR pp.Size='45' OR pp.Size='46' THEN '42-46 CM'
					WHEN pp.Size='48' OR pp.Size='49' OR pp.Size='50' OR pp.Size='51' OR pp.Size='52' THEN '48-52 CM'
					WHEN pp.Size='54' OR pp.Size='55' OR pp.Size='56' OR pp.Size='57' OR pp.Size='58' THEN '54-58 CM'
					WHEN pp.Size='60' OR pp.Size='61' OR pp.Size='62' THEN '60-62 CM'
					WHEN pp.Size='70' THEN '70 CM'
					WHEN pp.Size='S' THEN 'S'
					WHEN pp.Size='M' THEN 'M'
					WHEN pp.Size='L' THEN 'L'
					WHEN pp.Size='XL' THEN 'XL'
					ELSE 'NA'
					END
					AS SizeRange,
 					pp.ListPrice, pp.StandardCost, pp.ReorderPoint, 
                    pp.SafetyStockLevel, pp.Color, pp.FinishedGoodsFlag, pp.MakeFlag, pp.ProductNumber, pp.Name AS ProductName, pp.ProductID

FROM            Production.Product pp LEFT JOIN
                         Production.ProductModel ppm ON pp.ProductModelID = ppm.ProductModelID;
--Source for View FactInternetSales
USE AdventureWorks2019
GO

CREATE View dbo.etl_FactInternetSales AS 
SELECT soh.[SalesOrderNumber],  
    CAST( ROW_NUMBER() OVER (Partition by soh.[SalesOrderNumber] ORDER BY sod.SalesOrderDetailID) AS tinyint) AS LineNumber,
    CAST( [OrderDate] AS Date) AS OrderDate, 
    CAST( [ShipDate]  AS Date) AS ShipDate,  
    p.ProductNumber AS ProductID, 
    CAST( c.AccountNumber as nvarchar(10)) AS AccountNumber, soh.[TerritoryID], 
-- measures
    sod.OrderQty, sod.LineTotal AS [SubTotal], sod.UnitPrice AS UnitPrice      ,[TaxAmt]      ,[Freight]      ,[TotalDue], 
	p.StandardCost,
-- order fact columns
    soh.[PurchaseOrderNumber],
		psp.CountryRegionCode,
		CAST (CASE psp.CountryRegionCode
		WHEN 'US' THEN 'USD'
		WHEN 'CA' THEN 'CAD'
		WHEN 'FR' THEN 'FRF'
		WHEN 'DE' THEN 'DEM'
		WHEN 'GB' THEN 'GBP'
		ELSE 'AUD'
		END 
		as nchar(3)) AS CurrencyCode,
		sod.SpecialOfferID
  FROM Sales.SalesOrderDetail sod
    INNER JOIN [Sales].[SalesOrderHeader] soh 
      ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Sales.Customer c 
      ON c.CustomerID = soh.CustomerID
    INNER JOIN Production.Product p 
      ON p.ProductID = sod.ProductID
		INNER JOIN Person.Address pa
	ON soh.BillToAddressID=pa.AddressID
	INNER JOIN Person.StateProvince psp
	ON pa.StateProvinceID=psp.StateProvinceID
	where OnlineOrderFlag = 1 ;	
