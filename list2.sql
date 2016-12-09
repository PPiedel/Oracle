--Zad17
--Wy�wietli� pseudonimy, przydzia�y myszy oraz nazwy band dla kot�w operuj�cych na terenie POLE 
--posdaj�cych przydzia� myszy wi�kszy od 50.
--Uwzgl�dni� fakt, �e s� w stadzie koty posiadaj�ce prawo do polowa� na ca�ym �obs�ugiwanym� przez stado terenie.
-- Nie stosowa� podzapyta�.
SELECT 
  pseudo "Poluje w polu", 
  przydzial_myszy "Przydzial myszy", 
  nazwa "Banda"
FROM  Kocury JOIN Bandy USING(nr_bandy) -- NATURAL JOIN i USING implikuje to, �e nie mozemy poprzedzic aliasem kolumny nr_bandy gdyz jedno wystapienie tej kolumny jest eliminowane
WHERE przydzial_myszy > 50 AND (teren = 'POLE' OR teren='CALOSC') --prawo do polowania na calym terenie
ORDER BY przydzial_myszy DESC;

--Zad18
--Wy�wietli� bez stosowania podzapytania imiona i daty przyst�pienia do stada kot�w, 
--kt�re przyst�pi�y do stada przed kotem o imieniu �JACEK�. Wyniki uporz�dkowa� malej�co wg daty przyst�pienia do stadka.
SELECT
  K1.imie "Imie",
  K1.w_stadku_od "Poluje od"
FROM
  --Kocury K1, Kocury K2 --iloczyn kartezjanski
  Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy AND K1.w_stadku_od < K2.w_stadku_od
WHERE K2.imie = 'JACEK'
ORDER BY K1.w_stadku_od DESC;
  
--Zad19
--Dla kot�w pe�ni�cych funkcj� KOT i MILUSIA wy?wietli� w kolejno?ci hierarchii imiona wszystkich ich szef�w. 
--Zadanie rozwi�za� na trzy sposoby:
--a.	z wykorzystaniem tylko z��cze�,
--b.	z wykorzystaniem drzewa i operatora CONNECT_BY_ROOT,
--c.	z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH.

--a
SELECT
  K1.imie "Imie",
  K1.funkcja "Funkcja",
  NVL(K3.imie,' ') "Szef 2",
  NVL(K4.imie,' ') "Szef 3"
FROM 
  Kocury K1 LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo --zlaczenia i po kolei wyswietlamy dane 
  LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo     --bierzemy rowniez te kocury, ktore nie maja szefa  
  LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo    --RIGHT JOIN nie zadziala, bo bysmy brali wszystkie z prawej, ale zapomnieli o wczesniejszych
WHERE K1.funkcja IN ('KOT','MILUSIA');

--b
SELECT
  K1.imie "Imie",
  K1.funkcja "Funkcja",
  NVL(K2.imie,' ') "Szef 1",
  NVL(K3.imie,' ') "Szef 2",
  NVL(K4.imie,' ') "Szef 3"
FROM 
  Kocury K1 LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
  LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
  LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo 
WHERE CONNECT_BY_ROOT K1.funkcja IN ('KOT', 'MILUSIA') AND LEVEL =1
CONNECT BY PRIOR K1.szef=K1.pseudo;  --stworz kolejny wiersz z takiego kocura, ktorego pole pseudo jest takie jak szef biezacego wiersza
                                    --dokladamy szefa dla kocura, idziemy do gory

--c
SELECT
  CONNECT_BY_ROOT(imie )"Imie",
  CONNECT_BY_ROOT(funkcja) "Funkcja",
  SUBSTR(SYS_CONNECT_BY_PATH(RPAD(imie, 10), '|'),12) "Imiona kolejnych szef�w"
FROM 
  Kocury
