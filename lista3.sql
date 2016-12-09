--Zad34
--Napisaæ blok PL/SQL, który wybiera z relacji Kocury koty o funkcji podanej z klawiatury. 
--Jedynym efektem dzia³ania bloku ma byæ komunikat 
--informuj¹cy czy znaleziono, czy te¿ nie, kota pe³ni¹cego podan¹ funkcjê (w przypadku znalezienia kota wyœwietliæ nazwê odpowiedniej funkcji). 
DECLARE --blok anonimowy
  liczbaKrotek NUMBER;
  funkcjaKocura Funkcje.funkcja%TYPE:= '&funkcja' ; --funkcja wprowadzana z klawiatury
BEGIN
  SELECT COUNT(*)INTO liczbaKrotek --uzycie analityczne
  FROM Kocury
  WHERE funkcja = funkcjaKocura;
  
  IF liczbaKrotek > 0 
  THEN DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || funkcjaKocura); --ze znakiem przejscia do nowej linii
  ELSE DBMS_OUTPUT.PUT_LINE('Nie znaleziono');
  END IF;
END;


--Zad35
--Napisaæ blok PL/SQL, który wyprowadza na ekran nastêpuj¹ce informacje o kocie o pseudonimie wprowadzonym z klawiatury (w zale¿noœci od rzeczywistych danych):
--	'calkowity roczny przydzial myszy >700'
--'imiê zawiera litere A'
--'styczeñ jest miesiacem przystapienia do stada'
--	'nie odpowiada kryteriom'.
--Powy¿sze informacje wymienione s¹ zgodnie z hierarchi¹ wa¿noœci. Ka¿d¹ wprowadzan¹ informacjê poprzedziæ imieniem kota.
DECLARE
  calkowity_roczny_przydzial NUMBER;
  imie Kocury.imie%TYPE;
  miesiac NUMBER;
  kotZnaleziony BOOLEAN DEFAULT FALSE;
  pseudonim Kocury.pseudo%TYPE:='&pseudnonim';
