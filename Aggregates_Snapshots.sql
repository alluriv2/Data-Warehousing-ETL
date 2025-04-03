---- Creating Product Category Dimension Table

CREATE TABLE ProductCategoryDimension AS
SELECT DISTINCT CategoryID, CategoryName
FROM ProductDimension

ALTER TABLE ProductCategoryDimension
ADD CategoryKey INT AUTO_INCREMENT PRIMARY KEY



---- Creating One Way Aggregation by Product Category 

CREATE TABLE One_Way_Revenue_Agg_By_Product_Cat AS
SELECT SUM(r.UnitSold) as TotalUnitsSold, SUM(r.RevenueGenerated) AS TotalRevenueGenerated, r.CustomerKey, r.StoreKey, r.CalendarKey, pcd.CategoryKey
FROM RevenueAndUnits r, ProductCategoryDimension pcd, ProductDimension pd
WHERE pd.ProductKey = r.ProductKey AND pcd.CategoryID = pd.CategoryID
GROUP BY r.CustomerKey, r.StoreKey, r.CalendarKey, pcd.CategoryKey;

ALTER TABLE One_Way_Revenue_Agg_By_Product_Cat
ADD PRIMARY KEY(CalendarKey, CustomerKey, StoreKey, CategoryKey);



--- Creating both Product Category Dimension and One Way aggregation by product category tables to data ware housing from data staging 

CREATE TABLE alluriv_ZAGIMORE_DW.ProductCategoryDimension AS
SELECT * FROM ProductCategoryDimension;
ALTER TABLE alluriv_ZAGIMORE_DW.ProductCategoryDimension
ADD PRIMARY KEY(CategoryKey);

CREATE TABLE alluriv_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat AS
SELECT * FROM One_Way_Revenue_Agg_By_Product_Cat;
ALTER TABLE alluriv_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
ADD PRIMARY KEY(CalendarKey, CustomerKey, StoreKey, CategoryKey);

ALTER TABLE alluriv_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
ADD Foreign Key (CalendarKey) REFERENCES alluriv_ZAGIMORE_DW.CalendarDimension(CalendarKey),
ADD Foreign Key(CustomerKey) REFERENCES alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey),
ADD Foreign Key(StoreKey) REFERENCES alluriv_ZAGIMORE_DW.StoreDimension(StoreKey),
ADD Foreign Key(CategoryKey) REFERENCES alluriv_ZAGIMORE_DW.ProductCategoryDimension(CategoryKey);



--- creating daily store snapshot table in DS and DW

CREATE TABLE Daily_Store_Snapshot AS
SELECT SUM(r.UnitSold) as TotalUnitsSold, SUM(r.RevenueGenerated) AS TotalRevenueGenerated, COUNT(DISTINCT(r.TransactionID)) AS TotalNumberOfTransactions, AVG(RevenueGenerated) AS AverageRevenue, r.StoreKey, r.CalendarKey
FROM RevenueAndUnits r
GROUP BY r.StoreKey, r.CalendarKey;

CREATE TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot AS
SELECT * FROM Daily_Store_Snapshot
ALTER TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot
ADD PRIMARY KEY(CalendarKey,StoreKey);

ALTER TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot
ADD Foreign Key(StoreKey) REFERENCES alluriv_ZAGIMORE_DW.StoreDimension(StoreKey),
ADD Foreign Key (CalendarKey) REFERENCES alluriv_ZAGIMORE_DW.CalendarDimension(CalendarKey)


------- Adding a total footwear revenue column to the daily store snapshot

ALTER TABLE Daily_Store_Snapshot
ADD COLUMN TotalFootwearRevenue DECIMAL(10,0) DEFAULT 0;

CREATE TABLE FootwearRevenue AS
SELECT SUM(r.RevenueGenerated) AS TotalFootwearRevenue, r.StoreKey, r.CalendarKey
FROM RevenueAndUnits r, ProductDimension pd
WHERE pd.ProductKey = r.ProductKey AND pd.CategoryName = 'Footwear'
GROUP BY r.StoreKey, r.CalendarKey;
 

------ Updating the Dailystoresnapshot table with TotalfootwearRevenue

UPDATE Daily_Store_Snapshot ds, FootwearRevenue fr
SET ds.TotalFootwearRevenue = fr.TotalFootwearRevenue
WHERE ds.CalendarKey = fr.CalendarKey AND ds.StoreKey = fr.StoreKey


----- Adding local revenue column to the snapshot

ALTER TABLE Daily_Store_Snapshot
ADD COLUMN TotalLocalRevenue DECIMAL(10,0) DEFAULT 0;

CREATE TABLE TotalLocalRevenue AS
SELECT SUM(r.RevenueGenerated) AS TotalFootwearRevenue, r.StoreKey, r.CalendarKey
FROM RevenueAndUnits r, StoreDimension sd, CustomerDimension cd
WHERE sd.StoreKey = r.StoreKey AND cd.CustomerKey = r.CustomerKey AND LEFT(cd.CustomerZIP,2) = LEFT(sd.StoreZIP,2)
GROUP BY r.StoreKey, r.CalendarKey;

------ Updating the Dailystoresnapshot table with TotalLocalRevenue

UPDATE Daily_Store_Snapshot ds, TotalLocalRevenue lr
SET ds.TotalLocalRevenue = lr.TotalLocalRevenue
WHERE ds.CalendarKey = lr.CalendarKey AND ds.StoreKey = lr.StoreKey


------- Adding High value transaction count column to the snapshot

ALTER TABLE Daily_Store_Snapshot
ADD COLUMN HighValueTransCnt INT DEFAULT 0;

CREATE TABLE HighValueTransCnt AS
SELECT COUNT(DISTINCT r.TransactionID) AS HighValueTransCnt, r.StoreKey, r.CalendarKey
FROM RevenueAndUnits r
WHERE r.TransactionID IN 
(SELECT r.TransactionID
FROM RevenueAndUnits r
GROUP BY r.TransactionID
HAVING SUM(r.RevenueGenerated) > 100)
GROUP BY r.StoreKey, r.CalendarKey;


------ Updating the Dailystoresnapshot table with High Value transaction count

UPDATE Daily_Store_Snapshot ds, HighValueTransCnt hvtc
SET ds.HighValueTransCnt = hvtc.HighValueTransCnt
WHERE ds.CalendarKey = hvtc.CalendarKey AND ds.StoreKey = hvtc.StoreKey

------ Dropping and recreating snapshot in Data Warehouse

DROP TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot
CREATE TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot AS
SELECT *
FROM alluriv_ZAGIMORE_DS.Daily_Store_Snapshot

-- Adding Connections in Dataware house database
ALTER TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot
ADD PRIMARY KEY (CalendarKey, StoreKey);

ALTER TABLE alluriv_ZAGIMORE_DW.Daily_Store_Snapshot
ADD FOREIGN KEY (CalendarKey) REFERENCES alluriv_ZAGIMORE_DW.CalendarDimension(CalendarKey),
ADD FOREIGN KEY (StoreKey) REFERENCES alluriv_ZAGIMORE_DW.StoreDimension(StoreKey);