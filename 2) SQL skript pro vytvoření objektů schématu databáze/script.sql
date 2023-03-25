drop table "Trolejbusy, tramvaje";
drop table Autobusy;
drop table Kontroly;
drop table Závady;
drop table Jízdy;

drop table Zaměstnanci;
drop table Vozidla;

create  table Zaměstnanci
(
    "Zamestnanec_ID"                int not null primary key,
    "Jmeno"                         varchar(20),
    "Prijmeni"                      varchar(30),
    "Typ ridicskeho opravneni"      varchar(10),
    "Typ zamestnance"               varchar(1),
    constraint "Druh zamestnance" check ("Typ zamestnance" in ('S', 'V', 'R'))
);


create table Vozidla
(
    ID_Vozidla    int not null primary key,
    "Pocet mist"    number(3)
);

create table Jízdy
(
    "Jizda_ID"      int not null primary key,
    FK_Vuz_ID          int,
    foreign key (FK_Vuz_ID) references Vozidla (ID_Vozidla),
    FK_Zamestnanec_ID   int,
    foreign key (FK_Zamestnanec_ID) references  Zaměstnanci ("Zamestnanec_ID"),
    "Zacatek jizdy" timestamp,
    "Konec jizdy"   timestamp
);

create table Závady
(
    "Zavada_ID"       int not null primary key ,
    "Datum vzniku"    date,
    "Datum vyreseni"  date,
    "Popis problemu"  varchar(150),
    FK_Jizda_ID       int,
    foreign key (FK_Jizda_ID) references Jízdy ("Jizda_ID"),
    "Zavaznost"       varchar(10),
    constraint "Mira zavaznosti" check ("Zavaznost" in ('pojizdne', 'nepojizdne')),
    FK_Vedouci_ID     int,
    foreign key (FK_Vedouci_ID) references  Zaměstnanci("Zamestnanec_ID")
);

create table Kontroly
(
    "Kontrola_ID"                   int not null primary key,
    FK_Vozidlo_ID                   int not null,
    foreign key (FK_Vozidlo_ID) references Vozidla (ID_Vozidla),
    FK_Zavada_ID                    int,
    foreign key (FK_Zavada_ID) references Závady ("Zavada_ID"),
    FK_Vedouci_ID                   int not null,
    foreign key (FK_Vedouci_ID) references Zaměstnanci ("Zamestnanec_ID"),
    FK_Pracovnik_ID                 int,
    foreign key (FK_Pracovnik_ID) references Zaměstnanci ("Zamestnanec_ID"),
    "Typ kontroly"                  varchar(15),
    constraint "Druh kontroly"      check ("Typ kontroly" in ('pravidelna', 'akutni')),
    "Datum kontroly"                date,
    "Kontrolni zprava"              varchar(200),
    "Vedouci kontrolni technik"     varchar(30)
);


create table Autobusy
(
    "ID_Autobus"            int not null primary key,
    "Registracni znacka"    varchar(7),
    CONSTRAINT "SPZ" CHECK (REGEXP_LIKE("Registracni znacka", '^[1-9][A-Z][A-Z0-9][0-9]{4}$')),
    FK_Vozidla_ID          int,
    foreign key (FK_Vozidla_ID) references Vozidla (ID_Vozidla)
);

create table "Trolejbusy, tramvaje"
(
    "ID_Trolej"    int not null primary key,
    FK_Trolej_ID          int,
    foreign key (FK_Trolej_ID) references Vozidla (ID_Vozidla)
);


commit;
insert into Vozidla values (55, 7);
insert into Vozidla values (73, 9);

insert into Zaměstnanci values (895, 'Jan', 'Mechanicky', 'B', 'V');
insert into Zaměstnanci values (654, 'Veronika', 'Nicneumetelova', 'B, D, T', 'R');
insert into Zaměstnanci values (845, 'Pepa', 'Zly', 'B', 'S');

insert into Jízdy values (13, 55, 654, to_timestamp('03-05-2022 08:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 10:25', 'DD-MM-YYYY HH24:MI'));

insert into "Trolejbusy, tramvaje" values (73, 73);

insert into Vozidla values (3, 888);
insert into Vozidla values (7, 1);

insert into Závady values (55, to_timestamp('03-05-2022', 'DD-MM-YYYY'), to_timestamp('05-05-2022', 'DD-MM-YYYY'), 'vrzalo zadni prave kolo', 13, 'pojizdne', 895);
insert into Závady values (95, to_timestamp('06-07-1415', 'DD-MM-YYYY'), to_timestamp('25-3-1645', 'DD-MM-YYYY'), 'autobus shorel v kostnici', null, 'nepojizdne', 895);

insert into Kontroly values (77, 3, 95, 895, null, 'akutni', to_timestamp('07-12-2022', 'DD-MM-YYYY'), 'trolejbus nemel kola, ale vyreseno', '555');

commit;