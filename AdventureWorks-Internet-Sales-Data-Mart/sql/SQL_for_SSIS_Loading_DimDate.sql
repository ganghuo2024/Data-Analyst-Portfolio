DECLARE @startdate DATE = '20100101'
    , @enddate DATE = '20171231' ;

;WITH c
AS (
    SELECT  Num = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1
    FROM sys.columns c
    CROSS JOIN sys.columns c1
    )
, d
AS (
    SELECT  [date] = DATEADD(day, Num, @startdate), Num
    FROM c
    WHERE Num >= 0 AND Num <= DATEDIFF(day, @startdate, @enddate)
    )
SELECT DateKey = CAST(CONVERT(VARCHAR(8), DATEADD(day, Num, @startdate), 112) AS INT)
    , [date] AS FullDateAlternateKey
    , [DayNumberOfWeek] = DATEPART(weekday, [Date])
    , [DayNameOfWeek] = DATENAME(weekday, [Date])
    , [DayNumberOfMonth] = DATEPART(day, [Date])
    , [DayNumberOfYear] = DATEPART(dayofyear, [Date])
    , [WeekNumberOfYear] = DATEPART(week, [Date])
    , [MonthName] = DATENAME(month, [Date])
    , [MonthNumberOfYear] = DATEPART(month, [Date])
    , [CalendarQuarter] = DATEPART(quarter, [Date])
    , [CalendarYear] = YEAR([date])
    , [CalendarSemester] = ((DATEPART(quarter,[Date])-1)/2)+1
--Add more columns as needed.
FROM d