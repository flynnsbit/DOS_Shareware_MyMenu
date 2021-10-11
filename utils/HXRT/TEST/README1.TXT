
  1. HXRT Test Programs
  
  These are some test applications which may be useful in case of problems
  with HX and its Win32 emulation:
    
  þ DDTEST.EXE: Win32 console app switching to fullscreen graphic mode
    640x480x16 with DirectDraw. This will show if DirectDraw works, if
    the mouse cursor shape is displayed and if the mouse position 
    resolution is in pixels (mickeys).
    
  þ DDTSTDBL.EXE: Win32 GUI app to test flipping surfaces with DirectDraw.
    Uses 640x480x16 mode and 1 backbuffer (requires 1,2 MB video memory).
    
  þ DDTSTTRI.EXE: Win32 GUI app to test flipping surfaces with DirectDraw.
    Uses 640x480x16 mode and 2 backbuffers (requires 1,8 MB video memory).

  þ DOSTEST.EXE: this is a 32-bit DPMI app which tests if calling some
    important DOS file functions (used by DKRNL32) will modify the Hiword
    of registers EBX, ESI, EDI, EBP. A program which is known to make the
    test fail is loading FreeDOS' EMM386.EXE (tested with V2.07 and below).
    In case of failure some applications may not run as expected.
    This program will try to temporarily create a directory and a file in
    the current directory, so it needs write access for this. The names
    which are used are "~TEMP", "~TEMP.TXT" and "~TEMP_.TXT".

  þ ENUMMODE.EXE: Win32 GUI app displaying the video modes seen by
    DirectDraw.
    
  þ MEMSTAT.EXE: displays Int 15h extended memory information. HDPMI
    will use information of Int 15h, ax=E801 and ah=88h in raw mode,
    that is, no XMS host is installed.
  
  þ GETVMODE.EXE: displays information about VESA video modes. Enter
    GETVMODE ALL to list the available VESA modes. This will run the very 
    same code as it is used by HX's GDI and DirectX emulation to find
    graphics modes. Only modes with both attributes "Graphics" and "LFB"
    can be used.
  
  þ GDITEST.EXE: Win32 GUI app which will display mouse and key events.
    DirectDraw is not used here.

  þ LOCTIME.EXE: Win32 console app displaying system and local time. If
    local time is wrong when running in DOS, adjust TZ environment variable.

  þ RMINT.EXE: DOS PE binary to test HX's PE loader and DPMI host.
    
  þ TESTASPI.EXE: Win32 console app which tests the ASPI support.
    
  þ THREAD.EXE: Win32 console app which may be used to test if threads
    work with HX and the underlying OS. Two worker threads are created,
    while the main loop waits for keypresses (ESC terminates).


  2. If HX doesn't run at all

  With the following strategy one may find out what's the problem if
  HX just causes the computer to freeze or reboot.

  þ step 1: boot a DOS which has a XMS host (HIMEM) loaded, but without
    an EMM manager (EMM386, QEMM386, 386MAX, ...). This is the best
    configuration for HX's DPMI host HDPMI. Avoid loading sound, mouse or
    network drivers. To verify this configuration, run DPMI.EXE. It should
    tell that cpu is in real-mode, XMS host found, no VCPI or DPMI hosts 
    found.

  þ step 2: start HDPMI32.EXE without parameters. No messages should be 
    displayed and the command prompt should reappear.
  
  þ step 3: start DPMI.EXE. It should display information about the DPMI
    host. Check if the value for "largest free memory block" is reasonable.
    
  þ step 4: start DPMILD32.EXE without parameter. It should display a
    copyright message and an information that it misses a filename.

  þ step 5: start RMINT.EXE. This is a raw "DOS" PE binary which doesn't
    use any dlls, and it should display infos about the XMS host. 
  
  þ step 6: start LOCTIME.EXE. This is a Win32 binary which uses the
    KERNEL32 emulation dll DKRNL32.DLL. The current system and local time
    should be displayed. 

  þ step 7: start THREAD.EXE. This Win32 binary will tell if threads
    are working with HX.

  If all steps run without problems in this basic constellation, try to
  add - carefully - the stuff which is contained in your CONFIG.SYS and/or
  AUTOEXEC.BAT. Be aware that some memory managers include a DPMI host
  which will be used by HX if HDPMI isn't installed residently.
  

  Japheth
