CREATE TABLE vendor
(vendorid CHAR(2) NOT NULL,
 vendorname VARCHAR(25) NOT NULL,
 PRIMARY KEY (vendorid));
 
CREATE TABLE category
(categoryid CHAR(2) NOT NULL,
 categoryname VARCHAR(25) NOT NULL,
 PRIMARY KEY (categoryid));
 
CREATE TABLE product
(productid CHAR(3) NOT NULL,
 productname VARCHAR(25) NOT NULL,
 productprice NUMERIC (7,2) NOT NULL,
 vendorid CHAR(2) NOT NULL,
 categoryid CHAR(2) NOT NULL,
 PRIMARY KEY (productid),
 FOREIGN KEY (vendorid)
 REFERENCES vendor(vendorid),
 FOREIGN KEY (categoryid) REFERENCES category(categoryid));
 
CREATE TABLE region
(regionid CHAR NOT NULL,
 regionname VARCHAR(25) NOT NULL,
 PRIMARY KEY (regionid));
 
CREATE TABLE store
(storeid VARCHAR(3) NOT NULL,
 storezip CHAR(5) NOT NULL,
 regionid CHAR NOT NULL,
 PRIMARY KEY (storeid),
 FOREIGN KEY (regionid) REFERENCES region(regionid));
 
CREATE TABLE customer
(customerid CHAR(7) NOT NULL,
 customername VARCHAR(15) NOT NULL,
 customerzip CHAR(5) NOT NULL,
 PRIMARY KEY (customerid));
 
CREATE TABLE salestransaction
(tid VARCHAR(8) NOT NULL,
 customerid CHAR(7) NOT NULL,
 storeid VARCHAR(3) NOT NULL,
 tdate DATE NOT NULL,
 PRIMARY KEY (tid),
 FOREIGN KEY (customerid) REFERENCES customer(customerid),
 FOREIGN KEY (storeid)REFERENCES store(storeid));
 
CREATE TABLE soldvia
(productid CHAR(3) NOT NULL,
 tid VARCHAR(8) NOT NULL,
 noofitems INT NOT NULL,
 PRIMARY KEY (productid, tid),
 FOREIGN KEY (productid) REFERENCES product(productid),
 FOREIGN KEY (tid) REFERENCES salestransaction(tid));
 
 
CREATE TABLE rentalProducts
(productid CHAR(3) NOT NULL,
 productname VARCHAR(25) NOT NULL,
 vendorid CHAR(2) NOT NULL,
 categoryid CHAR(2) NOT NULL,
 productpricedaily NUMERIC(7,2) NOT NULL,
 productpriceweekly NUMERIC(7,2) NOT NULL,
 PRIMARY KEY (productid),
 FOREIGN KEY (vendorid) REFERENCES vendor(vendorid),
 FOREIGN KEY (categoryid) REFERENCES category(categoryid));
 
 
 
CREATE TABLE rentaltransaction
(tid VARCHAR(8) NOT NULL,
 customerid CHAR(7) NOT NULL,
 storeid VARCHAR(3) NOT NULL,
 tdate DATE NOT NULL,
 PRIMARY KEY (tid),
 FOREIGN KEY (customerid) REFERENCES customer(customerid),
 FOREIGN KEY (storeid) REFERENCES store(storeid));
 
CREATE TABLE rentvia
(productid CHAR(3) NOT NULL,
 tid VARCHAR(8) NOT NULL,
 rentaltype CHAR(1) NOT NULL,
 duration INT(2) NOT NULL,
 PRIMARY KEY (productid,tid),
 FOREIGN KEY (productid) REFERENCES rentalProducts(productid),
 FOREIGN KEY (tid) REFERENCES rentaltransaction(tid));
 
 
 
INSERT INTO vendor VALUES('PG','Pacifica Gear');
INSERT INTO vendor VALUES('MK','Mountain King');
INSERT INTO vendor VALUES('OA','Outdoor Adventures');
INSERT INTO vendor VALUES('WL','Wilderness Limited');
 
INSERT INTO category VALUES('CP','Camping');
INSERT INTO category VALUES('FW','Footwear');
INSERT INTO category VALUES('CL','Climbing');
INSERT INTO category VALUES('EL','Electronics');
INSERT INTO category VALUES('CY','Cycling');
 
