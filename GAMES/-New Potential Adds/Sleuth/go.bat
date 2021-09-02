echo off
dir /w
echo ÿ
echo The documentation for this program is stored in files on the disk.
echo Look at the file names above for names with README or MANUAL or DOC in them.
echo You can view these text files on the screen by entering at the DOS prompt:
echo                             TYPE filename.ext
echo           (substitute the actual filename and extension, of course)
echo This will cause the documentation to scroll by faster than you can read it.
echo So we recommend the use of a utility such as Vernon Buerg's LIST program
echo that will let you scroll and page up and down through a file. LIST is on disk
echo 1-UT-274 in The Public (Software) Library, P.O.Box 35705, Houston, TX 77235.
echo ÿ
echo You can also print the documentation by entering at the DOS prompt:
echo                            COPY filename.ext PRN
echo            (for more info on TYPE and COPY, see your DOS manual)
echo ÿ
pause
cls
echo ÿ
echo If there are any batch files on the disk (files with a BAT extension), they
echo may help you get going, but it's a good idea to see what they will do before
echo executing them. To do this, at the DOS prompt just enter
echo                              TYPE filename.BAT
echo Some programs have batch files that will print the documentation for you.
echo ÿ
echo A very few programs don't have documentation files.
echo They are self-documenting when run.
echo ÿ
echo Programs with an extension of BAS require you to load BASIC, BASICA or GWBASIC
echo to run the program.
echo ÿ
echo If you still have questions about how to get the documentation or how to run
echo the programs, get the "Introductory" disk from the Public (Software) Library.
echo ÿ
pause
cls
echo                         The Public (Software) Library
echo                    P.O.Box 35705  Houston, TX 35705-5705
echo                                (713) 721-6104
echo ÿ
echo         Our software library  is the result  of a great  deal of hard
echo         work  and  expense  in  acquiring,  testing,  organizing  and
echo         supporting public domain and shareware programs.
echo ÿ
echo         The disk fee  which you have  paid to us  covers our cost  of
echo         providing the above (and other) services. It does not include
echo         any compensation to the author of the program.
echo ÿ
echo         Most small programs that were quickly and easily written  and
echo         require no updates nor support are public domain.  The author
echo         asks  nothing  in return  and gets his satisfaction just from
echo         knowing that others are using and enjoying his work.
echo ÿ
echo         However, most of the large programs (and sometimes the small,
echo         but complex  programs) required  an extensive  amount of pro-
echo         gramming, debugging, testing, documenting and will benefit by
echo         future enhancements and on-going support.
echo ÿ
pause
cls
echo         Many of these programs  are commercial quality or  better and
echo         most are copyrighted,  but  the authors allow their  programs
echo         to be copied so  that others can try  them. This is known  as
echo         Shareware. (But not all programs in our library may be freely
echo         copied. Check the documentation for each.)
echo ÿ
echo         The documentation file on this disk will tell you the  amount
echo         that the author would like to receive if you try the  program
echo         and  decide  to  keep  using  it.  To encourage payment, some
echo         programmers offer more advanced versions, printed manuals and
echo         other incentives.
echo ÿ
echo         But even those that don't offer incentives still deserve your
echo         financial support  and encouragement  for the  work they have
echo         done.  This is  your moral obligation if you are  using their
echo         program. But beyond being an obligation, it is an  investment
echo         in the future of "shareware"  for which you will be  rewarded
echo         with more and better programs as a result of your support.
echo ÿ
echo ÿ
pause
cls
if exist read*.* dir read*.*
if exist manual*.* dir manual*.*
if exist *.doc dir *.doc
echo ÿ
echo       If any files are listed above, these are the ones to TYPE first
echo       (eg: TYPE READ.ME); otherwise, just try running the program.
