unit TxtScrIO;
interface

const
  Black   = $00;  DGray    = $08;
  Blue    = $01;  LBlue    = $09;
  Green   = $02;  LGreen   = $0a;
  Cyan    = $03;  LCyan    = $0b;
  Red     = $04;  LRed     = $0c;
  Magenta = $05;  LMagenta = $0d;
  Brown   = $06;  Yellow   = $0e;
  LGray   = $07;  White    = $0f;
  Blink   = $80;

procedure ShowStr(var dest; x,y: Byte; str: String; attr: Byte);
procedure ShowVStr(var dest; x,y: Byte; str: String; attr: Byte);
procedure ShowCStr(var dest; x,y: Byte; str: String; atr1,atr2: Byte);
procedure ShowVCStr(var dest; x,y: Byte; str: String; atr1,atr2: Byte);
procedure ShowC3Str(var dest; x,y: Byte; str: String; atr1,atr2,atr3: Byte);
procedure ShowVC3Str(var dest; x,y: Byte; str: String; atr1,atr2,atr3: Byte);
function CStrLen(str: String): Byte;
function AbsPos(x,y: Byte): Word;
function Color(fgnd,bgnd: Byte): Byte;
procedure CleanScreen(var dest);
procedure initialize;

type
  tCUSTOM_VIDEO_MODE = 0..52;

procedure SetCustomVideoMode(vmode: tCUSTOM_VIDEO_MODE);

type
  tFRAME_SETTING = Record
                     shadow_enabled,
                     wide_range_type,
                     zooming_enabled,
                     update_area: Boolean;
                   end;
const
  fr_setting: tFRAME_SETTING =
    (shadow_enabled:  TRUE;
     wide_range_type: FALSE;
     zooming_enabled: FALSE;
     update_area:     TRUE);

procedure Frame(var dest; x1,y1,x2,y2,atr1: Byte;
                          title: String; atr2: Byte; border: String);

const
  solid1 = '        ';
  solid2 = '€ﬂ€€€€‹€';
  single = '⁄ƒø≥≥¿ƒŸ';
  double = '…Õª∫∫»Õº';
  dbside = '÷ƒ∑∫∫”ƒΩ';
  dbtop  = '’Õ∏≥≥‘Õæ';

var
  MaxLn,MaxCol,
  work_maxln,work_maxcol: Byte;
  area_x1,area_y1,area_x2,area_y2: Byte;
  v_mode: Byte;
  DispPg: Byte;
  v_seg,v_ofs: Longint;
  CheckSnow: Boolean;

function iEGA:  Boolean;
function iVGA:  Boolean;
function iPS2:  Boolean;
function iMDA:  Boolean;
function iCGA:  Boolean;
function iMCGA: Boolean;

function  WhereX: Byte;
function  WhereY: Byte;
procedure GotoXY(x,y: Byte);
procedure ResetMode;

function  GetCursor: Longint;
procedure SetCursor(cursor: Longint);
procedure ThinCursor;
procedure WideCursor;
procedure HideCursor;
function  GetCursorShape: Word;
procedure SetCursorShape(shape: Word);

type
  tVIDEO_STATE = Record
                   font: Byte;
                   cursor: Longint;
                   MaxLn,MaxCol,v_mode: Byte;
                   v_ofs: Longint;
                   screen: array[0..PRED(8192)] of Byte;
                   data: array[0..PRED(4096)] of Byte;
                 end;

procedure GetVideoState(var data: tVIDEO_STATE);
procedure SetVideoState(var data: tVIDEO_STATE; restore_screen: Boolean);
procedure GetRGBitem(color: Byte; var red,green,blue: Byte);
procedure SetRGBitem(color: Byte; red,green,blue: Byte);
procedure WaitRetrace;
procedure GetPalette(var pal; first,last: Word);
procedure SetPalette(var pal; first,last: Word);

type
  tFADE  = (first,fadeOut,fadeIn);
  tDELAY = (fast,delayed);

type
  tFADE_BUF = Record
                action: tFADE;
                pal0: array[0..255] of Record r,g,b: Byte end;
                pal1: array[0..255] of Record r,g,b: Byte end;
              end;

const
  fade_speed: Byte = 63;

procedure VgaFade(var data: tFADE_BUF; fade: tFADE; delay: tDELAY);
procedure RefreshEnable;
procedure RefreshDisable;
procedure Split2Static;
procedure SplitScr(line: Integer);
procedure SetSize(columns,lines: Integer);
procedure SetTextDisp(x,y: Integer);

implementation
uses DPMI;

var
  absolute_pos: Word;

procedure DupChar; assembler;
asm
        pushad                           {  IN/ al     -column        }
        xor     ebx,ebx                  {      ah     -line          }
        xchg    ax,bx                    {      dl     -character     }
        xor     eax,eax                  {      dh     -attribute     }
        xchg    ax,bx                    {      ecx    -count         }
        mov     bl,al                    {      edi    -ptr. to write }
        mov     al,MaxCol
        mul     ah
        add     ax,bx
        mov     bl,MaxCol
        sub     ax,bx
        dec     ax
        shl     ax,1
        jecxz   @@1
        add     edi,eax
        xchg    ax,dx
        rep     stosw
        xchg    ax,dx
@@1:    mov     absolute_pos,ax
        popad
end;

procedure ShowStr(var dest; x,y: Byte; str: String; attr: Byte); assembler;
asm
        mov     edi,[dest]
        mov     esi,[str]
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        lodsb
        mov     cl,al
        jecxz   @@2
        add     edi,edx
        mov     ah,attr
@@1:    lodsb
        stosw
        loop    @@1
@@2:
end;

procedure ShowVStr(var dest; x,y: Byte; str: String; attr: Byte); assembler;
asm
        mov     al,MaxCol
        dec     al
        xor     ah,ah
        xor     ebx,ebx
        mov     bl,2
        mul     bl
        mov     bx,ax
        mov     edi,[dest]
        mov     esi,[str]
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        lodsb
        mov     cl,al
        jecxz   @@2
        add     edi,edx
        mov     ah,attr
