uses
  DOS,DPMI,
  A2player,TimerInt,ParserIO,StringIO,TxtScrIO,
  UNPK_LIB;

const
  _timer_xpos = 198;
  _timer_ypos = 5;
  _timer_color = 1;
  _decay_bar_xpos = 10;
  _decay_bar_ypos = 140;
  _decay_bar_palette_start = 250;
  _progress_xpos = 8;
  _progress_ypos = 155;
  _progress_color = 251;
  _fname_xpos = 8;
  _fname_ypos = 170;
  _fname_color = 255;
  _pos_str_xpos = 8;
  _pos_str_ypos = 186;
  _pos_str_color = 252;

type
  tOLD_ADTRACK2_INS = Record
                        fm_data: tFM_INST_DATA;
                        panning: Byte;
                        fine_tune: Shortint;
                      end;
type
  tOLD_FIXED_SONGDATA = Record
                          songname:      String[42];
                          composer:      String[42];
                          instr_names:   array[1..250] of String[32];
                          instr_data:    array[1..250] of tOLD_ADTRACK2_INS;
                          pattern_order: array[0..$7f] of Byte;
                          tempo:         Byte;
                          speed:         Byte;
                          common_flag:   Byte;
                        end;
type
  tOLD_CHUNK = Record
                 note:       Byte;
                 instr_def:  Byte;
                 effect_def: Byte;
                 effect:     Byte;
               end;
type
  tCHUNK = tADTRACK2_EVENT;

type
  tOLD_VARIABLE_DATA1 = array[0..$0f] of array[0..$3f] of
                        array[1..9]   of tOLD_CHUNK;
type
  tOLD_VARIABLE_DATA2 = array[0..7]   of array[1..18] of
                        array[0..$3f] of tOLD_CHUNK;
type
  tVARIABLE_DATA = array[0..7]    of array[1..20] of
                   array[0..$0ff] of tCHUNK;
type
  tPATTERN_DATA = array[0..15] of tVARIABLE_DATA;

type
  tByteSet = Set of Byte;

const
  INSTRUMENT_SIZE = SizeOf(tADTRACK2_INS);
  CHUNK_SIZE = SizeOf(tCHUNK);
  PATTERN_SIZE = 20*256*CHUNK_SIZE;

const
  decay_bar_rise: Real = 10.0;
  decay_bar_fall: Real = 0.50;
  adjust_tracks: Boolean = TRUE;
  accurate_conv: Boolean = TRUE;
  fix_c_note_bug: Boolean = TRUE;
  window_top: Byte = 8;
  modname: array[1..15] of String[39] = ('/´DLiB TR/´CK3R ][ module',
                                         '/´DLiB TR/´CK3R ][ G3 module',
                                         '/´DLiB TR/´CK3R ][ tiny module',
                                         '/´DLiB TR/´CK3R ][ G3 tiny module',
                                         'Amusic module',
                                         'XMS-Tracker module',
                                         'BoomTracker 4.0 module',
                                         'Digital-FM module',
                                         'HSC AdLib Composer / HSC-Tracker module',
                                         'MPU-401 tr’kkîr module',
                                         'Reality ADlib Tracker module',
                                         'Scream Tracker 3.x module',
                                         'FM-Kingtracker module',
                                         'Surprise! AdLib Tracker module',
                                         'Surprise! AdLib Tracker 2.0 module');
var
  old_songdata: tOLD_FIXED_SONGDATA;
  old_hash_buffer: tOLD_VARIABLE_DATA1;
  hash_buffer: tOLD_VARIABLE_DATA2;
  buffer: array[0..PRED(SizeOf(tVARIABLE_DATA))] of Byte;
  songdata_source: String;
  songdata_title: String;
  load_flag: Byte;
  fkey: Word;
  index,last_order: Byte;
  dirinfo: SearchRec;

var
  buf1,
  buf2,buf3: array[0..PRED(65535)] of Byte;
  vscreen: array[0..PRED(8192)] of Byte;
  correction: Integer;
  entries,
  entries2: Byte;
  temp,temp2: Byte;
  dos_memavail: Word;
  _ParamStr: array[0..255] of String;

const
  jukebox: Boolean = FALSE;

const
  kBkSPC  = $0e08;
  kESC    = $011b;
  kENTER  = $1c0d;