INSERT INTO product VALUES('1X1','Zzz Bag',100,'PG','CP');
INSERT INTO product VALUES('2X2','Easy Boot',70,'MK','FW');
INSERT INTO product VALUES('3X3','Cosy Sock',15,'MK','FW');
INSERT INTO product VALUES('4X4','Dura Boot',90,'PG','FW');
INSERT INTO product VALUES('5X5','Tiny Tent',150,'MK','CP');
INSERT INTO product VALUES('6X6','Biggy Tent',250,'MK','CP');
INSERT INTO product VALUES('7X7','Hi-Tec GPS',300,'OA','EL');
INSERT INTO product VALUES('8X8','Power Pedals',20,'MK','CY');
INSERT INTO product VALUES('9X9','Trusty Rope',30,'WL','CL');
INSERT INTO product VALUES('1X2','Comfy Harness',150,'MK','CL');
INSERT INTO product VALUES('1X3','Sunny Charger',125,'OA','EL');
INSERT INTO product VALUES('1X4','Safe-T Helmet',40,'PG','CY');
INSERT INTO product VALUES('2X1','Mmm Stove',80,'WL','CP');
INSERT INTO product VALUES('2X3','Reflect-o Jacket',35,'PG','CY');
INSERT INTO product VALUES('2X4','Strongster Carribeaner',20,'MK','CL');
INSERT INTO product VALUES('3X1','Sleepy Pad',25,'WL','CP');
INSERT INTO product VALUES('3X2','Bucky Knife',60,'WL','CP');
INSERT INTO product VALUES('3X4','Treado Tire',30,'OA','CY');
INSERT INTO product VALUES('4X1','Slicky Tire',25,'OA','CY');
INSERT INTO product VALUES('4X2','Electra Compass',45,'MK','EL');
INSERT INTO product VALUES('4X3','Mega Camera',275,'WL','EL');
INSERT INTO product VALUES('5X1','Simple Sandal',50,'PG','FW');
INSERT INTO product VALUES('5X2','Action Sandal',70,'PG','FW');
INSERT INTO product VALUES('5X3','Luxo Tent',500,'OA','CP');
 
INSERT INTO region VALUES('C','Chicagoland');
INSERT INTO region VALUES('T','Tristate');
INSERT INTO region VALUES('I','Indiana');
INSERT INTO region VALUES('N','North'); 
INSERT INTO store VALUES('S1','60600','C ');
INSERT INTO store VALUES('S2','60605','C');
INSERT INTO store VALUES('S3','35400','T');
INSERT INTO store VALUES('S4','60640','C');
INSERT INTO store VALUES('S5','46307','T');
INSERT INTO store VALUES('S6','47374','I');
INSERT INTO store VALUES('S7','47401','I');
INSERT INTO store VALUES('S8','55401','N');
INSERT INTO store VALUES('S9','54937','N');
INSERT INTO store VALUES('S10','60602','C');
INSERT INTO store VALUES('S11','46201','I');
INSERT INTO store VALUES('S12','55701','N');
INSERT INTO store VALUES('S13','60085','T');
INSERT INTO store VALUES('S14','53140','T');
 
INSERT INTO customer VALUES('1-2-333','Tina','60137');
INSERT INTO customer VALUES('2-3-444','Tony','60611');
INSERT INTO customer VALUES('3-4-555','Pam','35401');
INSERT INTO customer VALUES('4-5-666','Elly','47374');
INSERT INTO customer VALUES('5-6-777','Nora','60640');
INSERT INTO customer VALUES('6-7-888','Miles','60602');
INSERT INTO customer VALUES('7-8-999','Neil','55403');
INSERT INTO customer VALUES('8-9-000','Maggie','47401');
INSERT INTO customer VALUES('9-0-111','Ryan','46202');
INSERT INTO customer VALUES('0-1-222','Dan','55499');
 
 
INSERT INTO salestransaction VALUES ('T111','1-2-333','S1','2013-01-01');
INSERT INTO salestransaction VALUES ('T222','2-3-444','S2','2013-01-01');
INSERT INTO salestransaction VALUES ('T333','1-2-333','S3','2013-01-02');
INSERT INTO salestransaction VALUES ('T444','3-4-555','S3','2013-01-02');
INSERT INTO salestransaction VALUES ('T555','2-3-444','S3','2013-01-02');
INSERT INTO salestransaction VALUES ('T666','5-6-777','S10','2013-01-03');
INSERT INTO salestransaction VALUES ('T777','6-7-888','S13','2013-01-03');
INSERT INTO salestransaction VALUES ('T888','8-9-000','S4','2013-01-04');
INSERT INTO salestransaction VALUES ('T999','4-5-666','S6','2013-01-04');
INSERT INTO salestransaction VALUES ('T101','7-8-999','S12','2013-01-04');
INSERT INTO salestransaction VALUES ('T202','0-1-222','S8','2013-01-04');
INSERT INTO salestransaction VALUES ('T303','4-5-666','S6','2013-01-05');
INSERT INTO salestransaction VALUES ('T404','8-9-000','S6','2013-01-05');
INSERT INTO salestransaction VALUES ('T505','6-7-888','S14','2013-01-05');
INSERT INTO salestransaction VALUES ('T606','0-1-222','S11','2013-01-06');
INSERT INTO salestransaction VALUES ('T707','5-6-777','S4','2013-01-06');
INSERT INTO salestransaction VALUES ('T808','7-8-999','S9','2013-01-06');
INSERT INTO salestransaction VALUES ('T909','5-6-777','S4','2013-01-06');
INSERT INTO salestransaction VALUES ('T011','8-9-000','S7','2013-01-07');
INSERT INTO salestransaction VALUES ('T022','9-0-111','S5','2013-01-07');
 
