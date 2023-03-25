drop table "Servisní technici";
drop table "Trolejbusy, tramvaje";
drop table Autobusy;
drop table Jízdy;
drop table Vozidla;
drop table Závady;
drop table Kontroly;
drop table Zaměstnanci;

create  table Zaměstnanci
(
    "Zamestnanec_ID"                int primary key,
    "Jmeno"                         varchar(20),
    "Prijmeni"                      varchar(30),
    "Pozice"                        varchar(20),
    constraint "Druh pozice"        check ("Pozice" in ('ridic', 'servisni technik', 'vedouci')),
    "Typ ridicskeho opravneni"      varchar(5)
);

create table Kontroly
(
    "Kontrola_ID"                   int primary key,
    "Typ kontroly"                  varchar(15),
    constraint "Druh kontroly"      check ("Typ kontroly" in ('pravidelna', 'akutni')),
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
    constraint "Mira zavaznosti" check ("Zavaznost" in ('pojizdne', 'nepojizdne'))
);

create table Vozidla
(
    ID_Vozidla    int primary key,
    "Pocet mist"    number(3)
);

create table Jízdy
(
    "Jizda_ID"      int not null primary key,
    FK_Vuz_ID          int,
    CONSTRAINT Vuz_ID foreign key (FK_Vuz_ID) references Vozidla (ID_Vozidla),
    "Zacatek jizdy" timestamp,
    "Konec jizdy"   timestamp
);
create table Autobusy
(
    "ID_Vozidla"            int primary key,
    "Registracni znacka"    varchar(7),
    CONSTRAINT "SPZ" CHECK (REGEXP_LIKE("Registracni znacka", '^[1-9][A-Z][A-Z0-9][0-9]{4}$'))
);

create table "Trolejbusy, tramvaje"
(
    "ID_Vozidla"    int primary key
);

create table "Servisní technici"
(
    "ID_technika"   int primary key
);

commit;
insert into Autobusy values (55, '1BT6883');
insert into Autobusy values (73, '7B68569');
commit;

insert into Jízdy values (13,55, to_timestamp('03-05-2022 08:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 10:25', 'DD-MM-YYYY HH24:MI'));



insert into "Servisní technici" values (100);
insert into "Servisní technici" values (20);

insert into "Trolejbusy, tramvaje" values (15);

insert into Vozidla values (3, 888);
insert into Vozidla values (7, 1);

insert into Závady values (55, to_timestamp('03-05-2022', 'DD-MM-YYYY'), to_timestamp('05-05-2022', 'DD-MM-YYYY'), 'vrzalo zadni prave kolo', 'pojizdne');
insert into Závady values (95, to_timestamp('06-07-1415', 'DD-MM-YYYY'), to_timestamp('25-3-1645', 'DD-MM-YYYY'), 'autobus shorel v kostnici', 'nepojizdne');

insert into Kontroly values (77, 'akutni', to_timestamp('07-12-2022', 'DD-MM-YYYY'), 'trolejbus nemel kola, ale vyreseno', '555');

insert into Zaměstnanci values (895, 'Jan', 'Mechanicky', 'servisni technik', 'B');
insert into Zaměstnanci values (654, 'Veronika', 'Nicneumetelova', 'ridic', 'B, D, T');

select FK_Vuz_ID, "Pocet mist" from Jízdy inner join Vozidla V on V.ID_Vozidla = Jízdy.FK_Vuz_ID;


commit;