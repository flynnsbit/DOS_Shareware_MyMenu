/* dampinp.sh

   Header file for DAMP input drivers.

   !DO NOT MODIFY THIS FILE!
*/

/* The next line makes sure we include the common core */
#include "dampcore.sh"

/* First we must export our functions, so they can be called by DAMP */
export input_driver_init;
export input_driver_poll;

/* Now we import all the driver variables */
import char input_driver_name[256];
import char input_driver_author[256];
import char input_driver_author_email[256];
import char input_driver_description[256];
import float input_driver_version;

import int input_driver_return_value;

/* And the functions */
import int util_quit();
import int util_screenshot();
import int util_previous_track();
import int util_next_track();
import int util_random_toggle();
import int util_scroll_track_title();
import int util_surround_toggle();
import int util_volume_up();
import int util_volume_down();
import int util_graphics_toggle();
import int util_pause();
import int util_pad(int, int);
import int util_previous_playlist();
import int util_next_playlist();
import int util_rewind();
import int util_fast_forward();
import int util_continuous_toggle();
import int util_sync_toggle();
import int util_time_remain_toggle();

import int kbhit();
import char getch();
import int remove_keyboard();
