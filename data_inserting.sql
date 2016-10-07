--Funkcje
INSERT ALL
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('SZEFUNIO',90,110)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('BANDZIOR',70,90)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('LOWCZY',60,70)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('LAPACZ',50,60)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('KOT',40,50)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('MILUSIA',20,30)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('DZIELCZY',45,55)
  INTO Funkcje(funkcja,min_myszy,max_myszy) VALUES ('HONOROWA',6,25)
SELECT DUMMY  FROM dual;

--Wrogowie
INSERT ALL
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('KAZIO',10,'CZLOWIEK','FLASZKA')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('BUREK',4,'PIES','KOSC')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('DZIKI BILL',10,'PIES',NULL)
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('REKSIO',2,'PIES','KOSC')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('BETHOVEN',1,'PIES','PEDIGRIPALL')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('CHYTRUSEK',5,'LIS','KURCZAK')
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('SMUKLA',1,'SOSNA',NULL)
 INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka) VALUES ('BAZYLI',3,'KOGUT','KURA DO STADA')
SELECT DUMMY  FROM dual;

--Bandy
INSERT ALL
 INTO Bandy(nr_bandy,nazwa,teren) VALUES (1,'SZEFOSTWO','CALOSC')
 INTO Bandy(nr_bandy,nazwa,teren) VALUES (2,'CZARNI RYCERZE','POLE')
 INTO Bandy(nr_bandy,nazwa,teren) VALUES (3,'BIALI LOWCY','SAD')
 INTO Bandy(nr_bandy,nazwa,teren) VALUES (4,'LACIACI MYSLIWI','GORKA')
 INTO Bandy(nr_bandy,nazwa,teren) VALUES (5,'ROCKERSI','ZAGRODA')
SELECT DUMMY  FROM dual;


--Kocury 
INSERT ALL
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3)
  
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1)
  
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4)
  
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4)
  INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4)
SELECT DUMMY  FROM dual;

  
  






  
  




