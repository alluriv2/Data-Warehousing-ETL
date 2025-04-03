CREATE PROCEDURE populateCalendar()
BEGIN
DECLARE i INT DEFAULT 0;
myloop: LOOP
INSERT INTO CalendarDimension(Fulldate)
SELECT DATE_ADD('2013-01-01', INTERVAL i DAY);
SET i=i+1;
IF i=10000 then
LEAVE myloop;
END IF;
END LOOP myloop;
UPDATE CalendarDimension
SET CalendarMonth = MONTH(FullDate), CalendarYear = YEAR(FullDate);
END;