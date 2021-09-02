/*
   C prototype for accessing TheDraw Video Screen UnCrunch routine.

   This is the flash display routine used to display crunched TheDraw image
   files.  It uses a custom protocol for reproducing an image with any
   possible color combinations.  The control codes below #32 are reserved
   for this function.  See file UNCRUNCH.ASM for description of protocol.

   Example call:

     uncrunch (source_data,target_area,length);

       source_data should be a 32 bit address.
       target_area should be a 32 bit address.
       length should be an integer;

   NOTE:
     The UnCrunch routines require usage of a LARGE data model using
     32 bit pointers.  Use of a small data model will cause extremely
     erroneous results, is guaranteed to overwrite the wrong places
     and do all other manner of nasty things.  Please be aware of this.

   ---------------------------------------------------------------------
   Program example:

     Assume we have an ImageData file (saved to IMAGE.H) of a 40 character
     by 10 line block.  Also the following defintions.  ie:

       #include <stdio.h>
       #include "uncrunch.h"
       #include "image.h"

       main ()
       {
         unsigned char far *screenaddr = (char far *) 0xB8000000;

         uncrunch (IMAGEDATA,screenaddr+34*2+(5*160)-162,sizeof(IMAGEDATA));
       }

     SCREENADDR is a pointer mapped to the same location as the physical
     video addresses.   The rather messy array offset tells UnCrunch where
     to start displaying the ImageData block.

     The 34*2 indicates the horizontal position number 34 with the 5*160
     indicating line number 5.

     Note the use of the SIZEOF operator.  This tells the compiler to figure
     out how large the ImageData array is.  The array length value listed at
     the top of the image data (in IMAGE.h) could have been used also.

     UnCrunch remembers the original horizontal (X) starting position when
     it goes down to the next line.  This permits a block to be displayed
     correctly anywhere on the screen.  ie:

       +-------------------------------------------------+
       |                                                 |
       |                                                 | <- Pretend this
       |                                                 |    is the video
       |           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿               |    display.
       |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
       |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
       |           ³ÛÛ ImageData block ÛÛ³               |
       |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
       |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
       |           ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³               |
       |           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               |
       |                                                 |
       |                                                 |
       |                                                 |
       +-------------------------------------------------+


     The ImageData block could just as well have been display in the
     upper-left corner of the screen with:

       uncrunch (IMAGEDATA,screenaddr,sizeof(IMAGEDATA));

     Notice the array address offset has been removed, since we want the
     upper-left corner and SCREENADDR points directly at that position.

     To display the block in the lower-right corner you would use:
       uncrunch (IMAGEDATA,screenaddr+40*2+(15*160)-162,sizeof(IMAGEDATA));

     The block is 40 characters wide by 10 lines deep.  Therefore to display
     such a large block, we must display the block at X=40, Y=15.

   ---------------------------------------------------------------------

   There are two implementations of the UnCrunch routine.  One is for
   near code referencing and the other for far code referencing.  Use
   whichever is appropriate for your compiler configuration.  Please note,
   it would be bad to use the wrong one...

     The file UNCRUN_N.OBJ contains the near code model.
     The file UNCRUN_F.OBJ contains the far code model.

   Configure your machine to link in the appropriate file.  This is compiler
   dependant.  In TurboC for instance, you include the filename in the
   project file list.

   ---------------------------------------------------------------------

   The routines do not alter any CPU registers or return any result value.
   They have been tested successfully with Turbo C v2.0 and MicroSoft C v5.1,
   but are not guaranteed to work with all compilers.

   The stack setup expected by the routines is:

   NEAR CODE MODEL:
     SP:      <retaddr>   Return address
     SP+02:   <offset>    32-bit pointer to source data.
     SP+04:   <segment>
     SP+06:   <offset>    32-bit pointer to destination address.
     SP+08:   <segment>
     SP+0A:   <length>    Length (in bytes) of uncrunch data block.

   FAR CODE MODEL:
     SP:      <retofs>    Return address (32-bit, CS:IP);
     SP+02:   <retseg>
     SP+04:   <offset>    32-bit pointer to source data.
     SP+06:   <segment>
     SP+08:   <offset>    32-bit pointer to destination address.
     SP+0A:   <segment>
     SP+0C:   <length>    Length (in bytes) of uncrunch data block.

   Note finally that the routines do not clean up the stack after
   finishing (standard C calling convention).  It is up to the
   caller to remove the data parameters from the stack.
*/

extern int uncrunch ();

/*
   If your compiler can handle function prototypes and type void,
   you may prefer using the following header line.  It allows the
   compiler to perform better type checking.

extern void uncrunch (char far *sourceptr, char far *destptr, int length);
*/
