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


