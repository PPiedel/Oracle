--Zad1
--Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących na terenie POLE 
--posdających przydział myszy większy od 50.
--zględnić fakt, że są w stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.

SELECT pseudo "Poluje w polu", przydzial_myszy "Przydzial myszy", nazwa "Banda"
FROM  Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE przydzial_myszy > 50 AND teren = 'POLE' OR teren='CALOSC'
ORDER BY przydzial_myszy DESC;
      