WHERE CONNECT_BY_ISLEAF = 1
START WITH funkcja IN ('KOT', 'MILUSIA') -- zaczynam tam, gdzie funkcja to MILUSIA lub KOT
CONNECT BY PRIOR szef = pseudo;  --stworz kolejny wiersz z takiego kocura, ktorego pole pseudo jest takie jak szef biezacego wiersza
                                 --dokladamy szefa dla kocura, idziemy do gory

--Zad20
--Wy�wietli� imiona wszystkich kotek, kt�re uczestniczy�y w incydentach po 01.01.2007. 
--Dodatkowo wy�wietli� nazwy band do kt�rych nale�� kotki, imiona ich wrog�w wraz ze stopniem wrogo�ci oraz dat� incydentu.
SELECT 
  K1.imie "Imie kotki",
  B.nazwa "Nazwa bandy",
  WK.imie_wroga "Imie wroga",
  W.stopien_wrogosci "Ocena wroga",
  WK.data_incydentu "Data inc."
FROM 
  Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
  JOIN Wrogowie_Kocurow WK ON K1.pseudo = WK.pseudo     --jesli bym uzyl USING albo NATURAL JOIN to nie moglbym w selecie wyswietlic z ALIASEM
  JOIN Wrogowie W ON WK.imie_wroga = W.imie_wroga
WHERE K1.Plec='D'AND WK.data_incydentu > '2007-01-01'
ORDER BY K1.imie;


--Zad21
--Okre�li� ile kot�w w ka�dej z band posiada wrog�w
SELECT
  B.nazwa "Nazwa bandy",
  NVL(COUNT(DISTINCT K.pseudo),'0') "Koty z wrogami"    --DISTINCT bo niektore koty maja kilku wrogow
FROM
  Bandy B LEFT JOIN Kocury K   ON K.nr_bandy = B.nr_bandy --na upartego LEFT JOIN, ale jak banda nie ma kocurow, to wrogow tez nie ma
  JOIN Wrogowie_Kocurow WK ON WK.pseudo = K.pseudo
GROUP BY B.nazwa;   --grupujemy po nazwie grupy

--Zad22
--Znale�� koty (wraz z pe�nion� funkcj�), kt�re posiadaj� wi�cej ni� jednego wroga.
--laczymy kocury i ich wrogow, grupujemy po pseudonimie i wyswietlamy te grupy, ktore maja liczbe >1
SELECT 
  MAX(K.funkcja) "Funkcja", --max/min
  K.pseudo "Pseudonim kota",
  COUNT(WK.pseudo) "Liczba wrogow"
FROM Kocury K JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo --laczymy kocury i ich wrogow ->dostajemy kocury, ktore maja wrogow
GROUP BY K.pseudo --grupujemy po pseudninimie
HAVING COUNT(K.pseudo) > 1; --grupy, ktore maja wiecej niz jednego wrog

--Zad23
--Wy�wietli� imiona kot�w, kt�re dostaj� �mysz�� premi� wraz z ich ca�kowitym rocznym spo�yciem myszy.
--Dodatkowo je�li ich roczna dawka myszy przekracza 864 wy�wietli� tekst �powyzej 864�, je�li jest r�wna 864 tekst �864�, 
--je�li jest mniejsza od 864 tekst �poni�ej 864�. Wyniki uporz�dkowa� malej�co wg rocznej dawki myszy. 
--Do rozwi�zania wykorzysta� operator zbiorowy UNION.


--zbior dziele na trzy grupy, zgodnie z zadaniem i lacze pionowo je ze soba
-- ORDER_BY moze wystapic tylko na koncu takiego polecenia raz
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  'powyzej 864' "Dawka"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  > 864 --myszy z premia i odpowiednim przydzialem calkowitym
UNION   --suma bez powt�rze�
        --aby doszlo do polaczenia relacji musze miec ten sam schemat    
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  'ponizej 864' "Dawka"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  < 864 
UNION   --suma bez powt�rze�
        --aby doszlo do polaczenia relacji musze miec ten sam schemat  