BEGIN
  SELECT ((NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12), imie, EXTRACT(MONTH FROM(w_stadku_od)) INTO calkowity_roczny_przydzial, imie, miesiac
  FROM Kocury
  WHERE pseudo = pseudonim;
  
  --calkowity roczny przydzial myszy >700
  IF calkowity_roczny_przydzial > 700 THEN 
    DBMS_OUTPUT.PUT_LINE(imie ||' calkowity roczny przydzial myszy >700'); 
    kotZnaleziony := TRUE;
  END IF;
  --imiê zawiera litere A
  IF imie LIKE ('%a%') THEN 
    DBMS_OUTPUT.PUT_LINE(imie || ' imie zawiera litere A' ); 
    kotZnaleziony := TRUE;
  END IF;
  --styczeñ jest miesiacem przystapienia do stada
  IF miesiac=1 THEN 
    DBMS_OUTPUT.PUT_LINE(imie || 'styczen jest miesiace przystapienia do stada'); 
    kotZnaleziony := TRUE;
  END IF;
  --jesli nie spelnia zadnego warunku 
  IF kotZnaleziony= FALSE THEN
     DBMS_OUTPUT.PUT_LINE(imie || ' nie odpowiada kryteriom');
  END IF;
END;


--Zad36
--W zwi¹zku z du¿¹ wydajnoœci¹ w ³owieniu myszy SZEFUNIO postanowi³ wynagrodziæ swoich podw³adnych. 
--Og³osi³ wiêc, ¿e podwy¿sza indywidualny przydzia³ myszy ka¿dego kota o 10% poczynaj¹c od kotów o najni¿szym przydziale. 
--Jeœli w którymœ momencie suma wszystkich przydzia³ów przekroczy 1050, ¿aden inny kot nie dostanie podwy¿ki. 
--Jeœli przydzia³ myszy po podwy¿ce przekroczy maksymaln¹ wartoœæ nale¿n¹ dla pe³nionej funkcji (relacja Funkcje),
--przydzia³ myszy po podwy¿ce ma byæ równy tej wartoœci. 
--Napisaæ blok PL/SQL z kursorem, który wyznacza sumê przydzia³ów przed podwy¿k¹ a realizuje to zadanie. 
--Blok ma dzia³aæ tak d³ugo, a¿ suma wszystkich przydzia³ów 
--rzeczywiœcie przekroczy 1050 (liczba „obiegów podwy¿kowych” mo¿e byæ wiêksza od 1 a wiêc i podwy¿ka mo¿e byæ wiêksza ni¿ 10%). 
--Wyœwietliæ na ekranie sumê przydzia³ów myszy po wykonaniu zadania wraz z liczb¹ podwy¿ek (liczb¹ zmian w relacji Kocury). 
--Na koñcu wycofaæ wszystkie zmiany.
DECLARE
  CURSOR kursor IS --deklaracja kursora jawnego, przygotowanie danych
  SELECT * FROM Kocury K JOIN Funkcje F ON K.funkcja = F.funkcja ORDER BY przydzial_myszy; --'poczynaj¹c od kotów o najni¿szym przydziale'
  rekord kursor%ROWTYPE;
  sumaPrzydzialow NUMBER DEFAULT 0;
  liczbaZmian NUMBER DEFAULT 0;
  nowaWartosc NUMBER ;
BEGIN
  SELECT SUM(przydzial_myszy) INTO sumaPrzydzialow FROM Kocury; --suma przydzialow myszy na poczatku   
  
  <<zewn>>LOOP --petla zewnetrzna
            OPEN kursor; --otwarcie kursora --po otwarciu znajduje sie na pierwszej krotce          
              
              LOOP --petla wewnetrzna
                --jesli suma przekracza 1050 to podsumuj i wyjdz z petli zewnetrznej
                IF sumaPrzydzialow > 1050 THEN
                  DBMS_OUTPUT.PUT('Calk. przydzial w stadku '||sumaPrzydzialow);
                  DBMS_OUTPUT.PUT_LINE(' Zmian - '|| liczbaZmian);
                  EXIT zewn; --wyjdz z petli ZEWNETRZNEJ, zaden inny kot nie dostanie juz podwyzki
                END IF;
            
                FETCH kursor INTO rekord; --pobranie rekordu z kursora
                EXIT WHEN kursor%NOTFOUND;  --wyjdz z petli WEWNETRZNEJ jesli nie znaleziono juz kolejnej krotki
                
                --zmieniaj wartosc i zliczaj zmiany tylko jesli nowa wartosc mniejsza od max_myszy dla danej funkcji
                IF NVL(rekord.przydzial_myszy,0) < rekord.max_myszy 
                THEN 
                  nowaWartosc := NVL(rekord.przydzial_myszy,0) * 1.1; 
                  IF nowaWartosc > rekord.max_myszy THEN --Jeœli przydzia³ myszy po podwy¿ce przekroczy maksymaln¹ wartoœæ nale¿n¹ dla funkcji                   
                   nowaWartosc := rekord.max_myszy ;  --przydzia³ myszy po podwy¿ce ma byæ równy tej wartoœci            
                  END IF;
                
                  UPDATE Kocury SET przydzial_myszy = nowaWartosc WHERE pseudo = rekord.pseudo;
                  liczbaZmian  := liczbaZmian + 1;
                END IF;
                                 
                SELECT SUM(przydzial_myszy) INTO sumaPrzydzialow FROM Kocury; --aktualna suma przydzialow (po pojedynczej podwyzce)
              END LOOP;
              
            CLOSE kursor; --zamkniecie kursora
          END LOOP;          
END;

SELECT imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" FROM Kocury;
ROLLBACK;


--Zad 37
--Napisaæ blok, który powoduje wybranie w pêtli kursorowej FOR piêciu kotów o najwy¿szym ca³kowitym przydziale myszy. 
--Wynik wyœwietliæ na ekranie.
DECLARE
  CURSOR kursor IS
  SELECT * --piec kotow o najwyzszym przydziale myszy
  FROM( SELECT pseudo,NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) zjada
        FROM Kocury
        ORDER BY zjada DESC      
      )
  WHERE ROWNUM <=5;
  numer NUMBER DEFAULT 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
 
  FOR kocur IN  kursor --niejawne otwarcie, pobranie, zamkniece kursora, skonczy sie po pobraniu wszystkich rekordow z kursora
  LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(numer,4) || '  ' || RPAD(kocur.pseudo,9) || '    ' || LPAD(kocur.zjada,5) );
    numer:=numer+1;
  END LOOP;
  
  EXCEPTION
    WHEN NO_DATA_FOUND
         THEN DBMS_OUTPUT.PUT_LINE('Brak kotow');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


--Zad38
--Napisaæ blok, który zrealizuje wersjê a. lub wersjê b. zad. 19 w sposób uniwersalny (bez koniecznoœci uwzglêdniania wiedzy o g³êbokoœci drzewa). 
--Dan¹ wejœciow¹ ma byæ maksymalna liczba wyœwietlanych prze³o¿onych.
--Dla kotów pe³ni¹cych funkcjê KOT i MILUSIA wyœwietliæ w kolejnoœci hierarchii imiona wszystkich ich szefów. 
DECLARE
  liczbaPrzelozonych NUMBER DEFAULT &liczbaPrzelozonych; --maksymalna liczba wyswietlanych przelozonych
  maksymalnyPoziom NUMBER ; --maksymalny mo¿liwy do wyswietlenie poziom szefow
  obecnyPoziom NUMBER;
  obecnyKocur Kocury%ROWTYPE;
