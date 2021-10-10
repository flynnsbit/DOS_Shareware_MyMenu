/*
   damplcd.sh
   This is a set of standard things which could be needed by an
   LCD driver.

   ! DO NOT MODIFY THIS FILE !
*/

/* The next line makes sure we include the common core */
#include "dampcore.sh"

/* First we must export our functions, so they can be called by DAMP */
export lcd_driver_init;
export lcd_driver_clear;
export lcd_driver_home;
export lcd_driver_printf;

/* Now we import all the driver variables */
import char lcd_surround_symbol;
import char lcd_play_symbol;
import char lcd_random_symbol;
import char lcd_rew_symbol;
import char lcd_continuous_symbol;
import char lcd_driver_name[256];
import char lcd_driver_author[256];
import char lcd_driver_author_email[256];
import char lcd_driver_description[256];
import float lcd_driver_version;

import int lcd_display_width;
import int lcd_display_lines;

import unsigned char lcd_line[2][41];

import int damp_vu;              /* vu-meter level 0-63 */
import int damp_random_play;     /* is random play enabled? */
import int damp_surround;        /* is surround sound enabled? */
import int damp_paused;          /* is DAMP paused? */
import int damp_volume;          /* Volume level 0-255 */
import char damp_status[10];     /* eg: PLAY> PAUSE FFWD>> <<REW etc. */

import char damp_filename[256];  /* Filename */
import char damp_playlist_filename[1024]; /* Current playlist filename */
import char damp_playlist_filename_short[256]; /* Current playlist filename (without path) */

import char damp_id3_title[31];  /* ID3 title */
import char damp_id3_artist[31]; /* ID3 artist */
import char damp_id3_album[31];  /* ID3 album */
import char damp_id3_year[5];    /* ID3 year */
import char damp_id3_comment[30];   /* ID3 comment */
import char damp_id3_genre[64];   /* ID3 genre name or "NONE" */
import char damp_time[5];        /* Track time xx:xx */
import char damp_time_remaining[5]; /* Track time remaining xx:xx */
import int damp_track_number;    /* Track number */
import char damp_selection_buffer;  /* Track number being selected on keypad */
