; Patches CT-VOICE.DRV to use IRQ 7
;

[bits 16]                           ;16 bit code generation
[org 0x0100]                        ;com-file = start address 0x100
[section .text]                     ;code section

start:
jmp         begin

%macro printf 1
mov         dx,%1                   ;select message set in parameter %1
mov         ah,09h                  ;select print function
int         21h                     ;commit
%endmacro

;http://spike.scu.edu.au/~barry/interrupts.html
;open,close,seek,write
%macro patch 4
mov         ax,04200h               ;select seek file, pos: start of file
mov         bx,[handle]             ;bx = file handle
mov         cx,%1                   ;cx = segment
mov         dx,%2                   ;dx = offset
int         21h                     ;commit
jc          error                   ;if carry flag set jump to error
mov         ah,40h                  ;select write file
mov         bx,[handle]             ;bx = file handle
mov         cx,%3                   ;cx = no. bytes to write
mov         dx,%4                   ;ds:dx -> data to write
int         21h                     ;commit
jc          error                   ;if carry flag set jump to error
%endmacro

;function: open file
fopen:
mov         dx,filename             ;load filename into dx
mov         ax,03D02h               ;select open file
int         21h                     ;commit
jc          error                   ;if carry flag set jump to error
mov         [handle],ax             ;store file handle
ret                                 ;return to caller

; function: close file
fclose:
mov         ax,03E00h               ;select close file
int         21h                     ;commit
jc          error                   ;if carry flag set jump to error
ret                                 ;return to caller

error:
printf      error1
jmp         exit                    ;jump to exit

begin:
printf      title                   ;print message
call        fopen                   ;open file to be patched
patch       p1seg,p1ofs,p1len,p1dat
call        fclose                  ;close file
printf      success                 ;print message

exit:

mov         ax,04C00h               ;select return to dos
int         21h                     ;commit

[section .data]
filename    db 'CT-VOICE.DRV',0           ;target filename
title       db 'Patches CT-VOICE.DRV to use IRQ 7',0AH,0DH,'$'
error1      db 'Failure',0AH,0DH,'$'
success     db 'Success',0AH,0DH,'$'
handle      dw 0

;patch1
p1seg       equ 00000h              ;segment: most significant byte
p1ofs       equ 0032h               ;offset: least significant byte
p1dat       db  0x07         	    ;string
p1len       equ $-p1dat             ;length

