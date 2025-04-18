
--------------------   Product Dimension Refresh Procedure  --------------------

CREATE PROCEDURE ProductDimensionRefresh()
BEGIN

INSERT INTO ProductDimension(ProductID,ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID, CategoryName,ProductType,ExtractionTimestamp,pd_loaded)
SELECT p.productid, p.productname, p.productprice, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Sales',NOW(), FALSE
FROM alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v
WHERE p.categoryid = c.categoryid AND p.vendorid = v.vendorid AND p.productid NOT IN (
    SELECT ProductID
    FROM ProductDimension
    WHERE ProductType = 'Sales'
);

INSERT INTO ProductDimension(ProductID,ProductName,ProductDailyRentalPrice, ProductWeeklyRentalPrice, VendorID, VendorName, CategoryID, CategoryName,ProductType,ExtractionTimestamp,pd_loaded)
SELECT p.productid, p.productname, p.productpricedaily, p.productpriceweekly, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Rental',NOW(), FALSE
FROM alluriv_ZAGIMORE.rentalProducts p, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v
WHERE p.categoryid = c.categoryid AND p.vendorid = v.vendorid AND p.productid NOT IN (
    SELECT ProductID
    FROM ProductDimension
    WHERE ProductType = 'Rental'
);

INSERT INTO alluriv_ZAGIMORE_DW.ProductDimension(ProductKey, ProductID, VendorID, CategoryID, VendorName, CategoryName, ProductName, ProductSalesPrice, ProductWeeklyRentalPrice,ProductDailyRentalPrice, ProductType )
SELECT ProductKey, ProductID, VendorID, CategoryID, VendorName, CategoryName, ProductName, ProductSalesPrice, ProductWeeklyRentalPrice,ProductDailyRentalPrice, ProductType 
FROM alluriv_ZAGIMORE_DS.ProductDimension
WHERE pd_loaded = FALSE;

UPDATE ProductDimension
SET pd_loaded = TRUE;

END



--------------------   Store Dimension Refresh Procedure  --------------------

CREATE PROCEDURE StoreDimensionRefresh()
BEGIN

INSERT INTO StoreDimension(StoreID, StoreZIP, RegionID, RegionName,ExtractionTimestamp, sd_loaded)
SELECT s.storeid, s.storezip, s.regionid, r.regionname, NOW(), FALSE
FROM alluriv_ZAGIMORE.store s, alluriv_ZAGIMORE.region r
WHERE s.regionid = r.regionid AND s.storeid NOT IN (
    SELECT StoreID
    FROM StoreDimension
);

INSERT INTO alluriv_ZAGIMORE_DW.StoreDimension(StoreKey, StoreID, StoreZIP, RegionID, RegionName)
SELECT StoreKey, StoreID, StoreZIP, RegionID, RegionName
FROM alluriv_ZAGIMORE_DS.StoreDimension
WHERE sd_loaded = FALSE;

UPDATE StoreDimension
SET sd_loaded = TRUE;

END



--------------------   Customer Dimension Refresh Procedure  --------------------

CREATE PROCEDURE CustomerDimensionRefresh()
BEGIN

INSERT INTO CustomerDimension(CustomerName, CustomerID, CustomerZIP,ExtractionTimestamp, cd_loaded)
SELECT c.customername, c.customerid, c.customerzip, NOW(), FALSE
FROM alluriv_ZAGIMORE.customer c
WHERE c.customerid NOT IN (
    SELECT CustomerID
    FROM CustomerDimension
);

INSERT INTO alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey,CustomerID,CustomerName,CustomerZIP)
SELECT CustomerKey,CustomerID,CustomerName,CustomerZIP
FROM alluriv_ZAGIMORE_DS.CustomerDimension
WHERE cd_loaded = FALSE;

UPDATE CustomerDimension
SET cd_loaded = TRUE;

END



--------------------   Daily Fact Refresh Procedure  --------------------