procedure ResetF(var f: File);

var
  fattr: Word;

begin
  _debug_str_:= 'ADT2PLAY.PAS:ResetF_RW';
  GetFAttr(f,fattr);
  If (fattr AND ReadOnly = ReadOnly) then FileMode := 0;
  {$i-}
  Reset(f,1);
  {$i+}
end;

procedure BlockReadF(var f: File; var data; size: Longint; var bytes_read: Longint);
begin
  _debug_str_:= 'ADT2PLAY.PAS:BlockReadF';
  {$i-}
  BlockRead(f,data,size,bytes_read);
  {$i+}
  If (IOresult <> 0) then bytes_read := 0;
end;

procedure SeekF(var f: File; fpos: Longint);
begin
  _debug_str_:= 'ADT2PLAY.PAS:SeekF';
  {$i-}
  Seek(f,fpos);
  {$i+}
end;

procedure CloseF(var f: File);
begin
  _debug_str_:= 'ADT2PLAY.PAS:CloseF';
  {$i-}
  Close(f);
  {$i+}
  If (IOresult <> 0) then ;
end;

function min(value: Word; minimum: Word): Word; assembler;
asm
        mov     ax,value
        cmp     ax,minimum
        jae     @@1
        mov     ax,minimum
@@1:
end;

function max(value: Word; maximum: Word): Word; assembler;
asm
        mov     ax,value
        cmp     ax,maximum
        jbe     @@1
        mov     ax,maximum
@@1:
end;

function concw(lo,hi: Byte): Word; assembler;
asm
        mov     al,lo
        mov     ah,hi
end;

function keypressed: Boolean; assembler;
asm
        mov     ah,01h
        int     16h
        mov     al,TRUE
        jnz     @@1
        mov     al,FALSE
@@1:
end;

function is_4op_mode: Boolean; assembler;
asm
        mov     al,byte ptr [songdata.flag_4op]
        or      al,al
        jz      @@1
        mov     al,TRUE
@@1:
end;

function is_4op_chan(chan: Byte): Boolean; assembler;
asm
        mov     al,byte ptr [songdata.flag_4op]
        mov     ah,chan
        test    al,1
        jz      @@1
        cmp     ah,1
        jb      @@1
        cmp     ah,2
        ja      @@1
        mov     al,TRUE
        jmp     @@7
@@1:    test    al,2
        jz      @@2
        cmp     ah,3
        jb      @@2
        cmp     ah,4
        ja      @@2
        mov     al,TRUE
        jmp     @@7
@@2:    test    al,4
        jz      @@3
        cmp     ah,5
        jb      @@3
        cmp     ah,6
        ja      @@3
        mov     al,TRUE
        jmp     @@7
@@3:    test    al,8
        jz      @@4
        cmp     ah,10
        jb      @@4
        cmp     ah,11
        ja      @@4
        mov     al,TRUE
        jmp     @@7
@@4:    test    al,10h
        jz      @@5
        cmp     ah,12
        jb      @@5
        cmp     ah,13
        ja      @@5
        mov     al,TRUE
        jmp     @@7
@@5:    test    al,20h
        jz      @@6
        cmp     ah,14
        jb      @@6
        cmp     ah,15
        ja      @@6
        mov     al,TRUE
        jmp     @@7
@@6:    mov     al,FALSE
@@7:
end;

{$i structrs.inc}
{$i iloaders.inc}

const
  _picture_mode: Boolean = FALSE;

var
  vmem: array[0..PRED(320*200)] of Byte;
  fade_buf,fade_buf2: tFADE_BUF;
  vstate: tVIDEO_STATE;

procedure _refresh_decay_bar(xpos,ypos: Word; height,width,level: Byte); assembler;
asm
        mov     edi,0a0000h
        lea     edx,dword ptr [_picture_palette]
        add     edx,6
        lea     esi,dword ptr [_picture_bitmap]
        add     esi,6
        movzx   eax,ypos
        mov     ebx,320
        mul     ebx
        movzx   ebx,xpos
        add     eax,ebx
        add     edi,eax
        cmp     level,BYTE_NULL
        jnz     @@1
        mov     level,0
        jmp     @@2
@@1:    cmp     level,2
        jae     @@2
        mov     level,2
@@2:    movzx   ecx,width
        jecxz   @@10
