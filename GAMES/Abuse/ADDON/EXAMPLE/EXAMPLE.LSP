;;;; This file shows how to create a abuse level which uses your own
;;;; tiles without messing up the main abuse direcory structure & files.
;;;; The first important point is where to put your stuff.

;;;; All addons to abuse should be placed in the directory addon/
;;;; Abuse does not require this to be done, but it's a good idea so the
;;;; user can easily find/install/remove various addons.
;;;; if you do not already have the directory c:\abuse\addon, make it now.

;;;; If you created foretiles for abuse (using satan paint) you should 
;;;; start numbering them at 1200 because the last of the registered
;;;; tiles end at 1100 something.  Backtiles should start numbering at 350.

;;;; To have your tiles loaded into the game, you should create your
;;;; own Lisp Startup File (you can just copy this file and replace
;;;; the names with your own.

;;;; ****************** RUNNING PACKAGES *******************
;;;; For example to run this package, you should type :
;;;; abuse -lsf addon/example/example.lsp

;;;; ****************** CREATING PACKAGES *******************
;;;; to archive this package you should do the following
;;;;   DOS : 
;;;;     cd c:\abuse\addon
;;;;     pkzip -rp example.zip example\*.*
;;;;   UNIX :
;;;;     cd ~/abuse/addon
;;;;     tar cvf - example/ | gzip -9 -c > example.tar.gz


;;;; ****************** INSTALLING PACKAGES *******************
;;;; to install this package you should type
;;;;   DOS :
;;;;     cd c:\abuse\addon
;;;;     pkunzip -d example.zip
;;;;   UNIX :
;;;;     cd ~/abuse/addon
;;;;     gunzip -c example.tar.gz | tar xvf -




;;;; Now the meat of this package :
;;;; Note that slashes should be FORWARD slashes even if 
;;;; you are using DOS

;; load up some tiles I made.  You can add more filenames
;; if you wish, but they should all be loaded from 'your' dir.
(load_tiles "addon/example/example.spe")   

;; set the first level to the one I made
(set_first_level "addon/example/example.lvl")  

;; load up the normal abuse startup file
(load "abuse.lsp")                       



