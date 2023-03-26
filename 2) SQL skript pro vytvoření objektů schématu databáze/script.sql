drop table "TROLEJBUSY, TRAMVAJE";
drop table AUTOBUSY;
drop table KONTROLY;
drop table ZÁVADY;
drop table JÍZDY;
drop table ZAMĚSTNANCI;
drop table VOZIDLA;
drop sequence JÍZDY_SEQ;
drop sequence ZÁVADY_SEQ;

/*sekvence pro automatické číslování jízd, pokud je uživatel nezadá ručně*/
CREATE SEQUENCE JÍZDY_SEQ
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;

/*sekvence pro automatické číslování závad, pokud je uživatel nezadá ručně*/
CREATE SEQUENCE ZÁVADY_SEQ
  START WITH 1
  INCREMENT BY 1
  NOMAXVALUE;

/*specializace je řešená přes atribut "Typ zaměstnance": S - servisní technik, V - vedoucí technik, R - řidič*/
create  table ZAMĚSTNANCI
(
    "ID_Zamestnanec"                int not null primary key,
    "Jmeno"                         varchar(20) not null,
    "Prijmeni"                      varchar(30) not null,
    "Typ ridicskeho opravneni"      varchar(10),
    "Typ zamestnance"               varchar(1),
    constraint "Druh zamestnance" check ("Typ zamestnance" in ('S', 'V', 'R'))
);

/*generalizace pro tabulky "AUTOBUSY" a "TROLEJBUSY, TRAMVAJE", primární klíče z této tabulky jsou přejímány do specializací*/
create table VOZIDLA
(
    ID_Vozidlo    int not null primary key,
    "Pocet mist"  number(3)
);

create table JÍZDY
(
    "ID_Jizda"          int not null primary key,
    FK_ID_Vuz           int not null,
    foreign key (FK_ID_Vuz) references VOZIDLA (ID_Vozidlo),
    FK_ID_Zamestnanec   int not null,
    foreign key (FK_ID_Zamestnanec) references  ZAMĚSTNANCI ("ID_Zamestnanec"),
    "Zacatek jizdy"     timestamp,
    "Konec jizdy"       timestamp
);

create table ZÁVADY
(
    "ID_Zavada"       int not null primary key,
    "Datum vzniku"    date not null,
    "Datum vyreseni"  date,
    "Popis problemu"  varchar(150),
    FK_ID_Vozidlo     int not null,
    foreign key (FK_ID_Vozidlo) references VOZIDLA (ID_Vozidlo),
    FK_ID_Jizda       int,
    foreign key (FK_ID_Jizda) references JÍZDY ("ID_Jizda"),
    "Zavaznost"       varchar(10),
    constraint "Mira zavaznosti" check ("Zavaznost" in ('pojizdne', 'nepojizdne')),
    FK_ID_Vedouci     int not null,
    foreign key (FK_ID_Vedouci) references  ZAMĚSTNANCI("ID_Zamestnanec")
);

create table KONTROLY
(
    "ID_Kontrola"                   int not null primary key,
    FK_ID_Vozidlo                   int not null,
    foreign key (FK_ID_Vozidlo) references VOZIDLA (ID_Vozidlo),
    FK_ID_Zavada                    int not null,
    foreign key (FK_ID_Zavada) references ZÁVADY ("ID_Zavada"),
    FK_ID_Vedouci                   int not null,
    foreign key (FK_ID_Vedouci) references ZAMĚSTNANCI ("ID_Zamestnanec"),
    FK_ID_Pracovnik                 int,
    foreign key (FK_ID_Pracovnik) references ZAMĚSTNANCI ("ID_Zamestnanec"),
    "Typ kontroly"                  varchar(15),
    constraint "Druh kontroly"      check ("Typ kontroly" in ('pravidelna', 'akutni')),
    "Datum kontroly"                date not null,
    "Kontrolni zprava"              varchar(200),
    "Vedouci kontrolni technik"     varchar(30)
);

/*specializace od VOZIDLA; má navíc atribut registrační značka; hodnoty přejímají primární klíč z VOZIDLA*/
create table AUTOBUSY
(
    "ID_Autobus"            int not null,
    foreign key ("ID_Autobus") references VOZIDLA (ID_Vozidlo),
    "Registracni znacka"    varchar(7),
    CONSTRAINT "SPZ" CHECK (REGEXP_LIKE("Registracni znacka", '^[1-9][A-Z][A-Z0-9][0-9]{4}$'))
);

