      PAGE 55,132
      TITLE CUTPASTE 4.0                                               ; WARREN
;
; CUTPASTE -
;      Permission is granted to copy and distribute freely copies of this
;      program with the following restrictions:
;
;      1) this program be passed in the public domain
;      2) a fee, beyond the cost of the disk, not be charged
;      3) improvements under the name of CUTPASTE not be passed on 
;         but rather sent to us to check for possible incompatibilities 
;         with other programs
;
;   Larry Weiss, Gerry Boyd, (Stephen) Randy Davis
;   (214) 238-9545  POB 831420 Richardson, Texas 75083           

; version 4.0 differs from 3.0 only in that the cursor position is NOT ; WARREN
;   modified on entry.  This was because of a request by Robert Warren ; WARREN
;   for such a version. See the comments marked WARREN.                ; WARREN
      
;PARAMETERS -- MOST OF THESE MAY BE CHANGED TO ANY DESIRED VALUE

wndw_ht    equ 25             ;the size of the screen
wndw_wd    equ 80
cut_key    equ  07000H        ;scan code - ascii of cut (Alt-F9)
paste_key  equ  06600H        ;scan code - ascii of paste (Cntrl-F9)
                                ;now scan codes of edit keys
up_arrow   equ  4800H
down_arrow equ  5000H
left_arrow equ  4B00H
right_arrow equ 4D00H
del_left   equ  0008H         ;user rubout (^H) key
delete     equ  5300H         ;use del (lower right)
insert     equ  5200H
cr         equ  000DH
home       equ  4700H
escape     equ  001BH
tab        equ  7400H         ; ^right arrow
rev_tab    equ  7300H         ; ^left arrow
line_ins   equ  5100H         ;pg down
line_del   equ  4900H         ;pg up
mark_char  equ  4F00H         ;end key

blank      equ  00720H       ;define the character which is a blank
attrib     equ  007H         ;and our default attribute (should agree with blank)
video      equ  10H          ;video BIOS call
inv_attrib equ  070H         ;inverse of 'attrib'
    PAGE
CSEG  SEGMENT PARA PUBLIC 'CODE'
      ASSUME CS:CSEG,DS:CSEG,SS:CSEG,ES:NOTHING   ;STANDARD DECL FOR .COM FILE

      ORG  100H

Start:
      JMP INSTALL

;PLACE DATA AREA HERE FOR READABILITY

SCREENSAVE: DW (WNDW_HT * (WNDW_WD+1)) DUP (BLANK);RESERVE SPACE TO SAVE OPENED WINDOW
LINESAVE:   DW WNDW_WD DUP (BLANK) ;BUFFER FOR LINE DELETE

CURSOR_POS  DW 0
OLD_CUR_POS DW 0
SAVESTACK   DW 0,0

REQUEST     DW 0              ;REQUEST TYPE

KEY_RQST_HANDLER DD 0         ;ADDRESS OF THE ORIGINAL KEYBOARD REQUEST HANDLER

LEFT_MARG  DB   00            ;define the confines of the window
RIGHT_MARG DB   00
TOP_MARG   DB   00
BOT_MARG   DB   00
UPPER_LEFT DW   00

MARK       DW   -1            ;FLAGS USED IN CHARACTER FEED
FEED_START DW   00            ;ADDRESS IN BUFFER OF BEGIN...
FEED_STOP  DW   00            ;...AND END OF FEED
FEED_END1  DW   00            ;TEMP HOLDING SPOT FOR BEG FEED ADDR
FEED_END2  DW   00            ;TEMP HOLDING SPOT FOR END FEED ADDR

FEED_CHAR  DW   00            ;CHAR TO FEED ON THIS CALL

DISPLAY_SEG DW 00             ;SAVE OFF THE DISPLAY SEGMENT ***
PAGE
BEGIN PROC FAR                ;FAR LABEL SINCE ITS ENTERED BY INTERRUPT
MAINLOOP:
      MOV  CS:REQUEST,AX      ;SAVE HIS AX REGISTER

      MOV  AX,CS:FEED_START   ;ARE WE IN THE MIDDLE OF FEEDING CHARS...
      CMP  AX,CS:FEED_STOP    ;...TO THE APPLICATION?
      JZ   NOFEED             ;NO
      JMP  FEED               ;YES
