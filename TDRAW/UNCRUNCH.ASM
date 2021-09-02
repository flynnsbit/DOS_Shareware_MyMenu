;THEDRAW IMAGE UNCRUNCHING ROUTINE
;-----------------------------------------------------------------------------
;Compatible with MASM (Microsoft) and TASM v1.0 (Borland).  Minor format
;changes may be required for other assemblers.
;-----------------------------------------------------------------------------
;
;This is the routine for displaying crunched TheDraw image files.  The
;crunched data format is a simple custom protocol for reproducing any image.
;The control codes below decimal 32 are reserved for this function.
;Characters 32 and above are written directly to the destination address.
;
;The following shows the format of a control code sequence.  Please note that
;not all functions use the optional bytes <x> or <y>.
;
;Data Structure:  <current byte>[<x>[<y>]]
;
;   0..15 = New Foreground Color
;  16..23 = New Background Color
;      24 = Go down to next line, return to same horizontal position as when
;           routine was started (akin to a c/r).
;      25 = Displays <x> number of spaces.
;      26 = Displays <x> number of <y>.  Also used to display ANY characters
;           below #32.  This function is the only way to do this although it
;           uses three bytes.  Otherwise the code would be interpreted as
;           another command.
;      27 = Toggles on/off the foreground attribute blink flag.
;  28..31 = reserved
;
;----------------------------------------------------------------------------
;
;To use the routine, call the uncrunch procedure with the DS:SI register pair
;pointing to the TheDraw output listing, the ES:DI register pair pointing to
;the destination display address, and the length of the crunched image data
;in the CX register.  All modified registers are restored upon exiting.
;
;Assume an output file of a 40 character by 10 line block.  The label
;'IMAGEDATA' has been added for referencing purposes. ie:
;
;
;     ;TheDraw Assembler Crunched Screen Image
;     IMAGEDATA_WIDTH EQU 40
;     IMAGEDATA_DEPTH EQU 10
;     IMAGEDATA_LENGTH EQU 467
;     IMAGEDATA LABEL BYTE
;                DB      ...list of image bytes here...
;
;
;The following assembly language code could then be used to display the
;40x10 block on the screen with:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800h
;                MOV     ES,AX
;                MOV     DI,34*2 + 5*160-162
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;The data segment (DS register) is assumed to point at the segment ImageData
;resides in.   The ES:DI register pair points at position (34,5) on the color
;graphics adapter screen, calculated as an offset from the start of the screen.
;Monochrome card users, replace the 0B800h with 0B000h.
;
;The original horizontal starting offset is remembered by the uncrunch routine.
;The offset is restored upon moving down to the next line.  This permits a
;block to be displayed correctly anywhere on the screen.  ie:
;
;              ÚÄ horizontal starting offset
;              V
;  +-------------------------------------------------+
;  |                                                 |
;  |                                                 | <- Assume this
;  |                                                 |    is the video
;  |           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿               |    display.
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛ ImageData block ÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
;  |           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               |
;  |                                                 |
;  |                                                 |
;  |                                                 |
;  +-------------------------------------------------+
;
;
;To display the block in the lower-right corner, change the DI assignment to:
;
;                MOV     DI,40*2 + 15*160-162
;
;The block is 40 characters wide by 10 lines deep.  To display on a 80 by 25
;screen, we must display the block at coordinates (40,15).  To display in
;the upper-left screen corner use:
;
;                MOV     SI,offset IMAGEDATA
;                MOV     AX,0B800H
;                MOV     ES,AX
;                MOV     DI,1*2 + 1*160-162       ;coordinates 1,1
;                MOV     CX,IMAGEDATA_LENGTH
;                CALL    UNCRUNCH
;
;Notice in both cases only the offset address changed.  Note the latter case
;is also used for displaying a full screen image (which in general are
;always displayed at coordinate 1,1).
;
;----------------------------------------------------------------------------
;
;That's it!  The routine was designed for easy use and understanding; however,
;for some people the best way is to experiment.  Create a program using the
;above examples, perhaps with a 40x10 block (or any size).  Good luck!
;

UNCRUNCH PROC NEAR
;
;Parameters Required:
;  DS:SI  Crunched image source pointer.
;  ES:DI  Display address pointer.
;  CX     Length of crunched image source data.
;
       PUSH    SI                      ;Save registers.
       PUSH    DI
       PUSH    AX
       PUSH    BX
       PUSH    CX
       PUSH    DX
       JCXZ    Done

       MOV     DX,DI                   ;Save X coordinate for later.
       XOR     AX,AX                   ;Set Current attributes.
       CLD

LOOPA: LODSB                           ;Get next character.
       CMP     AL,32                   ;If a control character, jump.
       JC      ForeGround
       STOSW                           ;Save letter on screen.
Next:  LOOP    LOOPA
       JMP     Short Done

ForeGround:
       CMP     AL,16                   ;If less than 16, then change the
       JNC     BackGround              ;foreground color.  Otherwise jump.
       AND     AH,0F0H                 ;Strip off old foreground.
       OR      AH,AL
       JMP     Next

BackGround:
       CMP     AL,24                   ;If less than 24, then change the
       JZ      NextLine                ;background color.  If exactly 24,
       JNC     FlashBitToggle          ;then jump down to next line.
       SUB     AL,16                   ;Otherwise jump to multiple output
       ADD     AL,AL                   ;routines.
       ADD     AL,AL
       ADD     AL,AL
       ADD     AL,AL
       AND     AH,8FH                  ;Strip off old background.
       OR      AH,AL
       JMP     Next

NextLine:
       ADD     DX,160                  ;If equal to 24,
       MOV     DI,DX                   ;then jump down to
       JMP     Next                    ;the next line.

FlashBitToggle:
       CMP     AL,27                   ;Does user want to toggle the blink
       JC      MultiOutput             ;attribute?
       JNZ     Next
       XOR     AH,128                  ;Done.
       JMP     Next

MultiOutput:
       CMP     AL,25                   ;Set Z flag if multi-space output.
       MOV     BX,CX                   ;Save main counter.
       LODSB                           ;Get count of number of times
       MOV     CL,AL                   ;to display character.
       MOV     AL,32
       JZ      StartOutput             ;Jump here if displaying spaces.
       LODSB                           ;Otherwise get character to use.
       DEC     BX                      ;Adjust main counter.

StartOutput:
       XOR     CH,CH
       INC     CX
       REP STOSW
       MOV     CX,BX
       DEC     CX                      ;Adjust main counter.
       LOOPNZ  LOOPA                   ;Loop if anything else to do...

Done:  POP     DX                      ;Restore registers.
       POP     CX
       POP     BX
       POP     AX
       POP     DI
       POP     SI
       RET

UNCRUNCH ENDP