CREATE PROCEDURE DailyRegularFactRefresh()
BEGIN
DROP TABLE intermediate_fact;
CREATE TABLE intermediate_fact AS
SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS RevenueGenerated, 'Sales' AS RevenueType, sv.tid AS TransactionID, p.productid AS ProductID, st.storeid AS StoreID, st.customerid AS CustomerID, st.tdate AS FullDate
FROM alluriv_ZAGIMORE.soldvia sv, alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.salestransaction st
WHERE p.productid = sv.productid AND st.tid = sv.tid  
AND st.tdate > 
(
SELECT MAX(DATE(ExtractionTimestamp))
FROM RevenueAndUnits
);

ALTER TABLE intermediate_fact MODIFY RevenueType VARCHAR(25);
INSERT INTO intermediate_fact(UnitsSold, RevenueGenerated, RevenueType, TransactionID, ProductID, StoreID, CustomerID, FullDate )
SELECT 0 AS UnitsSold, r.productpricedaily * rv.duration AS RevenueGenerated, 'Rental, Daily' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'D'
AND rt.tdate > 
(
SELECT MAX(DATE(ExtractionTimestamp))
FROM RevenueAndUnits
);

INSERT INTO intermediate_fact(UnitsSold, RevenueGenerated, RevenueType, TransactionID, ProductID, StoreID, CustomerID, FullDate )
SELECT 0 AS UnitsSold, r.productpriceweekly * rv.duration AS RevenueGenerated, 'Rental, Weekly' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'W'
AND rt.tdate > 
(
SELECT MAX(DATE(ExtractionTimestamp))
FROM RevenueAndUnits
);

INSERT INTO RevenueAndUnits(UnitSold, RevenueGenerated, RevenueType,TransactionID, CustomerKey, StoreKey, ProductKey, CalendarKey, ExtractionTimestamp, f_loaded)
SELECT i.UnitsSold, i.RevenueGenerated, i.RevenueType, i.TransactionID, cud.CustomerKey, sd.StoreKey, pd.ProductKey, cad.CalendarKey, NOW(), FALSE
FROM intermediate_fact i, CustomerDimension cud, StoreDimension sd, ProductDimension pd, CalendarDimension cad
WHERE i.CustomerID = cud.CustomerID AND sd.StoreId = i.StoreID AND pd.ProductId = i.ProductID AND LEFT(pd.ProductType,1) = LEFT(i.RevenueType,1) AND i.FullDate = cad.FullDate;

INSERT INTO alluriv_ZAGIMORE_DW.RevenueAndUnits(RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey)
SELECT RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey
FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
WHERE f_loaded = FALSE;

UPDATE RevenueAndUnits
SET f_loaded = TRUE 
WHERE f_loaded = FALSE;
END



--------------------   Late Arriving Fact Refresh Procedure  --------------------

CREATE PROCEDURE LateArrivingFactRefresh()
BEGIN

DROP TABLE intermediate_fact;
CREATE TABLE intermediate_fact AS
SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS RevenueGenerated, 'Sales' AS RevenueType, sv.tid AS TransactionID, p.productid AS ProductID, st.storeid AS StoreID, st.customerid AS CustomerID, st.tdate AS FullDate
FROM alluriv_ZAGIMORE.soldvia sv, alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.salestransaction st
WHERE p.productid = sv.productid AND st.tid = sv.tid  AND
st.tid NOT IN (
    SELECT TransactionID
    FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
    WHERE RevenueType = 'Sales'
);

ALTER TABLE intermediate_fact MODIFY RevenueType VARCHAR(25);
INSERT INTO intermediate_fact(UnitsSold, RevenueGenerated, RevenueType, TransactionID, ProductID, StoreID, CustomerID, FullDate )
SELECT 0 AS UnitsSold, r.productpricedaily * rv.duration AS RevenueGenerated, 'Rental, Daily' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'D' AND
rt.tid NOT IN (
    SELECT TransactionID
    FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
    WHERE RevenueType LIKE 'R%'
);

INSERT INTO intermediate_fact(UnitsSold, RevenueGenerated, RevenueType, TransactionID, ProductID, StoreID, CustomerID, FullDate )
SELECT 0 AS UnitsSold, r.productpriceweekly * rv.duration AS RevenueGenerated, 'Rental, Weekly' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'W' AND
rt.tid NOT IN (
    SELECT TransactionID
    FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
    WHERE RevenueType LIKE 'R%'
);