NOFEED:
      MOV  AX,CS:REQUEST      ;RESTORE USERS AX
      PUSHF                   ;CALL OLD INTERRUPT HANDLER (EMULATE INT INSTRUCTION)
      CALL DWORD PTR [CS:KEY_RQST_HANDLER] ;GO AHEAD AND GET THE CHARACTER
      PUSHF                   ;SAVE THE FLAG RETURNED (FOR AH = 1 REQUESTS)

      CMP CS:BYTE PTR REQUEST+1,00H ;WE ARE ONLY INTERESTED IN CHAR. REQUESTS
      JZ  CNTINUE
      JMP FORGET_IT

CNTINUE:                      ;YES -- CHECK CHARACTER FOR 'OURS'
      POPF                    ;FOR NON-TYPE 1 REQUESTS DONT NEED TO SAVE FLAGS
      CMP AX,CUT_KEY
      JZ  CNT_AGIN
      CMP AX,PASTE_KEY
      JZ  PASTE_CHAR

      JMP RETURN_CHAR

CNT_AGIN:                     ;WE GOT IT! GO INTO EDITOR MODE
      MOV CS:SAVESTACK,SP
      MOV CS:SAVESTACK+2,SS
      MOV  AX,CS
      MOV  SS,AX
      MOV  SP,100H

      STI                     ;ENABLE INTERRUPTS WHILE PROCESSING CHARACTERS

      PUSH BP                 ;SET UP A STACK FRAME
      MOV  BP,SP
      SUB  SP,0EH
      CALL SAVEREG
      MOV  DS,AX

      CALL READ_CURSOR
      MOV OLD_CUR_POS,DX      ;SAVE THE CURSOR FOR LATER RESTORING
      MOV CURSOR_POS,DX      ;SAVE THE CURSOR FOR LATER RESTORING

      CALL CALC_WINDOW        ;CALCULATE WINDOW EXTREMETIES

      CALL WINDOW_SAVE        ;SAVE SCREEN

      MOV DX,CURSOR_POS       ;RESTORE CURSOR IN EDIT WINDOW
      CALL PLACE_CURSOR

      CALL EDITOR             ;LET HIM EDIT IN THE WINDOW

      CALL READ_CURSOR
      MOV CURSOR_POS,DX       ;SAVE CURSOR IN EDIT WINDOW FOR NEXT EDIT

      CALL WINDOW_SWAP        ;PUT BACK WHATEVER WAS ORIGINALLY THERE

      MOV DX,OLD_CUR_POS      ;RESTORE THE CURSOR POSITION
      CALL PLACE_CURSOR

      CALL RESTREG
      ADD  SP,0EH
      POP  BP

      MOV SS,CS:SAVESTACK+2
      MOV SP,CS:SAVESTACK

      MOV AH,00              ;RESTORE REQUEST TO SOMETHING DECENT
      JMP MAINLOOP           ;GO GET ANOTHER CHARACTER TO RETURN HIM

PASTE_CHAR:
      MOV  AX,CS:FEED_END1   ;BEGIN TO FEED CHARACTER STRING INTO APPLICATION
      MOV  CS:FEED_START,AX
      MOV  AX,CS:FEED_END2
      MOV  CS:FEED_STOP,AX

      MOV AH,00              ;RESTORE REQUEST TO SOMETHING DECENT
      JMP MAINLOOP           ;GO GET ANOTHER CHARACTER TO RETURN HIM

RETURN_CHAR:
      IRET                   ;RETURN WITH CHARACTER

;HANDLE REQUEST TYPE 1'S BY FAR RETURNING 2 AND TYPE 2'S BY JUST RETURNING

FORGET_IT:
      CMP  CS:BYTE PTR REQUEST+1,1      ;was it a "is char present" request?
      JZ   FI100

      POPF                   ;no -- just return whatever BIOS returned
      IRET