BEGIN
  SELECT MAX(level)-1 INTO maksymalnyPoziom --sprawdzam maksymalny poziom
  FROM Kocury
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;
  
  liczbaPrzelozonych := LEAST(liczbaPrzelozonych,maksymalnyPoziom); --LEAST zwraca wartosc najmniejsza z listy wartosci
  
  --budowanie naglowka
  --imie
  DBMS_OUTPUT.PUT(RPAD('Imie', 10));
  --kolejni szefowie w naglowku
  FOR i IN 1..liczbaPrzelozonych 
  LOOP
    DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
  
  --wyswietlanie wlasciwej listy kotow z szefami
  --dla kazdego kocura z selecta bede wyswietlal kolejnych szefow
  FOR kotPoczatkowy IN(SELECT * FROM Kocury WHERE funkcja IN ('MILUSIA','KOT')) --kursor niejawny
  LOOP
    obecnyPoziom := 1;
    DBMS_OUTPUT.PUT(RPAD(kotPoczatkowy.imie, 10));
    
    obecnyKocur:=kotPoczatkowy;
    WHILE obecnyPoziom <= liczbaPrzelozonych 
    LOOP
      IF obecnyKocur.szef IS NOT NULL  THEN
        SELECT * INTO obecnyKocur FROM Kocury WHERE pseudo=obecnyKocur.szef; --przechodze do kolejnego szefa w hierarchii
        DBMS_OUTPUT.put('  |  ' || RPAD(obecnyKocur.imie, 10));
      ELSE 
        DBMS_OUTPUT.PUT('  |  ' || RPAD(' ', 10)); -- wypelnij spacjami nawet jak jest null
      END IF;
      obecnyPoziom:=obecnyPoziom+1;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE; --nie wyswietli sie dopoki nie dam NEW_LINE - PUT daje do bufora
  END LOOP;
END;


--Zad39
--Napisaæ blok PL/SQL wczytuj¹cy trzy parametry reprezentuj¹ce nr bandy, nazwê bandy oraz teren polowañ. 
--Skrypt ma uniemo¿liwiaæ wprowadzenie istniej¹cych ju¿ wartoœci parametrów poprzez obs³ugê odpowiednich wyj¹tków. 
--Sytuacj¹ wyj¹tkow¹ jest tak¿e wprowadzenie numeru bandy <=0. 
--W przypadku zaistnienia sytuacji wyj¹tkowej nale¿y wyprowadziæ na ekran odpowiedni komunikat. 
--W przypadku prawid³owych parametrów nale¿y stworzyæ now¹ bandê w relacji Bandy. Zmianê nale¿y na koñcu wycofaæ.
DECLARE
  numer_bandy Bandy.nr_bandy%TYPE DEFAULT '&numer_bandy';
  nazwa_bandy Bandy.nazwa%TYPE DEFAULT '&nazwa_bandy';
  teren_bandy Bandy.teren%TYPE DEFAULT '&teren_bandy' ;
  
  liczba_band_o_danym_parametrze NUMBER DEFAULT 0;
  
  nr_bandy_mniejszy_od_zera EXCEPTION;
  banda_juz_istnieje EXCEPTION;
  przyczyna STRING(128) DEFAULT '';
BEGIN
  --rzuc wyjatek jesli wprowadzony numer mniejszy od zera
  IF numer_bandy <=0 THEN RAISE nr_bandy_mniejszy_od_zera;
  END IF;
  
  --sprawdzam czy istnnieje taki numer bandy
  SELECT COUNT(nr_bandy) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nr_bandy = numer_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
    przyczyna := TO_CHAR(numer_bandy);
  END IF;
  
  --sprawdzam czy istnieje taka nazwa bandy
  SELECT COUNT(nazwa) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nazwa = nazwa_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN  --nie rzucam wyjatku jeszcze zeby sprawdzic reszte
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || nazwa_bandy;
    ELSE
      przyczyna := nazwa_bandy;
    END IF;
  END IF;
  
  --sprawdzam czy istnieje taki teren bandy
  SELECT COUNT(teren) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE teren = teren_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || teren_bandy;
    ELSE
      przyczyna := teren_bandy;
    END IF;
  END IF;
  
  --jesli cos juz istnialo to rzucam wyjatek
  IF LENGTH(przyczyna) > 0 THEN --dopiero na koncu rzucam wyjatek
    RAISE banda_juz_istnieje;
  END IF;
  
  --dojde tutaj tylko wtedy, kiedy wczesniej nie rzuce wyjatku
  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);

  EXCEPTION
  WHEN nr_bandy_mniejszy_od_zera THEN DBMS_OUTPUT.PUT_LINE('Numer bandy musi byc wiekszy od zera');
  WHEN banda_juz_istnieje THEN DBMS_OUTPUT.PUT_LINE(przyczyna || ' Juz istnieje!');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

ROLLBACK;

