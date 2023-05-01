drop table "TROLEJBUSY, TRAMVAJE";
drop table AUTOBUSY;
drop table KONTROLY;
drop table ZÁVADY;
drop table JÍZDY;
drop table ZAMĚSTNANCI;
drop table VOZIDLA;
drop sequence JÍZDY_SEQ;
drop sequence ZÁVADY_SEQ;
drop materialized view zavady_pro_inspekci;



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
    "Pocet mist"  number(3),
    "Pojizdnost"  varchar(10)
    constraint "Pojizdnost vozidla"      check ("Pojizdnost" in ('pojizdne', 'nepojizdne'))
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

/* kursor pro prochazeni a zmenu ridice*/
CREATE OR REPLACE PROCEDURE zmena_ridicu AS
  -- Nastaveni cursoru na zamestnance kteri maji nejake ridicske opravneni
  CURSOR driver_cursor IS
    SELECT "ID_Zamestnanec", "Jmeno", "Prijmeni"
    FROM ZAMĚSTNANCI
    WHERE "Typ ridicskeho opravneni" IS NOT NULL;

  my_id ZAMĚSTNANCI."ID_Zamestnanec"%TYPE;
  my_name ZAMĚSTNANCI."Jmeno"%TYPE;
  my_surname ZAMĚSTNANCI."Prijmeni"%TYPE;

  -- exception handler
  PROCEDURE handle_exception AS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
  END;

BEGIN
  OPEN driver_cursor;
  FETCH driver_cursor INTO my_id, my_name, my_surname;

  -- Prochazeni kurzorem a vypis
  WHILE driver_cursor%FOUND LOOP
    -- Print the employee's name and surname
    DBMS_OUTPUT.PUT_LINE('Employee: ' || my_name || ' ' || my_surname);

    -- zmena na typ zamestnance = R
    UPDATE ZAMĚSTNANCI
    SET "Typ zamestnance" = 'R'
    WHERE "ID_Zamestnanec" = my_id;

    -- nacteni dalsiho radku
    FETCH driver_cursor INTO my_id, my_name, my_surname;
  END LOOP;

  CLOSE driver_cursor;
EXCEPTION

  WHEN OTHERS THEN
    handle_exception;
END;

BEGIN
    zmena_ridicu();
end;

/* trigger 1 - pri aktualizaci nebo vlozeni ZAVADY se zmeni stav pojizdnosti v tabulce VOZIDLA*/
CREATE OR REPLACE TRIGGER Nepojizdnost_on_update
AFTER UPDATE OR INSERT ON ZÁVADY
FOR EACH ROW
BEGIN
    UPDATE VOZIDLA SET "Pojizdnost" =  :NEW."Zavaznost"
    WHERE VOZIDLA.ID_Vozidlo = :NEW.FK_ID_Vozidlo;
END;

/*trigger 2 - pri aktualizaci "Datumu vyreseni" se zmeni stav v tabulce VOZIDLO na "pojizdne" */
CREATE OR REPLACE TRIGGER Opravene_vozidlo_on_update
AFTER UPDATE OF "Datum vyreseni" ON ZÁVADY
FOR EACH ROW
BEGIN
    UPDATE VOZIDLA SET "Pojizdnost" = 'pojizdne'
    WHERE VOZIDLA.ID_Vozidlo = :NEW.FK_ID_Vozidlo;
END;

/* index pro kategorizaci velkych a malych vozidel */
CREATE INDEX VELKE_VOZIDLA
    ON VOZIDLA("Pocet mist");

/* index spojujici vedouciho s kontrolou pro rychlejsi vyhledavani - pouzito v EXPLAIN PLAN*/
CREATE INDEX IDX_Vedouci_kontroly ON KONTROLY (FK_ID_Vozidlo, FK_ID_Vedouci);

commit;