FI100:
      POPF                   ;yes -- make funny return
      RET 02
      PAGE
;HERE WE ARE IN THE PROCESS OF FEEDING CHARACTERS TO THE APPLICATION
;FROM THE WINDOW BUFFER (SCREENSAVE)

FEED:
      CMP  CS:BYTE PTR REQUEST+1,1       ;WAS THIS A CHAR TYPE REQUEST?
      JA   KSTAT
                                ;YES -- RETURN HIM CHAR
      PUSH BX                 ;GET THE NEXT CHARACTER FROM THE BUFFER
      MOV  BX,AX
      MOV  AX,CS:[BX]
      POP  BX
      XOR  AH,AH              ;WE NO LONGER HAVE THE SCAN CODE, BUT ALL
      MOV  CS:FEED_CHAR,AX    ;ARE ASCII ANYWAY

      CMP  CS:BYTE PTR REQUEST+1,0       ;IS THIS A 'GET KEYBOARD CHAR' RQST?
      JNZ  FEED_KEY_STAT

      ADD  CS:FEED_START,2    ;YES -- MOVE UP THE POINTER BY 1


; SKIP ANY TRAILING BLANKS
      PUSH BX
      MOV BX,CS:FEED_START
FEED10:
      CMP BX,CS:FEED_STOP
      JZ  FEED50
      MOV AX,CS:[BX]
      CMP AL,' '
      JZ FEED20
      CMP  AL,00DH
      JNZ FEED50
      MOV CS:FEED_START,BX
      JMP FEED50
FEED20:
      INC BX
      INC BX
      JMP FEED10
FEED50:
      POP BX

      MOV AX,CS:FEED_CHAR
        IRET

FEED_KEY_STAT:
      STI                     ;NO -- ENABLE INTERRUPTS AND FEED HIM THE
      RET  02                 ;THE Z FLAG CLEAR WITH HIS CHAR

KSTAT:
      MOV  AX,CS:REQUEST      ;RESTORE REQUEST TO AH
      PUSHF
      CALL DWORD PTR [CS:KEY_RQST_HANDLER] ;PERFORM BIOS CALL -- WE DON'T KNOW
                                ;WHAT HE'S DOING AND WE SHOULDN'T GET IN THE WAY
      IRET                    ;RETURN THE RESULTS TO HIM (WHATEVER THEY ARE)
BEGIN ENDP
      PAGE
BODY  PROC NEAR               ;MAKE SHORT CALLS ONLY TO THE MAIN ROUTINES
CALC_WINDOW:
      MOV AH,0FH              ;FIND OUT VIDEO MODE FOR CALCULATING WINDOW SIZE
      INT VIDEO               ;GO AHEAD AND GET THE CHARACTER

;***SAVE OFF THE VIDEO SEGMENT***

      MOV CX,0B000H           ;IS IT MONOCHROME?
      CMP AL,7                ;WELL LOOK FOR MODE 7
      JZ  CW100
      MOV CX,0B800H           ;NO -- ITS GRAPHIX
CW100:
      MOV DISPLAY_SEG,CX      ;SAVE THIS OFF
;***

      DEC AH                  ;THIS IS THE NUMBER OF COLS ON SCREEN
      MOV RIGHT_MARG,AH       ;SET UP RIGHT AND LEFT MARGINS
      SUB AH,(WNDW_WD - 1)
      MOV LEFT_MARG,AH

      MOV TOP_MARG,0          ;WE HAVE NO INFORMATION ON NUMBER OF ROWS
      MOV BOT_MARG,WNDW_HT-1  ;SO WE MUST ASSUME SOMETHING NORMAL (IT ISNT
                              ;AS CRITICAL ANYWAY)

      MOV AL,AH               ;NOW ADD UPPER_LEFT HAND CORNER VALUE
      XOR AH,AH
      MOV UPPER_LEFT,AX


CW200:
      RET
      PAGE
