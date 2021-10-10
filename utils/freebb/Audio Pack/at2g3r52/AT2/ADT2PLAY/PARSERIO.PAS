unit ParserIO;
interface

type
  tDUMMY_BUFF = array[0..PRED(655350)] of Byte;

function Scan(var buf; skip,size: Longint; str: String): Longint;
function SensitiveScan(var buf; skip,size: Longint; str: String): Longint;
function Compare(var buf1,buf2; size: Longint): Boolean;
function Empty(var buf; size: Longint): Boolean;
function CountLines(var buf; size: Longint): Longint;
function Update16(var buf; size: Longint; crc: Word): Word;
function Update32(var buf; size: Longint; crc: Longint): Longint;

implementation

var
  CRC16_table: array[BYTE] of Word;
  CRC32_table: array[BYTE] of Longint;

function Scan(var buf; skip,size: Longint; str: String): Longint; assembler;
asm
        mov     edi,[str]
        mov     esi,[str]
        xor     eax,eax
        lodsb
        stosb
        xor     ecx,ecx
        mov     ecx,eax
        xor     ebx,ebx
        mov     ebx,eax
        jecxz    @@9
@@1:    lodsb
        cmp     al,'a'
        jb      @@2
        cmp     al,'z'
        ja      @@2
        sub     al,20h
@@2:    stosb
        loop    @@1
        sub     edi,ebx
        mov     esi,[buf]
        add     esi,skip
        mov     ecx,size
        sub     ecx,skip
        jecxz   @@8
        cld
        sub     ecx,ebx
        jb      @@8
        inc     ecx
@@4:    mov     ah,[edi]
        and     ah,NOT 20h
@@5:    lodsb
        and     al,NOT 20h
        cmp     al,ah
        loopne  @@5
        jne     @@8
        dec     esi
        mov     edx,ecx
        mov     ecx,ebx
@@6:    repe    cmpsb
        je      @@10
        mov     al,[esi-1]
        cmp     al,'a'
        jb      @@7
        cmp     al,'z'
        ja      @@7
        sub     al,20h
@@7:    cmp     al,[edi-1]
        je      @@6
        sub     ecx,ebx
        add     esi,ecx
        add     edi,ecx
        inc     esi
        mov     ecx,edx
        jne     @@4
@@8:    xor     eax,eax
        jmp     @@11
@@9:    mov     eax,1
        jmp     @@11
@@10:   sub     esi,ebx
        mov     eax,esi
        sub     eax,dword ptr buf
        inc     eax
@@11:   dec     eax
end;

function SensitiveScan(var buf; skip,size: Longint; str: String): Longint; assembler;
asm
        mov     edi,[buf]
        add     edi,skip
        mov     esi,[str]
        mov     ecx,size
        sub     ecx,skip
        xor     eax,eax
        jecxz   @@3
        cld
        lodsb
        cmp     al,1
        jb      @@5
        ja      @@1
        lodsb
        repne   scasb
        jne     @@3
        jmp     @@5
@@1:    xor     ah,ah
        mov     ebx,eax
        dec     ebx
        mov     edx,ecx
        sub     edx,eax
        jb      @@3
        lodsb
        add     edx,2
@@2:    dec     edx
        mov     ecx,edx
        repne   scasb
        jne     @@3
        mov     edx,ecx
        mov     ecx,ebx
        rep     cmpsb
        je      @@4
        sub     ecx,ebx
        add     esi,ecx
        add     edi,ecx
        inc     edi
        or      edx,edx
        jne     @@2
@@3:    xor     eax,eax
        jmp     @@6
@@4:    sub     edi,ebx
@@5:    mov     eax,edi
        sub     eax,dword ptr buf
@@6:    dec     eax
end;

