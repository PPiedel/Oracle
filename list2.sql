--Zad17
--Wywietlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujšcych na terenie POLE 
--posdajšcych przydział myszy większy od 50.
--zględnić fakt, że sš w stadzie koty posiadajšce prawo do polowań na całym obsługiwanym przez stado terenie.
-- Nie stosować podzapytań.
SELECT pseudo "Poluje w polu", przydzial_myszy "Przydzial myszy", nazwa "Banda"
FROM  Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE przydzial_myszy > 50 AND teren = 'POLE' OR teren='CALOSC'
ORDER BY przydzial_myszy DESC;

--Zad18
--Wywietlić bez stosowania podzapytania imiona i daty przystšpienia do stada kotów, 
--które przystšpiły do stada przed kotem o imieniu JACEK. Wyniki uporzšdkować malejšco wg daty przystšpienia do stadka.
SELECT
  K1.imie "Imie",
  K1.w_stadku_od "Poluje od"
FROM
  Kocury K1, Kocury K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;
  
--Zad19
--Dla kotów pełnicych funkcję KOT i MILUSIA wy?wietlić w kolejno?ci hierarchii imiona wszystkich ich szefów. Zadanie rozwizać na trzy sposoby:
--a.	z wykorzystaniem tylko złczeń,
--b.	z wykorzystaniem drzewa i operatora CONNECT_BY_ROOT,
--c.	z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH.

--a
SELECT
  K1.imie "Imie",
  '|' " ", 
  K1.funkcja "Funkcja",
  '|' " ",
  NVL(K2.imie,' ') "Szef 1",
  '|' " ",
  NVL(K3.imie,' ') "Szef 2",
  '|' "___",
  NVL(K4.imie,' ') "Szef 3"
FROM 
  Kocury K1 LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
  LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
  LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja IN ('KOT','MILUSIA');

  
  
--Zad20
--Wywietlić imiona wszystkich kotek, które uczestniczyły w incydentach po 01.01.2007. 
--Dodatkowo wywietlić nazwy band do których należš kotki, imiona ich wrogów wraz ze stopniem wrogoci oraz datę incydentu.
SELECT 
  K1.imie "Imie kotki",
  B.nazwa "Nazwa bandy",
  WK.imie_wroga "Imie wroga",
  W.stopien_wrogosci "Ocena wroga",
  WK.data_incydentu "Data inc."
FROM 
  Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
  JOIN Wrogowie_Kocurow WK ON K1.pseudo = WK.pseudo 
  JOIN Wrogowie W ON WK.imie_wroga = W.imie_wroga
WHERE K1.Plec='D'AND WK.data_incydentu > '2007-01-01'
ORDER BY K1.imie;


--Zad21
--Okrelić ile kotów w każdej z band posiada wrogów
SELECT
  B.nazwa "Nazwa bandy",
  NVL(COUNT(DISTINCT K.pseudo),'0') "Koty z wrogrami"    --DISTINCT bo niektore koty maja kilku wrogow
FROM
  Kocury K RIGHT JOIN Bandy B ON K.nr_bandy = B.nr_bandy --moglyby byc bandy bez wrogow
  JOIN Wrogowie_Kocurow WK ON WK.pseudo = K.pseudo
GROUP BY B.nazwa;

--Zad22
--Znaleć koty (wraz z pełnionš funkcjš), które posiadajš więcej niż jednego wroga.
SELECT 
  MAX(K.funkcja) "Funkcja", --max/min
  K.pseudo "Pseudonim kota",
  COUNT(WK.pseudo) "Liczba wrogow"
FROM Kocury K JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
GROUP BY K.pseudo
HAVING COUNT(K.pseudo) > 1;

--Zad23
--Wywietlić imiona kotów, które dostajš myszš premię wraz z ich całkowitym rocznym spożyciem myszy.
--Dodatkowo jeli ich roczna dawka myszy przekracza 864 wywietlić tekst powyzej 864, jeli jest równa 864 tekst 864, 
--jeli jest mniejsza od 864 tekst poniżej 864. Wyniki uporzšdkować malejšco wg rocznej dawki myszy. 
--Do rozwišzania wykorzystać operator zbiorowy UNION.