insert into VOZIDLA values (55, 7, 'pojizdne');
insert into VOZIDLA values (73, 50, 'pojizdne');
insert into VOZIDLA values (7, 1, 'pojizdne');
insert into VOZIDLA values (14, 20, 'pojizdne');
insert into VOZIDLA values (1, 20, 'pojizdne');
insert into VOZIDLA values (2, 20, 'pojizdne');
insert into VOZIDLA values (3, 88, 'pojizdne');
insert into VOZIDLA values (4, 20, 'pojizdne');
insert into VOZIDLA values (5, 20, 'pojizdne');
insert into VOZIDLA values (6, 20, 'pojizdne');
insert into VOZIDLA values (8, 20, 'pojizdne');
insert into VOZIDLA values (9, 20, 'pojizdne');
insert into VOZIDLA values (10, 20, 'pojizdne');
insert into VOZIDLA values (11, 20, 'pojizdne');
insert into VOZIDLA values (12, 20, 'pojizdne');
insert into VOZIDLA values (13, 20, 'pojizdne');
insert into VOZIDLA values (16, 20, 'pojizdne');
insert into VOZIDLA values (15, 20, 'pojizdne');

insert into AUTOBUSY values (73, '3J97005');
insert into AUTOBUSY values (1, '8A50070');
insert into AUTOBUSY values (7, '1A50071');
insert into AUTOBUSY values (8, '2A50072');
insert into AUTOBUSY values (9, '3A50073');
insert into AUTOBUSY values (10, '4A50074');
insert into AUTOBUSY values (11, '5A50075');
insert into AUTOBUSY values (12, '6A50076');
insert into AUTOBUSY values (13, '7A50077');
insert into AUTOBUSY values (15, '9A50078');
insert into AUTOBUSY values (16, '1A52079');

insert into "TROLEJBUSY, TRAMVAJE" values (55);
insert into "TROLEJBUSY, TRAMVAJE" values (3);

insert into ZAMĚSTNANCI values (895, 'Jan', 'Mechanicky', 'B', 'V');
insert into ZAMĚSTNANCI values (654, 'Veronika', 'Nicneumetelova', 'T', 'R');
insert into ZAMĚSTNANCI values (845, 'Pepa', 'Zly', 'B', 'S');
insert into ZAMĚSTNANCI values (112, 'Šimon', 'Hodny', null, 'S');
insert into ZAMĚSTNANCI values (896, 'Jana', 'Komara', 'D', 'S');
insert into ZAMĚSTNANCI values (897, 'Oto', 'Wichterle', 'B', 'R');
insert into ZAMĚSTNANCI values (898, 'Josef', 'Pepa', '', 'S');
insert into ZAMĚSTNANCI values (899, 'Karel', 'Kryl', 'D', 'R');
insert into ZAMĚSTNANCI values (900, 'Karla', 'Krylova', 'B', 'R');
insert into ZAMĚSTNANCI values (901, 'Lena', 'Nevime', 'B', 'R');
insert into ZAMĚSTNANCI values (902, 'Ondra', 'Bis', 'B', 'V');
insert into ZAMĚSTNANCI values (903, 'Iveta', 'Peer', '', 'S');
insert into ZAMĚSTNANCI values (904, 'Sasha', 'Rashile', '', 'V');
insert into ZAMĚSTNANCI values (905, 'Illaoi', 'Topová', '', 'S');
insert into ZAMĚSTNANCI values (906, 'Ahri', 'Mid', 'C', 'S');
insert into ZAMĚSTNANCI values (907, 'Zyra', 'Supporting', 'E', 'R');


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
insert into ZÁVADY values (67, to_timestamp('06-07-1415', 'DD-MM-YYYY'), null, 'autobus shorel v Kostnici', 73, 1, 'nepojizdne', 895);
insert into ZÁVADY ("Datum vzniku", "Datum vyreseni", "Popis problemu", FK_ID_Vozidlo, FK_ID_Jizda, "Zavaznost", FK_ID_Vedouci)
values (to_timestamp('25-08-1944', 'DD-MM-YYYY'), to_timestamp('25-09-1944', 'DD-MM-YYYY'), 'tramvaj trefila letecká puma', 3, null, 'nepojizdne', 654);
insert into ZÁVADY ("Datum vzniku", "Datum vyreseni", "Popis problemu", FK_ID_Vozidlo, FK_ID_Jizda, "Zavaznost", FK_ID_Vedouci)
values (to_timestamp('14-11-2022', 'DD-MM-YYYY'), null ,'tramvaj poškodili protestující studenti FSS',55, 4, 'pojizdne', 654);