--Zad40
CREATE OR REPLACE PROCEDURE wstawianie (numer_bandy Bandy.nr_bandy%TYPE,nazwa_bandy Bandy.nazwa%TYPE,teren_bandy Bandy.teren%TYPE )
IS
  liczba_band_o_danym_parametrze NUMBER DEFAULT 0;
  nr_bandy_mniejszy_od_zera EXCEPTION;
  banda_juz_istnieje EXCEPTION;
  przyczyna STRING(128) DEFAULT '';
BEGIN
  IF numer_bandy <=0 THEN RAISE nr_bandy_mniejszy_od_zera;
  END IF;
  
  SELECT COUNT(nr_bandy) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nr_bandy = numer_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
    przyczyna := TO_CHAR(numer_bandy);
  END IF;
  
  SELECT COUNT(nazwa) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nazwa = nazwa_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN  --nie rzucam wyjatku jeszcze zeby sprawdzic reszte
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || nazwa_bandy;
    ELSE
      przyczyna := nazwa_bandy;
    END IF;
  END IF;
  
  SELECT COUNT(teren) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE teren = teren_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || teren_bandy;
    ELSE
      przyczyna := teren_bandy;
    END IF;
  END IF;
  
  IF LENGTH(przyczyna) > 0 THEN --dopiero na koncu rzucam wyjatek
    RAISE banda_juz_istnieje;
  END IF;
  
  --dojde tutaj tylko wtedy, kiedy wczesniej nie rzuce wyjatku
  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);

  EXCEPTION
  WHEN nr_bandy_mniejszy_od_zera THEN DBMS_OUTPUT.PUT_LINE('Numer bandy musi byc wiekszy od zera');
  WHEN banda_juz_istnieje THEN DBMS_OUTPUT.PUT_LINE(przyczyna || ' Juz istnieje!');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--Zad41
--Zdefiniowaæ wyzwalacz, który zapewni, ¿e numer nowej bandy bêdzie zawsze wiêkszy o 1 od najwy¿szego numeru istniej¹cej ju¿ bandy. 
--Sprawdziæ dzia³anie wyzwalacza wykorzystuj¹c procedurê z zadania 40.
CREATE OR REPLACE TRIGGER dopisanie_bandy
BEFORE INSERT 
ON Bandy
FOR EACH ROW
BEGIN
  SELECT MAX(nr_bandy)+1 INTO :NEW.nr_bandy FROM Bandy;
END;
--test=
BEGIN 
  wstawianie(66,'NOWA_BANDA','NOWY_TEREN');
END;
ROLLBACK;


--zad42
--ograniczenie dla wyzwalacza wierszowego DML : brak mo¿liwoœci odczytu lub zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz. 
--a
--pamiec w postaci pakietu
CREATE OR REPLACE PACKAGE Pakiet AS
  przydzial_tygrysa NUMBER ;
  suma_podwyzek_dla_tygrysa NUMBER DEFAULT 0;
  suma_kar_dla_tygrysa NUMBER DEFAULT 0;
END Pakiet;

--najpierw aktywuje sie BEFORE poleceniowy
--tygrys ma tylko jeden przydzial myszy
CREATE OR REPLACE TRIGGER przydzial_myszy_tygrysa
BEFORE UPDATE OF przydzial_myszy ON Kocury 
BEGIN
  SELECT przydzial_myszy INTO Pakiet.przydzial_tygrysa FROM Kocury WHERE pseudo = 'TYGRYS';
END;

--potem before wierszowy
CREATE OR REPLACE TRIGGER przydzial_myszy
BEFORE UPDATE OF przydzial_myszy ON Kocury 
FOR EACH ROW
DECLARE
  przydzial_minimalny_funkcji NUMBER ;
  przydzial_maksymalny_funkcji NUMBER ;
  podwyzka NUMBER DEFAULT 0;
BEGIN
  SELECT min_myszy,max_myszy INTO przydzial_minimalny_funkcji,przydzial_maksymalny_funkcji
  FROM Funkcje
  WHERE funkcja = :NEW.funkcja; -- :OLD i :NEW moze byc wykorzystane w ciele lub w klauzuli WHEN
  
  IF :NEW.funkcja = 'MILUSIA' THEN
    --nie ma mowy o obnizce dla MILUS
    IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN 
      :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      DBMS_OUTPUT.PUT_LINE('Nie ma mowy o obnizce dla Milus !');
    --jesli nastapila podwyzka to wylicz jej wysokosc
    ELSE
      podwyzka := :NEW.przydzial_myszy - :OLD.przydzial_myszy;
      --jesli podwyzka jednak zbyt mala 
      IF podwyzka > 0 AND podwyzka < 0.1 * Pakiet.przydzial_tygrysa THEN
        --zwiekszenie przydzialu o wartosc 10% przydzialu tygrysa i zwiekszenie myszy_extra o 5
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * Pakiet.przydzial_tygrysa;
        :NEW.myszy_extra := :NEW.myszy_extra + 5; 
        
        --kara dla tygrysa
        Pakiet.suma_kar_dla_tygrysa := Pakiet.suma_kar_dla_tygrysa + 0.1 * Pakiet.przydzial_tygrysa;
        
        ELSE IF podwyzka > 0 AND podwyzka >= 0.1 * Pakiet.przydzial_tygrysa THEN
          --nagrodla dla tygrysa
        Pakiet.suma_podwyzek_dla_tygrysa := Pakiet.suma_podwyzek_dla_tygrysa + 5;
        END IF;
      END IF;  
    END IF;   
  END IF;
  
  -- ograniczenia zwiazane z pelniona funkcja (dla kazdej funkcji - nie tylko dla milus)
  IF :new.przydzial_myszy < przydzial_minimalny_funkcji THEN
    :new.przydzial_myszy := przydzial_minimalny_funkcji;
  ELSIF :new.przydzial_myszy > przydzial_maksymalny_funkcji THEN
    :new.przydzial_myszy := przydzial_maksymalny_funkcji;
  END IF;
