{
        function asciiz_string(str: String): String;
        function check_byte(var data; _byte: Byte; size: Longint): Boolean; assembler;
        procedure insert_command(cmd,cmd2: Word; patterns: Byte; chan: Byte; exceptions: tByteSet);
        procedure init_old_songdata;
        procedure import_old_a2m_event1(patt,line,chan: Byte; old_chunk: tOLD_CHUNK;
                                        processing_whole_song: Boolean);
        procedure replace_old_adsr(patterns: Byte);
        procedure import_old_a2m_patterns1(block: Byte; count: Byte);
        procedure import_old_a2m_event2(patt,line,chan: Byte; old_chunk: tOLD_CHUNK);
        procedure import_old_a2m_patterns2(block: Byte; count: Byte);
        procedure import_old_flags;
        procedure import_old_songdata(old_songdata: tOLD_FIXED_SONGDATA);
        procedure import_old_instruments(old_songdata: tOLD_FIXED_SONGDATA; var new_songdata: tFIXED_SONGDATA;
                                         instr,count: Byte);
        procedure import_single_old_instrument(old_songdata: tOLD_FIXED_SONGDATA; pos,instr: Byte);
        procedure a2m_file_loader;
        procedure a2t_file_loader;
        procedure a2p_file_loader;
        function dec2hex(dec: Byte): Byte;
        function truncate_string(str: String): String;
        procedure amd_file_loader;
        procedure import_cff_event(patt,line,chan,byte0,byte1,byte2: Byte);
        procedure import_cff_patterns(var data; patterns: Byte);
        procedure cff_file_loader;
        procedure import_standard_instrument(inst: Byte; var data);
        procedure dfm_file_loader;
        procedure import_hsc_event(patt,line,chan: Byte; event: Word);
        procedure import_hsc_patterns(var data; patterns: Byte);
        procedure import_hsc_instrument(inst: Byte; var data);
        procedure hsc_file_loader;
        procedure mtk_file_loader;
        procedure rad_file_loader;
        procedure fix_s3m_commands(patterns: Byte);
        procedure fix_single_pattern(patt: Byte);
        procedure s3m_file_loader;
        procedure fix_fmk_commands(patterns: Byte);
        procedure import_fin_instrument(inst: Byte; var data);
        procedure fmk_file_loader;
        procedure import_sat_instrument(inst: Byte; var data);
        function import_sat_instrument_name(var data; inst: Byte): String;
        procedure sat_file_loader;
        function _sal(op1,op2: Word): Byte; assembler;
        function _sar(op1,op2: Word): Byte; assembler;
        procedure import_sa2_effect(effect,def1,def2: Byte;
                                    var out1,out2: Byte);
        procedure sa2_file_loader;
        procedure a2i_file_loader;
        procedure a2f_file_loader;
        procedure a2b_file_loader(bankSelector: Boolean; loadBankPossible: Boolean);
        procedure a2w_file_loader(loadFromFile: Boolean; loadMacros: Boolean; bankSelector: Boolean; loadBankPossible: Boolean);
        procedure cif_file_loader;
        procedure fin_file_loader;
        procedure ins_file_loader;
        procedure sbi_file_loader;
        procedure import_sgi_instrument(inst: Byte; var data);
        procedure sgi_file_loader;
        procedure bnk_file_loader;
        procedure fib_file_loader;
        procedure ibk_file_loader;

}

function asciiz_string(str: String): String;
begin
  If (Pos(#0,str) <> 0) then asciiz_string := Copy(str,1,Pos(#0,str)-1)
  else asciiz_string := '';
end;

function check_byte(var data; _byte: Byte; size: Longint): Boolean; assembler;
asm
        push    ecx
        push    edi
        mov     edi,[data]
        mov     ecx,size
        jecxz   @@1
        mov     al,_byte
        repnz   scasb
        jnz     @@1
        mov     al,TRUE
        jmp     @@2
@@1:    mov     al,FALSE
@@2:    pop     edi
        pop     ecx
end;

procedure insert_command(cmd,cmd2: Word; patterns: Byte; chan: Byte; exceptions: tByteSet);

var
  chunk: tCHUNK;
  temp2,temp3: Byte;
  patt_break: Byte;
  order,patt: Byte;
  patts: String;

begin
  patts := '';
  order := 0; patt := BYTE_NULL;

  Repeat
    If (Pos(CHR(songdata.pattern_order[order]),patts) <> 0) or
       (songdata.pattern_order[order] >= $80) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        patt_break := songdata.patt_len;
        For temp3 := 1 to songdata.nm_tracks do
          For temp2 := 0 to PRED(songdata.patt_len) do
            begin
              get_chunk(patt,temp2,temp3,chunk);
              If (chunk.effect_def in [ef_PositionJump,ef_PatternBreak]) or
                 (chunk.effect_def2 in [ef_PositionJump,ef_PatternBreak]) then
                patt_break := temp2;

              If (temp3 = chan) and (temp2 <= patt_break) then
                If (cmd2 = 0) then
                  If (chunk.effect_def+chunk.effect = 0) or
                     (chunk.effect_def in exceptions) then
                    begin
                      chunk.effect_def := HI(cmd);
                      chunk.effect := LO(cmd);
                      put_chunk(patt,temp2,temp3,chunk);
                      EXIT;
                    end
                  else If (chunk.effect_def2+chunk.effect2 = 0) or
                          (chunk.effect_def2 in exceptions) then
                         begin
                           chunk.effect_def2 := HI(cmd);
                           chunk.effect2 := LO(cmd);
                           put_chunk(patt,temp2,temp3,chunk);
                           EXIT;
                         end
                       else
                else If ((chunk.effect_def+chunk.effect = 0) or
                         (chunk.effect_def in exceptions)) and
                        ((chunk.effect_def2+chunk.effect2 = 0) or
                         (chunk.effect_def2 in exceptions)) then
                       begin
                         chunk.effect_def := HI(cmd);
                         chunk.effect := LO(cmd);
                         chunk.effect_def2 := HI(cmd2);
                         chunk.effect2 := LO(cmd2);
                         put_chunk(patt,temp2,temp3,chunk);
                         EXIT;
                       end;
            end;
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);
end;

procedure init_old_songdata;

var
  temp: Byte;

begin
  FillChar(old_songdata,SizeOf(old_songdata),0);
  FillChar(old_songdata.pattern_order,SizeOf(old_songdata.pattern_order),$080);
  FillChar(old_songdata.instr_data,SizeOf(old_songdata.instr_data),0);

end;

var
  adsr_carrier: array[1..9] of Boolean;

procedure import_old_a2m_event1(patt,line,chan: Byte; old_chunk: tOLD_CHUNK;
                                processing_whole_song: Boolean);

const
  fx_Arpeggio          = $00;
  fx_FSlideUp          = $01;
  fx_FSlideDown        = $02;
  fx_FSlideUpFine      = $03;
  fx_FSlideDownFine    = $04;
  fx_TonePortamento    = $05;
  fx_TPortamVolSlide   = $06;
  fx_Vibrato           = $07;
  fx_VibratoVolSlide   = $08;
  fx_SetOpIntensity    = $09;
  fx_SetInsVolume      = $0a;
  fx_PatternBreak      = $0b;
  fx_PatternJump       = $0c;
  fx_SetTempo          = $0d;
  fx_SetTimer          = $0e;
  fx_Extended          = $0f;
  fx_ex_DefAMdepth     = $00;
  fx_ex_DefVibDepth    = $01;
  fx_ex_DefWaveform    = $02;
  fx_ex_ManSlideUp     = $03;
  fx_ex_ManSlideDown   = $04;
  fx_ex_VSlideUp       = $05;
  fx_ex_VSlideDown     = $06;
  fx_ex_VSlideUpFine   = $07;
  fx_ex_VSlideDownFine = $08;
  fx_ex_RetrigNote     = $09;
  fx_ex_SetAttckRate   = $0a;
  fx_ex_SetDecayRate   = $0b;
  fx_ex_SetSustnLevel  = $0c;
  fx_ex_SetReleaseRate = $0d;
  fx_ex_SetFeedback    = $0e;
  fx_ex_ExtendedCmd    = $0f;

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  chunk.note := old_chunk.note;
  chunk.instr_def := old_chunk.instr_def;
  chunk.effect_def := old_chunk.effect_def;
  chunk.effect := old_chunk.effect;

  Case old_chunk.effect_def of
    fx_Arpeggio:        chunk.effect_def := ef_Arpeggio;
    fx_FSlideUp:        chunk.effect_def := ef_FSlideUp;
    fx_FSlideDown:      chunk.effect_def := ef_FSlideDown;
    fx_FSlideUpFine:    chunk.effect_def := ef_FSlideUpFine;
    fx_FSlideDownFine:  chunk.effect_def := ef_FSlideDownFine;
    fx_TonePortamento:  chunk.effect_def := ef_TonePortamento;
    fx_TPortamVolSlide: chunk.effect_def := ef_TPortamVolSlide;
    fx_Vibrato:         chunk.effect_def := ef_Vibrato;
    fx_VibratoVolSlide: chunk.effect_def := ef_VibratoVolSlide;
    fx_SetInsVolume:    chunk.effect_def := ef_SetInsVolume;
    fx_PatternJump:     chunk.effect_def := ef_PositionJump;
    fx_PatternBreak:    chunk.effect_def := ef_PatternBreak;
    fx_SetTempo:        chunk.effect_def := ef_SetSpeed;
    fx_SetTimer:        chunk.effect_def := ef_SetTempo;

    fx_SetOpIntensity:
      If (old_chunk.effect DIV 16 <> 0) then
        begin
          chunk.effect_def := ef_SetCarrierVol;
          chunk.effect := 3+(old_chunk.effect DIV 16)*4;
        end
      else If (old_chunk.effect MOD 16 <> 0) then
             begin
               chunk.effect_def := ef_SetModulatorVol;
               chunk.effect := 3+(old_chunk.effect MOD 16)*4;
             end
           else chunk.effect_def := 0;

    fx_Extended:
      Case old_chunk.effect DIV 16 of
        fx_ex_DefAMdepth:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := ef_ex_SetTremDepth*16+old_chunk.effect MOD 16;
          end;

        fx_ex_DefVibDepth:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := ef_ex_SetVibDepth*16+old_chunk.effect MOD 16;
          end;


        fx_ex_DefWaveform:
          begin
            chunk.effect_def := ef_SetWaveform;
            Case old_chunk.effect MOD 16 of
              0..3: chunk.effect := (old_chunk.effect MOD 16)*16+$0f;
              4..7: chunk.effect := $0f0+(old_chunk.effect MOD 16)-4;
            end;
          end;

        fx_ex_VSlideUp:
          begin
            chunk.effect_def := ef_VolSlide;
            chunk.effect := (old_chunk.effect MOD 16)*16;
          end;

        fx_ex_VSlideDown:
          begin
            chunk.effect_def := ef_VolSlide;
            chunk.effect := old_chunk.effect MOD 16;
          end;

        fx_ex_VSlideUpFine:
          begin
            chunk.effect_def := ef_VolSlideFine;
            chunk.effect := (old_chunk.effect MOD 16)*16;
          end;

        fx_ex_VSlideDownFine:
          begin
            chunk.effect_def := ef_VolSlideFine;
            chunk.effect := old_chunk.effect MOD 16;
          end;

        fx_ex_ManSlideUp:
          begin
            chunk.effect_def := ef_Extended2;
            chunk.effect := ef_ex2_FineTuneUp*16+old_chunk.effect MOD 16;
          end;

        fx_ex_ManSlideDown:
          begin
            chunk.effect_def := ef_Extended2;
            chunk.effect := ef_ex2_FineTuneDown*16+old_chunk.effect MOD 16;
          end;

        fx_ex_RetrigNote:
          begin
            chunk.effect_def := ef_RetrigNote;
            chunk.effect := SUCC(old_chunk.effect MOD 16);
          end;

        fx_ex_SetAttckRate:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := old_chunk.effect MOD 16;
            If NOT adsr_carrier[chan] then
              Inc(chunk.effect,ef_ex_SetAttckRateM*16)
            else Inc(chunk.effect,ef_ex_SetAttckRateC*16);
          end;

        fx_ex_SetDecayRate:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := old_chunk.effect MOD 16;
            If NOT adsr_carrier[chan] then
              Inc(chunk.effect,ef_ex_SetDecayRateM*16)
            else Inc(chunk.effect,ef_ex_SetDecayRateC*16);
          end;

        fx_ex_SetSustnLevel:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := old_chunk.effect MOD 16;
            If NOT adsr_carrier[chan] then
              Inc(chunk.effect,ef_ex_SetSustnLevelM*16)
            else Inc(chunk.effect,ef_ex_SetSustnLevelC*16);
          end;

        fx_ex_SetReleaseRate:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := old_chunk.effect MOD 16;
            If NOT adsr_carrier[chan] then
              Inc(chunk.effect,ef_ex_SetRelRateM*16)
            else Inc(chunk.effect,ef_ex_SetRelRateC*16);
          end;

        fx_ex_SetFeedback:
          begin
            chunk.effect_def := ef_Extended;
            chunk.effect := ef_ex_SetFeedback*16+old_chunk.effect MOD 16;
          end;

        fx_ex_ExtendedCmd:
          If (old_chunk.effect MOD 16 in [0..9]) then
            begin
              chunk.effect_def := ef_Extended;
              chunk.effect := ef_ex_ExtendedCmd*16;

              Case old_chunk.effect MOD 16 of
                0: Inc(chunk.effect,ef_ex_cmd_RSS);
                1: Inc(chunk.effect,ef_ex_cmd_LockVol);
                2: Inc(chunk.effect,ef_ex_cmd_UnlockVol);
                3: Inc(chunk.effect,ef_ex_cmd_LockVP);
                4: Inc(chunk.effect,ef_ex_cmd_UnlockVP);

                5: begin
                     If processing_whole_song then chunk.effect_def := 255
                     else chunk.effect_def := 0;
                     chunk.effect := 0;
                     adsr_carrier[chan] := TRUE;
                   end;

                6: begin
                     If processing_whole_song then chunk.effect_def := 255
                     else chunk.effect_def := 0;
                     If processing_whole_song then chunk.effect := 1
                     else chunk.effect := 0;
                     adsr_carrier[chan] := FALSE;
                   end;

                7: Inc(chunk.effect,ef_ex_cmd_VSlide_car);
                8: Inc(chunk.effect,ef_ex_cmd_VSlide_mod);
                9: Inc(chunk.effect,ef_ex_cmd_VSlide_def);
              end;
            end
          else begin
                 chunk.effect_def := 0;
                 chunk.effect := 0;
               end;
      end;
  end;

  put_chunk(patt,line,chan,chunk);
end;

procedure replace_old_adsr(patterns: Byte);

var
  chunk,chunk2: tCHUNK;
  temp2,temp3: Byte;
  patt_break: Byte;
  order,patt: Byte;
  patts: String;

begin
  patts := '';
  FillChar(adsr_carrier,SizeOf(adsr_carrier),0);

  order := 0; patt := BYTE_NULL;
  Repeat
    If (songdata.pattern_order[order] >= $80) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        patt_break := BYTE_NULL;
        For temp2 := 0 to $3f do
          For temp3 := 1 to 9 do
            begin
              get_chunk(patt,temp2,temp3,chunk);
              chunk2 := chunk;

              If (chunk.effect_def in [ef_PositionJump,ef_PatternBreak]) then
                patt_break := temp2;

              If (chunk.effect_def in [$ff,ef_Extended]) then
                begin
                  If (chunk.effect_def = $ff) then
                    begin
                      chunk2.effect_def := 0;
                      chunk2.effect := 0;

                      If (temp2 <= patt_break) then
                        Case chunk.effect of
                          0: adsr_carrier[temp3] := TRUE;
                          1: adsr_carrier[temp3] := FALSE;
                        end;
                    end;

                  If (chunk.effect_def = ef_Extended) then
                    Case chunk.effect DIV 16 of
                      ef_ex_SetAttckRateM,
                      ef_ex_SetAttckRateC:
                        If adsr_carrier[temp3] then
                          chunk2.effect := ef_ex_SetAttckRateC*16+chunk.effect MOD 16
                        else chunk2.effect := ef_ex_SetAttckRateM*16+chunk.effect MOD 16;

                      ef_ex_SetDecayRateM,
                      ef_ex_SetDecayRateC:
                        If adsr_carrier[temp3] then
                          chunk2.effect := ef_ex_SetDecayRateC*16+chunk.effect MOD 16
                        else chunk2.effect := ef_ex_SetDecayRateM*16+chunk.effect MOD 16;

                      ef_ex_SetSustnLevelM,
                      ef_ex_SetSustnLevelC:
                        If adsr_carrier[temp3] then
                          chunk2.effect := ef_ex_SetSustnLevelC*16+chunk.effect MOD 16
                        else chunk2.effect := ef_ex_SetSustnLevelM*16+chunk.effect MOD 16;

                      ef_ex_SetRelRateM,
                      ef_ex_SetRelRateC:
                        If adsr_carrier[temp3] then
                          chunk2.effect := ef_ex_SetRelRateC*16+chunk.effect MOD 16
                        else chunk2.effect := ef_ex_SetRelRateM*16+chunk.effect MOD 16;
                    end;

                  If (Pos(CHR(songdata.pattern_order[order]),patts) = 0) then
                    If (chunk.effect_def <> chunk2.effect_def) or
                       (chunk.effect <> chunk2.effect) then
                      put_chunk(patt,temp2,temp3,chunk2);
                end;
            end;
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);
end;

procedure import_old_a2m_patterns1(block: Byte; count: Byte);

procedure get_old_chunk(pattern,line,channel: Byte; var chunk: tOLD_CHUNK);
begin chunk := old_hash_buffer[pattern][line][channel]; end;

var
  patt,line,chan: Byte;
  chunk: tOLD_CHUNK;

begin { import_old_a2m_patterns1 }
  For patt := 0 to max(PRED(count),15) do
    For line := 0 to $3f do
      For chan := 1 to 9 do
        begin
          get_old_chunk(patt,line,chan,chunk);
          import_old_a2m_event1(block*16+patt,line,chan,chunk,TRUE);
        end;
end;

procedure import_old_a2m_event2(patt,line,chan: Byte; old_chunk: tOLD_CHUNK);

const
  ef_ManualFSlide = 22;

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  chunk.note := old_chunk.note;
  chunk.instr_def := old_chunk.instr_def;

  If (old_chunk.effect_def <> ef_ManualFSlide) then
    begin
      chunk.effect_def := old_chunk.effect_def;
      chunk.effect := old_chunk.effect;
    end
  else If (old_chunk.effect DIV 16 <> 0) then
         begin
           chunk.effect_def := ef_Extended2;
           chunk.effect := ef_ex2_FineTuneUp*16+old_chunk.effect DIV 16;
         end
       else begin
              chunk.effect_def := ef_Extended2;
              chunk.effect := ef_ex2_FineTuneDown*16+old_chunk.effect MOD 16;
            end;

  put_chunk(patt,line,chan,chunk);
end;

procedure import_old_a2m_patterns2(block: Byte; count: Byte);

procedure get_old_chunk(pattern,line,channel: Byte; var chunk: tOLD_CHUNK);
begin chunk := hash_buffer[pattern][channel][line]; end;

var
  patt,line,chan: Byte;
  chunk: tOLD_CHUNK;

begin { import_old_a2m_patterns2 }
  For patt := 0 to max(PRED(count),7) do
    For line := 0 to $3f do
      For chan := 1 to 18 do
        begin
          get_old_chunk(patt,line,chan,chunk);
          import_old_a2m_event2(block*8+patt,line,chan,chunk);
        end;
end;

procedure import_old_flags;

var
  temp: Byte;

begin
  If (songdata.common_flag OR 2 = songdata.common_flag) then
    For temp := 1 to 20 do
      songdata.lock_flags[temp] := songdata.lock_flags[temp] OR $10;

  If (songdata.common_flag OR 4 = songdata.common_flag) then
    For temp := 1 to 20 do
      songdata.lock_flags[temp] := songdata.lock_flags[temp] OR $20;

  If (songdata.common_flag OR $20 = songdata.common_flag) then
    For temp := 1 to 20 do
      songdata.lock_flags[temp] := songdata.lock_flags[temp] AND NOT 3;
end;

procedure import_old_songdata(old_songdata: tOLD_FIXED_SONGDATA);

var
  temp: Byte;

begin
  songdata.songname := old_songdata.songname;
  songdata.composer := old_songdata.composer;

  For temp := 1 to 250 do
    begin
      songdata.instr_names[temp] := old_songdata.instr_names[temp];
      songdata.instr_data[temp].fm_data := old_songdata.instr_data[temp].fm_data;
      songdata.instr_data[temp].panning := old_songdata.instr_data[temp].panning;
      songdata.instr_data[temp].fine_tune := old_songdata.instr_data[temp].fine_tune;
      songdata.instr_data[temp].perc_voice := 0;
    end;

  Move(old_songdata.pattern_order,
       songdata.pattern_order,
       SizeOf(old_songdata.pattern_order));

  songdata.tempo := old_songdata.tempo;
  songdata.speed := old_songdata.speed;
  songdata.common_flag := old_songdata.common_flag;
  import_old_flags;
end;

procedure import_old_instruments(old_songdata: tOLD_FIXED_SONGDATA; var new_songdata: tFIXED_SONGDATA;
                                 instr,count: Byte);
var
  temp: Byte;

begin
  For temp := instr to instr+PRED(count) do
    begin
      new_songdata.instr_names[temp] := Copy(new_songdata.instr_names[temp],1,9)+
                                    Copy(old_songdata.instr_names[temp],10,22);
      new_songdata.instr_data[temp].fm_data := old_songdata.instr_data[temp].fm_data;
      new_songdata.instr_data[temp].panning := old_songdata.instr_data[temp].panning;
      new_songdata.instr_data[temp].fine_tune := old_songdata.instr_data[temp].fine_tune;
      new_songdata.instr_data[temp].perc_voice := 0;
    end;
end;

