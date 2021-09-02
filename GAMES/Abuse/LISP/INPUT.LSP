;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights
;;(setf player1 'joystick)


;; note : this function is called by the game when it collects input from
;; the local player (the machine you are playing on in net games)
;; because it is only executed locally it should not change any global varible
;; Also the rest of the game should not use any input gathering routines such as
;; joy_stat & key_presed.

;;  The returned input from this routine is passed on to the server where it is
;; distributed to other clients.
;; The format for return is '(xv yv B1 B2 B3 mx my)

;; xv = movement left right (-1=left, 0=none, 1=right)
;; yv = movement up and down (-1=up,  0=none, 1=right)
;; B1 = using special power (T or nil)
;; B2 = firing button (T or nil)
;; B3 = toggle to weapons (-1 toggle weapons to the left, 0=no toggle, 1 toggle to the right)
;; mx = mouse x position on the screen
;; my = mouse y position on the screen

;; other possible key names for get_key_code include :
;;   "Up_Arrow","Down_Arrow","Left_Arrow","Right_Arrow",
;;   "Left_Ctrl","Right_Ctrl","Left_Alt","Right_Alt",
;;   "Left_Shift","Right_Shift","Caps_Lock","Num_Lock",
;;   "Home","End","Del","F1","F2","F3","F4","F5","F6",
;;   "F7","F8","F9","F10","Insert"
;;   "a", "b", "c", ... 
;; though not all of these keys will work on all operating systems


;; note : at this current time weapon toggle input is ignored and
;; CTRL & INS are used... sorry :)  These have to be event based,
;; not polled so no key pressed are missed.

(setq left-key          (get_key_code "left_arrow"))
(setq right-key         (get_key_code "right_arrow"))
(setq up-key            (get_key_code "up_arrow"))
(setq down-key          (get_key_code "down_arrow"))
(setq weapon-left-key   (get_key_code "right_ctrl"))
(setq weapon-right-key  (get_key_code "insert"))


(defun get_local_input ()
  (let ((mstat (mouse_stat)))
    (list (if (key_pressed left-key) -1 (if (key_pressed right-key) 1 0))  ;; xv 
	  (if (key_pressed up-key) -1   (if (key_pressed down-key)  1 0))  ;; yv
	  (eq (fourth mstat) 1)                                            ;; special button
	  (eq (third mstat) 1)                                             ;; fire button
	  (if (or (eq (fifth mstat) 1) 
		  (key_pressed weapon-left-key)) -1                             ;; weapon toggle
              (if (key_pressed weapon-right-key)  1 0))
	  (first mstat)                                                    ;; mx
	  (second mstat)                                                   ;; my
	  )))


	

	



