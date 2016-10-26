--Zad17
--Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących na terenie POLE 
--posdających przydział myszy większy od 50.
--zględnić fakt, że są w stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.

SELECT pseudo "Poluje w polu", przydzial_myszy "Przydzial myszy", nazwa "Banda"
FROM  Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE przydzial_myszy > 50 AND teren = 'POLE' OR teren='CALOSC'
ORDER BY przydzial_myszy DESC;

--Zad18
--Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada kotów, 
--które przystąpiły do stada przed kotem o imieniu ’JACEK’. Wyniki uporządkować malejąco wg daty przystąpienia do stadka.
SELECT
  K1.imie "Imie",
  K1.w_stadku_od "Poluje od"
FROM
  Kocury K1, Kocury K2
WHERE K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;
  
--Zad19
--Dla kotów pełnišcych funkcję KOT i MILUSIA wywietlić w kolejnoci hierarchii imiona wszystkich ich szefów. Zadanie rozwišzać na trzy sposoby:
--a.	z wykorzystaniem tylko złšczeń,
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
--Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po 01.01.2007. 
--Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów wraz ze stopniem wrogości oraz datę incydentu.
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
--Określić ile kotów w każdej z band posiada wrogów
SELECT
  B.nazwa "Nazwa bandy",
  NVL(COUNT(DISTINCT K.pseudo),'0') "Koty z wrogrami"    --DISTINCT bo niektore koty maja kilku wrogow
FROM
  Kocury K RIGHT JOIN Bandy B ON K.nr_bandy = B.nr_bandy --moglyby byc bandy bez wrogow
  JOIN Wrogowie_Kocurow WK ON WK.pseudo = K.pseudo
GROUP BY B.nazwa;

--Zad22





      