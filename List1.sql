--Zad1
--Znajd� imiona wrog�w, kt�rzy dopu�cili si� incydent�w w 2009r.
--ver1
SELECT imie_wroga "Wrog", opis_incydentu "Przewina"
FROM Wrogowie_Kocurow
WHERE EXTRACT(YEAR FROM data_incydentu)  = 2009; 

--Zad2
--Znajd� wszystkie kotki (p�e� �e�ska), kt�re przyst�pi�y do stada mi�dzy 1 wrze�nia 2005r. a 31 lipca 2007r.
SELECT imie "Imie",funkcja "Funkcja", w_stadku_od "Z nami od"
FROM Kocury
WHERE Plec LIKE 'D' AND w_stadku_od >= '2005-09-01' AND w_stadku_od <= '2007-07-31';


--Zad3
--Wy�wietl imiona, gatunki i stopnie wrogo�ci nieprzekupnych wrog�w. 
--Wyniki maj� by� uporz�dkowane rosn�co wed�ug stopnia wrogo�ci.
SELECT imie_wroga "Wrog", gatunek "Gatunek", stopien_wrogosci "Stopien wrogosci"
FROM Wrogowie
WHERE LAPOWKA IS NULL
ORDER BY stopien_wrogosci;


--Zad4
--Wy�wietli� dane o kotach p�ci m�skiej zebrane w jednej kolumnie postaci:
--JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
--Wyniki nale�y uporz�dkowa� malej�co wg daty przyst�pienia do stada. 
--W przypadku tej samej daty przyst�pienia wyniki uporz�dkowa� alfabetycznie wg  pseudonim�w.
SELECT imie||' zwany '||pseudo||
            ' (fun.'|| funkcja ||')'||' lowi myszki w bandzie '||nr_bandy|| ' od '||w_stadku_od 
            "Wszystko o kocurach"
FROM Kocury
ORDER BY w_stadku_od DESC, pseudo;


--Zad5
--Znale�� pierwsze wyst�pienie litery A i pierwsze wyst�pienie litery L w ka�dym pseudonimie 
--a nast�pnie zamieni� znalezione litery na odpowiednio # i %. Wykorzysta� funkcje dzia�aj�ce na �a�cuchach. 
--Bra� pod uwag� tylko te imiona, w kt�rych wyst�puj� obie litery.
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
--Wy�wietli� imiona kot�w z co najmniej siedmioletnim sta�em (kt�re dodatkowo przyst�powa�y do stada od 1 marca do 30 wrze�nia), 
--daty ich przyst�pienia do stada, pocz�tkowy przydzia� myszy (obecny przydzia�, ze wzgl�du na podwy�k� po p� roku cz�onkostwa,  jest o 10% wy�szy od pocz�tkowego) , 
--dat� wspomnianej podwy�ki o 10% oraz aktualnym przydzia� myszy. 
--Wykorzysta� odpowiednie funkcje dzia�aj�ce na datach. W poni�szym rozwi�zaniu dat� bie��c� jest 14.06.2016
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
--Wy�wietli� imiona, kwartalne przydzia�y myszy i kwartalne przydzia�y dodatkowe dla wszystkich kot�w, 
--u kt�rych przydzia� myszy jest wi�kszy od dwukrotnego przydzia�u dodatkowego ale nie mniejszy od 55.
SELECT imie, NVL(przydzial_myszy,0)*3 "Myszy kwartalnie", NVL(myszy_extra,0)*3 "Kwartalne dodatki"
FROM Kocury
WHERE NVL(przydzial_myszy,0)>2*NVL(myszy_extra,0) AND NVL(przydzial_myszy,0)>=55;


--Zad8
--Wy�wietli� dla ka�dego kota (imi�) nast�puj�ce informacje o ca�kowitym rocznym spo�yciu myszy: 
--warto�� ca�kowitego spo�ycia je�li przekracza 660, 
--�Limit� je�li jest r�wne 660, �Ponizej 660� je�li jest mniejsze od 660. 
--Nie u�ywa� operator�w zbiorowych (UNION, INTERSECT, MINUS).
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
--Po kilkumiesi�cznym, spowodowanym kryzysem, zamro�eniu wydawania myszy Tygrys z dniem bie��cym wznowi� wyp�aty zgodnie z zasad�,
--�e koty, kt�re przyst�pi�y do stada w pierwszej po�owie miesi�ca (��cznie z 15-m) 
--otrzymuj� pierwszy po przerwie przydzia� myszy w ostatni� �rod� bie��cego miesi�ca, natomiast koty, kt�re przyst�pi�y do stada po 15-ym, 
--pierwszy po przerwie przydzia� myszy otrzymuj� w ostatni� �rod� nast�pnego miesi�ca. 
--W kolejnych miesi�cach myszy wydawane s� wszystkim kotom w ostatni� �rod� ka�dego miesi�ca. 
--Wy�wietli� dla ka�dego kota jego pseudonim, dat� przyst�pienia do stada oraz dat� pierwszego po przerwie przydzia�u myszy, 
--przy za�o�eniu, �e  dat� bie��c� jest 24 i 27 pa�dziernik 2016.
SELECT
  pseudo,
  w_stadku_od "W STADKU",
  CASE EXTRACT(MONTH FROM NEXT_DAY('2016-10-24', 3)) --jesli miesiac nastepnej srody
    WHEN EXTRACT(MONTH FROM DATE '2016-10-24') THEN --jest taki sam jak obecny miesiac
      CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN
          NEXT_DAY(LAST_DAY('2016-10-24')-7, 3) --ostatnia sroda w biezacym miesiacu
        ELSE
          NEXT_DAY(LAST_DAY(ADD_MONTHS('2016-10-24', 1))-7, 3) --ostatnia sroda w nastepnym miesiacu
      END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2016-10-24', 1))-7, 3) --jesli sie nie zalapal to w ostatnia srode kazdego miesiaca
  END "Wyplata"
