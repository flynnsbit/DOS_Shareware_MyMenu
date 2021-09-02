program VGA_Less;

{$G-,F+} (* Needs to do 8086 only, and needs jumptables :) *)

(* My entry into the 1995 Hornet 8086 compo entitled:
**
** VGA_Less!!! :)  (also known as Shades, Tranbience and Ytal)
** (Source_Less version, i.e. cleaned up a bit; all comments are only for the
** education of the ripper/reader)
**
** At least this doesn't have all my dead code lying around like One-Night
** Source did :)
*)

{ $DEFINE DEBUG}    {Remove leading space for the "poor-man's profiler"}

{$DEFINE i8086}     {Required by RADpas}

uses
	crt, radpas;

type
	CGAScreen = array[0..1, 0..8191] of byte;
	CGAScreen2 = array[0..16383] of byte;
	star = record
		x, y : integer;
		z : word;
		lp : word;
	 end;

const
	numstars = 511;
	numsnows = 255;

var
	mode : string;
	x, i, j : word;
	page, bright : byte;
	f0 : longint;
	f, fr, b : word;
	scr : ^CGAScreen;
	scr2 : ^CGAScreen2;
	YTab80 : array[0..199] of word;
	sintab, costab : array[0..511] of byte;
	sintab80, sintab80d2 : array[0..511] of word;
	vscr : array[0..63999] of byte absolute $A000:0000;
	vga : boolean;
	qfrm : integer;
	quit : boolean;
	fad0, fad1, fec0, fec1 : word;
	stars : array[0..numstars] of star;
	snows : array[0..numsnows] of star;
	numstar, numsnow, numworm : word;
	ch : char;
	smooth : boolean;
	rtabl : array[0..8191] of word;
	rpos : word;
	pal : array[0..255, 0..2] of byte;
	endpic : ^CGAScreen2;
	shadebob : array[0..7, 0..7] of byte;

	(* Linked stuff *)

	procedure CompoMusic; external; {$L 8086mus.obj}
	procedure NotCompoMusic; external; {$L funkmus.obj}
	procedure FirePalette; external; {$L firepal.obj}
	procedure EndPicture; external; {$L endpic.obj}
	procedure Pal332Pack; external; {$L 332pal.obj}
	procedure EndPalette; external; {$L endpal.obj}

	(* VGA driver *)

	procedure CGAToVGA; assembler;

	{var
		i : word;

	begin
		for i := 0 to 99 do
		 begin
			move (scr^[0, YTab80[i]], vscr[YTab80[i*2] + 80*20], 80);
			move (scr^[1, YTab80[i]], vscr[YTab80[i*2 + 1] + 80*20], 80);
		 end;
	end;}

	asm
		push ds
			mov ax, 0A000h
			mov es, ax
			mov di, 80*20

			lds si, scr

			mov dx, 100
		 @Loop:
			mov cx, 40
			rep movsw { Good thing I didn't accidentally put a db $66 there :) }
			add si, 8192-80
			mov cx, 40
			rep movsw
			sub si, 8192

			dec dx
			jnz @Loop
		pop ds
	end;

	procedure init80; assembler;

	{ This just initializes the VGA 80x200 mode.  Thanks to TCA / NewOrder
	(who also supplied the... um... comments :) }

	const
		CRTParams : array[1..10] of word =
			($0d06,$3e07,$4109,$ea10,$ac11,$df12,$0014,$e715,$0616,$e317);

	asm
		mov     ax, 0013h
		int     10h

		mov     dx,03c4h
		mov     ax,0604h
		out     dx,ax {disable chain4 mode}
		mov     ax,0100h
		out     dx,ax
		mov     dx,03c2h
		mov     al,0e3h
		out     dx,al

		mov     dx,03c4h
		mov     ax,0300h
		out     dx,ax

		mov     dx,03d4h
		mov     al,11h
		out     dx,al
		inc     dx
		in      al,dx
		and     al,7fh
		out     dx,al
		dec     dx
		cld
		mov     si,offset CRTParams
		mov     cx,10
	 @S:
		lodsw
		out     dx,ax
		loop    @s

		MOV     DX,3D4h
		MOV     AL,9
		OUT     DX,AL
		INC     DX
		IN      AL,DX
		AND     AL,0E0h
		mov	al, 1
		OUT     DX,AL

		mov     dx,03c4h
		mov     ax,0f02h
		out     dx,ax

		mov     ax,0a000h
		mov     es,ax
		xor     di,di
		db	66h
		db	33h
		db	0c0h {xor eax,eax}
		mov     cx,2000h
		db	0f3h
		db	66h; rep stosw
	end;

	procedure setscanlines (numl : word); assembler;

	{ Courtesy of Trixter / Hornet.  Sets each row on the screen to be numl+1
	scanlines thick.  Default for Mode13: numl = 1 }

	asm
		mov dx, 3d4h
		mov al, 9
		out dx, al
		inc dx
		in al, dx
		and al, 0E0h
		add ax, numl
		out dx, al
	end;

	procedure SetColor (c, r, g, b : byte); assembler;

	{ Sets VGA color C to have RGB values R, G and B respectively. }

	asm
		mov dx, 3C8h
		mov al, c
		out dx, al

		inc dx
		mov al, r
		out dx, al
		mov al, g
		out dx, al
		mov al, b
		out dx, al
	end;

	procedure SetPalette (var pal); assembler;

	{ My favorite SetPalette routine.  Feel honored to have it. :) }

	asm
		les di, pal

		mov dx, 3C8h
		mov al, 0
		out dx, al
		inc dx

		mov cx, 384
	 @Loop1:
		mov ax, es:[di]
		out dx, al
		xchg ah, al
		out dx, al

		add di, 2
		dec cx
		jnz @Loop1
	end;

	(* Everything else *)

	function mini(a, b : integer) : integer; assembler;

	{ Returns the lower of A or B }

	asm
		mov ax, a
		mov bx, b
		cmp ax, bx
		jl @dont
		xchg ax, bx
	 @dont:
	end;

	function maxi(a, b : integer) : integer; assembler;

	{ Returns the higher of A or B }

	asm
		mov ax, a
		mov bx, b
		cmp ax, bx
		jg @dont
		xchg ax, bx
	 @dont:
	end;

	procedure retrace; assembler;

	{ Waits for vertical retrace. }

	asm
		mov dx, 3d4h+6

	 @rt:
		in al, dx
		test al, 1000b
		jnz @rt

	 @n_rt:
		in al, dx
		test al, 1000b
		jz @n_rt
	end;

	function rand(max : word) : word;

	{ Hehe... I'm probably the first person to use a random-number lookup
	table :) }

	begin
		rand := rtabl[rpos] mod (max + 1);
		inc (rpos, max);
		if rpos > 8191 then
		 begin
			rpos := random(128);
			rtabl[random(8192)] := random(65535);
		 end;
	end;

	(* My jump-tables go here *)

	procedure Null;

	begin
	end;

	(* Faders *)

	procedure FadeFire; assembler;

	asm
		les di, scr

		cmp page, 0
		je @Page0
		add di, 8192
	 @Page0:

		mov cx, 8000/2
	 @LoopFade:
		mov ax, [es:di+80]

		or al, al
		jz @nolow
		dec al
	 @nolow:

		or ah, ah
		jz @nohigh
		dec ah
	 @nohigh:

		stosw

		dec cx
		jnz @LoopFade
	 end;

	procedure FadeFireDown; assembler;

	asm
		les di, scr

		cmp page, 0
		je @Page0
		add di, 8192
	 @Page0:

		add di, 8000

		mov cx, (8000 - 80)/2
	 @LoopFade:
		mov ax, [es:di-80]

		or al, al
		jz @nolow
		dec al
	 @nolow:

		or ah, ah
		jz @nohigh
		dec ah
	 @nohigh:

		mov es:[di], ax
		sub di, 2

		dec cx
		jnz @LoopFade

		sub di, 80
		mov cx, 80/2
		xor ax, ax
		rep stosw
	 end;

	procedure FadeFlat; assembler;

	asm
		les di, scr
		cmp page, 0
		je @Page0
		add di, 8192
	 @Page0:

		mov cx, 8192/2
	 @LoopFade:
		mov ax, [es:di]

		or al, al
		jz @nolow
		dec al
	 @nolow:

		or ah, ah
		jz @nohigh
		dec ah
	 @nohigh:

		stosw

		dec cx
		jnz @LoopFade
	 end;

	{ The following are declared forward because they have a special case in
	slow-computer mode }

	procedure FadeLog; forward;
	procedure FadeILog; forward;
	procedure FadeCls; forward;

