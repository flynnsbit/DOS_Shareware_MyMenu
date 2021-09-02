#Translated by Mateusz Viste "Fox" / mateusz.viste@mail.ru
#Polish letters encoded in the MAZOVIA standard
#Homepage: http://www.the.killer.webpark.pl
#
# fatal errors
0.0:Brak pamiëci. Brakuje %ld bajt¢w.\n
0.1:PAMIêï SYSTEMOWA ROZBITA! (bíÜd int 21.5803)\n
0.2:UMB Corruption: Chain doesn't reach top of low RAM at %dk. Last=0x%x.\n
0.3:The MCB chain is corrupted (no Z MCB after last M MCB, but %c at seg 0x%x).\n
0.4:Nieznany parametr: %s\nUßyj /? aby uzyskaç pomoc\n
0.5:nieznana opcja: %s\n%s
0.6:The /NOSUMMARY option was specified, but no other output-producing options\nwere specified, so no output is being produced.\n%s
0.7:Fatal error: failed to free HMA, error code %02Xh\n
0.8:nieznana opcja (oczekiwano '/'): %s\n%s
0.9:Oczekiwano jakiejû wartoûci po /%s, a nie kolejnego parametru\n%s
0.10:Internal error: option '%s' has '%s' as a prefix\nplus another equal-length prefix
0.11:Internal error: option '%s' was an exact match for two\ndifferent switches\n
0.12:Error: option '%s' is ambiguous - it is a partial match for two\nor more different options\n%s
0.13:Oczekiwano jakiejû wartoûci po /%s\n%s
0.14:Niepoprawna opcja '%s': naleßy podaç conajmniej pierwszÜ literë nazwy opcji
# misc messages
1.0:Nieznany system operacyjny
1.1:%lu bajt¢w\n
1.2:(%s bajt¢w)\n
1.3: (%7s bajt¢w)\n
1.4:Ostrzeßenie: urzÜdzenie zdaje sië naleßeç do paru blok¢w pamiëci (%s\ni %s)\n
1.5:(no drv)
1.6:Brak wolnej pamiëci %s \n
1.7:%s nie jest obecnie w pamiëci.\n
1.8:%s ußywa nastëpujÜcej pamiëci:\n
1.9:%s Memory is not accessible\n
# memory types
2.0:Typ pamiëci         Suma      Ußytej     Wolnej\n
#   ----------------  --------   --------   --------
2.1:Konwencjonalna
2.2:UMB
2.3:Zarezerwowana
2.4:XMS
2.5:Caíkowita pamiëç
2.6:Ponißej 1 MB
2.7:Caíkowitej EMS
2.8:Wolnej EMS
2.9:Najwiëkszy moßliwy program wykonyw.
2.10:Najwiëkszy wolny blok pamiëci UMB
2.11:%s rezyduje w pamiëci UMB.\n
2.12:Dostëpne miejsce w pamiëci HMA
2.13:HMA is available via the XMS driver\n
2.14:HMA is not available via the XMS driver: not implemented by the driver\n
2.15:HMA is not available via the XMS driver: a VDISK device is present\n
2.16:HMA is not available via the XMS driver: HMA does not exist\n
2.17:HMA is not available via the XMS driver: HMA already in use\n
2.18:HMA is not available via the XMS driver: HMAMIN is larger than HMA\n
2.19:HMA is available via the XMS driver, minimum TSR size (HMAMIN): %u bytes\n
2.20:HMA is not available via the XMS driver: unknown error %02Xh\n
2.21:HMA is not available as no XMS driver is loaded\n
2.22:Memory accessible using Int 15h
2.23:Memory is not accessible using Int 15h (code %02xh)\n
# block types
3.0:
3.1:wolna
3.2:kod systemowy
3.3:dane systemowe
3.4:program
3.5:ûrodowisko
3.6:pole danych
3.7:zarezerwowane
3.8:tablica przerwa§
3.9:pole danych BIOS
3.10:system data
3.11:sterownik urzÜdzenia
3.12:obszar danych
3.13:IFS
3.14:(bíÜd)
# classify msgs
4.0:\nModuíy ußywajÜce pamiëci ponißej 1 MB:\n\n
4.1:  Nazwa          Razem          Konwencjonalna       Pamiëç UMB\n
#     --------  ----------------   ----------------   ----------------
4.2:SYSTEM
4.3:Wolna
4.4:\nSegment    Rozmiar caík.      Nazwa           Typ\n
#     -------  ----------------  ------------  -------------
4.5:\n    Adres     Atryb.   Nazwa      Program\n
#      -----------  ------ ----------  ----------
4.6:\nSegment       Razem\n
#     -------  ----------------
#            ----------------
4.7:Razem:
4.8:sterownik urzÜdzenia systemowego\n
4.9:zainstalowane DEVICE=%s\n
4.10:%s Szczeg¢íy pamiëci:\n
4.11:Wolna pamiëç %s:\n
4.12: (%u w tym bloku)