FROM Kocury;

SELECT
  pseudo,
  w_stadku_od "W STADKU",
  CASE EXTRACT(MONTH FROM NEXT_DAY('2016-10-27', 3))
    WHEN EXTRACT(MONTH FROM TO_DATE ('2016-10-27')) THEN
      CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN
          NEXT_DAY(LAST_DAY('2016-10-27')-7, 3)
        ELSE
          NEXT_DAY(LAST_DAY(ADD_MONTHS('2016-10-27', 1))-7, 3)
      END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2016-10-27', 1))-7, 3)
  END "Wyplata"
FROM Kocury;


--Zad10
--Atrybut pseudo w tabeli Kocury jest kluczem g��wnym tej tabeli. 
--Sprawdzi�, czy rzeczywi�cie wszystkie pseudonimy s� wzajemnie r�ne. 
--Zrobi� to samo dla atrybutu szef.

--pseudo nie moze by nullem wiec nie bedzie grupy z nullem
--na pseudo nalozony jest indeks a to jest klucz i to bedzie najszybsze
SELECT 
      CASE COUNT (pseudo)
        WHEN 1 THEN pseudo || '- Unikalny'
        ELSE pseudo || ' - nieunikalny'
      END
      "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo ASC;


--rownie dobrze mozna wstawic COUNT(pseudo - ktory jest kluczem ? )
SELECT 
      CASE COUNT (*)
        WHEN 1 THEN szef || '- Unikalny'
        ELSE szef || ' - nieunikalny'
      END
      "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef ASC;


--Zad11
--Znale�� pseudonimy kot�w posiadaj�cych co najmniej dw�ch wrog�w.
SELECT pseudo "Pseudonim", COUNT(imie_wroga) "Liczba wrogow"
FROM Wrogowie_Kocurow 
GROUP BY pseudo
HAVING COUNT(imie_wroga) >=2;


--Zad12
--Znale�� maksymalny ca�kowity przydzia� myszy dla wszystkich grup funkcyjnych (z pomini�ciem SZEFUNIA i kot�w p�ci m�skiej) 
--o �rednim ca�kowitym przydziale (z uwzgl�dnieniem dodatkowych przydzia��w � myszy_extra) wi�kszym  od 50. 
SELECT  
  'Liczba kotow= ' "  ",
  COUNT(*) " ",
  'lowi jako' "   ",
  funkcja,
  'i zjada max.' "      ",
  TO_CHAR(MAX(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), '90.00') "       ",
  'myszy miesiecznie' "         "
FROM Kocury
WHERE funkcja <> 'SZEFUNIO' AND plec <> 'M'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) >50;


--Zad13
--Wy�wietli� minimalny przydzia� myszy w ka�dej bandzie z podzia�em na p�cie.
SELECT
  nr_bandy "Nr bandy",
  plec "Plec",
  MIN(NVL(przydzial_myszy,0)) "Minimalny przydzial"
FROM Kocury
--wszystkie te, ktore maja ta sama plec i nr_bandy do jednej grupy
GROUP BY nr_bandy,plec;


--Zad14
--Wy�wietli� informacj� o kocurach (p�e� m�ska) posiadaj�cych w hierarchii prze�o�onych szefa pe�ni�cego funkcj� BANDZIOR 
--(wy�wietli� tak�e dane tego prze�o�onego). Dane kot�w podleg�ych konkretnemu szefowi maj� by� wy�wietlone zgodnie z ich miejscem w hierarchii podleg�o�ci.
SELECT
  LEVEL "Poziom",
  pseudo "Pseudonim",
  funkcja "Funkcja",
  nr_bandy "Nr bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef --stworz kolejny wiersz z takiego kocura, ktorego pole szef jest taki jak pseudo biezacego wiersza
START WITH funkcja = 'BANDZIOR';


--Zad15
--Przedstawić informację o podległości kotów posiadających dodatkowy przydział myszy 
--tak aby imię kota stojącego najwyżej w hierarchii było wyświetlone z najmniejszym wcięciem 
--a pozostałe imiona z wcięciem odpowiednim do miejsca w hierarchii.
SELECT
  rpad(lpad((LEVEL-1), (LEVEL-1)*4+1, '===>'), 16)||
  lpad(' ',4*(level-1)) || imie "Hierarchia", --domyslnie spacja
  NVL(szef, 'Sam sobie panem') "Pseudo szefa",
  funkcja "Funkcja"
FROM Kocury
WHERE myszy_extra > 0
CONNECT BY PRIOR pseudo = szef --stworz kolejny wiersz z takiego kocura, ktorego pole szef jest taki jak pseudo biezacego wiersza
START WITH szef IS NULL;


--zad16
--Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych przełożonych do głównego szefa) 
--kotów płci męskiej o stażu dłuższym niż siedem lat (w poniższym rozwiązaniu datą bieżącą jest 14.06.2016)
--nie posiadających dodatkowego przydziału myszy.
SELECT
  lpad(' ',3*(LEVEL-1)) ||
  pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH
  plec = 'M' AND MONTHS_BETWEEN(SYSDATE,w_stadku_od) >72 AND myszy_extra IS NULL ;



