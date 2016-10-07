alter session set nls_date_format='yyyy-mm-dd';

CREATE TABLE Bandy
  (nr_bandy NUMBER(2) CONSTRAINT bandy_pk PRIMARY KEY,
  nazwa VARCHAR2(20) CONSTRAINT bandy_nazwa_not_null NOT NULL,
  teren VARCHAR2(15) CONSTRAINT bandy_teren_unique UNIQUE,
  szef_bandy VARCHAR2(15) );
  
CREATE TABLE Funkcje
  (funkcja VARCHAR2(10) CONSTRAINT funkcje_pk PRIMARY KEY,
  min_myszy NUMBER(3) CONSTRAINT funkcje_min_myszy CHECK ( min_myszy > 5),
  max_myszy NUMBER(3) CONSTRAINT funkcje_max_myszy CHECK (max_myszy < 200),
  CONSTRAINT max_myszy_and_min_myszy CHECK (max_myszy >= min_myszy)
  );
  
CREATE TABLE Wrogowie
  (imie_wroga VARCHAR2(15) CONSTRAINT wrogowie_pk PRIMARY KEY,
  stopien_wrogosci NUMBER(2) CONSTRAINT wrogowie_stopien_values CHECK (stopien_wrogosci>=1 AND stopien_wrogosci<=10),
  gatunek VARCHAR2(15),
  lapowka VARCHAR2(20)
  );
  
CREATE TABLE Kocury
  (imie VARCHAR2(15) CONSTRAINT kocury_imie_not_null NOT NULL,
  plec VARCHAR2(1) CONSTRAINT kocury_plec_values CHECK(plec IN('M','D')),
  pseudo VARCHAR2(15) CONSTRAINT kocury_pk PRIMARY KEY,
  funkcja VARCHAR2(10) CONSTRAINT kocury_funkcja_fk REFERENCES Funkcje(funkcja),
  szef VARCHAR2(15) CONSTRAINT kocury_szef_fk REFERENCES Kocury(pseudo),
  w_stadku_od DATE  DEFAULT(SYSDATE),
  przydzial_myszy NUMBER(3),
  myszy_extra NUMBER(3) ,
  nr_bandy NUMBER(2) CONSTRAINT kocury_nr_bandy_fk REFERENCES Bandy(nr_bandy)
  );
  
CREATE TABLE Wrogowie_Kocurow
  (pseudo VARCHAR2(15) CONSTRAINT wrogowie_pseudo_fk REFERENCES Kocury(pseudo),
  imie_wroga VARCHAR2(15) CONSTRAINT wrogowie_imie_fk REFERENCES Wrogowie(imie_wroga),
  data_incydentu DATE CONSTRAINT wrogowie_data_not_null NOT NULL,
  opis_incydentu      VARCHAR2(50),
  CONSTRAINT wrogowie_kocurow_pk PRIMARY KEY(pseudo,imie_wroga)
  );
  
ALTER TABLE Bandy
      ADD CONSTRAINT bandy_szef_fk 
      FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);
  
  
  
  
  
  