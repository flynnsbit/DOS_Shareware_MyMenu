
echo on
mode COM1 BAUDHARD=1152
echo root > COM1
echo 1 > COM1

echo mpg123 --list /media/fat/mp3/doom/doom.pls > COM1
