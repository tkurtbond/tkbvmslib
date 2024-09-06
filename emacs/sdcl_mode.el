;;; sdcl_mode.el -- mode for editing Sdcl program source.  A Work In Progress.
;;; adapted (very crudely) from c-mode.  TAB runs indent-relative
;;; (like indented-text mode), } moves to the right sdcl-indent-level
;;; spaces, C-M-a is moves to beginning of sdcl procedure, C-M-e to
;;; end, C-M-h marks function

(defvar sdcl-mode-abbrev-table nil
  "Abbrev table in use in Sdcl-mode buffers.")
(define-abbrev-table 'sdcl-mode-abbrev-table ())

(defvar sdcl-mode-map ()
  "Keymap used in Sdcl mode.")
(if sdcl-mode-map
    ()
  (setq sdcl-mode-map (make-sparse-keymap))
  (define-key sdcl-mode-map "{" 'electric-sdcl-brace)
  (define-key sdcl-mode-map "}" 'electric-sdcl-brace)
;  (define-key sdcl-mode-map ":" 'electric-sdcl-terminator)
  (define-key sdcl-mode-map "\e\C-a" 'sdcl-beginning-of-defun)
  (define-key sdcl-mode-map "\e\C-e" 'sdcl-end-of-defun)
  (define-key sdcl-mode-map "\e\C-h" 'mark-sdcl-function)
;  (define-key sdcl-mode-map "\e\C-q" 'indent-sdcl-exp) ;
  (define-key sdcl-mode-map "\177" 'backward-delete-char-untabify)
  (define-key sdcl-mode-map "\t" 'indent-relative))

(defvar sdcl-mode-syntax-table nil
  "Syntax table in use in Sdcl-mode buffers.")

(if sdcl-mode-syntax-table
    ()
  (setq sdcl-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\\ "\\" sdcl-mode-syntax-table)
  (modify-syntax-entry ?/ ". 14" sdcl-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" sdcl-mode-syntax-table)
  (modify-syntax-entry ?+ "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?- "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?= "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?% "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?< "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?> "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?& "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?\| "." sdcl-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" sdcl-mode-syntax-table))

(defconst sdcl-indent-level 4
  "*Indentation of Sdcl statements with respect to containing block.")
(defconst sdcl-brace-imaginary-offset 0
  "*Imagined indentation of a Sdcl open brace that actually 
follows a statement.")
(defconst sdcl-brace-offset 0
  "*Extra indentation for braces, compared with other text in same context.")
(defconst sdcl-argdecl-indent 4
  "*Indentation level of declarations of Sdcl function arguments.")
(defconst sdcl-label-offset -4
  "*Offset of Sdcl label lines and case statements relative to usual indentation.")
(defconst sdcl-continued-statement-offset 4
  "*Extra indent for lines not starting new statements.")

(defconst sdcl-auto-newline nil
  "*Non-nil means automatically newline before and after braces,
and after colons and semicolons, inserted in Sdcl code.")

(defconst sdcl-tab-always-indent t
  "*Non-nil means TAB in Sdcl mode should always reindent the current line,
regardless of where in the line point is when the TAB command is used.")

(defconst sdcl-continued-line-pat "[\\]"
  "*Regexp matching characters that indicate a continued line")

(defconst sdcl-begin-sub-pat "^[ \t]*[a-z0-9$_.]+:[ \t]*subr"
  "*Regexp that matches the beginning of a SDCL subprogram")

(defconst sdcl-end-sub-pat "^[ \t]*ends"
  "*Regexp that matches the end of a SDCL subprogram")

(defun sdcl-mode ()
  "Major mode for editing Sdcl code.
Expression and list commands understand all Sdcl brackets.
Comments are delimited with #.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.

Commands:
\\{sdcl-mode-map}

Turning on Sdcl mode calls the value of the variable sdcl-mode-hook
with no args, if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map sdcl-mode-map)
  (setq major-mode 'sdcl-mode)
  (setq mode-name "Sdcl")
  (setq local-abbrev-table sdcl-mode-abbrev-table)
  (set-syntax-table sdcl-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-line-function)
;  (setq indent-line-function 'indent-relative-maybe)
  (setq indent-line-function 'sdcl-indent-relative-maybe)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "#")
  (make-local-variable 'comment-column)
  (setq comment-column 40)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "#+[ \t]*")
  (make-local-variable 'comment-indent-hook)
  (setq comment-indent-hook 'sdcl-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  (run-hooks 'sdcl-mode-hook))

;; This is used by indent-for-comment
;; to decide how to indent a comment in Sdcl code
;; based on its context.

(defun sdcl-comment-indent ()
  (if (looking-at "###")
      (current-column)
    (if (looking-at "##")		;leave alone for now
;	(let ((tem (calculate-sdcl-indent)))
;	  (if (listp tem) (car tem) tem))
	(current-column)
      (if (looking-at "^#")
	  0
	(skip-chars-backward " \t")	;???leave alone if at beginning of line
	(max (if (bolp) 0 (1+ (current-column)))
	     comment-column)))))



(defun sdcl-indent-relative-maybe ()
  "Indent a new line like previous nonblank line."
  (interactive)
  (indent-relative t)
  (let ((i (save-excursion
	  (beginning-of-line)
	  (if (prev-sdcl-line 1)
	      ;;;
	      (cond 
	       ((sdcl-continued-line)
		(if (prev-sdcl-line 1)
		    (if (not (sdcl-continued-line))
			'do-indent)
		  'do-indent))
	       ((progn
		  (skip-chars-forward "^#\n")
		  (skip-chars-backward " \t")
		  (backward-char 1)
		  (looking-at "{"))
		'do-indent)
		;;last line not continued on new line  See if it was continued
		(t
		 (beginning-of-line)
		 (if (prev-sdcl-line 1)
		     (if (sdcl-continued-line)
			 'do-undent
		       'no-indent)
		   'no-indent)))	       
	       'no-indent))))
    (cond
     ((eq i 'do-indent)
      (insert-char ?\  sdcl-indent-level))
     ((eq i 'do-undent)
      (sdcl-delete-back sdcl-indent-level)))))



(defun prev-sdcl-line (n)
  "Move to previous Sdcl line"
  (re-search-backward "^[^\n]" nil t))



(defun sdcl-continued-line ()
  "Return t if line ends with a continuation character"
  (save-excursion
    (skip-chars-forward "^#\n")
    (skip-chars-backward " \t")
    (backward-char 1)
    (looking-at sdcl-continued-line-pat)))
	
    




(defun electric-sdcl-brace (arg)
  "Insert character and (sort-of) correct line's indentation."
  (interactive "P")
  (if (and (not (null arg)) (> arg 1))
      (insert-char last-command-char arg)
    (if (= last-command-char ?{ )
	(progn
	  (insert last-command-char)
	  (if sdcl-auto-newline 
	      (newline-and-indent)))
      (if (save-excursion		;only undent "}" if on a blank line
	    (beginning-of-line)
	    (looking-at "^[ \t]*$"))
	  (sdcl-delete-back sdcl-indent-level))
      (insert last-command-char))))



(defun sdcl-delete-back (arg)
  (while (and (> arg 0)
	      (or (= (preceding-char) ?\ )
		  (= (preceding-char) ?\t)))
    (backward-delete-char-untabify 1)
    (setq arg (1- arg))))



(defun electric-sdcl-terminator (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (message "This does not work!"))



(defun mark-sdcl-function ()
  "Put mark at end of Sdcl function, point at beginning."
  (interactive)
  (push-mark (point))
  (sdcl-end-of-defun)
  (forward-line 1)			;to get all the function in region
  (push-mark (point))
  (sdcl-beginning-of-defun))



(defun sdcl-beginning-of-defun (&optional arg)
  "Move backward to next beginning-of-defun.
With argument, do this that many times.
Returns t unless search stops due to end of buffer."
  (interactive "p")
  (and arg (< arg 0) (forward-char 1))
  (and (re-search-backward sdcl-begin-sub-pat nil 'move (or arg 1))
       (progn (beginning-of-line) t)))



(defun sdcl-end-of-defun (&optional arg)
  "Move forward to next end of defun."
  (interactive "p")
;  (and arg (< arg 0) (forward-char -1))
  (if (and arg (< arg 0))
      (forward-char -1)
    (if (looking-at sdcl-end-sub-pat)
	(forward-char 1)))      
  (and (re-search-forward "^end " nil 'move (or arg 1))
       (progn (beginning-of-line) t)))
		   
			    