const
	numFade = 6;
	Fade : array[0..numFade] of procedure =
		(Null, FadeFire, FadeLog, FadeCls, FadeFlat, FadeILog, FadeFireDown);

	(* Effects *)

	procedure FXFire;

	var
		i, j : word;
		pos : word;

	begin
		pos := YTab80[99];
		if page = 1 then
			inc (pos, 8192);

		for i := 7 to 71 do
			scr2^[pos + i] := rand(bright div 2);

		asm
			les di, scr
			add di, pos
			add di, 1

			mov dx, 2
		 @Loop0:

			mov cx, 78
		 @Loop1:
			xor ah, ah
			xor bh, bh

			mov al, es:[di-1]
			mov bl, es:[di]
			add ax, bx
			mov bl, es:[di+1]
			add ax, bx
			mov bl, es:[di-80]
			add ax, bx

			shr ax, 1
			shr ax, 1
			stosb

			dec cx
			jnz @Loop1

			dec dx
			jnz @Loop0
		 end;
	end;

	procedure FXSine;

	var
		i, p0, pos : integer;
		fscl : shortint;

	begin
		fscl := sintab[(f and 127)*4] - 128;
		p0 := 8192*page;

		asm
			les di, scr

			mov cx, 512
		 @Loop1:
			dec cx

			mov di, p0

			mov si, cx
			shl si, 1
			add si, offset sintab80
			add di, ds:[si]
			add di, 40

			mov si, cx
			add si, offset costab
			xor ah, ah
			mov al, ds:[si]
			sub al, 128
			imul fscl
			mov al, ah
			xor ah, ah { the same as shr ax, 9 but a HELL of a lot faster :) }
			sar al, 1
			cbw
			add di, ax

			xor ah, ah
			mov al, bright
			mul cx
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1 { too bad there's no such speedup for shr ax, 7 :( }

			mov es:[di], al

			inc cx
			sub cx, 1
			jnz @Loop1
		 end;
	end;

	procedure FXSine2;

	var
		i, p0, pos : integer;
		fscl, fscl2 : shortint;

	begin
		fscl := sintab[(f*4) and 511] - 128;
		fscl2 := sintab[(f*6 + 64) and 511] - 128;
		p0 := 8192*page;

		asm
			les di, scr

			mov cx, 512
		 @Loop1:
			dec cx

			mov di, p0

			mov si, cx
			shl si, 1
			add si, offset sintab80
			add di, ds:[si]
			add di, 40

			mov si, cx
			add si, offset costab
			xor ah, ah
			mov al, ds:[si]
			sub al, 128
			imul fscl { Yes, I'm using mul.  So sue me for coding so that it'll run
				in just 96k of memory :) }
			mov al, ah
			xor ah, ah
			sar al, 1
			cbw
			add di, ax

			xor ah, ah
			mov al, bright
			mul cx
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1

			mov es:[di], al

			mov di, p0

			mov si, cx
			shl si, 1
			add si, offset sintab80d2
			add di, ds:[si]
			add di, 40

			mov si, cx
			add si, offset costab
			xor ah, ah
			mov al, ds:[si]
			sub al, 128
			imul fscl2
			mov al, ah
			xor ah, ah
			sar al, 1
			sar al, 1
			cbw
			add di, ax

			xor ah, ah
			mov al, bright
			mul cx
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1
			shr ax, 1

			mov es:[di], al

			inc cx
			sub cx, 1
			jnz @Loop1
		 end;
	end;

	procedure FXStar;

	var
		i, x, y, z, pos : word;
		drawn : boolean;

	begin
		for i := 0 to numstar do
		 begin
			asm
				les di, scr

				cmp page, 0
				je @Page0
				add di, 8192
			 @Page0:

				mov ax, i
				shl ax, 1
				shl ax, 1
				shl ax, 1
				add ax, offset stars
				mov si, ax

				mov [drawn], 0

				mov bx, ds:[si+4]
				or bx, bx
				jz @done

				mov ax, ds:[si]
				cwd
				shl ax, 1
				shl ax, 1
				idiv bx
				add al, 39

				cmp al, 80
				jnb @done

				xor ah, ah
				add di, ax

				mov ax, ds:[si+2]
				cwd
				shl ax, 1
				shl ax, 1
				idiv bx
				add al, 49

				cmp al, 100
				jnb @done

				xor ah, ah
				mov si, ax
				shl si, 1
				add si, offset YTab80
				add di, ds:[si]

				mov ax, 00FFh
				sub ax, bx
				mov bl, bright
				mul bl
				mov al, ah
				xor ah, ah { shr ax, 8 :) }

				mov es:[di], al
				mov [drawn], 1

			 @done:
			 end;

			dec (stars[i].z);
			if not drawn then
			 begin
				stars[i].x := rand(256) - 128;
				stars[i].y := rand(256) - 128;
				stars[i].z := 255;
			 end;
		 end;
	end;

	procedure FXSnow;

	var
		i, x, y, z, pos : word;
		drawn : boolean;

	begin
		for i := 0 to numsnow do
		 begin
			asm
				les di, scr

				cmp page, 0
				je @Page0
				add di, 8192
			 @Page0:

				mov ax, i
				shl ax, 1
				shl ax, 1
				shl ax, 1
				add ax, offset snows
				mov si, ax

				mov [drawn], 0

				mov bx, ds:[si+4]
				or bx, bx
				jz @done

				mov ax, ds:[si]
				cwd
				shl ax, 1
				shl ax, 1
				idiv bx
				add al, 39

				cmp al, 80
				jnb @done

				xor ah, ah
				add di, ax

				mov ax, ds:[si+2]
				cwd
				shl ax, 1
				shl ax, 1
				idiv bx
				add al, 49

				cmp al, 100
				jnb @done

				xor ah, ah
				mov si, ax
				shl si, 1
				add si, offset YTab80
				add di, ds:[si]

				mov ax, 00FFh
				sub ax, bx
				mov bl, bright
				mul bl
				mov al, ah
				xor ah, ah

				mov es:[di], al
				mov [drawn], 1

			 @done:
			 end;

			inc (snows[i].y);
			if not drawn then
			 begin
				snows[i].x := rand(256) - 128;
				snows[i].z := rand(63) + 1;
				snows[i].y := -49*snows[i].z div 4;
			 end;
		 end;
	end;

	procedure FXWave; assembler;

	{var
		i : integer;

	begin
		for i := 0 to 79 do
			scr^[page, YTab80[sintab[(i*2 + f*4 + 1) and 511] div 4 + 17] + i] := bright;
	end;}

	asm
		les di, scr

		cmp page, 0
		je @page0
		add di, 8192
	 @page0:

		mov cx, 80
	 @LoopX:
		mov bx, f
		shl bx, 1
		shl bx, 1
		add bx, 160
		sub bx, cx
		sub bx, cx
		inc bx
		and bx, 511
		mov si, offset sintab
		mov dl, [si+bx]
		xor bh, bh
		mov bl, dl

		shr bx, 1
		shr bx, 1
		add bx, 17
		shl bx, 1
		mov si, offset YTab80
		mov dx, [si+bx]
		mov bx, dx

		mov al, bright
		mov es:[di+bx], al
		inc di

		dec cx
		jnz @LoopX
	end;

	const
		{ This is left over from when I was trying to do a "words" effect which
		didn't work out.  I left the list of words in for various reasons,
		including one of the hidden parts. }
		numWords = 40;
		words : array[0..numWords - 1] of string[10] =
			('lies',
			 'truth',
			 'love',
			 'hate',
			 'greed',
			 'selfless',
			 'fear',
			 'comfort',
			 'time',
			 'trance',
			 'worship',
			 'belief',
			 'human',
			 'merciful',
			 'worthy',
			 'worthless',
			 'versatile',
			 'lame',
			 'celibate',
			 'whore',
			 'order',
			 'nature',
			 'opinion',
			 'fact',
			 'identity',
			 'name',
			 #1,
			 #2,
			 'uptight',
			 'easygoing',
			 'porcupine',
			 'hedgehog',
			 'asexual',
			 'bisexual',
			 'alive',
			 'immortal',
			 'EFNet  ',
			 'AnotherNet',
			 'eden',
			 'eden');

	procedure FXRandom;

	var
		i : word;

	begin
		for i := 0 to 63 do
			scr^[page, random(8000)] := random(bright);
	end;

	procedure FXShadebob;

	{ This was added in literally at the last minute.  I put it in about 30
	minutes before I uploaded my final version to Trixter. }

	var
		p : word;

	begin
		p := (sintab[(f*5) and 511] div 4 + 8 + YTab80[sintab[(f*6 + 64) and 511] div 4 + 18]) and 8191;
		asm
			les di, scr
			cmp page, 0
			jz @Page0
			add di, 8192
		 @Page0:

			add di, p

			mov si, offset[shadebob]

			mov cx, 8
		 @LoopY:
			mov bx, 4
		 @LoopX:
			mov ax, ds:[si+bx]
			add es:[di+bx], ax

			dec bx
			jnz @LoopX

			add si, 8
			add di, 80

			dec cx
			jnz @LoopY
		end;
	end;