END;

--kontrola kar i nagrod dla TYGRYSA
--wystarczy, ze wykona sie raz
CREATE OR REPLACE TRIGGER po_przydziale_myszy
AFTER UPDATE OF przydzial_myszy ON Kocury 
DECLARE
tmp NUMBER;
BEGIN
  IF Pakiet.suma_kar_dla_tygrysa > 0 THEN
    tmp := Pakiet.suma_kar_dla_tygrysa;
    --Pakiet.suma_kar_dla_tygrysa := 0; -- przeciwdziala petli nieskonczonej
    
    IF tmp > Pakiet.przydzial_tygrysa THEN
      UPDATE Kocury SET przydzial_myszy = 0
      WHERE pseudo = 'TYGRYS';
    ELSE
      UPDATE Kocury SET przydzial_myszy = przydzial_myszy - tmp
      WHERE pseudo = 'TYGRYS';
    END IF;
  END IF;
   
  IF Pakiet.suma_podwyzek_dla_tygrysa > 0 THEN
    tmp := Pakiet.suma_podwyzek_dla_tygrysa;
    --Pakiet.suma_podwyzek_dla_tygrysa := 0; -- przeciwdziala petli nieskonczonej
    
    UPDATE Kocury SET
      myszy_extra = myszy_extra + Pakiet.suma_podwyzek_dla_tygrysa
    WHERE pseudo = 'TYGRYS';
  END IF;
  
END;

--test
SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy - 1 WHERE funkcja = 'MILUSIA';
SELECT * FROM Kocury;
ROLLBACK;


--Zad42b
CREATE OR REPLACE TRIGGER compound_trigger
FOR UPDATE OF przydzial_myszy 
ON Kocury
COMPOUND TRIGGER
  --zmienne, ktore wczesniej byly w pakiecie i w poszczegolnych wyzwalaczach, teraz wspolne
  przydzial_tygrysa NUMBER ;
  przydzial_minimalny_funkcji NUMBER ;
  przydzial_maksymalny_funkcji NUMBER ;
  podwyzka NUMBER DEFAULT 0;
  suma_podwyzek_dla_tygrysa NUMBER DEFAULT 0;
  suma_kar_dla_tygrysa NUMBER DEFAULT 0;
  tmp NUMBER;
  
  --odpowiednik wyzwalacza poleceniowego before
  BEFORE STATEMENT IS
  BEGIN
  SELECT przydzial_myszy INTO przydzial_tygrysa FROM Kocury WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;
  
  --odpowiednik wyzwalacza wierszowego before
  BEFORE EACH ROW IS
  BEGIN
   SELECT min_myszy,max_myszy INTO przydzial_minimalny_funkcji,przydzial_maksymalny_funkcji
  FROM Funkcje
  WHERE funkcja = :NEW.funkcja; -- :OLD i :NEW moze byc wykorzystane w ciele lub w klauzuli WHEN
  
  IF :NEW.funkcja = 'MILUSIA' THEN
    --nie ma mowy o obnizce dla MILUS
    IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN 
      :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      DBMS_OUTPUT.PUT_LINE('Nie ma mowy o obnizce dla Milus !');
    --jesli nastapila podwyzka to wylicz jej wysokosc
    ELSE
      podwyzka := :NEW.przydzial_myszy - :OLD.przydzial_myszy;
      --jesli podwyzka jednak zbyt mala 
      IF podwyzka > 0 AND podwyzka < 0.1 * przydzial_tygrysa THEN
        --zwiekszenie przydzialu o wartosc 10% przydzialu tygrysa i zwiekszenie myszy_extra o 5
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * przydzial_tygrysa;
        :NEW.myszy_extra := :NEW.myszy_extra + 5; 
        
        --kara dla tygrysa
        suma_kar_dla_tygrysa := suma_kar_dla_tygrysa + 0.1 * przydzial_tygrysa;
        DBMS_OUTPUT.PUT_LINE('Suma kar dla tygrysa za zbyt mala podwyzke dla Milus : ' || suma_kar_dla_tygrysa);
        ELSE IF podwyzka > 0 AND podwyzka >= 0.1 * przydzial_tygrysa THEN
        
        --nagrodla dla tygrysa
        suma_podwyzek_dla_tygrysa := suma_podwyzek_dla_tygrysa + 5;
        DBMS_OUTPUT.PUT_LINE('Suma podwyzek dla tygrysa za odpowiednio wysoka podwyzke dla Milus ' || suma_podwyzek_dla_tygrysa);
        END IF;
      END IF;  
    END IF;   
  END IF;
  
  -- ograniczenia zwiazane z pelniona funkcja (dla kazdej funkcji - nie tylko dla milus)
  IF :new.przydzial_myszy < przydzial_minimalny_funkcji THEN
    :new.przydzial_myszy := przydzial_minimalny_funkcji;
  ELSIF :new.przydzial_myszy > przydzial_maksymalny_funkcji THEN
    :new.przydzial_myszy := przydzial_maksymalny_funkcji;
  END IF;
  END BEFORE EACH ROW;
  
  --odpowiednik wyzwalacza poleceniowego after
  AFTER STATEMENT IS
  BEGIN
  IF suma_kar_dla_tygrysa > 0 THEN
    tmp := suma_kar_dla_tygrysa;
    --suma_kar_dla_tygrysa := 0; -- przeciwdziala petli nieskonczonej
    
    IF tmp > przydzial_tygrysa THEN
      UPDATE Kocury SET przydzial_myszy = 0
      WHERE pseudo = 'TYGRYS';
    ELSE
      UPDATE Kocury SET przydzial_myszy = przydzial_myszy - tmp
      WHERE pseudo = 'TYGRYS';
    END IF;
  END IF;
   
  IF suma_podwyzek_dla_tygrysa > 0 THEN
    tmp := suma_podwyzek_dla_tygrysa;
    --suma_podwyzek_dla_tygrysa := 0; -- przeciwdziala petli nieskonczonej
    
    UPDATE Kocury SET
      myszy_extra = myszy_extra + suma_podwyzek_dla_tygrysa
    WHERE pseudo = 'TYGRYS';
  END IF;
  END AFTER STATEMENT;
  