--zbior dziele na 3 grupy, zgodnie z zadaniem i UNION na kaz
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  'powyzej 864' "Dawka"
FROM Kocury
WHERE (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  > 864 
UNION
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  'ponizej 864' "Dawka"
FROM Kocury
WHERE (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  < 864 
UNION
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  '864' "Dawka"
FROM Kocury
WHERE (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  = 864
ORDER BY "Dawka Roczna" DESC;

--Zad24
--Znaleć bandy, które nie posiadajš członków. Wywietlić ich numery, nazwy i tereny operowania. 
--Zadanie rozwišzać na dwa sposoby: bez podzapytań i operatorów zbiorowych oraz wykorzystujšc operatory zbiorowe.

--bez podzapytan i operatorow zbiorowych
SELECT 
  B.nr_bandy "Numer bandy",
  B.nazwa "Nazwa",
  B.teren "Teren"
FROM Bandy B LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
WHERE K.nr_bandy IS NULL;

--z podzapytaniem i operatorem zbiorowym
SELECT 
  B.nr_bandy "Numer bandy",
  B.nazwa "Nazwa",
  B.teren "Teren"
FROM Bandy B
WHERE (
  SELECT COUNT(K.pseudo) FROM Kocury K
  WHERE K.nr_bandy = B.nr_bandy
  )=0; --licze koty, gdzie nr_bandy jest taki sam jak obecnej. I to musi byc = 0;
  
--Zad 25
--Znaleć koty, których przydział myszy jest nie mniejszy 
--od potrojonego najwyższego przydziału sporód przydziałów wszystkich MILU operujšcych w SADZIE. 
--Nie stosować funkcji MAX.
SELECT
  K1.imie "Imie",
  K1.funkcja "Funkcja",
  K1.przydzial_myszy "Przydzial myszy"
FROM Kocury K1 
WHERE K1.przydzial_myszy >= 3* (SELECT przydzial_myszy --rownie dobrze mogloby tu byc SELECT *
                                FROM      (
                                          SELECT przydzial_myszy
                                          FROM Kocury K2 JOIN Bandy B ON K2.nr_bandy = B.nr_bandy
                                          WHERE K2.funkcja = 'MILUSIA' AND B.teren IN ('SAD','CALOSC')
                                          )
                                WHERE ROWNUM = 1) --wybieram pierwszy wiersz z przydzialow MILUS z terenu SAD
ORDER BY przydzial_myszy;

--Zad26
--Znaleć funkcje (pomijajšc SZEFUNIA), 
--z którymi zwišzany jest najwyższy i najniższy redni całkowity przydział myszy.
--Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).
SELECT
  K1.funkcja "Funkcja",
  ROUND(AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0)))"Srednio najw. i najm. myszy"
FROM Kocury K1
WHERE K1.funkcja <> 'SZEFUNIO'
GROUP BY K1.funkcja
HAVING(ROUND(AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0))))
IN (
    (SELECT MAX(przydzial_sredni)
    FROM(
          SELECT ROUND(AVG(NVL(K2.przydzial_myszy,0)+NVL(K2.myszy_extra,0)) ) przydzial_sredni
          FROM Kocury K2
          WHERE K2.funkcja <> 'SZEFUNIO'
          GROUP BY K2.funkcja
        )
    ),
    ( 
    SELECT MIN(przydzial_sredni)
    FROM(
          SELECT ROUND(AVG(NVL(K3.przydzial_myszy,0)+NVL(K3.myszy_extra,0)) ) przydzial_sredni
          FROM Kocury K3
          WHERE K3.funkcja <> 'SZEFUNIO'
          GROUP BY K3.funkcja
        )
    )
);

--Zad27
--Znaleć koty zajmujšce pierwszych n miejsc pod względem całkowitej liczby spożywanych myszy 
--(koty o tym samym spożyciu zajmujš to samo miejsce!). 
--Zadanie rozwišzać na trzy sposoby:
--a.	wykorzystujšc podzapytanie skorelowane,
--b.	wykorzystujšc pseudokolumnę ROWNUM,
--c.	wykorzystujšc łšczenie relacji Kocury z relacjš Kocury.

--a
--???

--b
SELECT 
  pseudo "Pseudo",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "Zjada"
FROM Kocury K 
WHERE NVL(przydzial_myszy,0) + NVL(myszy_extra,0) IN --sprawdzam czy taka wartosc "zjada" znajduje sie w zbiorze pierwszych 6 wartosci "zjada"
    (SELECT *  --wybierz pierwsze 6 wartosci "zjada"
    FROM (
          SELECT DISTINCT NVL(przydzial_myszy,0) + NVL(myszy_extra,0) zjada --wybierz wszystkie "zjada" bez powtorzen
          FROM Kocury
          ORDER BY zjada DESC
          )
    WHERE ROWNUM <= 6
    );