/*specializace od VOZIDLA; hodnoty přejímají primární klíč z VOZIDLA*/
create table "TROLEJBUSY, TRAMVAJE"
(
    "ID_Trolej"    int not null,
    foreign key ("ID_Trolej") references VOZIDLA (ID_Vozidlo)
);

ALTER TABLE JÍZDY MODIFY "ID_Jizda" DEFAULT JÍZDY_SEQ.NEXTVAL;
ALTER TABLE ZÁVADY MODIFY "ID_Zavada" DEFAULT ZÁVADY_SEQ.NEXTVAL;
commit;

insert into VOZIDLA values (55, 7);
insert into VOZIDLA values (73, 50);
insert into VOZIDLA values (3, 88);
insert into VOZIDLA values (7, 1);

insert into AUTOBUSY values (73, '3J97005');

insert into "TROLEJBUSY, TRAMVAJE" values (55);
insert into "TROLEJBUSY, TRAMVAJE" values (3);

insert into ZAMĚSTNANCI values (895, 'Jan', 'Mechanicky', 'B', 'V');
insert into ZAMĚSTNANCI values (654, 'Veronika', 'Nicneumetelova', 'T', 'R');
insert into ZAMĚSTNANCI values (845, 'Pepa', 'Zly', 'B', 'S');

insert into JÍZDY (FK_ID_Vuz, FK_ID_Zamestnanec, "Zacatek jizdy", "Konec jizdy")
values (73, 654, to_timestamp('16-11-1414 08:00', 'DD-MM-YYYY HH24:MI'), to_timestamp('06-07-1415 10:35', 'DD-MM-YYYY HH24:MI'));
insert into JÍZDY (FK_ID_Vuz, FK_ID_Zamestnanec, "Zacatek jizdy", "Konec jizdy")
values (55, 654, to_timestamp('03-05-2022 08:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 10:25', 'DD-MM-YYYY HH24:MI'));
insert into JÍZDY (FK_ID_Vuz, FK_ID_Zamestnanec, "Zacatek jizdy", "Konec jizdy")
values (55, 654, to_timestamp('03-05-2022 09:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 11:25', 'DD-MM-YYYY HH24:MI'));
insert into JÍZDY (FK_ID_Vuz, FK_ID_Zamestnanec, "Zacatek jizdy", "Konec jizdy")
values (7, 895, to_timestamp('03-05-2022 13:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('03-05-2022 14:15', 'DD-MM-YYYY HH24:MI'));
insert into JÍZDY (FK_ID_Vuz, FK_ID_Zamestnanec, "Zacatek jizdy", "Konec jizdy")
values (55, 895, to_timestamp('14-11-2022 9:55', 'DD-MM-YYYY HH24:MI'), to_timestamp('14-1-2022 10:45', 'DD-MM-YYYY HH24:MI'));

insert into ZÁVADY ("Datum vzniku", "Datum vyreseni", "Popis problemu", FK_ID_Vozidlo, FK_ID_Jizda, "Zavaznost", FK_ID_Vedouci)
values (to_timestamp('03-05-2022', 'DD-MM-YYYY'), to_timestamp('05-05-2022', 'DD-MM-YYYY'), 'vrzalo zadni prave kolo', 7,1, 'pojizdne', 895);
insert into ZÁVADY values (67, to_timestamp('06-07-1415', 'DD-MM-YYYY'), to_timestamp('25-3-1645', 'DD-MM-YYYY'), 'autobus shorel v Kostnici', 73, 1, 'nepojizdne', 895);
insert into ZÁVADY ("Datum vzniku", "Datum vyreseni", "Popis problemu", FK_ID_Vozidlo, FK_ID_Jizda, "Zavaznost", FK_ID_Vedouci)
values (to_timestamp('25-08-1944', 'DD-MM-YYYY'), to_timestamp('25-09-1944', 'DD-MM-YYYY'), 'tramvaj trefila letecká puma', 3, null, 'nepojizdne', 654);
insert into ZÁVADY ("Datum vzniku", "Datum vyreseni", "Popis problemu", FK_ID_Vozidlo, FK_ID_Jizda, "Zavaznost", FK_ID_Vedouci)
values (to_timestamp('14-11-2022', 'DD-MM-YYYY'), null ,'tramvaj poškodili protestující studenti FSS',55, 4, 'pojizdne', 654);

insert into KONTROLY values (3, 55, 3, 895, null, 'akutni', to_timestamp('07-12-2022', 'DD-MM-YYYY'), 'trolejbus nemel kola, ale vyreseno', 555);

commit;