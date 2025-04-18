------------------------------------  Type 2 changes Product Dimension -----------------------------

-- Adding cols to the product dimension in DS and DW

ALTER TABLE ProductDimension
ADD dvf DATE,
ADD dvu DATE,
ADD CurrentStatus CHAR(1);

UPDATE ProductDimension
SET dvf = '2013-01-01', CurrentStatus = 'C';

UPDATE ProductDimension
SET dvu = '2040-01-01';

ALTER TABLE alluriv_ZAGIMORE_DW.ProductDimension
ADD dvf DATE,
ADD dvu DATE,
ADD CurrentStatus CHAR(1);

UPDATE alluriv_ZAGIMORE_DW.ProductDimension
SET dvf = '2013-01-01', CurrentStatus = 'C';

UPDATE alluriv_ZAGIMORE_DW.ProductDimension
SET dvu = '2040-01-01';

-- changing the prices of three products

UPDATE `product` 
SET `productprice` = '125.00'
WHERE `product`.`productid` = '3X1'; 

UPDATE `product` 
SET `productprice` = '304.00' 
WHERE `product`.`productid` = '3X4';

UPDATE `product` 
SET `productprice` = '590.00'
WHERE `product`.`productid` = '4X4';


--  More changes

UPDATE `product` SET `productname` = 'Dura Shoe' WHERE `product`.`productid` = '4X4';
UPDATE `product` SET `productprice` = '500.00' WHERE `product`.`productid` = '5X1'; 
UPDATE `product` SET `productname` = 'Action Shoe', `productprice` = '700.00' WHERE `product`.`productid` = '5X2';
UPDATE `product` SET `vendorid` = 'OA' WHERE `product`.`productid` = '6X6';


UPDATE `rentalProducts` SET `productname` = 'UTY_SDF' WHERE `rentalProducts`.`productid` = '1X6'; 
UPDATE `rentalProducts` SET `productpricedaily` = '65.00' WHERE `rentalProducts`.`productid` = '3X3'; 
UPDATE `rentalProducts` SET `productpricedaily` = '240.00', `productpriceweekly` = '180.00' WHERE `rentalProducts`.`productid` = '7X7';


UPDATE `product` SET `productname` = 'Slicky Boots', `productprice` = '235.00', `vendorid` = 'WL' WHERE `product`.`productid` = '4X1';
UPDATE `rentalProducts` SET `vendorid` = 'PG', `productpricedaily` = '130.00', `productpriceweekly` = '170.00' WHERE `rentalProducts`.`productid` = '1X8';


-- ProductDimensionType2 Validation

UPDATE `product` SET `productname` = 'Comedy Shoe', `productprice` = '770.00' WHERE `product`.`productid` = '5X2';
UPDATE `rentalProducts` SET `productname` = 'Hard Boot', `vendorid` = 'PG', `productpricedaily` = '128.00', `productpriceweekly` = '175.00' WHERE `rentalProducts`.`productid` = '2X2';


--------------------   Product Dimension Type2 Change Procedure  --------------------

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


------------------------------------------------  Type 2 changes Customer Dimension ------------------------------------------------


-- Adding cols to the customer dimension in DS and DW

ALTER TABLE CustomerDimension
ADD dvf DATE,
ADD dvu DATE,
ADD CurrentStatus CHAR(1);

UPDATE CustomerDimension
SET dvf = '2013-01-01', CurrentStatus = 'C';

UPDATE CustomerDimension
SET dvu = '2040-01-01';

ALTER TABLE alluriv_ZAGIMORE_DW.CustomerDimension
ADD dvf DATE,
ADD dvu DATE,
ADD CurrentStatus CHAR(1);

UPDATE alluriv_ZAGIMORE_DW.CustomerDimension
SET dvf = '2013-01-01', CurrentStatus = 'C';

UPDATE alluriv_ZAGIMORE_DW.CustomerDimension
SET dvu = '2040-01-01';


-- Changing customer data

UPDATE `customer` SET `customername` = 'Pamela' WHERE `customer`.`customerid` = '3-4-555'; 
UPDATE `customer` SET `customerzip` = '13672' WHERE `customer`.`customerid` = '6-7-888';


--------------------   Customer Dimension Type2 Change Procedure  --------------------

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