--c
--????

--Zad28
--Okrelić lata, dla których liczba wstšpień do stada jest najbliższa (od góry i od dołu) 
--redniej liczbie wstšpień  dla wszystkich lat (rednia z wartoci okrelajšcych liczbę wstšpień w poszczególnych latach). 
--Nie stosować perspektywy.
SELECT 
      'Srednia' "Rok",
      ROUND(AVG(COUNT(pseudo)),7) "Liczba wstapien"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
UNION ALL
SELECT 
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "Rok",
  COUNT(pseudo) "Liczba wstapien"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING (
        COUNT(pseudo) = (SELECT * FROM  --wybierz jedna grupe, ktorej liczna wstapien byla najblizsza sredniej calkowitej
                              (
                              SELECT COUNT (pseudo) --wybierz grupy majace srednia liczbe wstapien mniejsza od sredniej calkowitej
                              FROM Kocury
                              GROUP BY EXTRACT(YEAR FROM w_stadku_od)
                              HAVING COUNT (pseudo) <= (SELECT ROUND(AVG(COUNT(pseudo)),7) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
                              ORDER BY COUNT (pseudo) DESC                                           
                              )
                        WHERE ROWNUM = 1)
        )
UNION ALL
SELECT 
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "Rok",
  COUNT(pseudo) "Liczba wstapien"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING (
        COUNT(pseudo) = (SELECT * FROM  --wybierz jedna grupe, ktorej liczna wstapien byla najblizsza sredniej calkowitej
                              (
                              SELECT COUNT (pseudo) --wybierz grupy majace srednia liczbe wstapien mniejsza od sredniej calkowitej
                              FROM Kocury
                              GROUP BY EXTRACT(YEAR FROM w_stadku_od)
                              HAVING COUNT (pseudo) >= (SELECT ROUND(AVG(COUNT(pseudo)),7) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
                              ORDER BY COUNT (pseudo) ASC                                           
                              )
                        WHERE ROWNUM = 1)
        );
        
--Zad29
--Dla kocurów (płeć męska), dla których całkowity przydział myszy nie przekracza redniej w ich bandzie wyznaczyć następujšce dane:
--imię, całkowite spożycie myszy, numer bandy, rednie całkowite spożycie w bandzie. 
--Nie stosować perspektywy. Zadanie rozwišzać na trzy sposoby:
--a.	ze złšczeniem ale bez podzapytań,
--b.	ze złšczenie i z jedynym podzapytaniem w klauzurze FROM,
--c.	bez złšczeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.

--a
SELECT
  K1.imie "Imie",
  MAX(NVL(K1.przydzial_myszy,0) + NVL(K1.myszy_extra,0)) "Zjada",
  MAX(K1.nr_bandy) "Nr bandy",
  AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0)) "Srednia bandy"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy
WHERE K1.plec='M'
GROUP BY K1.imie
HAVING MAX(NVL(K1.przydzial_myszy,0) + NVL(K1.myszy_extra,0)) <= AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0));

--b
SELECT
  K.imie "Imie",
  NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0) "Zjada",
  K.nr_bandy "Nr bandy",
  TO_CHAR(srednia,'99.99') "Srednia bandy"
FROM Kocury K JOIN(
                    SELECT --tabela ze srednia i numerem dla kazdej bandy
                      AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0)) srednia,
                      nr_bandy banda
                    FROM Kocury K2
                    GROUP BY K2.nr_bandy
                  )
              ON K.nr_bandy = banda
WHERE NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0) < srednia AND plec='M'
ORDER BY K.nr_bandy DESC;
  
--c
SELECT
  K.imie "Imie",
  NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0) "Zjada",
  K.nr_bandy "Nr bandy",
  (SELECT --srednia dla konkretnej bandy
      AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0))
    FROM Kocury K2
    GROUP BY K2.nr_bandy
    HAVING K2.nr_bandy = K.nr_bandy
  ) "Srednia bandy"
FROM Kocury K
WHERE NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0) < (SELECT --srednia dla konkretnej bandy
                                                          AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0))
                                                          FROM Kocury K2
                                                          GROUP BY K2.nr_bandy
                                                          HAVING K2.nr_bandy = K.nr_bandy
                                                        )
                                                        AND plec='M';






