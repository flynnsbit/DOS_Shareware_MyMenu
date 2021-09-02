;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun key_ai () (if (touching_bg) 
		     (progn 
		       (play_sound YEAH_SOUND 127 (x) (y))
		       nil) T))

(defun hp_up () 
	(next_picture)

	(if (and (touching_bg) (with_object (bg) (give_player_health 20)))
	   (progn
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))


(def_char HEALTH
  (funs (ai_fun hp_up))
  (flags (add_front T))
  (range 0 0)
  (states "art/ball.spe" (stopped "heart" )))


(defun fast_ai () 
  (next_picture)
  (if (touching_bg) 
      (progn (with_object (bg) 
			  (progn
			    (setq special_power FAST_POWER)
;			    (user_fun SET_FAST_TIME 360)
			    (make_view_solid (find_rgb 255 255 255))))
	     nil) T))


(defun fast_cache (type) (list nil (list fast_image)))

(def_char POWER_FAST
  (funs (ai_fun fast_ai)
	(get_cache_list_fun fast_cache))
  (flags (add_front T))
  (range 20 20)
  (states "art/misc.spe" (stopped "fast" )))



(setq load_warn nil)
(load "register/powerup.lsp")
(setq load_warn T)
