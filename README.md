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

