INSERT INTO RevenueAndUnits(UnitSold, RevenueGenerated, RevenueType,TransactionID, CustomerKey, StoreKey, ProductKey, CalendarKey, ExtractionTimestamp, f_loaded)
SELECT i.UnitsSold, i.RevenueGenerated, i.RevenueType, i.TransactionID, cud.CustomerKey, sd.StoreKey, pd.ProductKey, cad.CalendarKey, NOW(), FALSE
FROM intermediate_fact i, CustomerDimension cud, StoreDimension sd, ProductDimension pd, CalendarDimension cad
WHERE i.CustomerID = cud.CustomerID AND sd.StoreId = i.StoreID AND pd.ProductId = i.ProductID AND LEFT(pd.ProductType,1) = LEFT(i.RevenueType,1) AND i.FullDate = cad.FullDate;

INSERT INTO alluriv_ZAGIMORE_DW.RevenueAndUnits(RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey)
SELECT RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey
FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
WHERE f_loaded = FALSE;

UPDATE RevenueAndUnits
SET f_loaded = TRUE 
WHERE f_loaded = FALSE;

END



--------------------   Product Dimension Type2 Change Refresh Procedure  --------------------

CREATE PROCEDURE ProductDimensionType2Refresh()
BEGIN

DROP TABLE IF EXISTS ipd;

CREATE TABLE ipd AS
SELECT p.productid, p.productname, c.categoryid, v.vendorid, v.vendorname, c.categoryname, pd.producttype, p.productprice, NULL AS productdailyrentalprice, NULL AS productweeklyrentalprice, NOW() AS ExtractionTimeStamp, FALSE AS pd_loaded, NOW() AS dvf, '2040-01-01' AS dvu, 'c' AS CurrentStatus
FROM alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v, alluriv_ZAGIMORE_DS.ProductDimension pd
WHERE p.categoryid = c.categoryid AND p.vendorid = v.vendorid
AND p.productid = pd.productid 
AND pd.producttype = 'Sales'
AND (p.productprice != pd.productsalesprice OR p.productname != pd.productname OR p.vendorid != pd.vendorid)
AND pd.CurrentStatus = 'C';

ALTER TABLE ipd MODIFY COLUMN productprice DECIMAL(7,2) NULL,
MODIFY COLUMN productdailyrentalprice DECIMAL(7,2) NULL,
MODIFY COLUMN productweeklyrentalprice DECIMAL(7,2) NULL;

INSERT INTO ipd(productid, productname, categoryid, vendorid, vendorname, categoryname, producttype, productprice, productdailyrentalprice, productweeklyrentalprice, ExtractionTimeStamp, pd_loaded, dvf, dvu, CurrentStatus)
SELECT r.productid, r.productname, c.categoryid, v.vendorid, v.vendorname, c.categoryname, pd.producttype, NULL AS productprice, r.productpricedaily, r.productpriceweekly , NOW() AS ExtractionTimeStamp, FALSE, NOW() AS dvf, '2040-01-01' AS dvu, 'c' AS CurrentStatus
FROM alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v, alluriv_ZAGIMORE_DS.ProductDimension pd
WHERE r.categoryid = c.categoryid AND r.vendorid = v.vendorid
AND r.productid = pd.productid 
AND pd.producttype = 'Rental'
AND (r.productpricedaily != pd.productdailyrentalprice OR r.productpriceweekly != pd.productweeklyrentalprice OR r.productname != pd.productname OR r.vendorid != pd.vendorid)
AND pd.CurrentStatus = 'C';

UPDATE ProductDimension pd, ipd
SET pd.dvu = NOW() - INTERVAL 1 DAY,
pd.CurrentStatus = 'N'
WHERE pd.producttype = ipd.producttype AND pd.productid = ipd.productid AND pd.CurrentStatus = 'C';

INSERT INTO ProductDimension(ProductID, ProductName, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRentalPrice, VendorID, VendorName, CategoryID, CategoryName, ProductType, ExtractionTimeStamp, pd_loaded, dvf, dvu, CurrentStatus)
SELECT ipd.productid, ipd.productname, ipd.productprice,ipd.productdailyrentalprice, ipd.productweeklyrentalprice, ipd.vendorid, ipd.vendorname, ipd.categoryid, ipd.categoryname, ipd.producttype , ipd.ExtractionTimeStamp, ipd.pd_loaded, ipd.dvf, ipd.dvu, ipd.CurrentStatus
FROM ipd;

