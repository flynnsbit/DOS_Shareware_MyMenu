MPXPLAY Audio player v1.53 by PDSoft (Attila P d r, Hungary)

Supported filetypes (decoders,demuxers):

AAC     (Advanced Audio Coding from http://www.audiocoding.com (in RAW/ADTS/ADIF fileformats))
AVI     (with AAC,AC3,DTS,MP2,MP3,PCM,WMA audio)
AC3     (Dolby AC3 from http://a52lib.sourceforge.net)
APE     (Monkey's Audio from http://www.monkeysaudio.com)
CDW     (Audio-CD 'ripp and play' on the fly)
DTS     (Digital Theatre Systems from http://www.videolan.org/dtsdec.html)
FLAC    (Free Lossless Audio Codec by http://flac.sourceforge.net and http://ffmpeg.sourceforge.net)
MP2,MP3 (Audio MPEG Layer II/III from http://www.mpg123.de)
MP4/M4A (MPEG4 container with AAC and MP3 audio)
MPC     (MPEGPlus/MusePack from http://www.musepack.net)
OGG     (Ogg Vorbis from http://www.xiph.org)
WAV     (with AAC,AC3,DTS,MP2,MP3,WMA or uncompressed PCM audio)
WMA/WMV (ASF container with WMA (7.0,8.0) and with AAC,AC3,DTS,MP2,MP3,PCM audio)
WV      (WavPack hybrid lossless audio from http://www.wavpack.com)

Playlists:

M3U,M3U8,PLS,FPL,CUE,MXU


Send suggestions and error reports to 

 mpxplay@freemail.hu   (please don't public this email address (ie: don't put it on your web page))

important notes and requests before you send me mail:
 - write MPXPLAY in the subject line !!!
 - before You ask something from me or you would like to send me a bug report, 
   please read README.TXT (this), MOREINFO.TXT and FAQ.TXT files!
 - you can find a lot of extra infos in the MPXPLAY.INI file too
   (keyboard mapping, LCD, joystick and serial port (infra receiver) configuration)
 - some infos are in the source files only (mpxsrc.zip)(ie: hardware description of LCD types in display\lcd.c)
 - don't send attachments (only if I ask for it)
 - sorry, but I can't answer to everybody, I read your requests/problems,
   but don't wait answer from me ...
   (Usually I don't answer, if you can find the answer to your question somewhere
    in the text files or I can't help you at all (especially at hardware problems))

Visit my homepage(s) for the latest Mpxplay versions:

   http://mpxplay.cjb.net   <- this address is linked to my actual main page

   http://www.mpxplay.net
   http://mpxplay.sourceforge.net
   http://www.freewebtown.com/mpxplay
   http://www.geocities.com/mpxplay
   http://www.sourceforge.net/projects/mpxplay (older Mpxplay versions)

And visit the Mpxplay forum for extra informations (linked on my homepages).


Mpxplay system requirements:

- Minimum CPU for playing 44.1khz, stereo, (128kbit/s) files (with '-f0 -sl 0 -bl -bn8' options): 

  AAC : Intel Pentium 66    (LC object type)
  AC3 : Intel 80486 DX4-120 (48khz,2.0ch,192kbit)
  APE : Intel Pentium 166 MMX (fast-mode encoded files work without MMX too)
  DTS : Intel PII-300 (48kHz,5.1ch,768kbit)
  FLAC: Intel Pentium 66  (depending on the compression ratio too)
  MP2 : Intel 80486 DX2-50  (DX2-66)
  MP3 : Intel 80486 DX2-80  (DX4-100)
  MPC : Intel 80486 DX4-100
  OGG : Intel 80486 DX4-120 (DX4-133)
  WMA : Intel Pentium 90
  WV  : Intel Pentium 166
  (note: demuxing from AVI,ASF,MP4 requires some extra time if it contains more than one stream (video or audio))

- Supported soundcards (see sndcards.txt for more infos):
 -PCI cards (use in DOS only):
  - SB Live, Audigy 1,2,4, Live 24, Audigy LS
  - CMI 8338/8738
  - Intel ICH(0-7), NForce(1-3)
  - VIA VT686/8233/8235/8237
 -ISA cards (or emulation on PCI card):
  - SB16 or compatible (DSP 4.x):
    - SB16 (ISA not PCI!)
    - SB AWE-32/64
    - SB PCI 128,512(?),Live,Audigy 1 (with SB16 emulation)
    - CMI-8330
  - WSS compatible: 
    - Crystal Sound (CS423x)(ie:Turtle Beach Malibu)
    - Yamaha OPL3
    - SB PCI 64, Ensoniqe (?)
    - some OPTI cards (?)
    - some CMI cards (?)
    - some ESS cards (?)
  - ESS 688,1688,1868,1869,1878,1879,1887,1888 chips (?)
  - GUS (GUS MAX, GUS PnP (AMD Interwave)(?))
  - SB Pro or compatible (DSP 1.5, 2.x, 3.x)(a lot of cards)
   ((?) means: not tested, maybe it doesn't work properly)
 -Under Win9x/2k/XP you can try VDMSOUND or DOSBOX programs too,
  they emulate SB16 (but they won't work at me under Win2000)

- Memory (not exact calculations):
 - 300k kbyte conventional
 - 4Mb XMS (+2*1Mb at -bp)(+size_of_file at -bl)(+decoder requirements (0.1Mb-1.0Mb))

- Display: VGA (or EGA)

- OS: MS-DOS 5.0 or above, FreeDOS,DR-DOS, Windows 95/98 (dos box), Linux & OS/2 dos emu (?)
  (under DOS the DOS32A or DOS4G version is recommended, the PMODE/W may cause memory allocation and IRQ problems)
  (under Linux and OS/2 (DOS emu) the PMODE/W or DOS32A version is recommended)

Command line option examples:

 MPXPLAY.EXE [option(s)] file [file2] [file3] [...] ('file' can be an audiofile (mp3,wav,etc.), playlist (m3u,pls,fpl,mxu) or dir-scan (d:\subd*.*\file*.*)) (multiply input files don't work at WAV output (-o))
 MPXPLAY.EXE [option(s)] -ds cde [filemask] (scan c: d: e: drives [for 'filemask' files (ie: *.mp3)])
 MPXPLAY.EXE [option(s)] d:\*.cdw           (play all audio CD tracks)
 MPXPLAY.EXE -o infile.mp3 outfile.wav      (decode mp3 to a wav file)
 MPXPLAY.EXE -o playlist.m3u                (decode all audio files (from the playlist) to wav files (into the current dir))
 MPXPLAY.EXE -o *.mp3 d:\outdir             (decode all audio files (*.mp3) to wav files (into the d:\outdir directory)
 MPXPLAY.EXE -o -obs *.mp4                  (demux aac audio from mp4 container)
 MPXPLAY.EXE -o -sl 0 d:\1.cdw 1.wav        (copy the 1. audio CD track into a wav file (ripp))
 MPXPLAY.EXE -o -sl 0 d:\*.cdw [d:\outdir]  (copy all audio CD tracks into wav files (into the current or into a specified dir))

for slow computers (486DX4-100 or bellow)(-bl requires 7-10Mb RAM (3Mb + filesize)):
 MPXPLAY.EXE -sl 0 -ddma -f0 -v -bl -bn8 playlist.m3u
 MPXPLAY.EXE -sl 0 -ddma -f0 -v playlist.m3u

for faster computers (Pentium or above):
 MPXPLAY.EXE -bp -ipl playlist.m3u
 MPXPLAY.EXE -bp -idl playlist.m3u

List of all command line options:

Playlist:
 -@  PLAYLIST : use a playlist (.m3u or .mxu)(not really needed, Mpxplay can detect the playlist file-type)
 -@i          : load/read playlist from stdin (m3u style)(ie: dir /b *.mp3 | mpxplay.exe -@i)
 -@d PLAYLIST : jukebox mode (load playlist to the left side)
 -@s PLAYLIST.M3U  : save playlist from editor into PLAYLIST file on exit (default:MPXPLAY.M3U)
 -@sw PLAYLIST.M3U : save playlist in EXTM3U format (like Winamp)
 -@sx PLAYLIST.MXU : save playlist in (own) extended format (playlist with file infos)
 -@sc PLAYLIST.CUE : save playlist in CUE format (indexed files)
 -ds DRIVES : multiple drive scan (-ds cde -> scans c: d: e: drives)(-ds cde *.wav -> search wav files only)
 -dd : enable jukebox mode (load files to the left side)(use at drive scan (-ds) and directory browser)

 -prn  : random play
 -prn2 : randomize playlist at start
 -pre  : replay/repeat playlist
 -pre1 : replay/repeat only 1 song (rewind to the begin of file)

 -pss NUM  : start play at NUM. song  (PlayStartSong) (without NUM, it just starts the playing at the first (or last played) song)
 -pst TIME : start song at TIME pos.  (PlayStartTime) (TIME may be in HOURS:MINUTES:SECONDS.HUNDREDTHS (HH:MM:SS.NN or MM:SS.NN or SSS.NN or SSS) format (ie: 3:17 or 197.25))
 -psf NUM  : start song at NUM. frame (PlayStartFrame)
 -psp NUM  : start song at NUM-16%    (PlayStartPercent)(16% is the begin of the song (116% is the end))
 -pcs NUM  : exit after NUM song      (PlayCountSong)
 -pct TIME : play duration (in 1 song)(PlayCountTime) (TIME may be in HH:MM:SS.NN or MM:SS.NN or MM:SS or SSS.NN or SSS (etc.) format)
 -pcf NUM  : play NUM frames only     (PlayCountFrame)
 -pcp NUM  : play NUM% from the song  (PlayCountPercent) (1-100)
 -pef NUM  : finish playing at NUM. frame (PlayEndFrame)(PlayFrameCount=PlayEndFrame-PlayStartFrame)(doesn't work with -psp)
 -pslf NUM : use/load NUM. fastlist (PlayStartList)(NUM. list in [fastlist] config)(without NUM, it loads the last used list and restores the list/song position from the [startup])
 -phs      : hi-lite scan, play only 10 seconds from every songs (1m00s-1m10s)(configurable with -pst,-pct options)
 -pap      : enable auto pause (auto pause before each song)

Display:
 -f0  : no screen output (some warning/error messages are not displayed in this mode (ie: serial-control and LCD errors))
 -ff  : only framepos and actual filename are displayed
 -fl  : one line display output
 -v   : verbose mode (mpeg info,id3tag info for -f0,-ff,-fl options)
 -fe  : full screen playlist-editor (without spectrum-analiser & browser)
 -fs  : single lines mode (disable 50 lines mode change at start) (25->50)
 -db  : disable directory browser in playlist editor (left side)(if you use it, program exits after the last song)
 -db2 : directory browser on both sides (left and right side too)(it has higher priority than the playlist loading)
 -ebs NUM : editor border size (1-64)(def:64)

Visual plugins (only at DOS4G version):
 -vps NAME : visual plugin selected name (else pick up all visual DLLs and skip after user-request (keyboard or mouse))
 -vpt SECS : visual plugin start time (start visualization after SECS seconds)(default: 0, visual plugins will not start without this option)

Input buffer (def.: 128 (4*32) kbyte prebuffer without interrupt decoding):
 -bp  : input file pre(ring)buffer (decoder runs on INT08)
 -bl  : input fullbuffer (it loads the (whole) song into memory before playing (max. 13mbyte))
 -bni : disable interrupt decoding (for -bl)
 -bn8 : disable all INT08 functions (interrupt decoding,dma monitor)
 -bbn : prebuffer blocks (for -bp)(1 block=32kbytes)(use: 8 - 64 (MP3-WAV))(def.: 4; -bp: 32)
 -bn  : no input buffer (not recommended, for testing only)

Sound card and file (wav) output:
 -scs CARD : manual soundcard select (force) (CARD may be: CMI,ICH,SBA,VIA, S16,ESS,WSS,GUS,SBP,NUL)
 -sct CARD : soundcard test (without CARD argument it tests and displays all detected cards)
 -scv NUM : set sound card volume (master & pcm together)(1-100(%))(at some soundcards under Win9x use 100% (ie: SB16 emu of SB Live/Audigy))
 -ddma    : double dma (soundcard buffer) (16-bit output: 32k->64k; 32-bit: 64k->128k) (recommended to use if outfreq>48000)
 -o       : write pcm data to a wav file (instead of soundcard)
 -of  NUM : set output frequency (constant soundcard freq / freq conversion at wav output)
 -oc  NUM : set output channels (at wav output only)(1 or 2)
 -ob  NUM : set output bits (wav output or Audigy 2/4, ICH4, Live24 cards)(if bits>16 then recommended to use the -hq option (enabled by default))
 -obf     : write 32-bit floating-point wav files (id=0x0003)
 -obs     : bitstream mode output (no decoding)(currently for file-out (-o) and with AAC,AC3,DTS,MP2,MP3 (AVI,ASF,MP4) input/output only)(ie: mpxplay.exe -o -obs infile.mp3 outfile.mp3 -pst 1:00 -pct 0:30)
 -oni     : create output filename from the id3-info (at -o,-obs)(nn. artist - title.wav)(works only if LFN is supported (with DOSLFN or under Win9x))
 -t       : testmode (no sound output, only decoding)

Sound mixing and output modifying:
 -sv   NUM : software volume setting (amplifying)(0-700)(def.: 100 (%))
 -sva      : enable auto volume correction
 -sr   NUM : surround/stereo expander (def.:100 (%) = no surround, 10=mono, 150=wide stereo)
 -sp   NUM : playing speed (freq) control (55-990)(def.: 100)
 -sctr NUM : set tone-treble (1-100) (SB16,AWE32/64: hardware; otherwise (or with MixerControl=3): software)
 -scbs NUM : set tone-bass   (1-100) (def.: 50 = no tone change)
 -sl   NUM : soundlimit (playlimit)(0-200)(def.:20)(finishes the playing of the song if the sound volume is under the limit)

 -csa NUM : select audio stream (in ASF/AVI/MP4, if it contains more than one audio stream)

 -cl : decode left channel only (1.9x/1.4x faster decoding at MP3/OGG files (only))
 -cm : downmix channels (stereo to mono)(ca. 1.7x faster decoding at MP3 files only)
 -hq : hq (float) mixer (recommended to use it, it's better but slower than int16 mixer) + fake high sounds at mp2 files

 -cf      : enable crossfade
 -cft NUM : crossfadetype   (def. 1) (0.bit (+1) :fade-out, 1.bit (+2) :fade-in)(-cft 3 : fade out + fade-in)
 -cfo NUM : fade-out length (def. 250)
 -cfp NUM : crossfade point (def. 120)(start crossfade at num. frame, relative to begining of fade-out)
 -cfi NUM : fade-in length  (def. 200)
 -cfl NUM : crossfade limit (def. 0) (start crossfade, when volume less than num (don't use crossfade point))
 (crossfade only: -cfo 150 -cfp 0 -cfi 150 , fade-out & fade-in only: -cfo 150 -cfp 150 -cfi 100 )

ID3-info, file-info loading:
 -inl : don't preload (load at skip only) file informations (header,id3tag) (but MXU/EXTM3U works (has effect))
 -ihl : load infos of highlighted file only (at cursor move (up/down arrows))
 -idl : load infos of displayed files only (displayed in playlist editor window)
 -ipl : load (all) infos paralell with playing
 -in  : don't load/display id3tag infos (only filename and time-length)
 -if KEYWORD : tag-filter (keep files which have KEYWORD in their id3tag(s) (or in filename(s) if there's no id3tag), delete the others)(restrictions: doesn't work properly with -inl,-ihl,-idl,-ipl,-in options; KEYWORD may not contain space(s); very slow at large playlists)

ID3-tag write/update in audio files (at aac,ac3,ape,dts,mp2,mp3,mpc,wv files only):
 -iw  : enable id3-tag writing
 -ita "artist"  : set artist tag (these options work without -iw option too)
 -itt "title"   : set title tag  (you also can use a listfile (-il) to set artist:title infos)
 -itl "album"   : set album tag
 -ity "year"    : set year tag   (if it's not set, and the file has no year-tag, then the program will set a YYYY/MM from the current date)
 -itc "comment" : set comment tag
 -itg "genre"   : set genre tag  (note: ID3v1 has standard (static) genre-types only (see id3genres[] in in_mp3.c))
 -itn "tracknum": set tracknum tag (note: ID3v1.1 (MP2,MP3) can store a number between 0 and 255 (ie: -itn "63") only)
 (note: if the audio file already has id3-tag and you don't set new tag(s)
        then the program keeps the original tags of the file
        you can use "" to clear a tag (ie: -itl ""))

Character (codepage) conversion (from audio files to Mpxplay and back):
 -8   : convert characters in id3tags (in artist,title,etc.)(doesn't convert in filenames)(configured in mpxplay.ini by WinChars/DosChars)
 -8f  : convert characters in filenames too (use it with -8)(-8u has no effect on filenames, -8ua converts filenames in M3U8 and FPL)(if a char conversion is wrong, remove it from the WinChars/DosChars)
 -8u  : enable UTF-8 text decoding in tags (in every tags/filetypes)
 -8ua : enable auto UTF-8 and UTF-16 decoding (where it's required)(APEv2,ASF,FLAC,ID3v2,Ogg,FPL,M3U8)(enabled by default, you can disable it in mpxplay.ini (Conv852437))
 -8cp CPNAME : target codepage for UTF-8/16 decoding (default: ISO-8859-2) (see moreinfo.txt for more CPNAMEs)
 -8uv : validate (use only) WinChars at UTF-8 decoding (above ascii 128)(to avoid wrong/false decoding at non-utf8 texts)
 -8b  : convert back chars (for -iw)(from Mpxplay to audio files, from DOSchars to WINchars only)(because -8 converts in both direction)

Playlist sort:
 -io  NUM : primary order key; order playlist by 0=title, 1=artist, 2=album, 3=year, 4=comment, 5=genre, 6=tracknum, 7=time, 8=filesize, 9=path, 10=filename, 11=path\filename, 12=order only directory entires (browser) by filename
 -io2 NUM : secondary order key (0=title, 1=artist, etc.)
 -io3 NUM : third order key (-"-)
 -io4 NUM : fourth order key (-"-)
 -iod     : descending order (else ascending)(use it with -io)

ID3-list:
 -il [infofile] : load LOCAL id3info listfile (for directory browser (left side), (re)loads list from every directory (after dir change)) (see moreinfo.txt too)
 -ig [infofile] : load GLOBAL id3info listfile (for both sides (directory browser and playlist)(create of id3list: mpxplay.exe playlist.m3u -@sx infofile.txt)
 -is [infofile] : save id3 infos in a listfile
 -ist NUM : field-types for -is (the bits of the NUM change/enable the fields)(def.:63)
   0. bit (  +1): list directory names
   1. bit (  +2): list filenames
   2. bit (  +4): artist-title list mode (non-fixed/fixed position)
   3. bit (  +8): list time of file
   4. bit ( +16): list bitrate (kbit/s)
   5. bit ( +32): list filesize in megabytes
   6. bit ( +64): list filenames with full path

Other (program controls):
 -x PRGNAME : set program name for DOS shell (i.e. -x nc.exe)
 -xs        : call a dosshell (automatically) after the start of Mpxplay
 -xr        : TSR mode (for CDW files only)('mpxplay.exe -bl -xr -xs -pre1 song.mp3' for continuous background playing)(this option has keeped for a possible future developing, it's not really usefull)
 -xas       : enable atx/apm shutdown (at exit)
 -xts TIME  : program play start time (start playing (unpause) at TIME)(in the next 24 hours) (TIME may be in HH:MM:SS or HH:MM or HH format)
 -xte TIME  : program exit time (in the next 24 hours) (TIME may be in HH:MM:SS or HH:MM or HH format)
 -xtl TIME  : program run-time length (from -xts or from the start of the program)(max. 24 hours)(TIME may be in HH:MM:SS or HH:MM or HH format)
              (note: HH is hour(s), MM is minute(s), SS is second(s))
 -dlls      : list informations about DLLs in Mpxplay's dir (only at DOS4G version)

Video out (not used yet):
 -vos NAME: select video output (driver) (built-in: VESA)
 -volm    : list available video modes (for the selected video driver)
 -vom HEX : set video mode manually (from the list by -volm)
 -vox NUM : set horizontal resolution (def:1024) (ie:640,800,1024,1280,1600)
 -voy NUM : set vertical resolution (ie:400,480,600,768,1024,1200)
 -vob NUM : set output bits / color depth (def:32) (if the videoout driver supports it) (16:hicolor; 24,32:truecolor)


Keyboard controls (some keys are case sensitive (lower case only)!)
(suggestion: set the keyboard speed to 30 char/sec in BIOS):

 ESC      - exit from the program (or terminate drive scanning, playlist checking, file loading (-bl), AAC seeking)
 CTRL-C   - exit from the program
 F10      - exit from the program without shutdown (at -xas)
 gray-'-' - step back one song in playlist
 gray-'+' - step forward one song in playlist
 white-'-'- step back like a CD player (if framenum>38, step to begin of song, else step to previous song)
 gray-'/' - step back one subdirectory (album) in playlist
 gray-'*' - step forward one subdirectory (album) in playlist
 alt-'/'  - load previous fastlist (from [fastlist] config in mpxplay.ini)
 alt-'*'  - load next fastlist
      ->  - (right arrow) forward 50 frames (configurable with SeekFrames in mpxplay.ini)
      <-  - (left arrow)  rewind  50 frames (50 frames is usually 1.3 sec)
 CTRL-gray-RIGHT  - seek +1% (or min. 200 frames)
 CTRL-gray-LEFT   - seek -1% (or min. 200 frames)
 CTRL-white-RIGHT - 4x seek forward (200 frames)
 CTRL-white-LEFT  - 4x seek rewind (200 frames)
 BACKSPACE- jump to begin of song (to 0. frame)
  A       - spectrum analiser enable/disable
  C       - crossfader enable/disable
  d       - hi-lite scan (demo mode) start/stop
 CTRL-'d' - open a DOS-shell (type 'exit' to return)
  E       - editor filenames show/hide
  F       - (cross) fade out/in enable/disable
  g       - switch between text and vga (video) mode (not useful yet)
 CTRL-'g' - skip one LCD page
  H       - HQ-mode (hq-mixer, mp2 decoder)
  J       - switch between juke-box (doombox) and normal mode (reloads playlist!)
  M       - mute sound (while press) (1/8 sound volume)
 CTRL-'m' - mute sound (on/off switch) 
  N       - random play (shuffle) enable/disable
  o       - open/close CD door (of primary CD drive)
  P       - start/pause playing (space button too)
 CTRL-'p' - enable/disable autopause
  R       - replay (repeat) enable/disable (none / 1 song / full playlist replay)
 CTLR-'r' - refresh directory browser OR reload playlist/rescan directories,drive(s) (ie: after CD change)
  S       - stop playing (jump to begin of playlist)
 CTRL-'s' - pause playing at (before) next song
  T       - time mode (elapsed,remaining,allelapsed,allremaining)
  V       - auto volume enable/disable
 CTRL-V   - reset all mixer functions to center/zero value (volume,surround,speed,balance,treble,bass)
  X       - swap channels (reverse stereo)

  .       - volume up   ('white home' too) (0-14: +1%, 15-100: +6%, 100-700: +0.5dB)
  ,       - volume down ('white end' too)
  '       - surround up   (stereo expander)
  ;       - surround down (to mono)
  ]       - playing speed up
  [       - playing speed down
  \       - speed up while push (fast-forward like tape-deck by speed-control)
  <       - balance-left
  >       - balance-right
  "       - bass up (hardware tone on SB16 and AWE32/64 cards, else software tone at MP3/MP2/MPC files)
  :       - bass down (-"-)
  }       - treble up (-"-)
  {       - treble down (-"-)
  |       - loudness on/off (80/50 bass&treble)('80' is configurable with an initial bass/treble value (!=50))
 alt-'.'  - soundcard volume up   (doesn't work on every cards (ie:GUS))
 alt-','  - soundcard volume down (and it has no indicator on the display)

   ALT-F9 - 25/50 lines mode switch
  CTRL-F9 - full screen playlist-editor mode (analiser and browser disabled)
 SHIFT-f9 - equal to ALT-F9 + CTRL-F9

 NUMBER   - type a playlist-entry number (1-9999)(jump to n. song)

 
 Unmapped keyboard functions (configurable in mpxplay.ini):
 
  KeyCRewind      - continuous rewind (press again key to stop it)
  KeyCForward     - -"-        forward
  KeySkipAlbL1Back- skip back one album-group (like SkipAlbumBack, but with 1 directory level higher)
  KeySkipAlbL1Frwd- skip forward -"-
  KeySkipAlbL2Back- skip back one album-group (like SkipAlbumBack, but with 2 directory level higher)
  KeySkipAlbL2Frwd- skip forward -"- (note: put all audio files in the same (sub)directory level, else these functions will not work properly)
  KeyShutDownExit - exit and shutdown computer (ATX only)
  KeyEditCpySngEhl- copy song (entry) and move/shift it to editorhighline position and skip editorhighline
  KeyEditDelFile  - delete file from disc (and from playlist) (like F8, but with a physical file delete)
  KeyEditCopyFile - copy file on disc (target side must be directory-browser) (like F5, but with a physical file copy)
  KeyEditMoveFile - move file on disc (move inside disk-partition, copy+delete if dest is on other disk-partition)
  KeyLCDpage0,KeyLCDpage1,KeyLCDpage2,KeyLCDpage3 - select LCD page 0,1,2 or 3


 Playlist-editor keys: 
  TAB               : change playlist editor side
  Up & Down arrows  : move cursor up/down 1 song in the playlist
  PageUp,PageDown   :       -"-           1 editor page (1 page=30 song on the default screen)
  ALT-gray-PgUp/PgDn:       -"-           1 album (subdir difference in the playlist)
  Home,End          :       -"-           to the top/bottom of playlist
  CTRL-PgUp/PgDn    : move to updir/subdir (in directory browser) or uplist/sublist (in playlist)
  CTRL-'\'          : jump to root dir/list (directory browser/sublist structure)
  CTRL-gray-'/','*' : jump to prev/next paralell playlist (using sublists) or directory (in directory browser)

  ENTER             : start the selected song OR load playlist OR change dir/sublist
  CTRL-ENTER        : select/unselect next song (and playing side)

                      set primary key and re-order playlist on actual editorside
  CTRL-F1           : orfer by filenames and disable sorting (sort directory entries only (browser/dir-scan))
  CTRL-F2           : order by artist /title/filename (1./2./3. keys)
  CTRL-F3           : order by title  /artist/filename
  CTRL-F4           : order by time   /artist/title/filename

  F2                  : save playlist (into a mpxplay.m3u file)
  F5 or Ins           : add/copy a song/playlist/subdir to the other side
  SHIFT-F5            : copy song/list/subdir name to the other side (do not load list/dir) (usefull for creating sublist)
  F8 or Del           : delete a song from the playlist
  CTRL-F5 or CTRL-Ins : copy all playlist entries to the other side
  CTRL-Del            : clear playlist (usually right side)
  CTRL-UP / DOWN      : shift (drag and move) a song up/down in playlist

  ALT-LEFT / RIGHT    : modify size of playlist-editorsides (horizontal)
  ALT-UP / DOWN       : resize playlist editor / song browser (vertical)

 Searching in the editor (searches in all metadatas and filenames):
  ALT-'a'-'z'     : init search (you must use ALT at the 1st character only)
  Backspace       : clear back
  Up/Down Arrows  : search (again) backward/forward in the playlist
  ESC/ENTER       : exit from the search
  ':'-key         : artist:title separator (to search in artist and title only)

 Mouse buttons:   
  left button (used to desktop functions by default (reconfigurable in mpxplay.ini)): 
   - one click on song-position line () to seek in song (to set a new position)
   - one click in the playlist to move the editor highline (and change editorside)
   - double click in the playlist to start a new (selected) song
   - one click on song-browser to skip to (select and start) a new song

  center button: step back in playlist   / fast rewind    (click/long press)
  right button:  step forward in playlist/ fast forward
  wheel up/down: editorhighline up/down  (http://cutemouse.sourceforge.net)
