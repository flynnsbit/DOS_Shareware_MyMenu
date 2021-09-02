*******************************************************************************
V8Power Tools
Copyright 2016 Jerome Shidel
Released under GPL v2.0 License.
*******************************************************************************

Putting the power of an 8-cylinder engine under the hood of DOS batch files.

===============================================================================

The V8Power Tools project is being designed in cooperation with
Jim Hall for the FreeDOS(TM) (http://www.freedos.org) operating system. It is
intended to expand the functionality of scripts written using batch files and
to provide them with a better looking user interface with increased
functionality.

===============================================================================

Compiling V8Power Tools

    Prerequisites:

        8086 or better cpu.
        EGA or better video adapter.
        FreeDOS(TM) 1.1 or higher (http://www.freedos.org)
        NASM for DOS version 2.11.08 (http://wwww.nasm.us)

    Compiling:

        Insure the NASM directory is in your path spec.
        Download the latest sources from http://github.com/LoopZ/V8Power
        Run the mkV8.bat script.
        All executibles will be placed in newly created BIN directory.

    For lazy people, like me:

        Precompiled versions are available at http://up.lod.bz/V8Power.

===============================================================================

V8Power Tools Tested Compatibility

    FreeDOS 1.1+

Limited compatiblilty of advanced features (no "set /p" batch support):

    MS-DOS 6.2 and 6.22
    PC-DOS 7.0, 7.01 and 2000
    DR-DOS 7.03
    DosBOX (i/o redirection or querying using stdout will NOT work)
    Windows 3.11 Shell
    Windows 98 Shell and Command Line
    Windows XP SP3 Shell (except vcursor)

===============================================================================

V8Power Tools Usage

Here is some basic information reguarding all utilities and how they operate.

    Options, values and hexidecimal numbers are not case specific /f white is
    the same as /F wHIte.

    Hexidecimal numbers may be prefixed with 0x to prevent them from being
    treated as base ten. (Example: 10 and 0x10)

    Spaces are mostly optional. /B7/f0 is the same as /B 7 /F 0.
    But, not / B7 / F0.

    To use a / or spaces in a value, put it in qoutes. Like "Jack and/or Jill".

    Use multiple qoutes to use quotes. Like "Jack's house" or 'Say "What?"'.

    Unless overriden, most utilities use the text attribute at the current
    cursor location.

===============================================================================

Here is color table used for all **/A**, **/F** and **/B** switches:

    Decimal     Hex         Label (Not case specific)

    0           0x00        Black
    1           0x01        Blue
    2           0x02        Green
    3           0x03        Cyan
    4           0x04        Red
    5           0x05        Magenta
    6           0x06        Brown
    7           0x07        Gray / Grey
    8           0x08        DarkGray / DarkGrey
    9           0x09        LightBlue
    10          0x0a        LightGreen
    11          0x0b        LightCyan
    12          0x0c        LightRed
    13          0x0d        LightMagenta
    14          0x0e        Yellow
    15          0x0f        White

-------------------------------------------------------------------------------

v8help [options]

Displays help text from V8Power Tools README.TXT document.

	[none]		Lists all V8Power Tools commands.
	command		Displays help for that V8Power Tool.

-------------------------------------------------------------------------------

vcls [options]

Clear screen, area or row (line).

    [none]      Clear the screen with the current text attribute.
    n           Set text attribute to n.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /G          Global Screen Clear. (Default)
    /L          Local Screen Clear. Detects its surroundings and only clears
                that.  Probably, a box or line or something. You don't really
                need this option. Because, you can just redraw the box, maybe.
    TEXT        Clear the text only. Leave all colors intact and ignore their
                color attributes.
    EOL         Clear from cursor to End of Line only.
    /C code     Clear by filling with an ASCII character code.
    /X column   Absolute screen column to start clear.
    /Y row      Absolute screen row to start clear.
    /W width    Total width of area to clear.
    /H height   Total height of area to clear.

-------------------------------------------------------------------------------

vcursor [options]

Change or query the cursor size and shape.

    [none]      Outputs the current cursor shape to STDOUT.
    n           Set the current cursor shape as n.
    HIDE        Hides the cursor.
    SMALL       Sets a small cursor.
    HALF        Sets the cursor to 1/2 of the text height.
    FULL        Sets the cursro to the full height of text.

Note: Although this utility is fully compatible with DOSBox, there is no
way to store the current cursor shape. See the examples, on how to work
around this issue. Also, this utility will not have any effect in a
Windows terminal.

-------------------------------------------------------------------------------

vdelay [ms]

Simple delay in milliseconds.

    [none]      Default is 1000ms (1 second) delay.
    ms          Delay for ms milliseconds. (0-65535, 0x0000-0xffff)
    /D          Detect method used for timing. (Not compatible with VirtualBox)
    /S          Use safe general purpose timer. (Default)
    /I          Use high precision interrupt timer. (Not compatible with
                VirtualBox)

-------------------------------------------------------------------------------

vecho [options] [text]

Output text to display.

    [none]      Preforms a Carriage Return and Line Feed to the display.
    text        Writes text to the display.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /N          Do not write a CRLF when done.
    /P          Perform a CRLF now.
    /S +        Insert a space character between parameters. (DEFAULT)
    /S -        Do not add space character between multiple parameters.
    /C code     Write an ASCII character code.
    /R times    Repeat the next write times number of times. (1-65535)
    /I          Write text that may waiting from the STDIN device.
    /G          Write text globally and ignore all framing.
    /L          Write text locally with regards to framing. (DEFAULT)
    /X code     Erase rest of line using ascii code, but don't move the cursor.
    /E          Same as using "/X 0x20" or "/X32".
    /T file ID  Look up ID in file and process it like command line options.
                Any additional options that follow this switch are used to
                populate %1-%9 variables in the text string.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vgotoxy [options]

Move or query cursor position.

    [none]      Preforms no action.
    /Q x or y   Queries the current X or Y position of the cursor and outputs
                it to STDOUT.
    /X column   Move cursor to column.
    /Y row      Move cursor to row.
    /G          Move cursor based on entire screen. (default)
    /L          Move cursor based on its surroundings.
    direction   Move cursor up, down, left or right one space.
    shift       Move cursor to the previous or next position and change
                rows if needed.
    position    Move cursor to the
                    SOP (Start of Page),
                    EOP (End of Page),
                    SOR (Start of Row),
                    EOR (End of Row),
                    SOL (Start of Text on Line),
                    EOL (End of Text on Line),
                    SOT (Start of All Text) or
                    EOT (End of All Text) position.

-------------------------------------------------------------------------------

vframe [options]

Draw a box windowing thingy and move cursor to its inside top left position.

    [none]      Draw a box that encloses the entire screen.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /X column   Screen column to start the box.
    /Y row      Screen row to start the box.
    /W width    Total width of the box.
    /H height   Total height of the box.
    /C          Centers the box horizontally and vertically.
    /T file ID  Look up ID in file and process it like command line options.
                Any additional options that follow this switch are used to
                populate %1-%9 variables in the text string.
    style       Box styles are Single, Double, SingleSides, DoubleSides
                and Hidden.
    shadow      Add a 3D style shadow.
    textbox     Draw a textbox style frame with a little padding and margins.
    optionbox   Draw a hidden style optionbox for choices inside a frame.

-------------------------------------------------------------------------------

vpcspkr [hz:][ms]

Generate a tone using the built in speaker.

    [none]      No output.
    hz:ms       Use the PC Speaker to generate a hz frequency tone. Then, delay
                for ms milliseconds. (Note: 0 frequency turns off speaker.
                If no frequency is provided then 0 is assumed)
    /D          Detect method used for timing. (Not compatible with VirtualBox)
    /S          Use safe general purpose timer. (Default)
    /I          Use high precision interrupt timer. (Not compatible with
                VirtualBox)

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vver [options]

V8Power information program.

    [none]      Outputs all info to STDOUT.
    all         Outputs all info to STDOUT.
    title       Outputs full title to STDOUT.
    copyright   Outputs the copyright message to STDOUT.
    version     Outputs the version information to STDOUT.
    license     Outputs license information to STDOUT.
    url         Outputs the website url information to STDOUT.
    email       Outputs email address to STDOUT.

-------------------------------------------------------------------------------

vprogres [options]

Draw a progress bar at current location without moving cursor.

    [none]      Draw a progress bar at 0%.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /W width    Override default width of the bar.
                (default is from cursor to end of line)
    value       Sets the value in a percent of progress.
    off         Do not display percentage number.
    align       Percentage number on left, center (Default) or right side of
                the progress bar.
    OF max      Calculate percentage of max. Example 5 of 7.


-------------------------------------------------------------------------------

vchoice [options]

Choose an option.

It returns an errorlevel of choice selected based on its entry number. Not
the letter/number of the choice. For example, if the second item is chosen,
it will return an errorlevel of 2. Regardless of any prefix (Like C, 1, R, etc).
Also, I personally recommend using auto for any set of choices that
you prefix with a letter or number.

    [none]      Perform using all automatic defaults settings.</td></tr>
    /A n        Set text attribute to n for selected item.
    /B color    Set the background text attribute to color (or a value) for
                selected item.
    /F color    Set the forground text attribute to color (or a value) for
                selected item.
    /D n        Preselect item number n as the default choice.
    type        Direct keypress selection type.
                    off     Select with only arrow keys.
                    auto    Detect direct jump characters. (Default)
                    alpha   Jump to selections using A-Z.
                    digit   Jump to selections using 1-9 (+0).
    /Q          Query for result. When the choice is made, it's text will be
                sent to STDOUT.
    /T seconds  Delay in seconds before the default item is automatically
                selected (0-3600). Note that even if the user navigates to a
                different item, the original default item will be selected when
                the timeout is achieved.
    /P n        Use polling mode and preselect item number n as the current
                choice. Note, any change of selection will exit vchoice and
                return 100+ the current choice number.
    CTRL-C      When specified and Control-C is pressed, will exit with
                errorlevel of 200.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vpause [options]

Simple wait for keypress or time-out.

    [none]      Wait forever for keypress.
    (/T)        Depreciated. Now, /D.
    /D seconds  Delay in seconds to wait before the pause times-out. (returns
                errorlevel 1)
    CTRL-C      When specified and Control-C is pressed, will exit with
                errorlevel of 200.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vline [options]

Draws a line.

    [none]      Draws as local single dumb line on the current row.
    single      Draws a single line.
    double      Draws a double line.
    hidden      Draws a invisible dumb line.
    dumb        Draws a dumb line without regard to what already exists.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vinfo [options]

General system information utility.

    [none]      Does nothing.
    /V          Verbose Mode.
    /D a        Test drive status.
                Returns these error codes:
                    15 - Not Present
                     5 - Not Formatted (for DOS)
                     4 - Network Drive (untested)
                     3 - CD/DVD-ROM (MSCDEX Only, most report error 15)
                     2 - Removable Media (like Floppy)
                     1 - (Reserved)
                     0 - No Special Conditions
    /M          Return Machine Type (This may break on future platforms)
                Returns these exit codes:
                    0 - Unknown, Normal or Native 8086 Hardware.
                    1 - 80186
                    2 - 80286
                    3 - 80386
                    4 - 80486
                    5 - 80586
                    6 - 80686 or better
                  101 - DOSBox.
                  102 - QEMU.
                  103 - VirtualBox.
                  104 - VMware.
                  200 - General, other emulator detected.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

verrlvl [options]

Sets current errorlevel. Mostly for testing batch file logic.

    [none]      Sets errorlevel to 0
    n           Sets errorlevel to n (0-255)

-------------------------------------------------------------------------------

vmath [options]

Super simple math utility. It is NOT as a calculator and is limited to working
on numbers from 0-32767. Good for looping, determining screen offsets and etc.

    +, ADD      Add next number to sum.
    -, SUB      Subtract next number from sum.
    *, MUL      Multiply sum by next number.
    /, DIV      Divide sum by next number.
    \, MOD      Divide sum by next number and set sum to the remainder.
    AND         Logical AND.
    OR          Logical OR.
    XOR         Logical XOR.
    SHR         Bit shift right.
    SHL         Bit shift left.

    /H          Set output to hexadecimal.
    /D          Set output to decimal.

-------------------------------------------------------------------------------

vstr [options]

Simple String processing utility. Outputs results to STDOUT.

    /N          Do not write a CRLF when done.
    /U          Input Filter: Convert to upper case.
    /D          Input Filter: Convert to lower case.
    /B          Input Filter: Ignore blank lines.
    /I          Input Filter: Ignore indentation.
    /C code     Write an ASCII character code.
    /R times    Repeat the next write times number of times. (1-65535)
    /L line     Return only this line from standard input. (0-65535)
                (Note: vline /L TOTAL will return the total number of lines.)
                Also, adding :n will output n number of lines.
    /S s1 s2    Search and replace all occurrences of s1 with s2.
    /F s1 s2    Set delimiter to s1 and only return field position or range s2.
    /T s2       Return tab field position or range s2.
    /P s1       Print text s1.

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vmode [options]

Set and query current video text modes.

    [none]      Outputs current video mode and font to STDOUT.
    VESA        Outputs a list of VESA modes to STDOUT.
    mode        Set current video mode. (0-0xffff) or a mode label with
                optional font setting.

                Modes:  BW40    Black and White 40 Column (also B40).
                        BW80    Black and White 80 Column (also B80, BW).
                        CO40    Color 40 Column (also C40).
                        CO80    Color 80 Column (also C80, COLOR).
                        MONO    Mono 80 Column.

                Fonts:  Font8   Select 8x8 ROM font. (also F8)
                        Font14  Select 8x14 EGA ROM font. (also F14)
                        Font16  Select 8x16 VGA ROM font. (also F16)

-------------------------------------------------------------------------------

vfdutil [options]

File and directory utility.

    [none]      Does nothing.
    /D file     Calculate and output drive letter of file to STDOUT.
    /P file     Calculate and output path of file to STDOUT.
    /C          Use before /D or /P to change drive or path without text output.
    /X          Use before /D or /P to return errorlevel 1-26 of drive letter.
    /F file     Calculate and output complete filename to STDOUT.
    /N file     Calculate and output file's basename to STDOUT.
    /E file     Calculate and output file's extension to STDOUT.
    /U template Calculate and output unique file/dir name based on template to
                STDOUT. The drive and path must exist.
                Example: "vfdutil /u C:\TEMP\TEST????.$$$"

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vask [options]

Prompt for text input.

    [none]      Use detected settings for input.
    [text]      Preset edited text.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /G          Input text globally and ignore all framing.
    /L          Input text locally with regards to framing. (DEFAULT)
    /C          When specified and Control-C is pressed, will exit with
                errorlevel of 200 and return the default value.
    /W width    Override default width of the bar.
                (default is from cursor to end of line)
    /T file ID  Look up ID in file and process it like command line options.
                Any additional options that follow this switch are used to
                populate %1-%9 variables in the text string.
    /D seconds  Delay in seconds to wait before the prompt times-out and
                returns the initial default value. (returns errorlevel 1)

    tba         (Still under development, more to be announced)

-------------------------------------------------------------------------------

vinsert [options]

Insert a blank row (line) at the current location.

    [none]      Insert a blank line.
    n           Insert n blank lines.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /G          Global Insert.
    /L          Local Insert. (Default)

-------------------------------------------------------------------------------

vdelete [options]

Delete row (line) at the current location.

    [none]      Delete line.
    n           Delete n lines.
    /A n        Set text attribute to n.
    /B color    Set the background text attribute to color (or a value).
    /F color    Set the forground text attribute to color (or a value).
    /G          Global Delete.
    /L          Local Delete. (Default)

-------------------------------------------------------------------------------

