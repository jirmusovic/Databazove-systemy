drop table "Servisní technici";
drop table "Trolejbusy, tramvaje";
drop table Autobusy;
drop table Vozidla;
drop table Jízdy;
drop table Závady;
drop table Kontroly;
drop table Zaměstnanci;

create  table Zaměstnanci
(
    "Zamestnanec_ID"                int primary key,
    "Jmeno"                         varchar(20),
    "Prijmeni"                      varchar(30),
    "Pozice"                        varchar(20),
    constraint "Druh pozice"        check ("Pozice" in ('řidič', 'servisní technik', 'vedoucí')),
    "Typ ridicskeho opravneni"      varchar(5)
);

create table Kontroly
(
    "Kontrola_ID"                   int primary key,
    "Typ kontroly"                  varchar(15),
    constraint "Druh kontroly"      check ("Typ kontroly" in ('pravidelná', 'akutní')),
    "Datum kontroly"                date,
    "Kontrolni zprava"              varchar(200),
    "Vedouci kontrolni technik"     varchar(30)
);

create table Závady
(
    "Zavada_ID"       int primary key,
    "Datum vzniku"    date,
    "Datum vyreseni"  date,
    "Popis problemu"  varchar(150),
    "Zavaznost"       varchar(10),
    constraint "Mira zavaznosti" check ("Zavaznost" in ('pojízdné'))
);

create table Jízdy
(
    "Jizda_ID"      int primary key,
    "Zacatek jizdy" timestamp,
    "Konec jizdy"   timestamp
);

create table Vozidla
(
    "ID_Vozidla"    int primary key,
    "Pocet mist"    number(3)
);

create table Autobusy
(
    "ID_Vozidla"            int primary key,
    "Registracni znacka"    varchar(7),
    CONSTRAINT "SPZ" CHECK (REGEXP_LIKE("Registracni znacka", '^[1-9][a-z][a-z0-9][0-9]{4}$'))
);

create table "Trolejbusy, tramvaje"
(
    "ID_Vozidla"    int primary key
);

create table "Servisní technici"
(
    "ID_technika"   int primary key
);


insert into Jízdy values (666, to_timestamp('03-05-2022 08:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 10:25', 'DD-MM-YYYY HH24:MI'));
