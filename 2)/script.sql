



DROP TABLE Kontrola;

CREATE TABLE Kontrola
(
    Kontrola_ID                     INT PRIMARY KEY, -- primary key column
    "Typ kontroly"                  VARCHAR(15),
    CONSTRAINT "Typ kontroly" CHECK ("Typ kontroly" IN ('pravidelná', 'akutní')),
    "Datum kontroly"                DATE,
    "Kontrolni zprava"              VARCHAR(200),
    "Vedouci kontrolni technik"     VARCHAR(30)
    
    -- specify more columns here
);

CREATE TABLE Závada
(
    "Zavada_ID"       INT PRIMARY KEY,
    "Datum vzniku"    DATE,
    "Datum vyreseni"  DATE,
    "Popis problemu"  VARCHAR(150),
    "Zavaznost"       VARCHAR(10),
    CONSTRAINT "Zavaznost" CHECK ("Zavaznost" IN ('pojízdné', ))
)