insert into KONTROLY values (3, 73, 3, 895, null, 'akutni', to_timestamp('07-12-2022', 'DD-MM-YYYY'), 'autobus nemel kola, ale vyreseno');
insert into KONTROLY values (4, 3, null, 895, 845, 'pravidelna', to_timestamp('07-01-2023', 'DD-MM-YYYY'), 'vse ok');
insert into KONTROLY values (85, 10, null, 895, null, 'pravidelna', to_timestamp('08-11-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (80, 10, null, 904, null, 'pravidelna', to_timestamp('09-10-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (5, 13, null, 895, null, 'pravidelna', to_timestamp('01-09-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (6, 16, null, 895, null, 'pravidelna', to_timestamp('02-01-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (7, 12, null, 904, null, 'pravidelna', to_timestamp('03-08-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (8, 14, null, 904, null, 'pravidelna', to_timestamp('04-03-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (9, 14, null, 895, null, 'pravidelna', to_timestamp('05-04-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (11, 16, null, 904, null, 'pravidelna', to_timestamp('06-06-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (10, 14, null, 904, null, 'pravidelna', to_timestamp('07-09-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (12, 16, null, 904, null, 'pravidelna', to_timestamp('24-05-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (13, 16, null, 895, null, 'pravidelna', to_timestamp('31-12-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (14, 15, null, 895, null, 'pravidelna', to_timestamp('15-02-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (15, 10, null, 895, null, 'pravidelna', to_timestamp('18-03-2022', 'DD-MM-YYYY'), '');
insert into KONTROLY values (16, 11, null, 904, null, 'pravidelna', to_timestamp('19-02-2022', 'DD-MM-YYYY'), '');

/* nastaveni prav pro xjirmu00 pro tabulky zavad a zamestnancu - simulace inspekce */
GRANT ALL PRIVILEGES ON ZÁVADY TO XJIRMU00;
GRANT ALL PRIVILEGES ON ZAMĚSTNANCI TO XJIRMU00;

/* vytvoreni materializovaneho pohledu jako inspekce */
CREATE MATERIALIZED VIEW zavady_pro_inspekci
REFRESH on COMMIT
AS
SELECT "Datum vzniku", "Datum vyreseni", "Popis problemu", "Jmeno", "Prijmeni" FROM ZÁVADY join ZAMĚSTNANCI Z on Z."ID_Zamestnanec" = ZÁVADY.FK_ID_Vedouci;

commit;

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

/* pouziti INDEXU pro vypsani vsech autobusu ktere maji 20 a vice mist */

select "Registracni znacka", "Pocet mist" from VOZIDLA V natural join AUTOBUSY A where V.ID_Vozidlo = A."ID_Autobus" and "Pocet mist" >= 20;


/* EXPLAIN PLAN - `jmeno` udelal pocet kontrol na autobusech*/
select "Prijmeni", COUNT("ID_Kontrola") as pocet_kontrol from AUTOBUSY A join VOZIDLA V on V.ID_Vozidlo = A."ID_Autobus" join KONTROLY K on V.ID_Vozidlo = K.FK_ID_Vozidlo join ZAMĚSTNANCI Z on Z."ID_Zamestnanec" = K.FK_ID_Vedouci and Z."ID_Zamestnanec" = K.FK_ID_Vedouci group by "Jmeno", "Prijmeni";
/* pridanim indexu IDX_Vedouci_kontroly spojujiciho jmeno vedouciho a id kontroly bylo dosazeno optimalizace */


/* rozdeleni vozidel na MALE a VELKE podle poctu mist*/
WITH velikost_vozidel AS (
  SELECT ID_Vozidlo, "Pocet mist"
  FROM VOZIDLA
)

SELECT
  velikost_vozidel.ID_Vozidlo,
  CASE
    WHEN velikost_vozidel."Pocet mist" > 15
    THEN 'VELKE'
    ELSE 'MALE'
  END AS kategorie
FROM velikost_vozidel
JOIN VOZIDLA ON velikost_vozidel.ID_Vozidlo = VOZIDLA.ID_Vozidlo;


