(define (message . args)
  (for-each display args)
  (newline))

(define (error code . args)
  (for-each display args)
  (newline)
  (quit code))


(define outfile #f)
(define infile #f)
(define remaining-args '())

(let* ((prog (car (program-arguments)))
       (scmfile (cadr (program-arguments)))
       (args (cddr (program-arguments))))
  (message "args: " args)
  (let loop ((args args))
    (cond ((null? args)
           #f)
          (else
           (let ((arg (car args))
                 (args (cdr args)))
             (cond ((string=? arg "-o")
                    (if (null? args) (error 2 "Missing argument to \"-o\"."))
                    (set! outfile (car args))
                    (loop (cdr args)))
                   ((string=? arg "-i")
                    (if (null? args) (error 2 "Missing argument to \"-i\"."))
                    (set! infile (car args))
                    (loop (cdr args)))
                   (else 
                    (set! remaining-args (cons arg remaining-args))
                    (loop args)))))))
  (set! remaining-args (reverse remaining-args))
  (message "infile: " infile " outfile: " outfile)
  (message "remaining-args: " remaining-args)
  (quit))
