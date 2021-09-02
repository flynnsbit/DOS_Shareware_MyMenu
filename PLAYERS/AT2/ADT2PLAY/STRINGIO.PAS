unit StringIO;
interface

type
  characters = Set of Char;

function Capitalize(str: String): String;
function Upper(str: String): String;
function Lower(str: String): String;
function iCASE(str: String): String;
function RotStrL(str1,str2: String; shift: Byte): String;
function RotStrR(str1,str2: String; shift: Byte): String;
function ExpStrL(str: String; size: Byte; chr: Char): String;
function ExpStrR(str: String; size: Byte; chr: Char): String;
function DietStr(str: String; size: Byte): String;
function CutStr(str: String): String;
function FlipStr(str: String): String;
function FilterStr(str: String; chr0,chr1: Char): String;
function FilterStr2(str: String; chr0: characters; chr1: Char): String;
function Num2str(num: Longint; base: Byte): String;
function Str2num(str: String; base: Byte): Longint;

type
  tINPUT_STR_SETTING = Record
                         insert_mode,
                         replace_enabled,
                         append_enabled:  Boolean;
                         character_set,
                         valid_chars,
                         word_characters: characters;
                         terminate_keys:  array[1..50] of Word
                       end;
type
  tINPUT_STR_ENVIRONMENT = Record
                             keystroke: Word;
                             locate_pos: Byte;
                           end;
