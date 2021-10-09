; Duke Nukem 3D Modem String File
; Version 1.3D File - April 1996
;
; Duke Nukem 3D is (c) 3D Realms Entertainment
; 3D Realms is a division of Apogee Software, Ltd.
;
; Duke Nukem 3D uses advanced modem code, and does not require the use of an
; init string for most modems out there.  If, however, you find you require
; the use of an init string, you can place it in this file.
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
; If your modem does not work with the default of ATZ, you will have to make
; your own init string.  In that case, follow these rules when making your own
; init string:
;
; 1) Turn off Data Compression.
; 2) Turn off Error Correction.
;
; Info on how to do this will be in your modem's manual.  Please do not contact
; 3D Realms for help in setting up an init string, we cannot assist with this.
;

Default String
AT Z
AT Z H0

Acubit 14.4 fax v32
AT &F &C1 &D2 %C0 \N1
AT Z H0

AT&T Data Port 14.4 FaxM.
AT &F &C1 &D2 S41=3 \N0 %C0
AT Z H0

ATI 9600 ETC-E Internal v.32
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Boca #1
AT &F &C1 &D2 S46=0 N0 &D2 &K0
AT Z H0

Boca #2
AT &F &C1 &D2 \N0 \G0 &K0 %C0 N0
AT Z H0

Cardinal 14.4
AT &F &C1 &D2 N0
AT Z H0

Cardinal
AT &F &C1 &D2 &Q6 &K0 %C0 \N0 N0
AT Z H0

Creative Labs Modem Blaster
AT &F &K0 %E0 \G0 \N0
AT Z H0

Digicom Scout Plus 14.4 Fax
AT &F &C1 &D2 *M0 *E0
AT Z H0

Gateway Telepath fax
AT &F &C1 &D2 B0 N0 \N0 %C0 &K0
AT Z H0

Gateway Telepath 550
AT &F &C1 &D2 S27=32 S15=16 S13=64 &B0 &H2 &I1 &K0 &M0
AT Z H0

Generic Hayes Compatible
AT Z
AT Z H0

GVC 14.4 fax
AT &F &C1 &D2 S46=0 N0 &K0
AT Z H0

Hayes Optima/Accura External 144 v.32bis
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Hayes Optima/Accura External 28.8
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

Identity Internal
AT &F &C1 &D2 B8 %C0 \Q0 \N1
AT Z H0

Infotel 14.4
AT &F &C1 &D2 &Q6 %C0 N0 &K0
AT Z H0

Intel #1
AT &F &C1 &D2 \N0 \Q0 \J1 \V0
AT Z H0

Intel #2
AT &F N0 &D2 &C1 &Q6 &K0 S0=1
AT Z H0

MegaHertz C596FM
AT &F &C1 &D2 \N1 \J0 %C0
AT Z H0

Practical Peripherals PM14400FXMT v.32bis
AT Z S46=0 &Q0 &D2
AT Z H0

Practical Peripherals PM14400FXSA v.32bis
AT Z S46=0 &Q0 &D2
AT Z H0

Practical Peripherals 14.4
AT Z S46=0 &Q0 &D2
AT Z H0

Rockwell 14.4
AT &F &C1 &D2 N0 S46=0 &K0 %C0
AT Z H0

Smart One 1442F
AT &F &C1 &D2 %C0 &K0 S95=44 S46=0
AT Z H0

Supra Fax 288 v.fc
AT &F &C1 &D1 &K0 &Q6 S36=3
AT Z H0

SupraFax #1
AT &F &C1 &D2 &Q6 &K %C0 \N1 S37=6 S0=1
AT Z H0

SupraFax #2
AT &F &C1 &D2 S46=136 %C0
AT Z H0

SupraFax #3
AT &F &C1 &D2 S46=136 M1 Q0 D2
AT Z H0

Telebit Worldblazer
AT &F &C1 &D2 S51=4 S180=0 S183=8 S190=0 L1
AT Z H0

Telepath 550
AT &F &C1 &D2 &M0 &K0 S0=1
AT Z H0

USRobotics Sportster External
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

USRobotics Sportster Internal
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

USRobotics 16.8 HST/Dual Standard
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

USRobotics V.Everything
AT &F &K0 &H0 &I0 &M0 &D1
AT Z H0

Viva 14.4 #1
AT &F &C1 &D2 \N0
AT Z H0

Viva 14.4 #2
AT &F &C1 &D2 \N0 \Q0 \J1 \VI
AT Z H0

VivaFax #3
AT &F &C1 &D2 N0 \N1 %C0 &K0
AT Z H0

VivaFax #4
AT &F &C1 &D2 \Q0 &M0 %C0 B8 \N1
AT Z H0

ZOOM 14.4 #1
AT &F &C1 &D2 &K0 &Q6 %C0 \G0 \N0 S46=136
AT Z H0

ZOOM 14.4 #2
AT &F &C1 &D2 &K0 &Q6 %C0 \G0 \N0 S46=136
AT Z H0

ZyXel U-1496B v.32bis
AT Z S46=0 &D2 &K0
AT Z H0
