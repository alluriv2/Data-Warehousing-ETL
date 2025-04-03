CREATE TABLE ProductDimension
(
  ProductKey INT AUTO_INCREMENT,
  ProductID CHAR(3) NOT NULL,
  VendorID CHAR(2) NOT NULL,
  CategoryID CHAR(2) NOT NULL,
  VendorName VARCHAR(25) NOT NULL,
  CategoryName VARCHAR(25) NOT NULL,
  ProductName VARCHAR(25) NOT NULL,
  ProductSalesPrice NUMERIC(7,2),
  ProductWeeklyRentalPrice NUMERIC(7,2) ,
  ProductDailyRentalPrice NUMERIC(7,2) ,
  ProductType VARCHAR(8) NOT NULL,
  PRIMARY KEY (ProductKey)
);

CREATE TABLE CalendarDimension
(
  CalendarKey INT AUTO_INCREMENT,
  FullDate DATE NOT NULL,
  CalendarMonth INT,
  CalendarYear INT,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE CustomerDimension
(
  CustomerKey INT AUTO_INCREMENT,
  CustomerID CHAR(7) NOT NULL,
  CustomerName VARCHAR(15) NOT NULL,
  CustomerZIP CHAR(5) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE StoreDimension
(
  StoreKey INT AUTO_INCREMENT,
  StoreID VARCHAR(3) NOT NULL,
  StoreZIP CHAR(5) NOT NULL,
  RegionID CHAR(1) NOT NULL,
  RegionName VARCHAR(25) NOT NULL,
  PRIMARY KEY (StoreKey)
);

CREATE TABLE RevenueAndUnits
(
  RevenueGenerated INT NOT NULL,
  UnitSold INT NOT NULL,
  RevenueType VARCHAR(8) NOT NULL,
  TransactionID VARCHAR(8) NOT NULL,
  CalendarKey INT NOT NULL,
  ProductKey INT NOT NULL,
  StoreKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  PRIMARY KEY (RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey)
);


INSERT INTO `CustomerDimension`(`CustomerID`, `CustomerName`, `CustomerZIP`) 
VALUES ('C1','bob','13676');

INSERT INTO `CustomerDimension`(`CustomerID`, `CustomerName`, `CustomerZIP`) 
VALUES ('C2','alice','13676');


ALTER TABLE CalendarDimension
ADD MonthYear INT;
UPDATE CalendarDimension
SET MonthYear = CONCAT(CalendarMonth,CalendarYear) ;

ALTER TABLE CalendarDimension
ADD DayofWeek VARCHAR(15);
UPDATE CalendarDimension
SET DayofWeek = DAYNAME(FullDate);

SELECT LPAD(MonthYear,6,'0')
FROM CalendarDimension;

UPDATE CalendarDimension
SET MonthYear = LPAD(MonthYear,6,'0');