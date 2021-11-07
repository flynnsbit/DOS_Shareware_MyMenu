; "memories" by HellMood/DESiRE
; the tiny megademo, 256 byte msdos intro
; shown in April 2020 @ REVISION
;
;   (= WILL BE COMMENTED IN DETAIL LATER =)
;
; create : nasm.exe memories.asm -fbin -o memories.com
; CHOOSE YOUR TARGET PLATFORM (compo version is dosbox)
; be sure to use the dosbox.conf from this archive!
; only ONE of the defines should be active!
%define dosbox			; size : 256 bytes
;%define freedos		; size : 230 bytes
;%define winxpdos		; size : 263 bytes

; DON'T TOUCH THESE UNLESS YOU KNOW WHAT YOU'RE DOING
%ifdef winxpdos
	%define music
	%define switch_uart
	%define safe_dx
	%define safe_segment
%endif
%ifdef freedos
	%define safe_dx
%endif
%ifdef dosbox
	;%define music
	;%define safe_dx ; sometimes needed
%endif

; GLOBAL PARAMETERS, TUNE WITH CARE!
%define volume 127	; not used on dosbox (optimization)
%define instrument 11
%define scale_mod -19*32*4; 
%define time_mask 7
%define targetFPS 35
%define tempo 1193182/256/targetFPS		
%define sierp_color 0x2A
%define tunnel_base_color 20
%define tunnel_pattern 6
%define tilt_plate_pattern 4+8+16
%define circles_pattern 8+16

org 100h
s:
%ifdef freedos
	mov fs,ax
	mov [fs:0x46c],ax
%endif
	mov al,0x13
	int 0x10	 
	xchg bp,ax
	mov bp,512*4
	push 0xa000-10
	pop es
%ifndef freedos
	mov ax,0x251c
	%ifdef safe_dx	
		mov dx,timer	
	%else ; assume DH=1, mostly true on DosBox
		mov dl,timer
	%endif
	int 0x21
%endif
top:
%ifdef freedos
	mov bp,[fs:0x46c]
%endif	
	mov ax,0xcccd
	mul di
	add al,ah
	xor ah,ah
	add ax,bp
	shr ax,9
	and al,15
	xchg bx,ax
	mov bh,1
	mov bl,[byte bx+table]
	call bx
	stosb
	inc di
	inc di
	jnz top
	mov al,tempo
	out 40h,al
	in al,0x60
	dec al
	jnz top
sounds:
	db 0xc3	; is MIDI/RET
%ifdef music
	db instrument,0x93
	%ifdef switch_uart
		db volume		; without switch, volume is in table
		db 0x3f 
	%endif
%endif
table: ; first index is volume, change order with care!		    					
	db fx2-s,fx1-s,fx0-s,fx3-s,fx4-s,fx5-s,fx6-s,sounds-s,stop-s
stop:
	pop ax
	ret
timer:
%ifndef freedos
	%ifdef safe_segment
		push cs
		pop ds
	%endif
		inc bp
	%ifdef music	
		test bp, time_mask
		jnz nomuse
		mov dx,0x330
		mov si,sounds
		outsb
		outsb
		outsb
		imul ax,bp,scale_mod
		shr ax,10
		add al,22
		out dx,al
		outsb
		%ifdef switch_uart
			inc dx
			outsb
		%endif
	%endif
nomuse:
	iret
%endif	
fx0: ; tilted plane, scrolling
	mov ax,0x1329		; initialize with constant
	add dh,al		; preventing divide overflow
	div dh			; reverse divide AL = C/Y'
	xchg dx,ax		; DL = C/Y', AL = X
	imul dl			; AH = CX/Y'
	sub dx,bp		; DL = C/Y'-T 	
	xor ah,dl		; AH = (CX/Y') ^ (C/Y'-T)
	mov al,ah		; move to AL
	and al,4+8+16		; select special pattern
ret
fx2: ; board of chessboards
	xchg dx,ax		; get XY into AX
	sub ax,bp		; subtract time from row
	xor al,ah		; XOR pattern (x xor y)
	or al,0xDB		; pattern for array of boards
	add al,13h		; shift to good palette spot
ret
fx1: ; circles, zooming
	mov al,dh		; get Y in AL
	sub al,100		; align Y vertically
	imul al			; AL = Y²
	xchg dx,ax		; Y²/256 in DH, X in AL
	imul al			; AL = X²
	add dh,ah		; DH = (X² + Y²)/256
	mov al,dh		; AL = (X² + Y²)/256
	add ax,bp		; offset color by time
	and al,8+16		; select special rings
ret
fx3: ; parallax checkerboards
	mov cx,bp		; set inital point to time
	mov bx,-16		; limit to 16 iterations
fx3L:
	add cx,di		; offset point by screenpointer
	mov ax,819		; magic, related to Rrrola constant
	imul cx			; get X',Y' in DX
	ror dx,1		; set carry flag on "hit"
	inc bx			; increment iteration count
	ja fx3L			; loop until "hit" or "iter=max"
	lea ax,[bx+31]	; map value to standard gray scale
ret
fx4: ; sierpinski rotozoomer	
	lea cx,[bp-2048]; center time to pass zero
	sal cx,3		; speed up by factor 8!
	movzx ax,dh		; get X into AL
	movsx dx,dl		; get Y int DL
	mov bx,ax		; save X in BX
	imul bx,cx		; BX = X*T
	add bh,dl		; BH = X*T/256+Y
	imul dx,cx		; DX = Y*T
	sub al,dh		; AL = X-Y*T/256
	and al,bh		; AL = (X-Y*T/256)&(X*T/256+Y)
	and al,252		; thicker sierpinski
	salc			; set pixel value to black
	jnz fx4q		; leave black if not sierpinski
	mov al,0x2A		; otherwise: a nice orange
	fx4q:
ret
fx5: ; raycast bent tunnel
	mov cl,-9		; start with depth 9 (moves backwards)
	fx5L: 
	push dx			; save DX, destroyed inside the loop
		mov al,dh	; Get Y into AL
		sub al,100	; Centering Y has to be done "manually".
		imul cl		; Multiply AL=Y by the current distance, to get a projection(1)
		xchg ax,dx	; Get X into AL, while saving the result in DX (DH)
		add al,cl	; add distance to projection, (bend to the right)
		imul cl		; Multiply AL=X by the current distance, to get a projection(2)
		mov al,dh	; Get projection(1) in AL
		xor al,ah	; combine with projection(2)
		add al,4	; center the walls around 0
		test al,-8	; check if the wall is hit
	pop dx			; restore DX
	loopz fx5L		; repeat until "hit" or "iter=max"
	sub cx,bp		; offset depth by time
	xor al,cl		; XOR pattern for texture 
	aam 6			; irregular pattern with MOD 6
	add al,20		; offset into grayscale palette
ret
fx6: ; ocean night / to day sky
	sub dh,120			; check if pixel is in the sky
	js fx6q				; quit if that's the case
	mov [bx+si],dx		; move XY to a memory location
	fild word [bx+si]	; read memory location as integer
	fidivr dword [bx+si]; reverse divide by constant
	fstp dword [bx+si-1]; store result as floating point
	mov ax,[bx+si]		; get the result into AX
	add ax,bp			; modify color by time
	and al,128			; threshold into two bands
	dec ax				; beautify colors to blue/black
fx6q:
ret