procedure import_single_old_instrument(old_songdata: tOLD_FIXED_SONGDATA; pos,instr: Byte);
begin
  songdata.instr_names[pos] := Copy(songdata.instr_names[pos],1,9)+
                               Copy(old_songdata.instr_names[instr],10,22);
  songdata.instr_data[pos].fm_data := old_songdata.instr_data[instr].fm_data;
  songdata.instr_data[pos].panning := old_songdata.instr_data[instr].panning;
  songdata.instr_data[pos].fine_tune := old_songdata.instr_data[instr].fine_tune;
  songdata.instr_data[pos].perc_voice := 0;
end;

procedure a2m_file_loader;

type
  tOLD_HEADER = Record
                  ident: array[1..10] of Char;
                  crc32: Longint;
                  ffver: Byte;
                  patts: Byte;
                  b0len: Word;
                  b1len: Word;
                  b2len: Word;
                  b3len: Word;
                  b4len: Word;
                  b5len: Word;
                  b6len: Word;
                  b7len: Word;
                  b8len: Word;
                end;
type
  tHEADER = Record
              ident: array[1..10] of Char;
              crc32: Longint;
              ffver: Byte;
              patts: Byte;
              b0len: Longint;
              b1len: array[0..15] of Longint;
            end;

const
  id = '_A2module_';

const
  old_a2m_header_size = 26;