@@1:    lodsb
        stosw
        add     edi,ebx
        loop    @@1
@@2:
end;

procedure ShowCStr(var dest; x,y: Byte; str: String; atr1,atr2: Byte); assembler;
asm
        mov     esi,[str]
        mov     edi,[dest]
        lodsb
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
        push    ecx
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        pop     ecx
        add     edi,edx
        mov     ah,atr1
        mov     bh,atr2
@@1:    lodsb
        cmp     al,'~'
        jz      @@2
        stosw
        loop    @@1
        jmp     @@3
@@2:    xchg    ah,bh
        loop    @@1
@@3:
end;

procedure ShowVCStr(var dest; x,y: Byte; str: String; atr1,atr2: Byte); assembler;
asm
        mov     al,MaxCol
        dec     al
        xor     ah,ah
        mov     bl,2
        mul     bl
        mov     bx,ax
        mov     esi,[str]
        mov     edi,[dest]
        lodsb
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
        push    ecx
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        pop     ecx
        add     edi,edx
        mov     dx,bx
        mov     ah,atr1
        mov     bh,atr2
@@1:    lodsb
        cmp     al,'~'
        jz      @@2
        stosw
        add     edi,edx
        loop    @@1
        jmp     @@3
@@2:    xchg    ah,bh
        loop    @@1
@@3:
end;

procedure ShowC3Str(var dest; x,y: Byte; str: String; atr1,atr2,atr3: Byte); assembler;
asm
        mov     esi,[str]
        mov     edi,[dest]
        lodsb
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
        push    ecx
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        pop     ecx
        add     edi,edx
        mov     ah,atr1
        mov     bl,atr2
        mov     bh,atr3
@@1:    lodsb
        cmp     al,'~'
        jz      @@2
        cmp     al,'`'
        jz      @@3
        stosw
        loop    @@1
        jmp     @@4
@@2:    xchg    ah,bl
        loop    @@1
        jmp     @@4
@@3:    xchg    ah,bh
        loop    @@1
@@4:
end;

procedure ShowVC3Str(var dest; x,y: Byte; str: String; atr1,atr2,atr3: Byte); assembler;
asm
        mov     al,MaxCol
        dec     al
        xor     ah,ah
        mov     bl,2
        mul     bl
        mov     bx,ax
        mov     esi,[str]
        mov     edi,[dest]
        lodsb
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@4
        push    ecx
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        xor     edx,edx
        mov     dx,absolute_pos
        pop     ecx
        add     edi,edx
        mov     dx,bx
        mov     ah,atr1
        mov     bl,atr2
        mov     bh,atr3
@@1:    lodsb
        cmp     al,'~'
        jz      @@2
        cmp     al,'`'
        jz      @@3
        stosw
        add     edi,edx
        loop    @@1
        jmp     @@4
@@2:    xchg    ah,bl
        loop    @@1
        jmp     @@4
@@3:    xchg    ah,bh
        loop    @@1
@@4:
end;

function CStrLen(str: String): Byte; assembler;
asm
        mov     edi,[str]
        xor     ecx,ecx
        mov     cl,[edi]
        inc     edi
        mov     bx,cx
        jecxz   @@2
        mov     al,'~'
@@1:    repne   scasb
        jnz     @@2
        dec     bx
        jmp     @@1
@@2:    mov     ax,bx
end;

function AbsPos(x,y: Byte): Word; assembler;
asm
        mov     al,x
        mov     ah,y
        xor     ecx,ecx
        call    DupChar
        mov     ax,absolute_pos
end;

function Color(fgnd,bgnd: Byte): Byte; assembler;
asm
        mov     al,bgnd
        xor     ah,ah
        mov     bh,16
        mul     bh
        add     al,fgnd
end;

procedure CleanScreen(var dest); assembler;
asm
        mov     edi,[dest]
        mov     al,1
        mov     bh,1
        mov     cl,MaxCol
        xor     ch,ch
@@1:    mov     ah,bh
        mov     dl,' '
        mov     dh,07h
        call    DupChar
        inc     bh
        cmp     bh,MaxLn
        jle     @@1
end;

procedure Frame(var dest; x1,y1,x2,y2,atr1: Byte;
                          title: String; atr2: Byte; border: String); assembler;
var
  xexp1,xexp2,xexp3,yexp1,yexp2: Byte;
  offs: Longint;

asm
        cmp     fr_setting.update_area,1
        jnz     @@0
        mov     al,x1
        mov     area_x1,al
        mov     al,y1
        mov     area_y1,al
        mov     al,x2
        mov     area_x2,al
        mov     al,y2
        mov     area_y2,al
@@0:    mov     bl,fr_setting.wide_range_type
        mov     bh,fr_setting.shadow_enabled
        mov     esi,[border]
        mov     edi,[dest]
        mov     offs,edi
        cmp     bl,0
        je      @@1
        mov     xexp1,4
        mov     xexp2,-1
        mov     xexp3,7
        mov     yexp1,1
        mov     yexp2,2
        jmp     @@2
@@1:    mov     xexp1,1
        mov     xexp2,2
        mov     xexp3,1
        mov     yexp1,0
        mov     yexp2,1
        jmp     @@4
@@2:    mov     al,x1
        sub     al,3
        mov     ah,y1
        dec     ah
        mov     dl,' '
        mov     dh,atr1
        xor     ecx,ecx
        mov     cl,x2
        sub     cl,x1
        add     cl,7
        call    DupChar
        mov     ah,y2
        inc     ah
        call    DupChar
        mov     bl,y1