;***NEW WINDOW_SWAP PROCEDURE AND WINDOW_SAVE COMBINED -- TWO DIFFERENT
;ENTRY POINTS TELL WHETHER TO DO THE WRITE OR NOT
;NOTE THAT THIS PROCEDURE DOES NOT BIOS CALLS -- ALL DIRECT WRITES

SWAP_SAVE DB 0

WINDOW_SAVE:
      MOV SWAP_SAVE,0         ;MARK THIS ENTRY POINT
      JMP WS025

WINDOW_SWAP:
        MOV SWAP_SAVE,0FFH       ;MARK THIS DIFFERENT ENTRY POINT

WS025:
        MOV CX,WNDW_HT          ;GET THE NUMBER OF ROWS IN WINDOW AREA
      MOV SI,OFFSET SCREENSAVE;START AT BEGINNING OF BUFFER
      MOV ES,DISPLAY_SEG      ;LOAD UP THE VIDEO SEGMENT
      MOV DI,00
      XOR BX,BX
WS050:
      MOV BL,LEFT_MARG        ;START ON THIS LINE AT THE LEFT MARGIN
WS100:
      SHL  BX,1               ;CHANGE THE COLUMN NUMBER TO BYTE POINTER
      MOV  AX,ES:[BX][DI]     ;GET THE NEXT CHARACTER FROM SCREEN
      XCHG AX,[SI]            ;STORE IT AWAY AND WRITE THE SAVED CHARACTER
      ADD  SI,2               ;AND MOVE SAVE POINTER OVER A WORD
;***HERE IS THE SWAP SAVE CHECK
      CMP  SWAP_SAVE,0        ;IS THIS WINDOW SWAP OR WINDOW SAVE?
      JZ   WS150
                                ;MUST BE SWAP
      MOV  ES:[BX][DI],AX     ;NOW RESTORE THAT CHARACTER TO THE SCREEN
WS150:
;***
        SHR      BX,1            ;PUT THE BYTE OFFSET BACK TO COLUMN NUMBER
      INC  BX
      CMP  BL,RIGHT_MARG      ;ARE WE BEYOND THE END OF THE LINE?
      JNA  WS100
                              ;YES -- SKIP DOWN TO NEXT LINE

      MOV WORD PTR [SI],000DH     ; SO CR'S ARE FED PROPERLY LATER
      INC SI
      INC SI

      SHL  BX,1               ;ADJUST DI BY ONE LINE'S WORTH SO THAT IT
      ADD  DI,BX              ;POINTS TO BEGINNING OF NEXT LINE
      LOOP WS050
      RET
      PAGE
EDITOR:

;check for edit keys (such as insert, delete, etc.)
;if not one of those, assume its ascii and just insert it in the
;screen return when AltF10 detected.

ED100:
      CALL GET_CHAR         ;read a character from the keyboard
      OR   AL,AL            ;if this is ascii then dont retain scan code
      JZ   ED105
      XOR  AH,AH

ED105:
        CALL UNSHADE_SCREEN      ;REMOVE PREVIOUS SHADING (IF ANY)

      MOV  BX,CURSOR_POS     ;in many cases we need the cursor position
      CMP  AX,CUT_KEY        ;check for exit
      JNZ  ED110
      JMP  ED800

ED110:
      CMP  AX,CR             ;check for each special character individually
      JNZ  ED120
      MOV  BL,LEFT_MARG
      INC  BH
      JMP  ED500
ED120:
      CMP  AX,LEFT_ARROW
      JNZ  ED140
      DEC  BL
      JMP  ED500

ED140:
      CMP  AX,RIGHT_ARROW
      JNZ  ED160
      INC  BL
      JMP  ED500

ED160:
      CMP   AX,UP_ARROW
      JNZ   ED180
      DEC   BH
      JMP   ED500

ED180:
      CMP  AX,DOWN_ARROW
      JNZ  ED200
      INC  BH
      JMP  ED500

ED200:
      CMP  AX,HOME
      JNZ  ED205
      MOV  BX,UPPER_LEFT
      JMP  ED500

ED205:                       ;tab and back tab functions
      CMP  AX,TAB
      JNZ  ED210
      MOV  CL,1              ;go forward
      JMP  ED213