var
  f: File;
  header: tHEADER;
  header2: tOLD_HEADER;
  temp,temp2: Longint;
  crc: Longint;
  xlen: array[0..6] of Word;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If NOT (header.ffver in [1..11]) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_old_songdata;
  If (header.ffver in [1..4]) then
    begin
      FillChar(adsr_carrier,SizeOf(adsr_carrier),BYTE(FALSE));
      ResetF(f);
      BlockReadF(f,header2,SizeOf(header2),temp);
      If NOT ((temp = SizeOf(header2)) and (header2.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      xlen[0] := header2.b2len;
      xlen[1] := header2.b3len;
      xlen[2] := header2.b4len;

      SeekF(f,old_a2m_header_size);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 0 to 2 do
        If ((header2.patts-1) DIV 16 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header2.b0len,2,crc);
      crc := Update32(header2.b1len,2,crc);

      For temp2 := 0 to 2 do
        crc := Update32(xlen[temp2],2,crc);

      If (crc <> header2.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      songdata.patt_len := 64;
      If adjust_tracks then songdata.nm_tracks := 9
      else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

      SeekF(f,old_a2m_header_size);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header2.ffver of
        4: Move(buffer,old_songdata,header2.b0len);
        3: LZSS_decompress(buffer,old_songdata,header2.b0len);
        2: LZW_decompress(buffer,old_songdata);
        1: SIXPACK_decompress(buffer,old_songdata,header2.b0len);
      end;

      For temp := 1 to 250 do
        old_songdata.instr_data[temp].panning := 0;

      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header2.ffver of
        4: Move(buffer,old_hash_buffer,header2.b1len);
        3: LZSS_decompress(buffer,old_hash_buffer,header2.b1len);
        2: LZW_decompress(buffer,old_hash_buffer);
        1: SIXPACK_decompress(buffer,old_hash_buffer,header2.b1len);
      end;
      import_old_a2m_patterns1(0,16);

      For temp2 := 0 to 2 do
        If ((header2.patts-1) DIV 16 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            Case header2.ffver of
              4: Move(buffer,old_hash_buffer,xlen[temp2]);
              3: LZSS_decompress(buffer,old_hash_buffer,xlen[temp2]);
              2: LZW_decompress(buffer,old_hash_buffer);
              1: SIXPACK_decompress(buffer,old_hash_buffer,xlen[temp2]);
            end;
            import_old_a2m_patterns1(SUCC(temp2),16);
          end;

      replace_old_adsr(header2.patts);
      import_old_songdata(old_songdata);
    end;

  If (header.ffver in [5..8]) then
    begin
      ResetF(f);
      BlockReadF(f,header2,SizeOf(header2),temp);
      If NOT ((temp = SizeOf(header2)) and (header2.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      xlen[0] := header2.b2len;
      xlen[1] := header2.b3len;
      xlen[2] := header2.b4len;
      xlen[3] := header2.b5len;
      xlen[4] := header2.b6len;
      xlen[5] := header2.b7len;
      xlen[6] := header2.b8len;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 0 to 6 do
        If ((header2.patts-1) DIV 8 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header2.b0len,2,crc);
      crc := Update32(header2.b1len,2,crc);

      For temp2 := 0 to 6 do
        crc := Update32(xlen[temp2],2,crc);

      If (crc <> header2.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      songdata.patt_len := 64;
      If adjust_tracks then songdata.nm_tracks := 18
      else If (songdata.nm_tracks < 18) then songdata.nm_tracks := 18;

      SeekF(f,SizeOf(header2));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header2.ffver of
        8: Move(buffer,old_songdata,header2.b0len);
        7: LZSS_decompress(buffer,old_songdata,header2.b0len);
        6: LZW_decompress(buffer,old_songdata);
        5: SIXPACK_decompress(buffer,old_songdata,header2.b0len);
      end;

      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header2.ffver of
        8: Move(buffer,hash_buffer,header2.b1len);
        7: LZSS_decompress(buffer,hash_buffer,header2.b1len);
        6: LZW_decompress(buffer,hash_buffer);
        5: SIXPACK_decompress(buffer,hash_buffer,header2.b1len);
      end;
      import_old_a2m_patterns2(0,8);

      For temp2 := 0 to 6 do
        If ((header2.patts-1) DIV 8 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            Case header2.ffver of
              8: Move(buffer,hash_buffer,header2.b2len);
              7: LZSS_decompress(buffer,hash_buffer,header2.b2len);
              6: LZW_decompress(buffer,hash_buffer);
              5: SIXPACK_decompress(buffer,hash_buffer,header2.b2len);
            end;
            import_old_a2m_patterns2(SUCC(temp2),8);
          end;
      import_old_songdata(old_songdata);
    end;

  If (header.ffver in [9,10,11]) then
    begin
      crc := DWORD_NULL;
      BlockReadF(f,buffer,header.b0len,temp);
      If NOT (temp = header.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b1len[0],temp);
      If NOT (temp = header.b1len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 1 to 15 do
        If ((header.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header.b1len[temp2],temp);
            If NOT (temp = header.b1len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header.b0len,2,crc);
      For temp2 := 0 to 15 do
        crc := Update32(header.b1len[temp2],2,crc);

      If (crc <> header.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      SeekF(f,SizeOf(header));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header.b0len,temp);
      If NOT (temp = header.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata);
      BlockReadF(f,buffer,header.b1len[0],temp);
      If NOT (temp = header.b1len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (header.ffver = 9) then
        import_old_flags;


      APACK_decompress(buffer,pattdata^[0]);
      For temp2 := 1 to 15 do
        If ((header.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header.b1len[temp2],temp);
            If NOT (temp = header.b1len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            If (temp2*8+8 <= max_patterns) then
              APACK_decompress(buffer,pattdata^[temp2])
            else limit_exceeded := TRUE;
          end;
    end;

  speed := songdata.speed;
  tempo := songdata.tempo;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  Case header.ffver of
    1..4: load_flag := 1;
    else  load_flag := 2;
  end;
end;

procedure a2t_file_loader;

type
  tOLD_HEADER1 = Record
                   ident: array[1..15] of Char;
                   crc32: Longint;
                   ffver: Byte;
                   patts: Byte;
                   tempo: Byte;
                   speed: Byte;
                   b0len: Word;
                   b1len: Word;
                   b2len: Word;
                   b3len: Word;
                   b4len: Word;
                   b5len: Word;
                 end;
type
  tOLD_HEADER2 = Record
                   ident: array[1..15] of Char;
                   crc32: Longint;
                   ffver: Byte;
                   patts: Byte;
                   tempo: Byte;
                   speed: Byte;
                   cflag: Byte;
                   b0len: Word;
                   b1len: Word;
                   b2len: Word;
                   b3len: Word;
                   b4len: Word;
                   b5len: Word;
                   b6len: Word;
                   b7len: Word;
                   b8len: Word;
                   b9len: Word;
                 end;
type
  tOLD_HEADER3 = Record
                   ident: array[1..15] of Char;
                   crc32: Longint;
                   ffver: Byte;
                   patts: Byte;
                   tempo: Byte;
                   speed: Byte;
                   cflag: Byte;
                   patln: Word;
                   nmtrk: Byte;
                   mcspd: Word;
                   b0len: Longint;
                   b1len: Longint;
                   b2len: Longint;
                   b3len: Longint;
                   b4len: array[0..15] of Longint;
                 end;
type
  tOLD_HEADER4 = Record
                   ident: array[1..15] of Char;
                   crc32: Longint;
                   ffver: Byte;
                   patts: Byte;
                   tempo: Byte;
                   speed: Byte;
                   cflag: Byte;
                   patln: Word;
                   nmtrk: Byte;
                   mcspd: Word;
                   is4op: Byte;
                   locks: array[1..20] of Byte;
                   b0len: Longint;
                   b1len: Longint;
                   b2len: Longint;
                   b3len: Longint;
                   b4len: array[0..15] of Longint;
                 end;
type
  tHEADER = Record
              ident: array[1..15] of Char;
              crc32: Longint;
              ffver: Byte;
              patts: Byte;
              tempo: Byte;
              speed: Byte;
              cflag: Byte;
              patln: Word;
              nmtrk: Byte;
              mcspd: Word;
              is4op: Byte;
              locks: array[1..20] of Byte;
              b0len: Longint;
              b1len: Longint;
              b2len: Longint;
              b3len: Longint;
              b4len: Longint;
              b5len: array[0..15] of Longint;
            end;
const
  id = '_A2tiny_module_';

var
  f: File;
  header: tHEADER;
  header2: tOLD_HEADER1;
  header3: tOLD_HEADER2;
  header4: tOLD_HEADER3;
  header5: tOLD_HEADER4;
  temp,temp2: Longint;
  crc: Longint;
  xlen: array[0..6] of Word;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If NOT (header.ffver in [1..11]) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_old_songdata;
  If (header.ffver in [1..4]) then
    begin
      FillChar(adsr_carrier,SizeOf(adsr_carrier),BYTE(FALSE));
      ResetF(f);
      BlockReadF(f,header2,SizeOf(header2),temp);
      If NOT ((temp = SizeOf(header2)) and (header2.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      xlen[0] := header2.b3len;
      xlen[1] := header2.b4len;
      xlen[2] := header2.b5len;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header2.b2len,temp);
      If NOT (temp = header2.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 0 to 2 do
        If ((header2.patts-1) DIV 16 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header2.b0len,2,crc);
      crc := Update32(header2.b1len,2,crc);
      crc := Update32(header2.b2len,2,crc);

      For temp2 := 0 to 2 do
        crc := Update32(xlen[temp2],2,crc);

      If (crc <> header2.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      songdata.patt_len := 64;
      If adjust_tracks then songdata.nm_tracks := 9
      else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

      SeekF(f,SizeOf(header2));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header2.b0len,temp);
      If NOT (temp = header2.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      old_songdata.tempo := header2.tempo;
      old_songdata.speed := header2.speed;

      Case header2.ffver of
        4: Move(buffer,old_songdata.instr_data,header2.b0len);
        3: LZSS_decompress(buffer,old_songdata.instr_data,header2.b0len);
        2: LZW_decompress(buffer,old_songdata.instr_data);
        1: SIXPACK_decompress(buffer,old_songdata.instr_data,header2.b0len);
      end;

      For temp := 1 to 250 do
        old_songdata.instr_data[temp].panning := 0;

      BlockReadF(f,buffer,header2.b1len,temp);
      If NOT (temp = header2.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header2.ffver of
        4: Move(buffer,old_songdata.pattern_order,header2.b1len);
        3: LZSS_decompress(buffer,old_songdata.pattern_order,header2.b1len);
        2: LZW_decompress(buffer,old_songdata.pattern_order);
        1: SIXPACK_decompress(buffer,old_songdata.pattern_order,header2.b1len);
      end;

      BlockReadF(f,buffer,header2.b2len,temp);
      If NOT (temp = header2.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      FillChar(old_hash_buffer,SizeOf(old_hash_buffer),0);
      Case header2.ffver of
        4: Move(buffer,old_hash_buffer,header2.b2len);
        3: LZSS_decompress(buffer,old_hash_buffer,header2.b2len);
        2: LZW_decompress(buffer,old_hash_buffer);
        1: SIXPACK_decompress(buffer,old_hash_buffer,header2.b2len);
      end;
      import_old_a2m_patterns1(0,16);

      For temp2 := 0 to 2 do
        If ((header2.patts-1) DIV 16 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            FillChar(old_hash_buffer,SizeOf(old_hash_buffer),0);
            Case header2.ffver of
              4: Move(buffer,old_hash_buffer,header2.b3len);
              3: LZSS_decompress(buffer,old_hash_buffer,header2.b3len);
              2: LZW_decompress(buffer,old_hash_buffer);
              1: SIXPACK_decompress(buffer,old_hash_buffer,header2.b3len);
            end;
            import_old_a2m_patterns1(SUCC(temp2),16);
          end;

      replace_old_adsr(header2.patts);
      import_old_songdata(old_songdata);
    end;

  If (header.ffver in [5..8]) then
    begin
      ResetF(f);
      BlockReadF(f,header3,SizeOf(header3),temp);
      If NOT ((temp = SizeOf(header3)) and (header3.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      xlen[0] := header3.b3len;
      xlen[1] := header3.b4len;
      xlen[2] := header3.b5len;
      xlen[3] := header3.b6len;
      xlen[4] := header3.b7len;
      xlen[5] := header3.b8len;
      xlen[6] := header3.b9len;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header3.b0len,temp);
      If NOT (temp = header3.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header3.b1len,temp);
      If NOT (temp = header3.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header3.b2len,temp);
      If NOT (temp = header3.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 0 to 6 do
        If ((header3.patts-1) DIV 8 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header3.b0len,2,crc);
      crc := Update32(header3.b1len,2,crc);
      crc := Update32(header3.b2len,2,crc);

      For temp2 := 0 to 6 do
        crc := Update32(xlen[temp2],2,crc);

      If (crc <> header3.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      songdata.patt_len := 64;
      If adjust_tracks then songdata.nm_tracks := 18
      else If (songdata.nm_tracks < 18) then songdata.nm_tracks := 18;

      SeekF(f,SizeOf(header3));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header3.b0len,temp);
      If NOT (temp = header3.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      old_songdata.tempo := header3.tempo;
      old_songdata.speed := header3.speed;
      old_songdata.common_flag := header3.cflag;

      Case header3.ffver of
        8: Move(buffer,old_songdata.instr_data,header3.b0len);
        7: LZSS_decompress(buffer,old_songdata.instr_data,header3.b0len);
        6: LZW_decompress(buffer,old_songdata.instr_data);
        5: SIXPACK_decompress(buffer,old_songdata.instr_data,header3.b0len);
      end;

      BlockReadF(f,buffer,header3.b1len,temp);
      If NOT (temp = header3.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      Case header3.ffver of
        8: Move(buffer,old_songdata.pattern_order,header3.b1len);
        7: LZSS_decompress(buffer,old_songdata.pattern_order,header3.b1len);
        6: LZW_decompress(buffer,old_songdata.pattern_order);
        5: SIXPACK_decompress(buffer,old_songdata.pattern_order,header3.b1len);
      end;

      BlockReadF(f,buffer,header3.b2len,temp);
      If NOT (temp = header3.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      FillChar(hash_buffer,SizeOf(hash_buffer),0);
      Case header3.ffver of
        8: Move(buffer,hash_buffer,header3.b2len);
        7: LZSS_decompress(buffer,hash_buffer,header3.b2len);
        6: LZW_decompress(buffer,hash_buffer);
        5: SIXPACK_decompress(buffer,hash_buffer,header3.b2len);
      end;
      import_old_a2m_patterns2(0,8);

      For temp2 := 0 to 6 do
        If ((header3.patts-1) DIV 8 > temp2) then
          begin
            BlockReadF(f,buffer,xlen[temp2],temp);
            If NOT (temp = xlen[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            FillChar(hash_buffer,SizeOf(hash_buffer),0);
            Case header3.ffver of
              8: Move(buffer,hash_buffer,header3.b3len);
              7: LZSS_decompress(buffer,hash_buffer,header3.b3len);
              6: LZW_decompress(buffer,hash_buffer);
              5: SIXPACK_decompress(buffer,hash_buffer,header3.b3len);
            end;
            import_old_a2m_patterns2(SUCC(temp2),8);
          end;
      import_old_songdata(old_songdata);
    end;

  If (header.ffver = 9) then
    begin
      ResetF(f);
      BlockReadF(f,header4,SizeOf(header4),temp);
      If NOT ((temp = SizeOf(header4)) and (header4.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header4.b0len,temp);
      If NOT (temp = header4.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header4.b1len,temp);
      If NOT (temp = header4.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header4.b2len,temp);
      If NOT (temp = header4.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header4.b3len,temp);
      If NOT (temp = header4.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header4.b4len[0],temp);
      If NOT (temp = header4.b4len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 1 to 15 do
        If ((header4.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header4.b4len[temp2],temp);
            If NOT (temp = header4.b4len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header4.b0len,2,crc);
      crc := Update32(header4.b1len,2,crc);
      crc := Update32(header4.b2len,2,crc);
      crc := Update32(header4.b3len,2,crc);

      For temp2 := 0 to 15 do
        crc := Update32(header4.b4len[temp2],2,crc);

      If (crc <> header4.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      SeekF(f,SizeOf(header4));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header4.b0len,temp);
      If NOT (temp = header4.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_data);
      BlockReadF(f,buffer,header4.b1len,temp);
      If NOT (temp = header4.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_macros);
      BlockReadF(f,buffer,header4.b2len,temp);
      If NOT (temp = header4.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.macro_table);
      BlockReadF(f,buffer,header4.b3len,temp);
      If NOT (temp = header4.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      songdata.tempo := header4.tempo;
      songdata.speed := header4.speed;
      songdata.common_flag := header4.cflag;
      songdata.patt_len := header4.patln;
      songdata.nm_tracks := header4.nmtrk;
      songdata.macro_speedup := header4.mcspd;
      import_old_flags;

      APACK_decompress(buffer,songdata.pattern_order);
      BlockReadF(f,buffer,header4.b4len[0],temp);
      If NOT (temp = header4.b4len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,pattdata^[0]);
      For temp2 := 1 to 15 do
        If ((header4.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header4.b4len[temp2],temp);
            If NOT (temp = header4.b4len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            If (temp2*8+8 <= max_patterns) then
              APACK_decompress(buffer,pattdata^[temp2])
            else limit_exceeded := TRUE;
          end;
    end;

  If (header.ffver = 10) then
    begin
      ResetF(f);
      BlockReadF(f,header5,SizeOf(header5),temp);
      If NOT ((temp = SizeOf(header5)) and (header5.ident = id)) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := DWORD_NULL;
      BlockReadF(f,buffer,header5.b0len,temp);
      If NOT (temp = header5.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header5.b1len,temp);
      If NOT (temp = header5.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header5.b2len,temp);
      If NOT (temp = header5.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header5.b3len,temp);
      If NOT (temp = header5.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header5.b4len[0],temp);
      If NOT (temp = header5.b4len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 1 to 15 do
        If ((header5.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header5.b4len[temp2],temp);
            If NOT (temp = header5.b4len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header5.b0len,2,crc);
      crc := Update32(header5.b1len,2,crc);
      crc := Update32(header5.b2len,2,crc);
      crc := Update32(header5.b3len,2,crc);

      For temp2 := 0 to 15 do
        crc := Update32(header5.b4len[temp2],2,crc);

      If (crc <> header5.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      SeekF(f,SizeOf(header5));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header5.b0len,temp);
      If NOT (temp = header5.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_data);
      BlockReadF(f,buffer,header5.b1len,temp);
      If NOT (temp = header5.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_macros);
      BlockReadF(f,buffer,header5.b2len,temp);
      If NOT (temp = header5.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.macro_table);
      BlockReadF(f,buffer,header5.b3len,temp);
      If NOT (temp = header5.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      songdata.tempo := header5.tempo;
      songdata.speed := header5.speed;
      songdata.common_flag := header5.cflag;
      songdata.patt_len := header5.patln;
      songdata.nm_tracks := header5.nmtrk;
      songdata.macro_speedup := header5.mcspd;
      songdata.flag_4op := header5.is4op;
      Move(header5.locks,songdata.lock_flags,SizeOf(songdata.lock_flags));

      APACK_decompress(buffer,songdata.pattern_order);
      BlockReadF(f,buffer,header5.b4len[0],temp);
      If NOT (temp = header5.b4len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,pattdata^[0]);
      For temp2 := 1 to 15 do
        If ((header5.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header5.b4len[temp2],temp);
            If NOT (temp = header5.b4len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            If (temp2*8+8 <= max_patterns) then
              APACK_decompress(buffer,pattdata^[temp2])
            else limit_exceeded := TRUE;
          end;
    end;

  If (header.ffver = 11) then
    begin
      crc := DWORD_NULL;
      BlockReadF(f,buffer,header.b0len,temp);
      If NOT (temp = header.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b1len,temp);
      If NOT (temp = header.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b2len,temp);
      If NOT (temp = header.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b3len,temp);
      If NOT (temp = header.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b4len,temp);
      If NOT (temp = header.b4len) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      BlockReadF(f,buffer,header.b5len[0],temp);
      If NOT (temp = header.b5len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      crc := Update32(buffer,temp,crc);
      For temp2 := 1 to 15 do
        If ((header.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header.b5len[temp2],temp);
            If NOT (temp = header.b5len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;
            crc := Update32(buffer,temp,crc);
          end;

      crc := Update32(header.b0len,2,crc);
      crc := Update32(header.b1len,2,crc);
      crc := Update32(header.b2len,2,crc);
      crc := Update32(header.b3len,2,crc);
      crc := Update32(header.b4len,2,crc);

      For temp2 := 0 to 15 do
        crc := Update32(header.b5len[temp2],2,crc);

      If (crc <> header.crc32) then
        begin
          CloseF(f);
          EXIT;
        end;

      init_songdata;
      load_flag := 0;

      SeekF(f,SizeOf(header));
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,buffer,header.b0len,temp);
      If NOT (temp = header.b0len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_data);
      BlockReadF(f,buffer,header.b1len,temp);
      If NOT (temp = header.b1len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.instr_macros);
      BlockReadF(f,buffer,header.b2len,temp);
      If NOT (temp = header.b2len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.macro_table);
      BlockReadF(f,buffer,header.b3len,temp);
      If NOT (temp = header.b3len) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,songdata.dis_fmreg_col);
      BlockReadF(f,buffer,header.b4len,temp);
      If NOT (temp = header.b4len) then
        begin
          CloseF(f);
          EXIT;
        end;

      songdata.tempo := header.tempo;
      songdata.speed := header.speed;
      songdata.common_flag := header.cflag;
      songdata.patt_len := header.patln;
      songdata.nm_tracks := header.nmtrk;
      songdata.macro_speedup := header.mcspd;
      songdata.flag_4op := header.is4op;
      Move(header.locks,songdata.lock_flags,SizeOf(songdata.lock_flags));

      APACK_decompress(buffer,songdata.pattern_order);
      BlockReadF(f,buffer,header.b5len[0],temp);
      If NOT (temp = header.b5len[0]) then
        begin
          CloseF(f);
          EXIT;
        end;

      APACK_decompress(buffer,pattdata^[0]);
      For temp2 := 1 to 15 do
        If ((header.patts-1) DIV 8 > PRED(temp2)) then
          begin
            BlockReadF(f,buffer,header.b5len[temp2],temp);
            If NOT (temp = header.b5len[temp2]) then
              begin
                CloseF(f);
                EXIT;
              end;

            If (temp2*8+8 <= max_patterns) then
              APACK_decompress(buffer,pattdata^[temp2])
            else limit_exceeded := TRUE;
          end;
    end;

  speed := songdata.speed;
  tempo := songdata.tempo;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  Case header.ffver of
    1..4: load_flag := 3;
    else  load_flag := 4;
  end;
end;


function dec2hex(dec: Byte): Byte;
begin dec2hex := (dec DIV 10)*16 +(dec MOD 10); end;

function truncate_string(str: String): String;
begin
  While (Length(str) > 0) and (str[Length(str)] in [#0,#32,#255]) do
    Delete(str,Length(str),1);
  truncate_string := str;
end;

procedure amd_file_loader;

type
  tPATDAT = array[0..$24] of
            array[0..$3f] of array[1..9] of
                             array[0..2] of Byte;
type
  tINSDAT = Record
              iName: array[1..23] of Char;     { Instrument name }
              iData: array[0..10] of Byte;     { Instrument data }
            end;
type
  tHEADER = Record
              sname: array[1..24]  of Char;    { Name of song [ASCIIZ] }
              aname: array[1..24]  of Char;    { Name of author [ASCIIZ] }
              instr: array[0..25]  of tINSDAT; { 26 instruments }
              snlen: Byte;                     { Song length }
              nopat: Byte;                     { Number of patterns -1 }
              order: array[0..$7f] of Byte;    { Pattern table }
              ident: array[1..9]   of Char;    { ID }
              versn: Byte;                     { Version 10h=normal module }
                                               {         11h=packed module }
            end;
const
  id_amd = '<oïQUîRoR';
  id_xms = 'MaDoKaN96';

var
  f: File;
  header: tHEADER;
  temp,tmp2,temp2,temp3,temp4: Longint;
  byte1,byte2,byte3: Byte;

procedure import_amd_instrument(inst: Byte; var data);
begin
  With songdata.instr_data[inst] do
    begin
      fm_data.AM_VIB_EG_modulator := tDUMMY_BUFF(data)[0];
      fm_data.KSL_VOLUM_modulator := tDUMMY_BUFF(data)[1];
      fm_data.ATTCK_DEC_modulator := tDUMMY_BUFF(data)[2];
      fm_data.SUSTN_REL_modulator := tDUMMY_BUFF(data)[3];
      fm_data.WAVEFORM_modulator  := tDUMMY_BUFF(data)[4]  AND 3;
      fm_data.AM_VIB_EG_carrier   := tDUMMY_BUFF(data)[5];
      fm_data.KSL_VOLUM_carrier   := tDUMMY_BUFF(data)[6];
      fm_data.ATTCK_DEC_carrier   := tDUMMY_BUFF(data)[7];
      fm_data.SUSTN_REL_carrier   := tDUMMY_BUFF(data)[8];
      fm_data.WAVEFORM_carrier    := tDUMMY_BUFF(data)[9]  AND 3;
      fm_data.FEEDBACK_FM         := tDUMMY_BUFF(data)[10] AND $0f;
    end;

  songdata.instr_data[inst].panning := 0;
  songdata.instr_data[inst].fine_tune := 0;
end;

procedure import_amd_event(pattern,line,channel,byte1,byte2,byte3: Byte);

var
  chunk: tCHUNK;
  param: Byte;

begin
  FillChar(chunk,SizeOf(chunk),0);
  If ((byte2 SHR 4)+(byte1 AND 1) SHL 4 <> 0) then
    chunk.instr_def := (byte2 SHR 4)+(byte1 AND 1) SHL 4;

  If (byte1 SHR 4 in [1..12]) and ((byte1 SHR 1) AND 7 in [0..7]) then
    chunk.note := 12*((byte1 SHR 1) AND 7)+(byte1 SHR 4);

  param := byte3 AND $7f;
  Case byte2 AND $0f of
  { ARPEGGIO }
    $00: begin
           chunk.effect_def := ef_Arpeggio;
           chunk.effect := dec2hex(param);
         end;

  { SLIDE FREQUENCY UP }
    $01: begin
           chunk.effect_def := ef_FSlideUp;
           chunk.effect := param;
         end;

  { SLIDE FREQUENCY DOWN }
    $02: begin
           chunk.effect_def := ef_FSlideDown;
           chunk.effect := param;
         end;

  { SET CARRIER/MODULATOR INTENSITY }
    $03: If (param DIV 10 in [1..9]) then
           begin
             chunk.effect_def := ef_SetCarrierVol;
             chunk.effect := (param DIV 10)*7;
           end
         else If (param MOD 10 in [1..9]) then
                begin
                  chunk.effect_def := ef_SetModulatorVol;
                  chunk.effect := (param MOD 10)*7;
                end;

  { SET THE VOLUME }
    $04: begin
           chunk.effect_def := ef_SetInsVolume;
           If (param < 64) then chunk.effect := param
           else chunk.effect := 63;
         end;

  { JUMP INTO PATTERN }
    $05: begin
           chunk.effect_def := ef_PositionJump;
           If (param < 100) then chunk.effect := param
           else chunk.effect := 99;
         end;

  { PATTERNBREAK }
    $06: begin
           chunk.effect_def := ef_PatternBreak;
           If (param < 64) then chunk.effect := param
           else chunk.effect := 63;
         end;

  { SET SONGSPEED }
    $07: If (param < 99) then
           If (param in [1..31]) then
             begin
               chunk.effect_def := ef_SetSpeed;
               chunk.effect := param;
             end
           else begin
                  chunk.effect_def := ef_SetTempo;
                  If (param = 0) then chunk.effect := 18
                  else chunk.effect := param;
                end;

  { TONEPORTAMENTO }
    $08: begin
           chunk.effect_def := ef_TonePortamento;
           chunk.effect := param;
         end;

  { EXTENDED COMMAND }
    $09: If (param < 60) then
           Case param DIV 10 of
           { DEFINE CELL-TREMOLO }
             0: If (param MOD 10 < 2) then
                  begin
                    chunk.effect_def := ef_Extended;
                    chunk.effect := dec2hex(param);
                  end;

           { DEFINE CELL-VIBRATO }
             1: If (param MOD 10 < 2) then
                  begin
                    chunk.effect_def := ef_Extended;
                    chunk.effect := $10+dec2hex(param);
                  end;

           { INCREASE VOLUME FAST }
             2: begin
                  chunk.effect_def := ef_VolSlide;
                  chunk.effect := (param MOD 10)*16;
                end;

           { DECREASE VOLUME FAST }
             3: begin
                  chunk.effect_def := ef_VolSlide;
                  chunk.effect := param MOD 10;
                end;

           { INCREASE VOLUME FINE }
             4: begin
                  chunk.effect_def := ef_Extended2;
                  chunk.effect := ef_ex2_VolSlideUpXF*16+(param MOD 10);
                end;

           { DECREASE VOLUME FINE }
             5: begin
                  chunk.effect_def := ef_Extended2;
                  chunk.effect := ef_ex2_VolSlideDnXF*16+(param MOD 10);
                end;
           end;
  end;

// specific corrections for Amusic event
  If (chunk.note = 0) then chunk.instr_def := 0;
  put_chunk(pattern,line,channel,chunk);
end;

procedure import_amd_packed_patterns(var data; patterns: Byte);

var
  temp,temp2,temp3,temp4,temp5: Word;
  count: Byte;

var
  tracks: Word;
  track_order: array[0..$3f] of array[1..9] of Word;
  track: array[0..$3f] of tCHUNK;

begin
  temp := (patterns+1)*9*SizeOf(WORD);
  Move(data,track_order,temp);

  tracks := tDUMMY_BUFF(data)[temp]+(tDUMMY_BUFF(data)[temp+1]) SHL 8;
  Inc(temp,2);

  temp3 := 0;
  temp4 := 0;
  count := 0;

  Repeat
    If (count = 0) then
      begin
        If (temp3 = 0) then
          begin
            temp2 := tDUMMY_BUFF(data)[temp]+(tDUMMY_BUFF(data)[temp+1]) SHL 8;
            Inc(temp,2);
          end;

        If (tDUMMY_BUFF(data)[temp] OR $80 <> tDUMMY_BUFF(data)[temp]) then
          begin
            If (temp2 DIV 9 <= $3f) and (temp2 MOD 9 < 9) then
              import_amd_event(temp2 DIV 9,temp3,temp2 MOD 9 +1,
                               tDUMMY_BUFF(data)[temp+2],
                               tDUMMY_BUFF(data)[temp+1],
                               tDUMMY_BUFF(data)[temp+0]);
            Inc(temp,3);
          end
        else
          begin
            count := (tDUMMY_BUFF(data)[temp] AND $7f)-1;
            Inc(temp);
          end;
      end
    else Dec(count);

    Inc(temp3);
    If (temp3 > $3f) then
      begin
        temp3 := 0;
        count := 0;
        Inc(temp4);
      end;
  until NOT (temp4 < tracks);

  For temp := 0 to patterns do
    For temp2 := 1 to 9 do
      begin
        temp3 := track_order[temp][temp2];
        temp4 := temp3 DIV 9;

        If (temp3 < 64*9) then
          begin
            For temp5 := 0 to $3f do
              get_chunk(temp4,temp5,temp3 MOD 9 +1,track[temp5]);
            For temp5 := 0 to $3f do
              put_chunk( temp,temp5,temp2,track[temp5]);
          end;
      end;
end;

function get_byte(var pos: Longint): Byte;
begin
  If (pos = SizeOf(buffer)) then
    begin
      Move(buf2,buffer,SizeOf(buf2));
      pos := 0;
    end;
  get_byte := buffer[pos];
  Inc(pos);
end;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and
         ((header.ident = id_amd) or (header.ident = id_xms))) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If NOT (header.versn in [$10,$11]) then
    begin
      CloseF(f);
      EXIT;
    end;

  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer),temp);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  tmp2 := WORD_NULL;
  If (temp = SizeOf(buffer)) then
    begin
      FillChar(buf2,SizeOf(buf2),0);
      BlockReadF(f,buf2,SizeOf(buf2),tmp2);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  tempo := 50;
  speed := 6;

  songdata.tempo := tempo;
  songdata.speed := speed;

  For temp2 := 0 to header.snlen-1 do
    If (temp2 < 128) and (header.order[temp2] in [0..header.nopat]) then
      songdata.pattern_order[temp2] := header.order[temp2];

  For temp2 := 0 to 25 do
    begin
      import_amd_instrument(temp2+1,header.instr[temp2].iData);
      songdata.instr_names[temp2+1] :=
        Copy(songdata.instr_names[temp2+1],1,9)+
        truncate_string(header.instr[temp2].iName);
    end;

  temp := 0;
  If (header.versn = $10) then
    For temp2 := 0 to header.nopat do
      For temp3 := 0 to $3f do
        For temp4 := 1 to 9 do
          begin
            byte3 := get_byte(temp);
            byte2 := get_byte(temp);
            byte1 := get_byte(temp);
            import_amd_event(temp2,temp3,temp4,byte1,byte2,byte3);
          end
  else
    import_amd_packed_patterns(buffer,header.nopat);

  songdata.common_flag := songdata.common_flag OR $80;
  songdata.songname := CutStr(asciiz_string(header.sname));
  songdata.composer := CutStr(asciiz_string(header.aname));
  import_old_flags;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  If (header.ident = id_amd) then load_flag := 5
  else load_flag := 6;
end;

procedure import_hsc_instrument(inst: Byte; var data); forward;

procedure import_cff_event(patt,line,chan,byte0,byte1,byte2: Byte);

var
  chunk: tCHUNK;
  temp1,temp2,temp3,temp4: Byte;

begin
  FillChar(chunk,SizeOf(chunk),0);
  temp1 := byte2;
  temp2 := temp1 DIV 16;
  temp3 := temp1 MOD 16;

  Case CHAR(byte1) of
  { SET SPEED }
    'A': If (temp1 > 0) then
           begin
             chunk.effect_def := ef_SetSpeed;
             chunk.effect := temp1;
           end;

  { SET CARRIER WAVEFORM }
    'B': If (temp1 < 4) then
           begin
             chunk.effect_def := ef_SetWaveform;
             chunk.effect := temp1*16;
           end;

  { SET MODULATOR VOLUME }
    'C': begin
           chunk.effect_def := ef_SetModulatorVol;
           If (temp1 < 64) then chunk.effect := 63-temp1
           else chunk.effect := 0;
         end;

  { VOLUME SLIDE UP/DOWN }
    'D': begin
           chunk.effect_def := ef_VolSlide;
           chunk.effect := temp1;
         end;

  { SLIDE DOWN }
    'E': If (temp1 <> 0) then
           begin
             chunk.effect_def := ef_FSlideDown;
             chunk.effect := temp1;
           end;

  { SLIDE UP }
    'F': If (temp1 <> 0) then
           begin
             chunk.effect_def := ef_FSlideUp;
             chunk.effect := temp1;
           end;

  { SET CARRIER VOLUME }
    'G': begin
           chunk.effect_def := ef_SetCarrierVol;
           If (temp1 < 64) then chunk.effect := 63-temp1
           else chunk.effect := 0;
         end;

  { SET TEMPO }
    'H': If (temp1 > 0) then
           begin
             chunk.effect_def := ef_SetTempo;
             If NOT (temp1 > 21) then temp1 := 125;
             temp4 := 1412926 DIV LONGINT(temp1 SHR 1);
             chunk.effect := 1;
             While (1193180 DIV chunk.effect > temp4) and
                   (chunk.effect < 255) do
               Inc(chunk.effect);
           end;

  { SET INSTRUMENT }
    'I': If (temp1 < 47) then
           begin
             chunk.effect_def := ef_Extended;
             chunk.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol;
             chunk.instr_def := temp1+1;
           end;

  { ARPEGGIO }
    'J': begin
           chunk.effect_def := ef_Arpeggio;
           chunk.effect := temp1;
         end;

  { JUMP TO ORDER }
    'K': If (temp1 < 128) then
           begin
             chunk.effect_def := ef_PositionJump;
             chunk.effect := temp1;
           end;

  { JUMP TO NEXT PATTERN IN ORDER }
    'L': chunk.effect_def := ef_PatternBreak;

  { SET TREMOLO HIGHER / SET VIBRATO DEEPER }
    'M': begin
           chunk.effect_def := ef_Extended;
           If (temp2 = 1) and (temp3 = 0) then chunk.effect := dec2hex(01);
           If (temp2 = 0) and (temp3 = 1) then chunk.effect := dec2hex(10);
           If (temp2 = 1) and (temp3 = 1) then chunk.effect := dec2hex(11);
         end;
  end;

  Case byte0 of
  { REGULAR NOTE }
    1..12*8+1: begin
                If NOT fix_c_note_bug then chunk.note := byte0
                else begin
                       chunk.note := byte0+1;
                       If (chunk.note > 12*8+1) then
                         chunk.note := 12*8+1;
                     end;
               end;
  { PAUSE }
    $6d: chunk.note := BYTE_NULL;
  end;

  put_chunk(patt,line,chan,chunk);
end;

procedure import_cff_patterns(var data; patterns: Byte);

type
  tPATDAT = array[0..$24] of
            array[0..$3f] of array[1..9] of
                             array[0..2] of Byte;

var
  voice: array[1..9] of Byte;
  arpgg: array[1..9] of Byte;
  chunk: tCHUNK;
  temp,temp2,temp3,temp4: Byte;
  order,patt: Byte;
  patt_break: Byte;
  patts: String;

begin
  patts := '';
  FillChar(arpgg,SizeOf(arpgg),0);
  If NOT accurate_conv then
       For temp := 1 to 9 do voice[temp] := temp
  else For temp := 1 to 9 do voice[temp] := 0;

  For temp := 0 to $24 do
    For temp2 := 0 to $3f do
      For temp3 := 1 to 9 do
        If NOT Empty(tPATDAT(data)[temp][temp2][temp3],3) then
          import_cff_event(temp,temp2,temp3,tPATDAT(data)[temp][temp2][temp3][0],
                                            tPATDAT(data)[temp][temp2][temp3][1],
                                            tPATDAT(data)[temp][temp2][temp3][2]);
  order := 0;
  patt := BYTE_NULL;

  Repeat
    If (songdata.pattern_order[order] > $24) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        patt_break := BYTE_NULL;
        For temp2 := 0 to $3f do
          For temp3 := 1 to 9 do
             begin
               get_chunk(patt,temp2,temp3,chunk);
               temp4 := tPATDAT(data)[patt][temp2][temp3][2];

               Case CHAR(tPATDAT(data)[patt][temp2][temp3][1]) of
               { SET MODULATOR VOLUME }
                 'C': If (chunk.instr_def = 0) and NOT accurate_conv then
                        chunk.instr_def := voice[temp3]
                      else If (chunk.instr_def = 0) and
                              (voice[temp3] = 0) then chunk.instr_def := temp3;

               { SET CARRIER VOLUME }
                 'G': If (chunk.instr_def = 0) and NOT accurate_conv then
                        chunk.instr_def := voice[temp3]
                      else If (chunk.instr_def = 0) and
                              (voice[temp3] = 0) then chunk.instr_def := temp3;

               { SET INSTRUMENT }
                 'I': If (temp4 < 47) then
                        If (temp2 <> patt_break) then
                          begin
                            voice[temp3] := temp4+1;
                            If NOT accurate_conv then
                              chunk.instr_def := voice[temp3];
                          end;

               { ARPEGGIO }
                 'J': begin
                        chunk.effect_def := ef_Arpeggio;
                        If (temp4 <> 0) then
                          begin
                            chunk.effect := temp4;
                            arpgg[temp3] := temp4;
                          end
                        else chunk.effect := arpgg[temp3];
                      end;

               { JUMP TO ORDER }
                 'K': If (temp4 < 128) then
                        patt_break := temp2+1;

               { JUMP TO NEXT PATTERN IN ORDER }
                 'L': patt_break := temp2+1;
               end;

               Case tPATDAT(data)[patt][temp2][temp3][0] of
               { REGULAR NOTE }
                 1..12*8+1: begin
                             If accurate_conv then
                               If (voice[temp3] = 0) then
                                 begin
                                   voice[temp3] := temp3;
                                   chunk.instr_def := voice[temp3];
                                 end;

                              If NOT accurate_conv then
                                chunk.instr_def := voice[temp3];
                            end;
               end;

               If (Pos(CHR(songdata.pattern_order[order]),patts) = 0) then
                 put_chunk(patt,temp2,temp3,chunk);
             end;
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $40);
end;

var
  _cff_heap: array[0..65535] of Byte;
  _cff_dictionary: array[0..32767] of Pointer;

procedure cff_file_loader;

type
  tHEADER = Record
              ident: array[1..16] of Char;    { Identification }
              versn: Byte;                    { Format version }
              fsize: Word;                    { Filesize -32 }
              cflag: Byte;                    { Flag 1=compressed data }
              resrv: array[0..11] of Byte;    { Reserved }
            end;
type
  tINSDAT = Record
              iData: array[0..11] of Byte;    { Instrument data }
              iName: array[1..20] of Char;    { Instrument name }
            end;
type
  tHEADR2 = Record
              instr: array[0..46] of tINSDAT; { 47 instruments }
              nopat: Byte;                    { Number of patterns }
              ascii: array[1..31] of Char;    { ASCII blab }
              writr: array[1..20] of Char;    { Song writer }
              sname: array[1..20] of Char;    { Song name }
              order: array[0..64] of Byte;    { Pattern order }
            end;
const
  _PRE_ASCII_BLAB_SIZE = $5e1; // SizeOf(tHEADR2.instr)+SizeOf(tHEADR2.nopat)

const
  id = '<CUD-FM-File>'+#26+CHR($de)+CHR($e0);
  ascii_blab = 'CUD-FM-File - SEND A POSTCARD -';

var
  f: File;
  header: tHEADER;
  headr2: tHEADR2;
  temp,temp2: Longint;
  offs,out_size: Longint;

function LZTYR_decompress(var input,output): Longint;

type
  tSTRING = array[0..255] of Byte;

var
  input_idx: Longint;

  the_string,
  temp_string: tSTRING;

  old_code_length: Byte;
  repeat_length: Byte;
  repeat_counter: Longint;
  output_length: Longint;
  code_length: Byte;
  bits_buffer: Longint;
  bits_left: Word;
  old_code: Longint;
  new_code: Longint;
  idx: Word;

  _cff_heap_length: Word;
  _cff_dictionary_length: Word;

function get_code: Longint;

var
  code: Longint;

begin
  While (bits_left < code_length) do
    begin
      bits_buffer := bits_buffer OR (tDUMMY_BUFF(input)[input_idx] SHL
                                     bits_left);
      Inc(input_idx);
      Inc(bits_left,8);
    end;

  code := bits_buffer AND ((1 SHL code_length)-1);
  bits_buffer := bits_buffer SHR code_length;
  Dec(bits_left,code_length);
  get_code := code;
end;

procedure translate_code(code: Longint; var str: tSTRING);

var
  translated_string: tSTRING;

begin
  If (code >= $104) then
    Move(_cff_dictionary[code-$104]^,translated_string,
         BYTE(_cff_dictionary[code-$104]^)+1)
  else begin
         translated_string[0] := 1;
         translated_string[1] := (code-4) AND $0ff;
        end;

  Move(translated_string,str,256);
end;

procedure startup;

var
  idx: Longint;

begin
  old_code := get_code;
  translate_code(old_code,the_string);

  If (the_string[0] > 0) then
    For idx := 0 to the_string[0]-1 do
      begin
        tDUMMY_BUFF(output)[output_length] := the_string[idx+1];
        Inc(output_length);
      end;
end;

procedure cleanup;
begin
  code_length := 9;
  bits_buffer := 0;
  bits_left := 0;
  _cff_heap_length := 0;
  _cff_dictionary_length := 0;
end;

procedure expand__cff_dictionary(str: tSTRING);
begin
  If (str[0] >= $0f0) then EXIT;
  Move(str,_cff_heap[_cff_heap_length],str[0]+1);
  _cff_dictionary[_cff_dictionary_length] := Addr(_cff_heap[_cff_heap_length]);
  Inc(_cff_dictionary_length);
  Inc(_cff_heap_length,str[0]+1);
end;

begin
  input_idx := 0;
  output_length := 0;
  cleanup;
  startup;

  Repeat
    new_code := get_code;

    // $00: end of data
    If (new_code = 0) then BREAK;

    // $01: end of block
    If (new_code = 1) then
      begin
        cleanup;
        startup;
        CONTINUE;
      end;

    // $02: expand code length
    If (new_code = 2) then
      begin
        Inc(code_length);
        CONTINUE;
      end;

    // $03: RLE
    If (new_code = 3) then
      begin
        old_code_length := code_length;
        code_length := 2;
        repeat_length := get_code+1;
        code_length := 4 SHL get_code;
        repeat_counter := get_code;

        For idx := 0 to PRED(repeat_counter*repeat_length) do
          begin
            tDUMMY_BUFF(output)[output_length] :=
              tDUMMY_BUFF(output)[output_length-repeat_length];
            Inc(output_length);
          end;

        code_length := old_code_length;
        startup;
        CONTINUE;
      end;

    If (new_code >= $104+_cff_dictionary_length) then
      begin
        Inc(the_string[0]);
        the_string[the_string[0]] := the_string[1];
      end
    else begin
           translate_code(new_code,temp_string);
           Inc(the_string[0]);
           the_string[the_string[0]] := temp_string[1];
         end;

    expand__cff_dictionary(the_string);
    translate_code(new_code,the_string);

    For idx := 0 to PRED(the_string[0]) do
      begin
        tDUMMY_BUFF(output)[output_length] := the_string[idx+1];
        Inc(output_length);
      end;

    old_code := new_code;
  until FALSE;

  LZTYR_decompress := output_length;
end;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) or
     (FileSize(f) > SizeOf(buffer)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If (header.cflag = 1) then
    begin
      FillChar(buffer,SizeOf(buffer),0);
      ResetF(f);
      BlockReadF(f,buffer,SizeOf(buffer),temp);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      CloseF(f);
      temp := LZTYR_decompress(buffer[$30],hash_buffer);
      out_size := temp;

      offs := SensitiveScan(hash_buffer,0,temp,ascii_blab);
      If (offs <> _PRE_ASCII_BLAB_SIZE) then
        begin
          EXIT;
        end;

      FillChar(buffer,SizeOf(buffer),0);
      Move(hash_buffer,headr2,SizeOf(headr2));
      Move(POINTER(Ofs(hash_buffer)+SizeOf(headr2))^,buffer,out_size-SizeOf(headr2));

    end
  else
    begin
      BlockReadF(f,headr2,SizeOf(headr2),temp);
      If NOT ((temp = SizeOf(headr2)) and (headr2.ascii = ascii_blab)) then
        begin
          CloseF(f);
          EXIT;
        end;

      FillChar(buffer,SizeOf(buffer),0);
      BlockReadF(f,buffer,SizeOf(buffer),temp);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
      CloseF(f);
    end;

  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  tempo := 51;
  speed := 6;

  songdata.tempo := tempo;
  songdata.speed := speed;

  For temp2 := 0 to 64 do
    If (headr2.order[temp2] in [0..headr2.nopat]) then
      songdata.pattern_order[temp2] := headr2.order[temp2];

  For temp2 := 0 to 46 do
    begin
      import_hsc_instrument(temp2+1,headr2.instr[temp2].iData);
      songdata.instr_data[temp2+1].fine_tune := 0;
      songdata.instr_names[temp2+1] :=
        Copy(songdata.instr_names[temp2+1],1,9)+
        truncate_string(headr2.instr[temp2].iName);
    end;

  songdata.common_flag := songdata.common_flag OR 2;
  songdata.songname := CutStr(headr2.sname);
  songdata.composer := CutStr(headr2.writr);
  import_old_flags;

  import_cff_patterns(buffer,headr2.nopat);
  songdata_title := NameOnly(songdata_source);
  load_flag := 7;
end;

procedure import_standard_instrument(inst: Byte; var data);
begin
  With songdata.instr_data[inst] do
    begin
      fm_data.AM_VIB_EG_modulator := tDUMMY_BUFF(data)[0];
      fm_data.AM_VIB_EG_carrier   := tDUMMY_BUFF(data)[1];
      fm_data.KSL_VOLUM_modulator := tDUMMY_BUFF(data)[2];
      fm_data.KSL_VOLUM_carrier   := tDUMMY_BUFF(data)[3];
      fm_data.ATTCK_DEC_modulator := tDUMMY_BUFF(data)[4];
      fm_data.ATTCK_DEC_carrier   := tDUMMY_BUFF(data)[5];
      fm_data.SUSTN_REL_modulator := tDUMMY_BUFF(data)[6];
      fm_data.SUSTN_REL_carrier   := tDUMMY_BUFF(data)[7];
      fm_data.WAVEFORM_modulator  := tDUMMY_BUFF(data)[8]  AND 3;
      fm_data.WAVEFORM_carrier    := tDUMMY_BUFF(data)[9]  AND 3;
      fm_data.FEEDBACK_FM         := tDUMMY_BUFF(data)[10] AND $0f;
    end;

  songdata.instr_data[inst].panning := 0;
  songdata.instr_data[inst].fine_tune := 0;
end;

procedure dfm_file_loader;

const
  id = 'DFM'+#26;

var
  header: Record
            ident: array[1..4] of Char;
            versn: Word;
            sname: String[32];
            tempo: Byte;
            instn: array[1..32] of String[11];
            instd: array[1..32] of tFM_INST_DATA;
            order: array[1..128] of Byte;
            patts: Byte;
          end;

var
  f: File;
  temp,temp2,temp3: Longint;
  pattern,line,channel,byte1,byte2: Byte;

procedure import_dfm_event(patt,line,chan,byte1,byte2: Byte);

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  If (byte1 AND $0f in [1..12,15]) and ((byte1 SHR 4) AND 7 in [0..7]) then
    If (byte1 AND $0f <> 15) then
      chunk.note := SUCC(PRED(byte1 AND $0f)+((byte1 SHR 4) AND 7)*12)
    else chunk.note := BYTE_NULL;

  Case byte2 SHR 5 of
   { INSTRUMENT CHANGE }
    1: chunk.instr_def := SUCC(byte2 AND $1f);

   { SET INSTRUMENT VOLUME }
    2: begin
         chunk.effect_def := ef_SetInsVolume;
         chunk.effect := (byte2 AND $1f)*2;
       end;

   { TEMPO CHANGE }
    3: begin
         chunk.effect_def := ef_SetSpeed;
         chunk.effect := SUCC(byte2 AND $1f);
       end;

   { SLIDE UP }
    4: begin
         chunk.effect_def := ef_FSlideUpFine;
         chunk.effect := byte2 AND $1f;
       end;

   { SLIDE DOWN }
    5: begin
         chunk.effect_def := ef_FSlideDownFine;
         chunk.effect := byte2 AND $1f;
       end;

   { END OF PATTERN }
    7: chunk.effect_def := ef_PatternBreak;
  end;

  put_chunk(patt,line,chan,chunk);
end;

procedure process_dfm_patterns(patterns: Byte);

var
  chunk: tCHUNK;
  temp2,temp3: Byte;
  order,patt: Byte;
  patts: String;
  instr_cache: array[1..18] of Byte;

begin
  patts := '';
  FillChar(instr_cache,SizeOf(instr_cache),0);
  order := 0;
  patt := BYTE_NULL;

  Repeat
    If (songdata.pattern_order[order] >= $80) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        For temp2 := 0 to $3f do
          For temp3 := 1 to 9 do
            begin
              get_chunk(patt,temp2,temp3,chunk);
              If (chunk.instr_def <> 0) then
                begin
                  chunk.effect_def := ef_Extended;
                  chunk.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol;
                  instr_cache[temp3] := chunk.instr_def;
                  If NOT (chunk.note in [1..12*8+1]) and
                     NOT accurate_conv then
                    chunk.instr_def := 0;
                end
              else If (chunk.note in [1..12*8+1]) and
                      (chunk.instr_def = 0) and NOT accurate_conv then
                     chunk.instr_def := instr_cache[temp3];

              If (Pos(CHR(songdata.pattern_order[order]),patts) = 0) then
                put_chunk(patt,temp2,temp3,chunk);
            end;
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);
end;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer),temp);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  tempo := 135;
  speed := SUCC(header.tempo);

  songdata.songname := CutStr(header.sname);
  songdata.tempo := tempo;
  songdata.speed := speed;
  songdata.common_flag := songdata.common_flag OR 1;
  songdata.common_flag := songdata.common_flag OR 2;
  songdata.common_flag := songdata.common_flag OR 8;
  songdata.common_flag := songdata.common_flag OR $10;
  import_old_flags;

  For temp2 := 1 to 128 do
    If (header.order[temp2] in [0..$7f]) then
      songdata.pattern_order[temp2-1] := header.order[temp2]
    else If (header.order[temp2] = $80) then BREAK
         else songdata.pattern_order[temp2-1] := $80+temp2;

  For temp2 := 1 to 32 do
    begin
      songdata.instr_names[temp2] :=
        Copy(songdata.instr_names[temp2],1,9)+
        CutStr(header.instn[temp2]);
      While (BYTE(songdata.instr_names[temp2][
                    Length(songdata.instr_names[temp2])]) < 32) and
            (Length(songdata.instr_names[temp2]) <> 0) do
        Delete(songdata.instr_names[temp2],
               Length(songdata.instr_names[temp2]),1);
      import_standard_instrument(temp2,header.instd[temp2]);
    end;

  temp2 := 0;
  temp3 := 0;
  Repeat
    pattern := buffer[temp2];
    If (pattern > 127) then
      begin
        CloseF(f);
        EXIT;
      end;

    Inc(temp2);
    Inc(temp3);

    For line := 0 to $3f do
      For channel := 1 to 9 do
        begin
          byte1 := buffer[temp2];
          If (temp2 >= temp) then
            begin
              CloseF(f);
              EXIT;
            end
          else Inc(temp2);

          If (byte1 OR $80 <> byte1) then byte2 := 0
          else begin
                 byte2 := buffer[temp2];
                 Inc(temp2);
               end;
          import_dfm_event(pattern,line,channel,byte1,byte2);
        end;
  until (temp2 >= temp);

  process_dfm_patterns(temp3);
  CloseF(f);

  songdata_title := NameOnly(songdata_source);
  load_flag := 8;
end;

type
  tHSC_PATTERNS = array[0..$31] of
                  array[0..$3f] of array[1..9] of Word;
type
  tHSC_DATA = Record
                instr: array[0..$7f] of array[0..$0b] of Byte;
                order: array[0..$31] of Byte;
                patts: tHSC_PATTERNS;
              end;

procedure import_hsc_event(patt,line,chan: Byte; event: Word);

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  Case HI(event) of
  { REGULAR NOTE }
    1..12*8+1: If NOT fix_c_note_bug then chunk.note := HI(event)
               else begin
                      chunk.note := HI(event)+1;
                      If (chunk.note > 12*8+1) then
                        chunk.note := 12*8+1;
                    end;
  { PAUSE }
    $7f: chunk.note := BYTE_NULL;

  { INSTRUMENT }
    $80: begin
           chunk.effect_def := ef_Extended;
           chunk.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol;
           chunk.instr_def := LO(event)+1;
           chunk.note := BYTE_NULL;
         end;
  end;

  If (HI(event) <> $80) then
    Case (LO(event) AND $0f0) of
    { PATTERNBREAK }
      $00: If (LO(event) AND $0f = 1) then
             chunk.effect_def := ef_PatternBreak;

    { MANUAL SLIDE UP }
      $10: begin
             chunk.effect_def := ef_Extended2;
             chunk.effect := ef_ex2_FineTuneUp*16+
                             max(LO(event) AND $0f +1,15);
           end;

    { MANUAL SLIDE DOWN }
      $20: begin
             chunk.effect_def := ef_Extended2;
             chunk.effect := ef_ex2_FineTuneDown*16+
                             max(LO(event) AND $0f +1,15);
           end;

    { SET CARRIER VOLUME }
      $a0: begin
             chunk.effect_def := ef_SetCarrierVol;
             chunk.effect := 63-(LO(event) AND $0f)*4;
             chunk.instr_def := LO(event)+1;
           end;

    { SET MODULATOR VOLUME }
      $b0: begin
             chunk.effect_def := ef_SetModulatorVol;
             chunk.effect := 63-(LO(event) AND $0f)*4;
           end;

    { SET INSTRUMENT VOLUME }
      $c0: begin
             chunk.effect_def := ef_SetInsVolume;
             chunk.effect := 63-(LO(event) AND $0f)*4;
           end;

    { SET SPEED }
      $f0: begin
             chunk.effect_def := ef_SetSpeed;
             chunk.effect := (LO(event) AND $0f)+1;
           end;
    end;
  put_chunk(patt,line,chan,chunk);
end;

procedure import_hsc_patterns(var data; patterns: Byte);

var
  voice: array[1..9] of Byte;
  event: Word;
  chunk: tCHUNK;
  temp,temp2,temp3: Byte;
  order,patt: Byte;
  patt_break: Byte;
  patts: String;

function _hsc_event(patt,line,chan: Byte): Word;
begin
  _hsc_event := LO(tHSC_PATTERNS(data)[patt][line][chan+1])+
                HI(tHSC_PATTERNS(data)[patt][line][chan]) SHL 8;
end;

begin { import_hsc_patterns }
  patts := '';
  If NOT accurate_conv then
       For temp := 1 to 9 do voice[temp] := temp
  else For temp := 1 to 9 do voice[temp] := 0;

  For temp := 0 to $31 do
    For temp2 := 0 to $3f do
      For temp3 := 1 to 9 do
        If (_hsc_event(temp,temp2,temp3) <> 0) then
          import_hsc_event(temp,temp2,temp3,_hsc_event(temp,temp2,temp3));

  order := 0;
  patt := BYTE_NULL;

  Repeat
    If (songdata.pattern_order[order] > $31) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        patt_break := BYTE_NULL;
        For temp2 := 0 to $3f do
          For temp3 := 1 to 9 do
            begin
              get_chunk(patt,temp2,temp3,chunk);
              event := _hsc_event(patt,temp2,temp3);

              Case HI(event) of
              { REGULAR NOTE }
                1..12*8+1: begin
                             If accurate_conv then
                               If (voice[temp3] = 0) then
                                 begin
                                   voice[temp3] := temp3;
                                   chunk.instr_def := voice[temp3];
                                 end;

                             If NOT accurate_conv then
                               chunk.instr_def := voice[temp3];
                           end;

              { INSTRUMENT }
                $80: If (temp2 <> patt_break) then
                       begin
                         voice[temp3] := LO(event)+1;
                         If NOT accurate_conv then
                           begin
                             chunk.instr_def := voice[temp3];
                             chunk.note := BYTE_NULL;
                           end;
                       end;
              end;

              If (HI(event) <> $80) then
                Case (LO(event) AND $0f0) of
                { PATTERNBREAK }
                  $00: If (LO(event) AND $0f = 1) then
                         patt_break := temp2+1;

                { SET CARRIER VOLUME }
                  $a0: If (chunk.instr_def = 0) and NOT accurate_conv then
                         chunk.instr_def := voice[temp3]
                       else If (chunk.instr_def = 0) and
                               (voice[temp3] = 0) then chunk.instr_def := temp3;

                { SET MODULATOR VOLUME }
                  $b0: If (chunk.instr_def = 0) and NOT accurate_conv then
                         chunk.instr_def := voice[temp3]
                       else If (chunk.instr_def = 0) and
                               (voice[temp3] = 0) then chunk.instr_def := temp3;

                { SET INSTRUMENT VOLUME }
                  $c0: If (chunk.instr_def = 0) and NOT accurate_conv then
                         chunk.instr_def := voice[temp3]
                       else If (chunk.instr_def = 0) and
                               (voice[temp3] = 0) then chunk.instr_def := temp3;
                end;

              If (Pos(CHR(songdata.pattern_order[order]),patts) = 0) then
                put_chunk(patt,temp2,temp3,chunk);
            end;
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);
end;

procedure import_hsc_instrument(inst: Byte; var data);
begin
  With songdata.instr_data[inst] do
    begin
      fm_data.AM_VIB_EG_carrier   := tDUMMY_BUFF(data)[0];
      fm_data.AM_VIB_EG_modulator := tDUMMY_BUFF(data)[1];
      fm_data.KSL_VOLUM_carrier   := tDUMMY_BUFF(data)[2];
      fm_data.KSL_VOLUM_modulator := tDUMMY_BUFF(data)[3];
      fm_data.ATTCK_DEC_carrier   := tDUMMY_BUFF(data)[4];
      fm_data.ATTCK_DEC_modulator := tDUMMY_BUFF(data)[5];
      fm_data.SUSTN_REL_carrier   := tDUMMY_BUFF(data)[6];
      fm_data.SUSTN_REL_modulator := tDUMMY_BUFF(data)[7];
      fm_data.FEEDBACK_FM         := tDUMMY_BUFF(data)[8]  AND $0f;
      fm_data.WAVEFORM_carrier    := tDUMMY_BUFF(data)[9]  AND 3;
      fm_data.WAVEFORM_modulator  := tDUMMY_BUFF(data)[10] AND 3;
    end;

  songdata.instr_data[inst].panning := 0;
  songdata.instr_data[inst].fine_tune := tDUMMY_BUFF(data)[11] SHR 4;
end;

var
  hscbuf: tHSC_DATA;

procedure hsc_file_loader;

const
  HSC_KSL: array[0..3] of Byte = (0,3,2,1);

var
  f: File;
  temp,temp2,temp3: Longint;

begin
  If (Lower(ExtOnly(songdata_source)) <> 'hsc') then
    begin
      load_flag := $7f;
      EXIT;
    end;

  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  FillChar(hscbuf,SizeOf(hscbuf),0);
  BlockReadF(f,hscbuf,SizeOf(hscbuf),temp);
  If (temp < SizeOf(hscbuf.instr)+SizeOf(hscbuf.order)) then
    begin
      CloseF(f);
      EXIT;
    end;

  For temp2 := 0 to $31 do
    If (hscbuf.order[temp2] > $b0) then hscbuf.order[temp2] := $080;

  temp3 := 0;
  While (temp3 < temp-SizeOf(hscbuf.instr)-SizeOf(hscbuf.order)) do
    begin
      If NOT (tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3+1] in
             [1..12*8+1,$00,$7f,$80]) or
         NOT (tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3] AND $0f0 in
             [$00,$10,$20,$a0,$b0,$c0,$f0]) then
        begin
          If NOT (tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3+1] in
                 [1..12*8+1,$00,$7f,$80]) then
            tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3+1] := $00;

          If NOT (tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3] AND $0f0 in
                 [$00,$10,$20,$a0,$b0,$c0,$f0]) then
            tDUMMY_BUFF(Addr(hscbuf.patts)^)[temp3] := 0;
        end;
      Inc(temp3,2);
    end;

  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  tempo := 18;
  speed := 2;

  songdata.common_flag := songdata.common_flag OR 2;
  songdata.tempo := tempo;
  songdata.speed := speed;
  import_old_flags;

  For temp2 := 0 to $31 do
    songdata.pattern_order[temp2] := hscbuf.order[temp2];

  import_hsc_patterns(hscbuf.patts,(temp-SizeOf(hscbuf.instr)
                                        -SizeOf(hscbuf.order)-1) DIV $480);

// specific corrections for HSC-Tracker instrument
  For temp2 := 0 to $7f do
    begin
      import_hsc_instrument(temp2+1,hscbuf.instr[temp2]);
      With songdata.instr_data[temp2+1].fm_data do
        begin
          KSL_VOLUM_modulator := KSL_VOLUM_modulator AND $3f+
                                 HSC_KSL[KSL_VOLUM_modulator SHR 6] SHL 6;
          KSL_VOLUM_carrier   := KSL_VOLUM_carrier AND $3f+
                                 HSC_KSL[KSL_VOLUM_carrier SHR 6] SHL 6;
        end;
    end;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 9;
end;

type
  tMTK_DATA = Record
                sname: String[33];
                compo: String[33];
                instn: array[0..$7f] of String[33];
                instt: array[0..$7f] of array[0..$0b] of Byte;
                order: array[0..$7f] of Byte;
                patts: tHSC_PATTERNS;
                dummy: Byte;
              end;

var
  buffer2: tMTK_DATA;

procedure mtk_file_loader;

var
  f: File;
  temp,temp2: Longint;
  crc: Word;
  old_c_fix: Boolean;

const
  id = 'mpu401tr’kkîr@data';

var
  header: Record
            id_string: array[1..18] of Char;
            crc_16bit: Word;
            data_size: Word;
          end;
begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.id_string = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer),temp);

  crc := 0;
  crc := Update16(buffer,temp,crc);
  If (crc <> header.crc_16bit) then
    begin
      CloseF(f);
      EXIT;
    end;

  FillChar(buffer2,SizeOf(buffer2),0);
  temp2 := RDC_decompress(buffer,buffer2,temp);
  If NOT (temp2 = header.data_size) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  tempo := 18;
  speed := 2;

  songdata.common_flag := songdata.common_flag OR 2;
  songdata.tempo := tempo;
  songdata.speed := speed;
  import_old_flags;

  For temp2 := 0 to $31 do
    If (buffer2.order[temp2] <> $ff) then songdata.pattern_order[temp2] := buffer2.order[temp2]
    else songdata.pattern_order[temp2] := $080;

  old_c_fix := fix_c_note_bug;
  fix_c_note_bug := FALSE;
  import_hsc_patterns(buffer2.patts,
                     (header.data_size-SizeOf(buffer2.sname)
                                      -SizeOf(buffer2.compo)
                                      -SizeOf(buffer2.instn)
                                      -SizeOf(buffer2.instt)
                                      -SizeOf(buffer2.order)-1) DIV $480);
  fix_c_note_bug := old_c_fix;

// specific corrections for MPU-401 TR’KKîR instrument
  For temp2 := 0 to $7f do
    begin
      import_hsc_instrument(temp2+1,buffer2.instt[temp2]);
      With songdata.instr_data[temp2+1].fm_data do
        begin
          If (KSL_VOLUM_modulator > 128) then
            KSL_VOLUM_modulator := KSL_VOLUM_modulator DIV 3;
          If (KSL_VOLUM_carrier > 128) then
            KSL_VOLUM_carrier := KSL_VOLUM_carrier DIV 3;
        end;

      songdata.instr_names[temp2+1] :=
        Copy(songdata.instr_names[temp2+1],1,9)+
        truncate_string(Copy(buffer2.instn[temp2],10,32));
    end;

  songdata.songname := CutStr(buffer2.sname);
  songdata.composer := CutStr(buffer2.compo);

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 10;
end;

procedure rad_file_loader;

const
  id = 'RAD by REALiTY!!';

var
  header: Record
            ident: array[1..16] of Char; { Use this to recognize a RAD tune }
            rmver: Byte;                 { Version of RAD file (10h) }
            xbyte: Byte;       { bit7      Set if a description follows }
          end;                 { bit6      Set if it's a "slow-timer" tune }
                               { bit[4..0] The initial speed of the tune }
var
  f: File;
  dscbuf: array[0..PRED(80*22)] of Char;
  pattoffs: array[0..$1f] of Word;
  temp,temp2,temp3,temp4,temp5,offs0: Longint;

procedure import_rad_event(pattern,line,channel,byte1,byte2,byte3: Byte);

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  If ((byte2 SHR 4)+(byte1 SHR 7) SHL 4 <> 0) then
    chunk.instr_def := (byte2 SHR 4)+(byte1 SHR 7) SHL 4;

  If (byte1 AND $0f in [1..12]) then chunk.note := 12*((byte1 SHR 4) AND 7)+(byte1 AND $0f)+1
  else If (byte1 AND $0f = $0f) then chunk.note := BYTE_NULL;

  Case byte2 AND $0f of
  { PORTAMENTO (FREQUENCY SLIDE) UP }
    $01: begin
           chunk.effect_def := ef_FSlideUp;
           chunk.effect := byte3;
         end;

  { PORTAMENTO (FREQUENCY SLIDE) DOWN }
    $02: begin
           chunk.effect_def := ef_FSlideDown;
           chunk.effect := byte3;
         end;

  { PORTAMENTO TO NOTE }
    $03: begin
           chunk.effect_def := ef_TonePortamento;
           chunk.effect := byte3;
         end;

  { PORTAMENTO TO NOTE WITH VOLUME SLIDE }
    $05: If (byte3 in [1..49]) then
           begin
             chunk.effect_def := ef_TPortamVolSlide;
             chunk.effect := max(byte3,15);

             If (byte3 > 15) then
               begin
                 chunk.effect_def2 := ef_TPortamVolSlide;
                 chunk.effect2 := max(byte3-15,15);
               end;
           end
         else If (byte3 in [51..99]) then
                begin
                  chunk.effect_def := ef_TPortamVolSlide;
                  chunk.effect := max(byte3-50,15)*16;

                  If (byte3-50 > 15) then
                    begin
                      chunk.effect_def2 := ef_TPortamVolSlide;
                      chunk.effect2 := max(byte3-50-15,15);
                    end;
                end;

  { VOLUME SLIDE }
    $0a: If (byte3 in [1..49]) then
           begin
             chunk.effect_def := ef_VolSlide;
             chunk.effect := max(byte3,15);

             If (byte3 > 15) then
               begin
                 chunk.effect_def2 := ef_VolSlide;
                 chunk.effect2 := max(byte3-15,15);
               end;
           end
         else If (byte3 in [51..99]) then
                begin
                  chunk.effect_def := ef_VolSlide;
                  chunk.effect := max(byte3-50,15)*16;

                  If (byte3-50 > 15) then
                    begin
                      chunk.effect_def2 := ef_VolSlide;
                      chunk.effect2 := max(byte3-50-15,15);
                    end;
                end;

  { SET VOLUME }
    $0c: begin
           chunk.effect_def := ef_SetInsVolume;
           If (byte3 < 64) then chunk.effect := byte3
           else chunk.effect := 63;
         end;

  { JUMP TO NEXT PATTERN IN ORDER LIST }
    $0d: begin
           chunk.effect_def := ef_PatternBreak;
           If (byte3 < 64) then chunk.effect := byte3
           else chunk.effect := 63;
         end;

  { SET SPEED }
    $0f: begin
           chunk.effect_def := ef_SetSpeed;
           chunk.effect := byte3;
         end;
  end;

// specific corrections for RAd-Tracker event
  If (chunk.effect_def in [ef_TonePortamento,
                           ef_TPortamVolSlide]) and
     (chunk.note = BYTE_NULL) then chunk.note := 0;
  If (chunk.effect_def in [ef_TonePortamento,
                           ef_TPortamVolSlide]) then chunk.instr_def := 0;
  If (chunk.note = 0) then chunk.instr_def := 0;
  put_chunk(pattern,line,channel+1,chunk);
end;


begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer),temp);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  temp2 := 0;
  offs0 := SizeOf(header);

  If (header.xbyte OR $80 = header.xbyte) then
    begin
      While (temp2 < temp) and (buffer[temp2] <> 0) do Inc(temp2);
      If (temp2 >= temp) then
        begin
          CloseF(f);
          EXIT;
        end;

      Inc(offs0,temp2+1);
      Dec(temp,temp2+1);
      Move(buffer,dscbuf,temp2+1);
      Move(buffer[temp2+1],buffer,temp);
    end;


  init_songdata;
  load_flag := 0;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  If (header.xbyte OR $40 = header.xbyte) then tempo := 18
  else tempo := 50;

  If (header.xbyte AND $1f in [1..31]) then speed := header.xbyte AND $1f
  else speed := 2;

  songdata.tempo := tempo;
  songdata.speed := speed;

  temp2 := 0;
  Repeat
    temp3 := buffer[temp2];
    Inc(temp2);
    If (temp3 <> 0) and (temp2+11 < temp) then
      begin
        import_hsc_instrument(temp3,buffer[temp2]);
        songdata.instr_data[temp3].fine_tune := 0;
        Inc(temp2,11);
      end;
  until (temp3 = 0) or (temp3 >= temp);

  Inc(offs0,temp2);
  Dec(temp,temp2);
  Move(buffer[temp2],buffer,temp);

  Inc(offs0,buffer[0]+1);
  If (buffer[0] <> 0) then
    Move(buffer[1],songdata.pattern_order,buffer[0]);

  Inc(offs0,32*SizeOf(WORD));
  Dec(temp,buffer[0]+1+32*SizeOf(WORD));

  Move(buffer[buffer[0]+1],pattoffs,32*SizeOf(WORD));
  Move(buffer[buffer[0]+32*SizeOf(WORD)+1],buffer,temp);

  temp5 := temp;
  For temp := 0 to 31 do
    begin
      temp2 := 0;
      temp3 := 0;
      If (pattoffs[temp] <> 0) and
         (pattoffs[temp] <= FileSize(f)) then
        Repeat
          temp2 := buffer[pattoffs[temp]-offs0+temp3];
          Repeat
            Inc(temp3);
            temp4 := buffer[pattoffs[temp]-offs0+temp3];
            If (buffer[pattoffs[temp]-offs0+temp3+2] AND $0f <> 0) then
              begin
                If (temp4 AND $0f in [0..8]) then
                  import_rad_event(temp,temp2 AND $3f,temp4 AND $0f,
                                   buffer[pattoffs[temp]-offs0+temp3+1],
                                   buffer[pattoffs[temp]-offs0+temp3+2],
                                   buffer[pattoffs[temp]-offs0+temp3+3]);
                Inc(temp3,3);
              end
            else begin
                   If (temp4 AND $0f in [0..8]) then
                     import_rad_event(temp,temp2 AND $3f,temp4 AND $0f,
                                      buffer[pattoffs[temp]-offs0+temp3+1],
                                      buffer[pattoffs[temp]-offs0+temp3+2],
                                      0);
                   Inc(temp3,2);
                 end;
          until (temp4 OR $80 = temp4) or (temp3 > temp5);
          Inc(temp3);
        until (temp2 OR $80 = temp2) or (temp3 > temp5);
    end;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 11;
end;

const
  temp_ef_Arpeggio = $0f0;
  temp_ef_rep      = $0f1;
  temp_ef_XFVSlide = $0f2;

var
  ins_c4factor: array[1..99] of Shortint;

procedure fix_s3m_commands(patterns: Byte);

var
  chunk,chunk2: tCHUNK;
  temp,temp4: Byte;
  patt_break: Byte;
  order,patt: Byte;
  patts: String;
  ins_cache,
  misc_cache,
  arpg_cache,
  volsld_cache,
  slide_cache,
  note_cache,
  patloop_cache: array[1..20] of Byte;
  prev_cache: array[1..20] of Record
                                effect_def,
                                effect,
                                effect_def2,
                                effect2: Byte;
                              end;

procedure fix_single_pattern(patt: Byte);

var
  temp2,temp3: Byte;

begin
  FillChar(prev_cache,SizeOf(prev_cache),0);
  FillChar(patloop_cache,SizeOf(patloop_cache),BYTE_NULL);
  patt_break := BYTE_NULL;

  For temp2 := 0 to $3f do
    For temp3 := 1 to 20 do
      begin
        get_chunk(patt,temp2,temp3,chunk);
        If (chunk.effect_def in [ef_PositionJump,ef_PatternBreak]) then
          patt_break := temp2;

        If (chunk.instr_def <> 0) and (temp2 <= patt_break) then
          ins_cache[temp3] := chunk.instr_def;

        If (chunk.note in [1..12*8+1]) and (temp2 <= patt_break) then
          note_cache[temp3] := chunk.note;

        If (chunk.instr_def <> 0) or ((chunk.instr_def = 0) and
                                      (chunk.note in [1..12*8+1]) and
                                      (ins_cache[temp3] <> 0)) then
          begin
            If (chunk.instr_def <> 0) then temp4 := chunk.instr_def
            else temp4 := ins_cache[temp3];
            If (ins_c4factor[temp4] <> 0) and
               NOT (Pos(CHR(songdata.pattern_order[order]),patts) <> 0) then
              begin
                If (ins_c4factor[temp4] <> -127) then
                  chunk.note := min(max(chunk.note+ins_c4factor[temp4],12*8+1),1)
                else chunk.note := 1;
                put_chunk(patt,temp2,temp3,chunk);
              end;
          end;

        If (chunk.effect_def = ef_Extended) and
           (chunk.effect DIV 16 = ef_ex_PatternLoop) and
           (chunk.effect MOD 16 <> 0) then
          If NOT (patloop_cache[temp3] in [0,BYTE_NULL]) and (temp2 <> 0) then
            begin
              If (prev_cache[temp3].effect_def = 0) and
                 (prev_cache[temp3].effect = 0) then
                begin
                  get_chunk(patt,PRED(temp2),temp3,chunk2);
                  chunk2.effect_def := ef_Extended;
                  chunk2.effect := ef_ex_PatternLoop*16;
                  If NOT ((chunk2.effect_def = chunk2.effect_def2) and
                          (chunk2.effect = chunk2.effect2)) then
                    begin
                      put_chunk(patt,PRED(temp2),temp3,chunk2);
                      prev_cache[temp3].effect_def := chunk.effect_def;
                      prev_cache[temp3].effect := chunk.effect;
                    end;
                end
              else If (prev_cache[temp3].effect_def2 = 0) and
                      (prev_cache[temp3].effect2 = 0) then
                     begin
                       get_chunk(patt,PRED(temp2),temp3,chunk2);
                       chunk2.effect_def2 := ef_Extended;
                       chunk2.effect2 := ef_ex_PatternLoop*16;
                       If NOT ((chunk2.effect_def2 = chunk2.effect_def) and
                               (chunk2.effect2 = chunk2.effect)) then
                         begin
                           put_chunk(patt,PRED(temp2),temp3,chunk2);
                           prev_cache[temp3].effect_def2 := chunk.effect_def2;
                           prev_cache[temp3].effect2 := chunk.effect2;
                         end;
                     end;
            end
          else If (patloop_cache[temp3] <> 0) and (temp2 <> 0) then
                 begin
                   get_chunk(patt,0,temp3,chunk2);
                   If (chunk2.effect_def = 0) and
                      (chunk2.effect = 0) then
                     begin
                       chunk2.effect_def := ef_Extended;
                       chunk2.effect := ef_ex_PatternLoop*16;
                       If NOT ((chunk2.effect_def = chunk2.effect_def2) and
                               (chunk2.effect = chunk2.effect2)) then
                         put_chunk(patt,0,temp3,chunk2);
                     end
                   else If (chunk2.effect_def2 = 0) and
                           (chunk2.effect2 = 0) then
                          begin
                            chunk2.effect_def2 := ef_Extended;
                            chunk2.effect2 := ef_ex_PatternLoop*16;
                            If NOT ((chunk2.effect_def2 = chunk2.effect_def) and
                                    (chunk2.effect2 = chunk2.effect)) then
                              put_chunk(patt,0,temp3,chunk2);
                          end;
                 end;

        If (temp2 <= patt_break) then
          begin
            If (chunk.effect DIV 16 <> 0) then
              misc_cache[temp3] := chunk.effect AND $0f0+
                                   misc_cache[temp3] AND $0f
            else If (chunk.effect_def in [ef_Vibrato,
                                          ef_ExtraFineVibrato,
                                          ef_Tremolo,
                                          ef_Tremor,
                                          ef_MultiRetrigNote]) then
                   begin
                     chunk.effect := misc_cache[temp3] AND $0f0+
                                     chunk.effect AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect MOD 16 <> 0) then
              misc_cache[temp3] := misc_cache[temp3] AND $0f0+
                                   chunk.effect AND $0f
            else If (chunk.effect_def in [ef_Vibrato,
                                          ef_ExtraFineVibrato,
                                          ef_Tremolo,
                                          ef_Tremor,
                                          ef_MultiRetrigNote]) then
                   begin
                     chunk.effect := chunk.effect AND $0f0+
                                     misc_cache[temp3] AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def = temp_ef_Arpeggio) then
              If (chunk.effect <> 0) then arpg_cache[temp3] := chunk.effect
              else begin
                     chunk.effect := arpg_cache[temp3];
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def in [ef_FSlideDown,ef_FSlideDownFine,
                                     ef_FSlideUp,ef_FSlideUpFine,
                                     ef_TonePortamento]) then
              If (chunk.effect <> 0) then slide_cache[temp3] := chunk.effect
              else begin
                     chunk.effect := slide_cache[temp3];
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

         // experimental method to fix up frequency slide
            If (chunk.effect_def in [ef_FSlideDown,ef_FSlideDownFine,
                                     ef_FSlideUp,ef_FSlideUpFine,
                                     ef_Vibrato,
                                     ef_ExtraFineVibrato,
                                     ef_TonePortamento]) then
              If (note_cache[temp3] <> 0) then
                begin
                  If (chunk.effect_def in [ef_Vibrato,ef_ExtraFineVibrato]) then
                    begin
                      temp := chunk.effect AND $0f0;
                      chunk.effect := chunk.effect MOD 16;
                    end;

                  Case SUCC(PRED(note_cache[temp3]) DIV 12) of
                    1: chunk.effect := max(Round(chunk.effect*0.55),255);
                    2: chunk.effect := max(Round(chunk.effect*0.75),255);
                    3: chunk.effect := max(Round(chunk.effect*0.95),255);
                    4: chunk.effect := max(Round(chunk.effect*1.15),255);
                    5: chunk.effect := max(Round(chunk.effect*1.35),255);
                    6: chunk.effect := max(Round(chunk.effect*1.55),255);
                    7: chunk.effect := max(Round(chunk.effect*1.75),255);
                    8: chunk.effect := max(Round(chunk.effect*1.95),255);
                  end;

                  If (chunk.effect_def in [ef_Vibrato,ef_ExtraFineVibrato]) then
                    chunk.effect := max(chunk.effect,15)+temp;

                  put_chunk(patt,temp2,temp3,chunk);
                end;

            If (chunk.effect_def = ef_Extended2) and
               (chunk.effect DIV 16 in [ef_ex2_FreqSlideDnXF,ef_ex2_FreqSlideUpXF]) then
              If (chunk.effect MOD 16 <> 0) then slide_cache[temp3] := chunk.effect MOD 16
              else begin
                     chunk.effect := chunk.effect AND $0f0+slide_cache[temp3] AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def in [ef_TPortamVolSlide,ef_VibratoVolSlide,
                                     ef_VolSlide,ef_VolSlideFine]) and
               (temp2 <= patt_break) then
              begin
                If (chunk.effect <> 0) then volsld_cache[temp3] := chunk.effect
                else begin
                       chunk.effect := volsld_cache[temp3];;
                       put_chunk(patt,temp2,temp3,chunk);
                     end;
              end;

            If (chunk.effect_def = ef_Extended2) and
               (chunk.effect DIV 16 in [ef_ex2_VolSlideDnXF,ef_ex2_VolSlideUpXF]) then
              If (chunk.effect MOD 16 <> 0) then
                Case chunk.effect DIV 16 of
                  ef_ex2_VolSlideDnXF:
                    volsld_cache[temp3] := chunk.effect MOD 16;
                  ef_ex2_VolSlideUpXF:
                    volsld_cache[temp3] := chunk.effect MOD 16 SHL 4;
                end
              else begin
                     Case chunk.effect DIV 16 of
                       ef_ex2_VolSlideDnXF:
                         chunk.effect := chunk.effect AND $0f0+volsld_cache[temp3] AND $0f;
                       ef_ex2_VolSlideUpXF:
                         chunk.effect := volsld_cache[temp3] AND $0f0+chunk.effect AND $0f;
                     end;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;
          end;

        If (prev_cache[temp3].effect_def in [ef_Vibrato,ef_ExtraFineVibrato,ef_VibratoVolSlide]) and
           NOT (chunk.effect_def in [ef_Vibrato,ef_ExtraFineVibrato,ef_VibratoVolSlide]) then
          If (chunk.effect_def = 0) and (chunk.effect = 0) then
            begin
              chunk2 := chunk;
              chunk2.effect_def := ef_Extended;
              chunk2.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_VibrOff;
              If NOT ((chunk2.effect_def = chunk2.effect_def2) and
                      (chunk2.effect = chunk2.effect2)) then
                begin
                  put_chunk(patt,temp2,temp3,chunk2);
                  chunk := chunk2;
                end;
            end
          else If (chunk.effect_def2 = 0) and (chunk.effect2 = 0) then
                 begin
                   chunk2 := chunk;
                   chunk2.effect_def2 := ef_Extended;
                   chunk2.effect2 := ef_ex_ExtendedCmd*16+ef_ex_cmd_VibrOff;
                   If NOT ((chunk2.effect_def2 = chunk2.effect_def) and
                           (chunk2.effect2 = chunk2.effect)) then
                     begin
                       put_chunk(patt,temp2,temp3,chunk2);
                       chunk := chunk2;
                     end;
                 end;

        If (chunk.effect_def = ef_Extended) and
           (chunk.effect DIV 16 = ef_ex_PatternLoop) then
          patloop_cache[temp3] := chunk.effect MOD 16;

        prev_cache[temp3].effect_def := chunk.effect_def;
        prev_cache[temp3].effect := chunk.effect;
        prev_cache[temp3].effect_def2 := chunk.effect_def2;
        prev_cache[temp3].effect2 := chunk.effect2;

        If (chunk.effect_def = temp_ef_Arpeggio) then
          begin
            chunk2 := chunk;
            chunk2.effect_def := ef_Arpeggio;
            put_chunk(patt,temp2,temp3,chunk2);
          end;
      end;
end;

begin { fix_s3m_commands }
  FillChar(ins_cache,SizeOf(ins_cache),0);
  FillChar(note_cache,SizeOf(note_cache),0);
  FillChar(volsld_cache,SizeOf(volsld_cache),0);
  FillChar(slide_cache,SizeOf(slide_cache),0);
  FillChar(misc_cache,SizeOf(misc_cache),0);
  FillChar(arpg_cache,SizeOf(arpg_cache),0);

  patts := '';
  order := 0; patt := BYTE_NULL;

  Repeat
    If (songdata.pattern_order[order] >= $80) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        If NOT (Pos(CHR(patt),patts) <> 0) then
          fix_single_pattern(patt);
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);

  For patt := 0 to PRED(patterns) do
    If NOT (Pos(CHR(patt),patts) <> 0) then
      fix_single_pattern(patt);
end;

procedure s3m_file_loader;

type
  tS3M_HEADER = Record
                  songname: array[1..28] of Char; { ASCIIZ }
                  byte1a:   Byte; { 1Ah }
                  ftype:    Byte; { File type: 16=ST3 module }
                  resrvd1:  array[0..1] of Byte;
                  ordnum:   Word; { Number of orders in file (should be even!) }
                  insnum:   Word; { Number of instruments in file }
                  patnum:   Word; { Number of patterns in file }
                  flags:    Word; {  [ These are old flags for Ffv1. Not supported in ST3.01 }
                                  {  |  +1:st2vibrato }
                                  {  |  +2:st2tempo }
                                  {  |  +4:amigaslides }
                                  {  | +32:enable filter/sfx with sb }
                                  {  ] }
                                  {   +8: 0vol optimizations }
                                  {         Automatically turn off looping notes whose volume }
                                  {         is zero for >2 note rows. }
                                  {  +16: amiga limits }
                                  {         Disallow any notes that go beyond the amiga hardware }
                                  {         limits (like amiga does). This means that sliding }
                                  {         up stops at B#5 etc. Also affects some minor amiga }
                                  {         compatibility issues. }
                                  {  +64: st3.00 volumeslides }
                                  {         Normally volumeslide is NOT performed on first }
                                  {         frame of each row (this is according to amiga }
                                  {         playing). If this is set, volumeslide is performed }
                                  {         ALSO on the first row. This is set by default }
                                  {         if the Cwt/v files is 0x1300 }
                                  { +128: special custom data in file (see below) }
                  cwt_v:    Word; { Created with tracker / version: &0xfff=version, >>12=tracker }
                                  {     ST3.00:0x1300 (NOTE: volumeslides on EVERY frame) }
                                  {     ST3.01:0x1301 }
                                  {     ST3.03:0x1303 }
                                  {     ST3.20:0x1320 }
                  ffi:      Word; { File format information }
                                  {   1=[VERY OLD] signed samples }
                                  {   2=unsigned samples }
                  id:       array[1..4] of Char; { "SCRM" }
                  g_v:      Byte; { global volume (see next section) }
                  i_s:      Byte; { initial speed (command A) }

                  i_t:      Byte; { initial tempo (command T) }
                  m_v:      Byte; { master volume (see next section) 7 lower bits }
                                  {   bit 8: stereo(1) / mono(0) }
                  u_c:      Byte; { ultra click removal }
                  d_p:      Byte; { 252 when default channel pan positions are present }
                                  { in the end of the header (xxx3). If !=252 ST3 doesn't }
                                  { try to load channel pan settings. }
                  resrvd2:  array[0..7] of Byte;
                  special:  Word;
                  chan_set: array[1..32] of Byte;
                end;
type
  tS3M_ADLINS = Record
                  itype:   Byte; { 2:amel 3:abd 4:asnare 5:atom 6:acym 7:ahihat }
                  dosname: array[1..12] of Char;
                  id0:     array[0..2]  of Char;
                  fmdata:  array[0..11] of Byte; { D00..D0B contains the adlib instrument specs packed like this: }
                                                 { modulator:                                              carrier: }
                                                 { D00=[freq.muliplier]+[?scale env.]*16+[?sustain]*32+    =D01 }
                                                 {         [?pitch vib]*64+[?vol.vib]*128 }
                                                 { D02=[63-volume]+[levelscale&1]*128+[l.s.&2]*64          =D03 }
                                                 { D04=[attack]*16+[decay]                                 =D05 }
                                                 { D06=[15-sustain]*16+[release]                           =D07 }
                                                 { D08=[wave select]                                       =D09 }
                                                 { D0A=[modulation feedback]*2+[?additive synthesis] }
                                                 { D0B=unused }
                  vol:     Byte; { Default volume 0..64 }
                  dsk:     Byte;
                  resrvd1: array[0..1] of Byte;
                  c2spd:   Word; { 'Herz' for middle C. ST3 only uses lower 16 bits. }
                                 { Actually this is a modifier since there is no }
                                 { clear frequency for adlib instruments. It scales }
                                 { the note freq sent to adlib. }
                  hi_c2sp: Word;
                  resrvd2: array[0..11] of Byte;
                  smpname: array[1..28] of Char; { ASCIIZ }
                  id:      array[1..4]  of Char; { "SCRI" or "SCRS" }
                end;
const
  id_mod = 'SCRM';
  id_ins_adl = 'SCRI';
  id_ins_smp = 'SCRS';

var
  f: File;
  header: tS3M_HEADER;
  order_list: array[0..254] of Byte;
  paraptr_ins: array[1..99] of Word;
  default_vol: array[1..99] of Byte;
  paraptr_pat: array[0..99] of Word;
  temp,temp2: Longint;
  insdata: tS3M_ADLINS;
  pat,row,chan: Byte;
  note,ins,vol,cmd,info: Byte;
  patlen,index: Word;

procedure import_s3m_event(pattern,line,channel,note,ins,vol,cmd,info: Byte);

var
  chunk: tCHUNK;

function scale_slide(slide: Byte): Byte;
begin
  If (slide > 16) then scale_slide := Round(16+slide/8)
  else scale_slide := Round(slide*(2-slide/16));
end;

begin
  FillChar(chunk,SizeOf(chunk),0);
  chunk.instr_def := ins;

  Case note of
    254: chunk.note := BYTE_NULL;
    255: chunk.note := 0;
    else If (note AND $0f in [0..11]) then
           chunk.note := 12*((note SHR 4) AND 7)+(note AND $0f)+1
  end;

  If (vol <> BYTE_NULL) then
    begin
      chunk.effect_def2 := ef_SetInsVolume;
      chunk.effect2 := max(vol,63);
    end
  else
    If NOT (note in [254,255]) and
       (ins <> 0) and
       (max(default_vol[ins],63) <> 63) then
      begin
        chunk.effect_def2 := ef_SetInsVolume;
        chunk.effect2 := max(default_vol[ins],63);
      end;

  Case CHR(cmd+ORD('A')-1) of
  { NONE }
    '@': chunk.effect := info;

  { SET SPEED }
    'A': If (info <> 0) then
           begin
             chunk.effect_def := ef_SetSpeed;
             chunk.effect := info;
           end;

  { JUMP TO ORDER }
    'B': If (info <= 254) then
           begin
             chunk.effect_def := ef_PositionJump;
             chunk.effect := info;
           end;

  { BREAK PATTERN }
    'C': If (info < 64) then
           begin
             chunk.effect_def := ef_PatternBreak;
             chunk.effect := Str2num(Num2str(info,16),10);
           end;

  { VOLUME SLIDE }
    'D': { VOLUME SLIDE DOWN }
         Case info DIV 16 of
         { NORMAL }
           0: begin
                chunk.effect_def := ef_VolSlide;
                chunk.effect := info MOD 16;
              end;

         { FINE }
          15: begin
                chunk.effect_def := ef_VolSlideFine;
                chunk.effect := info MOD 16;
              end;
         else
           { VOLUME SLIDE UP }
           Case info MOD 16 of
           { NORMAL }
             0: begin
                  chunk.effect_def := ef_VolSlide;
                  chunk.effect := info AND $0f0;
                end;

           { FINE }
            15: begin
                  chunk.effect_def := ef_VolSlideFine;
                  chunk.effect := info AND $0f0;
                end;
           end;
         end;

  { SLIDE DOWN }
    'E': Case info DIV 16 of
         { NORMAL }
           0..13: begin
                    chunk.effect_def := ef_FSlideDown;
                    chunk.effect := scale_slide(info);
                  end;

         { EXTRA FINE }
           14: begin
                 chunk.effect_def := ef_Extended2;
                 If (info <> 0) then
                   chunk.effect := ef_ex2_FreqSlideDnXF*16+min((info AND $0f) DIV 4,1)
                 else chunk.effect := ef_ex2_FreqSlideDnXF*16;
               end;

         { FINE }
           15: begin
                 chunk.effect_def := ef_FSlideDownFine;
                 chunk.effect := info AND $0f;
               end;
         end;

  { SLIDE UP }
    'F': Case info DIV 16 of
         { NORMAL }
           0..13: begin
                    chunk.effect_def := ef_FSlideUp;
                    chunk.effect := scale_slide(info);
                  end;

         { EXTRA FINE }
           14: begin
                 chunk.effect_def := ef_Extended2;
                 If (info <> 0) then
                   chunk.effect := ef_ex2_FreqSlideUpXF*16+min((info AND $0f) DIV 4,1)
                 else chunk.effect := ef_ex2_FreqSlideUpXF*16;
               end;

         { FINE }
           15: begin
                 chunk.effect_def := ef_FSlideUpFine;
                 chunk.effect := info AND $0f;
               end;
         end;

  { TONE PORTAMENTO }
    'G': begin
           chunk.effect_def := ef_TonePortamento;
           chunk.effect := scale_slide(info);
         end;

  { VIBRATO }
    'H': begin
           chunk.effect_def := ef_Vibrato;
           chunk.effect := info;
         end;

  { FINE VIBRATO }
    'U': begin
           chunk.effect_def := ef_ExtraFineVibrato;
           chunk.effect := info;
         end;

  { TREMOR }
    'I': begin
           chunk.effect_def := ef_Tremor;
           chunk.effect := info;
         end;

  { ARPEGGIO }
    'J': begin
           chunk.effect_def := temp_ef_Arpeggio;
           chunk.effect := info;
         end;

  { VIBRATO + VOLUME SLIDE }
    'K': begin
           chunk.effect_def := ef_VibratoVolSlide;
           chunk.effect := info;
         end;

  { TONE PORTAMENTO + VOLUME SLIDE }
    'L': begin
           chunk.effect_def := ef_TPortamVolSlide;
           chunk.effect := info;
         end;

  { RETRIG NOTE + VOLUME SLIDE }
    'Q': begin
           chunk.effect_def := ef_MultiRetrigNote;
           chunk.effect := (info MOD 16)*16+info DIV 16;
         end;

  { TREMOLO }
    'R': begin
           chunk.effect_def := ef_Tremolo;
           chunk.effect := info;
         end;

  { SPECIAL COMMAND }
    'S': Case info DIV 16 of
         { PATTERN LOOP }
           $0b: begin
                  chunk.effect_def := ef_Extended;
                  chunk.effect := ef_ex_PatternLoop*16+info MOD 16;
                end;

         { NOTE CUT }
           $0c: begin
                  chunk.effect_def := ef_Extended2;
                  chunk.effect := ef_ex2_NoteCut*16+info MOD 16;
                end;

         { NOTE DELAY }
           $0d: begin
                  chunk.effect_def := ef_Extended2;
                  chunk.effect := ef_ex2_NoteDelay*16+info MOD 16;
                end;

         { PATTERN DELAY }
           $0e: begin
                  chunk.effect_def := ef_Extended2;
                  chunk.effect := ef_ex2_PatDelayRow*16+info MOD 16;
                end;
         end;

  { TEMPO }
    'T': If (info >= 32) then
           begin
             chunk.effect_def := ef_SetTempo;
             chunk.effect := Round(info/2.5);
           end;

  { SET GLOBAL VOLUME }
    'V': begin
           chunk.effect_def := ef_SetGlobalVolume;
           chunk.effect := max(info,63);
         end;
  end;

  If (chunk.effect_def = 0) and (chunk.effect <> 0) then
    chunk.effect := 0;
  put_chunk(pattern,line,channel,chunk);
end;

// experimental method to fix up note fine-tuning
function find_scale_factor(freq: Longint; var fine_tune: Shortint): Shortint;

const
  _factor: array[-3..3+1] of Real = (1/8,1/4,1/2,1,2,4,8,16);

const
  _freq: array[1..12+1] of Word =
    { C-2         C#2         D-2 }
    ( 33453 DIV 4,35441 DIV 4,37679 DIV 4,
    { D#2         E-2         F-2 }
      39772 DIV 4,42441 DIV 4,44744 DIV 4,
    { F#2         G-2         G#2 }
      47727 DIV 4,50416 DIV 4,53426 DIV 4,
    { A-2         A#2         B-2 }
      56370 DIV 4,59658 DIV 4,63354 DIV 4,
    { C-3 }
      33453 DIV 2);

const
  _fm_freq: array[1..12+1] of Word =
    ($156, $16b, $181, $198, $1b0, $1ca,
     $1e5, $202, $220, $241, $263, $287,
     $2ae);

var
  factor: Real;
  temp,scaler: Shortint;

begin
  scaler := -3;
  fine_tune := 0;

  For scaler := -3 to 3+1 do
    For temp := 1 to 12 do
      begin
        factor := _factor[scaler];
        If (freq >= Round(_freq[temp]*factor)) and
           (freq <= Round(_freq[SUCC(temp)]*factor)) then
          If (freq-Round(_freq[temp]*factor) < Round(_freq[SUCC(temp)]*factor)-freq) then
            begin
              fine_tune := Round((_fm_freq[SUCC(temp)]-_fm_freq[temp])/
                                 (_freq[SUCC(temp)]-_freq[temp])*
                                 (freq-Round(_freq[temp]*factor)));
              find_scale_factor := scaler*12+PRED(temp);
              EXIT;
            end
          else
            begin
              fine_tune := Round((_fm_freq[SUCC(temp)]-_fm_freq[temp])/
                                 (_freq[SUCC(temp)]-_freq[temp])*
                                 (freq-Round(_freq[SUCC(temp)]*factor)));
              If (temp <> 12) then find_scale_factor := scaler*12+temp
              else find_scale_factor := SUCC(scaler)*12;
              EXIT;
            end;
      end;

  find_scale_factor := -127;
  fine_tune := 0;
end;

(*  // another method -- it's hard to say whether more or less accurate :)
function find_scale_factor(freq: Longint; var fine_tune: Shortint): Shortint;

const
  _factor: array[-3..3+1] of Real = (1/8,1/4,1/2,1,2,4,8,16);
  _finetune_factor: array[-3..3+1] of Real = (8,4,2,1,1/2,1/4,1/8,1/16);

const
  _freq: array[1..12+1] of Word =
    { C-2         C#2         D-2 }
    ( 33453 DIV 4,35441 DIV 4,37679 DIV 4,
    { D#2         E-2         F-2 }
      39772 DIV 4,42441 DIV 4,44744 DIV 4,
    { F#2         G-2         G#2 }
      47727 DIV 4,50416 DIV 4,53426 DIV 4,
    { A-2         A#2         B-2 }
      56370 DIV 4,59658 DIV 4,63354 DIV 4,
    { C-3 }
      33453 DIV 2);

var
  factor: Real;
  temp,scaler: Shortint;

begin
  scaler := -3;
  fine_tune := 0;

  For scaler := -3 to 3+1 do
    For temp := 1 to 12 do
      begin
        factor := _factor[scaler];
        If (freq >= Round(_freq[temp]*factor)) and
           (freq <= Round(_freq[SUCC(temp)]*factor)) then
          If (freq-Round(_freq[temp]*factor) < Round(_freq[SUCC(temp)]*factor)-freq) then
            begin
              fine_tune := Round((freq-Round(_freq[temp]*factor))/
                                  Round(16/_finetune_factor[scaler]));
              find_scale_factor := scaler*12+PRED(temp);
              EXIT;
            end
          else
            begin
              If (temp = 12) then Inc(scaler);
              fine_tune := Round((freq-Round(_freq[SUCC(temp)]*factor))/
                                  Round(16/_finetune_factor[scaler]));
              If (temp = 12) then temp := 0;
              find_scale_factor := scaler*12+temp;
              EXIT;
            end;
      end;

  find_scale_factor := -127;
  fine_tune := 0;
end;
*)

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.id = id_mod)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If (header.byte1a <> $1a) or (header.ftype <> $10) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,order_list,header.ordnum,temp);
  If (IOresult <> 0) or (temp <> header.ordnum) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,paraptr_ins,header.insnum*2,temp);
  If (IOresult <> 0) or (temp <> header.insnum*2) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,paraptr_pat,header.patnum*2,temp);
  If (IOresult <> 0) or (temp <> header.patnum*2) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_songdata;
  load_flag := 0;

  If (header.i_s <> 0) then speed := header.i_s
  else speed := 1;

  If (Round(header.i_t/2.5) < 255) then tempo := Round(header.i_t/2.5)
  else tempo := 255;

  songdata.tempo := tempo;
  songdata.speed := speed;
  songdata.songname := truncate_string(asciiz_string(header.songname));
  songdata.common_flag := songdata.common_flag OR $80;
  import_old_flags;

  For temp := 32 downto 1 do
    If (header.chan_set[temp] <> 255) then BREAK;


  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := max(temp,18)
  else If (songdata.nm_tracks < 18) then songdata.nm_tracks := 18;

  For temp := 1 to max(header.ordnum,128) do
    Case order_list[temp-1] of
      254: songdata.pattern_order[temp-1] := $80+temp;
      255: songdata.pattern_order[temp-1] := $80;
      else songdata.pattern_order[temp-1] := order_list[temp-1];
    end;

  FillChar(ins_c4factor,SizeOf(ins_c4factor),0);
  For temp := 1 to header.insnum do
    begin
      SeekF(f,paraptr_ins[temp]*16);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,insdata,SizeOf(insdata),temp2);
      If (IOresult <> 0) or (temp2 <> SizeOf(insdata)) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (truncate_string(insdata.smpname) <> '') then
        songdata.instr_names[temp] :=
          Copy(songdata.instr_names[temp],1,9)+
          Copy(truncate_string(asciiz_string(insdata.smpname)),1,32)
      else
        songdata.instr_names[temp] :=
          Copy(songdata.instr_names[temp],1,9)+
          truncate_string(insdata.dosname);

      If (insdata.itype in [2..7]) then
        begin
          If (insdata.id <> id_ins_adl) and (insdata.id <> id_ins_smp) then
            begin
              CloseF(f);
              EXIT;
            end;

          import_standard_instrument(temp,insdata.fmdata);
        end;

      default_vol[temp] := insdata.vol;
      If (insdata.c2spd <> 0) and
         (insdata.c2spd <> 8363) then
        ins_c4factor[temp] := find_scale_factor(insdata.c2spd,songdata.instr_data[temp].fine_tune);
    end;

  For pat := 0 to PRED(header.patnum) do
    begin
      SeekF(f,paraptr_pat[pat]*16);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,patlen,SizeOf(patlen),temp2);
      If (temp2 <> SizeOf(patlen)) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (patlen = 0) then CONTINUE;
      FillChar(buffer,SizeOf(buffer),0);
      BlockReadF(f,buffer,patlen-2,temp2);

      index := 0;
      row := 0;

      Repeat
        If (buffer[index] <> 0) then
          begin
            note := BYTE_NULL;
            ins  := 0;
            vol  := BYTE_NULL;
            cmd  := 0;
            info := 0;
            temp := buffer[index];
            Inc(index);

            chan := SUCC(temp AND 31);
            If (temp OR $20 = temp) then
              begin
                note := buffer[index];
                Inc(index);
                ins := buffer[index];
                Inc(index);
              end;

            If (temp OR $40 = temp) then
              begin
                vol := buffer[index];
                Inc(index);
              end;

            If (temp OR $80 = temp) then
              begin
                cmd := buffer[index];
                Inc(index);
                info := buffer[index];
                Inc(index);
              end;

            If (chan > songdata.nm_tracks) then songdata.nm_tracks := max(chan,18);
            If (chan in [1..songdata.nm_tracks]) then
              import_s3m_event(pat,row,chan,note,ins,vol,cmd,info);
          end
        else
          begin
            Inc(row);
            Inc(index);
          end;
      until (row = 64);
    end;

  fix_s3m_commands(header.patnum);
  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 12;
end;

procedure fix_fmk_commands(patterns: Byte);

var
  chunk,chunk2,
  chunk3: tCHUNK;
  patt_break: Byte;
  order,patt: Byte;
  patts: String;
  ins_cache,
  misc_cache,
  arpg_cache,
  forcevol_cache,
  volsld_cache,
  xfvolsld_cache,
  slide_cache: array[1..20] of Byte;
  _1st_ins_load: array[1..20] of Boolean;
  _speed_table_fixed: array[0..$7f] of Boolean;
  prev_cache: array[1..20] of Record
                                effect_def,
                                effect,
                                effect_def2,
                                effect2: Byte;
                              end;

procedure fix_single_pattern(patt: Byte);

var
  temp2,temp3: Byte;

begin
  FillChar(prev_cache,SizeOf(prev_cache),0);
  patt_break := BYTE_NULL;

  If NOT _speed_table_fixed[patt] then
    For temp2 := 0 to $3f do
      begin
        For temp3 := 1 to 20 do
          begin
            get_chunk(patt,temp2,temp3,chunk);
            If (chunk.effect_def = 0) then
              begin
                chunk.effect_def := ef_SetCustomSpeedTab;
                chunk.effect := $0fa;
                put_chunk(patt,temp2,temp3,chunk);
                _speed_table_fixed[patt] := TRUE;
              end
            else If (chunk.effect_def2 = 0) then
                   begin
                     chunk.effect_def2 := ef_SetCustomSpeedTab;
                     chunk.effect2 := $0fa;
                     put_chunk(patt,temp2,temp3,chunk);
                     _speed_table_fixed[patt] := TRUE;
                   end;
            If _speed_table_fixed[patt] then BREAK;
          end;
        If _speed_table_fixed[patt] then BREAK;
      end;

  For temp2 := 0 to $3f do
    For temp3 := 1 to 20 do
      begin
        get_chunk(patt,temp2,temp3,chunk);
        If (chunk.effect_def = temp_ef_rep) then
          begin
            chunk.effect_def := prev_cache[temp3].effect_def;
            put_chunk(patt,temp2,temp3,chunk);
          end;

        If (chunk.effect_def = temp_ef_XFVSlide) then
          begin
            chunk.effect_def := ef_Extended2;
            If (xfvolsld_cache[temp3] <> 0) then
              chunk.effect := ef_ex2_VolSlideUpXF*16+volsld_cache[temp3] DIV 16
            else chunk.effect := ef_ex2_VolSlideDnXF*16+volsld_cache[temp3] MOD 16;
            put_chunk(patt,temp2,temp3,chunk);
          end;

        If (chunk.effect_def in [ef_PositionJump,ef_PatternBreak]) then
          patt_break := temp2;

        If (temp2 <= patt_break) and
           (chunk.instr_def <> ins_cache[temp3]) and
           (chunk.effect_def2 <> ef_ForceInsVolume) then
          If (chunk.instr_def <> 0) then
            forcevol_cache[temp3] := 0;

        If ((chunk.effect_def = ef_Extended) and
            (chunk.effect = ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol)) or
           ((chunk.effect_def2 = ef_Extended) and
            (chunk.effect2 = ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol)) then
          forcevol_cache[temp3] := 0;

        If (chunk.effect_def2 = ef_ForceInsVolume) and
           (temp2 <= patt_break) then
          forcevol_cache[temp3] := 1;

        If (chunk.instr_def <> 0) and (temp2 <= patt_break) then
          ins_cache[temp3] := chunk.instr_def;

        If (chunk.instr_def <> 0) or ((chunk.instr_def = 0) and
                                      (chunk.note in [1..12*8+1]) and
                                      (ins_cache[temp3] <> 0)) then
          put_chunk(patt,temp2,temp3,chunk);

        If (temp2 <= patt_break) then
          begin
            If (chunk.effect DIV 16 <> 0) then
              misc_cache[temp3] := chunk.effect AND $0f0+
                                   misc_cache[temp3] AND $0f
            else If (chunk.effect_def in [ef_Vibrato,
                                          ef_Tremolo]) then
                   begin
                     chunk.effect := misc_cache[temp3] AND $0f0+
                                     chunk.effect AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect MOD 16 <> 0) then
              misc_cache[temp3] := misc_cache[temp3] AND $0f0+
                                   chunk.effect AND $0f
            else If (chunk.effect_def in [ef_Vibrato,
                                          ef_Tremolo]) then
                   begin
                     chunk.effect := chunk.effect AND $0f0+
                                     misc_cache[temp3] AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def = ef_RetrigNote) then
              If (chunk.effect <> 0) then misc_cache[temp3] := chunk.effect
              else begin
                     chunk.effect := misc_cache[temp3];
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def = temp_ef_Arpeggio) then
              If (chunk.effect <> 0) then arpg_cache[temp3] := chunk.effect
              else begin
                     chunk.effect := arpg_cache[temp3];
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def in [ef_FSlideDown,ef_FSlideDownFine,
                                     ef_FSlideUp,ef_FSlideUpFine,
                                     ef_TonePortamento]) then
              If (chunk.effect <> 0) then slide_cache[temp3] := chunk.effect
              else begin
                     chunk.effect := slide_cache[temp3];
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def = ef_Extended2) and
               (chunk.effect DIV 16 in [ef_ex2_FreqSlideDnXF,ef_ex2_FreqSlideUpXF]) then
              If (chunk.effect MOD 16 <> 0) then slide_cache[temp3] := chunk.effect MOD 16
              else begin
                     chunk.effect := chunk.effect AND $0f0+slide_cache[temp3] AND $0f;
                     put_chunk(patt,temp2,temp3,chunk);
                   end;

            If (chunk.effect_def in [ef_TPortamVolSlide,ef_VibratoVolSlide,
                                     ef_VolSlide,ef_VolSlideFine]) and
               (temp2 <= patt_break) then
              begin
                If (chunk.effect <> 0) then volsld_cache[temp3] := chunk.effect
                else begin
                       chunk.effect := volsld_cache[temp3];;
                       put_chunk(patt,temp2,temp3,chunk);
                     end;
              end;

            If (chunk.effect_def = ef_Extended2) and
               (chunk.effect DIV 16 in [ef_ex2_VolSlideDnXF,ef_ex2_VolSlideUpXF]) then
              If (chunk.effect MOD 16 <> 0) then
                Case chunk.effect DIV 16 of
                  ef_ex2_VolSlideDnXF:
                    begin
                      volsld_cache[temp3] := chunk.effect MOD 16;
                      xfvolsld_cache[temp3] := 0;
                    end;

                  ef_ex2_VolSlideUpXF:
                    begin
                      volsld_cache[temp3] := chunk.effect MOD 16*16;
                      xfvolsld_cache[temp3] := 1;
                    end;
                end;
          end;

        If (prev_cache[temp3].effect_def in [ef_Vibrato,ef_VibratoVolSlide]) and
           NOT (chunk.effect_def in [ef_Vibrato,ef_VibratoVolSlide]) then
          If (chunk.effect_def = 0) and (chunk.effect = 0) then
            begin
              chunk2 := chunk;
              chunk2.effect_def := ef_Extended;
              chunk2.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_VibrOff;
              If NOT ((chunk2.effect_def = chunk2.effect_def2) and
                      (chunk2.effect = chunk2.effect2)) then
                begin
                  put_chunk(patt,temp2,temp3,chunk2);
                  chunk := chunk2;
                end;
            end
          else If (chunk.effect_def2 = 0) and (chunk.effect2 = 0) then
                 begin
                   chunk2 := chunk;
                   chunk2.effect_def2 := ef_Extended;
                   chunk2.effect2 := ef_ex_ExtendedCmd*16+ef_ex_cmd_VibrOff;
                   If NOT ((chunk2.effect_def2 = chunk2.effect_def) and
                           (chunk2.effect2 = chunk2.effect)) then
                     begin
                       put_chunk(patt,temp2,temp3,chunk2);
                       chunk := chunk2;
                     end;
                 end;

        If (_1st_ins_load[temp3] and (chunk.instr_def <> 0)) or
           (forcevol_cache[temp3] <> 0) and
           (temp2 <= patt_break) and
           (chunk.instr_def <> 0) then
          If (chunk.effect_def2+chunk.effect2 = 0) then
            If NOT (chunk.effect_def in [ef_SetModulatorVol,ef_SetCarrierVol]) then
              begin
                chunk.effect_def2 := ef_Extended;
                chunk.effect2 := ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol;
                put_chunk(patt,temp2,temp3,chunk);
                forcevol_cache[temp3] := 0;
                _1st_ins_load[temp3] := FALSE;
              end
            else begin
                  chunk.effect_def2 := chunk.effect_def;
                  chunk.effect2 := chunk.effect;
                  chunk.effect_def := ef_Extended;
                  chunk.effect := ef_ex_ExtendedCmd*16+ef_ex_cmd_ResetVol;
                  put_chunk(patt,temp2,temp3,chunk);
                  forcevol_cache[temp3] := 0;
                  _1st_ins_load[temp3] := FALSE;
                end;

        prev_cache[temp3].effect_def := chunk.effect_def;
        prev_cache[temp3].effect := chunk.effect;
        prev_cache[temp3].effect_def2 := chunk.effect_def2;
        prev_cache[temp3].effect2 := chunk.effect2;

        If is_4op_chan(temp3) and
           (temp3 in [1,3,5,10,12,14]) then
          begin
            get_chunk(patt,temp2,SUCC(temp3),chunk3);
            If (chunk.instr_def = 0) and (chunk3.instr_def <> 0) then
              begin
                If (ins_cache[temp3] <> 0) then
                  chunk.instr_def := ins_cache[temp3]
                else chunk.instr_def := chunk3.instr_def;
                put_chunk(patt,temp2,temp3,chunk);
              end;
          end;

        If (chunk.effect_def = temp_ef_Arpeggio) then
          begin
            chunk2 := chunk;
            chunk2.effect_def := ef_Arpeggio;
            put_chunk(patt,temp2,temp3,chunk2);
          end;

        If (chunk.effect_def in [ef_SetModulatorVol,ef_SetCarrierVol]) and
           (chunk.effect_def2 = ef_ForceInsVolume) then
          begin
            chunk2 := chunk;
            chunk2.effect_def := chunk.effect_def2;
            chunk2.effect := chunk.effect2;
            chunk2.effect_def2 := chunk.effect_def;
            chunk2.effect2 := chunk.effect;
            put_chunk(patt,temp2,temp3,chunk2);
          end;
      end;
end;

begin { fix_fmk_commands }
  FillChar(ins_cache,SizeOf(ins_cache),0);
  FillChar(_1st_ins_load,SizeOf(_1st_ins_load),TRUE);
  FillChar(_speed_table_fixed,SizeOf(_speed_table_fixed),FALSE);
  FillChar(xfvolsld_cache,SizeOf(volsld_cache),0);
  FillChar(volsld_cache,SizeOf(volsld_cache),0);
  FillChar(slide_cache,SizeOf(slide_cache),0);
  FillChar(misc_cache,SizeOf(misc_cache),0);
  FillChar(arpg_cache,SizeOf(arpg_cache),0);
  FillChar(forcevol_cache,SizeOf(forcevol_cache),0);

  patts := '';
  order := 0; patt := BYTE_NULL;

  Repeat
    If (songdata.pattern_order[order] >= $80) then Inc(order)
    else
      begin
        patt := songdata.pattern_order[order];
        fix_single_pattern(patt);
        Inc(order);
        patts := patts+CHR(patt);
      end;
  until (patt >= patterns) or (order > $7f);

  For patt := 0 to PRED(patterns) do
    If NOT (Pos(CHR(patt),patts) <> 0) then
      fix_single_pattern(patt);
end;

procedure import_fin_instrument(inst: Byte; var data);
begin
  With songdata.instr_data[inst] do
    begin
      fm_data.AM_VIB_EG_modulator := tDUMMY_BUFF(data)[0];
      fm_data.AM_VIB_EG_carrier   := tDUMMY_BUFF(data)[1];
      fm_data.KSL_VOLUM_modulator := tDUMMY_BUFF(data)[2];
      fm_data.KSL_VOLUM_carrier   := tDUMMY_BUFF(data)[3];
      fm_data.ATTCK_DEC_modulator := tDUMMY_BUFF(data)[4];
      fm_data.ATTCK_DEC_carrier   := tDUMMY_BUFF(data)[5];
      fm_data.SUSTN_REL_modulator := tDUMMY_BUFF(data)[6];
      fm_data.SUSTN_REL_carrier   := tDUMMY_BUFF(data)[7];
      fm_data.WAVEFORM_modulator  := tDUMMY_BUFF(data)[8]  AND 7;
      fm_data.WAVEFORM_carrier    := tDUMMY_BUFF(data)[9]  AND 7;
      fm_data.FEEDBACK_FM         := tDUMMY_BUFF(data)[10] AND $0f;
    end;

  songdata.instr_data[inst].panning := 0;
  songdata.instr_data[inst].fine_tune := 0;
end;

procedure fmk_file_loader;

type
  tFMK_HEADER = Record
                  id:       array[1..4] of Char; { FMK! }
                  songname: array[1..28] of Char; { Song name (28) }
                  composer: array[1..28] of Char; { Composer name (28) }
                  bytef4:   Byte; { Value 244 (f4h), just for check. }
                  ftype:    Byte; { File type {1=evolution 1, 2=evolution 2 }
                  glob_var: Byte; { Global variables, bits : 0 = stereo, 1 = opl3, 2 = rhythm }
                                  { 3 = 4.8 db tremolo  4 = 14 cent vibrato. }
                  base_spd: Byte; { Song basespeed, ticks / second. this version : fixed 50. }
                  init_spd: Byte; { Song initial speed. }
                  reserved: array[0..8] of Byte; { Reserved }
                  ordnum:   Byte; { Length of song (order). }
                  insnum:   Byte; { Number of instruments. }
                  patnum:   Byte; { Number of patterns. }
                  trk_pan:  array[1..5] of Byte; { Track stereo pan positions, bits 0-1, 2-3, 4-5, 6-7. }
                                                 { value 0 = left 1 = both 2 = right, from track 1 to 18. }
                  trk_set:  array[1..20] of Byte; { Track initial settings, 255=unused, bits : }
                                                  { 0-2, type value: 0 = normal 1=hihat 2=cymbal 3=tom tom 4=snare 5=bass }
                                                  {                  6 = 4op    7=unused }
                                                  { 3-7, OPL-channel number (1-18), 21 = none. }
{ ### if ftype=2 --> trk_set: 1..18; type_value: 0 = normal  6 = 4op  7=unused }
                end;
const
  id = 'FMK!';

const
  _conv_fmk_pan: array[0..2] of Byte = (1,0,2);

type
  tFIN_DATA = Record
                dname: array[1..12] of Char;
                iname: array[1..27] of Char;
                idata: tFM_INST_DATA;
              end;
var
  f: File;
  header: tFMK_HEADER;
  order_list: array[0..254] of Byte;
  paraptr_ins: array[1..99] of Word;
  paraptr_pat: array[0..63] of Longint;
  paraptr_msg: Word;
  insdata: tFIN_DATA;
  temp,temp2,fpos_bak: Longint;
  pat,row,chan,
  desc_rows: Byte;
  note,ins,vol,cmd,info: Byte;
  patlen,index: Word;
  dscbuf: array[0..PRED(20*24)] of Char;


procedure import_fmk_event(pattern,line,channel,note,ins,vol,cmd,info: Byte);

var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  If (ins in [1..99]) then chunk.instr_def := ins;

  Case note of
    254: chunk.note := BYTE_NULL;
    255: chunk.note := 0;
    else If (note AND $0f in [1..12]) then
           chunk.note := 12*(note SHR 4)+(note AND $0f)
  end;

  If (vol <> BYTE_NULL) then
    begin
      chunk.effect_def2 := ef_ForceInsVolume;
      chunk.effect2 := 63-max(vol,63)
    end;

  Case CHR(cmd+ORD('A')-1) of
  { SET SPEED }
    'A': If (info <> 0) then
           begin
             chunk.effect_def := ef_SetSpeed;
             chunk.effect := info;
           end;

  { JUMP TO ORDER }
    'B': If (info <= 254) then
           begin
             chunk.effect_def := ef_PositionJump;
             chunk.effect := info;
           end;

  { CARRIER PARAM }
    'C': Case info DIV 16 of
           1: begin
                chunk.effect_def := ef_Extended3;
                chunk.effect := ef_ex3_SetMultipC*16+info MOD 16;
              end;

           2: begin
                chunk.effect_def := ef_Extended3;
                chunk.effect := ef_ex3_SetKslC*16+(info MOD 16) AND 3;
              end;

           3: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetAttckRateC*16+info MOD 16;
              end;

           4: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetDecayRateC*16+info MOD 16;
              end;

           5: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetSustnLevelC*16+info MOD 16;
              end;

           6: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetRelRateC*16+info MOD 16;
              end;

           7: begin
                chunk.effect_def := ef_SetWaveform;
                chunk.effect := info AND 7 SHL 4+$0f;
              end;

           8: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetFeedback*16+info AND 7;
              end;
         end;

  { VOLUME SLIDE }
    'D': { VOLUME SLIDE DOWN }
         Case info DIV 16 of
         { NORMAL }
           0: If (info MOD 16 = 0) then chunk.effect_def := temp_ef_XFVSlide
              else begin
                     chunk.effect_def := ef_Extended2;
                     chunk.effect := ef_ex2_VolSlideDnXF*16+info MOD 16
                   end;
         { FINE }
          15: begin
                chunk.effect_def := ef_VolSlideFine;
                chunk.effect := info MOD 16;
              end;
         else
           { VOLUME SLIDE UP }
           Case info MOD 16 of
           { NORMAL }
             0: If (info DIV 16 = 0) then chunk.effect_def := temp_ef_XFVSlide
                else begin
                       chunk.effect_def := ef_Extended2;
                       chunk.effect := ef_ex2_VolSlideUpXF*16+info DIV 16;
                     end;
           { FINE }
            15: begin
                  chunk.effect_def := ef_VolSlideFine;
                  chunk.effect := info AND $0f0;
                end;
           end;
         end;

  { SLIDE DOWN }
    'E': Case info DIV 16 of
         { NORMAL }
           0..14: begin
                    chunk.effect_def := ef_FSlideDown;
                    chunk.effect := info;
               end;

         { FINE }
           15: begin
                 chunk.effect_def := ef_FSlideDownFine;
                 chunk.effect := info AND $0f;
               end;
         end;

  { SLIDE UP }
    'F': Case info DIV 16 of
         { NORMAL }
           0..14: begin
                    chunk.effect_def := ef_FSlideUp;
                    chunk.effect := info;
                  end;

         { FINE }
           15: begin
                 chunk.effect_def := ef_FSlideUpFine;
                 chunk.effect := info AND $0f;
               end;
         end;

  { TONE PORTAMENTO }
    'G': begin
           chunk.effect_def := ef_TonePortamento;
           chunk.effect := info;
         end;

  { VIBRATO }
    'H': begin
           chunk.effect_def := ef_Vibrato;
           If (info <> 0) and (info DIV 16 = 0) then
             chunk.effect := $10+info AND $0f
           else If (info <> 0) and (info MOD 16 = 0) then
                  chunk.effect := info AND $0f0+1
                else chunk.effect := info;
         end;

  { RETRIG NOTE }
    'I': begin
           chunk.effect_def := ef_RetrigNote;
           If (info <> 0) then chunk.effect := max(info*2,255);
         end;

  { ARPEGGIO }
    'J': begin
           chunk.effect_def := temp_ef_Arpeggio;
           chunk.effect := info;
         end;

  { MODLATOR PARAM }
    'M': Case info DIV 16 of
           1: begin
                chunk.effect_def := ef_Extended3;
                chunk.effect := ef_ex3_SetMultipM*16+info MOD 16;
              end;

           2: begin
                chunk.effect_def := ef_Extended3;
                chunk.effect := ef_ex3_SetKslM*16+(info MOD 16) AND 3;
              end;

           3: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetAttckRateM*16+info MOD 16;
              end;

           4: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetDecayRateM*16+info MOD 16;
              end;

           5: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetSustnLevelM*16+info MOD 16;
              end;

           6: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetRelRateM*16+info MOD 16;
              end;

           7: begin
                chunk.effect_def := ef_SetWaveform;
                chunk.effect := $0f0+info AND 7;
              end;

           8: begin
                chunk.effect_def := ef_Extended;
                chunk.effect := ef_ex_SetFeedback*16+info AND 7;
              end;
         end;

  { SET VIBRATO/TREMOLO WAVEFORM }
    'N': ;

  { BREAK PATTERN }
    'P': If (info < 64) then
           begin
             chunk.effect_def := ef_PatternBreak;
             chunk.effect := Str2num(Num2str(info,16),10);
           end;

  { TREMOLO }
    'R': begin
           chunk.effect_def := ef_Tremolo;
           If (info <> 0) and (info DIV 16 = 0) then
             chunk.effect := $10+info AND $0f
           else If (info <> 0) and (info MOD 16 = 0) then
                  chunk.effect := info AND $0f0+1
                else chunk.effect := info;
         end;

  { STEREO CONTROL }
    'S': If (header.glob_var AND 1 = 1) then
           begin
             chunk.effect_def := ef_Extended;
             Case info of
               1: chunk.effect := ef_ex_SetPanningPos*16+1;
               2: chunk.effect := ef_ex_SetPanningPos*16+0;
               3: chunk.effect := ef_ex_SetPanningPos*16+2;
             end;
           end;

  { MODULATOR VOLUME }
    'T': begin
           chunk.effect_def := ef_SetModulatorVol;
           chunk.effect := info AND $3f;
         end;

  { CARRIER VOLUME }
    'U': begin
           chunk.effect_def := ef_SetCarrierVol;
           chunk.effect := info AND $3f;
         end;
  end;

  If (chunk.effect_def = 0) and (chunk.effect <> 0) then
    chunk.effect := 0;
  put_chunk(pattern,line,channel,chunk);
end;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.id = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If (header.bytef4 <> $f4) or NOT (header.ftype in [1,2]) then
    begin
      CloseF(f);
      EXIT;
    end;

  If (header.ftype = 2) then
    begin
      SeekF(f,SizeOf(header)-2);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  If (header.ordnum <> 0) then
    begin
      BlockReadF(f,order_list,header.ordnum,temp);
      If (IOresult <> 0) or (temp <> header.ordnum) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  BlockReadF(f,paraptr_msg,SizeOf(paraptr_msg),temp);
  If (IOresult <> 0) or (temp <> SizeOf(paraptr_msg)) then
    begin
      CloseF(f);
      EXIT;
    end;

  fpos_bak := FilePos(f);
  If (paraptr_msg <> 0) then
    begin
      SeekF(f,paraptr_msg);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,desc_rows,SizeOf(desc_rows),temp);
      If (IOresult <> 0) or (temp <> SizeOf(desc_rows)) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (desc_rows <> 0) then
        begin
          BlockReadF(f,dscbuf,desc_rows*20,temp);
          If (IOresult <> 0) or (temp <> desc_rows*20) then
            begin
              CloseF(f);
              EXIT;
            end;
        end;

    end;

  SeekF(f,fpos_bak);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  If (header.insnum <> 0) then
    begin
      BlockReadF(f,paraptr_ins,header.insnum*2,temp);
      If (IOresult <> 0) or (temp <> header.insnum*2) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  If (header.patnum <> 0) then
    begin
      BlockReadF(f,paraptr_pat,header.patnum*4,temp);
      If (IOresult <> 0) or (temp <> header.patnum*4) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  init_songdata;
  load_flag := 0;

  If (header.init_spd <> 0) then speed := header.init_spd
  else speed := 1;

  If (header.base_spd <> 0) then tempo := header.base_spd
  else tempo := 50;

  songdata.tempo := tempo;
  songdata.speed := speed;
  songdata.songname := truncate_string(header.songname);
  songdata.composer := truncate_string(header.composer);
  songdata.common_flag := songdata.common_flag OR 1;
  songdata.common_flag := songdata.common_flag OR 2;
  songdata.common_flag := songdata.common_flag OR $80;

  For temp := 18 downto 1 do
    If NOT (header.trk_set[temp] AND 7 = 7) then BREAK;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := temp
  else If (songdata.nm_tracks < 18) then songdata.nm_tracks := 18;

  For temp2 := 1 to temp do
    If (header.trk_set[temp2] AND 7 = 6) then
      Case temp2 of
        1,2:   songdata.flag_4op := songdata.flag_4op OR 1;
        3,4:   songdata.flag_4op := songdata.flag_4op OR 2;
        5,6:   songdata.flag_4op := songdata.flag_4op OR 4;
        10,11: songdata.flag_4op := songdata.flag_4op OR 8;
        12,13: songdata.flag_4op := songdata.flag_4op OR $10;
        14,15: songdata.flag_4op := songdata.flag_4op OR $20;
      end;

  If (header.glob_var AND 1 = 1) then
    songdata.common_flag := songdata.common_flag OR $20;

  If (header.glob_var SHR 3 AND 1 = 1) then
    songdata.common_flag := songdata.common_flag OR 8;

  If (header.glob_var SHR 4 AND 1 = 1) then
    songdata.common_flag := songdata.common_flag OR $10;

  import_old_flags;
  If (header.glob_var AND 1 = 1) then
    begin
      Inc(songdata.lock_flags[1], _conv_fmk_pan[header.trk_pan[1] AND 3]);
      Inc(songdata.lock_flags[2], _conv_fmk_pan[header.trk_pan[1] SHR 2 AND 3]);
      Inc(songdata.lock_flags[3], _conv_fmk_pan[header.trk_pan[1] SHR 4 AND 3]);
      Inc(songdata.lock_flags[4], _conv_fmk_pan[header.trk_pan[1] SHR 6 AND 3]);
      Inc(songdata.lock_flags[5], _conv_fmk_pan[header.trk_pan[2] AND 3]);
      Inc(songdata.lock_flags[6], _conv_fmk_pan[header.trk_pan[2] SHR 2 AND 3]);
      Inc(songdata.lock_flags[7], _conv_fmk_pan[header.trk_pan[2] SHR 4 AND 3]);
      Inc(songdata.lock_flags[8], _conv_fmk_pan[header.trk_pan[2] SHR 6 AND 3]);
      Inc(songdata.lock_flags[9], _conv_fmk_pan[header.trk_pan[3] AND 3]);
      Inc(songdata.lock_flags[10],_conv_fmk_pan[header.trk_pan[3] SHR 2 AND 3]);
      Inc(songdata.lock_flags[11],_conv_fmk_pan[header.trk_pan[3] SHR 4 AND 3]);
      Inc(songdata.lock_flags[12],_conv_fmk_pan[header.trk_pan[3] SHR 6 AND 3]);
      Inc(songdata.lock_flags[13],_conv_fmk_pan[header.trk_pan[4] AND 3]);
      Inc(songdata.lock_flags[14],_conv_fmk_pan[header.trk_pan[4] SHR 2 AND 3]);
      Inc(songdata.lock_flags[15],_conv_fmk_pan[header.trk_pan[4] SHR 4 AND 3]);
      Inc(songdata.lock_flags[16],_conv_fmk_pan[header.trk_pan[4] SHR 6 AND 3]);
      Inc(songdata.lock_flags[17],_conv_fmk_pan[header.trk_pan[5] AND 3]);
      Inc(songdata.lock_flags[18],_conv_fmk_pan[header.trk_pan[5] SHR 2 AND 3]);
    end;

  For temp := 1 to max(header.ordnum,128) do
    Case order_list[temp-1] of
      255: songdata.pattern_order[temp-1] := $80;
      else songdata.pattern_order[temp-1] := order_list[temp-1];
    end;

  For temp := 1 to header.insnum do
    begin
      SeekF(f,paraptr_ins[temp]);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,insdata,SizeOf(insdata),temp2);
      If (IOresult <> 0) or (temp2 <> SizeOf(insdata)) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (truncate_string(insdata.iname) <> '') then
        songdata.instr_names[temp] :=
          Copy(songdata.instr_names[temp],1,9)+
          Copy(truncate_string(insdata.iname),1,32)
      else
        songdata.instr_names[temp] :=
          Copy(songdata.instr_names[temp],1,9)+
          truncate_string(insdata.dname);

      import_fin_instrument(temp,insdata.idata);
    end;

  For pat := 0 to PRED(header.patnum) do
    begin
      SeekF(f,paraptr_pat[pat]);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (paraptr_pat[pat] = 0) then CONTINUE;
      BlockReadF(f,patlen,SizeOf(patlen),temp2);
      If (temp2 <> SizeOf(patlen)) then
        begin
          CloseF(f);
          EXIT;
        end;

      If (patlen = 0) then CONTINUE;
      FillChar(buffer,SizeOf(buffer),0);
      BlockReadF(f,buffer,patlen,temp2);

      index := 0;
      row := 0;

      Repeat
        If (buffer[index] <> 0) then
          begin
            note := BYTE_NULL;
            ins  := 0;
            vol  := BYTE_NULL;
            cmd  := 0;
            info := 0;
            temp := buffer[index];
            Inc(index);

            chan := SUCC(temp AND 31);
            If (temp OR $20 = temp) then
              begin
                note := buffer[index];
                Inc(index);
                ins := buffer[index];
                Inc(index);
              end;

            If (temp OR $40 = temp) then
              begin
                vol := buffer[index];
                Inc(index);
              end;

            If (temp OR $80 = temp) then
              begin
                cmd := buffer[index];
                Inc(index);
                info := buffer[index];
                Inc(index);
              end;

            If (PRED(chan) in [1..18]) then
              import_fmk_event(pat,row,PRED(chan),note,ins,vol,cmd,info);
          end
        else
          begin
            Inc(row);
            Inc(index);
          end;
      until (row = 64);
    end;

  fix_fmk_commands(header.patnum);
  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 13;
end;

procedure import_sat_instrument(inst: Byte; var data);
begin
  With songdata.instr_data[inst] do
    begin
      fm_data.FEEDBACK_FM         := tDUMMY_BUFF(data)[0] AND $0f;
      fm_data.AM_VIB_EG_modulator := tDUMMY_BUFF(data)[1];
      fm_data.AM_VIB_EG_carrier   := tDUMMY_BUFF(data)[2];
      fm_data.ATTCK_DEC_modulator := tDUMMY_BUFF(data)[3];
      fm_data.ATTCK_DEC_carrier   := tDUMMY_BUFF(data)[4];
      fm_data.SUSTN_REL_modulator := tDUMMY_BUFF(data)[5];
      fm_data.SUSTN_REL_carrier   := tDUMMY_BUFF(data)[6];
      fm_data.WAVEFORM_modulator  := tDUMMY_BUFF(data)[7] AND 3;
      fm_data.WAVEFORM_carrier    := tDUMMY_BUFF(data)[8] AND 3;
      fm_data.KSL_VOLUM_modulator := tDUMMY_BUFF(data)[9];
      fm_data.KSL_VOLUM_carrier   := tDUMMY_BUFF(data)[10];
    end;

  songdata.instr_data[inst].panning := 0;
  songdata.instr_data[inst].fine_tune := 0;
end;

function import_sat_instrument_name(var data; inst: Byte): String;

var
  temp1: Word;
  temp2: Byte;
  temp3: String;

begin
  temp1 := 0;
  temp2 := 0;
  temp3 := '';

  While (temp1 < 496) do
    begin
      If (tDUMMY_BUFF(data)[temp1] = BYTE('')) then Inc(temp2);
      Inc(temp1);
      If (temp2 = inst+1) then
        begin
          While (tDUMMY_BUFF(data)[temp1] in [$20..$0ff]) and
                (Length(temp3) < 22) do
            begin
              temp3 := temp3+CHR(tDUMMY_BUFF(data)[temp1]);
              Inc(temp1);
            end;
          BREAK;
        end;
    end;

  import_sat_instrument_name := temp3;
end;

procedure import_sa2_effect(effect,def1,def2: Byte;
                            var out1,out2: Byte); forward;
procedure sat_file_loader;

type
  tHEADER = Record { version 1 }
              ident: array[1..4]   of Char; { ident_string }
              vernm: Byte;                  { version_number (1) }
              instt: array[0..$1e] of       { 31_instruments }
                     array[0..$0a] of Byte;
              instn: array[0..495] of Byte; { 31_instrument_names }
              order: array[0..254] of Byte; { pattern_order }
              nopat: Word;                  { number of patterns }
              snlen: Byte;                  { song_length }
              rspos: Byte;                  { restart_position }
              calls: Word;                  { calls_per_second }
            end;
type
  tHEADR2 = Record { version 6 }
              ident: array[1..4]   of Char; { ident_string }
              vernm: Byte;                  { version_number (1) }
              instt: array[0..$1e] of       { 31_instruments }
                     array[0..$0e] of Byte;
              instn: array[0..495] of Byte; { 31_instrument_names }
              order: array[0..$7f] of Byte; { pattern_order }
              nopat: Word;                  { number of patterns }
              snlen: Byte;                  { song_length }
              rspos: Byte;                  { restart_position }
              calls: Word;                  { calls_per_second }
              arpgd: array[1..512] of Byte; { arpeggio_data }
            end;
const
  id = 'SAdT';

var
  f: File;
  header: tHEADER;
  headr2: tHEADR2;
  SATver: Byte;
  temp,tmp2,tmp3,temp2,temp3,
  temp4,temp5: Longint;
  byte1,byte2,byte3,byte4,byte5,note_inc: Byte;

procedure import_sat_event(pattern,line,channel,
                           byte1,byte2,byte3,byte4,byte5: Byte);
var
  chunk: tCHUNK;

begin
  FillChar(chunk,SizeOf(chunk),0);
  If (byte2 in [1..31]) then chunk.instr_def := byte2;
  If (byte1 in [1..12*8+1]) then chunk.note := byte1+note_inc;

  import_sa2_effect(byte3,byte4,byte5,chunk.effect_def,chunk.effect);
  If (chunk.effect_def = ef_Extended) and
     (chunk.effect = ef_ex_ExtendedCmd*16) and (chunk.note = 0) then
    begin
      chunk.note := BYTE_NULL;
      chunk.effect_def := 0;
      chunk.effect := 0;
    end;

  put_chunk(pattern,line,channel,chunk);
end;

var
  absolute: Longint;

function get_byte(var pos: Longint): Byte;
begin
  If (pos = SizeOf(buffer)-5) then
    begin
      If NOT (absolute > SizeOf(buffer)-5) then Move(buf2,buffer,SizeOf(buf2)-5)
      else Move(buf3,buffer,SizeOf(buf3)-5);
      pos := 0;
    end;
  get_byte := buffer[pos];
  Inc(pos);
  Inc(absolute);
end;

begin
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  If NOT (header.vernm in [1,5,6]) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  SATver := header.vernm;
  If (SATver in [5,6]) then
    begin
      SeekF(f,0);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;

      BlockReadF(f,headr2,SizeOf(headr2),temp);
      If (temp <> SizeOf(headr2)) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  temp5 := (FileSize(f)-temp) DIV (64*9*5);
  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer)-5,temp);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  tmp2 := WORD_NULL;
  If (temp = SizeOf(buffer)-5) then
    begin
      FillChar(buf2,SizeOf(buf2),0);
      BlockReadF(f,buf2,SizeOf(buf2)-5,tmp2);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  tmp3 := WORD_NULL;
  If (tmp2 = SizeOf(buf2)-5) then
    begin
      FillChar(buf3,SizeOf(buf3),0);
      BlockReadF(f,buf3,SizeOf(buf3)-5,tmp3);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  init_songdata;
  load_flag := 0;

  songdata.common_flag := songdata.common_flag OR 8;
  songdata.common_flag := songdata.common_flag OR $10;
  import_old_flags;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  For temp := 1 to 20 do
    songdata.lock_flags[temp] := songdata.lock_flags[temp] OR 4 OR 8;

  If (SATver = 1) then
    begin
      speed := 6;
      If (header.calls < 255) then tempo := header.calls
      else tempo := 255;

      songdata.tempo := tempo;
      songdata.speed := speed;

      For temp := 0 to max(header.snlen-1,127) do
        If (temp < 128) and (header.order[temp] in [0..63]) then
          songdata.pattern_order[temp] := header.order[temp];
      If (header.rspos < 128) and (SUCC(temp) < 128) then
        songdata.pattern_order[SUCC(temp)] := $80+header.rspos;

      temp5 := max(temp5,header.nopat);
      For temp := 0 to $1e do
        begin
          import_sat_instrument(temp+1,header.instt[temp]);
          songdata.instr_names[temp+1] :=
            Copy(songdata.instr_names[temp+1],1,9)+
            truncate_string(import_sat_instrument_name(header.instn,temp));
        end;
    end
  else
    begin
      speed := 6;
      If (headr2.calls < 255) then tempo := headr2.calls
      else tempo := 255;

      songdata.tempo := tempo;
      songdata.speed := speed;

      For temp := 0 to headr2.snlen-1 do
        If (temp < 128) and (headr2.order[temp] in [0..63]) then
          songdata.pattern_order[temp] := headr2.order[temp];
      If (headr2.rspos < 128) and (SUCC(temp) < 128) then
        songdata.pattern_order[SUCC(temp)] := $80+headr2.rspos;

      temp5 := max(temp5,headr2.nopat);
      For temp := 0 to $1e do
        begin
          import_sat_instrument(temp+1,headr2.instt[temp]);
          songdata.instr_names[temp+1] :=
            Copy(songdata.instr_names[temp+1],1,9)+
            truncate_string(import_sat_instrument_name(headr2.instn,temp));
        end;
    end;

  temp := 0;
  absolute := 0;

  Case SATver of
    1: note_inc := 24;
    5: note_inc := 12;
    6: note_inc := 0;
  end;

  For temp2 := 0 to temp5-1 do
    For temp3 := 0 to 63 do
      For temp4 := 1 to 9 do
        begin
          byte1 := get_byte(temp);
          byte2 := get_byte(temp);
          byte3 := get_byte(temp);
          byte4 := get_byte(temp);
          byte5 := get_byte(temp);
          import_sat_event(temp2,temp3,temp4,byte1,byte2,byte3,byte4,byte5);
        end;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 14;
end;

function _sal(op1,op2: Word): Byte; assembler;
asm
        mov     ax,op1
        mov     cx,op2
        sal     ax,cl
end;

function _sar(op1,op2: Word): Byte; assembler;
asm
        mov     ax,op1
        mov     cx,op2
        sar     ax,cl
end;

procedure import_sa2_effect(effect,def1,def2: Byte;
                            var out1,out2: Byte);
begin
  Case effect of
  { NORMAL PLAY OR ARPEGGIO }
    $00: begin
           out1 := ef_Arpeggio;
           out2 := def1*16+def2;
         end;

  { SLIDE UP }
    $01: begin
           out1 := ef_FSlideUp;
           out2 := def1*16+def2;
         end;

  { SLIDE DOWN }
    $02: begin
           out1 := ef_FSlideDown;
           out2 := def1*16+def2;
         end;

  { TONE PORTAMENTO }
    $03: begin
           out1 := ef_TonePortamento;
           out2 := def1*16+def2;
         end;

  { VIBRATO }
    $04: begin
           out1 := ef_Vibrato;
           out2 := def1*16+def2;
         end;

  { TONE PORTAMENTO + VOLUME SLIDE }
    $05: If (def1+def2 <> 0) then
           If (def1 in [1..15]) then
             begin
               out1 := ef_TPortamVolSlide;
               out2 := min(_sar(def1,2),1)*16;
             end
           else begin
                  out1 := ef_TPortamVolSlide;
                  out2 := min(_sar(def2,2),1);
                end
         else
           begin
             out1 := ef_TPortamVolSlide;
             out2 := def1*16+def2;
           end;

  { VIBRATO + VOLUME SLIDE }
    $06: If (def1+def2 <> 0) then
           If (def1 in [1..15]) then
             begin
               out1 := ef_VibratoVolSlide;
               out2 := min(_sar(def1,2),1)*16;
             end
           else begin
                  out1 := ef_VibratoVolSlide;
                  out2 := min(_sar(def2,2),1);
                end
         else
           begin
             out1 := ef_VibratoVolSlide;
             out2 := def1*16+def2;
           end;

  { RELEASE SUSTAINING SOUND }
    $08: begin
           out1 := ef_Extended;
           out2 := ef_ex_ExtendedCmd*16+0;
         end;

  { VOLUME SLIDE }
    $0a: If (def1+def2 <> 0) then
           If (def1 in [1..15]) then
             begin
               out1 := ef_VolSlide;
               out2 := min(_sar(def1,2),1)*16;
             end
           else begin
                  out1 := ef_VolSlide;
                  out2 := min(_sar(def2,2),1);
                end
         else
           begin
             out1 := ef_VolSlide;
             out2 := def1*16+def2;
           end;

  { POSITION JUMP }
    $0b: If (def1*16+def2 < 128) then
           begin
             out1 := ef_PositionJump;
             out2 := def1*16+def2;
           end;

  { SET VOLUME }
    $0c: begin
           out1 := ef_SetInsVolume;
           out2 := def1*16+def2;
           If (out2 > 63) then out2 := 63;
         end;

  { PATTERN BREAK }
    $0d: If (def1*16+def2 < 64) then
           begin
             out1 := ef_PatternBreak;
             out2 := def1*16+def2;
           end;

  { SET SPEED }
    $0f: If (def1*16+def2 < $20) then
           begin
             out1 := ef_SetSpeed;
             out2 := def1*16+def2;
           end
         else If (def1 < 16) and (def2 < 16) then
                begin
                  out1 := ef_SetTempo;
                  out2 := Round((def1*16+def2)/2.5);
                end;
    else begin
           out1 := 0;
           out2 := 0;
         end;
  end;
end;

procedure sa2_file_loader;

type
  tHEADER = Record
              ident: array[1..4]   of Char; { These bytes mark a song }
              vernm: Byte;                  { Version number (9) }
              instt: array[0..$1e] of       { 31 instruments }
                     array[0..$0e] of Byte;
              instn: array[0..495] of Byte; { 31_instrument_names }
              order: array[0..$7f] of Byte; { Pattern order }
              nopat: Word;                  { Number of patterns }
              snlen: Byte;                  { Length of song }
              rspos: Byte;                  { Restart position }
              snbpm: Word;                  { BPM }
              arpgd: array[1..512] of Byte; { Arpeggio data (list+commands) }
              ordr2: array[0..63]  of       { Track order }
                     array[1..9]   of Byte;
              chans: Word;                  { Active channels }
            end;
const
  id = 'SAdT';

var
  f: File;
  header: tHEADER;
  temp,temp2,temp3,temp4,temp5: Longint;

procedure import_sa2_event(pattern,line,channel,
                           byte1,byte2,byte3: Byte);
var
  chunk: tCHUNK;
  temp: Byte;

begin
  FillChar(chunk,SizeOf(chunk),0);
  temp := (byte1 AND 1) SHL 4 +(byte2 SHR 4);
  If (temp in [1..31]) then chunk.instr_def := temp;
  If (byte1 SHR 1 in [1..12*8+1]) then chunk.note := (byte1 SHR 1);

  import_sa2_effect(byte2 AND $0f,byte3 SHR 4,byte3 AND $0f,
                    chunk.effect_def,chunk.effect);
  If (chunk.effect_def = ef_Extended) and
     (chunk.effect = ef_ex_ExtendedCmd*16) and (chunk.note = 0) then
    begin
      chunk.note := BYTE_NULL;
      chunk.effect_def := 0;
      chunk.effect := 0;
    end;

  put_chunk(pattern,line,channel,chunk);
end;

begin { sa2_file_loader }
  {$i-}
  Assign(f,songdata_source);
  ResetF(f);
  {$i+}
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  BlockReadF(f,header,SizeOf(header),temp);
  If NOT ((temp = SizeOf(header)) and (header.ident = id)) then
    begin
      CloseF(f);
      EXIT;
    end;

  If NOT (header.vernm in [8,9]) then
    begin
      CloseF(f);
      EXIT;
    end;

  load_flag := $7f;
  If (header.vernm = 8) then
    begin
      SeekF(f,FilePos(f)-2);
      If (IOresult <> 0) then
        begin
          CloseF(f);
          EXIT;
        end;
    end;

  FillChar(buffer,SizeOf(buffer),0);
  BlockReadF(f,buffer,SizeOf(buffer)-3,temp);
  If (IOresult <> 0) then
    begin
      CloseF(f);
      EXIT;
    end;

  init_songdata;
  load_flag := 0;

  songdata.common_flag := songdata.common_flag OR 8;
  songdata.common_flag := songdata.common_flag OR $10;
  import_old_flags;

  songdata.patt_len := 64;
  If adjust_tracks then songdata.nm_tracks := 9
  else If (songdata.nm_tracks < 9) then songdata.nm_tracks := 9;

  For temp := 1 to 20 do
    songdata.lock_flags[temp] := songdata.lock_flags[temp] OR 4 OR 8;

  speed := 6;
  If (Round(header.snbpm/2.5) < 255) then tempo := Round(header.snbpm/2.5)
  else tempo := 255;

  songdata.tempo := tempo;
  songdata.speed := speed;

  temp2 := 0;
  temp3 := 0;
  temp4 := 1;

  Repeat
    While (header.ordr2[temp2][temp4] = 0) and
          (temp2 <= header.nopat-1) do
      begin
        Inc(temp4);
        If (temp4 > 9) then begin temp4 := 1; Inc(temp2); end;
      end;

    If (temp2 <= header.nopat-1) then
      begin
        temp5 := 64*3*(header.ordr2[temp2][temp4]-1)+temp3*3;
        import_sa2_event(temp2,temp3,temp4,buffer[temp5],
                                           buffer[temp5+1],
                                           buffer[temp5+2]);
        Inc(temp3);
        If (temp3 > $3f) then
          begin
            temp3 := 0;
            If (temp4 < 9) then Inc(temp4)
            else begin temp4 := 1; Inc(temp2); end;
          end;
      end;
  until (temp2 > header.nopat-1);

  For temp := 0 to header.snlen-1 do
    If (temp < 128) and (header.order[temp] in [0..63]) then
      songdata.pattern_order[temp] := header.order[temp];
  If (header.rspos < 128) and (SUCC(temp) < 128) then
    songdata.pattern_order[SUCC(temp)] := $80+header.rspos;

  For temp := 0 to $1e do
    begin
      import_sat_instrument(temp+1,header.instt[temp]);
      songdata.instr_names[temp+1] := Copy(songdata.instr_names[temp+1],1,9)+
        truncate_string(import_sat_instrument_name(header.instn,temp));
    end;

  CloseF(f);
  songdata_title := NameOnly(songdata_source);
  load_flag := 15;
end;