function Compare(var buf1,buf2; size: Longint): Boolean; assembler;
asm
        xor     edx,edx
        mov     eax,size
        cmp     eax,16
        jb      @@3
        mov     ecx,4
        div     ecx
        mov     ecx,eax
        jecxz   @@1
        mov     esi,[buf1]
        mov     edi,[buf2]
        cld
        repz    cmpsd
        jnz     @@2
        mov     ecx,edx
        jecxz   @@1
        repz    cmpsb
        jnz     @@2
@@1:    mov     al,1
        jmp     @@6
@@2:    xor     al,al
        jmp     @@6
@@3:    mov     ecx,size
        jecxz   @@4
        mov     esi,[buf1]
        mov     edi,[buf2]
        cld
        repz    cmpsb
        jnz     @@5
@@4:    mov     al,1
        jmp     @@6
@@5:    xor     al,al
@@6:
end;

function Empty(var buf; size: Longint): Boolean; assembler;
asm
        xor     edx,edx
        mov     eax,size
        cmp     eax,16
        jb      @@3
        mov     ecx,4
        div     ecx
        mov     ecx,eax
        jecxz   @@1
        mov     edi,[buf]
        xor     eax,eax
        repz    scasd
        jnz     @@2
        mov     ecx,edx
        jecxz   @@1
        repz    scasb
        jnz     @@2
@@1:    mov     al,1
        jmp     @@6
@@2:    xor     al,al
        jmp     @@6
@@3:    mov     ecx,size
        jecxz   @@4
        mov     edi,[buf]
        xor     eax,eax
        repz    scasb
        jnz     @@5
@@4:    mov     al,1
        jmp     @@6
@@5:    xor     al,al
@@6:
end;

function CountLines(var buf; size: Longint): Longint; assembler;
asm
        mov     edi,[buf]
        mov     ecx,size
        mov     edx,edi
        add     edx,ecx
        xor     ebx,ebx
        jecxz   @@3
@@1:    mov     al,0dh
        repnz   scasb
        jnz     @@3
        cmp     byte ptr [edi],0ah
        jnz     @@2
        inc     edi
        inc     ebx
@@2:    cmp     edi,edx
        jb      @@1
@@3:    mov     eax,ebx
end;

function Update16(var buf; size: Longint; crc: Word): Word; assembler;
asm
        mov     esi,[buf]
        lea     edi,[CRC16_table]
        mov     bx,crc
        mov     ecx,size
        jecxz   @@2
@@1:    xor     ax,ax
        lodsb
        mov     dl,bh
        xor     dh,dh
        xor     bh,bh
        xor     bx,ax
        and     ebx,000000ffh
        shl     ebx,1
        mov     bx,[edi+ebx]
        xor     bx,dx
        loop    @@1
@@2:    mov     ax,bx
end;

function Update32(var buf; size: Longint; crc: Longint): Longint; assembler;
asm
        mov     esi,[buf]
        lea     edi,[CRC32_table]
        mov     ebx,crc
        mov     ecx,size
        jecxz   @@2
@@1:    xor     eax,eax
        lodsb
        xor     ebx,eax
        mov     edx,ebx
        and     ebx,000000ffh
        shl     ebx,2
        mov     ebx,[edi+ebx]
        shr     edx,8
        and     edx,00ffffffh
        xor     ebx,edx
        loop    @@1
@@2:    mov     eax,ebx
end;

procedure make_table_16bit;

var
  crc: Word;
  n,index: Byte;

begin
  For index := 0 to 255 do
  begin
    crc := index;
    For n := 1 to 8 do
      If Odd(crc) then crc := crc SHR 1 XOR $0a001
      else crc := crc SHR 1;
    CRC16_table[index] := crc;
  end;
end;

procedure make_table_32bit;

var
  crc: DWord;
  n,index: Byte;

begin
  For index := 0 to 255 do
    begin
      crc := index;
      For n := 1 to 8 do
        If Odd(crc) then crc := crc SHR 1 XOR $0edb88320
        else crc := crc SHR 1;
      CRC32_table[index] := crc;
    end;
end;

begin
  make_table_16bit;
  make_table_32bit;
end.