INSERT INTO soldvia VALUES('1X1','T111',1);
INSERT INTO soldvia VALUES('2X2','T222',1);
INSERT INTO soldvia VALUES('3X3','T333',5);
INSERT INTO soldvia VALUES('1X1','T333',1);
INSERT INTO soldvia VALUES('4X4','T444',1);
INSERT INTO soldvia VALUES('2X2','T444',2);
INSERT INTO soldvia VALUES('4X4','T555',4);
INSERT INTO soldvia VALUES('5X5','T555',2);
INSERT INTO soldvia VALUES('6X6','T555',1);
INSERT INTO soldvia VALUES('7X7','T666',1);
INSERT INTO soldvia VALUES('9X9','T666',1);
INSERT INTO soldvia VALUES('1X3','T666',2);
INSERT INTO soldvia VALUES('8X8','T777',1);
INSERT INTO soldvia VALUES('1X4','T888',4);
INSERT INTO soldvia VALUES('2X3','T888',3);
INSERT INTO soldvia VALUES('9X9','T999',1);
INSERT INTO soldvia VALUES('1X2','T999',5);
INSERT INTO soldvia VALUES('8X8','T999',3);
INSERT INTO soldvia VALUES('1X3','T999',1);
INSERT INTO soldvia VALUES('1X2','T101',3);
INSERT INTO soldvia VALUES('1X4','T101',1);
INSERT INTO soldvia VALUES('2X4','T202',4);
INSERT INTO soldvia VALUES('9X9','T303',3);
INSERT INTO soldvia VALUES('1X4','T303',2);
INSERT INTO soldvia VALUES('2X1','T303',2);
INSERT INTO soldvia VALUES('3X1','T303',2);
INSERT INTO soldvia VALUES('2X4','T404',1);
INSERT INTO soldvia VALUES('2X3','T404',2);
INSERT INTO soldvia VALUES('2X2','T505',3);
INSERT INTO soldvia VALUES('3X2','T505',1);
INSERT INTO soldvia VALUES('2X1','T505',4);
INSERT INTO soldvia VALUES('2X4','T606',7);
INSERT INTO soldvia VALUES('3X1','T606',4);
INSERT INTO soldvia VALUES('2X2','T606',3);
INSERT INTO soldvia VALUES('3X4','T606',2);
INSERT INTO soldvia VALUES('4X4','T606',2);
INSERT INTO soldvia VALUES('3X2','T707',1);
INSERT INTO soldvia VALUES('3X4','T707',4);
INSERT INTO soldvia VALUES('4X1','T707',2);
INSERT INTO soldvia VALUES('5X3','T808',1);
INSERT INTO soldvia VALUES('4X2','T808',1);
INSERT INTO soldvia VALUES('2X2','T808',1);
INSERT INTO soldvia VALUES('4X3','T808',1);
INSERT INTO soldvia VALUES('3X3','T808',4);
INSERT INTO soldvia VALUES('4X2','T909',3);
INSERT INTO soldvia VALUES('6X6','T909',1);
INSERT INTO soldvia VALUES('3X3','T011',3);
INSERT INTO soldvia VALUES('4X3','T022',3);
INSERT INTO soldvia VALUES('2X2','T022',3);
INSERT INTO soldvia VALUES('5X1','T022',2);
 
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('5X5','Tiny Tent',15, 50,'MK','CP');
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('7X7','Hi-Tec GPS',20, 80,'OA','EL');
 
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('123','0-1-222','S1','2019-01-16');
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('5X5','123','D',2);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('7X7','123','D',2);
 
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('456','1-2-333','S10','2019-01-16');
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('5X5','456','W',1);
 
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('1X1','Zzz Bag',10, 60,'MK','CL');
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('2X2','Easy Boot',18, 75,'OA','FW');
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('3X3','Cosy Sock',5, 25,'PG','FW');
INSERT INTO rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('4X4','Dura Boot',25, 120,'WL','FW');
 
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('231','2-3-444','S11','2020-01-01');
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('312','3-4-555','S12','2019-12-21');
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('321','4-5-666','S3','2019-11-28');
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('564','5-6-777','S2','2019-10-07');
INSERT INTO rentaltransaction(tid, customerid, storeid, tdate) VALUES('645','6-7-888','S7','2019-09-16');
 
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('4X4','231','W',2);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('4X4','312','D',3);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('2X2','564','D',5);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('1X1','564','W',4);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('1X1','456','D',6);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('7X7','231','D',1);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('2X2','645','W',3);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('5X5','645','D',5);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('2X2','321','D',3);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('4X4','321','D',3);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('3X3','312','W',1);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('1X1','312','D',5);
INSERT INTO rentvia(productid, tid, rentaltype, duration) VALUES ('7X7','312','D',5);