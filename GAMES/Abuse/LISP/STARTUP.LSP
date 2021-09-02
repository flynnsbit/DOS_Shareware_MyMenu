;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(setq keep_backup T)                  ;; determines if Save

(setq load_warn nil)
(load "lastsave.lsp")
(load "lisp/english.lsp")             ;; load language specific stuff
(load "gamma.lsp")                    ;; load gamma correction values if they have been saved

(if (not (load "hardness.lsp"))       ;; load hardness, if no file set to hard
    (setf difficulty        'hard))
(setq load_warn T)

; *********** Defaults **************************

(setf sfx_directory     "sfx/")

;(load_big_font     "art/letters.spe" "letters")
(load_big_font     "art/screen11.spe" "screen11")
(load_small_font   "art/letters.spe" "small_font")
(load_console_font "art/consfnt.spe" "fnt5x7")
(load_color_filter "art/back/backgrnd.spe")
(load_palette      "art/back/backgrnd.spe")
(setq normal_tint (def_tint "art/back/backgrnd.spe"))


(load_tiles "art/fore/foregrnd.spe"
	    "art/fore/techno.spe"
	    "art/fore/techno2.spe"
	    "art/fore/techno3.spe"
	    "art/fore/techno4.spe"
	    "art/fore/cave.spe"

	    "art/back/intro.spe"
	    "art/back/city.spe"
	    "art/back/tech.spe"
	    "art/back/cave.spe"
	    "art/back/backgrnd.spe")

(setq load_warn nil)
(load "register/tiles.lsp")       ;; load up registered artwork if it's there
(setq load_warn T)

(setf title_screen      '("art/title.spe" . "title_screen"))
(setf logo              '("art/title.spe" . "cdc_logo"))

;(setf demos        '("demos/demo3"))
(setq help_screens '("art/help.spe" "sell1" "sell2" "sell4"))

(if (not (get_option "-f"))
    (progn
      (if skip_trainer_level
	  (set_first_level "levels/level01.spe")
	(set_first_level "levels/level00.spe"))))





