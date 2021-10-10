/* ICONSOLE.sc

   Input driver for DAMP by Matt Craven.
   This driver just takes standard input from the console
   in order to control DAMP.

   It is meant as an example of how to write an input driver,
   and is not really intended for major use.
*/

/* We MUST have the next line: */
#include "dampinp.sh"

/*===========================================================================
  input_driver_init()

  This function is called when DAMP starts up, and should initialise
  the input device appropriately.
===========================================================================*/

void input_driver_init()
{
   /* If damp_developer is non-zero, we should output debugging
      information */

   if(damp_developer)
      printf("input_driver_init(): Beginning initialisation.\n");

   /* The very first thing to do, is setup all the driver information */

   sprintf(input_driver_name,"Console Input Driver");
   sprintf(input_driver_author,"Matt Craven");
   sprintf(input_driver_author_email,"matt@damp-mp3.co.uk");
   sprintf(input_driver_description,"Input driver for standard console input");
   input_driver_version = 1.0;

   /* Then we want to remove the DAMP low-level keyboard driver. Note
      that this will NOT be the case for most other drivers, just ones
      that use the keyboard. */

   remove_keyboard();

   /* For this simple case, we'll just make sure the keyboard
      buffer is empty. */

   while(kbhit()) getch();

   if(damp_developer)
      printf("input_driver_init(): Initialisation successful.\n");
}

/*===========================================================================
  input_driver_poll()

  This is called regularly by DAMP.  It should check for input and call
  the appropriate util_* function to perform the desired action.

  It should set input_driver_return_value to the value that the
  util_* function returns, or 0 if you don't call any util_* functions.
===========================================================================*/

void input_driver_poll()
{
   char i;

   input_driver_return_value = 0;

   if(kbhit())
   {
      i = getch();

      switch(i)
      {
         case 27:    /* ESC key */
            input_driver_return_value = util_quit();
            break;

         case '-':  /* Volume down */
         case '_':  /* (in case shift was pressed or caps lock was on) */
            input_driver_return_value = util_volume_down();
            break;

         case '=':  /* Volume up */
         case '+':
            input_driver_return_value = util_volume_up();
            break;

         case ',':  /* Previous track */
         case '<':
            input_driver_return_value = util_previous_track();
            break;

         case '.':  /* Next track */
         case '>':
            input_driver_return_value = util_next_track();
            break;

         case 'r':  /* Random play toggle */
         case 'R':
            input_driver_return_value = util_random_toggle();
            break;

         case 't':  /* Scroll track title (in gfx mode) */
         case 'T':
            input_driver_return_value = util_scroll_track_title();
            break;

         case 's':  /* Surround sound toggle */
         case 'S':
            input_driver_return_value = util_surround_toggle();
            break;

         case 'g':  /* Graphics toggle */
         case 'G':
            input_driver_return_value = util_graphics_toggle();
            break;

         case 'p':  /* Pause */
         case 'P':
            input_driver_return_value = util_pause();
            break;

         case 'z':  /* Previous playlist */
         case 'Z':
            input_driver_return_value = util_previous_playlist();
            break;

         case 'x':  /* Next playlist */
         case 'X':
            input_driver_return_value = util_next_playlist();
            break;

         case '[':  /* Rewind */
         case '{':
            input_driver_return_value = util_rewind();
            break;

         case ']':  /* Fast forward */
         case '}':
            input_driver_return_value = util_fast_forward();
            break;

         /* And now the number keys for track selection */

         case '1':
            input_driver_return_value = util_pad(1, 0);
            break;
         case '2':
            input_driver_return_value = util_pad(2, 0);
            break;
         case '3':
            input_driver_return_value = util_pad(3, 0);
            break;
         case '4':
            input_driver_return_value = util_pad(4, 0);
            break;
         case '5':
            input_driver_return_value = util_pad(5, 0);
            break;
         case '6':
            input_driver_return_value = util_pad(6, 0);
            break;
         case '7':
            input_driver_return_value = util_pad(7, 0);
            break;
         case '8':
            input_driver_return_value = util_pad(8, 0);
            break;
         case '9':
            input_driver_return_value = util_pad(9, 0);
            break;
         case '0':
            input_driver_return_value = util_pad(0, 0);
            break;

         /* And now with shift pressed, for playlist selection */

         case '!':
            input_driver_return_value = util_pad(1, 1);
            break;
         case '\"':
            input_driver_return_value = util_pad(2, 1);
            break;
         case 'œ':
            input_driver_return_value = util_pad(3, 1);
            break;
         case '$':
            input_driver_return_value = util_pad(4, 1);
            break;
         case '\%':
            input_driver_return_value = util_pad(5, 1);
            break;
         case '^':
            input_driver_return_value = util_pad(6, 1);
            break;
         case '&':
            input_driver_return_value = util_pad(7, 1);
            break;
         case '*':
            input_driver_return_value = util_pad(8, 1);
            break;
         case '(':
            input_driver_return_value = util_pad(9, 1);
            break;
         case ')':
            input_driver_return_value = util_pad(0, 1);
            break;

      }
   }
}
