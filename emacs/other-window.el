;;; Subject: Performing functions in "the other window"
;;; There is a whole series of operations that can be performed "in the
;;; other window", all starting with "C-x 4".  It seemed that the support
;;; code for the other-window-ness of these operations should be in one
;;; function, so I wrote up the following function to do so.  As written,
;;; it causes "C-x 6 anything" to do "C-x anything" in the other window,
;;; and "ESC 6 anything" to do "ESC anything" in the other window, and if
;;; you bind perform-operation-in-other-window to a two-character sequence
;;; starting with any particular prefix key, it will extend the operations
of that prefix key to operate on the other window.

(defun perform-operation-in-other-window (prefix)
  "Performs an operation in the other window.
Prompts for the remainder of a multi-key command sequence, goes to the other
window, and executes the command.  The multi-key command sequence is assumed
to start with the first character that this command was invoked with.  Thus,
if it is invoked with C-x 6, then C-x 6 m invokes the command bound to C-x m
in the other window, and if it is invoked with ESC 6, then ESC 6 . invokes
the command bound to ESC . in the other window.  For this purpose, meta-ized
keys are treated as a two-key sequence starting with ESC.  Any prefix argument
is passed to the invoked command."
  (interactive "P")
  (let ((first-key (string-to-char (this-command-keys))))
    (if (>= first-key 128)
	(setq first-key ?\e))
    (setq unread-command-char first-key)
    (let ((key-sequence (read-key-sequence nil)))
      (other-window 1)
      (setq prefix-arg prefix)
      (call-interactively (key-binding key-sequence)))))

(global-set-key "\C-x6" 'perform-operation-in-other-window)
;(global-set-key "\e6" 'perform-operation-in-other-window)