ED210:
      CMP  AX,REV_TAB
      JNZ  ED220

      MOV  CL,0FFH           ;go backwards one tab slot
      ADD  DL,CL             ;start one char to left initially

ED213:
      CALL READ_CHAR         ;get char at current position
      MOV  CH,AL             ;save it for comparison
ED215:
      ADD  DL,CL             ;move over one character
      CMP  DL,RIGHT_MARG     ;stop at left and right margins (or beyond)
      JGE  ED218
      CMP  DL,LEFT_MARG
      JLE  ED218

      CALL READ_CHAR         ;read current character
      CMP  CH,' '            ;if original was a space...
      JNZ  ED216
      CMP  AL,' '            ;...then go until not space
      JZ  ED215
      JMP ED217
ED216:
      CMP AL,' '             ;...else, go until space
      JNZ ED215
ED217:
      CMP  CL,0FFH           ;if we were going backwards (towards left)...
      JNZ  ED218
      ADD  DL,1              ;...then scoot back to the right by 1
ED218:
      MOV  BX,DX
      JMP  ED500

ED220:
      CMP  AX,ESCAPE         ;wipe out remainder of line
      JNZ  ED240
      MOV  DX,BX
      CALL ERASE_LINE
      JMP  ED500

ED240:
      CMP  AX,DEL_LEFT       ;move cursor left one char and then do normal del
      JNZ  ED260
      DEC  BL
      CMP  BL,LEFT_MARG
      JNB  ED250
      MOV  BL,RIGHT_MARG
      CMP  BH,00
      JZ   ED250
      DEC  BH
ED250:
      JMP  ED270

ED260:
      CMP  AX,DELETE         ;in delete char we...
      JNZ  ED280
ED270:
      MOV  CL,RIGHT_MARG
      SUB  CL,BL             ;calculate how many chars to right margin
      XOR  CH,CH
      MOV  DX,BX             ;...start at current cursor position...
      JCXZ ED275
ED272:
      INC  DL                ;...get character just to the right...
      CALL READ_CHAR
      DEC  DL                ;...move left one position...
      CALL WRITE_CHAR        ;...and write it there...
      INC  DL                ;...now do it again for the char to the right...
      LOOP ED272             ;...for the distance from cursor to right margin;...
ED275:
      MOV  AX,BLANK
      CALL WRITE_CHAR
      JMP  ED500

ED280:
      CMP  AX,INSERT         ;in the case of insert we do reverse of delete
      JNZ  ED300
      MOV  DH,BH             ;start at the right margin
      MOV  DL,RIGHT_MARG
      MOV  CL,DL             ;caculate number of spaces to right
      SUB  CL,BL
      XOR  CH,CH
      JCXZ ED290
ED285:
      DEC  DL
      CALL READ_CHAR
      INC  DL
      CALL WRITE_CHAR
      DEC  DL
      LOOP ED285
ED290:
      MOV  AX,BLANK
      CALL WRITE_CHAR
      JMP  ED500

ED300:
      CMP  AX,LINE_INS       ;check for insert line
      JNZ  ED320
      MOV  DH,BOT_MARG       ;we're going to need that
ED305:
      MOV  DL,LEFT_MARG      ;always start at the far left
      CMP  DH,BH             ;are we on our current line?
      JZ   ED315
                             ;no -- then move it down
      MOV  CX,WNDW_WD
ED310:
      DEC  DH
      CALL READ_CHAR         ;get the character
      INC  DH
      CALL WRITE_CHAR        ;and put it back one line higher
      INC  DL                ;move right one character
      LOOP ED310

      DEC  DH                ;now move up a line and do it again
      JMP  ED305
ED315:
      MOV  BL,LEFT_MARG      ;move us over the far left marg
      CALL ERASE_LINE        ;and wipe out the line we are on
      JMP  ED500

ED320:
      CMP  AX,LINE_DEL       ;and check for line delete
      JNZ  ED340

