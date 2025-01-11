
CREATE DATABASE ChinookDB;

CREATE SCHEMA ChinookDB.staging;

USE SCHEMA ChinookDB.staging;



CREATE OR REPLACE TABLE Artist_staging (
    ArtistId INT NOT NULL,
    Name NVARCHAR(120),
    CONSTRAINT PK_Artist PRIMARY KEY (ArtistId)
);

CREATE OR REPLACE TABLE Album_staging (
    AlbumId INT NOT NULL,
    Title NVARCHAR(160) NOT NULL,
    ArtistId INT NOT NULL,
    CONSTRAINT PK_Album PRIMARY KEY (AlbumId)
);

CREATE OR REPLACE TABLE Customer_staging (
    CustomerId INT NOT NULL,
    FirstName NVARCHAR(40) NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    Company NVARCHAR(80),
    Address NVARCHAR(70),
    City NVARCHAR(40),
    State NVARCHAR(40),
    Country NVARCHAR(40),
    PostalCode NVARCHAR(10),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24),
    Email NVARCHAR(60) NOT NULL,
    SupportRepId INT,
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
);

CREATE OR REPLACE TABLE Employee_staging (
    EmployeeId INT NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    FirstName NVARCHAR(20) NOT NULL,
    Title NVARCHAR(30),
    ReportsTo INT,
    BirthDate DATETIME,
    HireDate DATETIME,
    Address NVARCHAR(70),
    City NVARCHAR(40),
    State NVARCHAR(40),
    Country NVARCHAR(40),
    PostalCode NVARCHAR(10),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24),
    Email NVARCHAR(60),
    CONSTRAINT PK_Employee PRIMARY KEY (EmployeeId)
);

CREATE OR REPLACE TABLE Genre_staging (
    GenreId INT NOT NULL,
    Name NVARCHAR(120),
    CONSTRAINT PK_Genre PRIMARY KEY (GenreId)
);

CREATE OR REPLACE TABLE Invoice_staging (
    InvoiceId INT NOT NULL,
    CustomerId INT NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    BillingAddress NVARCHAR(70),
    BillingCity NVARCHAR(40),
    BillingState NVARCHAR(40),
    BillingCountry NVARCHAR(40),
    BillingPostalCode NVARCHAR(10),
    Total NUMERIC(10,2) NOT NULL,
    CONSTRAINT PK_Invoice PRIMARY KEY (InvoiceId)
);

CREATE OR REPLACE TABLE InvoiceLine_staging (
    InvoiceLineId INT NOT NULL,
    InvoiceId INT NOT NULL,
    TrackId INT NOT NULL,
    UnitPrice NUMERIC(10,2) NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT PK_InvoiceLine PRIMARY KEY (InvoiceLineId)
);

CREATE OR REPLACE TABLE MediaType_staging (
    MediaTypeId INT NOT NULL,
    Name NVARCHAR(120),
    CONSTRAINT PK_MediaType PRIMARY KEY (MediaTypeId)
);

CREATE OR REPLACE TABLE Playlist_staging (
    PlaylistId INT NOT NULL,
    Name NVARCHAR(120),
    CONSTRAINT PK_Playlist PRIMARY KEY (PlaylistId)
);

CREATE OR REPLACE TABLE PlaylistTrack_staging (
    PlaylistId INT NOT NULL,
    TrackId INT NOT NULL,
    CONSTRAINT PK_PlaylistTrack PRIMARY KEY (PlaylistId, TrackId)
);

CREATE OR REPLACE TABLE Track_staging (
    TrackId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    AlbumId INT,
    MediaTypeId INT NOT NULL,
    GenreId INT,
    Composer NVARCHAR(220),
    Milliseconds INT NOT NULL,
    Bytes INT,
    UnitPrice NUMERIC(10,2) NOT NULL,
    CONSTRAINT PK_Track PRIMARY KEY (TrackId)
);


CREATE OR REPLACE STAGE my_stage;
CREATE STAGE my_stage;

COPY INTO Album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Customer_staging
FROM @my_stage/customer.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Employee_staging
FROM @my_stage/employee.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Invoice_staging
FROM @my_stage/invoice.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Invoiceline_staging
FROM @my_stage/invoiceline.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO MediaType_staging
FROM @my_stage/mediatype.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Playlist_staging
FROM @my_stage/playlist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO PlaylistTrack_staging
FROM @my_stage/playlisttrack.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Track_staging
FROM @my_stage/track.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- ELT --