SELECT
  imie "Imie",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "Dawka Roczna",
  '864' "Dawka"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0 AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12  = 864
ORDER BY "Dawka Roczna" DESC; --ORDER_BY moze wystapic tylko na koncu takiego polecenia, jednokrotnie


--Zad24
--Znale�� bandy, kt�re nie posiadaj� cz�onk�w. Wy�wietli� ich numery, nazwy i tereny operowania. 
--Zadanie rozwi�za� na dwa sposoby: bez podzapyta� i operator�w zbiorowych oraz wykorzystuj�c operatory zbiorowe.

--a) bez podzapytan i operatorow zbiorowych
-- wszystkie bandy lacze z kocurami
-- nie kazda banda ma czlonkow = kocur bedzie mial null
SELECT 
  K.pseudo, 
  K.myszy_extra,
  B.nr_bandy "Numer bandy",
  B.nazwa "Nazwa",
  B.teren "Teren"
FROM Kocury K RIGHT JOIN Bandy B ON B.nr_bandy = K.nr_bandy  --nie kazda banda ma czlonkow = kocur bedzie mial null
                                                            --wszystkie bandy lacze z kocurami
                                                            -- Bandy B LEFT JOIN Kocury K tez poprawne
WHERE K.pseudo IS NULL; --wybieram te krotki, gdzie kocur ma nulla w pseudo
                            --to musi byc klucz lub atrybut obowiazkowy
                            -- mogloby tez byc K.pseudo IS NULL
    
    
--b) z podzapytaniem i operatorem zbiorowym
SELECT 
  B.nr_bandy "Numer bandy",
  B.nazwa "Nazwa",
  B.teren "Teren"
FROM Bandy B
                  --ANY(/ALL) mozna stosowac w WHERE w przypadku, kiedy podzapytanie zwraca jedna kolumne
WHERE 0 = ANY (  --troche na sile, ale podzapytanie zwraca nie tylko jedna kolumne a nawet dokladnie jeden wiersz nawet
          SELECT COUNT(K.pseudo) FROM Kocury K
          WHERE K.nr_bandy = B.nr_bandy
          ); --licze koty, gdzie nr_bandy jest taki sam jak obecnej. I to musi byc = 0
              -- podzapytanie skorelowane, dla kazdego kota obliczane na podstawie jego bandy
  
--Zad 25
--Znale�� koty, kt�rych przydzia� myszy jest nie mniejszy (czyli >=)
--od potrojonego najwy�szego przydzia�u spo�r�d przydzia��w wszystkich MILU� operuj�cych w SADZIE. 
--Nie stosowa� funkcji MAX.
SELECT
  K1.imie "Imie",
  K1.funkcja "Funkcja",
  K1.przydzial_myszy "Przydzial myszy"
FROM Kocury K1 
WHERE K1.przydzial_myszy >= 3* (SELECT * --rownie dobrze mogloby tu byc SELECT przydzial_myszy
                                FROM      (--wybieram przydzialy_myszy dla milus operujacych w sadzie
                                          SELECT przydzial_myszy 
                                          FROM Kocury K2 JOIN Bandy B ON K2.nr_bandy = B.nr_bandy
                                          WHERE K2.funkcja = 'MILUSIA' AND B.teren IN ('SAD','CALOSC') --calosc operuje tez w sadzie
                                          )
                                WHERE ROWNUM = 1) --wybieram pierwszy wiersz z przydzialow MILUS z terenu SAD
                                      --ROWNUM jest przypisywany do wierszy tuz po FROM/WHERE
ORDER BY przydzial_myszy;             --ROWNUM to pseudokolumna, FROM/WHERE->ROWNUM->SELECT/GROUP BY/HAVONG/ORDER
                                      --ROWNUM jest zwiekszany po kazdym wierszu, ktory zdal wiec  WHERE ROWNUM = 5 or WHERE ROWNUM > 5  nie ma sensu

