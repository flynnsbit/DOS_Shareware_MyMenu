/*
   HD44780 16x2 Wiring-scheme 2 LCD driver for DAMP
   By Klaus Peichl
*/

/* Including damplcd.sh will do all the importing and exporting of the
   generic things required by our driver */

#include "damplcd.sh"

/* Now we'll define some constants */

const short LCD_PORTADDRESS = 0x378;
const short LCD_DATA = 0x378;
const short LCD_STATUS = 0x379;
const short LCD_CONTROL = 0x37a;



/*===========================================================================
  void lcd_driver_command(char cmd)

  This function issues a command for the lcd.
  Examples:   1   = clear
              2   = home
            128+x = Set cursor to character x
  =========================================================================*/

void lcd_driver_command(char cmd)
{

   /* Reset Register Select => LCD treats next data as a command */
   outportb(LCD_CONTROL, inportb(LCD_CONTROL) & 0xFB);

   /* Send the command */
   outportb(LCD_DATA, cmd);

   /* Raise Enable signal */
   outportb(LCD_CONTROL,inportb(LCD_CONTROL) | 0x08);

   /* Keep the Enable level a short time */
   delay(2);

   /* Reset Enable signal */
   outportb(LCD_CONTROL,inportb(LCD_CONTROL) & 0xF7);

   /* Let the LCD do the command (clear and home may take 1.64ms) */
   delay(20);
}


/*===========================================================================
  void lcd_driver_char(char chr)

  This function sends a data byte to the lcd. The byte is interpreted
  either as a character to display at the current cursor position or
  as character generator RAM data for user defined characters.
  =========================================================================*/

void lcd_driver_char(char chr)
{
   /* Set Register Select => LCD gets data not a command */
   outportb(LCD_CONTROL, inportb((short)LCD_CONTROL) | 0x04);

   /* Send the character */
   outportb(LCD_DATA, chr);

   /* Set Enable signal */
   outportb(LCD_CONTROL,inportb(LCD_CONTROL) | 0x08);

   // You might need a delay here on fast PCs.
   // On my 6x86MX-PR200, no delay is required.
   //   delay(1);

   /* Reset Enable signal */
   outportb(LCD_CONTROL,inportb(LCD_CONTROL) & 0xF7);

   /* Reset Register Select */
   outportb(LCD_CONTROL, inportb(LCD_CONTROL) & 0xFB);
}


/*===========================================================================
  void lcd_driver_init()

  This function should set-up the LCD, clear it, and return the cursor
  to the home position.
  =========================================================================*/

void lcd_driver_init()
{
   int n;
   char command[4];
   char b;

   /* First we put our driver details into the appropriate variables */
   sprintf(lcd_driver_name,"HD44780 16x2 Driver 2");
   sprintf(lcd_driver_author,"Klaus Peichl");
   sprintf(lcd_driver_author_email,"pei@iis.fhg.de");
   sprintf(lcd_driver_description,"HD44780 16x2 Driver for Wiring Scheme 2");
   lcd_driver_version = 1.5;

   /* Setup what characters we'd like to use for the various symbols */
   lcd_surround_symbol = 219;
   lcd_play_symbol = 62;
   lcd_random_symbol = 63;
   lcd_rew_symbol = 60;
   lcd_continuous_symbol = 'C';

   /* Now we'll initialise the LCD */

   command[0] = 0x0F; /* Init command*/
   command[1] = 0x01; /* Clear command */
   command[2] = 0x38; /* Dual Line / 8 Bits command */
   command[3] = 0x0C; /* Cursor OFF */

   b = inportb(LCD_CONTROL);
   outportb(LCD_CONTROL, b & 0xDF); 
   /* Reset Control Port - Make sure Forward Direction */

   for (n = 0; n < 4; n++)
   {
      lcd_driver_command(command[n]);
   }
}

/*===========================================================================
  void lcd_driver_clear()

  This function should clear the LCD display.
  =========================================================================*/

void lcd_driver_clear()
{
   char command = 0x01;

   lcd_driver_command(command);
}


/*===========================================================================
  void lcd_driver_home()

  This function should return the LCD cursor to the home position.
  =========================================================================*/

void lcd_driver_home()
{
   char command = 0x02;

   lcd_driver_command(command);
}


/*==========================================================================
  void lcd_driver_printf()

  This function should take the two strings lcd_line[0] and lcd_line[1] and
  output them onto the top and bottom lines of the LCD.
  ========================================================================*/

void lcd_driver_printf()
{
   int n;
   const char blank='.';
   char  cmd;

   /* If damp_developer is TRUE, we will output some debugging info
      (in this case, we'll output a representation of what should be
      on the LCD) */

   if(damp_developer)
   {
      gotoxy(1,wherey()-4);
      printf("[--------------]\n");
   }



   /* Output the top line */

   cmd=128+0;
   lcd_driver_command(cmd);

   for(n=0;n<lcd_display_width;n++)
   {
      if(damp_developer) printf("%c",lcd_line[0][n]);

      /* Send the character */
      lcd_driver_char(lcd_line[0][n]);

   }

   if(damp_developer) printf("\n");

   /* Output the second line */

   /* Set LCD Cursor to 64th character (beginning of second line): */
   cmd=128+64;
   lcd_driver_command(cmd);

   for(n=0;n<lcd_display_width;n++)
   {
      if(damp_developer) printf("%c",lcd_line[1][n]);

      /* Send the character */
      lcd_driver_char(lcd_line[1][n]);

   }

   if(damp_developer)
   {
      printf("\n");
      printf("[--------------]\n");
   }
}