ED325:
      MOV  DL,LEFT_MARG      ;always start at the far left
      CMP  DH,BOT_MARG       ;are we on the last line?
      JZ   ED335
                             ;no -- then move it up
      MOV  CX,WNDW_WD
ED330:
      INC  DH
      CALL READ_CHAR         ;get the character
      DEC  DH
      CALL WRITE_CHAR        ;and put it back one line lower
      INC  DL                ;move right one character
      LOOP ED330

      INC  DH                ;now move down a line and do it again
      JMP  ED325
ED335:
      MOV  BL,LEFT_MARG      ;move us over the far left marg of our line
      CALL ERASE_LINE        ;and wipe out the bottom line
      JMP  ED500

ED340:
      CMP  AX,MARK_CHAR      ;check for mark
      JNZ  ED400

      MOV  DX,BX
      CMP  MARK,-1           ;if mark isnt set...
      JNZ  ED350
      MOV  MARK,BX           ;...just set it and switch its attrib
      CALL READ_CHAR
      MOV  AH,ATTRIB
      CALL WRITE_CHAR
      JMP  ED500

ED350:                       ;else, store off feed start and end addresses
      CALL CONVERT_LOC
      MOV  FEED_END1,AX

      MOV  DX,MARK
      CALL CONVERT_LOC
      MOV  FEED_END2,AX

      MOV  CX,FEED_END1
      CMP  CX,AX
      JNA  ED355
      MOV  FEED_END1,AX
      MOV  FEED_END2,CX
ED355:
        CALL TRIM_SCREEN ;TRIM OFF UNMARKED THINGS ON SCREEN
      JMP  ED800             ;note that this char exits the utility

ED400:                       ;wasnt an edit character -- must be ascii
                                ;just write the character at current position
      MOV  AH,ATTRIB
      CALL W_CHAR
      INC  BL                ;move over one position

ED500:                       ;adjust resulting cursor position
      CMP  BL,RIGHT_MARG
      JLE  ED550
      MOV  BL,RIGHT_MARG
ED550:
      CMP  BH,BOT_MARG
      JLE  ED600
      MOV  BH,BOT_MARG
ED600:
      CMP  BL,LEFT_MARG
      JGE  ED650
      MOV  BL,LEFT_MARG
ED650:
      CMP  BH,TOP_MARG
      JGE  ED700
      MOV  BH,TOP_MARG
ED700:
      MOV  CURSOR_POS,BX
      MOV  DX,BX             ;be sure and move the cursor to the new
      CALL PLACE_CURSOR      ;position
      JMP  ED100

ED800:                       ;exit
      RET
      PAGE
;
; HERE WE PLACE SOME SMALL GENERAL PURPOSE ROUTINES
;

PLACE_CURSOR:                ;place cursor at location in dx

      CALL SHADE_SCREEN       ;if we are in mark mode, set the
                                ;screen square to inverse video
      MOV AH,2H
      PUSH BX
      XOR BX,BX
      INT VIDEO
      POP  BX
      RET

UP_LEFT DW 0
LW_RIGHT DW 0
ATTRIBUTE DB 0
SAVE_AX DW 0
SAVE_DX DW 0

SHADE_SCREEN:                    ;NEW SCREEN SHADING PROCEDURE
        CMP      MARK,-1H        ;IS A MARK SET?
        JZ       SS_END
                                ;YES -- OK SWING INTO ACTION
        MOV      SAVE_AX,AX
        MOV      SAVE_DX,DX
        MOV      ATTRIBUTE,INV_ATTRIB ;FIRST SET THE ATTRIBUTE TO INVERSE
        MOV      BX,CURSOR_POS
        MOV     AX,MARK         ;NOW, CALCULATE THE UPPER LEFT CORNER...
        CMP      BL,AL           ;...OF OUR SHADED BOX
        JA       SS100
        MOV      AL,BL
SS100:
        CMP      BH,AH
        JA       SS200
        MOV      AH,BH
SS200:
        MOV      UP_LEFT,AX
        MOV      AX,MARK ;NOW THE LOWER RIGHT CORNER
        CMP      BL,AL
        JB       SS300
        MOV      AL,BL
