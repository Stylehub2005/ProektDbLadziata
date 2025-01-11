
-- GRAFY --

--1) Prijmy podla krajiny--
SELECT 
    c.dim_country AS Country,
    SUM(il.Quantity * il.UnitPrice) AS Revenue
FROM fact_invoiceLine il
JOIN dim_customers c ON c.dim_customer_id = il.CustomerId
GROUP BY c.dim_country
ORDER BY Revenue DESC;

--2) Top10 Oblubene zanre--
SELECT 
    g.GenreId AS Genre,
    COUNT(il.TrackId) AS SalesCount
FROM fact_invoiceLine il
JOIN dim_track t ON t.track_id = il.TrackId
JOIN GENRE_STAGING g ON g.GenreId = t.genre_id
GROUP BY g.GenreId
ORDER BY SalesCount DESC
LIMIT 10;


--3)Trendy predaja podla mesiacov--
SELECT 
    d.monthAsString AS Month,
    SUM(il.Quantity * il.UnitPrice) AS Revenue
FROM fact_invoiceLine il
JOIN DIM_DATE d ON d.date = CAST(il.date AS DATE)
GROUP BY d.month, d.monthAsString
ORDER BY d.month;

--4) Analyza nacasovania nakupov s podrobnostami o prijmoch a mnozstve--
SELECT 
    t.Hour AS Hour,
    COUNT(il.InvoiceLineId) AS PurchaseCount,
    SUM(il.Quantity * il.UnitPrice) AS Revenue
FROM fact_invoiceLine il
JOIN DIM_TIME t ON t.Date = il.date
GROUP BY t.Hour
ORDER BY t.Hour;

--5)Top 10 najoblubenejsich skladieb podla prijmov a poctu predajov--
WITH TrackStats AS (
    SELECT 
        t.name AS TrackName,
        COUNT(il.InvoiceLineId) AS SalesCount,
        SUM(il.Quantity * il.UnitPrice) AS Revenue
    FROM fact_invoiceLine il
    JOIN dim_track t ON t.track_id = il.TrackId
    GROUP BY t.name
)
SELECT 
    TrackName,
    SalesCount,
    Revenue
FROM TrackStats
ORDER BY SalesCount DESC, Revenue DESC
LIMIT 10;


--6)Analyza preferencii zakaznikov podla zanru a krajiny--
SELECT 
    c.dim_country AS Country,
    g.GenreId AS Genre,
    COUNT(il.InvoiceLineId) AS SalesCount
FROM fact_invoiceLine il
JOIN dim_customers c ON c.dim_customer_id = il.CustomerId
JOIN dim_track t ON t.track_id = il.TrackId
JOIN GENRE_STAGING g ON g.GenreId = t.genre_id
GROUP BY c.dim_country, g.GenreId
ORDER BY c.dim_country, SalesCount DESC;












