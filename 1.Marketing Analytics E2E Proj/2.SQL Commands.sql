SELECT TOP (1000) [ProductID]
      ,[ProductName]
      ,[Category]
      ,[Price]
  FROM [PortfolioProject_MarketingAnalytics].[dbo].[products];

--********************************************************************


-- Query to categorize the Product based on price


SELECT [ProductID], [ProductName], [Price],

CASE 
WHEN Price < 50 THEN 'Low'
WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
ELSE 'High'
END AS 'Price Category'

FROM dbo.products

Order BY Price;


--********************************************************************

Select * from dbo.customers;
select * from dbo.geography;

--********************************************************************

--SQL Statement to join both the customer and geography table to enrich the data

Select c.CustomerID,c.CustomerName,c.Email,c.Gender,c.Age,c.GeographyID,g.Country,g.City
from dbo.customers as c
left join
-- right join
-- inner join
-- full outer join
dbo.geography as g
ON c.GeographyID = g.GeographyID
Order By GeographyID;


--********************************************************************

select * from dbo.customer_reviews;


--********************************************************************


--Query to replace double spaces in the review text 
--And clean Engagement Table

select ReviewID, CustomerID, ProductID, ReviewDate, Rating, 
--ReviewText,
replace (ReviewText, '  ' , ' ' ) AS ReviewText
from dbo.customer_reviews

--********************************************************************

select * from dbo.engagement_data;

--********************************************************************

Select EngagementId, ContentId, CampaignID, ProductID,
UPPER(Replace(ContentType,'Socialmedia', 'Social Media')) AS ContentType,
LEFT(ViewsClicksCombined,CHARINDEX('-',ViewsClicksCombined)-1) AS Views,
RIGHT (ViewsClicksCombined,LEN(ViewsClicksCombined) - CHARINDEX('-',ViewsClicksCombined)) AS Clicks,
Likes,
FORMAT(CONVERT(DATE,EngagementDate),'dd-mm-yyyy') AS EngagementDate
From dbo.engagement_data

--********************************************************************

select * from dbo.customer_journey;

--********************************************************************

--To remove the duplicate records

WITH DuplicateRecords AS (
Select JourneyID,CustomerID, ProductID, VisitDate, Stage,Action,Duration,
ROW_NUMBER() OVER( 
PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
ORDER BY JourneyID) 
AS RowNum
from dbo.customer_journey)

--to get the list of duplicate records from the Duplicate records(A temporary Table) 
Select * 
from DuplicateRecords
Where RowNum > 1
Order BY JourneyID


--********************************************************************

--Selecting the cleaned non-duplicate data
Select 
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COALESCE(Duration, avg_duration) AS Duration
From
    (Select 
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        UPPER(Stage) AS Stage,
        Action,
        Duration,
        AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,
        ROW_NUMBER() OVER(
        PARTITION BY CustomerID, ProductID,VisitDate,UPPER(Stage),Action
        ORDER BY JourneyID) AS row_num
    FROM dbo.customer_journey)
AS subquery
WHERE row_num= 1
ORDER BY JourneyID;