SS300:
        CMP      BH,AH
        JB       SS400
        MOV      AH,BH
SS400:
        MOV      LW_RIGHT,AX
        JMP      SS_COMMON

UNSHADE_SCREEN:
        CMP      MARK,-1H        ;HERE WE UNSHADE THE SHADED AREA
        JZ       SS_END
        MOV      SAVE_AX,AX
        MOV      SAVE_DX,DX
        MOV      ATTRIBUTE,ATTRIB ;CHANGE THE BOX BACK TO NORMAL


;NOW BEGIN TO SHADE IN FROM THE UPPER LEFT TO THE LOWER RIGHT CORNERS

SS_COMMON:
        MOV      DX,UP_LEFT
        MOV      BX,LW_RIGHT
SS500:
        CMP      DL,BL                   ;ARE WE OFF THE RIGHT END?
        JA       SS600
        MOV      AH,ATTRIBUTE
        CALL     WRITE_ATTRIB
        INC      DL
        JMP      SS500
SS600:
        INC      DH                      ;OK WE WENT OFF THE RIGHT END...
        CMP      DH,BH                   ;...MOVE DOWN ONE AND CHECK LOWER BOUND
        JA       SS700
        MOV      DL,BYTE PTR UP_LEFT
        JMP      SS500
SS700:
        MOV      AX,SAVE_AX
        MOV      DX,SAVE_DX
SS_END:
        RET

TRIM_SCREEN:                             ;AFTER HE SELECTS THE SECOND MARK
                                        ;WE TRIM OFF THE RIGHT MARG OF SCREEN
        MOV      MARK,-1H                ;FIRST CLEAR MARK
        MOV      BX,UP_LEFT              ;START WITH THE FIRST LINE
        MOV      BL,BYTE PTR LW_RIGHT
TS100:
        MOV      DX,LW_RIGHT             ;COMPARE THIS WITH THE LAST LINE
        CMP      BH,DH                   ;FINISHED?
        JZ       TS200
        MOV      DX,BX                   ;NO -- ERASE THE END OF THIS LINE
        CALL     ERASE_LINE
        INC      BH                      ;AND CONTINUE ON TO NEXT LINE
        JMP      TS100
TS200:
        RET

READ_CURSOR:                  ;read cursor location into dx
      MOV AH,3H
      PUSH BX
      XOR BX,BX
      INT VIDEO
      POP  BX
      RET

;***NEW READ CHAR PROCEDURE***
READ_CHAR:                    ;read screen character at location in dx
      CALL CALC_VID_LOC       ;covert the row and column into location
      MOV  AX,ES:[DI]         ;get the character at that location
      RET
;***

R_CHAR:                       ;read screen char at current cursor location
      MOV AH,8H
      PUSH BX
      XOR BH,BH
      INT VIDEO
      POP  BX
      RET

;***NEW WRITE CHAR PROCEDURE
WRITE_CHAR:                   ;write attrib/char in ax at location in dx
      PUSH AX                 ;save the attrib from destruction
      CALL CALC_VID_LOC       ;convert the row and column into location
      POP  AX
      MOV ES:[DI],AX
      RET
WRITE_ATTRIB:
      PUSH AX
      CALL CALC_VID_LOC
      POP  AX
        MOV ES:01[DI],AH
      RET
;***

W_CHAR:                       ;write character at current cursor location
      PUSH BX                 ;save bx register
      MOV  BL,AH
      XOR  BH,BH
      PUSH CX                 ;retain cx register also
      MOV  CX,1
      MOV  AH,9H
      INT VIDEO
      POP  CX
      POP  BX
      RET

GET_CHAR:                     ;get character from keyboard into ax
      MOV AH,0H
      PUSHF                   ;simulate call to keyboard handler
      CALL DWORD PTR [KEY_RQST_HANDLER]
      RET

ERASE_LINE:                   ;erase the current line from dx to right margin
      MOV  CL,RIGHT_MARG
      SUB  CL,BL
      INC  CL
      XOR  CH,CH
      MOV  SI,OFFSET LINESAVE