@@3:    push    ecx
        push    edi
        movzx   ecx,height
        jecxz   @@9
@@4:    movzx   ebx,height
        sub     ebx,ecx
        movzx   eax,level
        cmp     ebx,eax
        jnae    @@5
        mov     ebx,edi
        sub     ebx,0a0000h
        add     ebx,esi
        movzx   eax,byte ptr [ebx]
        jmp     @@8
@@5:    movzx   eax,height
        push    edx
        xor     edx,edx
        sub     eax,ecx
        mov     ebx,5
        div     ebx
        mov     eax,edx
        pop     edx
        cmp     eax,3
        jbe     @@6
        mov     ebx,edi
        sub     ebx,0a0000h
        add     ebx,esi
        movzx   eax,byte ptr [ebx]
        jmp     @@8
@@6:    or      eax,eax
        jnz     @@7
        xor     eax,eax
        jmp     @@8
@@7:    add     eax,_decay_bar_palette_start
        cmp     level,2
        jnbe    @@8
        mov     eax,250
@@8:    mov     byte ptr [edi],al
        sub     edi,320
        loop    @@4
@@9:    pop     edi
        pop     ecx
        inc     edi
        loop    @@3
@@10:
end;

const
  _decay_bars_initialized: Boolean = FALSE;
  _decay_bars_nm_tracks: Byte = 0;

var
  _old_decay_bar_value: array[1..25] of Byte;

procedure decay_bars_refresh;

var
  temp: Byte;

begin
  _debug_str_:= 'ADT2PLAY.PAS:decay_bars_refresh';
  If NOT _decay_bars_initialized then
    For temp := 1 to 25 do
      _old_decay_bar_value[temp] := BYTE_NULL;

  For temp := 1 to 25 do
    begin
      If (decay_bar[temp].dir = 1) then
        decay_bar[temp].lvl := decay_bar[temp].lvl+
                 decay_bar[temp].dir*(decay_bar_rise/IRQ_freq*100)
      else
        decay_bar[temp].lvl := decay_bar[temp].lvl+
                 decay_bar[temp].dir*(decay_bar_fall/IRQ_freq*100);

      If (decay_bar[temp].lvl < 0) then decay_bar[temp].lvl := 0;
      If (decay_bar[temp].lvl > decay_bar[temp].max_lvl) then
        begin
          decay_bar[temp].dir := -1;
          If (decay_bar[temp].lvl > 63) then
            decay_bar[temp].lvl := 63;
        end;

      If (_old_decay_bar_value[temp] <> Round(decay_bar[temp].lvl*4/3)) then
        begin
          _refresh_decay_bar(_decay_bar_xpos+PRED(temp)*12,_decay_bar_ypos,
                             Round(63*4/3),10,
                             Round(decay_bar[temp].lvl*4/3));
          _old_decay_bar_value[temp] := Round(decay_bar[temp].lvl*4/3);
        end;
    end;
end;

procedure toggle_picture_mode;

var
  index: Byte;

begin
  _debug_str_:= 'ADT2PLAY.PAS:toggle_picture_mode';
  If NOT _picture_mode then
    begin
      _picture_mode := NOT _picture_mode;
      GetVideoState(vstate);
      fade_speed := 16;
      fade_buf.action := first;
      VgaFade(fade_buf,fadeOut,delayed);
      For index := 1 to 20 do WaitRetrace;
      asm mov ax,13h; int 10h end;

      For index := 1 to 20 do WaitRetrace;
      For index := 0 to 255 do
        SetRGBitem(index,tRGB_PALETTE(MEM[Ofs(_picture_palette)+6])[index].r,
                         tRGB_PALETTE(MEM[Ofs(_picture_palette)+6])[index].g,
                         tRGB_PALETTE(MEM[Ofs(_picture_palette)+6])[index].b);
      fade_speed := 16;
      fade_buf.action := first;
      VgaFade(fade_buf2,fadeOut,fast);

      Move(MEM[Ofs(_picture_bitmap)+6],MEM[$0a0000],320*200);
      VgaFade(fade_buf2,fadeIn,delayed);
      external_irq_hook := decay_bars_refresh;
    end
  else begin
         external_irq_hook := NIL;
         _picture_mode := NOT _picture_mode;
         _decay_bars_initialized := FALSE;
         VgaFade(fade_buf2,fadeOut,delayed);

         SetVideoState(vstate,FALSE);
         VgaFade(fade_buf2,fadeOut,fast);
         For index := 1 to 20 do WaitRetrace;
         Move(vstate.screen,MEM[$0b8000],SizeOf(vstate.screen));

         For index := 1 to 20 do WaitRetrace;
         VgaFade(fade_buf,fadeIn,delayed);
       end;