--Zad26
--Znale�� funkcje (pomijaj�c SZEFUNIA), 
--z kt�rymi zwi�zany jest najwy�szy i najni�szy �redni ca�kowity przydzia� myszy.
--Nie u�ywa� operator�w zbiorowych (UNION, INTERSECT, MINUS).

--zastanawialem sie nad tym "najwy�szy i najni�szy"

WITH Przydzial_Sredni AS (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) ) przydzial_sredni
                          FROM Kocury
                          WHERE funkcja <> 'SZEFUNIO'
                          GROUP BY funkcja
                          )--wyznaczam sredni calkowity przydzial myszy 
SELECT
  K1.funkcja "Funkcja",
  ROUND(AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0)))"Srednio najw. i najm. myszy"
FROM Kocury K1
WHERE K1.funkcja <> 'SZEFUNIO'
GROUP BY K1.funkcja
HAVING(ROUND(AVG(NVL(K1.przydzial_myszy,0)+NVL(K1.myszy_extra,0))))
IN (
    (SELECT MAX(przydzial_sredni)
    FROM Przydzial_Sredni
    ),
    ( 
    SELECT MIN(przydzial_sredni)
    FROM Przydzial_Sredni
    )
);


--Zad27
--Znale�� koty zajmuj�ce pierwszych n miejsc pod wzgl�dem ca�kowitej liczby spo�ywanych myszy 
--(koty o tym samym spo�yciu zajmuj� to samo miejsce!). 
--Zadanie rozwi�za� na trzy sposoby:
--a.	wykorzystuj�c podzapytanie skorelowane,
--b.	wykorzystuj�c pseudokolumn� ROWNUM,
--c.	wykorzystuj�c ��czenie relacji Kocury z relacj� Kocury.

--a
SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury K1
WHERE
  6 > ( --musi byc mniejsza od liczby n
    SELECT COUNT(*) --liczba krotek, gdzie inne kocury zjadaja wiecej niz dany kocur
    FROM Kocury K2
    WHERE NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0) > NVL(K1.przydzial_myszy,0) + NVL(K1.myszy_extra,0) --skorelowanie : K2,K1
  )--za kazdym razem liczba kocurow z przydzialem wiekszym od danego kocura musi byc <= 6
ORDER BY "ZJADA" DESC;


--b
SELECT 
  pseudo "Pseudo",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "Zjada"
FROM Kocury K 
WHERE NVL(przydzial_myszy,0) + NVL(myszy_extra,0) IN --sprawdzam czy taka wartosc "zjada" znajduje sie w zbiorze pierwszych 6 wartosci "zjada"
    (SELECT *  --wybierz wszystko z pierwszych 6 wartosci przydzialow "zjada"
      FROM (
          SELECT DISTINCT NVL(przydzial_myszy,0) + NVL(myszy_extra,0) zjada --wybierz wszystkie przydzialy ("zjada") bez powtorzen
          FROM Kocury
          ORDER BY zjada DESC
          )
      WHERE ROWNUM <= 6
        --ROWNUM jest przypisywany do wierszy tuz po FROM/WHERE, przed ORDER BY
        --ROWNUM to pseudokolumna, FROM/WHERE->ROWNUM->SELECT/GROUP BY/HAVONG/ORDER
        --ROWNUM jest zwiekszany po kazdym wierszu, ktory zdal wiec  WHERE ROWNUM = 5 or WHERE ROWNUM > 5  nie ma sensu
    );

--c

SELECT 
  K1.pseudo, 
  NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) "Zjada"
FROM Kocury K1 JOIN Kocury K2 ON NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)<=NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)
      --polacz te krotki, gdzie przydzial drugiego kota jest wiekszy badz rowny od naszego
GROUP BY K1.pseudo, NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)
HAVING COUNT( DISTINCT NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) <= 6
ORDER BY "Zjada" DESC;

