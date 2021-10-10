/*
   dampcore.sh
   This is a set of standard things which could be needed by any
   driver.

   ! DO NOT MODIFY THIS FILE !
*/

/* VARIABLES */

import int damp_developer;    /* This will be set to TRUE if we want
                                 debugging output */

/* The following variables are for exchanging information between the
   input and output drvers, if you want to do that... */

import int damp_shared_int;
import char damp_shared_char[1024];
//import long damp_shared_long;
import float damp_shared_float;

/* FUNCTIONS */

import void printf(char *,...);
import void sprintf(char *,char *,...);
import int strlen(char *);
import void gotoxy(int,int);
import int wherey();
import unsigned char inportb(unsigned short);
import void outportb(unsigned short, unsigned char);
import void delay(int);
import int bioscom(int,char,int);

