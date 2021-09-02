FreeDOS APPEND 5.0
==================

(C) 2004-2006  Eduardo CASINO ALMAO (casino_e@terra.es)
    For the FreeDOS Project
    Under the GNU GPL 2.0

    Please report bugs to FreeDOS Bugzilla
                   (http://www.freedos.org/bugs/bugzilla/)

DESCRIPTION

APPEND enables programs to open data files in specified directories as if
the files were in the current directory. Using the /X[:ON] switch, this can
be extended to file searches and command execution.

Please refer to the help file or type APPEND /? for the complete syntax.
FreeDOS APPEND is fully command line and error message compatible with MS
APPEND. Any difference should be considered a bug.

APPEND can store the directory search list in the APPEND environment
variable.  This is activated using the /E switch the very first time that
APPEND is executed.

APPEND becomes a resident command after the first time it is executed and
occupies 4928 bytes of conventional memory. It can be loaded in upper
memory with LH.


IMPLEMENTATION DETAILS

1. Introduction

   This aims to be an as complete as possible implementation of the APPEND
   command for FreeDOS and other DOSes. It has been tested to work in
   FreeDOS and in MS-DOS 6.

   All the documented features I am aware of are implemented, and some
   others that I have been able to infer with test programs. This means
   that the internals of this implementation are very likely much different
   than the original, so if there is any program that rely on those
   internals, it will possibly fail.

2. Implemented features

2.1. Int 21h handler
 
   FD APPEND intercepts and extends the following Int 21h function calls:

    0Fh    Open File using FCB
    23h    Get File Size using FCB
    3Dh    Open Existing File
    6C00h  Extended Open/Create (except if action when file does not exist
           is set to create)

   Additionally, if /X[:ON] is set, the following function calls are also
   intercepted:

    11h    Find First matching file using FCB (except if file attribute is
           a volume label)
    4B00h  Exec - Load and Execute Program subfunction
    4B03h  Exec - Load Overlay subfunction
    4Eh    Find First (except if file attribute is a volume label)

   Warning: The FCB functions are not thoroughly tested, so they are more
            likely to contain bugs.

   The implementation of functions 3Dh, 6C00h, 4B03h and 4Eh is pretty much
   the same, which slight differences because of the registers they use to
   pass data or the flags we have to check. Basically, it consist in
   executing the unmodified function first and, if it fails, append the
   file name to each of the APPEND paths until we find the file or run out
   of paths.

   Functions 0Fh, 11h and 23h share exactly the same implementation. In
   this case, calls the unmodified function first and then executes
   succesive ChDir (3Bh) calls before calling function itself for each
   directory in the APPEND path. Before returning, the default dir is
   restored.

   Function 4B00h is a bit special. First, like the others, executes a call
   to the unmodified function. But then, it is the only one that does not
   honor the /PATH:ON|PATH:OFF switch and executes even if the file
   argument contains a path. Next, it executes a FindFirst (4Eh) for each
   path until it finds the file or run out of paths and, finally, it
   executes the Exec with the file appended to the last path tried.
   A local DTA is used for the FindFirst calls.

2.1.1  Error handling
  
   Errors other than 02h (file not found), 03h (path not found) or 12h (no
   more files) are interpreted as if the file had been found, the search
   stops and the error is returned to the caller.

   The actual error is checked for all FCB calls using function 59h (Get
   Extended Error Information.)


2.2. Installable Command Multiplexer (Int 2Fh, Function AEh)

   FD APPEND becomes a resident command after its first execution. It uses
   the installable command multiplexer and hooks subfunction 00h
   (Installation Check) and 01h (Execute). Second and succesive invocations
   of APPEND are managed by the Installable Command Multiplexer. Any
   attempt of executing the program from disk again will fail.


2.3. Int2Fh function B7h API

   FD APPEND implements the complete API, as documented in [1] and inferred
   from test programs, except function 2FB701h, which is not well
   documented and is not supposed to be part of the MS APPEND 5.0 API,
   either. These are the implementation details:

   * B700 Installation Check - As in [1].

   * B701 According to [1], this is Get Append Path (Microtek). It is not
          implemented. B704h should be used instead.

   * B702 Get Version - Returns AX=FDFDh. MS APPEND 5.0+ returns FFFFh, so
          this can be used to check for FD APPEND. I chose this number for
          obvious reasons, pretty much the same as the OEM version in the
          FreeDOS kernel.

   * B703 Hook Int 21 -  As in [1].

       A program can use this function to specify a user Int 21h handler
       which APPEND should chain to.

       Each invocation to this function toggles a flag that indicates
       APPEND whether to chain to/from the user's or the original i21h
       handler.  The first invocation activates the user handler.

       This function returns APPEND's int 21h handler.
       
       The desired scenario is as follows:

                  +--------------+   +-----------+   +-------------+
                  |    APPEND    |   | USER i21h |   | SYSTEM i21h | 
           i21h ->| i21h handler |-->|  handler  |-->|   handler   |
                  +--------------+   +-----------+   +-------------+

       You may think that the logical thing to do would be to tell APPEND
       the pointer to the user handler using 2FB703h, get the original i21h
       handler in return and chain the user handler to it. But read again
       what 2FB703h returns: "APPEND's int 21h handler". A closer
       inspection will reveal that this is not the same as the original
       APPEND handler at offset 0084h in the vector interrupt table: it is
       a different entry point.

       What you see immediately after calling 2FB703h is that APPEND stops
       working and that your handler is not being executed at all. If you
       call 2FB703h again, APPEND comes back to life, but no signs of your
       handler, and so on and so forth.

       Some minutes of experimentation and a couple of hangs later, I
       chained the user handler to the vector in the interrupt table and
       installed the returned APPEND's handler in place of the old one.
       Surprise! things started to work. Immediately after the first call
       to 2FB703h, the user handler executed right after APPEND's one and
       right before the system's handler. Successive calls to 2FB703h
       turned off and on the user handler. This is the actual setup:

       i21h
        |
        |  +---------------------+                      +-----------------+
        |  | APPEND i21h handler |                      | ORIGINAL SYSTEM |
        +->|  returned by B703h  |--------------------->|  i21h handler   |
           |  (New entry point)  |                      +-----------------+
           +-------------+-------+         +--------------------+  |
                         |  +-----------+  |  ORIGINAL APPEND   |  |
                         |  | USER i21h |  |    i21h handler    +->+
                         +->|  handler  |->| (Orig entry point) |
                            +-----------+  +--------------------+

       And this is what APPEND's int 21h handler does depending on its
       entry point:

       +- Original entry point: --------------------+
       |                                            |
       |   IF NOT User handler active               |
       |   THEN                                     |
       |       Execute APPEND                       |
       |   ENDIF                                    |
       |   Chain to the original Int21h handler     |
       +--------------------------------------------+

       +- New entry point: -------------------------+
       |                                            |
       |   Execute APPEND                           |
       |   IF User handler active                   |
       |   THEN                                     |
       |       Chain to the user Int21h handler     |
       |   ELSE                                     |
       |       Chain to the original Int21h handler |
       |   ENDIF                                    |
       +--------------------------------------------+

       To sum up, if you want APPEND to chain to your own int 21h handler,
       here you have some example code:

        ; --- Program BEGIN

                        org     0100h

                        jmp     start

        ; -- User's INT 21h handler ---------------------------------------
        ;
        ; Just print "I'm alive!" for every int 213Dh trapped by APPEND
        ;

        old_int21       dd      0
        alive           db      13, "I'm alive!", 13, 10, '$'

        int21:          pushf

                        cmp     ah, 3Dh                 ; Trap Open
                        jne     chain

                        push    ax
                        push    dx
                        push    ds

                        mov     dx, cs
                        mov     ds, dx
                        mov     ah, 09h
                        mov     dx, alive
                        pushf
                        call    far [cs:old_int21]

                        pop     ds
                        pop     dx
                        pop     ax

        chain:          popf
                        jmp     far [cs:old_int21]
                
        end_resident:
        ; -- End of resident code -----------------------------------------

        start:          ; Get vect to original int 21 handler
                        ;
                        mov     ax, 3521h
                        int     21h             ; get vector to ES:BX
                        mov     ax, es
                        mov     [old_int21], bx
                        mov     [old_int21+2], ax

                        ; Set our own int 21h handler and get APPEND's one
                        ;
                        mov     ax, 0B703h
                        push    cs
                        pop     es
                        mov     di, int21
                        int     2Fh             ; APPEND's handler returned
                                                ; in ES:DI

                        ; Check es:di. If unmodified, function 2FB703h
                        ; is not supported / installed
                        ;
                        cmp     di, int21
                        jne     install
                        mov     dx, cs
                        mov     ax, es
                        cmp     ax, dx
                        je      quit

                        ; Now, install new int21 handler
                        ;
        install:        mov     ax, 2521h
                        push    es
                        pop     ds
                        mov     dx, di
                        int     21h     ; DS:DX -> new interrupt handler

                        ; Release environment
                        ;
                        mov     bx,[cs:2Ch]     ; Segment of environment
                        mov     al,49h          ; Free memory
                        mov     es,bx
                        int     21h

                        ; Terminate and stay resident
                        ;
                        mov     dx, end_resident+15
                        shr     dx, 4
                        mov     ax, 3100h       ; go TSR, errorlevel 0
                        int     21h

        quit:           mov     ah, 09h
                        mov     dx, Error
                        int     21h

                        mov     ax, 4C01h       ; Exit errorlevel 1
                        int     21h

        Error           db      13, "APPEND not installed.", 13, 10, '$'

        ; --- Program END


   * B704 Get Append Path - As in [1]. MS APPEND returns invalid data when
          /E is set. FD APPEND always returns the valid APPEND path.

   * B706 Get Append Function State - As in [1]. This is the meaning of the
          flags:

          Bit
           0  Set if APPEND is enabled
        1-11  Reserved
          12  Set if APPEND applies directory search even if a drive has
              been specified. This flag is set/unset together with the next
              one with the /PATH:ON /PATH:OFF switches
          13  Set if APPEND applies directory search even if a path has
              been specified
          14  Set if APPEND uses the APPEND var in the environment (/E)
          15  Set if APPEND applies also to file searches and command
              execution

   * B707 Set Append Function State - As in [1].

          Programs that do not want APPEND directory search when using any
          of the i21h functions that APPEND intercepts should use these two
          functions to temporarily deactivate APPEND.

   * B710 Get Version Info - As in [1]. FD APPEND identifies itself as MS
          APPEND 5.0

   * B711 Set Return Found Name State. This differs from what is stated in
          [1]. This implementation is MS APPEND compatible.

          When this function is called, if next and only next int 21h
          function called is 3Dh, 6Ch or, if /X is set, also 4Eh or 4B03h,
          the actual found pathname is written on top of the filename
          passed to the int 21h call. It is not "the fully qualified name".

          Function 4Eh has a special behavior if AL != 00h. In this case,
          the actual found path will be prepended to the original filespec
          without a path.
 
REFERENCES

   [1]  Ralf Brown's Interrupt List, rel. 61
        (http://www.pobox.com/~ralf/files.html
