# FDNPKG language file
#
# Language..: Slovene
# Translator: Matej Horvat (http://matejhorvat.si/)
# Updated...: 2015-08-17
# Codepage..: 852

#### Help ####

1.0:To je internetni upravitelj paketov za FreeDOS.
1.1:Uporaba: FDNPKG dejavnost [parametri]
1.2:kjer je dejavnost ena od sledeŸih:
1.3: SEARCH [niz]          PoiçŸe paket, ki vsebuje niz v internetnih zbirkah
1.4: VSEARCH [niz]         Enako kot SEARCH, a izpiçe çe pakete z izvorno kodo
1.5: INSTALL paket         Namesti §eljeni paket oz. lokalno ZIP datoteko
1.6: REMOVE paket          Odstrani paket
1.7: DUMPCFG               Izpiçe nastavitve
1.8: LICENSE               Izpiçe licenco tega programa
1.9:FDNPKG uporablja sledeŸo verzijo WatTCP:
1.10: INSTALL-NOSRC paket   Enako kot INSTALL, toda ne namesti izvorne kode
1.11: INSTALL-WSRC paket    Enako kot INSTALL, toda namesti izvorno kodo
1.12: SHOWINSTALLED [niz]   Izpiçe nameçŸene pakete, ki vsebujejo niz
1.13: CHECKUPDATES          Preveri, ali obstajajo posodobitve, in jih izpiçe
1.14: UPDATE                Posodobi vse pakete na najnovejço verzijo
1.15: UPDATE paket          Posodobi doloŸen paket na najnovejço verzijo
1.16: LISTLOCAL [niz]       Izpiçe nameçŸene pakete, ki vsebujejo niz
1.17: FDNPKG uporablja sledeŸo verzijo Watt-32:
1.18: LISTFILES paket       Izpiçe datoteke, ki pripadajo paketu


### General stuff ####

2.0:Spremenljivka TEMP ni nastavljena! Ka§e naj na imenik, kamor se da pisati.
2.1:Primer: SET TEMP=C:\TEMP
2.2:Spremenljivka DOSDIR ni nastavljena! Ka§e naj na glavni imenik FreeDOSa.
2.3:Primer: SET DOSDIR=C:\FDOS
2.4:Neveljavno çtevilo parametrov. Za§enite FDNPKG brez parametrov za pomoŸ.
2.5:Nastavljena ni nobena zbirka. Potrebujete vsaj eno.
2.6:V nastavitveno datoteko dodajte vsaj en vnos sledeŸe oblike:
2.7:REPO www.freedos.org/repo
2.8:Trenutno nastavljene zbirke za FDNPKG:
2.9:Osve§ujem %s...
2.10:Prenos zbirke ni uspel!
2.11:Ni bilo mogoŸe prebrati zbirke iz zaŸasne datoteke.
2.12:Opozorilo: %TZ% ni nastavljena. ¬asi novih datotek morda ne bodo toŸni.
2.13:Baza paketov nalo§ena iz predpomnilnika.
2.14:Ni dovolj spomina! (%s)
2.15:Napaka: Zagon TCP/IP ni uspel!
2.16:Prenaçam %s...
2.17:OPOZORILO: Navideznega pomnilnika je malo. FDNPKG morda ne bo deloval prav.
2.18:NAPAKA: Ni mogoŸe pisati v imenik %s. Preverite svojo spremenljivko TEMP.


#### Installing package ####

