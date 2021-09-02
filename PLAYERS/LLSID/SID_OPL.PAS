unit sid_opl;

interface

var sidregs:array[0..24] of byte;
Procedure Adlibinit;

procedure sid_out(reg,dta:byte);
procedure sid_frame;
procedure sid_reset;
procedure setreg(reg:Byte);

{implementation}

const adlreg=$388;adldta=adlreg+1;

type optbl=record
            {20}misc:byte;
            {40}voll:byte;
            {e0}wave:byte;
            {60}adsr:Word;
                useadsr:boolean;
           end;
     chntbl=record
              op1:optbl;
              op2:optbl;
            {c0}fbfm:byte;
            end;
     adlibfreq=record
                 Fn:word;
                 Bl:byte;
               end;

var
 waves:array[0..15] of chntbl;
 adsr:array[0..3] of array[0..15] of byte;
 convtable:array[0..4095] of adlibfreq;
 OldExit : pointer;
 oldwaves:array[0..2] of byte;
 pan:array[0..2] of byte;

implementation

uses dos;

procedure initconv;
function twotothe(n:byte):longint;
var i:byte;j:longint;
begin
  j:=1;
  for i:=1 to n do j:=j*2;
  twotothe:=j;
end;

procedure splithz(hz:word;var fn:word;var bl:byte);
var fnum:word;
    block:byte;
begin
  block:=0;
  repeat
    FNum := word(longint((Hz * twotothe(20-Block)) div 49716));
    if fnum>1023 then inc(block);
  until fnum<1024;
  fn:=fnum;
  bl:=block;
end;

var w:word;
begin
  for w:=0 to 4095 do splithz(w,convtable[w].fn,convtable[w].bl);
end;

procedure adlibsend(a,b:byte);assembler;
asm
  mov dx,adlreg
  mov al,a
  out dx,al
  in  al,dx
  inc dx
  mov al,b
  out dx,al
end;

procedure waveselect(chn,b:byte);
begin
  if b and 4=4 then b:=4;
  if oldwaves[chn]=b then exit;
  oldwaves[chn]:=b;
  adlibsend(chn+$20,waves[b].op1.misc);
  adlibsend(chn+$40,waves[b].op1.voll);
  adlibsend(chn+$e0,waves[b].op1.wave);
  adlibsend(chn+$23,waves[b].op2.misc);
  adlibsend(chn+$43,waves[b].op2.voll);
  adlibsend(chn+$e3,waves[b].op2.wave);
  adlibsend(chn+$c0,pan[chn]+waves[b].fbfm);
  if waves[b].op1.useadsr then
  begin
    adlibsend(chn+$60,waves[b].op1.adsr shr 8);
    adlibsend(chn+$80,waves[b].op1.adsr and $ff);
  end else
  begin
    adlibsend(chn+$60,adsr[0][sidregs[(chn*7)+5] shr 4] shl 4+
                      adsr[1][sidregs[(chn*7)+5] and$f]);
    adlibsend(chn+$80,adsr[2][sidregs[(chn*7)+6] shr 4] shl 4+
                      adsr[3][sidregs[(chn*7)+6] and$f]);
  end;
  if waves[b].op2.useadsr then
  begin
    adlibsend(chn+$63,waves[b].op2.adsr shr 8);
    adlibsend(chn+$83,waves[b].op2.adsr and $ff);
  end else
  begin
    adlibsend(chn+$63,adsr[0][sidregs[(chn*7)+5] shr 4] shl 4+
                      adsr[1][sidregs[(chn*7)+5] and$f]);
    adlibsend(chn+$83,adsr[2][sidregs[(chn*7)+6] shr 4] shl 4+
                      adsr[3][sidregs[(chn*7)+6] and$f]);
  end;
end;
procedure sidadsr;external;{$L sidadsr}
procedure sidwaves;external;{$L sidwaves}
procedure initsounds;
begin
  initconv;
  move(@sidwaves^,waves,208);
  move(@sidadsr^,adsr,64);
end;

procedure opl3(b:boolean);
Var Temp  : Integer;
begin
  Port[adlreg+2] := 5;
  if b then Port[adldta] := 1 else port[adldta]:=0;
  temp:=port[adldta];
end;
Procedure Adlibinit;
Var  A : Integer;
Begin
  opl3(true);
  for a:=$20 to $f5 do adlibsend(a,0);
  adlibsend(1,$20);
  adlibsend(8,0);
  opl3(true);
end;


procedure casechannel(chn,reg:byte);{chn=0..2}
var fhz,
    fn,w:word;
    b:byte;
