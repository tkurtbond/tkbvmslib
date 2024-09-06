(defun dcl-indent-line ()
  "Indent a DCL line."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (not (looking-at "\\$"))
	0
      )))


(defun dcl-indent-level ()
  "Compute the indentation necessary for a DCL line,
depending on context."
  (interactive))



(defun dcl-comment-indent ()
  "Compute indent for an DCL comment.
Puts a full-stop before comments on a line by themselves."
  (let ((pt (point)))
    (unwind-protect
	(progn
	  (skip-chars-backward " \t")
	  (if (bolp)
	      (progn
		(setq pt (1+ pt))
		(insert ?$)
		1)
	    (if (save-excursion
		  (backward-char 1)
		  (looking-at "^\\$"))
		1
	      (max comment-column
		   (* 8 (/ (+ (current-column)
			      9) 8)))))) ; add 9 to ensure at least two blanks
      (goto-char pt))))

(defun forward-dcl-line (&optional cnt)
  "Go forward one DCL line, skipping lines of comments.
An argument is a repeat count; if negative, move backward."
  (interactive "p")
  (if (not cnt) (setq cnt 1))
  (while (and (> cnt 0) (not (eobp)))
    (forward-line 1)
    (while (and (not (eobp)) (looking-at "\\$[ \t]*!"))
      (forward-line 1))
    (setq cnt (- cnt 1)))
  (while (and (< cnt 0) (not (bobp)))
    (forward-line -1)
    (while (and (not (bobp))
		(looking-at "\\$[ \t]*!"))
      (forward-line -1))
    (setq cnt (+ cnt 1)))
  cnt)

(defun backward-dcl-line (&optional cnt)
  "Go backward one DCL line, skipping lines of comments.
An argument is a repeat count; negative means move forward."
  (interactive "p")
  (forward-dcl-line (- cnt)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun nroff-comment-indent ()
  "Compute indent for an nroff/troff comment.
Puts a full-stop before comments on a line by themselves."
  (let ((pt (point)))
    (unwind-protect
	(progn
	  (skip-chars-backward " \t")
	  (if (bolp)
	      (progn
		(setq pt (1+ pt))
		(insert ?.)
		1)
	    (if (save-excursion
		  (backward-char 1)
		  (looking-at "^\\."))
		1
	      (max comment-column
		   (* 8 (/ (+ (current-column)
			      9) 8)))))) ; add 9 to ensure at least two blanks
      (goto-char pt))))