const
  is_setting: tINPUT_STR_SETTING =
    (insert_mode:     TRUE;
     replace_enabled: TRUE;
     append_enabled:  TRUE;
     character_set:   [#$20..#$0ff];
     valid_chars:     [#$20..#$0ff];
     word_characters: ['A'..'Z','a'..'z','0'..'9','_'];
     terminate_keys:  ($011b,$1c0d,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$0000,$0000));
var
  is_environment: tINPUT_STR_ENVIRONMENT;

function InputStr(s: String; x,y,ln,ln1: Byte; atr1,atr2: Byte): String;
function SameName(str1,str2: String): Boolean;
function PathOnly(path: String): String;
function NameOnly(path: String): String;
function BaseNameOnly(path: String): String;
function ExtOnly(path: String): String;

implementation

uses
  DOS,TxtScrIO;

function Capitalize(str: String): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@4
        mov     al,[esi]
        inc     esi
        cmp     al,'a'
        jb      @@0
        cmp     al,'z'
        ja      @@0
        sub     al,20h
@@0:    mov     [edi],al
        inc     edi
@@1:    mov     ah,al
        mov     al,[esi]
        inc     esi
        cmp     ah,' '
        jnz     @@2
        cmp     al,'a'
        jb      @@2
        cmp     al,'z'
        ja      @@2
        sub     al,20h
        jmp     @@3
@@2:    cmp     al,'A'
        jb      @@3
        cmp     al,'Z'
        ja      @@3
        add     al,20h
@@3:    mov     [edi],al
        inc     edi
        loop    @@1
@@4:
end;

function Upper(str: String): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
@@1:    mov     al,[esi]
        inc     esi
        cmp     al,'a'
        jb      @@2
        cmp     al,'z'
        ja      @@2
        sub     al,20h
@@2:    mov     [edi],al
        inc     edi
        loop    @@1
@@3:
end;

function Lower(str: String): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
@@1:    mov     al,[esi]
        inc     esi
        cmp     al,'A'
        jb      @@2
        cmp     al,'Z'
        ja      @@2
        add     al,20h
@@2:    mov     [edi],al
        inc     edi
        loop    @@1
@@3:
end;

function iCase(str: String): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@5
        push    edi
        push    ecx
@@1:    mov     al,[esi]
        inc     esi
        cmp     al,'a'
        jb      @@2
        cmp     al,'z'
        ja      @@2
        sub     al,20h
@@2:    mov     [edi],al
        inc     edi
        loop    @@1
        pop     ecx
        pop     edi
@@3:    mov     al,[edi]
        cmp     al,'i'-20h
        jnz     @@4
        add     al,20h
@@4:    mov     [edi],al
        inc     edi
        loop    @@3
@@5:
end;

function RotStrL(str1,str2: String; shift: Byte): String;
begin
  RotStrL := Copy(str1,shift+1,Length(str1)-shift)+
             Copy(str2,1,shift);
end;

function RotStrR(str1,str2: String; shift: Byte): String;
begin
  RotStrR := Copy(str2,Length(str2)-shift+1,shift)+
             Copy(str1,1,Length(str1)-shift);
end;

function ExpStrL(str: String; size: Byte; chr: Char): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        cld
        xor     ecx,ecx
        lodsb
        cmp     al,size
        jge     @@1
        mov     ah,al
        mov     al,size
        stosb
        mov     al,ah
        mov     cl,size
        sub     cl,al
        mov     al,chr
        rep     stosb
        mov     cl,ah
        rep     movsb
        jmp     @@2
@@1:    stosb
        mov     cl,al
        rep     movsb
@@2:
end;

function ExpStrR(str: String; size: Byte; chr: Char): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        cld
        xor     ecx,ecx
        lodsb
        cmp     al,size
        jge     @@1
        mov     ah,al
        mov     al,size
        stosb
        mov     cl,ah
        rep     movsb
        mov     al,ah
        mov     cl,size
        sub     cl,al
        mov     al,chr
        rep     stosb
        jmp     @@2
@@1:    stosb
        mov     cl,al
        rep     movsb
@@2:
end;

function DietStr(str: String; size: Byte): String;
begin
  If (Length(str) <= size) then
    begin
      DietStr := str;
      EXIT;
    end;

  Repeat
    Delete(str,size DIV 2,1)
  until (Length(str)+3 = size);

  Insert('...',str,size DIV 2);
  DietStr := str
end;

function CutStr(str: String): String;
begin
  While (str[0] <> #0) and (str[1] in [#00,#32]) do Delete(str,1,1);
  While (str[0] <> #0) and (str[Length(str)] in [#00,#32]) do Delete(str,Length(str),1);
  CutStr := str;
end;

function FlipStr(str: String): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        dec     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@2
        add     edi,ecx
@@1:    mov     al,[esi]
        inc     esi
        mov     [edi],al
        dec     edi
        loop    @@1
@@2:
end;

function FilterStr(str: String; chr0,chr1: Char): String; assembler;
asm
        mov     esi,[str]
        mov     edi,@result
        mov     al,[esi]
        inc     esi
        mov     [edi],al
        inc     edi
        xor     ecx,ecx
        mov     cl,al
        jecxz   @@3
@@1:    mov     al,[esi]
        inc     esi
        cmp     al,chr0
        jnz     @@2
        mov     al,chr1
@@2:    mov     [edi],al
        inc     edi
        loop    @@1
@@3:
end;

const
  _treat_char: array[$80..$a5] of Char =
    'CueaaaaceeeiiiAAE_AooouuyOU_____aiounN';

function FilterStr2(str: String; chr0: characters; chr1: Char): String;

var
  temp: Byte;

begin
  For temp := 1 to Length(str) do
    If NOT (str[temp] in chr0) then
      If (str[temp] >= #$80) and (str[temp] <= #$a5) then
        str[temp] := _treat_char[BYTE(str[temp])]
      else If (str[temp] = #0) then str[temp] := ' '
           else str[temp] := chr1;
  FilterStr2 := str;
end;

function Num2str(num: Longint; base: Byte): String; assembler;

const
  hexa: array[0..PRED(16)+32] of Char = '0123456789ABCDEF'+
                                        #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
asm
        xor     eax,eax
        xor     edx,edx
        xor     edi,edi
        xor     esi,esi
        mov     eax,num
        xor     ebx,ebx
        mov     bl,base
        cmp     bl,2
        jb      @@3
        cmp     bl,16
        ja      @@3
        mov     edi,32
@@1:    dec     edi
        xor     edx,edx
        div     ebx
        mov     esi,edx
        mov     dl,byte ptr [hexa+esi]
        mov     byte ptr [hexa+edi+16],dl
        and     eax,eax
        jnz     @@1
        mov     esi,edi
        mov     ecx,32
        sub     ecx,edi
        mov     edi,@result
        mov     al,cl
        stosb
@@2:    mov     al,byte ptr [hexa+esi+16]
        stosb
        inc     esi
        loop    @@2
        jmp     @@4
@@3:    mov     edi,@result
        xor     al,al
        stosb
@@4:
end;

const
  digits: array[0..35] of Char = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function Digit2index(digit: Char): Byte;

var
  index: Byte;

begin
  digit := UpCase(digit);
  index := 15;
  While (index > 0) and (digit <> digits[index]) do Dec(index);
  Digit2index := Index;
end;

function position_value(position,base: Byte): Longint;

var
  value: Longint;
  index: Byte;

begin
  value := 1;
  For index := 2 to position do value := value*base;
  position_value := value;
end;

function Str2num(str: String; base: Byte): Longint;

var
  value: Longint;
  index: Byte;

begin
  value := 0;
  For index := 1 to Length(str) do
    Inc(value,Digit2index(str[index])*
              position_value(Length(str)-index+1,base));
  Str2num := value;
end;

function InputStr(s: String; x,y,ln,ln1: Byte; atr1,atr2: Byte): String;

var
  appn,for1st,qflg,ins: Boolean;
  cloc,xloc,xint,mx,attr: Byte;
  key: Word;
  cur: Longint;
  s1,s2: String;

function LookupKey(key: Word; var table; size: Byte): Boolean; assembler;
asm
        mov     esi,[table]
        xor     ecx,ecx
        mov     cl,size
        mov     al,1
        jecxz   @@3
@@1:    lodsw
        cmp     ax,key
        jz      @@2
        loop    @@1
@@2:    xor     al,al
        jecxz   @@3
        mov     al,1
@@3:
end;

function more(value1,value2: Byte): Byte; assembler;
asm
        mov     al,value1
        cmp     al,value2
        jnb     @@1
        mov     al,value2
@@1:
end;

begin
  s := Copy(s,1,ln);
  If (is_environment.locate_pos > ln1) then
    is_environment.locate_pos := ln1;
  If (is_environment.locate_pos > Length(s)+1) then
    is_environment.locate_pos := Length(s);

  cloc := is_environment.locate_pos;
  xloc := is_environment.locate_pos;
  xint := x;
  qflg := FALSE;
  ins  := is_setting.insert_mode;
  appn := NOT is_setting.append_enabled;

  Dec(x);
  cur := GetCursor;
  If ins then ThinCursor else WideCursor;
  s1 := s;
  If (BYTE(s1[0]) > ln1) then s1[0] := CHR(ln1);

  ShowStr(Ptr(v_seg,v_ofs)^,xint,y,ExpStrR('',ln1,' '),atr1);
  ShowStr(Ptr(v_seg,v_ofs)^,xint,y,s1,atr2);
  for1st := TRUE;

  Repeat
    s2 := s1;
    If (xloc = 1) then s1 := Copy(s,cloc,ln1)
    else s1 := Copy(s,cloc-xloc+1,ln1);

    If NOT appn then attr := atr2
    else attr := atr1;

    If appn and for1st then
      begin
        ShowStr(Ptr(v_seg,v_ofs)^,xint,y,ExpStrR(s1,ln1,' '),atr1);
        for1st := FALSE;
      end;

    If (s2 <> s1) then
      ShowStr(Ptr(v_seg,v_ofs)^,xint,y,ExpStrR(s1,ln1,' '),atr1);

    If (ln1 < ln) then
      If (cloc-xloc > 0) and (Length(s) > 0) then
        ShowStr(Ptr(v_seg,v_ofs)^,xint,y,'',(attr AND $0f0)+$0f)
      else If (cloc-xloc = 0) and (Length(s) <> 0) then
             ShowStr(Ptr(v_seg,v_ofs)^,xint,y,s[1],attr)
           else
             ShowStr(Ptr(v_seg,v_ofs)^,xint,y,' ',atr1);

    If (ln1 < ln) then
      If (cloc-xloc+ln1 < Length(s)) then
        ShowStr(Ptr(v_seg,v_ofs)^,xint+ln1-1,y,'',(attr AND $0f0)+$0f)
      else If (cloc-xloc+ln1 = Length(s)) then
             ShowStr(Ptr(v_seg,v_ofs)^,xint+ln1-1,y,s[Length(s)],attr)
           else
             ShowStr(Ptr(v_seg,v_ofs)^,xint+ln1-1,y,' ',atr1);

    GotoXY(x+xloc,y);
    asm xor ah,ah; int 16h; mov key,ax end;
    If LookupKey(key,is_setting.terminate_keys,50) then qflg := TRUE;

    If NOT qflg then
      Case LO(key) of
        $09: appn := TRUE;
        $19: begin appn := TRUE; s := ''; cloc := 1; xloc := 1; end;

        $14: begin
               appn := TRUE;
               While (s[cloc] in is_setting.word_characters) and
                     (cloc <= Length(s)) do Delete(s,cloc,1);

               While NOT (s[cloc] in is_setting.word_characters) and
                         (cloc <= Length(s)) do Delete(s,cloc,1);
             end;

        $7f: begin
               appn := TRUE;
               While (s[cloc-1] in is_setting.word_characters) and
                     (cloc > 1) do
                 begin
                   Dec(cloc); Delete(s,cloc,1);
                   If (xloc > 1) then Dec(xloc);
                 end;

               While NOT (s[cloc-1] in is_setting.word_characters) and
                         (cloc > 1) do
                 begin
                   Dec(cloc); Delete(s,cloc,1);
                   If (xloc > 1) then Dec(xloc);
                 end;
             end;

        $11: begin appn := TRUE; Delete(s,cloc,Length(s)); end;

        $08: begin
               appn := TRUE;
               If (cloc > 1) then
                 begin
                   If (xloc > 1) then Dec(xloc);
                   Dec(cloc); Delete(s,cloc,1);
                 end;
             end;

        $00: begin
               If (HI(key) in [$73,$74,$4b,$4d,$52,$47,$4f]) then
                 appn := TRUE;

               Case (HI(key)) of
                 $73: begin
                        While (s[cloc] in is_setting.word_characters) and
                              (cloc > 1) do
                          begin
                            Dec(cloc);
                            If (xloc > 1) then Dec(xloc);
                          end;

                        While NOT (s[cloc] in is_setting.word_characters) and
                                  (cloc > 1) do
                          begin
                            Dec(cloc);
                            If (xloc > 1) then Dec(xloc);
                          end;
                      end;

                 $74: begin
                        While (s[cloc] in is_setting.word_characters) and
                              (cloc < Length(s)) do
                          begin
                            Inc(cloc);
                            If (xloc < ln1) then Inc(xloc);
                          end;

                        While NOT (s[cloc] in is_setting.word_characters) and
                                  (cloc < Length(s)) do
                          begin
                            Inc(cloc);
                            If (xloc < ln1) then Inc(xloc);
                          end;
                      end;

                 $4b: begin
                        If (cloc > 1) then Dec(cloc);
                        If (xloc > 1) then Dec(xloc);
                      end;

                 $4d: begin
                        If (cloc < Length(s)) or ((cloc = Length(s)) and
                             ((Length(s) < more(ln,ln1)))) then
                          Inc(cloc);
                        If (xloc < ln1) and (xloc <= Length(s)) then Inc(xloc);
                      end;

                 $53: begin
                        appn := TRUE;
                        If (cloc <= Length(s)) then Delete(s,cloc,1);
                      end;

                 $52: If is_setting.replace_enabled then
                        begin
                          ins := NOT ins;
                          If ins then ThinCursor else WideCursor;
                        end;

                 $47: begin cloc := 1; xloc := 1; end;

                 $4f: begin
                        If (Length(s) < more(ln,ln1)) then cloc := Succ(Length(s))
                        else cloc := Length(s);
                        If (cloc < ln1) then xloc := cloc else xloc := ln1;
                      end;
               end;
             end;

        else If NOT (LO(key) in [$09,$19,$0d,$14,$0b,$7f]) and
                    (CHR(LO(key)) in characters(is_setting.character_set)) then
               begin
                 If NOT appn then begin s := ''; cloc := 1; xloc := 1; end;
                 appn := TRUE;
                 If ins and (Length(s) < ln) then
                   begin
                     Insert(CHR(LO(key)),s,cloc);
                     s := FilterStr2(s,is_setting.valid_chars,'_');
                     If (cloc < ln) then Inc(cloc);
                     If (xloc < ln) and (xloc < ln1) then Inc(xloc)
                   end
                 else
                   If (Length(s) < ln) or NOT ins then
                     begin
                       If (cloc > Length(s)) and (Length(s) < ln) then
                         Inc(BYTE(s[0]));

                       s[cloc] := CHR(LO(key));
                       s := FilterStr2(s,is_setting.valid_chars,'_');
                       If (cloc < ln) then Inc(cloc);
                       If (xloc < ln) and (xloc < ln1) then Inc(xloc);
                     end;
               end;
      end;
  until qflg;

//  SetCursor(cur);
  If (cloc = 0) then is_environment.locate_pos := 1
  else is_environment.locate_pos := cloc;
  is_environment.keystroke := key;
  InputStr := s;
end;

function SameName(str1,str2: String): Boolean; assembler;

var
  LastW: Word;

asm
        xor     eax,eax
        xor     ecx,ecx
        mov     esi,[str1]
        mov     edi,[str2]
        xor     ah,ah
        mov     al,[esi]
        inc     esi
        mov     cx,ax
        mov     al,[edi]
        inc     edi
        mov     bx,ax
        or      cx,cx
        jnz     @@1
        or      bx,bx
        jz      @@13
        jmp     @@14
        xor     dh,dh
@@1:    mov     al,[esi]
        inc     esi
        cmp     al,'*'
        jne     @@2
        dec     cx
        jz      @@13
        mov     dh,1
        mov     LastW,cx
        jmp     @@1
@@2:    cmp     al,'?'
        jnz     @@3
        inc     edi
        or      bx,bx
        je      @@12
        dec     bx
        jmp     @@12
@@3:    or      bx,bx
        je      @@14
        cmp     al,'['
        jne     @@11
        cmp     word ptr [esi],']?'
        je      @@9
        mov     ah,byte ptr [edi]
        xor     dl,dl
        cmp     byte ptr [esi],'!'
        jnz     @@4
        inc     esi
        dec     cx
        jz      @@14
        inc     dx
@@4:    mov     al,[esi]
        inc     esi
        dec     cx
        jz      @@14
        cmp     al,']'
        je      @@7
        cmp     ah,al
        je      @@6
        cmp     byte ptr [esi],'-'
        jne     @@4
        inc     esi
        dec     cx
        jz      @@14
        cmp     ah,al
        jae     @@5
        inc     esi
        dec     cx
        jz      @@14
        jmp     @@4
@@5:    mov     al,[esi]
        inc     esi
        dec     cx
        jz      @@14
        cmp     ah,al
        ja      @@4
@@6:    or      dl,dl
        jnz     @@14
        inc     dx
@@7:    or      dl,dl
        jz      @@14
@@8:    cmp     al,']'
        je      @@10
@@9:    mov     al,[esi]
        inc     esi
        cmp     al,']'
        loopne  @@9
        jne     @@14
@@10:   dec     bx
        inc     edi
        jmp     @@12
@@11:   cmp     [edi],al
        jne     @@14
        inc     edi
        dec     bx
@@12:   xor     dh,dh
        dec     cx
        jnz     @@1
        or      bx,bx
        jnz     @@14
@@13:   mov     al,1
        jmp     @@16
@@14:   or      dh,dh
        jz      @@15
        jecxz   @@15
        or      bx,bx
        jz      @@15
        inc     edi
        dec     bx
        jz      @@15
        mov     ax,LastW
        sub     ax,cx
        add     cx,ax
        sub     esi,eax
        dec     esi
        jmp     @@1
@@15:   mov     al,0
@@16:
end;

var
  dir:  DirStr;
  name: NameStr;
  ext:  ExtStr;

function PathOnly(path: String): String;
begin
  FSplit(path,dir,name,ext);
  PathOnly := dir;
end;

function NameOnly(path: String): String;
begin
  FSplit(path,dir,name,ext);
  NameOnly := name+ext;
end;

function BaseNameOnly(path: String): String;
begin
  FSplit(path,dir,name,ext);
  BaseNameOnly := name;
end;

function ExtOnly(path: String): String;
begin
  FSplit(path,dir,name,ext);
  Delete(ext,1,1);
  ExtOnly := ext;
end;

begin
  is_environment.locate_pos := 1;
end.
