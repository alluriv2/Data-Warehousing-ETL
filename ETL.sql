-- SQL code for extracting the customer dimension

INSERT INTO CustomerDimension(CustomerName, CustomerID, CustomerZIP)
SELECT c.customername, c.customerid, c.customerzip
FROM alluriv_ZAGIMORE.customer c

-- SQL code for extracting the Store Dimension
INSERT INTO StoreDimension(StoreID, StoreZIP, RegionID, RegionName)
SELECT s.storeid, s.storezip, s.regionid, r.regionname
FROM alluriv_ZAGIMORE.store s, alluriv_ZAGIMORE.region r
WHERE s.regionid = r.regionid

-- SQL code for extracting Product Dimension
INSERT INTO ProductDimension(ProductID,ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID, CategoryName,ProductType)
SELECT p.productid, p.productname, p.productprice, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Sales'
FROM alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v
WHERE p.categoryid = c.categoryid AND p.vendorid = v.vendorid;

--SQL code for extracting Rental Dimension
INSERT INTO ProductDimension(ProductID,ProductName,ProductDailyRentalPrice, ProductWeeklyRentalPrice, VendorID, VendorName, CategoryID, CategoryName,ProductType)
SELECT p.productid, p.productname, p.productpricedaily, p.productpriceweekly, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Rental'
FROM alluriv_ZAGIMORE.rentalProducts p, alluriv_ZAGIMORE.category c, alluriv_ZAGIMORE.vendor v
WHERE p.categoryid = c.categoryid AND p.vendorid = v.vendorid;

-- SQL code for extracting the fact table
-- Part 1: Sales Revenue
-- Step 1: Extracting the facts into intermediate fact
CREATE TABLE intermediate_fact AS
SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS RevenueGenerated, 'Sales' AS RevenueType, sv.tid AS TransactionID, p.productid AS ProductID, st.storeid AS StoreID, st.customerid AS CustomerID, st.tdate AS FullDate
FROM alluriv_ZAGIMORE.soldvia sv, alluriv_ZAGIMORE.product p, alluriv_ZAGIMORE.salestransaction st
WHERE p.productid = sv.productid AND st.tid = sv.tid  

-- Step 2: Populating fact table with data from intermediate fact table
INSERT INTO RevenueAndUnits(UnitSold, RevenueGenerated, RevenueType,TransactionID, CustomerKey, StoreKey, ProductKey, CalendarKey)
SELECT i.UnitsSold, i.RevenueGenerated, i.RevenueType, i.TransactionID, cud.CustomerKey, sd.StoreKey, pd.ProductKey, cad.CalendarKey
FROM intermediate_fact i, CustomerDimension cud, StoreDimension sd, ProductDimension pd, CalendarDimension cad
WHERE i.CustomerID = cud.CustomerID AND sd.StoreId = i.StoreID AND pd.ProductId = i.ProductID AND pd.ProductType = 'Sales' AND i.FullDate = cad.FullDate

-- Part 2: Rental Revenue
-- Step 1: Extracting the facts into intermediate fact
DROP TABLE intermediate_fact;
CREATE TABLE intermediate_fact AS
SELECT 0 AS UnitsSold, r.productpricedaily * rv.duration AS RevenueGenerated, 'Rental, Daily' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'D'

INSERT INTO intermediate_fact(UnitsSold, RevenueGenerated, RevenueType, TransactionID, ProductID, StoreID, CustomerID,FullDate)
SELECT 0 AS UnitsSold, r.productpriceweekly * rv.duration AS RevenueGenerated, 'Rental, Weekly' AS RevenueType, rv.tid AS TransactionID, r.productid AS ProductID, rt.storeid AS StoreID, rt.customerid AS CustomerID, rt.tdate AS FullDate
FROM alluriv_ZAGIMORE.rentvia rv, alluriv_ZAGIMORE.rentalProducts r, alluriv_ZAGIMORE.rentaltransaction rt
WHERE r.productid = rv.productid AND rt.tid = rv.tid AND rv.rentaltype = 'W'

-- Step 2: Populating fact table with data from intermediate fact table
INSERT INTO RevenueAndUnits(UnitSold, RevenueGenerated, RevenueType,TransactionID, CustomerKey, StoreKey, ProductKey, CalendarKey)
SELECT i.UnitsSold, i.RevenueGenerated, i.RevenueType, i.TransactionID, cud.CustomerKey, sd.StoreKey, pd.ProductKey, cad.CalendarKey
FROM intermediate_fact i, CustomerDimension cud, StoreDimension sd, ProductDimension pd, CalendarDimension cad
WHERE i.CustomerID = cud.CustomerID AND sd.StoreId = i.StoreID AND pd.ProductId = i.ProductID AND pd.ProductType = 'Rental' AND i.FullDate = cad.FullDate


---------------------------  Loading of Dimension Data from Data Staging into Data Warehousing  --------------------------------

INSERT INTO alluriv_ZAGIMORE_DW.CustomerDimension(CustomerKey,CustomerID,CustomerName,CustomerZIP)
SELECT CustomerKey,CustomerID,CustomerName,CustomerZIP
FROM alluriv_ZAGIMORE_DS.CustomerDimension;


INSERT INTO alluriv_ZAGIMORE_DW.StoreDimension(StoreKey, StoreID, StoreZIP, RegionID, RegionName)
SELECT StoreKey, StoreID, StoreZIP, RegionID, RegionName
FROM alluriv_ZAGIMORE_DS.StoreDimension

INSERT INTO alluriv_ZAGIMORE_DW.ProductDimension(ProductKey, ProductID, VendorID, CategoryID, VendorName, CategoryName, ProductName, ProductSalesPrice, ProductWeeklyRentalPrice,ProductDailyRentalPrice, ProductType )
SELECT ProductKey, ProductID, VendorID, CategoryID, VendorName, CategoryName, ProductName, ProductSalesPrice, ProductWeeklyRentalPrice,ProductDailyRentalPrice, ProductType 
FROM alluriv_ZAGIMORE_DS.ProductDimension

INSERT INTO alluriv_ZAGIMORE_DW.CalendarDimension(CalendarKey, FullDate, CalendarMonth, CalendarYear)
SELECT CalendarKey, FullDate, CalendarMonth, CalendarYear
FROM alluriv_ZAGIMORE_DS.CalendarDimension

INSERT INTO alluriv_ZAGIMORE_DW.RevenueAndUnits(RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey)
SELECT RevenueGenerated,UnitSold, RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey
FROM alluriv_ZAGIMORE_DS.RevenueAndUnits

