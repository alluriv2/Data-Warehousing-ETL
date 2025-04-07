# ETL Project Using SQL and phpMyAdmin

This project was developed as part of a Data Warehousing course to demonstrate the Extract, Transform, and Load (ETL) process using SQL within phpMyAdmin. It serves as an educational example of setting up databases, data staging, and a data warehouse, as well as performing ETL operations, aggregating data, and managing refresh procedures.

## Technologies Used

- **MySQL**: Relational database management system for data storage.
- **phpMyAdmin**: Web-based interface for managing MySQL databases.
- **SQL**: Language used for performing data extraction, transformation, and loading tasks.

## Educational Purpose

This project is intended solely for educational purposes to showcase the application of ETL processes within a data warehousing context. It was developed as part of academic coursework and is not intended for commercial use or distribution.

## Running the ETL Process

1. **Create the Database and Calendar Dimension**: Run the `ZAGIMORE_DB_Creation.sql` script to create the database.

2. **Populate the Calendar Dimension**: Execute the `populateCalendarProcedure.sql` script to populate the calendar dimension table with date attributes. This step ensures that the calendar dimension is populated with the necessary data for analysis.

3. **Create the Data Staging Area**: Run the `ZAGIMORE_DS_Creation.sql` script to set up the staging tables. These tables temporarily hold raw data extracted from various sources before transformation.

4. **Create the Data Warehouse**: Run the `ZAGIMORE_DW_Creation.sql` script to establish the data warehouse structures. These structures are optimized for analytical queries and reporting.

5. **Perform the Initial ELT**: Execute the `ETL.sql` script to process and load data from the staging area into the data warehouse. This step performs the initial extraction, transformation, and loading of data.

6. **Create Aggregates and Snapshots**: Run the `Aggregates_Snapshots.sql` script to generate necessary aggregates and snapshots. These are useful for reporting and historical analysis.

7. **Set Up Refresh Procedures**: Execute the `Refreshes.sql` script to establish procedures for keeping the data up-to-date. These procedures ensure that the data warehouse reflects the latest information.

## Getting Started

### Prerequisites

1. **phpMyAdmin**: Install phpMyAdmin to interact with MySQL databases through a web interface.
2. **MySQL**: Install MySQL to set up and manage your databases.
3. **SQL**: Basic knowledge of SQL queries is required for performing ETL tasks.

### Installation

1. Install MySQL and phpMyAdmin on your local machine or use a web-hosted version of phpMyAdmin.
2. Clone or download the project repository to your local machine.
3. Open phpMyAdmin and log in to your MySQL server.

### Running the ETL Process

1. **Create the Database**: Run the `ZAGIMORE_DB_Creation.sql` script to create the database and the calendar dimension.
2. **Create the Data Staging Area**: Run the `ZAGIMORE_DS_Creation.sql` script to set up the staging tables.
3. **Create the Data Warehouse**: Run the `ZAGIMORE_DW_Creation.sql` script to create the data warehouse structures.
4. **Perform the Initial ELT**: Run the `ETL.sql` script to process and load the data into the warehouse.
5. **Create Aggregates and Snapshots**: Run the `Aggregates_Snapshots.sql` script to generate necessary aggregates and snapshots for analysis.
6. **Set Up Refresh Procedures**: Run the `Refreshes.sql` script to establish the refresh procedures for keeping the data up-to-date.

## Acknowledgments

This project was developed as part of the Data Warehousing course at Clarkson University. Special thanks to Professor Boris Jukic for guidance and support throughout the course.

## License

This project is intended for educational purposes only. All content is provided "as is," without warranty of any kind. For licensing inquiries, please contact Vaibhav Alluri.

## Contact

For more information, please contact:

- **Name**: Vaibhav Alluri
- **Email**: alluriv@clarkson.edu