const
	numFX = 8;
	fx : array[0..numFX] of procedure =
		(null, FXFire, FXSine, FXSine2, FXStar, FXSnow, FXWave, FXRandom, FXShadeBob);

	(* More specific fades *)
	{ My handling of the cases in this leaves a bit to be desired.  Oh well.
	Don't expect many comments in this place, since I can't even remember what
	the hell each bit does anyway. :) }

	procedure FadeLog;

	var
		lastbrt : word;
		i : byte;

	begin
		if page = 0 then
		 begin
			if not (smooth or (fec0 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				f := (f - 8) and 1023;
				for i := 8 downto 1 do
				 begin
					bright := lastbrt shr i;
					fx[fec0];
					f := (f + 1) and 1023;
				 end;
				bright := lastbrt;
			 end
			else
				asm
					les di, scr

					mov cx, 8192/2
				 @LoopFade:
					mov ax, [es:di]
					shr ax, 1
					and ax, 0FF7Fh
					stosw { Stosw is faster on the 8086.  NEVER use it in this case if
						you're coding for anything more modern. :) }

					dec cx
					jnz @LoopFade
				 end;
		 end
		else
		 begin
			if not (smooth or (fec1 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				f := (f - 8) and 1023;
				for i := 8 downto 1 do
				 begin
					bright := lastbrt shr i;
					fx[fec1];
					f := (f + 1) and 1023;
				 end;
				bright := lastbrt;
			 end
			else
				asm
					les di, scr
					add di, 8192

					mov cx, 8192/2
				 @LoopFade:
					mov ax, [es:di]
					shr ax, 1
					and ax, 0FF7Fh
					stosw

					dec cx
					jnz @LoopFade
				 end;
		 end;
	end;

	procedure FadeILog;

	var
		lastbrt : word;
		i : byte;

	begin
		if page = 0 then
		 begin
			if not (smooth or (fec0 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				f := (f - 8) and 1023;
				for i := 8 downto 1 do
				 begin
					bright := lastbrt shl i;
					fx[fec0];
					f := (f + 1) and 1023;
				 end;
				bright := lastbrt;
			 end
			else if fec0 = 4 then
				asm
					les di, scr

					mov si, offset stars
					add si, 6
					xor bh, bh

					mov cx, numstar
				 @Loop:
					mov bl, ds:[si]
					mov al, es:[di+bx]
					shl al, 1
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else if fec0 = 5 then
				asm
					les di, scr

					mov si, offset snows
					add si, 6
					xor bh, bh

					mov cx, numsnow
				 @Loop:
					mov bl, ds:[si]
					mov al, es:[di+bx]
					shl al, 1
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else
				asm
					les di, scr

					mov cx, 8192/2
				 @LoopFade:
					mov ax, [es:di]
					shr ax, 1
					and ax, 0FF7Fh
					stosw

					dec cx
					jnz @LoopFade
				 end;
		 end
		else
		 begin
			if not (smooth or (fec1 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				f := (f - 8) and 1023;
				for i := 8 downto 1 do
				 begin
					bright := lastbrt shl i;
					fx[fec1];
					f := (f + 1) and 1023;
				 end;
				bright := lastbrt;
			 end
			else if fec1 = 4 then
				asm
					les di, scr
					add di, 8192

					mov si, offset stars
					add si, 6
					xor bh, bh

					mov cx, numstar
				 @Loop:
					mov bl, ds:[si]
					mov al, es:[di+bx]
					shl al, 1
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else if fec1 = 5 then
				asm
					les di, scr
					add di, 8192

					mov si, offset snows
					add si, 6
					xor bh, bh

					mov cx, numsnow
				 @Loop:
					mov bl, ds:[si]
					mov al, es:[di+bx]
					shl al, 1
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else
				asm
					les di, scr
					add di, 8192

					mov cx, 8192/2
				 @LoopFade:
					mov ax, [es:di]
					shr ax, 1
					and ax, 0FF7Fh
					stosw

					dec cx
					jnz @LoopFade
				 end;
		 end;
	end;

	procedure FadeCls;

	var
		lastbrt : word;

	begin
		if page = 0 then
		 begin
			if not (smooth or (fec0 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				bright := 0;
				f := (f - 1) and 1023;
				fx[fec0];
				f := (f + 1) and 1023;
				bright := lastbrt;
			 end
			else if fec0 = 4 then
				asm
					les di, scr

					mov si, offset stars
					add si, 6
					xor bh, bh

					xor al, al

					mov cx, numstar
				 @Loop:
					mov bl, ds:[si]
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else if fec0 = 5 then
				asm
					les di, scr

					mov si, offset snows
					add si, 6
					xor bh, bh

					mov cx, numsnow
				 @Loop:
					mov bl, ds:[si]
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else
			 asm
				les di, scr

				mov cx, 8192/2
				mov ax, 0 { this should be xor ax, ax... oops :) }
				rep stosw
			 end;
		 end
		else
		 begin
			if not (smooth or (fec1 in [4, 5, 6])) then
			 begin
				lastbrt := bright;
				bright := 0;
				f := (f - 1) and 1023;
				fx[fec1];
				f := (f + 1) and 1023;
				bright := lastbrt;
			 end
			else if fec1 = 4 then
				asm
					les di, scr

					mov si, offset stars
					add si, 6
					xor bh, bh

					xor al, al

					mov cx, numstar
				 @Loop:
					mov bl, ds:[si]
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else if fec1 = 5 then
				asm
					les di, scr

					mov si, offset snows
					add si, 6
					xor bh, bh

					mov cx, numsnow
				 @Loop:
					mov bl, ds:[si]
					mov es:[di+bx], al

					add si, 8
					dec cx
					jnz @Loop
				end
			else
			 asm
				les di, scr
				add di, 8192

				mov cx, 8192/2
				mov ax, 0
				rep stosw
			 end;
		 end;
	end;

(* This bit ripped from Test8086.Pas by Trixter / Hornet *)

function CPUSpd : word;

Const
	Processor_cycles: Array[0..4] Of Byte = (165, 165, 25, 103, 42);
	{Cycle times of 8086, 80186, 80286, 80386, 80486}

	{
	Notice that here I have defined the 8086 as a Processor type of 0 vice
	the returned value of 1 from WhatCPU.  Since the original code did not
	distinguish between the 8086 and the 80186, I can get away with this.
	}

Var
	Ticks,
	Cycles,
	CPS:                                                                                LongInt;
	Which_CPU:Word;

Function i86_to_i286:Word;Assembler;

	Asm { Function i86_to_i286 }
		CLI
		MOV   CX,1234
		XOr   DX,DX
		XOr   AX,AX
		MOV   AL,$B8
		OUT   $43,AL
		In    AL,$61
		Or    AL,1
		OUT   $61,AL
		XOr   AL,AL
		OUT   $42,AL
		OUT   $42,AL
		XOr   AX,AX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		IDIV  CX
		In    AL,$42
		MOV   AH,AL
		In    AL,$42
		XCHG  AL,AH
		NEG   AX
		STI
	End;  { Function i86_to_i286 }

Function i386_to_i486:Word;Assembler;

	Asm  { Function i386_to_i486 }
		CLI
		MOV   AL,$B8
		OUT   $43,AL
		In    AL,$61
		Or    AL,1
		OUT   $61,AL
		XOr   AL,AL
		OUT   $42,AL
		OUT   $42,AL
		DB 66H,$B8,00h,00h,00h,80h;
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		DB 66H,0FH,$BC,$C8; { BSF ECX,EAX }
		In    AL,42H
		MOV   AH,AL
		In    AL,42H
		XCHG  AL,AH
		NEG   AX
		STI
	End;  { Function i386_to_486 }

Begin  { Procedure CPUSpd }
	Which_CPU := Test8086;
	If Which_cpu < 3
	Then Ticks := i86_to_i286
	Else Ticks := i386_to_i486;
	Cycles := 20 * Processor_cycles[Which_CPU];
	CPS := (Cycles * 119318) Div Ticks;
	CPUSpd {MHz} := CPS Div 100000;
	{KHz := (CPS Mod 100000 + 500) Div 1000}
	{CPUSpd := 20*42*119318 div ticks;}
End;  { Procedure CPUSpd }

(* That ends the section of code so majorly ripped that I didn't even bother
changing it to my style :) *)

begin
	writeln ('VGALess - (c)1995-6 Quantum Porcupine');
	writeln ('Use parameters ''greetz'' and ''credz'' for, well, hmmm, I forgot. :)');
	writeln;

	for i := 1 to paramcount do
		if paramstr(i) = 'greetz' then
		 begin
			writeln ('Greetings go to:');
			writeln;
			writeln ('Tran - Thanks for, well, guess... :)');
			writeln ('TCA / NewOrder - Thanks for the bit of code I put into the VGA driver, and');
			writeln ('  for all the guidance you''ve thrown at me whether I liked it or not!');
			writeln ('Reality members - Thanks for RAD, ''coz it is');
			writeln ('Trixter / Hornet - Thanks for putting up with my countless betas, fixing my');
			writeln ('  endless stupidity, and the CPU speed code in Test8086.Pas :)');
			writeln ('All 8086 compo judges - Thanks for judging, no matter what the result is.');
			writeln ('  I had fun doing this anyway, and that outweighs any of the prizes you will');
			writeln ('  undoubtedly throw at me. :)');
			writeln ('ae - May the best porcupine win! :)');
			writeln ('All the IRC lusers who gave me help with CGA programming... ancient card,');
			writeln ('  hard as hell to code on. :)');
			writeln ('Everybody else - Thanks for watching, and keep on the lookout for... well,');
			writeln ('  anything done by anybody! :)');
			writeln;
			exit;
		 end
		else if paramstr(i) = 'credz' then
		 begin
			writeln ('Credits for this fine production:');
			writeln;
			writeln ('Code, Gfx - Quantum Porcupine / Versatile(?) Productions');
			writeln ('VGA driver initialization - TCA / NewOrder');
			writeln ('Music - "Rain" by Tran (ripped and adjusted by QP, used with permission)');
			writeln ('Beta testing and CPU speed test code - Trixter / Hornet');
			writeln;
			writeln ('Note: no matter what BigCheese may say, no other members of DAMN!/Versatile');
			writeln ('had anything to do with the production of this demo. :)');
			writeln;

			exit;
		 end
		else if paramstr(i) = 'wordz' then  (* hidden part #1 *)
		 begin
			writeln ('Quantum''s Words of the Day are:');
			writeln;
			for i := 0 to numwords - 1 do
				write (words[i] : 10);
			writeln;
			writeln ('And on that happy note...');
			writeln;
			readkey;
		 end
		else
		 begin
			mode := paramstr(i);
			for j := 1 to length(mode) do
				mode[j] := upcase(mode[j]);
		 end;

	if (paramcount = 0)
			or not (mode[1] = '/')
			or not (mode[2] in ['C', 'M', 'Q', 'V', 'G', 'T'])
			or not (mode[3] in ['Y', 'N']) then
	 begin
		mode := '/';

		writeln ('What video mode?');
		writeln;
		writeln ('Key  Card  Mode     ');
		writeln ('--------------------');
		writeln ('C    CGA   256-color');
		writeln ('M    CGA   256-gray ');
		writeln ('T    Tandy 256-color');
		writeln ('V    VGA   256-color');
		writeln ('G    VGA   256-gray ');
		writeln;

		writeln ('Note: Tandy is graphics *only*.  Sound is unsupported ''coz I need more than');
		writeln ('3-channel square waves. :)');
		writeln;

		writeln;
		write ('-> ');
		repeat
			ch := upcase(readkey);
		until ch in ['C', 'M', 'Q', 'V', 'G', 'T'];
		writeln (ch);
		writeln;
		mode := mode+ch;

		writeln ('How smooth do you want it?');
		writeln;
		writeln ('Key  Choice');
		writeln ('----------------------------------------------------------');
		writeln ('N    Let it go as fast as possible on my pitiful machine');
		writeln ('       (Paced by music, inaccurate but fast effects)');
		writeln ('Y    Let it go smooth as possible on my speed-demon (Paced');
		writeln ('       by self, accurate but "slow" effects.  Reccomended:');
		writeln ('       486DX-50 or higher with cache, 486DX/4-100 without)');
		writeln;

		write ('BTW, I strongly reccomend you choose ');
		if CPUSpd >= 50 then
		 begin
			writeln ('Y, unless you want quantized colors,');
			writeln ('which can actually look kind of cool :)');
		 end
		else
		 begin
			writeln ('N, unless you want it to take a few');
			writeln ('minutes for each effect (No! No! No! :)');
		 end;

		writeln;
		write ('-> ');
		repeat
			ch := upcase(readkey);
		until ch in ['N', 'Y'];
		writeln (ch);
		writeln;
		mode := mode+ch;
	 end;

	smooth := mode[3] = 'Y';

	randomize;

	vga := true;
	case upcase(mode[2]) of
		'C' : begin
			asm
				mov ax, 004h
				int 10h
			 end;

			scr := ptr($B800, 0);
			vga := false;
		 end;
		'M' : begin
			asm
				mov ax, 006h
				int 10h
			 end;

			scr := ptr($B800, 0);
			vga := false;
		 end;
		'Q' : begin  (* hidden part #2 *)
			asm
				mov ax, 013h
				int 10h
			 end;

			new (scr);
			vga := true;
			setscanlines (1);
			move (ptr(seg(firepalette), ofs(firepalette)+1)^, pal, 768);
			setpalette (pal);
		 end;
		'T' : begin
			asm
				mov ax, 08h
				int 10h
			 end;

			scr := ptr($B800, 0);
			vga := false;
		 end;
		'V' : begin
			Init80;

			new (scr);
			move ((@Pal332Pack)^, pal, 768);
			setpalette (pal);
		 end;
		'G' : begin
			Init80;

			new (scr);
			for i := 0 to 767 do
				pal[i div 3, i mod 3] := i div 12;
			setpalette (pal);
		 end;
	 end;

	fillchar (scr^, 16384, 0);
	scr2 := @(scr^);

	InstallFastRADTimer;
	case Mode[4] of
		'0' : PlayRADPtr (@NotCompoMusic); (* hidden part #3 *)
		else PlayRADPtr (@CompoMusic);
	 end;

	for i := 0 to 199 do
		YTab80[i] := i*80;
	for i := 0 to 511 do
	 begin
		sintab[i] := trunc(sin(i*pi/256)*128) + 127;
		sintab80[i] := YTab80[sintab[i]*100 div 256];
		sintab80d2[i] := YTab80[sintab[i]*50 div 256 + 25];
		costab[i] := trunc(cos(i*pi/256)*128) + 127;
	 end;
	for i := 0 to 8191 do
		rtabl[i] := random(65535);

	numstar := mini(numstars*cpuspd div 50, numstars);
	numsnow := mini(numsnows*cpuspd div 50, numsnows);

	for i := 0 to numstar do
		with stars[i] do
		 begin
			x := random(256) - 128;
			y := random(256) - 128;
			z := random(255) + 1;
		 end;
	for i := 0 to numsnow do
		with snows[i] do
		 begin
			x := random(256) - 128;
			y := random(256) - 128;
			z := random(63) + 1;
		 end;

	for i := 0 to 7 do
		for j := 0 to 7 do
			shadebob[i, j] := (32 - (sqr(i - 4) + sqr(j - 4)))*2;

	f0 := 0;
	fad0 := 0;
	fec0 := 0;
	fad1 := 0;
	fec1 := 0;
	repeat
		repeat  (* IntHappened is set to true every time the music-playback
			interrupt (called 70 times per second) is activated *)
		until IntHappened;
		IntHappened := false;

		if keypressed then
			quit := true;

		b := orderpos*64 + line;
		if b < 63 then
			f0 := 0
		else if b = 63 then
			f0 := 768
		else
			inc (f0);

		fr := f0 and 1023;
		f := fr;

		if not (smooth or (b < 64)) then
			fr := (b*8 + speedcnt*8 div speed) and 1023;

		page := 0;
		bright := sintab[(fr and 1023) div 2];
		if fr = 768 then
		 begin
			fad0 := random(numFade + 1);

			repeat
				inc (fec0, random(numFade) + 1);
				fec0 := fec0 mod (numFX + 1);
			until (fec0 or fec1) <> 0;

			if fec0 = 1 then
				fad0 := 1
			else if fec0 = 2 then
				fad0 := 2;
		 end;
		{$IFDEF DEBUG}
			setcolor (0, 63, 0, 0);
		{$ENDIF}
		fade[fad0];
		{$IFDEF DEBUG}
			setcolor (0, 63, 63, 0);
		{$ENDIF}
		fx[fec0];
		{$IFDEF DEBUG}
			setcolor (0, 0, 0, 0);
		{$ENDIF}

		page := 1;
		bright := costab[(fr mod 1024) div 2];
		if fr = 512 then
		 begin
			fad1 := random(numFade + 1);

			repeat
				inc (fec1, random(numFade) + 1);
				fec1 := fec1 mod (numFX + 1);
			until (fec0 or fec1) <> 0;

			if fec1 = 1 then
				fad1 := 1
			else if fec1 = 2 then
				fad1 := 2;
		 end;
		{$IFDEF DEBUG}
			setcolor (0, 0, 0, 63);
		{$ENDIF}
		fade[fad1];
		{$IFDEF DEBUG}
			setcolor (0, 0, 63, 63);
		{$ENDIF}
		fx[fec1];
		{$IFDEF DEBUG}
			setcolor (0, 0, 0, 0);
		{$ENDIF}

		if vga then
			CGAToVGA;
	until quit;

	while keypressed do
		readkey;

	UninstallRADTimer;

	{ This next bit of code I cannot account for.  I must have been stoned when
	I did it.  I don't remember getting stoned either. }

	endpic := @EndPicture;
	if not (smooth and vga) then
	 begin
		for i := 0 to 255 do
		 begin
			page := 0;
			FadeFlat;

			page := 1;
			FadeFlat;

			if vga then
				cgatovga;

			j := (255 - i) div 4;
			for f := 0 to 8 do
				if (63 - j) > Old43[f] then
					asm
						mov ax, f
						mov cl, al
						mov ax, j
						mov ch, al
						call SetVolume
					 end;
		 end;
		if vga then
			setpalette ((@EndPalette)^);

		move (endpic^, scr^, 80*100);
		if vga then
			CGAToVGA;

		page := 0;
		if not vga then
			FadeFlat;

		repeat
			readkey;
		until not keypressed;
		{ Ack... flashback to one rather painful thread on
		comp.lang.pascal.borland :) }

		if smooth then
			for i := 0 to 255 do
			 begin
				if (i and 1) = 0 then
					retrace;
				page := 0;
				FadeFlat;
				if vga then
					CGAtoVGA;
			 end
		else
			for i := 0 to 8 do
			 begin
				smooth := true;
				for j := 0 to 3 do
					retrace;
				FadeLog;
				smooth := false;
				if vga then
					CGAToVGA;
			 end;
	 end
	else
	 begin
		for i := 63 downto 0 do
		 begin
			for j := 0 to 255 do
				for f := 0 to 2 do
					if pal[j, f] > 0 then
						dec (pal[j, f]);
			retrace;
			setpalette (pal);

			for f := 0 to 8 do
				asm
					mov ax, f
					mov cl, al
					mov ax, i
					mov ch, al
					call SetVolume
				 end;
		 end;

		for i := 0 to 15 do
			retrace;
		asm
			mov ax, 013h
			int 10h
		 end;

		setpalette (pal);
		for i := 0 to 15 do
			retrace;

		for i := 0 to 99 do
			move (endpic^[i*80], vscr[i*320+16120], 80);

		move ((@endpalette)^, pal, 768);
		for i := 0 to 63 do
		 begin
			retrace;
			for j := 0 to 255 do
				setcolor (j, mini(pal[j, 0], i), mini(pal[j, 1], i), mini(pal[j, 2], i));
		 end;

		repeat
			readkey;
		until not keypressed;

		scr := @vscr;
		for i := 0 to 255 do
		 begin
			retrace;
			asm
				les di, scr
				add di, 160-40

				mov dx, 100+50
				sub dx, i
				cmp dx, 0
				jng @NoDraw
			 @LoopY:

				mov cx, 80
			 @LoopX:
				xor ah, ah
				xor bh, bh
				mov al, es:[di-1]
				mov bl, es:[di+1]
				add ax, bx
				mov bl, es:[di]
				add ax, bx
				mov bl, es:[di+320]
				add ax, bx
				shr ax, 1
				shr ax, 1
				mov es:[di], al

				inc di

				dec cx
				jnz @LoopX

				add di, 320-80

				dec dx
				jnz @LoopY

			 @NoDraw:
			 end;

			if i and 3 = 0 then
			 begin
				for j := 0 to 255 do
					for f := 0 to 2 do
						if pal[j, f] > 0 then
							dec (pal[j, f]);
				setpalette (pal);
			 end;
		 end;
	 end;

	delay (500);
	StopRAD;

	for i := 0 to 3 do
		retrace;
	asm
		mov ax, 003h
		int 10h
	 end;
	textcolor (lightgray);
	if vga then
		setcolor (lightgray, 0, 0, 0);

	for i := 0 to 3 do
		retrace;

	writeln ('VGAless/Shades/Tranbience/Ytal (c)1995-6 Quantum Porcupine');
	writeln ('Contact: jshagam@nmsu.edu, http://web.nmsu.edu/~jshagam');
	writeln;
	randomize;
	case random(12) of  (* semi-hidden part thingy *)
		0 : writeln ('I think, therefore I am [a porcupine]');
		1 : writeln ('Ajatella siksi min„');
		2 : writeln ('Ornatus impeditur');
		3 : writeln ('Min„ olen piikkisika');
		4 : writeln ('Minnun nimeni on Kvantti Piikkisika, murhaaja siilin!');
		5 : writeln ('I dare to jar the senses!');
		6 : writeln ('And remember kids, Slaughter is just Laughter with an S!');
		7 : writeln ('I didn''t do it!');
		8 : writeln ('It was like that when I got here!');
		9 : writeln ('Cogito ergo non es');
		10 : writeln ('This statement is false');
		11 : begin
			writeln ('You know what looks really cool?  If the detection says to choose "Y" for');
			writeln ('smoothness, choose "N" instead.  It looks especially cool with the flaming');
			writeln ('double-spheres.  Try it! :)');
		 end;
	 end;
	writeln;
	writeln;
	if paramcount = 0 then
	 begin
		writeln ('For future reference:  Start this up with parameter:');
		writeln;
		writeln (mode);
		writeln;
		writeln ('to use the settings chosen for this run.');
		writeln;
	 end;

	if vga then
		for i := 0 to 63 do
		 begin
			retrace;
			setcolor (lightgray, i*32 div 64, i*16 div 64, i*64 div 64);
		 end;
end.