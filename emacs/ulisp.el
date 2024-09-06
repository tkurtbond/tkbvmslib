;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; vms-subprocess.el -- simple enhancements to subprocesses using mailboxes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar ul-load-file-name "sys$login:ulisp.tmp"
  "*String containing name of temporary file used for sending
expressions from emacs to under-LISP")

(defvar ul-load-command-name "load"
  "*String containing name of command to use to load temporary files
 used to send expressions from emacs to under-LISP")

(defvar ul-load-command-tail ""
  "*String contains options to pass to the command used to load
temporary files used to send expressions from emacs to under-LISP,
AFTER the file name")


(define-key command-mode-map "\C-j" 'command-send-input)
(define-key command-mode-map "\C-c\C-y" 'yank-xmit-to-subprocess)
(define-key command-mode-map "\C-xk" 'end-subprocess)

(defun yank-xmit-to-subprocess ()
  "Send contents of kill ring to VMS subprocess through a mailbox,
one line at a time to avoid problems with overflowing the mailbox."
  (interactive)
  (if kill-ring
      (let* ((text (car kill-ring))
	    (i 0)
	    (p (string-match "\n" text i)))
	(while p
	  (send-command-to-subprocess 1 (substring text i p))
	  (setq i (1+ p))
	  (setq p (string-match "\n" text i)))
	(send-command-to-subprocess 1 (substring text i)))))
	
	
(defun send-region-to-ulisp (p m)
  "Send the region to the *COMMAND* subprocess, which is
expected to be running a LISP.  The sexp is written to a file in the user's 
main (login) directory and a LOAD form is sent to the *COMMAND* subprocess to 
load it into the LISP."
  (interactive "d\nm")
  (write-region p m ul-load-file-name nil 'dont-write)
  (send-command-to-subprocess 
   1
   (concat "(" ul-load-command-name " \"" ul-load-file-name "\" "
	   ul-load-command-tail ")")))


(defun send-sexp-to-ulisp ()
  "Send the sexp before point to the *COMMAND* subprocess, which is
expected to be running a LISP.  The sexp is written to a file in the user's 
login directory and a LOAD form is sent to the *COMMAND* subprocess to 
load it into the LISP."
  (interactive)
  (save-excursion
    (let ((beg (point)) end)
      (backward-sexp)
      (setq end (point))
      (send-region-to-ulisp beg end))))