END compound_trigger;

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 1 WHERE funkcja = 'MILUSIA';
SELECT * FROM Kocury;
ROLLBACK;


--Zad43 
--Napisaæ zapytanie, w ramach którego obliczone zostan¹ sumy ca³kowitego spo¿ycia myszy 
--przez koty sprawuj¹ce ka¿d¹ z funkcji z podzia³em na bandy i p³cie kotów. Podsumowaæ przydzia³y dla ka¿dej z funkcji
--Napisaæ blok, który zrealizuje zad. 33 w sposób uniwersalny (bez koniecznoœci uwzglêdniania wiedzy o funkcjach pe³nionych przez koty). 
DECLARE
  liczba NUMBER;
BEGIN
  --naglowek raportu
  DBMS_OUTPUT.PUT('NAZWA BANDY       PLEC    ILE');
  FOR funkcja IN (SELECT funkcja FROM FUNKCJE) LOOP
    DBMS_OUTPUT.PUT(LPAD(funkcja.funkcja, 10));
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('    SUMA');
   
  --tresc raportu
  FOR banda IN (SELECT nazwa, nr_bandy FROM BANDY ORDER BY nazwa) LOOP
    FOR plec IN (SELECT plec FROM KOCURY group by plec) LOOP
      DBMS_OUTPUT.PUT(CASE WHEN plec.plec = 'M' THEN RPAD(banda.nazwa, 18) ELSE '                  ' END);
      DBMS_OUTPUT.PUT(CASE WHEN plec.plec = 'M' THEN 'Kocor  ' ELSE 'Kotka  ' END);   
      -- liczba kotow wspolna ze wzgledu na banda,plec
      SELECT COUNT(*) 
        INTO liczba 
        FROM KOCURY K 
        WHERE K.nr_bandy = banda.nr_bandy
        AND K.plec = plec.plec;
      DBMS_OUTPUT.PUT(LPAD(liczba,4));
      
      --sumy prydzialow wspolne ze wzgledu na banda,plec,funkcja
      FOR funkcja IN (SELECT funkcja FROM FUNKCJE) LOOP
        SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0))
          INTO liczba 
          FROM KOCURY K 
          WHERE K.nr_bandy = banda.nr_bandy
          AND K.plec = plec.plec
          AND K.funkcja = funkcja.funkcja;
        DBMS_OUTPUT.PUT(LPAD(NVL(liczba, 0),10));
      END LOOP;
      
      --suma wspolna ze wzgledu na banda,plec
      SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0))
        INTO liczba 
        FROM KOCURY K 
        WHERE K.nr_bandy = banda.nr_bandy
        AND K.plec = plec.plec;
      DBMS_OUTPUT.PUT(LPAD(NVL(liczba, 0),8));
      DBMS_OUTPUT.NEW_LINE();
    END LOOP;
  END LOOP;
  -- myslniki
  DBMS_OUTPUT.PUT('----------------- ------ ----');
  FOR funkcja IN (SELECT funkcja FROM FUNKCJE) LOOP
    DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT(' -------');
  DBMS_OUTPUT.NEW_LINE();
  
  -- sumy - ostatni wiersz raportu
  DBMS_OUTPUT.PUT('ZJADA RAZEM                  ');
  
  --sumy dla funkcji
  FOR funkcja IN (SELECT funkcja FROM FUNKCJE) LOOP
    SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0))
      INTO liczba FROM KOCURY K
      WHERE K.FUNKCJA=FUNKCJA.FUNKCJA;
      DBMS_OUTPUT.PUT(LPAD(NVL(liczba, 0),10));
 