end;

procedure wtext(xstart,ystart: Word; txt: String; color: Byte);

var
  x,y: Word;
  temp,i,j,b: Word;

begin
  _debug_str_:= 'ADT2PLAY.PAS:wtext';
  If NOT _picture_mode then EXIT;
  Move(MEM[Ofs(_picture_bitmap)+6+320*ystart],vmem[320*ystart],(8+1)*320);
  x := xstart+1;
  y := ystart+1;

  For temp := 1 to Length(txt) do
    begin
      For j := 0 to 7 do
        begin
          b := tCHAR8x8(MEM[Ofs(_font8x8)+6])[txt[temp]][j];
          For i := 7 downto 0 do
            If (b OR (1 SHL i) = b) then
              vmem[x+7-i+(y+j)*320] := 0
        end;
      Inc(x,8);
    end;

  x := xstart;
  y := ystart;

  For temp := 1 to Length(txt) do
    begin
      For j := 0 to 7 do
        begin
          b := tCHAR8x8(MEM[Ofs(_font8x8)+6])[txt[temp]][j];
          For i := 7 downto 0 do
            If (b OR (1 SHL i) = b) then
              vmem[x+7-i+(y+j)*320] := color;
        end;
      Inc(x,8);
    end;

  Move(vmem[320*ystart],MEM[$0a0000+320*ystart],(8+1)*320);
end;

procedure wtext2(xstart,ystart: Word; txt: String; color: Byte);

const
  _double: array[0..15] of Byte = (0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7);

var
  x,y: Word;
  temp,i,j,b: Word;

begin
  _debug_str_:= 'ADT2PLAY.PAS:wtext2';
  If NOT _picture_mode then EXIT;
  Move(MEM[Ofs(_picture_bitmap)+6+320*ystart],vmem[320*ystart],(16+1)*320);
  x := xstart+1;
  y := ystart+1;

  For temp := 1 to Length(txt) do
    begin
      For j := 0 to 15 do
        begin
          b := tCHAR8x16(MEM[Ofs(_font8x16)+6])[txt[temp]][j];
          For i := 15 downto 0 do
            If (b OR (1 SHL _double[i]) = b) then
              vmem[x+15-i+(y+j)*320] := 0
        end;
      Inc(x,16);
    end;

  x := xstart;
  y := ystart;

  For temp := 1 to Length(txt) do
    begin
      For j := 0 to 15 do
        begin
          b := tCHAR8x16(MEM[Ofs(_font8x16)+6])[txt[temp]][j];
          For i := 15 downto 0 do
            If (b OR (1 SHL _double[i]) = b) then
              vmem[x+15-i+(y+j)*320] := color;
        end;
      Inc(x,16);
    end;

  Move(vmem[320*ystart],MEM[$0a0000+320*ystart],(16+1)*320);
end;

procedure C3Write(str: String; atr1,atr2,atr3: Byte);
begin
  _debug_str_:= 'ADT2PLAY.PAS:CWrite';
  If _picture_mode then EXIT;
  ShowC3Str(MEM[$0b8000],WhereX,WhereY,str,atr1,atr2,atr3);
  GotoXY(1,WhereY);
end;

procedure C3WriteLn(str: String; atr1,atr2,atr3: Byte);
begin
  _debug_str_:= 'ADT2PLAY.PAS:C3WriteLn';
  ShowC3Str(Ptr(v_seg,v_ofs)^,WhereX,WhereY,
            str,
            atr1,atr2,atr3);
  WriteLn;
end;

procedure CWriteLn(str: String; atr1,atr2: Byte);

var
  temp: Word;
  attr,posx,posy: Byte;
  color2: Boolean;

