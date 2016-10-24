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
  imie "Imie",
  w_stadku_od "Poluje od"
FROM Kocury K1, Kocury K2
WHERE K2.imie = 'Jacek' AND K1.w_stadku_od < K2.w_stadku_od ;
  

      