--Zad28
--Okre�li� lata, dla kt�rych liczba wst�pie� do stada jest najbli�sza (od g�ry i od do�u) 
--�redniej liczbie wst�pie�  dla wszystkich lat (�rednia z warto�ci okre�laj�cych liczb� wst�pie� w poszczeg�lnych latach). 
--Nie stosowa� perspektywy.
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
--Dla kocur�w (p�e� m�ska), dla kt�rych ca�kowity przydzia� myszy nie przekracza �redniej w ich bandzie wyznaczy� nast�puj�ce dane:
--imi�, ca�kowite spo�ycie myszy, numer bandy, �rednie ca�kowite spo�ycie w bandzie. 
--Nie stosowa� perspektywy. Zadanie rozwi�za� na trzy sposoby:
--a.	ze z��czeniem ale bez podzapyta�,
--b.	ze z��czenie i z jedynym podzapytaniem w klauzurze FROM,
--c.	bez z��cze� i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.

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

--Zad30
--Wygenerowa� list� kot�w z zaznaczonymi kotami o najwy�szym i o najni�szym sta�u w swoich bandach. Zastosowa� operatory zbiorowe.
SELECT 
  K.imie "Imie",
  K.w_stadku_od || '<---' "Wstapil do stadka",
  "NAJMLODSZY STAZEM W BANDZIE " || K.nr_bandy
FROM
Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE K.w_stadku_od = 
      (
      SELECT MAX(K1.w_stadku_od)
      FROM Kocury K1
      GROUP BY K1.w_stadku_od
      HAVING K1.nr_bandy = B.nr_bandy
      )
UNION
SELECT 
  K.imie "Imie",
  K.w_stadku_od || '<---' "Wstapil do stadka",
  "NAJSTARSZY STAZEM W BANDZIE " || K.nr_bandy
FROM
Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE K.w_stadku_od = 
      (
      SELECT MIN(K1.w_stadku_od)
      FROM Kocury K1
      GROUP BY K1.w_stadku_od
      HAVING K1.nr_bandy = B.nr_bandy
      )
UNION
SELECT 
  K.imie "Imie",
  K.w_stadku_od || '<---' "Wstapil do stadka",
  " "
FROM
Kocury K
WHERE K.w_stadku_od NOT IN 
      (
      ( SELECT MAX(K1.w_stadku_od)
        FROM Kocury K1
        GROUP BY K1.w_stadku_od
        HAVING K1.nr_bandy = B.nr_bandy),
      ( SELECT MIN(K1.w_stadku_od)
        FROM Kocury K1
        GROUP BY K1.w_stadku_od
        HAVING K1.nr_bandy = B.nr_bandy)
      );

--Zad31
--Zdefiniowa� perspektyw� wybieraj�c� nast�puj�ce 
--dane: nazw� bandy, �redni, maksymalny i minimalny przydzia� myszy w bandzie, ca�kowit� liczb� kot�w w bandzie 
--oraz liczb� kot�w pobieraj�cych w bandzie przydzia�y dodatkowe. 
--Pos�uguj�c si� zdefiniowan� perspektyw� wybra� nast�puj�ce dane o kocie, 
--kt�rego pseudonim podawany jest interaktywnie z klawiatury:
--pseudonim , imi�, funkcja, przydzia� myszy, minimalny i maksymalny przydzia� myszy w jego bandzie oraz dat� wst�pienia do stada.

CREATE OR REPLACE VIEW  p1 (NAZWA_BANDY, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD)
AS
SELECT 
  B.nazwa,
  AVG(NVL(K.przydzial_myszy,0)),
  MAX(NVL(K.przydzial_myszy,0)),
  MIN(NVL(K.przydzial_myszy,0)),
  COUNT(K.pseudo),
  COUNT(myszy_extra)
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY B.nazwa;

SELECT
  K.pseudo "PSEUDONIM",
  K.imie "IMIE",
  K.funkcja "FUNKCJA",
  K.przydzial_myszy "ZJADA",
  'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA",
  K.w_stadku_od "LOWI OD"
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
JOIN p1 ON B.nazwa = p1.NAZWA_BANDY
WHERE pseudo = '&pseudonim';

