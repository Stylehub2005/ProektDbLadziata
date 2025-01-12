# ProektDbLadziata
Toto úložisko obsahuje implementáciu procesu ETL softvéru Snowflake na analýzu údajov zo súboru údajov Chinook. Cieľom projektu je preskúmať hudobné preferencie používateľov, správanie zákazníkov a kľúčové finančné ukazovatele z údajov o predaji, skladbách, žánroch a zákazníkoch. Výsledný dátový model umožňuje viacrozmernú analýzu a vizualizáciu kľúčových metrík, ako je popularita žánrov, tržby podľa regiónov, časové trendy v nákupoch a preferencie zákazníkov.
## 1. Úvod a popis zdrojových dát
Cieľom projektu je analyzovať údaje týkajúce sa hudobných skladieb, používateľov a ich nákupov. Táto analýza identifikuje kľúčové trendy v preferenciách zákazníkov, najpopulárnejších žánroch, skladateľoch a nákupnom správaní používateľov.
Východiskové údaje pochádzajú zo súboru údajov Chinook, ktorý obsahuje informácie o predaji hudobných skladieb, albumov, žánrov a zákazníkov. Súbor údajov obsahuje 10 hlavných tabuliek:
<br />

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