@@3:    mov     al,x1
        sub     al,3
        mov     ah,bl
        mov     dl,' '
        mov     ecx,3
        call    DupChar
        mov     al,x2
        inc     al
        mov     dl,' '
        mov     ecx,3
        call    DupChar
        inc     bl
        cmp     bl,y2
        jng     @@3
@@4:    mov     al,x1
        mov     ah,y1
        mov     dl,[esi+1]
        mov     dh,atr1
        mov     ecx,1
        push    edi
        call    DupChar
        inc     al
        mov     dl,[esi+2]
        mov     dh,atr1
        mov     cl,x2
        sub     cl,x1
        dec     cl
        call    DupChar
        mov     al,x2
        mov     dl,[esi+3]
        mov     dh,atr1
        mov     ecx,1
        call    DupChar
        mov     bl,y1
@@5:    inc     bl
        mov     al,x1
        mov     ah,bl
        mov     dl,[esi+4]
        mov     dh,atr1
        mov     ecx,1
        call    DupChar
        inc     al
        mov     dl,' '
        mov     dh,atr1
        mov     cl,x2
        sub     cl,x1
        dec     cl
        call    DupChar
        mov     al,x2
        mov     dl,[esi+5]
        mov     dh,atr1
        mov     ecx,1
        call    DupChar
        cmp     bl,y2
        jnge    @@5
        mov     al,x1
        mov     ah,y2
        mov     dl,[esi+6]
        mov     dh,atr1
        mov     ecx,1
        call    DupChar
        inc     al
        mov     dl,[esi+7]
        mov     cl,x2
        sub     cl,x1
        dec     cl
        call    DupChar
        mov     al,x2
        mov     dl,[esi+8]
        mov     dh,atr1
        mov     ecx,1
        call    DupChar
        mov     esi,[title]
        mov     cl,[esi]
        jecxz   @@7
        xor     eax,eax
        mov     al,x2
        sub     al,x1
        sub     al,cl
        mov     bl,2
        div     bl
        add     al,x1
        add     al,ah
        mov     ah,y1
        xor     ecx,ecx
        call    DupChar
        push    eax
        xor     eax,eax
        mov     ax,absolute_pos
        mov     edi,offs
        add     edi,eax
        pop     eax
        lodsb
        mov     cl,al
        mov     ah,atr2
@@6:    lodsb
        stosw
        loop    @@6
@@7:    cmp     bh,0
        je      @@11
        mov     bl,y1
        sub     bl,yexp1
@@8:    inc     bl
        mov     al,x2
        add     al,xexp1
        mov     ah,bl
        xor     ecx,ecx
        call    DupChar
        push    eax
        xor     eax,eax
        mov     ax,absolute_pos
        mov     edi,offs
        add     edi,eax
        pop     eax
        inc     edi
        mov     al,07
        stosb
        cmp     MaxLn,80
        jae     @@9
        inc     edi
        stosb
        cmp     MaxCol,132
        jna     @@9
        inc     edi
        stosb
@@9:    cmp     bl,y2
        jng     @@8
        mov     al,x1
        add     al,xexp2
        mov     ah,y2
        add     ah,yexp2
        xor     ecx,ecx
        call    DupChar
        push    eax
        xor     eax,eax
        mov     ax,absolute_pos
        mov     edi,offs
        add     edi,eax
        pop     eax
        inc     edi
        mov     al,07
        mov     cl,x2
        sub     cl,x1
        add     cl,xexp3
        cmp     MaxLn,45
        jb      @@10
        dec     cl
@@10:   stosb
        inc     edi
        loop    @@10
@@11:
end;

function iEGA: Boolean; assembler;
asm
        mov     ax,01200h
        mov     bx,00010h
        mov     cx,0ffffh
        int     10h
        cmp     cx,0ffffh
        jz      @@1
        mov     al,1
        jmp     @@2
@@1:    xor     al,al
@@2:
end;

function iVGA: Boolean; assembler;
asm
        mov     ax,1a00h
        int     10h
        cmp     al,1ah
        jnz     @@1
        cmp     bl,7
        jb      @@1
        cmp     bl,0ffh
        jnz     @@2
@@1:    xor     al,al
        jmp     @@3
@@2:    mov     al,1
@@3:
end;

function iPS2: Boolean; assembler;
asm
        mov     ax,1a00h
        int     10h
        and     al,0ffh
        cmp     al,1ah
        jnz     @@1
        and     bl,0ffh
        cmp     bl,07h
        jb      @@1
        cmp     bl,0ch
        ja      @@1
        cmp     bl,09h
        jz      @@1
        cmp     bl,0ah
        jz      @@1
        mov     al,1
        jmp     @@2
@@1:    xor     al,al
@@2:
end;

function iMDA: Boolean; assembler;
asm
        cmp     v_mode,07h
        jnz     @@1
        mov     al,1
        jmp     @@2
@@1:    xor     al,al
@@2:
end;

function iCGA: Boolean; assembler;
asm
        call    iMDA
        cmp     al,0
        jnz     @@1
        call    iEGA
        cmp     al,0
        jnz     @@1
        call    iPS2
        cmp     al,0
        jnz     @@1
        mov     al,1
        jmp     @@2
@@1:    xor     al,al
@@2:
end;

function iMCGA: Boolean; assembler;
asm
        call    iMDA
        cmp     al,0
        jnz     @@1
        call    iEGA
        cmp     al,0
        jnz     @@1
        call    iPS2
        cmp     al,1
        jnz     @@1
        mov     al,1
        jmp     @@2
@@1:    xor     al,al
@@2:
end;

function WhereX: Byte; assembler;
asm
        mov     bh,DispPg
        mov     ah,03h
        int     10h
        inc     dl
        mov     al,dl
end;

function WhereY: Byte; assembler;
asm
        mov     bh,DispPg
        mov     ah,03h
        int     10h
        inc     dh
        mov     al,dh
end;

procedure GotoXY(x,y: Byte); assembler;
asm
        mov     dh,y
        mov     dl,x
        dec     dh
        dec     dl
        mov     bh,DispPg
        mov     ah,02h
        int     10h
