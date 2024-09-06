;;; vaxbasic.el -- mode for editing VAX BASIC program source.
;;; A Work In Progress; Very Crude.
;;; TAB runs indent-relative.  

(defvar vaxbasic-mode-abbrev-table nil
  "Abbrev table in use in vaxbasic-mode buffers.")
(define-abbrev-table 'vaxbasic-mode-abbrev-table ())

(defvar vaxbasic-mode-map ()
  "Keymap used in VAX BASIC mode.")
(if vaxbasic-mode-map
    ()
  (setq vaxbasic-mode-map (make-sparse-keymap))
  (define-key vaxbasic-mode-map "\e\C-a" 'beginning-of-vaxbasic-defun)
  (define-key vaxbasic-mode-map "\e\C-e" 'end-of-vaxbasic-defun)
  (define-key vaxbasic-mode-map "\e\C-h" 'mark-vaxbasic-function)
  (define-key vaxbasic-mode-map "\C-c\C-e" 'vaxbasic-mode-align-ampersand)
  (define-key vaxbasic-mode-map "\177" 'backward-delete-char-untabify)
  (define-key vaxbasic-mode-map "\t" 'indent-relative))

(defvar vaxbasic-mode-syntax-table nil
  "Syntax table in use in Vaxbasic-mode buffers.")

(if vaxbasic-mode-syntax-table
    ()
  (setq vaxbasic-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\\ "\\" vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?/ ". 14" vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?+ "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?- "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?= "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?% "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?< "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?> "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?& "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?\| "." vaxbasic-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" vaxbasic-mode-syntax-table))

(defconst vaxbasic-indent-level 4
  "*Indentation of VAX BASIC statements with respect to containing block.")
(defconst vaxbasic-label-offset -4
  "*Offset of VAX BASIC label lines and case statements relative to
usual indentation.")
(defconst vaxbasic-continued-statement-offset 4
  "*Extra indent for lines not starting new statements.")

(defconst vaxbasic-continued-line-pat "[&]"
  "*Regexp matching characters that indicate a continued line.")

(defvar vaxbasic-continued-line-column 78
  "*Column for continuation characters.")


(defun vaxbasic-mode ()
  "Major mode for editing VMS BASIC code.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.

Commands:
\\{vaxbasic-mode-map}

Turning on VAX BASIC mode calls the value of the variable vaxbasic-mode-hook
with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map vaxbasic-mode-map)
  (setq major-mode 'vaxbasic-mode)
  (setq mode-name "VAX BASIC")
  (setq local-abbrev-table vaxbasic-mode-abbrev-table)
  (set-syntax-table vaxbasic-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^[ ]*$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-line-function)
;  (setq indent-line-function 'indent-relative-maybe)
  (setq indent-line-function 'vaxbasic-indent-relative-maybe)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "!")
  (make-local-variable 'comment-column)
  (setq comment-column 40)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "!+[ \t]*")
  (make-local-variable 'comment-indent-hook)
  (setq comment-indent-hook 'vaxbasic-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  (make-local-variable 'page-delimiter)
  (setq page-delimiter "^%PAGE")
  (run-hooks 'vaxbasic-mode-hook))

;; This is used by indent-for-comment
;; to decide how to indent a comment in VAX BASIC code
;; based on its context.

(defun vaxbasic-comment-indent ()
  (if (looking-at "!\\+")
      (current-column)
    (if (looking-at "!-")
	(current-column)
      (if (save-excursion
	    (beginning-of-line)
	    (looking-at "^[ \t]*!"))
	  (current-column)		;leave alone if at beginning of line
	(skip-chars-backward " \t")	
	(max (if (bolp) 0 (1+ (current-column)))
	     comment-column)))))



(defun vaxbasic-indent-relative-maybe ()
  "Indent a new line like previous nonblank line."
  (interactive)
  (indent-relative t)
  (let ((i (save-excursion
	  (beginning-of-line)
	  (if (prev-vaxbasic-line 1)
	      ;;;
	      (cond 
	       ((vaxbasic-continued-line)
		(if (prev-vaxbasic-line 1)
		    (if (not (vaxbasic-continued-line))
			'do-indent)
		  'do-indent))
	       ((progn
		  (skip-chars-forward "^!\n") ;!was#
		  (skip-chars-backward " \t")
		  (backward-char 1)
		  (looking-at "{"))
		'do-indent)
		;;last line not continued on new line  See if it was continued
		(t
		 (beginning-of-line)
		 (if (prev-vaxbasic-line 1)
		     (if (vaxbasic-continued-line)
			 'do-undent
		       'no-indent)
		   'no-indent)))	       
	       'no-indent))))
    (cond
     ((eq i 'do-indent)
      (insert-char ?\  vaxbasic-indent-level))
     ((eq i 'do-undent)
      (vaxbasic-delete-back vaxbasic-indent-level)))))



(defun prev-vaxbasic-line (n)
  "Move to previous VAX BASIC line"
  (re-search-backward "^[^\n]" nil t))



(defun vaxbasic-continued-line ()
  "Return t if line ends with a continuation character"
  (save-excursion
    (skip-chars-forward "^\n")
    (skip-chars-backward " \t")
    (backward-char 1)
    (looking-at vaxbasic-continued-line-pat)))
	
    

(defun vaxbasic-delete-back (arg)
  (while (and (> arg 0)
	      (or (= (preceding-char) ?\ )
		  (= (preceding-char) ?\t)))
    (backward-delete-char-untabify 1)
    (setq arg (1- arg))))

(defun beginning-of-vaxbasic-defun ()
  "Go to the start of the enclosing procedure; return t if at top level."
  (interactive)
  (if (re-search-backward "^\\(function\\|sub\\|program\\)\\s \\|^end[ \t\n]"
			  (point-min) 'move)
      (looking-at "e")
    t))


(defun end-of-vaxbasic-defun ()
  "Go to the end of the enclosing function."
  (interactive)
  (if (not (bobp)) (forward-char -1))
  (re-search-forward
   "\\(\\s \\|^\\)end[ 	]+\\(function\\|sub\\|program\\)\\(\\s \\|$\\)"
   (point-max) 'move)
  (forward-word -1)
  (forward-line 1))


(defun mark-vaxbasic-function ()
  "Put mark at end of VAX BASIC function, point at beginning."
  (interactive)
  (push-mark (point))
  (end-of-vaxbasic-defun)
  (push-mark (point))
  (beginning-of-line 0)
  (beginning-of-vaxbasic-defun))


(defun vaxbasic-mode-align-ampersand ()
  "If the current line has an ampersand at the end, align it at the right 
of the screen."
  (interactive)
  (message "Yow!")
  (save-excursion
    (end-of-line)
    (skip-chars-backward " \t")  
    (backward-char 1)
    (cond ((looking-at "&")
	   ;; Get rid of any previous whitespace, if any
	   (just-one-space)
	   (let ((d (- vaxbasic-continued-line-column (current-column))))
	     (if (> d 0)
		 (insert-char ? d))
	     (forward-char 1)
	     (let ((b (point)))
	       (end-of-line)
	       (delete-region b (point)))))))) 