END LOOP;  
DBMS_OUTPUT.NEW_LINE();
 
END;



--Zad44
CREATE OR  REPLACE PACKAGE Podatki AS
  PROCEDURE wstawianie(numer_bandy Bandy.nr_bandy%TYPE, nazwa_bandy Bandy.nazwa%TYPE, teren_bandy Bandy.teren%TYPE);  
  FUNCTION nalezny_podatek(pseudonim Kocury.pseudo%TYPE) RETURN NUMBER;
END Podatki;

CREATE OR REPLACE PACKAGE BODY Podatki AS
  --Procedura z zadania 40
  PROCEDURE wstawianie (numer_bandy Bandy.nr_bandy%TYPE,nazwa_bandy Bandy.nazwa%TYPE,teren_bandy Bandy.teren%TYPE )
  IS
  liczba_band_o_danym_parametrze NUMBER DEFAULT 0;
  nr_bandy_mniejszy_od_zera EXCEPTION;
  banda_juz_istnieje EXCEPTION;
  przyczyna STRING(128) DEFAULT '';
BEGIN
  IF numer_bandy <=0 THEN RAISE nr_bandy_mniejszy_od_zera;
  END IF;
  
  SELECT COUNT(nr_bandy) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nr_bandy = numer_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
    przyczyna := TO_CHAR(numer_bandy);
  END IF;
  
  SELECT COUNT(nazwa) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE nazwa = nazwa_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN  --nie rzucam wyjatku jeszcze zeby sprawdzic reszte
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || nazwa_bandy;
    ELSE
      przyczyna := nazwa_bandy;
    END IF;
  END IF;
  
  SELECT COUNT(teren) INTO liczba_band_o_danym_parametrze FROM Bandy WHERE teren = teren_bandy;
  IF liczba_band_o_danym_parametrze > 0 THEN 
     IF LENGTH(przyczyna) > 0 THEN
      przyczyna := przyczyna || ', ' || teren_bandy;
    ELSE
      przyczyna := teren_bandy;
    END IF;
  END IF;
  
  IF LENGTH(przyczyna) > 0 THEN --dopiero na koncu rzucam wyjatek
    RAISE banda_juz_istnieje;
  END IF;
  
  --dojde tutaj tylko wtedy, kiedy wczesniej nie rzuce wyjatku
  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);

  EXCEPTION
  WHEN nr_bandy_mniejszy_od_zera THEN DBMS_OUTPUT.PUT_LINE('Numer bandy musi byc wiekszy od zera');
  WHEN banda_juz_istnieje THEN DBMS_OUTPUT.PUT_LINE(przyczyna || ' Juz istnieje!');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
  
END;
  
  --funkcja wyliczajaca podatek nalezny od kocura