ALTER TABLE alluriv_ZAGIMORE_DW.RevenueAndUnits 
DROP FOREIGN KEY RevenueAndUnits_ibfk_5;

REPLACE INTO alluriv_ZAGIMORE_DW.ProductDimension (ProductKey, ProductID, ProductName,CategoryID, VendorID, VendorName, CategoryName, ProductType,ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRentalPrice, dvf, dvu, CurrentStatus)
SELECT ProductKey, ProductID, ProductName,CategoryID, VendorID, VendorName, CategoryName, ProductType,ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRentalPrice, dvf, dvu, CurrentStatus
FROM ProductDimension;

ALTER TABLE alluriv_ZAGIMORE_DW.RevenueAndUnits
ADD CONSTRAINT RevenueAndUnits_ibfk_5 
FOREIGN KEY (ProductKey) REFERENCES alluriv_ZAGIMORE_DW.ProductDimension(ProductKey);

UPDATE ProductDimension SET pd_loaded = 1 WHERE pd_loaded = 0;

END



--------------------   Customer Dimension Type2 Change Refresh Procedure  --------------------

CREATE PROCEDURE CustomerDimensionType2Refresh()
BEGIN

DROP TABLE IF EXISTS icd;

CREATE TABLE icd AS
SELECT c.customerid
FROM alluriv_ZAGIMORE.customer c, alluriv_ZAGIMORE_DS.CustomerDimension cd
WHERE cd.CustomerID = c.customerid
AND (c.customername != cd.CustomerName OR c.customerzip != cd.CustomerZIP)
AND cd.CurrentStatus = 'C';

UPDATE CustomerDimension cd, icd
SET cd.dvu = NOW() - INTERVAL 1 DAY, cd.CurrentStatus = 'N'
WHERE cd.CustomerID = icd.customerid AND cd.CurrentStatus = 'C';

INSERT INTO CustomerDimension(CustomerID,CustomerName, CustomerZIP, ExtractionTimestamp, cd_loaded, dvf, dvu, CurrentStatus)
SELECT c.customerid, c.customername, c.customerzip, NOW(), FALSE, NOW(), '2040-01-01', 'C'
FROM alluriv_ZAGIMORE.customer c, alluriv_ZAGIMORE_DS.icd AS i
WHERE c.customerid = i.customerid;

ALTER TABLE alluriv_ZAGIMORE_DW.RevenueAndUnits
DROP FOREIGN KEY RevenueAndUnits_ibfk_4;

ALTER TABLE alluriv_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
DROP FOREIGN KEY One_Way_Revenue_Agg_By_Product_Cat_ibfk_2;

REPLACE INTO alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey, CustomerID,CustomerName, CustomerZIP, dvf, dvu, CurrentStatus)
SELECT CustomerKey, CustomerID,CustomerName, CustomerZIP, dvf, dvu, CurrentStatus
FROM CustomerDimension;

ALTER TABLE alluriv_ZAGIMORE_DW.RevenueAndUnits
ADD CONSTRAINT RevenueAndUnits_ibfk_4
FOREIGN KEY (CustomerKey) REFERENCES alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey);

ALTER TABLE alluriv_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
ADD CONSTRAINT One_Way_Revenue_Agg_By_Product_Cat_ibfk_2
FOREIGN KEY (CustomerKey) REFERENCES alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey);

UPDATE CustomerDimension
SET cd_loaded = 1
WHERE cd_loaded = 0;

END



--------------------   Master Refresh Procedure  --------------------

CREATE PROCEDURE DailyRefresh()
BEGIN

CALL CustomerDimensionRefresh();
CALL ProductDimensionRefresh();
CALL StoreDimensionRefresh();
CALL CustomerDimensionType2Refresh();
CALL ProductDimensionType2Refresh();
CALL DailyRegularFactRefresh();
CALL LateArrivingFactRefresh();

END