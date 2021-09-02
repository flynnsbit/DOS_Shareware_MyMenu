;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;; all messages that need translation here

(setq gamma_msg "Click on the darkest color visible \n on your monitor for each spectrum")
(setq telep_msg "Press down to teleport")

(defun get_train_msg (message_num)
  (select message_num	  
	  (0 "Aim gun with mouse, fire with left mouse button")
	  (1 "Collect ammo to increase firing speed")
	  (2 "Press the down arrow to activate objects, this is a switch")
	  (3 "This console saves the state of the game, press down")
	  (4 "Press down to activate platform")
	  (5 "Hold down the right mouse button to use special powers")
	  (6 "Click with the RIGHT mouse button to select weapons")
	  (7 "Press the up arrow to climb ladders")
	  (8 "Press the down arrow to start!")
	  (9 "Shoot hidden walls to destroy them")
	  (10 "Shoot switch ball to activate")
	  ))
	 
(setq to_be_continued "To be continued.....")

(setq load_warn nil)
(if (not (load "register/english.lsp"))
    (setq end_msg 
	  (concatenate 'string "Thank you for playing Abuse.\n\n"
		       "* To use Abuse's builtin level editor, type :\n"
		       "  'abuse -edit' when you start the game.  It is highly recommended\n"
		       "  that you print out the key listing from abuse.doc and learn them.\n\n"
		       "* Read gamedev.txt for information on how you can make money with the\n"
		       "  levels you design.\n\n"
		       "* Edit lisp/options.lsp to configure a few options for abuse\n\n"
		       "* Buy commercial abuse and mow down aliens with the Plasma rifle,\n"
		       "  build up an army of Death frizbees for senseless destruction,\n"
		       "  or wave your Light saber around and watch the body parts fly\n\n"
		       "* Get 14 more levels with new artwork, new sounds, and new characters.\n"
		       "  call 1-800-810-0022.  Check or credit card accepted.  The order\n"
		       "  hotline is open 24hrs/day 7 days a week.\n\n")))
(setq load_warn T)

(setq plot_start
      (concatenate 'string 
		   "  The Ants were fearless, efficient killers.  The Unified Underground's "
		   "only opening was that the Ant defense systems were designed by engineers "
		   "too arrogant to consider the threat of an individual.  It was enough to "
		   "justify the covert Abuse Missions.\\n"
		   "  On August 31, 2021, eight bytes were zeroed in a computer, and Nick "
		   "Vrenna's identity was erased.  A suit of armor cradling a smoking auto "
		   "rifle stood in shadows appreciating the stench coming from the first "
		   "retired Ant of the day.  The armored soul feared the effort would end up "
		   "as pathetic as the Terran Surrender Terms, but humanity had nothing "
		   "else. "))

(setq plot_middle
      (concatenate 'string 
		   "Against all hope, the first leg of the Abuse Missions was a success, "
		   "thought the armor while being wrenched through the site-teleporter to "
		   "god knows where.  But the congratulations were empty.  This much was "
		   "clearly a front.  The real action lay ahead.. "))


(setq plot_end
      (concatenate 'string 
		   "The armor went into it knowing what came next.  Even as the solid "
		   "coolant module was removed, the messy reaction started its jagged "
		   "growth.  Nick died when his identity record was zeroed out.  It wasn't "
		   "bad a second time.  The peace was welcome. "))