--Zad32
--Dla kot�w o trzech najd�u�szym sta�ach w po��czonych bandach CZARNI RYCERZE i �ACIACI MY�LIWI 
--zwi�kszy� przydzia� myszy o 10% minimalnego przydzia�u w ca�ym stadzie lub o 10 w zale�no�ci od tego 
--czy podwy�ka dotyczy kota p�ci �e�skiej czy kota p�ci m�skiej.
--Przydzia� myszy extra dla kot�w obu p�ci zwi�kszy� o 15% �redniego przydzia�u extra w bandzie kota. 
--Wy�wietli� na ekranie warto�ci przed i po podwy�ce a nast�pnie wycofa� zmiany.
  
CREATE OR REPLACE VIEW p2
AS
SELECT
  K.pseudo "Pseudonim",
  K.plec "Plec",
  NVL(K.przydzial_myszy,0) "Myszy pszed podw.",
  NVL(K.myszy_extra,0) "Extra przed podw."
FROM Kocury K
WHERE K.pseudo IN (
                  (SELECT * FROM
                    (
                    SELECT pseudo
                    FROM Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
                    WHERE B.nazwa = 'CZARNI RYCERZE' 
                    ORDER BY K1.w_stadku_od
                    )
                  WHERE rownum<=3)
                  UNION ALL
                   (SELECT * FROM
                    (
                    SELECT pseudo
                    FROM Kocury K2 JOIN Bandy B2 ON K2.nr_bandy = B2.nr_bandy
                    WHERE B2.nazwa = 'LACIACI MYSLIWI' 
                    ORDER BY K2.w_stadku_od
                    )
                  WHERE rownum<=3)    
                );
SET AUTOCOMMIT OFF;  
              
SELECT * FROM p2;


UPDATE
  Kocury K1
SET
  K1.przydzial_myszy = 
    CASE K1.plec
      WHEN 'M' THEN NVL(K1.przydzial_myszy,0) + 10
      WHEN 'D' THEN NVL(K1.przydzial_myszy,0) + (
        SELECT MIN(NVL(K.przydzial_myszy, 0)) FROM Kocury K) * 0.1
    END,
  K1.myszy_extra = NVL(K1.myszy_extra,0)+ (SELECT AVG(NVL(K2.myszy_extra,0)) FROM Kocury K2 WHERE K1.nr_bandy = K2.nr_bandy GROUP BY nr_bandy )*0.15
WHERE pseudo IN (
                  SELECT "Pseudonim" FROM p2
                  );

SELECT
  pseudo "Pseudonim",
  plec "Plec",
  NVL(przydzial_myszy, 0) "Myszy po podw.",
  NVL(myszy_extra, 0) "Extra po podw."
FROM
  Kocury
WHERE pseudo IN (
                  SELECT "Pseudonim" FROM p2
                  );
ROLLBACK;
SET AUTOCOMMIT ON;
                
     
--Zad33           
--Napisa� zapytanie, w ramach kt�rego obliczone zostan� sumy ca�kowitego spo�ycia myszy przez koty 
--sprawuj�ce ka�d� z funkcji z podzia�em na bandy i p�cie kot�w. 
--Podsumowa� przydzia�y dla ka�dej z funkcji. Zadanie wykona� na dwa sposoby:
--a.	z wykorzystaniem tzw. raportu macierzowego,
--b.	z wykorzystaniem klauzuli PIVOT

