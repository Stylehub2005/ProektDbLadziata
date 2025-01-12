# ProektDbLadziata
Toto úložisko obsahuje implementáciu procesu ETL softvéru Snowflake na analýzu údajov zo súboru údajov Chinook. Cieľom projektu je preskúmať hudobné preferencie používateľov, správanie zákazníkov a kľúčové finančné ukazovatele z údajov o predaji, skladbách, žánroch a zákazníkoch. Výsledný dátový model umožňuje viacrozmernú analýzu a vizualizáciu kľúčových metrík, ako je popularita žánrov, tržby podľa regiónov, časové trendy v nákupoch a preferencie zákazníkov.
## 1. Úvod a popis zdrojových dát
Cieľom projektu je analyzovať údaje týkajúce sa hudobných skladieb, používateľov a ich nákupov. Táto analýza identifikuje kľúčové trendy v preferenciách zákazníkov, najpopulárnejších žánroch, skladateľoch a nákupnom správaní používateľov.
Východiskové údaje pochádzajú zo súboru údajov Chinook, ktorý obsahuje informácie o predaji hudobných skladieb, albumov, žánrov a zákazníkov. Súbor údajov obsahuje 10 hlavných tabuliek:
<br/>

* __Artist__
* __Album__ 
* __Track__
* __Genre__ 
* __Customer__
* __Invoice__ 
* __InvoiceLine__
* __Playlist__
* __MediaType__ 
* __Epmloyee__

### 1.1 Dátová architektúra
#### ERD diagram