3.0:Paket %s je §e nameçŸen. ¬e ga §elite posodobiti, ga najprej odstranite.
3.1:Paketa %s ni mogoŸe najti v internetnih zbirkah.
3.2:Paketa %s ni v zbirkah.
3.3:%s je na voljo v veŸ kot eni zbirki. Izberite eno:
3.4:Vaça izbira:
3.5:Neveljavna izbira!
3.6:Prenaçam paket %s...
3.7:Napaka pri prenosu paketa. Prenos prekinjen.
3.8:Napaka: Neveljavna ZIP datoteka! Paketa ni mogoŸe namestiti.
3.9:Napaka: Paket vsebuje datoteko, ki §e obstaja na tem raŸunalniku:
3.10:Napaka: Ni mogoŸe ustvariti %s.
3.11:Paket %s nameçŸen.
3.12:Napaka: Paket ne vsebuje datoteke %s; to ni veljaven FreeDOS paket.
3.13:Napaka: Preneçen paket ima napaŸen CRC. Namestitev prekinjena.
3.14:Napaka: Ni mogoŸe odpreti preneçenega paketa. Namestitev prekinjena.
3.15:Napaka: Ni dovolj spomina za izraŸun CRC vrednosti paketa.
3.16:Paket %s nameçŸen (z izvorno kodo, Ÿe je ta prilo§ena).
3.17:Paket %s nameçŸen (brez izvorne kode).
3.18:Paket %s je §e nameçŸen! Morda §elite uporabiti dejavnost UPDATE.
3.19:Paket %s nameçŸen: %d datotek razçirjenih, %d napak.
3.20:Napaka: paket vsebuje çifrirano datoteko:
3.21:Napaka: ni mogoŸe odpreti povezovalne datoteke %s za branje.
3.22:Napaka: ni mogoŸe odpreti povezovalne datoteke %s za pisanje.


#### Removing package ####
4.0:Paket %s ni nameçŸen, zato ga ni mogoŸe odstraniti.
4.1:Ni mogoŸe odpreti datoteke LST.
4.2:Dose§ena omejitev dol§ine seznama imenikov. Imenik %s ne bo odstranjen!
4.3:Ni dovolj spomina. Ni mogoŸe shraniti imenika %s!
4.4:odstranjujem %s
4.5:Paket %s odstranjen.


#### Searching package ####
5.0:Noben paket ne ustreza iskalnim zahtevam.
5.1:Ni dovolj spomina za procesiranje opisov paketov!


#### Package database handling ####
6.0:Napaka: Neveljavno kazalo (napaŸna glava). Zbirka bo preskoŸena.
6.1:Napaka: Neveljavno kazalo. Zbirka bo preskoŸena.
6.2:Napaka: Ni dovolj spomina za bazo paketov!
6.3:Napaka: Ni mogoŸe odpreti datoteke %s.
6.4:Opozorilo: Ni mogoŸe odpreti predpomnilne datoteke %s.


#### Loading configuration ####
7.0:Napaka: Zbirka %s je naçteta dvakrat!
7.1:Napaka: Ni mogoŸe odpreti nastavitvene datoteke %s.
7.2:Warning: token without value on line #%d
7.3:Warning: Config file token overflow on line #%d
7.4:Warning: token with empty value on line #%d
7.5:Opozorilo: nevidni znaki na koncu vrstice çt. %d
7.6:Vsaj ena zbirka je bila izpuçŸena; preveŸ jih je naçtetih (omejitev je %d).
7.8:Warning: Unknown token '%s' at line #%d
7.9:Warning: Config file value overflow on line #%d
7.10:Opozorilo: Vrednost "%s" v vrstici çt. %d prezrta.
7.11:Opozorilo: Neveljaven ukaz DIR v vrstici %d.
7.12:Napaka: Pot DIR v vrstici çt. %d je predolga.
7.13:Napaka: Okoljska spremenljivka %s, omenjena v vrstici çt. %d, ne obstaja.
7.14:Napaka: Zbirka %s je naçteta dvakrat!
7.15:Error: custom dir '%s' is not a valid absolute path!
7.16:Error: custom dir '%s' is a reserved name!


#### Unziping package ####
8.0:Ni dovolj spomina!
8.1:Neznana vrsta datoteke ZIP: 0x%08x
8.2:Napaka: Paket vsebuje datoteko, ki je stisnjena z nepodprto metodo (%d):
8.3:Napaka med razçirjanjem %s v %s!


#### Handling the local list of installed packages ####
9.0:Napaka: Dostop do imenika %s ni mogoŸ.
9.1:Napaka: Ni mogoŸe najti lokalnega paketa %s.


#### Package updates ####
10.0:%s (nameçŸena verzija %s)
10.1:verzija %s na %s
10.2:Za paket %s ni posodobitve.
10.3:Obstaja posodobitev za paket %s. Posodobitev poteka...
10.4:%d paketov pregledanih, %d paketov posodobljenih, %d napak.
10.5:Najdenih %d posodobitev.


#### Downloading ####
11.0:Prenaçam %s... %ld bajtov