CREATE TABLE DIM_CUSTOMERS AS
SELECT 
    c.CUSTOMERID AS dim_customer_id,
    c.Country AS dim_country,
    c.Email AS email
FROM CUSTOMER_STAGING c;



CREATE OR REPLACE TABLE DIM_TRACK AS
SELECT 
    t.TrackId as track_id,
    t.Name as name, 
    a.AlbumId as album_id,
    t.Composer as composer,
    t.UnitPrice as UnitPrice,
    ar.ArtistId as artist_id,
    g.GenreId as genre_id,
    m.MediaTypeId as MediType_id
FROM track_staging t
JOIN ALBUM_STAGING a ON a.AlbumId = t.AlbumId
JOIN ARTIST_STAGING ar ON ar.ArtistId = a.ArtistId
JOIN GENRE_STAGING g ON t.GenreId = g.GenreId
JOIN MEDIATYPE_STAGING m ON m.MediaTypeId = t.MediaTypeId;



CREATE OR REPLACE TABLE DIM_TIME AS 
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY DATE_TRUNC('HOUR', InvoiceDate)) AS dim_time_id,
    i.invoicedate as Date,
    HOUR(invoicedate) AS Hour,
    MINUTE(invoicedate) AS Minute,
    SECOND (invoicedate) AS Second

FROM INVOICE_STAGING i;



CREATE OR REPLACE TABLE DIM_DATE AS 
SELECT DISTINCT 
  ROW_NUMBER() OVER (ORDER BY CAST(invoicedate AS DATE)) AS dim_date_id, 
    CAST(invoicedate AS DATE) AS date,                    
    DATE_PART(day, invoicedate) AS day,                   
    DATE_PART(dow, invoicedate) + 1 AS dayOfWeek,        
    CASE DATE_PART(dow, invoicedate) + 1
        WHEN 1 THEN 'Pondelok'
        WHEN 2 THEN 'Utorok'
        WHEN 3 THEN 'Streda'
        WHEN 4 THEN 'Štvrtok'
        WHEN 5 THEN 'Piatok'
        WHEN 6 THEN 'Sobota'
        WHEN 7 THEN 'Nedeľa'
    END AS dayOfWeekAsString,
    DATE_PART(month, invoicedate) AS month,              
    CASE DATE_PART(month, invoicedate)
        WHEN 1 THEN 'Január'
        WHEN 2 THEN 'Február'
        WHEN 3 THEN 'Marec'
        WHEN 4 THEN 'Apríl'
        WHEN 5 THEN 'Máj'
        WHEN 6 THEN 'Jún'
        WHEN 7 THEN 'Júl'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'Október'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS monthAsString,
    DATE_PART(year,invoicedate) AS year,                
    DATE_PART(week, invoicedate) AS week,               
    DATE_PART(quarter, invoicedate) AS quarter 

    FROM INVOICE_STAGING i
GROUP BY CAST(invoicedate AS DATE), 
         DATE_PART(day, invoicedate), 
         DATE_PART(dow, invoicedate), 
         DATE_PART(month, invoicedate), 
         DATE_PART(year, invoicedate), 
         DATE_PART(week, invoicedate), 
         DATE_PART(quarter, invoicedate);


         
CREATE OR REPLACE TABLE fact_invoiceLine AS
SELECT 
    il.InvoiceLineId as InvoiceLineId,
    il.Quantity as Quantity,
    il.UnitPrice as UnitPrice,
    c.dim_customer_id as CustomerId,
    i.invoicedate as date,
    t.track_id as TrackId
    FROM INVOICELINE_STAGING il
    
    JOIN INVOICE_STAGING i ON i.invoiceid = il.invoiceid
    JOIN dim_track t ON t.track_id = il.trackid
    JOIN dim_customers c ON c.dim_customer_id = i.Customerid; 


DROP TABLE IF EXISTS Artist_staging;
DROP TABLE IF EXISTS Album_staging;
DROP TABLE IF EXISTS Customer_staging;
DROP TABLE IF EXISTS Employee_staging;
DROP TABLE IF EXISTS Genre_staging;
DROP TABLE IF EXISTS Invoice_staging;
DROP TABLE IF EXISTS InvoiceLine_staging;
DROP TABLE IF EXISTS MediaType_staging;
DROP TABLE IF EXISTS Playlist_staging;
DROP TABLE IF EXISTS PlaylistTrack_staging;
DROP TABLE IF EXISTS Track_staging;

        

    
    





    
    