begin
  _debug_str_:= 'ADT2PLAY.PAS:CWriteLn';
  If _picture_mode then EXIT;
  color2 := FALSE;
  attr := atr1;
  posx := WhereX;
  posy := WhereY;

  For temp := 1 to Length(str) do
    If (str[temp] <> '~') then
      begin
        MEM[$0b8000+(posx-1+(posy-1)*MaxCol) SHL 1] := BYTE(str[temp]);
        MEM[$0b8000+(posx-1+(posy-1)*MaxCol) SHL 1+1] := attr;
        If (posx < MaxCol) then Inc(posx)
        else begin
               posx := 1;
               Inc(posy);
               If (posy > MaxLn) then
                 begin
                   asm
                        mov     ah,06h
                        mov     al,1
                        mov     bh,07h
                        mov     ch,window_top
                        mov     cl,1
                        mov     dh,MaxLn
                        mov     dl,MaxCol
                        dec     ch
                        dec     cl
                        dec     dh
                        dec     dl
                        int     10h
                   end;
                   Dec(posy);
                 end;
             end;
      end
    else begin
           color2 := NOT color2;
           If color2 then attr := atr2 else attr := atr1;
         end;

  Inc(posy);
  If (posy > MaxLn) then
    begin
      asm
           mov     ah,06h
           mov     al,1
           mov     bh,07h
           mov     ch,window_top
           mov     cl,1
           mov     dh,MaxLn
           mov     dl,MaxCol
           dec     ch
           dec     cl
           dec     dh
           dec     dl
           int     10h
      end;
      Dec(posy);
    end;

  posx := 1;
  GotoXY(posx,posy);
end;

function __progress_str(value: Byte): String;

var
  result: String;

begin
  result := '';
  Repeat
    If (value > 4) then
      begin
        result := result+#4;
        Dec(value,4);
      end;
    If (value <= 4) and (value <> 0) then
      result := result+CHR(0+value)
  until (value <= 4);
  __progress_str := result;
end;