Surové dáta sú organizované v relačnej štruktúre, ktorá je vizualizovaná prostredníctvom entitno-relačného diagramu (ERD):
![ModelChinook](https://github.com/user-attachments/assets/352a5d45-7ee4-4767-96c3-9b7c15506ebb)
Obrázok 1 Entitno-relačná schéma Chinook

## 2 Dimenzionálny model
Navrhnutý bol hviezdicový model (star schema) pre efektívnu analýzu dát z __Chinook__ databázy, kde centrálny bod predstavuje faktová tabuľka __fact_InvoiceLine__, ktorá je prepojená s nasledujúcimi dimenziami:

* __dim_Track:__ Obsahuje podrobné informácie o skladbách, vrátane názvu, autora (kompozitora), žánru, albumu, ceny a formátu médií.
* __dim_Customer:__ Obsahuje demografické údaje o zákazníkoch, ako sú krajina, e-mailová adresa a ďalšie údaje potrebné na segmentáciu používateľov.
* __dim_Date:__ Zahrňuje informácie o dátumoch faktúr, ako sú deň, mesiac, rok, týždeň, deň v týždni a štvrťrok.
* __dim_Time:__ Obsahuje podrobné časové údaje, ako hodina, minúta a sekunda, ktoré umožňujú analýzu časových vzorcov.
<br />
Štruktúra hviezdicového modelu, zobrazená na diagrame nižšie, ukazuje prepojenia medzi faktovou tabuľkou a dimenziami. Tento model umožňuje jednoduché vykonávanie mnohorozmerných analýz, ako sú analýzy predaja podľa krajín, časových trendov, popularity skladieb alebo žánrov.
<br />
Diagram znázorňuje jasnú štruktúru modelu, ktorá zjednodušuje pochopenie a implementáciu v analytických nástrojoch.

![StarModelChinook](https://github.com/user-attachments/assets/dd9e0f4c-84ec-40dc-a506-8665ab9d58a9)
Obrázok 2 Schéma hviezdy pre Chinook

## 3. ETL proces v Snowflake
ETL proces zahŕňal tri kľúčové fázy: extrakciu (Extract), transformáciu (Transform) a nahrávanie (Load). Tento postup bol realizovaný v prostredí Snowflake s cieľom pripraviť zdrojové dáta zo staging vrstvy a pretransformovať ich do viacdimenzionálneho modelu optimalizovaného pre analýzu a vizualizáciu.

### 3.1 Extract (Extrahovanie dát)
Dáta zo zdrojového datasetu vo formáte .csv boli najskôr nahraté do Snowflake pomocou interného stage úložiska s názvom my_stage. Stage v Snowflake funguje ako dočasné úložisko na importovanie alebo exportovanie dát. Vytvorenie stage bolo realizované prostredníctvom nasledujúceho príkazu:
<br />

__Príklad kódu:__
```
CREATE OR REPLACE STAGE my_stage;
```
<br />
Súbory obsahujúce údaje o knihách, používateľoch, hodnoteniach, zamestnaniach a úrovniach vzdelania boli následne nahraté do stage úložiska. Dáta boli následne importované do staging tabuliek pomocou príkazu COPY INTO. Pre každú tabuľku bol použitý podobný príkaz, napríklad:
<br />

__Príklad kódu:__
```
COPY INTO Album_staging  
FROM @my_stage/album.csv  
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);  
```
Pri spracovaní nekonzistentných záznamov bol použitý parameter ON_ERROR = 'CONTINUE', ktorý umožnil pokračovanie procesu bez prerušenia v prípade výskytu chýb.

### 3.2 Transfor (Transformácia dát)
Na základe ETL procesu boli dáta zo staging tabuliek vyčistené, transformované a obohatené s cieľom vytvoriť dimenzie a faktové tabuľky vhodné na analýzu.Tento proces zahŕňal:
#### __Transformácia údajov o skladbách:__ 
Tabuľka __DIM_TRACK__ obsahuje detailné informácie o skladbách vrátane názvu, skladateľa, ceny, žánru, albumu a typu média. Táto dimenzia bola vytvorená kombináciou údajov z viacerých staging tabuliek, ako sú track_staging, album_staging, artist_staging, genre_staging a mediatype_staging. Táto transformácia umožňuje prepojenie skladieb s ich príslušnými kontextovými atribútmi.

__Príklad kódu:__
```
CREATE OR REPLACE TABLE DIM_TRACK AS
SELECT 
    t.TrackId AS track_id,
    t.Name AS name, 
    a.AlbumId AS album_id,
    t.Composer AS composer,
    t.UnitPrice AS UnitPrice,
    ar.ArtistId AS artist_id,
    g.GenreId AS genre_id,
    m.MediaTypeId AS MediType_id
FROM track_staging t
JOIN album_staging a ON a.AlbumId = t.AlbumId
JOIN artist_staging ar ON ar.ArtistId = a.ArtistId
JOIN genre_staging g ON t.GenreId = g.GenreId
JOIN mediatype_staging m ON m.MediaTypeId = t.MediaTypeId;
```

#### __Transformácia dátumových údajov:__
 Tabuľka __DIM_DATE__ bola navrhnutá tak, aby uchovávala informácie o dátumoch. Obsahuje odvodené údaje, ako deň, deň v týždni, mesiac (textový aj číselný formát), rok, štvrťrok a týždeň. Táto dimenzia poskytuje možnosť podrobnej časovej analýzy. Vznikla extrakciou a spracovaním údajov zo stĺpca invoicedate v staging tabuľke invoice_staging.

__Príklad kódu:__
```
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
    DATE_PART(year, invoicedate) AS year,                
    DATE_PART(week, invoicedate) AS week,               
    DATE_PART(quarter, invoicedate) AS quarter 
FROM invoice_staging i
GROUP BY CAST(invoicedate AS DATE), 
         DATE_PART(day, invoicedate), 
         DATE_PART(dow, invoicedate), 
         DATE_PART(month, invoicedate), 
         DATE_PART(year, invoicedate), 
         DATE_PART(week, invoicedate), 
         DATE_PART(quarter, invoicedate);
```
__Vytvorenie faktovej tabuľky:__
Faktová tabuľka __FACT_INVOICELINE__ bola navrhnutá na ukladanie informácií o jednotlivých položkách na faktúrach. Obsahuje metriky, ako sú množstvo, cena a prepojenie na dimenzie skladieb, zákazníkov, dátumov a časov.

__Príklad kódu:__
```
CREATE OR REPLACE TABLE FACT_INVOICELINE AS
SELECT 
    il.InvoiceLineId AS InvoiceLineId,
    il.Quantity AS Quantity,
    il.UnitPrice AS UnitPrice,
    c.dim_customer_id AS CustomerId,
    i.invoicedate AS date,
    t.track_id AS TrackId
FROM invoiceline_staging il
JOIN invoice_staging i ON i.invoiceid = il.invoiceid
JOIN dim_track t ON t.track_id = il.trackid
JOIN dim_customers c ON c.dim_customer_id = i.Customerid;
```
Tieto dimenzie a faktové tabuľky umožňujú vykonávať detailnú analýzu a poskytujú pohľad na rôzne aspekty podnikania, vrátane predajov, zákazníkov a produktov.

### __3.3 Load (Načítanie dát)__
Po úspešnom vytvorení dimenzií a faktových tabuliek boli dáta nahraté do finálnej databázovej štruktúry. Na záver boli staging tabuľky odstránené s cieľom optimalizovať využitie úložiska:

__Príklad kódu:__
```
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
```
ETL proces v Snowflake umožnil spracovanie pôvodných dát z formátu .csv do viacdimenzionálneho modelu typu hviezda. Tento proces zahŕňal čistenie, obohacovanie a reorganizáciu údajov, čím sa vytvoril model, ktorý umožňuje analýzu preferencií a správania používateľov. Výsledný model slúži ako základ pre tvorbu vizualizácií a reportov.


























