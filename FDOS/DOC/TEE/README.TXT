TEE v2.0.3
Originally by Jim Hall
Rewritten by Alexis Malozemoff with heavy inspiration from the
GNU Coreutils-6.9 tee implementation

ABOUT

TEE reads data from standard input and writes to standard output as well 
as any files specified by the user.

EXAMPLES

To print "example" to standard output as well as log.txt:
	ECHO example | TEE log.txt

To append "example" to log.txt instead:
	ECHO example | TEE /A log.txt

BASIC INSTALLATION

TEE comes with two default builds.  TEE.EXE is TEE build with kitten support.
_TEE.EXE is built without kitten.

To compile TEE you need the OpenWatcom C compilation suite.
Simply type:
	wmake

This will compile the default installation of TEE.
You can then copy TEE.EXE to your BIN directory.
Additionally, if you compiled with KITTEN support, move the necessary
NLS file in the NLS directory to wherever you store your NLS files.

ADDITIONAL INSTALLATION OPTIONS

If you'd like internationalization through KITTEN, type:
	wmake kitten=yes

To delete all build files:
	wmake clean

To delete all build files and any executables created:
	wmake cleanall

To create a zip of the directory:
	wmake dist

INTERNATIONALIZATION

TEE uses the kitten library for internationalization.  
See the table below for current translations:

        LANGUAGE        CODE        KITTEN SUPPORT        HTML HELP

        English          EN                Y                  Y
        Esperanto        EO                Y                  
        German           DE                Y                  Y

COPYING

All files provided by the TEE source code are licensed under the GNU GPL v2.0
except the KITTEN library, which uses the GNU LGPL license.
These licenses are provided in the DOCS\ folder.

