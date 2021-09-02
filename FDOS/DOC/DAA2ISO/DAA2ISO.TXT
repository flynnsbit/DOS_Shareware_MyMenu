######################################################################

Title:  DAA2ISO / GBI2ISO
Author: Luigi Auriemma
e-mail: aluigi@autistici.org
web:    aluigi.org

DAA2ISO homepage:
        http://aluigi.org/mytoolz.htm#daa2iso

######################################################################

1) Introduction
2) Usage on Windows
3) Usage on *nix/MacOSX
4) Features and known bugs
5) Technical info about the format
6) Comments about the DAA format

######################################################################

===============
1) Introduction
===============

DAA2ISO is an open source command-line/GUI tool for converting single
and multipart DAA and GBI images to the original ISO format.

The DAA image (Direct Access Archive) in fact is just a compressed
CD/DVD ISO which can be created through the commercial program
PowerISO.


######################################################################

===================
2) Usage on Windows
===================

Using DAA2ISO on Windows is really a joke, just double click on
DAA2ISO.exe and the tool will open a DOS-like window which contains
all the needed informations about the status of conversion, then you
will need to choose the input DAA file you want to convert and
subsequently the name of the ISO file you want to create.

The tool automatically supports multipart files so it's enough that
you select only the first one (like file.part01.daa).

If you want to use the tool from the command-line, so specifying the
input and output files manually as in the older versions of the tool,
you can do it too since DAA2ISO automatically recognizes if it has
been launched from the console (cmd.exe) or through double-click.
Just specify the input DAA file and the output ISO file you want to
create like in the examples of the subsequent section.

Remember that you can also associate the DAA extension to DAA2ISO, so
when you will double-click on these files DAA2ISO will popup and will
allow you to choose the output ISO immediately or you can also
drag'n'drop the DAA file directly on DAA2ISO.EXE.

Note that DAA2ISO is a stand-alone program, so all you need to have is
just DAA2ISO.EXE and you can place it everywhere you want.


######################################################################

=======================
3) Usage on *nix/MacOSX
=======================

Compile the source code using 'make', this will generate the DAA2ISO
executable.
If you want to install it type 'make install' or just copy the
executable where you want since it's the only file you need.

Using it then it's simple, just specify the input file and the ISO
file you want to create like the following example:

  daa2iso "my file.daa" output.iso
or
  daa2iso "my file.part01.daa" output.iso


######################################################################

==========================
4) Features and known bugs
==========================

The tool supports password/encryption, multiple volumes, little/big
endian architectures and should work on many platforms (Windows,
Linux, MacOS, *BSD, Amiga and others).

The only known micro-bug is that on Windows 95/98/ME works only the so
called GUI version because the method I use to know if the program has
been launched from the console or through double-click is not
compatible with this OS, anyway this is not a problem since the 99% of
the Windows users don't like the command-line 8-)

From version 0.1.7 daa2iso is no longer zlib dependent, I have adopted
the tinf library of Joergen Ibsen available on
http://www.ibsensoftware.com/download.html because it's tiny, simple
and was a joke to modify it for adding the needed changes for
compatibility with PowerISO.
Instead the LZMA decompression library comes from Igor Pavlov of
http://www.7-zip.org.

I'm available for any comment or feedback, so if you find a
compatibility problem with a specific DAA image (and you are sure that
the image is perfect) send me a mail.


######################################################################

==================================
5) Technical info about the format
==================================

DAA2ISO is open source so there is nothing better than its source code
for explaining in detail this file format.

In short DAA is only a simple ISO compressed image, so it can't handle
audio or mixed/extra content but only the good old ISO data.


######################################################################

================================
6) Comments about the DAA format
================================

I don't like and don't approve the DAA format because it's proprietary
and doesn't give benefits.
What you can do with DAA can be done better with ZIP or 7zip without
the need to be forced to buy a software like PowerISO only for burning
an image.

Ok exists my tool which can do the job but this is not a valid reason
to continue to use this useless format.

So if you want to create a CD/DVD image, DO NOT USE DAA!


######################################################################
