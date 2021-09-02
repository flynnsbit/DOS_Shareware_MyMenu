# fatal errors
0.0:Geheugen is op. %ld meer bytes nodig.\n
0.1:SYSTEEMGEHEUGEN TRASHED! (int 21.5803 failure)\n
0.2:UMB Corruption: Ketting haalt de top van lage RAM bij %dk niet. Laatste=0x%x.\n
0.3:De MCB ketting is beschadigd (geen Z MCB na laatste M MCB, maar %c op seg 0x%x).\n
0.4:Use /? voor hulp\n
0.5:onbekende optie: %s\n%s
# FIXME: to be translated
0.6:The /NOSUMMARY option was specified, but no other output-producing options\nwere specified, so no output is being produced.\n%s
# FIXME: to be translated
0.7:Fatal error: failed to free HMA, error code %02Xh\n
# FIXME: to be translated
0.8:unknown option (expected a '/'): %s\n%s
# FIXME: to be translated
0.9:Expected a value after /%s, not another switch\n%s
# FIXME: to be translated
0.10:Internal error: option '%s' has '%s' as a prefix\nplus another equal-length prefix
# FIXME: to be translated
0.11:Internal error: option '%s' was an exact match for two\ndifferent switches\n
# FIXME: to be translated
0.12:Error: option '%s' is ambiguous - it is a partial match for two\nor more different options\n%s
# FIXME: to be translated
0.13:Expected a value after /%s\n%s
# FIXME: to be translated
0.14:Invalid option '%s': you must specify at least one letter of the\noption name
# misc messages
1.0:Een onbekend besturingssysteem
1.1:%s bytes\n
1.2:(%s bytes)\n
1.3: (%7s bytes)\n
# FIXME: to be translated
1.4:Warning: device appears to be owned by multiple memory blocks (%s\nand %s)\n
# FIXME: to be translated
1.5:(no drv)
# FIXME: to be translated
1.6:No %s Memory is free\n
# FIXME: to be translated
1.7:%s is not currently in memory.\n
# FIXME: to be translated
1.8:%s is using the following memory:\n
# FIXME: to be translated
1.9:%s Memory is not accessible\n
# memory types
2.0:Geheugentype       Totaal    Gebruikt     Vrij\n
#   ----------------  --------   --------   --------
2.1:Conventioneel
2.2:Boven
2.3:Gereserveerd
2.4:Uitgebreid (XMS)
2.5:Totaal geheugen
2.6:Totaal onder 1 MB
2.7:Totaal Vergroot (EMS)
2.8:Vrij Vergroot (EMS)
2.9:Grootste uitvoerbare programmagrootte
2.10:Grootste vrije bovengeheugenblok
2.11:%s is resident in het hoge geheugengebied (HMA).\n
# FIXME: to be translated
2.12:Available space in High Memory Area
# FIXME: to be translated
2.13:HMA is available via the XMS driver\n
# FIXME: to be translated
2.14:HMA is not available via the XMS driver: not implemented by the driver\n
# FIXME: to be translated
2.15:HMA is not available via the XMS driver: a VDISK device is present\n
# FIXME: to be translated
2.16:HMA is not available via the XMS driver: HMA does not exist\n
# FIXME: to be translated
2.17:HMA is not available via the XMS driver: HMA already in use\n
# FIXME: to be translated
2.18:HMA is not available via the XMS driver: HMAMIN is larger than HMA\n
# FIXME: to be translated
2.19:HMA is available via the XMS driver, minimum TSR size (HMAMIN): %u bytes\n
# FIXME: to be translated
2.20:HMA is not available via the XMS driver: unknown error %02Xh\n
# FIXME: to be translated
2.21:HMA is not available as no XMS driver is loaded\n
# FIXME: to be translated
2.22:Memory accessible using Int 15h
# FIXME: to be translated
2.23:Memory is not accessible using Int 15h (code %02xh)\n
# block types
3.0:
3.1:vrij
3.2:systeemcode
3.3:systeemgegevens
3.4:programma
3.5:omgeving
3.6:gegevensgebied
3.7:gereserveerd
# FIXME: to be translated
3.8:interrupt vector table
# FIXME: to be translated
3.9:BIOS data area
# FIXME: to be translated
3.10:system data
3.11:stuurprogramma
# FIXME: to be translated
3.12:data area
3.13:IFS
# FIXME: to be translated
3.14:(error)
# classify msgs
4.0:\nModules die geheugen onder 1 MB gebruiken:\n\n
4.1:  Naam           Totaal          Conventioneel      Bovengeheugen\n
#     --------  ----------------   ----------------   ----------------
4.2:SYSTEEM
4.3:Vrij
4.4:\nSegment       Totaal           Naam          Type\n
#     -------  ----------------  ------------  -------------
4.5:\n    Adres      Attr    Naam      Programma\n
#      -----------  ------ ----------  ----------
4.6:\nSegment       Totaal\n
#     -------  ----------------
#            ----------------
4.7:Totaal:
# FIXME: to be translated
4.8:system device driver\n
# FIXME: to be translated
4.9:installed DEVICE=%s\n
# FIXME: to be translated
4.10:%s Memory Detail:\n
# FIXME: to be translated
4.11:Free %s Memory:\n
# FIXME: to be translated
4.12: (%u in this block)
# EMS stuff
5.0:EMS INTERNE FOUT.\n
5.1:  EMS stuurprogramma niet geinstalleerd in het systeem.\n
5.2:EMS stuurprogramma versie
5.3:EMS pagina lijst
5.4:Totaal EMS-geheugen
5.5:Vrij EMS-geheugen
5.6:Totale hendels
5.7:Vrije hendels
5.8:\n  Hendel  Pagina's Grootte      Naam\n
#      -------- ------  --------   ----------
# XMS stuff
6.0:XMS stuurprogramma niet geinstalleerd in het systeem.\n
6.1:\nTesten van het XMS geheugen ...\n
6.2:XMS INTERNE FOUT.\n
6.3:INT 2F AX=4309 ondersteund\n
6.4:XMS versie
6.5:XMS stuurprogramma versie
6.6:HMA status
6.7:bestaat
6.8:bestaat niet
6.9:A20 lijn status
6.10:aangeschakeld
6.11:uitgeschakeld
6.12:Vrij XMS-geheugen
6.13:Grootste vrije XMS blok
6.14:Vrije hendels
6.15: Blok    Hendel    Grootte   Sloten\n
#    ------- --------  --------  -------
6.16:Vrij bovengeheugen
6.17:Grootste bovenblok
6.18:Bovengeheugen niet beschikbaar\n
# help message
7.0:FreeDOS MEM versie %s
7.1:Laat de hoeveelheid gebruikt en vrij geheugen in uw systeem zien.
# FIXME: to be translated
7.2:Syntaxis: MEM [zero or more of the options shown below]
7.3:/E          Geeft alle informatie over Vergroot Geheugen (EMS)
7.4:/FULL       Volledige lijst van geheugenblokken
7.5:/C          Classificeer modules die geheugen onder 1 MB gebruiken
7.6:/DEVICE     Lijst van stuurprogramma's die nu in het geheugen zijn
7.7:/U          Lijst van programma's in conventioneel- en bovengeheugen.
7.8:/X          Geeft alle informatie over Uitgebreid Geheugen (XMS)
7.9:/P          Pauzeert na ieder scherm vol met informatie
7.10:/?          Laat deze hulpmelding zien
# FIXME: to be translated
7.11:/DEBUG      Show programs and devices in conventional and upper memory
# FIXME: to be translated
7.12:/M <name> | /MODULE <name>\n            Show memory used by the given program or driver
# FIXME: to be translated
7.13:/FREE       Show free conventional and upper memory blocks
# FIXME: to be translated
7.14:/ALL        Show all details of high memory area (HMA)
# FIXME: to be translated
7.15:/NOSUMMARY  Do not show the summary normally displayed when no other\n            options are specified
# FIXME: to be translated
7.16:/SUMMARY    Negates the /NOSUMMARY option
# FIXME: to be translated
7.17:/%-10s No help is available for this option\n
# FIXME: to be translated
7.18:/OLD        Compatability with FreeDOS MEM 1.7 beta
# FIXME: to be translated
7.19:/D          Same as /DEBUG by default, same as /DEVICE if /OLD used
# FIXME: to be translated
7.20:/F          Same as /FREE by default, same as /FULL if /OLD used
# paging message
8.0:\nDruk op <Enter> om door te gaan of op <Esc> om weg te gaan . . .
# Memory type names
# FIXME: to be translated
9.0:Conventional
# FIXME: to be translated
9.1:Upper
# FIXME: to be translated
9.2:(error)
