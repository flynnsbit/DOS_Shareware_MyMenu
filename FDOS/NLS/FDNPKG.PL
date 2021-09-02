#
# FDNPKG language file
#
# Language..: Polish
# Codepage..: MAZOVIA
# Translator: Mateusz Viste
#



#### Help ####
1.0:Sieciowy menadßer pakiet¢w dla FreeDOS.
1.1:Skíadnia: FDNPKG akcja [parametry]
1.2:Gdzie akcja to jedno z ponißszych:
1.3: search [string]   - wyszukuje w repozytoriach pakiety zawierajÜce 'string'
1.4: vsearch [string]  - to samo co 'search', ale wyûwietla takße repozytoria
1.5: install pkg       - instaluje pakiet 'pkg' (lub lokalny plik zip)
1.6: remove pkg        - usuwa pakiet 'pkg'
1.7: dumpcfg           - wyûwietla konfiguracjë wczytanÜ z pliku cfg
1.8: license           - wyûwietla licencjë programu
1.9:FDNPKG jest podlinkowany z WatTCP w ponißszej wersji:
1.10: install-nosrc pkg - instaluje pakiet 'pkg' (lub lokalny plik zip) bez ¶r¢deí
1.11: install-wsrc pkg  - instaluje pakiet 'pkg' (lub lokalny plik zip) ze ¶r¢díami
1.12: showinstalled [str] - wyûwietla zainstalowane pakiety zawierajÜce 'str'
1.13: checkupdates      - sprawdza dostëpne uaktualnienia pakiet¢w i je wyûwietla
1.14: update pkg        - uaktualnia pakiet 'pkg' do nowszej wersji
1.15: update [pkg]      - uaktualnia pakiet 'pkg' (lub wszystkie pakiety)
1.16: listlocal [str]   - wyûwietla zainstalowane pakiety zawierajÜce 'str'
1.17:FDNPKG jest podlinkowany z Watt-32 w ponißszej wersji:
1.18: listfiles pkg     - wyûwietla pliki naleßÜce do pakietu 'pkg'


### General stuff ####
2.0:%TEMP% nie ustawione! Ustaw by wskazywaío na tymczasowy katalog.
2.1:Przykíad: SET TEMP=C:\TEMP
2.2:%DOSDIR% nie ustawione! Ustaw by wskazywaío na katalog instalacji FreeDOS.
2.3:Przykíad: SET DOSDIR=C:\FDOS
2.4:Nieprawidíowa liczba parametr¢w. Uruchom bez parametr¢w by uzyskaç pomoc.
2.5:Brak skonfigurowanych repozytori¢w. Ustaw przynajmniej jeden.
2.6:Dodaj do pliku konfiguracyjnego przynajmniej jeden wpis w takiej formie:
2.7:REPO www.freedos.org/repo
2.8:Ponißej lista skonfigurowanych repozytori¢w fdnpkg:
2.9:Odûwießanie %s...
2.10:ûciÜganie repozytorium nie powiodío sië!
2.11:BíÜd podczas íadowania repozytorium z pliku tmp...
2.12:UWAGA: %TZ% nie ustawione! daty na instalowanych plikach mogÜ byç nieûcisíe.
2.13:Baza danych pakiet¢w zaíadowana z pamiëci podrëcznej.
2.14:Brak pamiëci! (%s)
2.15:BúèD: inicjalizacja TCP/IP nie powiodía sië!
2.16:úadowanie %s...
2.17:UWAGA: Niski poziom pamiëci wirtualnej. FDNPKG moße zachowywaç sië bíëdnie.
2.18:BúèD: Nie moßna pisaç w katalogu '%s'. Sprawd¶ ustawienie zmiennej %%TEMP%%.