FUNCTION nalezny_podatek(pseudonim Kocury.pseudo%TYPE) RETURN NUMBER AS
    podatek_nalezny NUMBER DEFAULT 0;
    tmp NUMBER DEFAULT 0;
    funkcja Funkcje.funkcja%TYPE;
  BEGIN
  
  --podatek podstawowy
  SELECT CEIL(0.05* (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) podatek_podstawowy INTO podatek_nalezny
  FROM Kocury
  WHERE pseudo = pseudonim;
  
  --podatek od nieposiadania podwaldnych
  SELECT COUNT(pseudo) liczba_podwladnych INTO tmp
  FROM Kocury
  WHERE szef = pseudonim;
  --jesli kot nie posiada podwladnych to podatek rosnie + 2
  IF tmp = 0 THEN
    podatek_nalezny := podatek_nalezny + 2;
  END IF;
  
  --koty nie posiadaj¹ce wrogów oddaj¹ po jednej myszy za zbytni¹  ugodowoœæ
  SELECT COUNT(WK.pseudo) INTO tmp
  FROM Wrogowie_Kocurow WK
  WHERE WK.pseudo = pseudonim;
  --jesli brak wrogow to obciaz podatkiem +1
  IF tmp = 0 THEN
    podatek_nalezny := podatek_nalezny + 1;
  END IF;
  
  --podatek od bycia MILUSIA
  --jesli pelniona funkcja to MILUSIA to podatek + 3
  SELECT funkcja INTO funkcja
  FROM Kocury
  WHERE pseudo = pseudonim;
  IF funkcja = 'MILUSIA' THEN
    podatek_nalezny := podatek_nalezny + 3;
  END IF;
  
  RETURN podatek_nalezny;
  
  END nalezny_podatek;

END Podatki;


--Zad45
DROP TABLE Dodatki_extra;
CREATE TABLE Dodatki_extra (
 pseudo VARCHAR2(15) CONSTRAINT dodatki_extra_pk PRIMARY KEY REFERENCES Kocury(pseudo),
 dodatek_extra NUMBER(3) NOT NULL
);

CREATE OR REPLACE TRIGGER dodatki_extra
AFTER UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF :NEW.przydzial_myszy > :OLD.przydzial_myszy AND :NEW.funkcja = 'MILUSIA' AND LOGIN_USER != 'TYGRYS' THEN
    EXECUTE IMMEDIATE
    '
    DECLARE
      CURSOR Milusie IS SELECT pseudo FROM Kocury WHERE funkcja = ''MILUSIA'';
      liczbaKrotekWDodatkach NUMBER DEFAULT 0;
    BEGIN
      SELECT COUNT(*) INTO liczbaKrotekWDodatkach FROM Dodatki_extra;
      IF liczbaKrotekWDodatkach > 0 THEN
        UPDATE Dodatki_extra SET dodatek_extra = NVL(dodatek_extra,0)-10;
      ELSE
        FOR milusia IN Milusie LOOP
          INSERT INTO Dodatki_extra(pseudo, dodatek_extra) VALUES (milusia.pseudo, -10);
        END LOOP;
      END IF;
    END;
    ';
  END IF; 
  COMMIT;
END;


--Zad 46
--Napisaæ wyzwalacz, który uniemo¿liwi wpisanie kotu przydzia³u myszy spoza przedzia³u (min_myszy, max_myszy) 
--okreœlonego dla ka¿dej funkcji w relacji Funkcje. 
--Ka¿da próba wykroczenia poza obowi¹zuj¹cy przedzia³
--ma byæ dodatkowo monitorowana w osobnej relacji (kto, kiedy, jakiemu kotu, jak¹ operacj¹).
CREATE TABLE Historia_zmian(
          nr_zmiany NUMBER(5),
          kto VARCHAR2(15),
          kiedy DATE,
          komu VARCHAR2(15),
          operacja VARCHAR2(15));
          
CREATE SEQUENCE nr_zmiany;

CREATE OR REPLACE TRIGGER przydzial_spoza_przedzialu
BEFORE INSERT OR UPDATE OF przydzial_myszy 
ON Kocury
FOR EACH ROW
DECLARE  
  kto Historia_zmian.kto%TYPE;
  kiedy Historia_zmian.kiedy%TYPE;
  komu Historia_zmian.komu%TYPE;
  jaka_operacja Historia_zmian.operacja%TYPE;
  
  przydzial_minimalny_funkcji NUMBER ;
  przydzial_maksymalny_funkcji NUMBER ;
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    SELECT min_myszy,max_myszy INTO przydzial_minimalny_funkcji,przydzial_maksymalny_funkcji
    FROM Funkcje
    WHERE funkcja = :NEW.funkcja; -- :OLD i :NEW moze byc wykorzystane w ciele lub w klauzuli WHEN
    
    --jesli przydzial poza zakresem
    IF :NEW.przydzial_myszy > przydzial_maksymalny_funkcji OR :NEW.przydzial_myszy < przydzial_minimalny_funkcji THEN
      DBMS_OUTPUT.PUT_LINE('Nowy przydzial poza zakresem!');    
      
      --zmien nowa wartosc na poprawna
      :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      
      --zarejestruj taka zmiane
      kto := LOGIN_USER;
      kiedy := SYSDATE;
      komu := :NEW.pseudo;
      IF INSERTING THEN
        jaka_operacja := 'INSERT';
      END IF;
      IF UPDATING THEN
        jaka_operacja := 'UPDATE';
      END IF;
    END IF;
   
    --zapisz probe zmiany w relacji Historia_zmian
    INSERT INTO Historia_zmian(NR_ZMIANY,KTO,KIEDY,KOMU,OPERACJA) VALUES (nr_zmiany.NEXTVAL,kto,kiedy,komu,jaka_operacja);
    COMMIT; 
END;

--test
UPDATE Kocury  SET przydzial_myszy = 150 WHERE pseudo='LOLA';
UPDATE Kocury  SET przydzial_myszy = 80 WHERE pseudo='RAFA';



