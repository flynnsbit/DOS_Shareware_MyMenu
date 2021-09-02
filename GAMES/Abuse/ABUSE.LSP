;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;(trace)
(perm-space)
(setq load_warn nil)
(if (not (load "lisp/common.lsp"))
    (progn
      (print "Please make sure you unzipped the game with the -d option")
      (print "so that all directories get created properly.")      
      (print "example : pkunzip -d abusXXXX.zip")      
      (quit)))
(setq load_warn T)


(load "lisp/options.lsp")     
(load "lisp/startup.lsp")
(load "lisp/input.lsp")
(load "lisp/userfuns.lsp")
(load "lisp/sfx.lsp")
(load "lisp/gates.lsp")
(load "lisp/duong.lsp")
(load "lisp/ant.lsp")
(load "lisp/people.lsp")
(load "lisp/weapons.lsp")
(load "lisp/explo.lsp")
(load "lisp/platform.lsp")
(load "lisp/guns.lsp")
(load "lisp/jugger.lsp")
(load "lisp/flyer.lsp")
(load "lisp/teleport.lsp")
(load "lisp/general.lsp")
(load "lisp/powerup.lsp")
(load "lisp/doors.lsp")
(load "lisp/light.lsp")
(load "lisp/ladder.lsp")
(load "lisp/switch.lsp")

(setq bad_guy_list (list DARNEL ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT))

(gc)              ;; garbage collection perm space
(tmp-space)       ;; execute game code in tmp space which is not GC'ed
(create_players DARNEL)
