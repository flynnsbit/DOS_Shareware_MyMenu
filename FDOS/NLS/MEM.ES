# fatal errors
0.0:No hay memoria suficiente. Se requieren %ld bytes m s.\n
0.1:LA MEMORIA DEL SISTEMA EST CORRUPTA (fallo en int 21.5803)\n
0.2:Cadena de MCBs corrupta: no llega al tope de la TPA en %dk (£ltimo=0x%x)\n
0.3:Cadena de MCBs corrupta: sin MCB Z tras el £ltimo M (es %c, en seg 0x%x)\n
0.4:Use /? para la ayuda\n
0.5:Opci¢n desconocida: %s\n%s
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
1.0:Sistema operativo desconocido
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
2.0:Tipo de memoria    Total       Usado     Libre\n
#   ----------------  --------   --------   --------
2.1:Convencional
2.2:Superior
2.3:Reservada
2.4:Extendida (XMS)
2.5:Memoria total
2.6:Total bajo 1 MB
2.7:Total Expandida (EMS)
2.8:Libre Expandida (EMS)
2.9:Tama¤o de programa ejecutable m s grande
2.10:Bloque de memoria superior libre m s grande
2.11:%s reside en memoria alta (HMA).\n
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
3.1:libre
3.2:c¢digo sistema
3.3:datos sistema
3.4:programa
3.5:entorno    
3.6: rea de datos
3.7:reservada
# FIXME: to be translated
3.8:interrupt vector table
# FIXME: to be translated
3.9:BIOS data area
# FIXME: to be translated
3.10:system data
3.11:controlador
# FIXME: to be translated
3.12:data area
3.13:IFS
# FIXME: to be translated
3.14:(error)
# classify msgs
4.0:\nM¢dulos que usan memoria bajo 1 MB:\n\n
4.1:  Nombre         Total           Convencional        Superior\n
#     --------  ----------------   ----------------   ----------------
4.2:SISTEMA
4.3:Libre
4.4:\nSegmento      Total           Nombre         Tipo\n
#     -------  ----------------  ------------  -------------
4.5:\n  Direcci¢n   Atrib.   Nombre     Programa\n
#      -----------  ------ ----------  ----------
4.6:\nSegmento      Total\n
#     -------  ----------------
#            ----------------
4.7:Total:
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
5.0:Error interno EMS.\n
5.1: No hay controlador EMS en el sistema.\n
5.2:Versi¢n del controlador EMS
5.3:Marco de p gina EMS
5.4:Total memoria EMS
5.5:Memoria EMS libre
5.6:Referencias (handles) totales
5.7:Referencias (handles) libres
5.8:\n  Handle  P ginas  Tama¤o     Nombre\n
#      -------- ------  --------   ----------
# XMS stuff
6.0:No hay controlador XMS instalado en el sistema.\n
6.1:\nComprobando la memoria XMS ...\n
6.2:Error interno XMS.\n
6.3:Se soporta INT 2F AX=4309\n
6.4:Versi¢n XMS
6.5:Versi¢n controlador XMS
6.6:Estado de HMA
6.7:existe
6.8:no existe
6.9:Estado de la l¡nea A20
6.10:habilitado
6.11:deshabilitado
6.12:Memoria XMS libre
6.13:Bloque libre XMS m s grande
6.14:Referencias (handles) libres
6.15: Bloque  Handle    Tama¤o  Bloqueos\n
#    ------- --------  --------  -------
6.16:Memoria superior libre
6.17:Bloque de memoria superior m s grande
6.18:No hay memoria superior disponible\n
# help message
7.0:FreeDOS MEM versi¢n %s
7.1:Muestra la cantidad de memoria ocupada y libre del sistema.
# FIXME: to be translated
7.2:Sintaxis: MEM [zero or more of the options shown below]
7.3:/E          Devuelve informaci¢n sobre memoria expandida (EMS)
7.4:/FULL       Listado completo de bloques de memoria
7.5:/C          Clasificar los m¢dulos de memoria en el primer MB
7.6:/DEVICE     Lista los controladores de dispositivo en memoria
7.7:/U          Lista los programas en memoria convencional y superior
7.8:/X          Devuelve informaci¢n sobre memoria extendida (XMS)
7.9:/P          Realiza una pausa despu‚s de cada pantalla completa
7.10:/?          Muestra este mensaje de ayuda
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
8.0:\nPulse <Enter> para continuar o <Esc> para salir . . .
# Memory type names
# FIXME: to be translated
9.0:Conventional
# FIXME: to be translated
9.1:Upper
# FIXME: to be translated
9.2:(error)