end;

procedure ResetMode; assembler;
asm
        xor     ah,ah
        mov     al,v_mode
        mov     bh,DispPg
        int     10h
end;

function GetCursor: Longint; assembler;
asm
        xor     edx,edx
        mov     bh,DispPg
        mov     ah,03h
        int     10h
        shl     edx,16
        xor     eax,eax
        push    edx
        call    GetCursorShape
        pop     edx
        add     edx,eax
        mov     eax,edx
end;


procedure SetCursor(cursor: Longint); assembler;
asm
        xor     eax,eax
        mov     ax,word ptr [cursor]
        push    eax
        call    SetCursorShape
        mov     dx,word ptr [cursor+2]
        mov     bh,DispPg
        mov     ah,02h
        int     10h
end;

procedure ThinCursor; assembler;
asm
        xor     ecx,ecx
        call    iMDA
        cmp     al,1
        jnz     @@1
        mov     cx,0b0ch
        jmp     @@5
@@1:    call    iCGA
        cmp     al,1
        jnz     @@2
        mov     cx,0708h
        jmp     @@5
@@2:    call    iMCGA
        cmp     al,1
        jnz     @@3
        mov     cx,0708h
        jmp     @@5
@@3:    call    iVGA
        cmp     al,1
        jnz     @@4
        mov     cx,0d0eh
        jmp     @@5
@@4:    mov     cx,0b0ch
@@5:    push    ecx
        call    SetCursorShape
end;

procedure WideCursor; assembler;
asm
        xor     ecx,ecx
        call    iMDA
        cmp     al,1
        jnz     @@1
        mov     cx,010ch
        jmp     @@5
@@1:    call    iCGA
        cmp     al,1
        jnz     @@2
        mov     cx,0107h
        jmp     @@5
@@2:    call    iMCGA
        cmp     al,1
        jnz     @@3
        mov     cx,0107h
        jmp     @@5
@@3:    call    iVGA
        cmp     al,1
        jnz     @@4
        mov     cx,010eh
        jmp     @@5
@@4:    mov     cx,010ch
@@5:    push    ecx
        call    SetCursorShape
end;

procedure HideCursor; assembler;
asm
        xor     ecx,ecx
        mov     cx,1010h
        push    ecx
        call    SetCursorShape
end;

function GetCursorShape: Word; assembler;
asm
        mov     dx,03d4h
        mov     al,0ah
        out     dx,al
        inc     dx
        in      al,dx
        and     al,1fh
        mov     ah,al
        dec     dx
        mov     al,0bh
        out     dx,al
        inc     dx
        in      al,dx
        and     al,1fh
end;

procedure SetCursorShape(shape: Word); assembler;
asm
        mov     dx,03d4h
        mov     al,0ah
        out     dx,al
        inc     dx
        in      al,dx
        mov     ah,BYTE(shape)[1]
        and     al,0e0h
        or      al,ah
        out     dx,al
        dec     dx
        mov     al,0bh
        out     dx,al
        inc     dx
        in      al,dx
        mov     ah,BYTE(shape)[0]
        and     al,0e0h
        or      al,ah
        out     dx,al
end;

procedure initialize;
begin
  asm
        mov     ah,0fh
        int     10h
        and     al,7fh
        mov     v_mode,al
        mov     DispPg,bh
  end;

  If (MEM[0:$449] = 7) then
    begin
      v_seg := $0b000;
      MaxLn := 25;
    end
  else begin
         v_seg := $0b800;
         MaxLn := SUCC(MEM[0:$484]);
       end;

  v_ofs  := MEM[0:$44e];
  MaxCol := MEM[0:$44a];

  work_MaxLn  := MaxLn;
  work_MaxCol := MaxCol;

  If iCGA then CheckSnow := TRUE
  else CheckSnow := FALSE;
end;

var
  dos_seg: Word;
  bios_data_backup: array[0..167] of Byte;
  regs: tRmRegs;

procedure GetVideoState(var data: tVIDEO_STATE);
begin
  Move(Ptr(v_seg,v_ofs)^,data.screen,SizeOf(data.screen));
  data.cursor := GetCursor;
  data.font := MEMW[0:$0485];
  data.v_mode := v_mode;
  data.MaxLn := MaxLn;
  data.MaxCol := MaxCol;
  data.v_ofs := v_ofs;
  Move(MEM[$40:0],bios_data_backup,168);
  dos_seg := DosMemoryAlloc(SizeOf(tVIDEO_STATE(data).data));
  ClearRmRegs(regs);
  regs.cx := 7;
  regs.es := dos_seg;
  regs.ax := $1c01;
  RealModeInt($10,regs);
  Move(bios_data_backup,MEM[$40:0],168);
  Move(POINTER(DWORD(dos_seg)*16)^,tVIDEO_STATE(data).data,
       SizeOf(tVIDEO_STATE(data).data));
  DosMemoryFree(dos_seg);
end;

procedure SetVideoState(var data: tVIDEO_STATE; restore_screen: Boolean);
begin
  v_mode := data.v_mode;
  ResetMode;
  Move(MEM[$40:0],bios_data_backup,168);
  dos_seg := DosMemoryAlloc(SizeOf(tVIDEO_STATE(data).data));
  Move(tVIDEO_STATE(data).data,POINTER(DWORD(dos_seg)*16)^,
       SizeOf(tVIDEO_STATE(data).data));
  ClearRmRegs(regs);
  regs.cx := 7;
  regs.es := dos_seg;
  regs.ax := $1c02;
  RealModeInt($10,regs);
  DosMemoryFree(dos_seg);
  Move(bios_data_backup,MEM[$40:0],168);

  MEM[0:$44e] := data.v_ofs;
  MEM[0:$484] := PRED(data.MaxLn);
  MEM[0:$44a] := data.MaxCol;

  Case data.font of
     8:  asm mov ax,1112h; xor bl,bl; int 10h end;
    14:  asm mov ax,1111h; xor bl,bl; int 10h end;
    else asm mov ax,1114h; xor bl,bl; int 10h end;
  end;

  initialize;
  SetCursor(data.cursor);
  If restore_screen then
    Move(data.screen,Ptr(v_seg,v_ofs)^,SizeOf(data.screen));