ER100:
      CALL READ_CHAR         ;get the character @ current location
      MOV  [SI],AX
      ADD  SI,2

      MOV  AX,BLANK
      CALL WRITE_CHAR        ;***CHANGED FROM W_CHAR***
      INC  DL
      LOOP ER100
      RET

RESTORE_LINE:                ;restore the current line from dx to right margin
      MOV  CL,RIGHT_MARG
      SUB  CL,BL
      INC  CL
      XOR  CH,CH
      MOV  DI,OFFSET LINESAVE

RL100:
      MOV  AX,[DI]           ;get the saved char
      CALL WRITE_CHAR         ;put the saved char where indicated
      ADD  DI,2
      INC  DL
      LOOP RL100
      RET

CONVERT_LOC:                 ;convert a location on the screen (in dx) into AX
      MOV  CX,DX
      MOV  AX,OFFSET SCREENSAVE
CL100:
      CMP  CH,TOP_MARG
      JZ   CL200
      ADD  AX,(WNDW_WD+1)*2
      DEC  CH
      JMP  CL100

CL200:
      CMP  CL,LEFT_MARG
      JZ   CL300
      ADD  AX,2
      DEC  CL
      JMP  CL200

CL300:
      RET

SAVEREG:
      MOV  -2[BP],BX          ;save reggies on stack frame
      MOV  -4[BP],CX
      MOV  -6[BP],DX
      MOV  -8[BP],SI
      MOV  -0AH[BP],DI
      MOV  -0CH[BP],DS
      MOV  -0EH[BP],ES       ;***ADDED SAVING OF ES***
      RET
RESTREG:
      MOV  BX,-2[BP]          ;NOW PUT THE REGGIES BACK AND PULL DOWN
      MOV  CX,-4[BP]          ;THE STACK FRAME
      MOV  DX,-6[BP]
      MOV  SI,-8[BP]
      MOV  DI,-0AH[BP]
      MOV  DS,-0CH[BP]
      MOV  ES,-0EH[BP]       ;***ADD RESTORE OF ES***
      RET

;***NEW PROCEDURE TO CONVERT ROW AND COLUMN INTO ADDRESS

CALC_VID_LOC:                ;convert the row and column in dx into an
                             ;offset into the video display buffer
      XOR  AX,AX
      XOR  DI,DI
      PUSH CX                ;save cx -- some of those who call us need it
      XOR  CX,CX

      MOV  AL,RIGHT_MARG     ;get the width of a row
      INC  AX
      MOV  CL,DH             ;put the number of rows into cx
      JCXZ CVL200
CVL100:
      ADD  DI,AX             ;for every row add in another 80/40 columns
      LOOP CVL100
CVL200:
      MOV  AL,DL             ;now move over to the current column
      ADD  DI,AX

      POP  CX                ;restore cx

      SHL  DI,1              ;now convert this into byte offset
      MOV  ES,DISPLAY_SEG
      RET
;***

BODY  ENDP
      PAGE
INSTALL:
;THIS PROGRAM INSTALLS THE REST OF THE CODE FOR CUTPASTE

      MOV DX,OFFSET MESSAGE  ;OUTPUT 'OK' MESSAGE
      MOV AH,9H
      INT 21H

      MOV AX,3516H            ;GET INTERRUPT 16 VECTOR
      INT 21H
      MOV WORD PTR KEY_RQST_HANDLER,BX
      MOV WORD PTR KEY_RQST_HANDLER+2,ES

      MOV AX,2516H
      MOV DX,OFFSET BEGIN     ;NOW PUT OUR ROUTINE THERE
      INT 21H

      MOV DX,OFFSET INSTALL   ;TERMINATE AND STAY RESIDENT
      ADD DX,100H
      MOV CL,4
      SHR DX,CL
      MOV AH,31H
      INT 21H

MESSAGE DB 10,13,'CUTPASTE 4.0 installed',10,13,' ALT F9 to enable cut', ; WARREN
        DB 10,13,'   ^F9 to paste   ',10,13,'$'

CSEG ENDS
     END START
