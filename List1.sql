--Zad1,ver1.
--Znajdź imiona wrogów, którzy dopuścili się incydentów w 2009r.
SELECT imie_wroga "Wrog", opis_incydentu "Przewina"
FROM Wrogowie_Kocurow
WHERE EXTRACT(YEAR FROM data_incydentu)  = 2009; 

--ver2
SELECT imie_wroga "Wrog", opis_incydentu "Przewina"
FROM Wrogowie_Kocurow
WHERE data_incydentu LIKE '2009%'; 

--Zad2
--Znajdź wszystkie kotki (płeć żeńska), które przystąpiły do stada między 1 września 2005r. a 31 lipca 2007r.
SELECT imie "Imie",funkcja "Funkcja", w_stadku_od "Z nami od"
FROM Kocury
WHERE Plec LIKE 'D' AND w_stadku_od >= '2005-09-01' AND w_stadku_od <= '2007-07-31';

--Zad3
--Wyświetl imiona, gatunki i stopnie wrogości nieprzekupnych wrogów. 
--Wyniki mają być uporządkowane rosnąco według stopnia wrogości.
SELECT imie_wroga "Wrog", gatunek "Gatunek", stopien_wrogosci "Stopien wrogosci"
FROM Wrogowie
WHERE LAPOWKA IS NULL
ORDER BY stopien_wrogosci;

--Zad4
--Wyświetlić dane o kotach płci męskiej zebrane w jednej kolumnie postaci:
--JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
--Wyniki należy uporządkować malejąco wg daty przystąpienia do stada. 
--W przypadku tej samej daty przystąpienia wyniki uporządkować alfabetycznie wg  pseudonimów.
SELECT imie||' zwany '||pseudo||
            ' (fun.'|| funkcja ||')'||' lowi myszki w bandzie '||nr_bandy|| ' od '||w_stadku_od 
            "Wszystko o kocurach"
FROM Kocury
ORDER BY w_stadku_od DESC, pseudo;

--Zad5
--Znaleźć pierwsze wystąpienie litery A i pierwsze wystąpienie litery L w każdym pseudonimie 
--a następnie zamienić znalezione litery na odpowiednio # i %. Wykorzystać funkcje działające na łańcuchach. 
--Brać pod uwagę tylko te imiona, w których występują obie litery.

SELECT pseudo "Pseudo", REGEXP_REPLACE(
                                        REGEXP_REPLACE(pseudo, 'A', '#', 1, 1),
                                        'L',
                                        '%',
                                        1,
                                        1
                                      ) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%L%A%' OR pseudo LIKE '%A%L%';

--Zad6
--Wyświetlić imiona kotów z co najmniej siedmioletnim stażem (które dodatkowo przystępowały do stada od 1 marca do 30 września), 
--daty ich przystąpienia do stada, początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku członkostwa,  jest o 10% wyższy od początkowego) , 
--datę wspomnianej podwyżki o 10% oraz aktualnym przydział myszy. 
--Wykorzystać odpowiednie funkcje działające na datach. W poniższym rozwiązaniu datą bieżącą jest 14.06.2016

--SOMETHING WRONG ???
SELECT imie,
      w_stadku_od "W stadku", 
      ROUND(NVL(przydzial_myszy, 0)*0.9) "Zjadal", 
      ADD_MONTHS(w_stadku_od,6) "Podwyzka",
      NVL(przydzial_myszy, 0) "Zjada"
FROM Kocury
WHERE MONTHS_BETWEEN('2016-06-14',w_stadku_od) >= 72 
      AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9 
      AND EXTRACT(DAY FROM w_stadku_od)>=1
      AND EXTRACT(DAY FROM w_stadku_od)<=30;
      
      
--Zad7
--Wyświetlić imiona, kwartalne przydziały myszy i kwartalne przydziały dodatkowe dla wszystkich kotów, 
--u których przydział myszy jest większy od dwukrotnego przydziału dodatkowego ale nie mniejszy od 55.

SELECT imie, NVL(przydzial_myszy,0)*3 "Myszy kwartalnie", NVL(myszy_extra,0)*3 "Kwartalne dodatki"
FROM Kocury
WHERE NVL(przydzial_myszy,0)>2*NVL(myszy_extra,0) AND NVL(przydzial_myszy,0)>=55;

--Zad8
--Wyświetlić dla każdego kota (imię) następujące informacje o całkowitym rocznym spożyciu myszy: 
--wartość całkowitego spożycia jeśli przekracza 660, 
--’Limit’ jeśli jest równe 660, ’Ponizej 660’ jeśli jest mniejsze od 660. 
--Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).

SELECT imie,
      CASE
        WHEN (NVL(przydzial_myszy,0)+nvl(myszy_extra,0))*12 > 660 THEN TO_CHAR((NVL(przydzial_myszy,0)+nvl(myszy_extra,0))*12)
        WHEN (NVL(przydzial_myszy,0)+nvl(myszy_extra,0))*12 = 660 THEN 'Limit'
        ELSE 'Ponizej 660'
      END
      "Zjada rocznie"
FROM Kocury
ORDER BY imie;

--Zad9
--Po kilkumiesięcznym, spowodowanym kryzysem, zamrożeniu wydawania myszy Tygrys z dniem bieżącym wznowił wypłaty zgodnie z zasadą,
--że koty, które przystąpiły do stada w pierwszej połowie miesiąca (łącznie z 15-m) 
--otrzymują pierwszy po przerwie przydział myszy w ostatnią środę bieżącego miesiąca, natomiast koty, które przystąpiły do stada po 15-ym, 
--pierwszy po przerwie przydział myszy otrzymują w ostatnią środę następnego miesiąca. 
--W kolejnych miesiącach myszy wydawane są wszystkim kotom w ostatnią środę każdego miesiąca. 

--Wyświetlić dla każdego kota jego pseudonim, datę przystąpienia do stada oraz datę pierwszego po przerwie przydziału myszy, 
--przy założeniu, że  datą bieżącą jest 24 i 27 październik 2016.
SELECT
  pseudo,
  w_stadku_od "W STADKU",
  CASE EXTRACT(MONTH FROM NEXT_DAY('2015-11-24', 'ŚRODA'))
    WHEN EXTRACT(MONTH FROM TO_DATE ('2015-11-24')) THEN
      CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN
          NEXT_DAY(LAST_DAY('2015-11-24')-7, 'ŚRODA')
        ELSE
          NEXT_DAY(LAST_DAY(ADD_MONTHS('2015-11-24', 1))-7, 'ŚRODA')
      END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2015-11-24', 1))-7, 'ŚRODA')
  END "Wyplata"
FROM Kocury;

--Zad10
--Atrybut pseudo w tabeli Kocury jest kluczem głównym tej tabeli. 
--Sprawdzić, czy rzeczywiście wszystkie pseudonimy są wzajemnie różne. 
--Zrobić to samo dla atrybutu szef.

SELECT 
      CASE COUNT (pseudo)
        WHEN 1 THEN pseudo || '- Unikalny'
        ELSE pseudo || ' - nieunikalny'
      END
      "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo ASC;


SELECT 
      CASE COUNT (szef)
        WHEN 1 THEN szef || '- Unikalny'
        ELSE szef || ' - nieunikalny'
      END
      "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef ASC;