end;

procedure GetRGBitem(color: Byte; var red,green,blue: Byte);
begin
  PORT[$3c7] := color;
  red   := PORT[$3c9];
  green := PORT[$3c9];
  blue  := PORT[$3c9];
end;

procedure SetRGBitem(color: Byte; red,green,blue: Byte);
begin
  PORT[$3c8] := color;
  PORT[$3c9] := red;
  PORT[$3c9] := green;
  PORT[$3c9] := blue;
end;

procedure WaitRetrace; assembler;
asm
        mov     dx,3dah
@@1:    in      al,dx
        and     al,08h
        jnz     @@1
@@2:    in      al,dx
        and     al,08h
        jz      @@2
end;

procedure GetPalette(var pal; first,last: Word); assembler;
asm
        xor     eax,eax
        xor     ecx,ecx
        mov     ax,first
        mov     cx,last
        sub     ecx,eax
        inc     ecx
        mov     dx,03c7h
        out     dx,al
        add     dx,2
        mov     edi,[pal]
        add     edi,eax
        add     edi,eax
        add     edi,eax
        mov     eax,ecx
        add     ecx,eax
        add     ecx,eax
        rep     insb
end;

procedure SetPalette(var pal; first,last: Word); assembler;
asm
        mov     dx,03dah
@@1:    in      al,dx
        test    al,8
        jz      @@1
        xor     eax,eax
        xor     ecx,ecx
        mov     ax,first
        mov     cx,last
        sub     ecx,eax
        inc     ecx
        mov     dx,03c8h
        out     dx,al
        inc     dx
        mov     esi,[pal]
        add     esi,eax
        add     esi,eax
        add     esi,eax
        mov     eax,ecx
        add     ecx,eax
        add     ecx,eax
        rep     outsb
end;

const
  fade_first: Byte = 0;
  fade_last:  Byte = 255;

procedure wait_ms; assembler;
asm
@@1:    mov     di,-1*1193*2
        xor     al,al
        out     43h,al
        in      al,40h
        mov     bl,al
        in      al,40h
        mov     bh,al
@@2:    xor     al,al
        out     43h,al
        in      al,40h
        mov     ah,al
        in      al,40h
        xchg    ah,al
        sub     ax,bx
        cmp     ax,di
        jnc     @@2
end;

procedure VgaFade(var data: tFADE_BUF; fade: tFADE; delay: tDELAY);

var
  i,j: Byte;

begin
  If (fade = fadeOut) and (data.action in [first,fadeIn]) then
    begin
      GetPalette(data.pal0,fade_first,fade_last);
      If delay = delayed then
        For i := fade_speed downto 0 do
          begin
            For j := fade_first to fade_last do
              begin
                data.pal1[j].r := data.pal0[j].r * i DIV fade_speed;
                data.pal1[j].g := data.pal0[j].g * i DIV fade_speed;
                data.pal1[j].b := data.pal0[j].b * i DIV fade_speed;
              end;
            SetPalette(data.pal1,fade_first,fade_last);
            wait_ms;
          end
      else
        begin
          FillChar(data.pal1,SizeOf(data.pal1),0);
          SetPalette(data.pal1,fade_first,fade_last);
        end;
      data.action := fadeOut;
    end;

  If (fade = fadeIn) and (data.action = fadeOut) then
    begin
      If delay = delayed then
        For i := 0 to fade_speed do
          begin
            For j := fade_first to fade_last do
              begin
                data.pal1[j].r := data.pal0[j].r * i DIV fade_speed;
                data.pal1[j].g := data.pal0[j].g * i DIV fade_speed;
                data.pal1[j].b := data.pal0[j].b * i DIV fade_speed;
              end;
            SetPalette(data.pal1,fade_first,fade_last);
            wait_ms;
          end
      else
        SetPalette(data.pal0,fade_first,fade_last);
      data.action := fadeIn;
    end;
end;

procedure RefreshEnable; assembler;
asm mov ax,1200h; mov bl,36h; int 10h end;

procedure RefreshDisable; assembler;
asm mov ax,1201h; mov bl,36h; int 10h end;

procedure Split2Static;

var
  temp: Byte;

begin
  temp := PORT[$3da];
  PORT[$3c0] := $10 OR $20;
  PORT[$3c0] := PORT[$3c1] OR $20;
end;

procedure SplitScr(line: Integer);

var
  temp: Byte;

begin
  PORT[$3d4] := $18;
  PORT[$3d5] := LO(line);
  PORT[$3d4] := $07;
  temp := PORT[$3d5];

  If (line < $100) then temp := temp AND $0ef
  else temp := temp OR $10;

  PORT[$3d5] := temp;
  PORT[$3d4] := $09;
  temp := PORT[$3d5];

  If (line < $200) then temp := temp AND $0bf
  else temp := temp OR $40;

  PORT[$3d5] := temp;
end;

procedure SetSize(columns,lines: Integer);
begin
  PORT[$3d4] := $13;
  PORT[$3d5] := columns SHR 1;
  MEMW[$0000:$44a] := columns;
  MEMW[$0000:$484] := lines-1;
  MEMW[$0000:$44c] := columns*lines;
end;

procedure SetTextDisp(x,y: Integer);

var
  temp: Byte;