begin
  fhz:=word(sidregs[(chn*7)+1] shl 8+sidregs[(chn*7)+0]) div 17;
  if (sidregs[(chn*7)+4] and 128)=128 then fhz:=3333;
  fn:=convtable[fhz].fn;
  b:=convtable[fhz].bl;
  case reg of
    0,1: if sidregs[(chn*7)+4]>15 then if (sidregs[(chn*7)+4] and 8)<>8 then
         begin
           adlibsend(chn+$a0,byte(fn));
           adlibsend(chn+$b0,(b shl 2)+(( sidregs[(chn*7)+4] and 1)shl 5)+(fn shr 8));
         end;
    2,3: if oldwaves[chn]=4 then
         begin
           w:=((sidregs[(chn*7)+3]and$f shl 8)+sidregs[(chn*7)+2]);
           if w>2048 then w:=4096-w;
           adlibsend(chn+$40,32+(w shr 7));
{           end else adlibsend(chn+$40,63);}
          end;
      4: begin
           if (oldwaves[chn]<>sidregs[(chn*7)+4] shr 4) then
           begin
             adlibsend(chn+$a0,byte(fn));
             adlibsend(chn+$b0,(b shl 2)+(( sidregs[(chn*7)+4] and 1)shl 5)+(fn shr 8));
           end;
           waveselect(chn,sidregs[(chn*7)+4] shr 4);

           if (sidregs[(chn*7)+4] and 2)=2 then
             adlibsend(1,0) else adlibsend(1,32);
           if (sidregs[(chn*7)+4] and 8)=8 then
           begin
             adlibsend(chn+$a0,0);
             adlibsend(chn+$b0,(sidregs[(chn*7)+4] and 1)shl 5);
           end else if (sidregs[(chn*7)+4] and 1)=0 then adlibsend(chn+$b0,(b shl 2)+0+(fn shr 8));
         end;
      5:begin
          adlibsend(chn+$60,adsr[0][sidregs[(chn*7)+5] shr 4] shl 4+adsr[1][sidregs[(chn*7)+5] and$f]);
          adlibsend(chn+$63,adsr[0][sidregs[(chn*7)+5] shr 4] shl 4+adsr[1][sidregs[(chn*7)+5] and$f]);
          if waves[sidregs[(chn*7)+4]shr 4].op1.useadsr then adlibsend(chn+$60,waves[sidregs[(chn*7)+4] shr 4].op1.adsr shr 8);
          if waves[sidregs[(chn*7)+4]shr 4].op2.useadsr then adlibsend(chn+$63,waves[sidregs[(chn*7)+4] shr 4].op2.adsr shr 8);
        end;
      6:begin
          adlibsend(chn+$80,adsr[2][sidregs[(chn*7)+6] shr 4] shl 4+adsr[3][sidregs[(chn*7)+6] and$f]);
          adlibsend(chn+$83,adsr[2][sidregs[(chn*7)+6] shr 4] shl 4+adsr[3][sidregs[(chn*7)+6] and$f]);
          if waves[sidregs[(chn*7)+4]shr 4].op1.useadsr then adlibsend(chn+$80,waves[sidregs[(chn*7)+4]shr 4].op1.adsr and$ff);
          if waves[sidregs[(chn*7)+4]shr 4].op2.useadsr then adlibsend(chn+$83,waves[sidregs[(chn*7)+4]shr 4].op2.adsr and$ff);
        end;
  end;
end;

procedure casefilter(reg:Byte);
begin
  case reg of
    24: begin
{          if sidregs[4]>16 then adlibsend($43,(not ((dta and $f) shl 2))and 63);
          if sidregs[11]>16 then adlibsend($44,(not ((dta and $f) shl 2))and 63);
          if sidregs[18]>16 then adlibsend($45,(not ((dta and $f) shl 2))and 63);
          if sidregs[4]>16 then adlibsend($40,(not ((dta and $f) shl 2))and 63);
          if sidregs[11]>16 then adlibsend($41,(not ((dta and $f) shl 2))and 63);
          if sidregs[18]>16 then adlibsend($42,(not ((dta and $f) shl 2))and 63);}
        end;
  end;
end;
procedure setreg(reg:Byte);
begin
  case reg of
    0..6: casechannel(0,reg);
    7..13: casechannel(1,reg-7);
    14..20: casechannel(2,reg-14);
    24: casefilter(reg);
  end;
end;

procedure sid_out;
begin;
  if reg<25 then
  begin
    sidregs[reg]:=dta;
{    if (reg mod 7)=4 then if (dta and 1)=1 then exit;}
    setreg(reg);
  end;
end;
procedure sid_frame;
var reg:byte;
begin
  for reg:=0 to 24 do setreg(reg);
end;
procedure sid_reset;
var w:word;
begin
  for w:=0 to 2 do oldwaves[w]:=0;
  for w:=0 to 2 do pan[w]:=48;
  for w:=0 to 24  do sid_out(w,0);
  sid_frame;
end;
{$F+}
procedure shutdown;
begin
  adlibinit;
  exitproc:=oldexit
end;
{$F-}
begin
  OldExit:=ExitProc;
  ExitProc:=@ShutDown;
  adlibinit;
  initsounds;
  sid_reset;
end.