#### Installing package ####
3.0:Pakiet %s jest juß zainstalowany! Usu§ go najpierw jeûli chcesz uaktualniç.
3.1:Nie znaleziono pakietu '%s' w repozytoriach.
3.2:Pakiet '%s' jest niedostëpny w repozytoriach.
3.3:%s jest dostëpny z kilku repozytori¢w. Wybierz kt¢ry ußyç:
3.4:Tw¢j wyb¢r:
3.5:Nieprawidíowy wyb¢r!
3.6:ûciÜganie pakietu %s...
3.7:BíÜd podczas ûciÜgania pakietu.
3.8:BíÜd: Nieprawidíowe archiwum zip! Pakiet nie zostaí zainstalowany.
3.9:BíÜd: Pakiet zawiera plik kt¢ry juß istnieje lokalnie:
3.10:BíÜd: Nie udaío sië stworzyç %s!
3.11:Pakiet %s zostaí zainstalowany.
3.12:BíÜd: Pakiet nie zawiera pliku %s! Nieprawidíowy pakiet FreeDOS.
3.13:BíÜd: ûciÜgniëty pakiet zawiera bíëdne CRC. Instalacja przerwana.
3.14:BíÜd: Nie udaío sië otworzyç ûciÜgniëtego pakietu. Instalacja przerwana.
3.15:BíÜd: Brak pamiëci podczas obliczania CRC pakietu!
3.16:Pakiet %s zostaí zainstalowany (wraz ze ¶r¢díami, jeûli dostëpne).
3.17:Pakiet %s zostaí zainstalowany (bez ¶r¢deí).
3.18:Pakiet %s jest juß zainstalowany! Zobacz akcjë 'update'.
3.19:Pakiet %s zostaí zainstalowany: rozpakowano %d plik¢w, %d bíëd¢w.
3.20:BíÜd: Pakiet zawiera zaszyfrowany plik:
3.21:BíÜd: Nie udaío sië otworzyç pliku link '%s' dla odczytu.
3.22:BíÜd: Nie udaío sië otworzyç pliku link '%s' dla zapisu.


#### Removing package ####
4.0:Pakiet %s nie jest zainstalowany, wiëc nie wykasowany.
4.1:BíÜd podczas dostëpu do pliku lst!
4.2:Limit dirlist osiÜgniëty. Katalog %s nie zostanie usuniëty!
4.3:Brak pamiëci! Nie zapamiëtano katalogu %s!
4.4:usuwanie %s
4.5:Pakiet %s zostaí usuniëty.


#### Searching package ####
5.0:°aden pakiet nie pasuje do wyszukiwania.
5.1:Brak pamiëci podczas przetwarzania opisu pakietu!


#### Package database handling ####
6.0:BíÜd: Nieprawidíowy plik indeksu (bíëdny nagí¢wek)! Repozytorium zignorowane.
6.1:BíÜd: Nieprawidíowy plik indeksu! Repozytorium zignorowane.
6.2:BíÜd: Brak pamiëci podczas íadowania bazy danych!
6.3:BíÜd: Nie zdoíano otworzyç pliku danych '%s'.
6.4:Uwaga: Nie zdoíano otworzyç pliku pamiëci podrëcznej %s!


#### Loading configuration ####
7.0:BíÜd: repozytorium '%s' jest skonfigurowane dwa razy!
7.1:BíÜd: nie zdoíano otworzyç pliku konfiguracyjnego '%s'!
7.2:Uwaga: token bez wartoûci w linii #%d
7.3:Uwaga: zbyt díugi token konfiguracyjny w linii #%d
7.4:Uwaga: token z pustÜ wartoûciÜ w linii #%d
7.5:Uwaga: spacja po wartoûci w linii #%d
7.6:Odrzucono repozytorium: zbyt wiele skonfigurowanych (maks=%d)
7.8:Uwaga: Nieznany token '%s' w linii #%d
7.9:Uwaga: zbyt díuga wartoûç w pliku konfiguracyjnym w linii #%d
7.10:Uwaga: Nieprawidíowa wartoûç '%s' w linii #%d
7.11:Uwaga: Nieprawidíowe polecenie 'DIR' w linii #%d
7.12:BíÜd: za díuga ûcießka DIR w linii #%d
7.13:BíÜd: NieistniejÜca zmienna ûrodowiskowa '%s' w linii #%d
7.14:BíÜd: repozytorium '%s' jest skonfigurowane dwa razy!
7.15:BíÜd: katalog specjalny '%s' nie jest prawidíowÜ ûcießkÜ!
7.16:BíÜd: katalog specjalny '%s' jest zarezerwowanÜ nazwÜ!


#### Unziping package ####
8.0:Brak pamiëci!
8.1:nieznana sygnatura zip: 0x%08x
8.2:BíÜd: Pakiet zawiera plik skompresowany nieznanÜ metodë (%d):
8.3:BíÜd podczas rozpakowywania '%s' do '%s'!


#### Handling the local list of installed packages ####
9.0:BíÜd: Dostëp do katalogu %s nie powi¢dí sië.
9.1:BíÜd: Nie znaleziono lokalnego pakietu %s.


#### Package updates ####
10.0:%s (wersja lokalna: %s)
10.1:wersja %s pod %s
10.2:Nie znaleziono aktualizacji dla pakietu '%s'.
10.3:Znaleziono aktualizacjë dla pakietu '%s'. Aktualizacja w toku...
10.4:sprawdzono %d pakiet¢w, zaktualizowano %d pakiet¢w, %d bíëdnych pakiet¢w.
10.5:znaleziono aktualizacje dla %d pakiet¢w.


#### Downloading ####
11.0:ûciÜganie %s... %ld bajt¢w