begin
  While (PORT[$3da] AND 1 =  1) do ;
  While (PORT[$3da] AND 1 <> 1) do ;

  PORT[$3d4] := $0c;
  PORT[$3d5] := HI((y SHR 4)*MaxCol+(x DIV 9));
  PORT[$3d4] := $0d;
  PORT[$3d5] := LO((y SHR 4)*MaxCol+(x DIV 9));
  PORT[$3d4] := $08;
  PORT[$3d5] := (PORT[$3d5] AND $0e0) OR (y AND $0f);
  temp := PORT[$3da];
  PORT[$3c0] := $13 OR $20;
  PORT[$3c0] := (x+9) MOD 9;
end;

procedure SetCustomVideoMode(vmode: tCUSTOM_VIDEO_MODE);

const
  vmode_data: array[0..52,0..63] of Byte = (

{ 1..5   - BIOS variables,
  6..9   - Sequencer,
  10     - Miscellaneous Output,
  11..35 - CRTC,
  36..55 - Attribute,
  56..64 - Graphics   }

{  0, Text 36x14, 9x14, complete }
(  36,  13,  14,   0, 4,     8,   3,   0,   2,    99,
  40, 35, 36,138, 38,192,183, 31,  0,205, 11, 12,  0,  0,  0,
   0,148,134,135, 18, 31,142,177,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  1, Text 40x14, 8x14, complete }
(  40,  13,  14,   0, 5,     9,   3,   0,   2,    99,
  45, 39, 40,144, 43,160,183, 31,  0,205, 11, 12,  0,  0,  0,
   0,148,134,135, 20, 31,142,177,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  2, Text 40x14, 9x14, complete }
(  40,  13,  14,   0, 5,     8,   3,   0,   2,   103,
  45, 39, 40,144, 43,160,183, 31,  0,205, 11, 12,  0,  0,  0,
   0,148,134,135, 20, 31,142,177,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  3, Text 46x14, 8x14, complete }
(  46,  13,  14,   0, 6,     9,   3,   0,   2,   103,
  52, 45, 46,151, 50,150,183, 31,  0,205, 11, 12,  0,  0,  0,
   0,148,134,135, 23, 31,142,177,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{  4, Text 36x15, 9x16, complete }
(  36,  14,  16,  0, 5,     8,   3,   0,   2,   227,
  40, 35, 36,138, 38,192, 11, 62,  0,207, 13, 14,  0,  0,  0,
   0,234,172,223, 18, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  5, Text 40x15, 8x16, complete }
(  40,  14,  16,   0, 5,     9,   3,   0,   2,   227,
  45, 39, 40,144, 43,160, 11, 62,  0,207, 13, 14,  0,  0,  0,
   0,234,172,223, 20, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  6, Text 40x15, 9x16, complete }
(  40,  14,  16,   0, 5,     8,   3,   0,   2,   231,
  45, 39, 40,144, 43,160, 11, 62,  0,207, 13, 14,  0,  0,  0,
   0,234,172,223, 20, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  7, Text 46x15, 8x16, complete }
(  46,  14,  16,   0, 6,     9,   3,   0,   2,   231,
  52, 45, 46,151, 50,150, 11, 62,  0,207, 13, 14,  0,  0,  0,
   0,234,172,223, 23, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{  8, Text 36x17, 9x14, complete }
(  36,  16,  14,   0, 5,     8,   3,   0,   2,   227,
  40, 35, 36,138, 38,192,  7, 62,  0,205, 11, 12,  0,  0,  0,
   0,230,168,219, 18, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{  9, Text 40x17, 8x14, complete }
(  40,  16,  14,   0, 6,     9,   3,   0,   2,   227,
  45, 39, 40,144, 43,160,  7, 62,  0,205, 11, 12,  0,  0,  0,
   0,230,168,219, 20, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 10, Text 40x17, 9x14, complete }
(  40,  16,  14,   0, 6,     8,   3,   0,   2,   231,
  45, 39, 40,144, 43,160,  7, 62,  0,205, 11, 12,  0,  0,  0,
   0,230,168,219, 20, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 11, Text 46x17, 9x14, complete }
(  46,  16,  14,   0, 7,     9,   3,   0,   2,   231,
  52, 45, 46,151, 50,150,  7, 62,  0,205, 11, 12,  0,  0,  0,
   0,230,168,219, 23, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 12, Text 36x22, 9x16, complete }
(  36,  21,  16,   0, 7,     8,   3,   0,   2,   163,
  40, 35, 36,138, 38,192,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 18, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 13, Text 40x22, 8x16, complete }
(  40,  21,  16,   0, 7,     9,   3,   0,   2,   163,
  45, 39, 40,144, 43,160,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 20, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 14, Text 40x22, 9x16, complete }
(  40,  21,  16,   0, 7,     8,   3,   0,   2,   167,
  45, 39, 40,144, 43,160,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 20, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 15, Text 46x22, 8x16, complete }
(  46,  21,  16,   0, 8,     9,   3,   0,   2,   167,
  52, 45, 46,151, 50,150,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 23, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 16, Text 70x22, 9x16, complete }
(  70,  21,  16,   0,13,     0,   3,   0,   2,   163,
  83, 69, 70,150, 75, 21,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 35, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 17, Text 80x22, 8x16, complete }
(  80,  21,  16,   0,14,     1,   3,   0,   2,   163,
  95, 79, 80,130, 85,129,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 40, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 18, Text 80x22, 9x16, complete }
(  80,  21,  16,   0,14,     0,   3,   0,   2,   167,
  95, 79, 80,130, 85,129,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 40, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 19, Text 90x22, 8x16, complete }
(  90,  21,  16,   0,16,     1,   3,   0,   2,   167,
 107, 89, 90,142, 95,138,193, 31,  0, 79, 13, 14,  0,  0,  0,
   0,133,165, 95, 45, 31,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 20, Text 36x25, 9x16, complete }
(  36,  24,  16,   0, 8,     8,   3,   0,   2,    99,
  40, 35, 36,138, 38,192,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 18, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 21, Text 40x25, 8x16, complete }
(  40,  24,  16,   0, 8,     9,   3,   0,   2,    99,
  45, 39, 40,144, 43,160,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 20, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 22, Text 40x25, 9x16, complete }
(  40,  24,  16,   0, 8,     8,   3,   0,   2,   103,
  45, 39, 40,144, 43,160,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 20, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 23, Text 46x25, 8x16, complete }
(  46,  24,  16,   0,10,     9,   3,   0,   2,   103,
  52, 45, 46,151, 50,150,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 23, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 24, Text 70x25, 9x16, complete }
(  70,  24,  16,   0,14,     0,   3,   0,   2,   99,
  83, 69, 70,150, 75, 21,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 35, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 25, Text 80x25, 8x16, complete }
(  80,  24,  16,   0,16,     1,   3,   0,   2,   99,
  95, 79, 80,130, 85,129,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 40, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 26, Text 80x25, 9x16, standard }
(  80,  24,  16,   0,16,     0,   3,   0,   2,   103,
  95, 79, 80,130, 85,129,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 40, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 27, Text 90x25, 8x16, complete }
(  90,  24,  16,  0, 18  ,   1,   3,   0,   2,  103,
 107, 89, 90,142, 95,138,191, 31,  0, 79, 13, 14,  0,  0,  0,
   0,156,142,143, 45, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 28, Text 46x29, 8x16, complete }
(  46,  28,  14,   0,11,     9,   3,   0,   2,   103,
  52, 45, 46,151, 50,150,193, 31,  0, 77, 11, 12,  0,  0,  0,
   0,159,145,149, 23, 31,155,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 29, Text 70x29, 9x14, complete }
(  70,  28,  14,  0, 16  ,   0,   3,   0,   2,   99,
  83, 69, 70,150, 75, 21,193, 31,  0, 77, 11, 12,  0,  0,  0,
   0,159,145,149, 35, 31,155,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 30, Text 80x29, 8x14, complete }
(  80,  28,  14,  0, 19  ,   1,   3,   0,   2,   99,
  95, 79, 80,130, 85,129,193, 31,  0, 77, 11, 12,  0,  0,  0,
   0,159,145,149, 40, 31,155,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 31, Text 80x29, 9x14, complete }
(  80,  28,  14,  0, 19  ,   0,   3,   0,   2,  103,
  95, 79, 80,130, 85,129,193, 31,  0, 77, 11, 12,  0,  0,  0,
   0,159,145,149, 40, 31,155,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 32, Text 90x29, 8x14, complete }
(  90,  28,  14,  0, 21  ,   1,   3,   0,   2,  103,
 107, 89, 90,142, 95,138,193, 31,  0, 77, 11, 12,  0,  0,  0,
   0,159,145,149, 45, 31,155,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 33, Text 70x30, 9x16, complete }
(  70,  29,  16,  0, 17  ,   0,   3,   0,   2,  227,
  83, 69, 70,150, 75, 21, 11, 62,  0, 79, 13, 14,  0,  0,  0,
   0,234,172,223, 35, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 34, Text 80x30, 8x16, complete }
(  80,  29,  16,  0, 19  ,   1,   3,   0,   2,  227,
  95, 79, 80,130, 85,129, 11, 62,  0, 79, 13, 14,  0,  0,  0,
   0,234,172,223, 40, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 35, Text 80x30, 9x16, complete }
(  80,  29,  16,  0, 19  ,   0,   3,   0,   2,  231,
  95, 79, 80,130, 85,129, 11, 62,  0, 79, 13, 14,  0,  0,  0,
   0,234,172,223, 40, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 36, Text 90x30, 8x16 ,complete }
(  90,  29,  16,  0, 22  ,   1,   3,   0,   2,  231,
 107, 89, 90,142, 95,138, 11, 62,  0, 79, 13, 14,  0,  0,  0,
   0,234,172,223, 45, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 37, Text 70x34, 9x14, complete }
(  70,  33,  14,  0, 19  ,   0,   3,   0,   2,  227,
  83, 69, 70,150, 75, 21,  7, 62,  0, 77, 11, 12,  0,  0,  0,
   0,230,168,219, 35, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 38, Text 80x34, 8x14, complete }
(  80,  33,  14,  0, 22  ,   1,   3,   0,   2,  227,
  95, 79, 80,130, 85,129,  7, 62,  0, 77, 11, 12,  0,  0,  0,
   0,230,168,219, 40, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 39, Text 80x34, 9x14, complete }
(  80,  33,  14,  0, 22  ,   0,   3,   0,   2,  231,
  95, 79, 80,130, 85,129,  7, 62,  0, 77, 11, 12,  0,  0,  0,
   0,230,168,219, 40, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 40, Text 90x34, 8x14, complete }
(  90,  33,  14,  0, 24  ,   1,   3,   0,   2,  231,
 107, 89, 90,142, 95,138,  7, 62,  0, 77, 11, 12,  0,  0,  0,
   0,230,168,219, 45, 31,227,  2,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 41, Text 70x44, 9x8, complete }
(  70,  43,   8,   0,25,     0,   3,   0,   2,   163,
  83, 69, 70,150, 75, 21,193, 31,  0, 71,  6,  7,  0,  0,  0,
   0,133,135, 95, 35, 15,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 42, Text 80x44, 8x8, complete }
(  80,  43,   8,   0,28,     1,   3,   0,   2,   163,
  95, 79, 80,130, 85,129,193, 31,  0, 71,  6,  7,  0,  0,  0,
   0,133,135, 95, 40, 15,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 43, Text 80x44, 9x8, complete }
(  80,  43,   8,   0,28,     0,   3,   0,   2,   167,
  95, 79, 80,130, 85,129,193, 31,  0, 71,  6,  7,  0,  0,  0,
   0,133,135, 95, 40, 15,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 44, Text 90x44, 8x8, complete }
(  90,  43,   8,   0,31,     1,   3,   0,   2,   167,
 107, 89, 90,142, 95,138,193, 31,  0, 71,  6,  7,  0,  0,  0,
   0,133,135, 95, 45, 15,101,187,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 45, Text 70x50, 9x8, complete }
(  70,  49,   8,   0,28,     0,   3,   0,   2,   99,
  83, 69, 70,150, 75, 21,191, 31,  0, 71,  6,  7,  0,  0,  0,
   0,156,142,143, 35, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 46, Text 80x50, 8x8, complete }
(  80,  49,   8,   0,32,     1,   3,   0,   2,   99,
  95, 79, 80,130, 85,129,191, 31,  0, 71,  6,  7,  0,  0,  0,
   0,156,142,143, 40, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 47, Text 80x50, 9x8, standard }
(  80,  49,   8,   0,32,     0,   3,   0,   2,   103,
  95, 79, 80,130, 85,129,191, 31,  0, 71,  6,  7,  0,  0,  0,
   0,156,142,143, 40, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63, 12,  0, 15, 8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 48, Text 90x50, 8x8, complete }
(  90,  49,   8,  0, 36  ,   1,   3,   0,   2,  103,
 107, 89, 90,142, 95,138,191, 31,  0, 71,  6,  7,  0,  0,  0,
   0,156,142,143, 45, 31,150,185,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),


{ 49, Text 70x60, 9x8, complete }
(  70,  59,   8,  0, 33  ,   0,   3,   0,   2,  227,
  83, 69, 70,150, 75, 21, 11, 62,  0, 71,  6,  7,  0,  0,  0,
   0,234,172,223, 35, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 50, Text 80x60, 8x8, complete }
(  80,  59,   8,  0, 38  ,   1,   3,   0,   2,  227,
  95, 79, 80,130, 85,129, 11, 62,  0, 71,  6,  7,  0,  0,  0,
   0,234,172,223, 40, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 51, Text 80x60, 9x8, complete }
(  80,  59,   8,  0, 38  ,   0,   3,   0,   2,  231,
  95, 79, 80,130, 85,129, 11, 62,  0, 71,  6,  7,  0,  0,  0,
   0,234,172,223, 40, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  8,
    0,   0,   0,   0,   0,  16,  14,   0, 255),

{ 52, Text 90x60, 8x8, complete }
(  90,  59,   8,128, 42  ,   1,   3,   0,   2,  231,
 107, 89, 90,142, 95,138, 11, 62,  0, 71,  6,  7,  0,  0,  0,
   0,234,172,223, 45, 31,231,  6,163,255,  0,  1,  2,  3,  4,
   5, 20,  7, 56, 57, 58, 59, 60, 61, 62, 63,  8,  0, 15,  0,
    0,   0,   0,   0,   0,  16,  14,   0, 255)

);

begin
  asm
        movzx   eax,vmode
        shl     eax,6
        lea     esi,[vmode_data]
        add     esi,eax
        mov     dx,3cch
        in      al,dx
        mov     dl,0d4h
        test    al,1
        jnz     @@1
        mov     dl,0b4h
  @@1:  add     dx,6
        in      al,dx
        xor     al,al
        mov     dx,3c0h
        out     dx,al
        mov     ax,100h
        mov     dx,3c4h
        out     dx,ax
        add     esi,5
        mov     ecx,4
        mov     al,1
        mov     dx,3c4h
  @@2:  mov     ah,[esi]
        inc     esi
        out     dx,ax
        inc     al
        loop    @@2
        mov     al,[esi]
        inc     esi
        mov     dx,3c2h
        out     dx,al
        mov     dx,3c4h
        mov     ax,300h
        out     dx,ax
        mov     dx,3cch
        in      al,dx
        mov     dl,0d4h
        test    al,1
        jnz     @@3
        mov     dl,0b4h
  @@3:  movzx   edi,SEG0040
        shl     edi,4
        add     edi,63h
        shl     edi,4
        mov     [edi],dx
        mov     al,11h
        out     dx,al
        inc     dx
        mov     ah,al
        in      al,dx
        dec     dx
        xchg    al,ah
        and     ah,7fh
        out     dx,ax
        mov     ecx,25
        xor     al,al
  @@4:  mov     ah,[esi]
        inc     esi
        out     dx,ax
        inc     al
        loop    @@4
        add     dx,6
        in      al,dx
        xor     ah,ah
        mov     ecx,20
        mov     dx,3c0h
  @@5:  mov     al,ah
        out     dx,al
        inc     ah
        mov     al,[esi]
        inc     esi
        out     dx,al
        loop    @@5
        xor     al,al
        mov     ecx,9
        mov     dx,3ceh
  @@6:  mov     ah,[esi]
        inc     esi
        out     dx,ax
        inc     al
        loop    @@6
        mov     dx,3c0h
        mov     al,32
        out     dx,al
  end;

  MEM[SEG0040:$4a] := vmode_data[vmode,0];
  MEM[SEG0040:$84] := vmode_data[vmode,1];
  MEM[SEG0040:$85] := vmode_data[vmode,2];
  MEM[SEG0040:$4c] := vmode_data[vmode,3];
  MEM[SEG0040:$4d] := vmode_data[vmode,4];
  FillChar(MEM[SEG0040:$4e],17,0);

  MEM[SEG0040:$60] := vmode_data[vmode,20];
  MEM[SEG0040:$61] := vmode_data[vmode,21];
  MEM[SEG0040:$62] := 0;

  Case vmode_data[vmode,2] of
     8: asm mov ah,11h; mov al,2; xor bx,bx; int 10h end;
    14: asm mov ah,11h; mov al,1; xor bx,bx; int 10h end;
    16: asm mov ah,11h; mov al,4; xor bx,bx; int 10h end;
  end;

  initialize;
  CleanScreen(Ptr(v_seg,v_ofs)^);
end;

begin
  initialize;
end.