# EMS stuff
5.0:WEWNêTRZNY BúèD EMS.\n
5.1:W systemie brak obecnie sterownika EMS.\n
5.2:\nWersja sterownika EMS
5.3:Ramka strony EMS
5.4:Caíkowita pamiëç EMS
5.5:Wolna pamiëç EMS
5.6:Wszystkich uchwyt¢w
5.7:Wolnych uchwyt¢w
5.8:\n  Uchwyt  Strony   Rozmiar     Nazwa\n
#      -------- ------  --------   ----------
# XMS stuff
6.0:Sterownik XMS nie jest zainstalowany w systemie.\n
6.1:\nTestowanie pamiëci XMS...\n
6.2:WEWNêTRZNY BúèD XMS.\n
6.3:INT 2F AX=4309 wspierane\n
6.4:Wersja XMS
6.5:Wersja sterownika XMS
6.6:status HMA
6.7:jest
6.8:nie ma
6.9:status linii A20
6.10:wíÜczone
6.11:wyíÜczone
6.12:Wolna pamiëç XMS
6.13:Najwiëkszy wolny blok XMS
6.14:Wolnych uchwyt¢w
6.15: Blok    Uchwyt    Rozmiar   Locks\n
#    ------- --------  --------  -------
6.16:Wolna pamiëç UMB
6.17:Najwiëkszy wolny blok UMB
6.18:Pamiëç UMB niedostëpna\n
# help message
7.0:FreeDOS MEM wersja %d.%d\n
7.1:Wyûwietla rozmiar wolnej i ußytej pamiëci w systemie.
7.2:Skíadnia: MEM [zero lub wiëcej opcji opisanych ponißej]
7.3:/E          Wyûwietla wszystkie informacje na temat pamiëci EMS
7.4:/F          Przedstawia peínÜ listë blok¢w pamiëci
7.5:/C          Klasyfikuje moduíy korzystajÜce z pamiëci ponißej 1 MB
7.6:/DEVICE     Wyûwietla listë sterownik¢w obecnych w pamiëci
7.7:/U          Wyûwietla listë program¢w w pamiëci konwencjonalnej i UMB
7.8:/X          Wyûwietla wszystkie informacje na temat pamiëci XMS
7.9:/P          Zatrzymuje sië po kaßdym peínym ekranie
7.10:/?          Wyûwietla niniejszÜ pomoc
7.11:/DEBUG      Wyûwietla programy i sterowniki w pamiëci konwencjonalnej i UMB
7.12:/M <nazwa> | /MODULE <nazwa>\n            Wyûwietla iloûç pamiëci ußytej przez podany program lub sterownik
7.13:/FREE       Wyûwietla wolnÜ pamiëç konwencjonalnÜ i UMB (wyßsze bloki pamiëci)
7.14:/ALL        Wyûwietla szczeg¢íy o HMA (wysoki obszar danych)
7.15:/NOSUMMARY  Nie wyûwietla podsumowania kt¢re normalnie ukazuje sië jeûli\n            nie podano ßadnych opcji
7.16:/SUMMARY    Neguje opcjë /NOSUMMARY
7.17:/%-10s Brak pomocy dla tej opcji\n
7.18:/OLD        Kompatybilnoûç z FreeDOS MEM 1.7 beta
7.19:/D          Odpowiednik /DEBUG, chyba ße ußyto /OLD, to odpowiednik /DEVICE
7.20:/F          Odpowiednik /FREE, chyba ße ußyto /OLD, to odpowiednik /FULL
8.0:\nNaciûnij <Enter> aby kontynuowaç lub <Esc> by zako§czyç...
# Memory type names
9.0:Konwencjonalna
9.1:UMB
9.2:(bíÜd)
