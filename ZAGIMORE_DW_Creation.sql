CREATE TABLE ProductDimension
(
  ProductKey INT NOT NULL,
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
  CalendarKey INT NOT NULL,
  FullDate DATE NOT NULL,
  CalendarMonth DATE NOT NULL,
  CalendarYear DATE NOT NULL,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE CustomerDimension
(
  CustomerKey INT NOT NULL,
  CustomerID CHAR(7) NOT NULL,
  CustomerName VARCHAR(15) NOT NULL,
  CustomerZIP CHAR(5) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE StoreDimension
(
  StoreKey INT NOT NULL,
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
  PRIMARY KEY (RevenueType, TransactionID, CalendarKey, ProductKey, StoreKey, CustomerKey),
  FOREIGN KEY (CalendarKey) REFERENCES CalendarDimension(CalendarKey),
  FOREIGN KEY (ProductKey) REFERENCES ProductDimension(ProductKey),
  FOREIGN KEY (StoreKey) REFERENCES StoreDimension(StoreKey),
  FOREIGN KEY (CustomerKey) REFERENCES CustomerDimension(CustomerKey)
)