function _progress_str: String;
begin
  If (songdata.patt_len = 0) then EXIT;
  If (entries <> 0) then
     _progress_str :=
       ExpStrR(__progress_str(
                 Round(4*38/entries*(current_order-correction+
                 1/songdata.patt_len*(current_line+1)))),38,#0)
  else _progress_str := ExpStrR('',38,#0);
end;

function _timer_str: String;
begin
  _timer_str := ExpStrL(Num2str(song_timer DIV 60,10),2,'0')+':'+
                ExpStrL(Num2str(song_timer MOD 60,10),2,'0')+'.'+
                Num2str(song_timer_tenths DIV 10,10);
end;

function _position_str: String;
begin
  If (songdata.patt_len = 0) then EXIT;
  If (entries <> 0) then
    _position_str :=
      'Order '+ExpStrL(Num2str(current_order,10),3,'0')+'/'+
               ExpStrL(Num2str(PRED(entries2),10),3,'0')+', '+
      'pattern '+ExpStrL(Num2str(current_pattern,10),3,'0')+', '+
      'row '+ExpStrL(Num2str(current_line,10),3,'0')+' '+
      '['+ExpStrL(Num2str(Round(100/entries*(current_order-correction+
          1/songdata.patt_len*(current_line+1))),10),3,'0')+'%] '+
      '['+_timer_str+']'+' '
  else _position_str :=
         'Order '+ExpStrL(Num2str(current_order,10),3,'0')+'/'+
                  ExpStrL(Num2str(PRED(entries2),10),3,'0')+', '+
         'pattern '+ExpStrL(Num2str(current_pattern,10),3,'0')+', '+
         'row '+ExpStrL(Num2str(current_line,10),3,'0')+' '+
         '['+ExpStrL('',3,'0')+'%] '+
         '['+_timer_str+']'+' ';
end;

function _position_str2: String;
begin
  _position_str2 :=
    'Order '+ExpStrL(Num2str(current_order,10),3,'0')+'/'+
             ExpStrL(Num2str(PRED(entries2),10),3,'0')+', '+
    'pattern '+ExpStrL(Num2str(current_pattern,10),3,'0')+', '+
    'row '+ExpStrL(Num2str(current_line,10),3,'0')+' ';
end;

procedure fade_out;

var
  temp: Byte;

begin
  _debug_str_:= 'ADT2PLAY.PAS:fade_out';
  For temp := overall_volume downto 0 do
    begin
      set_overall_volume(temp);
      _delay_counter := 0;
      While (_delay_counter < overall_volume DIV 10) do
        begin
          wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
          wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
          wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'',_pos_str_color);
          C3Write(DietStr(_position_str+'',PRED(MaxCol)),$0f,0,0);
          MEMW[0:$041c] := MEMW[0:$041a];
        end;
    end;
end;

function _gfx_mode: Boolean;

var
  result: Boolean;
  temp: Byte;

begin
  result := FALSE;
  For temp := 1 to ParamCount do
    If (Lower(_ParamStr[temp]) = '/gfx') then
      begin
        result := TRUE;
        BREAK;
      end;
  _gfx_mode := result;
end;

procedure _list_title;
begin
  If iVGA then
    begin
      CWriteLn('',$07,0);
      CWriteLn('   subz3ro''s',$09,0);
      CWriteLn('       ÄÂÄ       ÄÄ',$09,0);
      CWriteLn('  /´DLiB³R/´CK3R ³³ G3 PLAYER',$09,0);
      CWriteLn('   ³       ³     ÄÄ      0.41',$09,0);
      CWriteLn('',$07,0);
    end
  else begin
         WriteLn;
         WriteLn('   subz3ro''s');
         WriteLn('       ÄÂÄ       ÄÄ');
         WriteLn('  /´DLiB³R/´CK3R ³³ G3 PLAYER');
         WriteLn('   ³       ³     ÄÄ      0.41');
         WriteLn;
       end;
end;

var
  old_exit_proc: procedure;

procedure new_exit_proc;
begin
  If (ErrorAddr <> NIL) then
    begin
      stop_playing;
      TimerDone;
      opl3exp($0004);
      opl3exp($0005);
      FreeMem(pattdata,PATTERN_SIZE*max_patterns);

      asm
          mov   ax,03h
          xor   bh,bh
          int   10h
          mov   MaxCol,80
          mov   MaxLn,25
      end;

      WriteLn('ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ');
      WriteLn('Û ABNORMAL PROGRAM TERMiNATiON Û');
      WriteLn('ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß');
      WriteLn('ERROR_ID #'+Num2str(ExitCode,10)+' at '+ExpStrL(Num2str(LONGINT(ErrorAddr),16),8,'0'));
      WriteLn(_debug_str_);
      WriteLn;
      WriteLn('Please send this information with brief description');
      WriteLn('what you were doing with the program when this error was encountered');
      WriteLn('to following email address:');
      WriteLn;
      WriteLn('subz3ro@hotmail.com');

      ErrorAddr := NIL;
      HALT(ExitCode);
    end
  else
    ExitProc := @old_exit_proc;
end;

begin
  For temp := 0 to 255 do
    _ParamStr[temp] := ParamStr(temp);

  If NOT _gfx_mode then
    begin
      If iVGA then CleanScreen(MEM[$0b8000]);
      GotoXY(1,1);
      _list_title;
    end;

  asm
        mov     bx,0ffffh
        mov     ah,48h
        int     21h
        mov     dos_memavail,bx
  end;

  If (dos_memavail*16 DIV 1024 < 120) then
    begin
      If _gfx_mode then _list_title;
      WriteLn('ERROR(1) - Insufficient DOS memory!');
      HALT(1);
    end;

  If NOT iVGA then
    begin
      WriteLn('ERROR(2) - Insufficient video equipment!');
      HALT(2);
    end;

  For temp := 1 to ParamCount do
    If (Lower(_ParamStr[temp]) = '/jukebox') then
      jukebox := TRUE;

  index := 0;
  If (ParamCount = 0) then
    begin
      If _gfx_mode then _list_title;
      CWriteLn('Syntax: '+BaseNameOnly(_ParamStr[0])+' files|wildcards [files|wildcards{...}]',$07,0);
      CWriteLn('',$07,0);
      CWriteLn('Command-line options:',$07,0);
      CWriteLn('  /jukebox    play modules w/ no repeat',$07,0);
      CWriteLn('  /gfx        graphical interface',$07,0);
      HALT;
    end;

  @old_exit_proc := ExitProc;
  ExitProc := @new_exit_proc;

  If _gfx_mode then
    toggle_picture_mode;

  Repeat
    If NOT (index <> 0) then
      begin
        CWriteLn(FilterStr(DietStr('úù-Ä--ùú   úù-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ùú       úù-ÄÄÄ--ùú úù-ÄÄ-Äùú',
                                   PRED(MaxCol)),
                           '.',' '),$01,0);
        CWriteLn(                  '  ~[~SPACE~]~ Fast-Forward ~[~Ä~]~ Restart ~[~ÄÙ~]~ Next ~[~ESC~]~ Quit',$09,$01);
        CWriteLn(FilterStr(DietStr('úù-ÄÄÄÄÄÄÄÄÄÄ--ùú      úù-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Äùú',
                                  PRED(MaxCol)),
                          '.',' '),$01,0);

        CWriteLn('',$07,0);
        window_top := WhereY;
      end;

    Inc(index);
    If (_ParamStr[index][1] <> '/') then
      begin
        FindFirst(_ParamStr[index],AnyFile-VolumeID-Directory,dirinfo);
        If (DosError <> 0) then
          begin
            CWriteLn(DietStr('ERROR(2) - No such file "'+
                             Lower(_ParamStr[index])+'"',
                     PRED(MaxCol)),$07,0);
            CWriteLn('',$07,0);
            FindNext(dirinfo);
            CONTINUE;
          end;

        While NOT (DosError <> 0) do
          begin
            If (PathOnly(_ParamStr[index]) <> '') then
              songdata_source := Upper(PathOnly(_ParamStr[index])+dirinfo.name)
            else songdata_source := Upper(dirinfo.name);

            wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
            wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
            wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'  ',_pos_str_color);
            wtext2(_fname_xpos,_fname_ypos,NameOnly(songdata_source),_fname_color);
            wtext(_pos_str_xpos,_pos_str_ypos,'Loading...',_pos_str_color);

            C3Write(DietStr('Loading "'+songdata_source+'" (please wait)',
                           PRED(MaxCol)),$07,0,0);
            For temp := 1 to 10 do WaitRetrace;

            limit_exceeded := FALSE;
            load_flag := BYTE_NULL;

            _decay_bars_initialized := FALSE;
            a2m_file_loader;
            If (load_flag = BYTE_NULL) then a2t_file_loader;
            If (load_flag = BYTE_NULL) then amd_file_loader;
            If (load_flag = BYTE_NULL) then cff_file_loader;
            If (load_flag = BYTE_NULL) then dfm_file_loader;
            If (load_flag = BYTE_NULL) then mtk_file_loader;
            If (load_flag = BYTE_NULL) then rad_file_loader;
            If (load_flag = BYTE_NULL) then s3m_file_loader;
            If (load_flag = BYTE_NULL) then fmk_file_loader;
            If (load_flag = BYTE_NULL) then sat_file_loader;
            If (load_flag = BYTE_NULL) then sa2_file_loader;
            If (load_flag = BYTE_NULL) then hsc_file_loader;
            If (load_flag = BYTE_NULL) or
               (load_flag = $7f) then
              begin
                CWriteLn(DietStr(ExpStrR('ERROR(3) - Invalid module ('+songdata_source+')',
                                         PRED(MaxCol),' '),
                                 PRED(MaxCol)),$07,0);
                CWriteLn('',$07,0);
                FindNext(dirinfo);
                CONTINUE;
              end;

            last_order := 0;
            entries := 0;
            If limit_exceeded then
              begin
                CWriteLn(DietStr(ExpStrR('ERROR(1) - Insufficient memory!',
                                         PRED(MaxCol),' '),
                         PRED(MaxCol)),$07,0);
                CWriteLn('',$07,0);
                FindNext(dirinfo);
                CONTINUE;
              end;

            count_order(entries);
            correction := calc_following_order(0);
            entries2 := entries;
            If (correction <> -1) then Dec(entries,correction)
            else entries := 0;
            CWriteLn(DietStr(ExpStrR('Playing '+modname[load_flag]+' "'+
                                     songdata_source+'"',
                                     PRED(MaxCol),' '),
                             PRED(MaxCol)),$07,0);
            temp2 := PRED(WhereY);

            If (entries = 0) then
              begin
                If NOT _picture_mode then GotoXY(1,temp2);
                CWriteLn(DietStr(ExpStrR('Playing '+modname[load_flag]+' "'+
                                         songdata_source+'"',
                                         PRED(MaxCol),' '),
                                 PRED(MaxCol)),$08,0);
                CWriteLn(DietStr(ExpStrR(''+NameOnly(songdata_source)+' [stopped] ['+
                                         ExpStrL(Num2str(TRUNC(time_playing) DIV 60,10),2,'0')+
                                         ':'+ExpStrL(Num2str(TRUNC(time_playing) MOD 60,10),2,'0')+']',
                                         PRED(MaxCol),' '),
                                 PRED(MaxCol)),$07,0);
                CWriteLn('',$07,0);
                FindNext(dirinfo);
                CONTINUE;
              end;

            start_playing;
            set_overall_volume(63);
            _decay_bars_nm_tracks := songdata.nm_tracks;
            _decay_bars_initialized := TRUE;

            Repeat
              If (overall_volume = 63) then
                begin
                  wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
                  wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
                  wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'  ',_pos_str_color);
                  C3Write(DietStr(_position_str+'  ',PRED(MaxCol)),$0f,0,0);
                end;

              If (PORT[$60] = $39) { SPACE pressed } then
                begin
                  If (overall_volume > 32) then
                    For temp := 63 downto 32 do
                      begin
                        set_overall_volume(temp);
                        _delay_counter := 0;
                        While (_delay_counter < overall_volume DIV 20) do
                          begin
                            wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
                            wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
                            wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'',_pos_str_color);
                            MEMW[0:$041c] := MEMW[0:$041a];
                            C3Write(DietStr(_position_str+'',PRED(MaxCol)),$0f,0,0);
                          end;
                      end
                  else begin
                         wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
                         wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
                         wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'',_pos_str_color);
                         C3Write(DietStr(_position_str+'',PRED(MaxCol)),$0f,0,0);
                         MEMW[0:$041c] := MEMW[0:$041a];
                       end;
                  fast_forward := TRUE;
                end
              else If (PORT[$60] = $0b9) { SPACE released } then
                     begin
                       fast_forward := FALSE;
                       If (overall_volume < 63) then
                         For temp := 32 to 63 do
                           begin
                             set_overall_volume(temp);
                             _delay_counter := 0;
                             While (_delay_counter < overall_volume DIV 20) do
                               begin
                                 wtext2(_timer_xpos,_timer_ypos,_timer_str,_timer_color);
                                 wtext(_progress_xpos,_progress_ypos,_progress_str,_progress_color);
                                 wtext(_pos_str_xpos,_pos_str_ypos,_position_str2+'  ',_pos_str_color);
                                 C3Write(DietStr(_position_str+'  ',PRED(MaxCol)),$0f,0,0);
                                 MEMW[0:$041c] := MEMW[0:$041a];
                               end;
                           end;
                     end;

              If keypressed then asm xor ax,ax; int 16h; mov fkey,ax end
              else fkey := $0ffff;
              MEMW[0:$041c] := MEMW[0:$041a];

              If jukebox and (last_order <> current_order) then
                begin
                  If (last_order > current_order) and
                     (last_order = PRED(entries2)) then BREAK
                  else last_order := current_order;
                end;

              If (fkey = kBkSPC) then
                begin
                  fade_out;
                  stop_playing;
                  set_overall_volume(63);
                  start_playing;
                end;
            until (fkey = kENTER) or
                  (fkey = kESC);

            fade_out;
            stop_playing;
            If NOT _picture_mode then GotoXY(1,temp2);
            CWriteLn(DietStr(ExpStrR('Playing '+modname[load_flag]+' "'+
                                     songdata_source+'"',
                                     PRED(MaxCol),' '),
                             PRED(MaxCol)),$08,0);
            CWriteLn(DietStr(ExpStrR(''+NameOnly(songdata_source)+' [stopped] ['+
                                     ExpStrL(Num2str(TRUNC(time_playing) DIV 60,10),2,'0')+
                                     ':'+ExpStrL(Num2str(TRUNC(time_playing) MOD 60,10),2,'0')+']',
                                     PRED(MaxCol),' '),
                             PRED(MaxCol)),$07,0);
            CWriteLn('',$07,0);
            If (fkey = kESC) then BREAK;
            FindNext(dirinfo);
          end;
      end;
  until (index = ParamCount);

  If _picture_mode then toggle_picture_mode;
  MEMW[0:$041c] := MEMW[0:$041a];
  FreeMem(pattdata,PATTERN_SIZE*max_patterns);
  ExitProc := @old_exit_proc;
  HALT(0);
end.
