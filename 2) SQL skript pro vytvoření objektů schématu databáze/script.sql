
drop table Vozidlo;
drop table Jízda;
drop table Závada;
drop table Kontrola;

create table Kontrola
(
    Kontrola_ID                     int primary key,
    "Typ kontroly"                  varchar(15),
    constraint "Typ kontroly" check ("Typ kontroly" in ('pravidelná', 'akutní')),
    "Datum kontroly"                date,
    "Kontrolni zprava"              varchar(200),
    "Vedouci kontrolni technik"     varchar(30)
);

create table Závada
(
    "Zavada_ID"       int primary key,
    "Datum vzniku"    date,
    "Datum vyreseni"  date,
    "Popis problemu"  varchar(150),
    "Zavaznost"       varchar(10),
    constraint "Zavaznost" check ("Zavaznost" in ('pojízdné'))
);

create table Jízda
(
    "Jizda_ID"      int primary key,
    "Zacatek jizdy" timestamp,
    "Konec jizdy"   timestamp
);

create table Vozidlo
(
    "ID_Vozidla"    int primary key,
    "Pocet mist"    number(3)
);

create table Autobus
(
    "ID_Vozidla"            int primary key,
    "Registracni znacka"    varchar(7),
    CONSTRAINT "Registracni znacka" CHECK (REGEXP_LIKE("Registracni znacka", '^[1-9][a-z][a-z0-9][0-9]{4}$')),
);

create table "Trolejbus, tramvaj"
(
    "ID_Vozidla"    int primary key
);

create table "Servisní technik"
(
    "ID_technika"   int primary key
);


insert into Jízda values (666, to_timestamp('03-05-2022 08:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 10:25', 'DD-MM-YYYY HH24:MI'));