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
    FK_ID_Zavada                    int,
    foreign key (FK_ID_Zavada) references ZÁVADY ("ID_Zavada"),
    FK_ID_Vedouci                   int not null,
    foreign key (FK_ID_Vedouci) references ZAMĚSTNANCI ("ID_Zamestnanec"),
    FK_ID_Pracovnik                 int,
    foreign key (FK_ID_Pracovnik) references ZAMĚSTNANCI ("ID_Zamestnanec"),
    "Typ kontroly"                  varchar(15),
    constraint "Druh kontroly"      check ("Typ kontroly" in ('pravidelna', 'akutni')),
    "Datum kontroly"                date not null,
    "Kontrolni zprava"              varchar(200)
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
insert into VOZIDLA values (14, 20);

insert into AUTOBUSY values (73, '3J97005');
insert into AUTOBUSY values (14, '8A50071');

insert into "TROLEJBUSY, TRAMVAJE" values (55);
insert into "TROLEJBUSY, TRAMVAJE" values (3);

insert into ZAMĚSTNANCI values (895, 'Jan', 'Mechanicky', 'B', 'V');
insert into ZAMĚSTNANCI values (654, 'Veronika', 'Nicneumetelova', 'T', 'R');
insert into ZAMĚSTNANCI values (845, 'Pepa', 'Zly', 'B', 'S');
insert into ZAMĚSTNANCI values (112, 'Šimon', 'Hodny', null, 'S');


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

insert into KONTROLY values (3, 55, 3, 895, null, 'akutni', to_timestamp('07-12-2022', 'DD-MM-YYYY'), 'trolejbus nemel kola, ale vyreseno');
insert into KONTROLY values (4, 3, null, 895, 845, 'pravidelna', to_timestamp('07-01-2023', 'DD-MM-YYYY'), 'vse ok');

commit;

/*
  Konkrétně musí tento skript obsahovat alespoň dva dotazy využívající spojení dvou tabulek,
  jeden využívající spojení tří tabulek, dva dotazy s klauzulí GROUP BY
  a agregační funkcí, jeden dotaz obsahující predikát EXISTS a
  jeden dotaz s predikátem IN s vnořeným selectem (nikoliv IN s množinou konstantních dat),
  tj. celkem minimálně 7 dotazů. U každého z dotazů musí být (v komentáři SQL kódu) popsáno srozumitelně,
  jaká data hledá daný dotaz (jaká je jeho funkce v aplikaci).
 */


/* Spojeni dvou tabulek 2x */
/* informace o vozidle, ktere vyjelo v dany cas */
select "Pocet mist", ID_Vozidlo, "ID_Jizda" from VOZIDLA natural join JÍZDY where FK_ID_Vuz=ID_Vozidlo AND "Zacatek jizdy" = to_timestamp('16-11-1414 08:00', 'DD-MM-YYYY HH24:MI');
/* informace o zamestnancich, kteri vedli zavady oznacene jako pojizdne */
select "Jmeno", "Prijmeni" from ZAMĚSTNANCI natural join ZÁVADY where FK_ID_Vedouci="ID_Zamestnanec" and "Zavaznost"='pojizdne';

/* Spojeni 3 tabulek = jmeno a prijmeni vedouciho z kontroly a pocet mist kontrolovaneho vozu */
select "Jmeno", "Prijmeni", "Pocet mist" from ZAMĚSTNANCI Z natural join KONTROLY K natural join VOZIDLA V where Z."ID_Zamestnanec" = K.FK_ID_Vedouci AND V.ID_Vozidlo=K.FK_ID_Vozidlo;

/* Group by a agregace 2x */
/* celkovy pocet jizd vozidla */
select ID_Vozidlo, COUNT("ID_Jizda") as pocet_jizd from VOZIDLA natural join JÍZDY J where VOZIDLA.ID_Vozidlo = J.FK_ID_Vuz group by ID_Vozidlo;

/* prumerny pocet mist vsech vozidel */
select avg("Pocet mist") as prum_pocet_mist from VOZIDLA;

/* pocet kontrol vedoucich zamestancu */
select "Jmeno", "Prijmeni", COUNT("ID_Kontrola") as pocet_kontrol from ZAMĚSTNANCI Z natural join KONTROLY K where Z."ID_Zamestnanec" = K.FK_ID_Vedouci group by "Jmeno", "Prijmeni";

/* Exists = vozidla, ktera maji zaznam o zavade v databazi*/

select ID_Vozidlo from VOZIDLA V where exists(select * from ZÁVADY Z where Z.FK_ID_Vozidlo=V.ID_Vozidlo);

/* In + vnoreny select = vypis zamestnancu s poctem jizd, ktere maji nejaky zaznam o jizde*/

select "Jmeno", "Prijmeni", count("ID_Zamestnanec") as pocet_jizd from ZAMĚSTNANCI where "ID_Zamestnanec" in (select "ID_Zamestnanec" from JÍZDY where FK_ID_Zamestnanec="ID_Zamestnanec") group by "Jmeno", "Prijmeni";
