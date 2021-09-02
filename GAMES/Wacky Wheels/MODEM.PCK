; Wacky Wheels Modem String File
; Revision 1 - October 17th, 1994
;
; Wacky Wheels is (c) 1994 Apogee Software, Ltd / Beavis Soft
;
; This file is periodically updated with new strings.  If you are interested
; in obtaining the latest list of strings, please contact Apogee online.
; The contact addresses are available in the WW-HELP.EXE file that accompanies
; this game.  You can also check this file for information on getting on the
; Apogee Modem Players Directory!
;
; You can add your own strings if you so desire.  If you do this, however, you
; must follow the format of this file, or you may not be able to properly pick
; any modems at all.  Editing rules:
;
; 1) Line #1 is the name of the modem you wish to use
; 2) Line #2 is the initialization string.  We urge you to use &F before any
;    other commands.  This will restore the modem to factory defaults on most
;    every Hayes compatible modem out there.  Check your manual to ensure that
;    &F is the factory default command on your modem.
; 3) The third line is the hangup command.
; 4) The fourth line is blank.  The blank line is important.
; 5) Anything that starts with a semicolon (;) is ignored.
;
; ---------------------------------------------------------------------------
; Tested Strings
; ---------------------------------------------------------------------------
;
; The modems listed in this section of the file were actually used by Apogee
; Software during the testing of this game.  They worked for us, and they
; should work for you without any further intervention besides picking them
; in the SETUP.EXE program that comes with Wacky Wheels.  If you run into
; trouble, please check the WW-HELP.EXE file that comes with Wacky Wheels.
;

ATI 9600 ETC-E Internal v.32
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Hayes Optima/Accura 144 v.32bis
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Hayes Optima/Accura 288 v.fc
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Practical Peripherals 14.4
AT Z S46=0 &Q0 &D2
AT Z H0

Practical Peripherals PM14400FXMT v.32bis
AT Z S46=0 &Q0 &D2
AT Z H0

Practical Peripherals PM14400FXSA v.32bis
AT Z S46=0 &Q0 &D2
AT Z H0

Supra Fax 288 v.fc
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

; The USRobotics Sportster modem will sometimes require use of the
; Interbyte delay in the SETUP.EXE program.  Please see WW-HELP.EXE
; for more information on the interbyte delay.
;
USRobotics Sportster 14.4 Internal
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

USRobotics Sportster 14.4 Test #2
AT Z &K0 &M0 &D2 E1 V1 X4
AT Z H0

USRobotics 14.4 fax Test #3
AT S0=1 S7=60 E1 Q0 V1 &C1 &D2 &K0 &N6 &A3
AT Z H0

USRobotics 16.8 HST/Dual Standard
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

USRobotics V.Everything
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

ZyXel U-1496B v.32bis
AT Z S46=0 &D2 &K0
AT Z H0

; ---------------------------------------------------------------------------
; Untested Strings
; ---------------------------------------------------------------------------
;
; The modems in this section were not actually tested by Apogee during the
; testing of the game, but are provided as a start for owners of these modems.
; If you have difficulty in getting a modem to work properly and then do have
; success, please contact Apogee Online with this information, so it can be
; added to this configuration list for later revisions of the document.
;
;
Acubit 14.4 fax v32
AT Z S37=9 %C0 \N1
AT Z H0

AT&T Data Port 14.4 FaxM.
AT &F S41=3 %B9600 \N0 %C0
AT Z H0

Boca 14.4 fax
AT Z S46=0 N0 &Q0 &D2 &K0
AT Z H0

Boca 14.4 v32 fax
AT \N0 \G0 &K0 %C0 N0
AT Z H0

Cardinal 9600fax
AT &F &Q6 &K0 %C0 \N0 N0
AT Z H0

Cardinal 14.4 v32
AT &F &Q0 N0
AT Z H0

Digicom Scout Plus 14.4 Fax
AT Z *m0 *e0
AT Z H0

Gateway Telepath 14.4 fax
AT &F B0 N0 \N0 %C0 &K0
AT Z H0

Gateway Telepath 550
AT &F S27=32 S15=16 S13=64 &B0 &H2 &I1 &N6 &K0 &M0
AT Z H0

GVC 14.4 MNP2-5 v42
AT &F %C0 \N0 B8
AT Z H0

GVC 14.4 fax
AT Z S46=0 N0 &Q0 &D2 &K0
AT Z H0

Identity Internal
AT &F B8 %C0 \Q0 \N1
AT Z H0

Infotel 14.4
AT &Q6 %C0 N0 &K0
AT Z H0

Intel 14.4
AT &F \N0 \Q0 \J1\V0
AT Z H0

Intel 14.4i
AT B8 %C0 "H0 \N0 \Q0
AT Z H0

Intel 14.4 ext
AT\N0/Q0
AT Z H0

Intel 14.4 fax
AT &F N0 &D2 &C1 &Q6 &K0 S0=1
AT Z H0

MegaHertz C596FM
AT &F \N1 \J0 &Q0 %C0
AT Z H0

Redicard v.32 bis 14.4
AT %C & \N
AT Z H0

Smart One 1442F
AT Z %C0 &Q0 &K0 &D2 S95=44 S46=0
AT Z H0

SupraFax 14.4
AT &Q6 &K %C0 \N1 S37=6 S0=1
AT Z H0

SupraFax 14.4 v32
AT &F0 S46=136 %C0
AT Z H0

SupraFax 14.4 v32-
AT &F S46=136 M1 Q0 D2
AT Z H0

Telebit Worldblazer 14.4
AT S51=4 S180=0 S183=8 S190=0 L1
AT H

Telepath 550
AT Z &N6 &M0 &K0 S0=1
AT Z H0

ZOOM 14.4 v32 v42 fax
AT &F N0 &D2 &C1 &Q6 &K0 S0=1
AT Z H0

ZOOM VFX v32
AT &K0 &Q0 &D2 E1 V1 X4 N0 &Q0
AT Z H0

VivaFax 14.4
AT\Q0 &M0 %C0 B8 \N1
AT Z H0

VivaFax 14.4
AT &F &C1 &D2 N0 \N1 %C0 &K0
AT Z H0

Viva 14.4i fax
AT\N0\Q0\J1\VI
AT Z H0

ZOOM VFP 14.4
AT &K0 &Q0 &D2 E1 V1 X4 N0
AT Z H0

ZOOM 14.4
AT N0 S46=136 %C0 &Q0 \G0
AT Z H0

ZOOM VXP 14.4 v42
AT &F &K0 &M0 &Q0 &D0 &C0 \G0 %C0
AT Z H0
