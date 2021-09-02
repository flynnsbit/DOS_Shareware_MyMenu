{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P+,Q+,R+,S+,T+,V+,X+}
{$M 16384,0,2048}
program mklink;
{Builds a Joliet Directory Link Table from all Joliet CDs in all drives.
 This table has following content:
 - 35 BYTE  volume label, CRLF, EOF, padding zeros
 -  1 DWORD signature (='JLT1' for this version)
 -  1 WORD  size to load
 -  1 WORD  number of entries (=n)
 -  1 WORD  size of table (=n * bytes/entry)
 -  n ?     ISO directory sectors
 -  n ?     corresponding Joliet directory sectors
 -  ? BYTE  code to scan table
 The name is built from the CD volume serial number, +.JLT extension

 This generator program has some limitations:
 ? every directory must be less than 64K (runtime error 220)
   (relax this requires huge pointer arithmetics. Loading single
    sectors would degrade MKLINKs performance dramatically.
    Huge pointers are easy if allocated memory has offset of zero.)
 - directory data for all levels must fit into DOS memory (runtime error 203)
   (ISO resticts depth to eight levels, but most writer software
    can relax this limitation. You may recompile using Borland DPMI.)
 - Empty directories may not be mapped together as intended
   (This is by design of Joliet - a better implementation can compare strings
    to get better results, but for normal usage, malfunction is meaningless.)

 - Although it's possible to create different trees for ISO and Joliet
   (i.e. the disc appears different and may show up different directories
    with same names under DOS and Win9x - or similar strange or useful
    things - e.g. providing a DOS+Win16 and a Win32 executable under the
    same name), it's rarely used. I have never seen such a CDROM,
    but Nero or WinOnCD (even older versions) are able to create this.
   MKLINK and DOSLFN too can't work correctly with such a CDROM.
   (Due to program logic, Odi-LFN tools CAN support this situation.)

 The "force mode" includes:
 - Taking all given drive letters as MSCDEX letters (do not check them)
 - Skipping "CeQuadrat Joliet Directory Link Table", burned by WinOnCD
 - Overwriting existing files (do not skip if they exist)

 Unreadable and Non-Joliet CDs are always skipped.

 A check whether LFN and SFN DirEnts are in the same order can be done;
 writing a special file, saying "This CD doesn't need a .JLT table",
 will be convenient for future DOSLFN.

 Attention!
 mklink's output file names (.JLT) are subject of change,
 as it can assume DOSLFN is running and there is no need to
 strip the file name down to 8 characters (as it makes distinction
 of different CDs more difficult).

 MKLINK has now codepage-dependent Unicode->OEM conversion with DBCS support,
 but that's for user's amusing and programmer's debugging only. MKLINK
 doesn't rely on comparing names.

 Freeware 01/03 haftmann#software}

uses Dos,WinDos,Strings{$IFDEF DPMI},WinAPI{$ENDIF};
{Dos	 for NameStr}
{WinDos  for GetArgCount and GetArgStr}
{Strings for StrCopy, StrPas, StrScan...}

type			{boring struct declarations}
 PtrRec=record
  ofs,sel:Word;
 end;
 LongRec=record
  lo,hi:Word;
 end;
 WordRec=record
  lo,hi:Byte;
 end;
 PByte=^Byte;
 PWord=^Word;
 PLongInt=^LongInt;
{$IFDEF DPMI}
type
 TCRS=record	{DPMI Client Register Structure}
  _di,e_di,_si,e_si,_bp,e_bp,r1,r2,
  _bx,e_bx,_dx,e_dx,_cx,e_cx,_ax,e_ax,
  flags,_es,_ds,_fs,_gs,_ip,_cs,_sp,_ss: Word;
 end;
var
 crs:TCRS;	{global Real Mode register}
 RMBuffer: LongInt;	{Real Mode Buffer (2KB) Segment(lo) and Selector(hi)}
{$S-}
procedure call2F(p:PChar;len:Word); assembler;
{fixed to Client_ES:Client_BX = RMBuffer, AX=Function Number}
 asm	pusha
{	 push	ds
	  mov	es,LongRec[RMBuffer].lo
	  mov	di,0
	  lds	si,[p]
	  mov	cx,[len]
	  rep	movsb
	 pop	ds
}	 push	ds
	 pop	es
	 mov	di,offset crs
	 mov	TCRS[di]._ax,ax
	 mov	ax,LongRec[RMBuffer].hi
	 mov	TCRS[di]._es,ax
	 xor	cx,cx
	 mov	TCRS[di]._bx,cx
	 mov	TCRS[di]._ss,cx
	 mov	TCRS[di]._sp,cx
	 mov	bx,2Fh
	 mov	ax,300h
	 int	31h
	 push	ds
	  mov	ds,LongRec[RMBuffer].lo
	  mov	si,0
	  les	di,[p]
	  mov	cx,[len]
	  rep	movsb
	 pop	ds
	popa
 end;
{$S+}
{$ELSE}
function Byte2Para(Bytes:LongInt):Word; assembler;
 asm	mov	dx,LongRec[Bytes].hi
	mov	ax,LongRec[Bytes].lo
	add	ax,0Fh
	adc	dx,0
	mov	cx,4
@@l:	shr	dx,1
	rcr	ax,1
	loop	@@l
 end;

function GlobalAllocPtr(Flags:Word; Bytes:LongInt):Pointer; assembler;
 asm	push	LongRec[Bytes].hi
	push	LongRec[Bytes].lo
	call	Byte2Para
	or	dx,dx
	jnz	@@err
	xchg	bx,ax
	mov	ah,48h
	int	21h	{allocate DOS memory block}
	jnc	@@ok
@@err:	xor	ax,ax
@@ok:	xchg	dx,ax
	xor	ax,ax
 end;

function GlobalFreePtr(P:Pointer):Word; assembler;
 asm	mov	es,PtrRec[P].sel
	mov	ah,49h
	int	21h	{free DOS memory block}
	jc	@@e
	xor	ax,ax
@@e:
 end;
{$ENDIF}

procedure IncHP(var P:PChar; By: Word); assembler;
 asm	les	di,[P]
	mov	ax,[By]
	add	es:PtrRec[di].Ofs,ax
	jnc	@@e
	mov	ax,[SelectorInc]
	add	es:PtrRec[di].Sel,ax
@@e:
 end;

var
 drv: Word;
 asciidrv: Char;
 multiple: Boolean;	{whether MKLINK works with more than one drive}
 verbosity: Integer;
 forcemode: Boolean;	{enforce overwriting file and ignoring CeQuadrat}
 batchmode: Boolean;	{continue manually changing discs until done}
 comparing: Boolean;	{show compare result of ISO and Joliet tree leaves}
 contmode:  Boolean;	{if at first time no disc in a closed drive, eject}
 sameorder: Boolean;	{comparing is always done because it's now fast}
 manual:    Boolean;	{read/write the two tables "manually"}
 manualw:   Boolean;	{writing the manual link}
 timer: Word absolute $40:$6C;	{18.2 ms per increment}

function ReadSectors(sec:PChar; cnt:Word; Nr:LongInt):Boolean; assembler;
{Reads some CD sectors; may include VTOC sectors at #16+ depending on
 (MS)CDEX running; parameter sorting compatible to Int25/Int26 call.
 For simplicity, in DPMI mode only one sector can be read}
 asm	les	bx,[sec]
	mov	si,LongRec[Nr].hi
	mov	di,LongRec[Nr].lo
	mov	cx,[drv]
{$IFDEF DPMI}
	mov	[crs._si],si
	mov	[crs._di],di
	mov	[crs._cx],cx
	mov	[crs._dx],1
	mov	ax,1508h
	push	es
	push	bx
	push	2048
	call	call2F
	mov	ax,[crs.flags]
	shr	al,1
{$ELSE}
	mov	dx,[cnt]
	mov	ax,1508h
	int	2Fh
{$ENDIF}
	mov	al,1
	sbb	al,0
 end;

function HugeReadSectors(sec:PChar; cnt:Word; Nr:LongInt):Boolean;
 var
  c: Word;
 begin
  HugeReadSectors:=false;
  while cnt<>0 do begin
{$IFDEF DPMI}
   if not ReadSectors(sec,1,Nr) then exit;	{only one allowed}
   Inc(Nr);
   IncHP(sec,2048);
   Dec(cnt);
{$ELSE}
   c:=cnt; if c>16 then c:=16;	{YET DIRTY: read max. 32K}
   if not ReadSectors(sec,c,Nr) then exit;
   Inc(Nr,c);
   IncHP(sec,2048*c);
   Dec(cnt,c);
{$ENDIF}
  end;
  HugeReadSectors:=true;
 end;

procedure Idle; assembler;
{releases current time slice to Virtual Machine Manager (Windows, OS/2),
 and give DOS and TSRs a hint to do some backgound processing}
 asm	int	28h
	mov	ax,1680h	{release time slice (PM)}
	int	2Fh
	mov	ah,0Bh		{check input status (^C)}
	int	21h
 end;

function Ioctl(s:PChar):Boolean;
{Maintain a CD IOCTL call (with its brain-damaged structure),
 String <s> must contain:
 s[0]=control code (3=read, 12=write)
 s[1]=number of bytes to read or write
 s[2+]=bytes to write or (return) bytes ro read}
 type
  TDDRH=packed record
   len,sub,cmd: Byte;
   status: Word;
   devname: array[0..7] of Char;
   mediadescriptor: Byte;
   bufferptr: Pointer;
   buffersize: Word;
   startsector: LongInt;
   volumeptr: LongInt;
  end;
{$IFDEF DPMI}
 type
  TDDR=record
   ddrh:TDDRH;
   scratch:array[0..0] of Byte;
  end;
 var
  ddrp:^TDDR;
 begin
  ddrp:=Ptr(LongRec(RMBuffer).lo,0);
  FillChar(ddrp^,sizeof(TDDR),0);
  ddrp^.ddrh.len:=sizeof(TDDRH);		{28 = $1C}
  ddrp^.ddrh.cmd:=Byte(s[0]);
  ddrp^.ddrh.bufferptr:=Ptr(LongRec(RMBuffer).hi,sizeof(TDDRH));
  Byte(ddrp^.ddrh.buffersize):=Byte(s[1]);
  Move(s[2],ddrp^.scratch[0],Byte(s[1]));
  asm	mov	ax,[drv]
	mov	[crs._cx],ax
	mov	ax,1510h	{IOCTL}
	push	0
	push	0
	push	0	{no buffer transfer here!}
	call	call2F
	mov	al,byte ptr [crs.flags]
	not	al
	and	al,1		{CY flag}
	mov	[@Result],al
  end;
  Move(ddrp^.scratch[0],s[2],Byte(s[1]));
{$ELSE}
 var
  ddr: TDDRH;
 begin
  FillChar(ddr,sizeof(ddr),0);
  ddr.len:=sizeof(ddr);		{28 = $1C}
  ddr.cmd:=Byte(s[0]);
  ddr.bufferptr:=s+2;
  Byte(ddr.buffersize):=Byte(s[1]);
  asm	push	ss
	pop	es
	lea	bx,[ddr]
	mov	cx,[drv]
	mov	ax,1510h
	stc
	int	2Fh
	mov	al,1
	sbb	al,0
	mov	[@Result],al
  end;
{$ENDIF}
 end;

function DetermineVolStart:LongInt;
 type
  PMsf=^TMsf;
  Tmsf=record
   f,s,m:Byte;
  end;
  PAudioDiskInfo=^TAudioDiskInfo;
  TAudioDiskInfo=record
   cmd: Byte;		{=10}
   first,last: Byte;
   leadout: LongInt;
  end;
  PAudioTrackInfo=^TAudioTrackInfo;
  TAudioTrackInfo=record
   cmd: Byte;		{=11}
   tno: Byte;		{track number}
   start: LongInt;
   ctrl_adr: Byte;	{data track if bit 6 is set}
  end;
 var
  tno: Byte;
  s: array[0..9] of Char;
 begin
  StrCopy(s,#3#7#10);
  Ioctl(s);		{get first and last track number}
  for tno:=PAudioDiskInfo(s+2)^.last downto PAudioDiskInfo(s+2)^.first
  do begin
   StrCopy(s,#3#7#11);
   Byte(s[3]):=tno;
   Ioctl(s);		{get track info: start and type}
   if PAudioTrackInfo(s+2)^.ctrl_adr and $40 <>0 then begin
    with PMsf(@PAudioTrackInfo(s+2)^.start)^ do begin
     DetermineVolStart:=LongInt(m)*4500+s*75+f-150;
    end;
    exit;
   end;
  end;
  DetermineVolStart:=-1;
 end;

function toc(tic:Word):Word;
{returns time elapsed since taking tic, in steps of about 55 ms}
 begin
  {$Q-}
  toc:=Timer-tic;	{ignore any overflows here, these are intended!}
  {$Q+}
 end;

function CD_Status:Word;
 var
  s: array[0..6] of Char;
 begin
  StrCopy(s,#3#5#6);
  Ioctl(s);
  CD_Status:=PWord(s+3)^;
 end;

function isatty(fh:Integer):Boolean; assembler;
 asm	mov	bx,[fh]
	mov	ax,4400h
	int	21h
	xchg	dx,ax
	rol	al,1		{Bit 7 -> Bit 0}
	and	al,1
 end;

const
 Drehstrich: array[0..3] of Char='\|/-';

function CD_Eject:Boolean;
{As Name implies, ejects a CD from current drive; does some message outpus}
 var
  t,tic:Word;
  dr: Integer;
 begin
  tic:=timer;
  Write('Ejecting ',asciidrv,':');
  Ioctl(#12#2#1#0);		{unlock door if locked (for disc changers)}
  CD_Eject:=Ioctl(#12#1#0);
  {Assume that every eject must take at least 1.5 seconds.
   Some implementations of CD drivers return control immediately,
   and door status will not immediately return OPEN, this confuses.}
  repeat Idle until toc(tic)>25;
  {Win95 CD driver does not return OPEN even if is, to get right state,
   you have to query seldom enough - therefore, this "self-lenging"
   wait loop between two Ioctls}
  dr:=0; t:=2;
  repeat
   tic:=timer;
   repeat Idle until toc(tic)>=t;
   if isatty(1) then begin
    Write(Drehstrich[dr],#8);
    dr:=(dr+1)mod 4;
   end;
   Inc(t,t);			{twice idle time to wait (Win95 requires)}
  until CD_Status and 1 <>0;	{until drive reports an open door!}
  Write(#13,#13:13);
 end;

function CD_WaitForClose:Boolean;
{An interactive waiting for next CD. If user does insert no CD, program
 stops. If there is a closed door without a CD at first call, this routine
 opens the tray. The insertion notification message will be animated.}
 label restart;
 var
  i,v:Integer;
  tic,sta: Word;
  s: String[70];
 begin
  s:='Insert next CD';
  if multiple then s:=s+' into '+asciidrv+':' else s:=s+',';
  s:=s+' or no CD if you want to terminate. '#13;
restart:
  sta:=CD_Status;
  if sta and 1 <>0 then begin
   {$Q-}
   contmode:=true;
   i:=Length(s); v:=1;
   repeat
    tic:=timer;
    Write(s:i);
    Inc(i,v);
    if i=80 then v:=-1;
    if i=Length(s) then v:=1;
    repeat Idle until toc(tic)>=4;	{do not ask too often}
    sta:=CD_Status;
   until sta and 1 =0;			{until drive reports a closed door}
   tic:=timer;
   repeat Idle until toc(tic)>1*18;	{wait some seconds}
   Write(#13:80);
   {$Q+}
  end;
  if sta and $800 <>0 then begin
   if contmode then begin
    WriteLn('No CD in drive ',asciidrv,':, aborting program now.');
    halt;
   end else begin
    CD_Eject;
    goto restart;
   end;
  end;
 end;


function MapBytes(Nr,len:LongInt):PChar;
{Like true memory mapping, this routine returns a pointer to loaded
 sectors. This routine memorize the size
 of block two bytes below the returned pointer.}
 var P:PChar;
 begin
  P:=GlobalAllocPtr(0,len);
  if P=nil then begin
   WriteLn('Too large (',len,' Bytes) directory structure to map, aborting!');
   RunError(220);
  end;
  if not HugeReadSectors(P,(len+2047) shr 11,Nr) then begin
   WriteLn('Cannot read sectors from CD drive, aborting!');
   RunError(221);
  end;
  MapBytes:=P;
 end;

procedure UnmapBytes(p:PChar);
{Frees memory, uses the memorized size, therefore, acts as free() C function}
 begin
  GlobalFreePtr(p);
 end;

type
 ee=(le,be);
 bedw=array[ee] of LongInt;
 bew=array[ee] of Word;
 PDirEnt=^TDirEnt;
 TDirEnt=record
  r: Byte;	{the number of bytes in the record (which must be even)}
  ea: Byte;	{0 [number of sectors in extended attribute record]}
  file_start_lbn: bedw;		{Logical Block Number (=sector) of file start}
  file_size_byte: bedw;		{file length in bytes}
  date_time: array[0..6] of Byte;
  bit_flags: Byte;
  interleave_size: Byte;		{interleave size}
  interleave_skip: Byte;		{interleave skip factor}
  volume_set_number: bew;		{volume set sequence number}
  filename: String[1];		{a Pascal string!}
 end;

procedure Time_CD2FAT(const de:TDirEnt; var Time:LongInt);
 var
  dt: TDateTime;
 begin
  with de do begin
   dt.year:=	date_time[0]+1900;
   dt.month:=	date_time[1];
   dt.day:=	date_time[2];
   dt.hour:=	date_time[3];
   dt.min:=	date_time[4];
   dt.sec:=	date_time[5];
  end;
  PackTime(dt,Time);
 end;

procedure Time_Ascii2FAT(sp:PChar; var Time: LongInt);
 var
  dt: TDateTime;
  s: String[17];
  e: Integer;
 begin
  s[0]:=#17;
  Move(sp^,s[1],17);
  Val(Copy(s, 1,4),dt.year, e);
  Val(Copy(s, 5,2),dt.month,e);
  Val(Copy(s, 7,2),dt.day,  e);
  Val(Copy(s, 9,2),dt.hour, e);
  Val(Copy(s,11,2),dt.min,  e);
  Val(Copy(s,13,2),dt.sec,  e);
  PackTime(dt,Time);
 end;

var
 UniXlat:    PWord;		{pointer to Unicodes}
 UniTableLen: Word;		{length of table, in Words}
 TrailMinLen: Word;		{for DBCS type, TrailByte area}

procedure LoadUni;
 var
  cp: Word;			{Code Page}
  fname: array[0..12] of Char;	{built file name}
  ok: Boolean;			{Okay flag}
  buf: array[0..31] of Byte;	{buffer for header parsing}
  i: Integer;
  f: File;			{BlockRead file type}
 begin
  asm	mov	ax,6601h
	xor	bx,bx
	int	21h
	mov	[cp],bx
  end;
  if cp=0 then exit;
  Str(cp:5,fname);
  if cp<10000 then fname[0]:='C';
  if cp<1000 then fname[1]:='P';
  StrCopy(fname+5,'UNI.TBL');
  Assign(f,fname); {$I-} Reset(f,1) {$I+};
  if IOResult<>0 then begin
   WriteLn('Couldn''t open Unicode table file ',fname);
   exit;
  end;
  ok:=false;
  BlockRead(f,buf,sizeof(buf));
  for i:=0 to HIGH(buf) do case buf[i] of
   0: break;
   1: begin ok:=true; break; end;
   2: begin
    if i<=HIGH(buf)-2 then begin
     ok:=true;
     Inc(i);
     TrailMinLen:=PWord(@buf[i])^;
     Inc(i);
    end;
    break;
   end;
  end;
  if not OK then begin
   WriteLn('Unicode table file ',fname,' has wrong format.');
   Close(f);
   exit;
  end;
  Inc(i);
  UniTableLen:=FileSize(f)-i;		{in bytes}
  Seek(f,i);				{start of unicodes}
  UniXlat:=GlobalAllocPtr(0,UniTableLen);
  BlockRead(f,UniXlat^,UniTableLen);	{map all unicodes}
  UniTableLen:=UniTableLen div 2;	{in words}
  Close(f);
 end;

procedure uni2oem(w:Word;var s:PChar); assembler;
{Same routine as in DOSLFN, supports DBCS}
 asm	mov	ax,[w]
	les	di,[s]
	les	di,es:[di]
	cld
	cmp	ax,80h
	jc	@@e
	push	es
	push	di
	 les	di,[UniXlat]
	 mov	cx,es
	 jcxz	@@nc		{no translation without a table}
	 mov	cx,[UniTableLen]
	 push	di
	 push	cx
	  repne	scasw
	 pop	ax
	 pop	di
	 jne	@@NoConv
	 sub	ax,cx
	 add	ax,7Fh		{Index 0 is AX=80h}
	 or	ah,ah		{>=100h?}
	 jz	@@e1		{1 Byte Character}
	 dec	ah		{-100h}
	 div	WordRec[TrailMinLen].hi	{AH=TrailIndex, AL=LeadIndex}
	 xor	dx,dx
	 xchg	dh,ah		{save TrailIndex, zero AH}
	 inc	ax		{1-based}
	 mov	cx,80h
	 repne	scasw		{search Index}
	 mov	dl,0FFh		{AH is 0}
	 sub	dl,cl		{Index 0 -> Leadbyte 80h}
	 xchg	dx,ax		{AL=LeadByte, AH=TrailIndex}
	pop	di
	pop	es
	stosb			{write LeadByte}
	xchg	ah,al
	add	al,WordRec[TrailMinLen].lo
	jmp	@@e
@@nc:
	or	ah,ah		{>=100h?}
	jz	@@e1		{take an ISO-Latin-1 character}
@@NoConv:
	mov	al,'_'		{not convertable char}
@@e1:	pop	di
	pop	es
@@e:	stosb
	xchg	ax,di
	les	di,[s]
	stosw			{change Offset}
 end;

function ununi(d:PChar;s:PWord; l:Integer):PChar;
{copies l Motorola Unicode characters from s to d}
 begin
  while l<>0 do begin
   uni2oem(Swap(s^),d);
   Inc(s);
   dec(l);
  end;
  ununi:=d;
 end;

procedure ununicode(var s:String);
{unicode-to-ascii conversion; unicode data is big endian}
 var
  i: Integer;
 begin
  if odd(length(s)) then exit;
  s[0]:=Char(ununi(@s[1],PWord(@s[1]),length(s) div 2)-@s[1]);
 end;

var
 DbcsLeadByteTable: PWord;
	{points to pairs of LeadMinByte/LeadMaxByte, zero-terminated}

procedure PrepareDBCS; assembler;
 var
  info: array[0..4] of Char;
 asm	cld
	mov	ax,6507h
	mov	bx,0FFFFh
	mov	cx,5
	mov	dx,bx
	push	ss
	pop	es
	mov	di,sp
	int	21h
	les	di,es:[di+1]
	scasw			{skip count word}
	mov	PtrRec[DbcsLeadByteTable].ofs,di
	mov	PtrRec[DbcsLeadByteTable].sel,es
 end;

function IsDbcsLeadByte(c:Char):Boolean; assembler;
{same as the Windows function}
 asm	cld
	push	ds
	push	si
	 lds	si,[DbcsLeadByteTable]
 @@l:	 lodsw
	 cmp	ax,1
	 jc	@@e
	 cmp	[c],al
	 jc	@@e
	 cmp	ah,[c]
	 jc	@@l
@@e:	pop	si
	pop	ds
	db	0D6h		{SETALC = "sbb al,al" in one byte}
	inc	al
 end;

function LeftStr(s:String; bytes:Integer):String;
{DBCS safe "Left$" function, copies <bytes> or <bytes-1> bytes}
 var
  i:Integer;
 begin
  for i:=1 to Length(s) do begin
   if IsDbcsLeadByte(s[i]) then Inc(i);
   if i>bytes then Dec(bytes);
   if i>=bytes then break;
  end;
  LeftStr:=Copy(s,1,bytes);
 end;

function IsRegularDir(const de:TDirEnt): Boolean;
 begin
  with de do begin
   IsRegularDir:=(bit_flags and 2 <>0)	{Verzeichnis}
     and (filename<>#0)
     and (filename<>#1)	{nicht . und ..}
  end;
 end;

function IsBadDirEnt(de:PDirEnt): Boolean;
 begin
  with de^ do begin
   IsBadDirEnt:=odd(r) or (ea<>0) or (r<Length(filename)+33);
  end;
 end;

procedure ShowRead;
 const
  dr: Integer=0;
 begin
  if verbosity=0 then exit;
  if not isatty(1) then exit;
  write(Drehstrich[dr],#13);
  dr:=(dr+1)mod 4;
 end;

type
 PScan=^TScan;
 TScan=object
  start_sec, start_len: LongInt;
  cur_len: LongInt;
  sec: PChar;
  de: PDirEnt;
  constructor Init(ssec,slen:LongInt);
  function Have_DirEnt:Boolean;
  procedure Rewind;
  function Next_DirEnt(wrap:Boolean):Boolean;
  function Suche_Datei(lookfor: LongInt):Boolean;
  function Suche_Vrz:Boolean;
  function Count_DirEnts:LongInt;
  function Locate_File(lbn:LongInt):PDirEnt;
  destructor Done;
 end;

constructor TScan.Init(ssec,slen:LongInt);
 begin
  start_sec:=ssec;
  start_len:=(slen+2047) and $7FFFF800;	{round up to whole sectors}
  sec:=MapBytes(ssec,slen);	{read in whole structure, we have lot space}
  ShowRead;
  Rewind;
 end;

function TScan.Have_DirEnt:Boolean;
{moves p to the next sector boundary if p points to a tail of a sector
 AND l is greater than 2048}
 var
  a: Word;
 begin
  if (de^.r=0) and (cur_len>2048) then begin
   a:=cur_len mod 2048;	{last 11 bits (sector size may change)}
   IncHP(PChar(de),a);		{move pointer forward}
   Dec(cur_len,a);		{decrease residual length}
  end;
  Have_DirEnt:=(cur_len<>0) and not IsBadDirEnt(de);
 end;

procedure TScan.Rewind;
 begin
  cur_len:=start_len;
  de:=PDirEnt(sec);		{rewind}
 end;

function TScan.Next_DirEnt(wrap:Boolean):Boolean;
{moves de to the next directory entry,
 and wraps to begin if end is reached}
 begin
  Next_DirEnt:=true;
  with de^ do begin
   IncHP(PChar(de),r);
   Dec(cur_len,r);
  end;
  if not Have_DirEnt then begin
   if wrap then Rewind
   else Next_DirEnt:=false;
  end;
 end;

function TScan.Suche_Datei(lookfor: LongInt):Boolean;
{seaches a file with "lookfor" sector in ss in round-robin manner}
 var
  sde: PDirEnt;	{Rundenspeicher}
 begin
  Suche_Datei:=false;
  sde:=de;
  repeat
   if (de^.bit_flags and 2 =0)	{sollte in der Regel sofort treffen!}
   and (de^.file_start_lbn[le]=lookfor)
   then begin
    Suche_Datei:=true;
    exit;
   end;
   Next_DirEnt(true);
  until sde=de;
 end;

function TScan.Suche_Vrz:Boolean;
{searches next directory in ss, round-robin}
 var
  sde: PDirEnt;	{Rundenspeicher}
 begin
  Suche_Vrz:=false;
  sde:=de;
  repeat
   if IsRegularDir(de^)
   then begin
    Suche_Vrz:=true;
    exit;
   end;
   Next_DirEnt(true);
  until sde=de;
 end;

function TScan.Count_DirEnts:LongInt;
{D: Counts files and subdirs in p separately
 O: LOWORD=number of files
    HIWORD=number of subdirs, not counting . and ..}
 var
  cnt: LongRec;
 begin
  cnt.lo:=0;
  cnt.hi:=Word(-2);
  repeat
   if de^.bit_flags and 2 =0
   then Inc(cnt.lo)
   else Inc(cnt.hi);
  until not Next_DirEnt(false);
  Rewind;
  Count_DirEnts:=LongInt(cnt);
 end;

function TScan.Locate_File(lbn:LongInt):PDirEnt;
{D: Searches for a file matching <lbn>, or first file if <lbn>=0
 O: matched DirEnt, nil when not found}
 begin
  Locate_File:=nil;
  repeat
   if (de^.bit_flags and 2 =0)
   and ((lbn=0) or (de^.file_start_lbn[le]=lbn)) then begin
    Locate_File:=de;
    Rewind;
    exit;
   end;
  until not Next_DirEnt(false);
  Rewind;
 end;

destructor TScan.Done;
 begin
  UnmapBytes(sec);	{free memory}
 end;


var
 Num_Links,SNum_Links: LongInt;
 LTab,STab: array[0..$0FFF] of LongInt; {link data (max. 32K)}

function InSTab(k:LongInt):Boolean;
{D: Checks whether <k> is already in STab}
 var
  i: Integer;
 begin
  InSTab:=false;
  for i:=0 to Num_Links-1 do begin
   if STab[i]=k then begin
    InSTab:=true;
    exit;
   end;
  end;
 end;

procedure DisplayMatch(lsec,ssec:LongInt;
  lname,sname:string; depth:Byte; const comment:string);
 begin
  if Verbosity<>0 then begin
   if 35-depth-length(lname)<0 then begin
    lname:=LeftStr(lname,35-depth-3)+'...';
   end;
   if 8-length(sname)<0 then begin
    sname:=LeftStr(sname,8-3)+'...';
   end;
   Write('':depth,lname,'':35-depth-length(lname),lsec:6,
      ' <=> ',sname,'':8-length(sname),ssec:7,' (',comment,')');
   if Verbosity>=2 then writeln else write('':15-length(comment),#13);
  end;
  LTab[Num_Links]:=lsec;
  STab[Num_Links]:=ssec;
  Inc(Num_Links);
 end;

function ByteSize:Byte;
{Determine the smallest number of bytes to hold the links.}
 var
  b:Byte;
  i:Integer;
  sec:LongInt;
 begin
  sec:=0;
  for i:=Num_Links-1 downto 0 do
   sec:=sec or LTab[i] or STab[i];
  if sec>$ffffff then
   b:=4
  else if sec>$ffff then
   b:=3
  else if sec>$ff then
   b:=2
  else
   b:=1;
  ByteSize:=b;
end;

procedure CheckOrder(var ls,ss:TScan);
{Works with the logic of present (for files) and future (for dirs) DOSLFN}
 var
  i:Integer;
  l:LongInt;
 begin
  ls.Rewind;
  ss.Rewind;
  repeat
   l:=ls.de^.file_start_lbn[le];
   if ls.de^.bit_flags and 2 <>0 then begin
    if IsRegularDir(ls.de^) then begin
     ss.Suche_Vrz;	{simply take the next directory}
     for i:=Num_Links-1 downto 0 do
     if LTab[i]=l then begin
      if STab[i]<>ss.de^.file_start_lbn[le] then begin
       sameorder:=false;
       exit;
      end;
      break;
     end;	{with correct program logic, the loop must always find a hit}
    end;
   end else begin
    ss.Suche_Datei(l);	{should never return FALSE}
   end;
   ss.Next_DirEnt(true);
  until not ls.Next_DirEnt(false);
  exit;
 end;

procedure MakeLDirList(lsec,llen:LongInt; const lname:String; depth:Byte);
 var
  ls: TScan;		{object for scanning Joliet directory}
 begin
  WriteLn(lsec:7,'':depth,lname);
  LTab[Num_Links]:=lsec;
  Inc(Num_Links);
  ls.Init(lsec,llen);	{read entire LFN directory}
  repeat
   if IsRegularDir(ls.de^) then begin
    UnUnicode(ls.de^.filename);
    MakeLDirList(ls.de^.file_start_lbn[le],ls.de^.file_size_byte[le],
		 ls.de^.filename,depth+1);
   end
  until not ls.Next_DirEnt(false);
  ls.done;
 end;

procedure MakeSDirList(ssec,slen:LongInt; const sname:String; depth:Byte);
 var
  ss: TScan;		{object for scanning ISO directory}
 begin
  WriteLn(ssec:7,'':depth,sname);
  STab[SNum_Links]:=ssec;
  Inc(SNum_Links);
  ss.Init(ssec,slen);	{read entire SFN directory, prepare search}
  repeat
   if IsRegularDir(ss.de^) then
    MakeSDirList(ss.de^.file_start_lbn[le],ss.de^.file_size_byte[le],
		 ss.de^.filename,depth+1);
  until not ss.Next_DirEnt(false);
  ss.done;
 end;

function MakeDirLink(lsec,llen,ssec,slen:LongInt;
  const lname,sname:string; depth, ldetect:Byte):Byte;
{possible return values:
 * 0 = Empty directory (this may be propagated)
 * 1 = No Match (sure)
 * 255 = Match (sure)
 * graduated "don't know exactly": all values between 2 and 254}
 label exi;
 var
  sde: PDirEnt;
  ls,ss: TScan;		{two objects for scanning Joliet and ISO directory}
  lcount,scount:LongInt;	{counter for directories and files}
  len:byte;
 begin
  ls.Init(lsec,llen);	{read entire LFN directory}
  ss.Init(ssec,slen);	{read entire SFN directory, prepare search}
  lcount:=ls.Count_DirEnts;
  scount:=ss.Count_DirEnts;
  if ldetect=255 then begin
   DisplayMatch(lsec,ssec,lname,sname,depth,'known');
   if lcount=0 then goto exi;	{return immediately if CD is completely empty}
  end else begin
   {Check #1: Number of directories and files must be the same}
   if lcount<>scount then begin
    if (LongRec(scount).hi=0) and (LongRec(lcount).hi<>0) and
       (LongRec(scount).lo<>LongRec(lcount).hi+LongRec(lcount).lo) then begin
     ldetect:=1;
     goto exi;
    end;
   end;
   {Check #2: If there is no DirEnt at all, it is an empty directory.
    Because empty dir is an empty dir, eventually wrong linkage
    due to wrong order does not bother. Return 0}
   if lcount=0 then begin
    len:=length(sname);
    if len>length(lname) then
     len:=length(lname);
    if strlicomp(PChar(addr(lname))+1,PChar(addr(sname))+1,len)=0 then begin
     DisplayMatch(lsec,ssec,lname,sname,depth,'EMPTY');
     ldetect:=255;
    end else
     ldetect:=1;
    goto exi;
   end;
   {Check #3: If there are files, there must exist direct companions.
    Only one file is checked here; if matching, MakeDirLink return 255}
   if LongRec(lcount).lo<>0 then begin
    sde:=ls.Locate_File(0);{return NIL is internal error}
    if ss.Locate_File(sde^.file_start_lbn[le])<>nil then begin
     ldetect:=255;		{A match is now sure}
     DisplayMatch(lsec,ssec,lname,sname,depth,'file inside');
    end else begin
     ldetect:=1;
     goto exi;
    end;
   end;
  end;
  {Check #4: If there is no subtree, return with ldetect, which
   must be 255 when no subtree is there due to program logic.}
  if LongRec(lcount).hi=0 then goto exi;
  {Check #5 and recursion: Do with all subdirs, but propagate 1}
  if ldetect=0 then ldetect:=1;
  repeat
   if IsRegularDir(ls.de^) then begin
    UnUnicode(ls.de^.filename);	{needed for display and sorting}
    ss.Suche_Vrz;		{seek to first (or next) DirEnt}
    sde:=ss.de;			{start round-robin search}
    repeat
{For speed, SFN directories that are already in the list should not
 scanned again}
     if not InSTab(ss.de^.file_start_lbn[le])
     then case MakeDirLink(
       ls.de^.file_start_lbn[le],ls.de^.file_size_byte[le],
       ss.de^.file_start_lbn[le],ss.de^.file_size_byte[le],
       ls.de^.filename,
       ss.de^.filename,
       depth+1,0) of
      0: begin
       if ldetect<>255 then ldetect:=0;
       break;		{silence on empty subtrees}
      end;
      255: begin	{Callee has a match}
{If we had no match from files, now we can match due to matching subtree.
 The inner loop can be exited}
       if ldetect<>255 then begin
	DisplayMatch(lsec,ssec,lname,sname,depth,'subtree');
	ldetect:=255;
       end;
       break;		{exit search loop, subtree had given out the match}
      end;
     end{case};
     ss.Next_DirEnt(true);
     ss.Suche_Vrz;
    until sde=ss.de;
   end;
   ss.Next_DirEnt(true);
  until not ls.Next_DirEnt(false);
  if ldetect=0 then begin
   DisplayMatch(lsec,ssec,lname,sname,depth,'EMPTY subtree');
  end;
exi:
  if (ldetect=255) and sameorder then CheckOrder(ls,ss);
  ss.Done;
  ls.Done;
  MakeDirLink:=ldetect;
 end;


type
 PVolDesc=^TVolDesc;
 TVolDesc=record
  id: array[0..7] of Char;	{#n'CD001'#1#0, n=1,2,255}
  system_id: array[0..31] of Char;
  volume_id: array[0..31] of Char;
  zero1: array[0..7] of Byte;
  total_sec_number: bedw;
  joliet_id: array[0..31] of Char;
  volume_set_size: bew;		{1}
  volume_sequence_number: bew;	{1}
  sector_size: bew;		{2048}
  path_table_length: bedw;
  le_path_table_sec: LongInt;
  le_path_table_2_sec: LongInt;
  be_path_table_sec: LongInt;
  be_path_table_2_sec: LongInt;
  root_directory_record: TDirEnt;	{array[0..33] of Byte}
  volume_set_id:	array[0..127] of Char;
  publisher_id:		array[0..127] of Char;
  data_preparer_id:	array[0..127] of Char;
  application_id:	array[0..127] of Char;
  copyright_file_id:	array[0..36] of Char;
  abstract_file_id:	array[0..36] of Char;
  bibliographical_file_id: array[0..36] of Char;
  time_creation:	array[0..16] of Char;
  time_modification:	array[0..16] of Char;
  time_expire:		array[0..16] of Char;
  time_effective:	array[0..16] of Char;
 end;

type
 PVD_info=^TVD_info;
 TVD_info=record
  dir_sec, dir_len:  LongInt;
 end;

procedure ScanVDInfo(sec:PChar; var vd: TVD_Info);
 begin
  with PVolDesc(sec)^.root_Directory_record do begin
   vd.dir_sec:=file_start_lbn[le];
   vd.dir_len:=file_size_byte[le];
  end;
 end;

function MkVSN(sec:PChar):NameStr;
{Make the Volume Serial Number the same as Win32 (as found in 98SE)}
 const
  hex: array[0..15] of Char='0123456789ABCDEF';
 var
  vsn: LongInt;
  i: Integer;
  h: array[0..8] of Char;
 begin
  vsn:=0;
  for i:=0 to 511 do begin	{2048/4}
   Inc(WordRec(LongRec(vsn).lo).lo,PByte(sec)^);
   Inc(WordRec(LongRec(vsn).lo).hi,PByte(sec+1)^);
   Inc(WordRec(LongRec(vsn).hi).lo,PByte(sec+2)^);
   Inc(WordRec(LongRec(vsn).hi).hi,PByte(sec+3)^);
   Inc(sec,4);
  end;
  for i:=7 downto 0 do begin
   h[i]:=hex[Byte(vsn) and $0f];
   vsn:=vsn shr 4;
  end;
  MkVSN:=StrPas(h);
 end;

function TrimRight(S:PChar; l:Integer):String;
{Assumes that S has l characters, leaves S right trimmed}
 var
  i: Integer;
 begin
  for i:=l-1 downto 0 do begin
   if s[i] in [#0,' '] then s[i]:=#0 else break;
  end;
  TrimRight:=StrPas(S);
 end;

const
 jlt_id:array[0..3] of Char='JLT1';
 link_id:array[0..37] of Char='CeQuadrat Joliet directory link table';
var
 link_data:PLongInt;	{points to a copy of table above, for comparing}

function TablesEqual:Boolean;
{compares <link_data> (found as CeQuadrat table on CD) against
 found values in Num_Links, STab, and LTab}
 label w;
 var
  ldp: PLongInt;
  i,j: Integer;
  s,l: LongInt;
 begin
  TablesEqual:=false;
  ldp:=link_data;
  if ldp^<>Num_Links then exit; {trivial root sectors are included}
  Inc(ldp);
  for i:=0 to Num_Links-1 do begin
   l:=ldp^; Inc(ldp);
   s:=ldp^; Inc(ldp);
   for j:=0 to Num_Links-1 do begin
    if s=STab[j] then begin	{found corresponding}
     if l=LTab[j] then goto w	{equal, next in outer loop}
     else exit;			{not equal, return with FALSE}
    end;
   end;
w:end;
  TablesEqual:=true;
 end;

const
 ByteCode: array[0..7] of Byte=(
  $f2,$ae,			{	repne	scasb	      }
  $75,$03,			{	jne	@@be	      }
  $8a,$41,$ff,			{	mov	al,[di+bx-1]  }
  $c3); 			{@@be:	ret		      }
 ByteCodeSize=8;

 WordCode: array[0..7] of Byte=(
  $f2,$af,			{	repne	scasw	      }
  $75,$03,			{	jne	@@we	      }
  $8b,$41,$fe,			{	mov	ax,[di+bx-2]  }
  $c3); 			{@@we:	ret		      }
 WordCodeSize=8;

 TripleCode: array[0..28] of Byte=(
  $66,$50,			{@@tl:	push	eax	      }
  $5A,				{	pop	dx	      }
  $5A,				{	pop	dx	      }
  $39,$05,			{@@tc:	cmp	[di],ax       }
  $74,$07,			{	je	@@tlf	      }
  $83,$C7,$03,			{@@tn:	add	di,3	      }
  $49,				{	dec	cx	      }
  $75,$F6,			{	jnz	@@tc	      }
  $C3,				{	ret		      }
  $38,$55,$02,			{@@tlf: cmp	[di+2],dl     }
  $75,$F4,			{	jne	@@tn	      }
  $8A,$51,$02,			{	mov	dl,[di+2+bx]  }
  $52,				{	push	dx	      }
  $FF,$31,			{	push	[wo di+bx]    }
  $66,$58,			{	pop	eax	      }
  $C3); 			{	ret		      }
 TripleCodeSize=29;

 DWordCode: array[0..9] of Byte=(
  $f2,$66,$af,			{	repne	scasd	      }
  $75,$04,			{	jne	@@dwe	      }
  $66,$8b,$41,$fc,		{	mov	eax,[di+bx-4] }
  $c3); 			{@@dwe: ret		      }
 DWordCodeSize=10;


function ProcessDrive(d:Char):Boolean;
 label nx,fe,eject,exi;		{skip eject exit}
 type
  Apres=(_PVD,_SVD,_TVD,_LinkTable);
 var
  sec: PChar;			{on heap to preserve stack}
  present: set of Apres;
  i: Integer;
  tic: Word;
  VolStart,l: LongInt;
  lrec: LongRec absolute l;
  ldptr: PLongInt;
  secidx: Integer;
  vsn: namestr;
  Time,VTime,FTime: LongInt;
  lvol,svol: string[32];	{CD volume strings}
  pvd,svd: TVD_Info;
  f: File;
  ptr:PChar;
 begin
  ProcessDrive:=false;
  asciidrv:=d;
  drv:=Ord(d)-Ord('A');		{set global variables}
  if batchmode then CD_WaitForClose;
  Write('Drive ',d,': '); Flush(output);
  present:=[];
  tic:=timer;
  VolStart:=DetermineVolStart;
  if VolStart<0 then begin
   WriteLn('SKIP: No data tracks found');
   goto exi;
  end;
  GetMem(sec,2048);
  for i:=0 to 10 do begin
   if not ReadSectors(sec,1,VolStart+16+i) then begin
    WriteLn('SKIP: Cannot read VTOC #',i);
    FreeMem(sec,2048);
    goto exi;
   end;
   if StrLComp(sec+1,'CD001'#1,6)<>0 then begin
    WriteLn('SKIP: Wrong Volume Descriptor at #',i);
    goto fe;
   end;
   case sec[0] of
    #1: begin
     Include(present,_PVD);
     svol:=TrimRight(PVolDesc(sec)^.volume_id,32);
     ScanVDInfo(sec,pvd);
     Time_CD2FAT(PVolDesc(sec)^.root_directory_record,Time);
     if PVolDesc(sec)^.time_modification[0]<>'0'	{given?}
     then Time_Ascii2FAT(PVolDesc(sec)^.time_modification,VTime)
     else VTime:=Time;		{they should be equal in any case}
    end;
    #2: if (PWord(sec+88)^=$2F25)		{'%/'}
     and (sec[90] in ['@','C','E']) then begin	{Joliet signature}
     vsn:=MkVSN(sec);
     ScanVDInfo(sec,svd);
     ununi(PVolDesc(sec)^.volume_id,PWord(@PVolDesc(sec)^.volume_id),16);
     lvol:=TrimRight(PVolDesc(sec)^.volume_id,16);
     Include(present,_SVD);
    end;
    #255: begin
     Include(present,_TVD);
     break;			{leave "for" loop}
    end;
   end;
  end;
  Inc(i);
  if present<>[_PVD.._TVD] then begin
   WriteLn('SKIP: No valid Joliet Descriptor found');
   goto fe;
  end;
  ReadSectors(sec,1,VolStart+16+i);
  if strcomp(sec,link_id)=0 then begin
   if not ForceMode and (VolStart=0) then begin
    WriteLn('SKIP: Found "',link_id,'", check with /f');
    goto fe;
   end;
   l:=PLongInt(sec+$2C)^;
   if l>$0FFF then begin	{should fit in 32K}
    WriteLn('WARNING: found a too long "',link_id,'" with ',l,' entries');
   end else begin
    lrec.hi:=4+l*8;		{memory usage}
    link_data:=GlobalAllocPtr(0,lrec.hi);
    secidx:=$2C;		{data follows from there}
    ldptr:=link_data;
    repeat
     lrec.lo:=2048-secidx;	{get length in this sector}
     if lrec.lo>lrec.hi then lrec.lo:=lrec.hi;	{limit length}
     Move(sec[secidx],ldptr^,lrec.lo);		{copy bytes}
     Inc(PChar(ldptr),lrec.lo);	{increment destination ptr}
     Dec(lrec.hi,lrec.lo);	{decrement residual length}
     if lrec.hi=0 then break;	{all done}
     Inc(i);			{read next link data sector}
     ReadSectors(sec,1,VolStart+16+i);
     secidx:=0;			{take whole sector}
    until false;
   end;
  end;
  if not manual or manualw then begin
   Assign(f,vsn+'.JLT');        {.JLT stands for Joliet Link Table}
   if not ForceMode then begin	{don't look for CeQuadrat and present file}
    {$I-}Reset(f,1);{$I+}
    if IOResult=0 then begin
     GetFTime(f,FTime);
     Close(f);
     if VTime=FTime then begin
      WriteLn('SKIP: link table ',FileRec(f).name,' already present');
      goto fe;
     end else if verbosity>=2 then begin
      WriteLn('INFO: link table ',FileRec(f).name,' present, but out of date');
     end;
    end;
   end;
  end;
  FreeMem(sec,2048);
	{now: action!}
  sameorder:=true;
  Num_Links:=0;
  SNum_Links:=0;
  if not manual then begin
   writeln('Joliet_Name','LBN':21,' <=> ISO_Name    LBN (link_reason)');
   MakeDirLink(svd.dir_sec,svd.dir_len,pvd.dir_sec,pvd.dir_len,
     lvol,svol,1,255);
  end else begin
   if not manualw then begin
    WriteLn(#13#10,'LBN':7,' Joliet_Name');
    MakeLDirList(svd.dir_sec,svd.dir_len,lvol,1);
    WriteLn(#13#10,'LBN':7,' ISO_Name');
    MakeSDirList(pvd.dir_sec,pvd.dir_len,svol,1);
   end else begin
    ReadLn;				{skip Drive}
    ReadLn;				{skip Joliet_Name}
    {$I-}
    repeat
     ReadLn(LTab[Num_Links]);
     if IOResult<>0 then break;		{found ISO_Name}
     Inc(Num_Links);
    until false;
    ReadLn;				{skip ISO_Name}
    repeat
     ReadLn(STab[SNum_Links]);
     if IOResult<>0 then break;		{found link count}
     Inc(SNum_Links);
    until false;
    {I+}
    if Num_Links<>SNum_Links then begin
     WriteLn('Links disagree! Joliet: ',Num_Links,' ISO: ',SNum_Links);
     RunError(224);
    end;
   end;
  end;
  if (verbosity=1) and not manual then write(#13:79);   {79 spaces and CR}
  if comparing then begin
   Write('INFO: ISO and Joliet trees have ');
   if sameorder
   then WriteLn('same order.')
   else WriteLn('DIFFERENT order! DOSLFN needs a .JLT file.');
  end;
	{now save the result}
  write('Found ',Num_Links,' links');
  if manual and (SNum_Links<>Num_Links) then
   write(' and ',SNum_Links,' short links');
  tic:=toc(tic) div 18;
  case tic of
   0:;				{do nothing}
   1: Write(' in one second');
   else Write(' in ',tic,' seconds');
  end;
  if link_data<>nil then begin
   if TablesEqual then begin
    Write(', ignore same table on CD');
   end else begin
    WriteLn(', found DIFFERENT VERSION of (yet ignored)');
    Write('"',link_id,'"');
   end;
  end;
  if not manual or manualw then begin
   write(', now writing ',FileRec(f).name);
   l:=ByteSize;
   case l of
    1: begin sec:=PChar(@ByteCode); tic:=ByteCodeSize; end;
    2: begin sec:=PChar(@WordCode); tic:=WordCodeSize; end;
    3: begin sec:=PChar(@TripleCode); tic:=TripleCodeSize; end;
    4: begin sec:=PChar(@DWordCode); tic:=DWordCodeSize; end;
   end;
   SNum_Links:=Num_Links*l;
   {$I-}
   Rewrite(f,1); 		{all bytes}
   lvol:=lvol+#13#10#26; 	{write the volume label and CRLF+EOF}
   ptr:=PChar(addr(lvol))+1;	{ to use TYPE to identify the file}
   FillChar((ptr+length(lvol))^,35-length(lvol),#0);
   BlockWrite(f,ptr^,35);
   BlockWrite(f,jlt_id,4);	{35: DWord: signature, for safety}
   i:=SNum_Links*2+tic;
   BlockWrite(f,i,2);		{39: Word: size to load}
   BlockWrite(f,Num_Links,2);	{41: Word: number of links}
   BlockWrite(f,SNum_Links,2);	{43: Word: size of links}
   for i:=0 to Num_Links-1 do	{45:	   ISO directory sectors}
    BlockWrite(f,STab[i],l);
   for i:=0 to Num_Links-1 do	{45+[43]:  Joliet directory sectors}
    BlockWrite(f,LTab[i],l);
   BlockWrite(f,sec^,tic);	{45+2*[43]:Code to scan table}
   SetFTime(f,VTime);
   Close(f);
   {$I+}
   if IOResult<>0 then begin
    WriteLn;
    Write('ERROR: cannot write data to file ',FileRec(f).name);
   end;
  end;
nx:
  WriteLn;
  goto eject;
fe:
  FreeMem(sec,2048);
eject:
  if link_data<>nil then begin
   GlobalFreePtr(link_data);
   link_data:=nil;
  end;
exi:
  if batchmode then CD_Eject;
 end;

var
 drvs: array[0..26] of Char;	{MSCDEX drive letter list}

procedure setdrv; assembler;
 asm	mov	bx,0
	mov	ax,1500h
	int	2fh
	push	bx		{save count}
{$IFDEF DPMI}
	 mov	ax,150Dh	{get drive assignment list}
	 mov	bx,offset drvs
	 push	ds
	 push	bx
	 push	TYPE drvs
	 call	call2F
{$ELSE}
	 push	ds
	 pop	es
	 mov	bx,offset drvs
	 mov	ax,150Dh
	 int	2Fh
{$ENDIF}
	pop	cx
@@l:	add	byte ptr [bx],'A'	{make letters}
	inc	bx
	loop	@@l
	mov	byte ptr [bx],0		{terminate list}
 end;

procedure Usage;
 begin
  WriteLn('MKLINK reads all Joliet CDs and creates Link Tables for use with DOSLFN');
  WriteLn('Options: /? Get Help, /f force mode, /v more verbose, /v- less verbose');
  WriteLn(#9' /b batch process (ejects CD, continues after inserting another CD)');
  WriteLn(#9' /c compare order of ISO and Joliet tree leaves in means of DOSLFN');
  WriteLn(#9' /m manually create the links (writes to stdout, reads from stdin)');
  WriteLn('Normal letters are drive letters to scan for (with or without colon :)');
  WriteLn({$IFDEF DPMI}'DPMI compilation! '+{$ENDIF}'haftmann#software & Jason Hood, Freeware 10/03');
  halt;
 end;

var
 sp,spa: PChar;
 i: integer;
 arg: array[0..7] of Char;
 newdrvs: array[0..26] of Char;
begin
 FileMode:=0;
 verbosity:=1;
{$IFDEF DPMI}
 RMBuffer:=GlobalDosAlloc(2048);
{$ENDIF}
 SetDrv;
 sp:=newdrvs;
 for i:=1 to GetArgCount do begin
  GetArgStr(arg,i,sizeof(arg));
  StrUpper(arg);
  spa:=arg;
  case spa^ of
   '-','/': repeat
    Inc(spa);
    case spa^ of
     'V': case spa[1] of
      '-': begin Dec(verbosity); Inc(spa); end;
      else Inc(verbosity);
     end;
     'F': forcemode:=true;
     'B': batchmode:=true;
     'C': comparing:=true;
     'M': begin manual:=true; manualw:=not isatty(0); end;
     #0:  break;			{exit the REPEAT-UNTIL loop}
     else Usage;			{wrong or -h parameter given}
    end;
   until false;
   'A'..'Z': repeat
    if (not forcemode) and (StrScan(drvs,spa^)=nil) then begin
     WriteLn('Drive ',arg[0],': is not a CDROM drive, ignoring it');
    end else begin
     sp^:=spa^; Inc(sp);
    end;
    Inc(spa);
    if spa^=':' then Inc(spa);
    if not (spa^ in [#0,'A'..'Z']) then Usage;	{letters must follow}
   until spa^=#0;
   else Usage;
  end;
 end;
 if sp<>newdrvs then StrCopy(drvs,newdrvs);	{copy user preference}

 LoadUni;
 PrepareDBCS;

 multiple:=StrLen(drvs)>1;
 repeat
  sp:=drvs;
  while sp^<>#0 do begin
   ProcessDrive(sp^);
   Inc(sp);
  end;
 until not batchmode;
{$IFDEF DPMI}
 GlobalDosFree(LongRec(RMBuffer).lo);
{$ENDIF}
end.

(*
		   ISO9660 Simplified for DOS/Windows

			 by Philip J. Erdelsky
		       75746.3411@compuserve.com
		   http://www.alumni.caltech.edu/~pje/

1. Introduction

We weren't sure about it a few years ago, but by now it should be clear
to everyone that CD-ROM's are here to stay. Most PC's are equipped with
CD-ROM readers, and most major PC software packages are being
distributed on CD-ROM's.

Under DOS (and Windows, which uses the DOS file system) files are
written to both hard and floppy disks with a so-called FAT (File
Allocation Table) file system.

Files on a CD-ROM, however, are written to a different standard, called
ISO9660. ISO9660 is rather complex and poorly written, and obviously
contains a number of diplomatic compromises among advocates of DOS,
UNIX, MVS and perhaps other operating systems.

The simplified version presented here includes only features that would
normally be found on a CD-ROM to be used in a DOS system and which are
supported by the Microsoft MS-DOS CD-ROM Extensions (MSCDEX). It is
based on ISO9660, on certain documents regarding MSCDEX (version 2.10),
and on the contents of some actual CD-ROM's.

Where a field has a specific value on a CD-ROM to be used with DOS, that
value is given in this document. However, in some cases a brief
description of values for use with other operating systems is given in
square brackets.

ISO9660 makes provisions for sets of CD-ROM's, and apparently even
permits a file system to span more than one CD-ROM. However, this
feature is not supported by MSCDEX.


3. Files

The directory structure on a CD-ROM is almost exactly like that on a DOS
floppy or hard disk. (It is presumed that the reader of this document is
reasonably familiar with the DOS file system.) For this reason, DOS and
Windows applications can read files from a CD-ROM just as they would
from a floppy or hard disk.

There are only a few differences, which do not affect most applications:

     (1) The root directory contains the notorious "." and ".." entries,
	 just like any other directory.

     (2) There is no limit, other than disk capacity, to the size of the
	 root directory.

     (3) The depth of directory nesting is limited to eight levels,
	 including the root. For example, if drive E: contains a CD-ROM,
	 a file such as E:\D2\D3\D4\D5\D6\D7\D8\FOO.TXT is permitted but
	 E:\D2\D3\D4\D5\D6\D7\D8\D9\FOO.TXT is not.

     (4) If a CD-ROM is to be used by a DOS system, file names and
	 extensions must be limited to eight and three characters,
	 respectively, even though ISO9660 permits longer names and
	 extensions.

     (5) ISO9660 permits only capital letters, digits and underscores in
	 a file or directory name or extension, but DOS also permits a
	 number of other punctuation marks.

     (6) ISO9660 permits a file to have an extension but not a name, but
	 DOS does not.

     (7) DOS permits a directory to have an extension, but ISO9660 does
	 not.

     (8) Directories on a CD-ROM are always sorted, as described below.

Of course, neither DOS, nor UNIX, nor any other operating system can
WRITE files to a CD-ROM as it would to a floppy or hard disk, because a
CD-ROM is not rewritable. Files must be written to the CD-ROM by a
special program with special hardware.


4. Sectors

The information on a CD-ROM is divided into sectors, which are numbered
consecutively, starting with zero. There are no gaps in the numbering.

Each sector contains 2048 8-bit bytes. (ISO9660 apparently permits other
sector sizes, but the 2048-byte size seems to be universal.)

When a number of sectors are to be read from the CD-ROM, they should be
read in order of increasing sector number, if possible, since that is
the order in which they pass under the read head as the CD-ROM rotates.
Most implementations arrange the information so sectors will be read in
this order for typical file operations, although ISO9660 does not
require this in all cases.

The order of bytes within a sector is considered to be the order in
which they appear when read into memory; i.e., the "first" bytes are
read into the lowest memory addresses. This is also the order used in
this document; i.e., the "first" bytes in any list appear at the top of
the list.


5. Character Sets

Names and extensions of files and directories, the volume name, and some
other names are expressed in standard ASCII character codes (although
ISO9660 does not use the name ASCII). According to ISO9660, only capital
letters, digits, and underscores are permitted. However, DOS permits
some other punctuation marks, which are sometimes found on CD-ROM's, in
apparent defiance of ISO9660.

MSCDEX does offer support for the kanji (Japanese) character set.
However, this document does not cover kanji.


6. Sorting Names or Extensions

Where ISO9660 requires file or directory names or extensions to be
sorted, the usual ASCII collating sequence is used. That is, two
different names or extensions are compared as follows:

     (1) ASCII blanks (32) are added to the right end of the shorter
	 name or extension, if necessary, to make it as long as the
	 longer name or extension.

     (2) The first (leftmost) position in which the names or extensions
	 are not identical determines the order. The name or extension
	 with the lower ASCII code in that position appears first in the
	 sorted order.


7. Multiple-Byte Values

A 16-bit numeric value (usually called a word) may be represented on a
CD-ROM in any of three ways:

     Little Endian Word: The value occupies two consecutive bytes, with
       the less significant byte first.

     Big Endian Word: The value occupies two consecutive bytes, with
       the more significant byte first.

     Both Endian Word: The value occupies FOUR consecutive bytes; the
       first and second bytes contain the value expressed as a little
       endian word, and the third and fourth bytes contain the same
       value expressed as a big endian word.

A 32-bit numeric value (usually called a double word) may be represented
on a CD-ROM in any of three ways:

     Little Endian Double Word: The value occupies four consecutive
       bytes, with the least significant byte first and the other bytes
       in order of increasing significance.

     Big Endian Double Word: The value occupies four consecutive bytes,
       with the most significant first and the other bytes in order of
       decreasing significance.

     Both Endian Double Word: The value occupies EIGHT consecutive
       bytes; the first four bytes contain the value expressed as a
       little endian double word, and the last four bytes contain the
       same value expressed as a big endian double word.


8. The First Sixteen Sectors are Empty

The first sixteen sectors (sector numbers 0 to 15, inclusive) contain
nothing but zeros. ISO9660 does not define the contents of these
sectors, but for DOS they are apparently always written as zeros.
They are apparently reserved for use by systems that can be booted from
a CD-ROM.


9. The Volume Descriptors

Sector 16 and a few of the following sectors contain a series of volume
descriptors. There are several kinds of volume descriptor, but only two
are normally used with DOS. Each volume descriptor occupies exactly one
sector.

The last volume descriptors in the series are one or more Volume
Descriptor Set Terminators. The first seven bytes of a Volume Descriptor
Set Terminator are 255, 67, 68, 48, 48, 49 and 1, respectively. The
other 2041 bytes are zeros. (The middle bytes are the ASCII codes for
the characters CD001.)

The only volume descriptor of real interest under DOS is the Primary
Volume Descriptor. There must be at least one, and there is usually only
one. However, some CD-ROM's have two or more identical Primary Volume
Descriptors. The contents of a Primary Volume Descriptor are as follows:

     length
     in bytes  contents
     --------  ---------------------------------------------------------
        1      1
	6      67, 68, 48, 48, 49 and 1, respectively (same as Volume
                 Descriptor Set Terminator)
        1      0
       32      system identifier
       32      volume identifier
        8      zeros
        8      total number of sectors, as a both endian double word
       32      zeros
        4      1, as a both endian word [volume set size]
        4      1, as a both endian word [volume sequence number]
        4      2048 (the sector size), as a both endian word
	8      path table length in bytes, as a both endian double word
	4      number of first sector in first little endian path table,
		 as a little endian double word
	4      number of first sector in second little endian path table,
		 as a little endian double word, or zero if there is no
		 second little endian path table
	4      number of first sector in first big endian path table,
		 as a big endian double word
	4      number of first sector in second big endian path table,
		 as a big endian double word, or zero if there is no
		 second big endian path table
       34      root directory record, as described below
      128      volume set identifier
      128      publisher identifier
      128      data preparer identifier
      128      application identifier
       37      copyright file identifier
       37      abstract file identifier
       37      bibliographical file identifier
       17      date and time of volume creation
       17      date and time of most recent modification
       17      date and time when volume expires
       17      date and time when volume is effective
        1      1
        1      0
      512      reserved for application use (usually zeros)
      653      zeros

The first 11 characters of the volume identifier are returned as
the volume identifier by standard DOS system calls and utilities.

Other identifiers are not used by DOS, and may be filled with ASCII
blanks (32).

Each date and time field is of the following form:

     length
     in bytes  contents
     --------  ---------------------------------------------------------
	4      year, as four ASCII digits
	2      month, as two ASCII digits, where
		 01=January, 02=February, etc.
	2      day of month, as two ASCII digits, in the range
		 from 01 to 31
	2      hour, as two ASCII digits, in the range from 00 to 23
	2      minute, as two ASCII digits, in the range from 00 to 59
	2      second, as two ASCII digits, in the range from 00 to 59
	2      hundredths of a second, as two ASCII digits, in the range
		 from 00 to 99
	1      offset from Greenwich Mean Time, in 15-minute intervals,
		 as a twos complement signed number, positive for time
		 zones east of Greenwich, and negative for time zones
		 west of Greenwich

If the date and time are not specified, the first 16 bytes are all ASCII
zeros (48), and the last byte is zero.

Other kinds of Volume Descriptors (which are normally ignored by DOS)
have the following format:

     length
     in bytes  contents
     --------  ---------------------------------------------------------
        1      neither 1 nor 255
	6      67, 68, 48, 48, 49 and 1, respectively (same as Volume
                 Descriptor Set Terminator)
      2041     other things


10. Path Tables

The path tables normally come right after the volume descriptors.
However, ISO9660 merely requires that each path table begin in the
sector specified by the Primary Volume Descriptor.

The path tables are actually redundant, since all of the information
contained in them is also stored elsewhere on the CD-ROM. However, their
use can make directory searches much faster.

There are two kinds of path table -- a little endian path table, in
which multiple-byte values are stored in little endian order, and a big
endian path table, in which multiple-byte values are stored in big
endian order. The two kinds of path tables are identical in every other
way.

A path table contains one record for each directory on the CD-ROM
(including the root directory). The format of a record is as follows:

     length
     in bytes  contents
     --------  ---------------------------------------------------------
	1      N, the name length (or 1 for the root directory)
	1      0 [number of sectors in extended attribute record]
	4      number of the first sector in the directory, as a
		 double word
	2      number of record for parent directory (or 1 for the root
		 directory), as a word; the first record is number 1,
		 the second record is number 2, etc.
	N      name (or 0 for the root directory)
      0 or 1   padding byte: if N is odd, this field contains a zero; if
		 N is even, this field is omitted

According to ISO9660, a directory name consists of at least one and not
more than 31 capital letters, digits and underscores. For DOS the upper
limit is eight characters.

A path table occupies as many consecutive sectors as may be required to
hold all its records. The first record always begins in the first byte
of the first sector. Except for the single byte described above, no
padding is used between records; hence the last record in a sector is
usually continued in the next following sector. The unused part of the
last sector is filled with zeros.

The records in a path table are arranged in a precisely specified order.
For this purpose, each directory has an associated number called its
level. The level of the root directory is 1. The level of each other
directory is one greater than the level of its parent. As noted above,
ISO9660 does not permit levels greater than 8.

The relative positions of any two records are determined as follows:

     (1) If the levels are different, the directory with the lower level
	 appears first. In particular, this implies that the root
         directory is always represented by the first record in the
	 table, because it is the only directory with level 1.

     (2) If the levels are identical, but the directories have different
         parents, then the directories are in the same relative
         positions as their parents.

     (3) Directories with the same level and the same parent are
         arranged in the order obtained by sorting on their names, as
         described in Section 6.


11. Directories

A directory consists of a series of directory records in one or more
consecutive sectors. However, unlike path records, directory records may
not straddle sector boundaries. There may be unused space at the end of
each sector, which is filled with zeros.

Each directory record represents a file or directory. Its format is as
follows:

     length
     in bytes  contents
     --------  ---------------------------------------------------------
	1      R, the number of bytes in the record (which must be even)
	1      0 [number of sectors in extended attribute record]
	8      number of the first sector of file data or directory
		 (zero for an empty file), as a both endian double word
	8      number of bytes of file data or length of directory,
		 excluding the extended attribute record,
		 as a both endian double word
	1      number of years since 1900
	1      month, where 1=January, 2=February, etc.
	1      day of month, in the range from 1 to 31
	1      hour, in the range from 0 to 23
	1      minute, in the range from 0 to 59
	1      second, in the range from 0 to 59
		 (for DOS this is always an even number)
	1      offset from Greenwich Mean Time, in 15-minute intervals,
		 as a twos complement signed number, positive for time
		 zones east of Greenwich, and negative for time zones
		 west of Greenwich (DOS ignores this field)
	1      flags, with bits as follows:
		 bit     value
		 ------  ------------------------------------------
		 0 (LS)  0 for a norma1 file, 1 for a hidden file
		 1       0 for a file, 1 for a directory
		 2       0 [1 for an associated file]
		 3       0 [1 for record format specified]
		 4       0 [1 for permissions specified]
		 5       0
		 6       0
		 7 (MS)  0 [1 if not the final record for the file]
	1      0 [file unit size for an interleaved file]
	1      0 [interleave gap size for an interleaved file]
	4      1, as a both endian word [volume sequence number]
	1      N, the identifier length
	N      identifier
	P      padding byte: if N is even, P = 1 and this field contains
		 a zero; if N is odd, P = 0 and this field is omitted
    R-33-N-P   unspecified field for system use; must contain an even
		 number of bytes

The length of a directory includes the unused space, if any, at the ends
of sectors. Hence it is always an exact multiple of 2048 (the sector
size). Since every directory, even a nominally empty one, contains at
least two records, the length of a directory is never zero.

All fields in the first record (sometimes called the "." record) refer
to the directory itself, except that the identifier length is 1, and the
identifier is zero. The root directory record in the Primary Volume
Descriptor also has this format.

All fields in the second record (sometimes called the ".." record) refer
to the parent directory, except that the identifier length is 1, and the
identifier is 1. The second record in the root directory refers to the
root directory.

The identifier for a subdirectory is its name. The identifier for a file
consists of the following fields, in the order given:

     (1) The name, consisting of the ASCII codes for at least one and
         not more than eight capital letters, digits and underscores.

     (2) If there is an extension, the ASCII code for a period (46). If
         there is no extension, this field is omitted.

     (3) The extension, consisting of the ASCII codes for not more than
	 three capital letters, digits and underscores. If there is no
         extension, this field is omitted.

     (4) The ASCII code for a semicolon (59).

     (5) The ASCII code for 1 (49). [On other systems, this is the
         version number, consisting of the ASCII codes for a sequence of
         digits representing a number between 1 and 32767, inclusive.]

Some implementations for DOS omit (4) and (5), and some use punctuation
marks other than underscores in file names and extensions.

Directory records other than the first two are sorted as follows:

     (1) Records are sorted by name, as described above.

     (2) Every series of records with the same name is sorted by
         extension, as described above. For this purpose, a record
         without an extension is sorted as though its extension
	 consisted of ASCII blanks (32).

     (3) [On other systems, every series of records with the same name
         and extension is sorted in order of decreasing version number.]

     (4) [On other systems, two records with the same name, extension
         and version number are permitted, if the first record is an
         associated file.]

[ISO9660 permits names containing more than eight characters and
extensions containing more than three characters, as long as both of
them together contain no more than 30 characters.]

It is apparently permissible under ISO9660 to use two or more
consecutive records to represent consecutive pieces of the same file.
Bit 7 of the flags byte is set in every record except the last one.
However, this technique seems pointless and is apparently not used. It
is not supported by MSCDEX.

Interleaving is another technique that is apparently seldom used. It is
not supported by MSCDEX (version 2.10).


12. Arrangement of Directory and Data Sectors

ISO9660 does not specify the order of directory or file sectors. It
merely requires that the first sector of each directory or file be in
the location specified by its directory record, and that the sectors for
directories and non-interleaved files be consecutive.

However, most implementations arrange the directories so each directory
follows its parent, and the data sectors for the files in each directory
lie immediately after the directory and immediately before the next
following directory. This appears to be an efficient arrangement for
most applications.

Some implementations go one step further and order the directories in
the same manner as the corresponding path table records.

const
 oem_uni_tab: array[#$80..#$FF] of word=(	{here: code page 437}
  $00C7, $00FC, $00E9, $00E2, $00E4, $00E0, $00E5, $00E7,
  $00EA, $00EB, $00E8, $00EF, $00EE, $00EC, $00C4, $00C5,
  $00C9, $00E6, $00C6, $00F4, $00F6, $00F2, $00FB, $00F9,
  $00FF, $00D6, $00DC, $00A2, $00A3, $00A5, $20A7, $0192,
  $00E1, $00ED, $00F3, $00FA, $00F1, $00D1, $00AA, $00BA,
  $00BF, $2310, $00AC, $00BD, $00BC, $00A1, $00AB, $00BB,
  $2591, $2592, $2593, $2502, $2524, $2561, $2562, $2556,
  $2555, $2563, $2551, $2557, $255D, $255C, $255B, $2510,
  $2514, $2534, $252C, $251C, $2500, $253C, $255E, $255F,
  $255A, $2554, $2569, $2566, $2560, $2550, $256C, $2567,
  $2568, $2564, $2565, $2559, $2558, $2552, $2553, $256B,
  $256A, $2518, $250C, $2588, $2584, $258C, $2590, $2580,
  $03B1, $00DF, $0393, $03C0, $03A3, $03C3, $03BC, $03C4,
  $03A6, $0398, $03A9, $03B4, $221E, $03C6, $03B5, $2229,
  $2261, $00B1, $2265, $2264, $2320, $2321, $00F7, $2248,
  $00B0, $2219, $00B7, $221A, $207F, $00B2, $25A0, $00A0);
*)
