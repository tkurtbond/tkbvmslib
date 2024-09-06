(setq auto-mode-alist
      (cons '("\\.frgl$" . frgl-mode) auto-mode-alist))

(autoload 'frgl-mode "emx_lib:frgl-mode"
	  "Mode for editing FRGL programs" t)

(defun frgl-mode ()
  "Major mode for editing FRGL programs; same as indented-text-mode, 
but with proper comment settings."
  (interactive)
  (kill-all-local-variables)
  (indented-text-mode)
  (make-local-variable 'comment-start)
  (setq comment-start "!")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "!+[ 	]*")
  (make-local-variable 'comment-column)
  (setq comment-column 40)
  (make-local-variable 'comment-indent-hook)
  (setq comment-indent-hook 'tkb-comment-indent))
