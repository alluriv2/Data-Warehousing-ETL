
------------------------------------------------- Daily Fact Refresh  -------------------------------------------------

ALTER TABLE RevenueAndUnits
ADD ExtractionTimestamp TIMESTAMP, ADD f_loaded BOOLEAN;

UPDATE RevenueAndUnits
SET f_loaded = TRUE;

UPDATE RevenueAndUnits
SET ExtractionTimestamp = NOW() - INTERVAL  10 DAY;

-- Adding new Sales Transactions

INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('ABCD', '0-1-222', 'S1', '2025-03-25');
INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('2X4', 'ABCD', '3');
INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('4X2', 'ABCD', '6');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('QWERTY', '4-5-666', 'S2', '2025-03-25');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('5X5', 'QWERTY', 'D', '5');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('2X2', 'QWERTY', 'W', '3');



-- Extracting new sales facts

-- Step 1: Extracting the facts into intermediate fact
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


-- Step2: Extracting facts with data into intermediate fact table

INSERT INTO RevenueAndUnits(UnitSold, RevenueGenerated, RevenueType,TransactionID, CustomerKey, StoreKey, ProductKey, CalendarKey, ExtractionTimestamp, f_loaded)
SELECT i.UnitsSold, i.RevenueGenerated, i.RevenueType, i.TransactionID, cud.CustomerKey, sd.StoreKey, pd.ProductKey, cad.CalendarKey, NOW(), FALSE
FROM intermediate_fact i, CustomerDimension cud, StoreDimension sd, ProductDimension pd, CalendarDimension cad
WHERE i.CustomerID = cud.CustomerID AND sd.StoreId = i.StoreID AND pd.ProductId = i.ProductID AND LEFT(pd.ProductType,1) = LEFT(i.RevenueType,1) AND i.FullDate = cad.FullDate


-- Loading facts into DWH

INSERT INTO alluriv_ZAGIMORE_DW.RevenueAndUnits(RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey)
SELECT RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey
FROM alluriv_ZAGIMORE_DS.RevenueAndUnits
WHERE f_loaded = FALSE


--   Updating in the DS

UPDATE RevenueAndUnits
SET f_loaded = TRUE 
WHERE f_loaded = FALSE

-- Creating new sales and rental transaction with 27th March  

INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('GHJK', '0-1-222', 'S1', '2025-03-27');
INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('2X4', 'GHJK', '3');
INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('4X2', 'GHJK', '6');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('YUIO', '4-5-666', 'S2', '2025-03-27');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('5X5', 'YUIO', 'D', '5');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('2X2', 'YUIO', 'W', '3');



--  DailyFactRefresh Procedure  

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

-------------------------------------------------  Product Dimension Refresh  -------------------------------------------------

ALTER TABLE ProductDimension
ADD ExtractionTimestamp TIMESTAMP, ADD pd_loaded BOOLEAN;

UPDATE ProductDimension
SET pd_loaded = TRUE;

UPDATE ProductDimension
SET ExtractionTimestamp = NOW() - INTERVAL  20 DAY;

INSERT INTO `product` (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) VALUES ('1X5', 'KYT', '10', 'MK', 'CY');
INSERT INTO `rentalProducts` (`productid`, `productname`, `vendorid`, `categoryid`, `productpricedaily`, `productpriceweekly`) VALUES ('1X5', 'KYT', 'MK', 'CY', '2', '4');

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


INSERT INTO `product` (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) VALUES ('1X6', 'UTY', '238', 'OA', 'FW');
INSERT INTO `rentalProducts` (`productid`, `productname`, `vendorid`, `categoryid`, `productpricedaily`, `productpriceweekly`) VALUES ('1X6', 'UTY', 'OA', 'FW', '30', '70');



-- ProductDimensionRefresh Procedure  

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


-------------------------------------------------  Store Dimension Refresh  -------------------------------------------------

ALTER TABLE StoreDimension
ADD ExtractionTimestamp TIMESTAMP, ADD sd_loaded BOOLEAN;

UPDATE StoreDimension
SET sd_loaded = TRUE;

UPDATE StoreDimension
SET ExtractionTimestamp = NOW() - INTERVAL  20 DAY;

INSERT INTO `store` (`storeid`, `storezip`, `regionid`) VALUES ('S15', '13676', 'I');


--  StoreDimensionRefresh Procedure 

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

-- Testing StoreDimensionRefresh

INSERT INTO `store` (`storeid`, `storezip`, `regionid`) VALUES ('S16', '13699', 'N');

-------------------------------------------------  Customer Dimension Refresh -------------------------------------------------

ALTER TABLE CustomerDimension
ADD ExtractionTimestamp TIMESTAMP, ADD cd_loaded BOOLEAN;

UPDATE CustomerDimension
SET cd_loaded = TRUE;

UPDATE CustomerDimension
SET ExtractionTimestamp = NOW() - INTERVAL  20 DAY;

INSERT INTO `customer` (`customerid`, `customername`, `customerzip`) VALUES ('2-2-234', 'Jim', '13676');


-- CustomerDimensionRefresh Procedure  

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

INSERT INTO `customer` (`customerid`, `customername`, `customerzip`) VALUES ('2-8-422', 'Jan', '13699');


--- Testing CustomerDimensionRefresh

INSERT INTO `product` (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) VALUES ('1X8', 'JFK', '238', 'OA', 'FW');
INSERT INTO `rentalProducts` (`productid`, `productname`, `vendorid`, `categoryid`, `productpricedaily`, `productpriceweekly`) VALUES ('1X8', 'JFK', 'OA', 'FW', '30', '70');


-------------------------------------------------  Late Arriving Fact Refresh  -------------------------------------------------

-- LateArrivingFactRefresh Procedure

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

-- Testing LateArrivingFactRefresh

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('ZXCV', '2-8-422', 'S5', '2025-03-21');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('4X4', 'ZXCV', 'D', '3');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('7X7', 'ZXCV', 'W', '6');


INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('DFGN', '6-7-888', 'S5', '2025-03-05');
INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('2X2', 'DFGN', '4');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('854', '2-2-234', 'S10', '2025-01-14');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) VALUES ('4X4', '854', 'D', '8'), ('3X3', '854', 'W', '3');