--a
SELECT * FROM(SELECT 
  DECODE(plec,'M',' ','D',nazwa)"NAZWA BANDY",
  DECODE(plec, 'M', 'Kocur','D','Kotka') "Plec",
  TO_CHAR(COUNT(*)) "Ile",
  TO_CHAR(SUM(DECODE(funkcja,'SZEFUNIO',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Szefunio",
  TO_CHAR(SUM(DECODE(funkcja,'BANDZIOR',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Bandzior",
  TO_CHAR(SUM(DECODE(funkcja,'LOWCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Lowczy",
  TO_CHAR(SUM(DECODE(funkcja,'LAPACZ',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,'KOT',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"KOT",
  TO_CHAR(SUM(DECODE(funkcja,'MILUSIA',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,'DZIELCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "Suma"
FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
GROUP BY nazwa, plec
ORDER BY nazwa)
UNION ALL --UNION sortuje wynik w celu usuniecia duplikatow, dlatego UNION ALL
SELECT
  'Z----------------',
  '------',
  '----',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '-------'
FROM DUAL
UNION ALL
SELECT
  'Zjada razem',
  ' ',
  ' ',
  TO_CHAR(SUM(DECODE(funkcja,'SZEFUNIO',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Szefunio",
  TO_CHAR(SUM(DECODE(funkcja,'BANDZIOR',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Bandzior",
  TO_CHAR(SUM(DECODE(funkcja,'LOWCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Lowczy",
  TO_CHAR(SUM(DECODE(funkcja,'LAPACZ',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,'KOT',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"KOT",
  TO_CHAR(SUM(DECODE(funkcja,'MILUSIA',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,'DZIELCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)))
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy;
  

--b
WITH Dane AS (SELECT funkcja, nazwa, plec, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) myszy_calk FROM Kocury NATURAL JOIN Bandy)
SELECT * FROM ( 
SELECT DECODE(plec, 'D', nazwa, ' ') "NAZWA BANDY",
  DECODE(plec, 'D', 'Kotka', 'Kocur') plec,
  TO_CHAR(s.ile) ILE, 
  TO_CHAR(NVL(pivot.SZEFUNIO, 0)) "SZEFUNIO",
  TO_CHAR(NVL(pivot.BANDZIOR, 0)) "BANDZIOR",
  TO_CHAR(NVL(pivot.LOWCZY,0)) "LOWCZY",
  TO_CHAR(NVL(pivot.LAPACZ,0)) "LAPACZ",
  TO_CHAR(NVL(pivot.KOT,0)) "KOT",
  TO_CHAR(NVL(pivot.MILUSIA,0)) "MILUSIA",
  TO_CHAR(NVL(pivot.DZIELCZY, 0)) "DZIELCZY",
  TO_CHAR(s.suma) "SUMA"
  FROM (Dane
        PIVOT(
          SUM(myszy_calk)
          FOR funkcja
          IN ('SZEFUNIO' SZEFUNIO, 'BANDZIOR' BANDZIOR, 'LOWCZY' LOWCZY, 'LAPACZ' LAPACZ, 'KOT' KOT, 'MILUSIA' MILUSIA, 'DZIELCZY' DZIELCZY)
        ) pivot
        NATURAL JOIN (SELECT nazwa, plec, COUNT(*) ILE, SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra, 0)) suma FROM Kocury NATURAL JOIN Bandy GROUP BY nazwa, plec) s
        )
  ORDER BY nazwa)
UNION ALL --UNION sortuje wynik w celu usuniecia duplikatow, dlatego UNION ALL
SELECT
  'Z----------------',
  '------',
  '----',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '-------'
FROM DUAL
UNION ALL
SELECT
  'Zjada razem',
  ' ',
  ' ',
  TO_CHAR(SUM(DECODE(funkcja,'SZEFUNIO',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Szefunio",
  TO_CHAR(SUM(DECODE(funkcja,'BANDZIOR',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Bandzior",
  TO_CHAR(SUM(DECODE(funkcja,'LOWCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"Lowczy",
  TO_CHAR(SUM(DECODE(funkcja,'LAPACZ',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,'KOT',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"KOT",
  TO_CHAR(SUM(DECODE(funkcja,'MILUSIA',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,'DZIELCZY',NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0),0)))"DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)))
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy;







