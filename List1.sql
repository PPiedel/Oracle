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



