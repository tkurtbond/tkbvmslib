(defun x-renumber-rows (high low inc)
  (interactive "nHigh: \nnLow: \nnInc:")
  (message "top: high: %d low: %d" high low)
  (while (>= high low)
  (message "high: %d low: %d" high low)
    (goto-char (point-min))
    (query-replace-regexp (concat "\\((\\|!row \\)" (int-to-string high))
			  (concat "\\1" (int-to-string (+ high inc))))
    (setq high (1- high))))

(defun x-number-lines ()
  (interactive)
  (let ((line 1))
    (while (/= (point) (point-max))
      (insert "| " (int-to-string line))
      (setq line (1+ line))
      (forward-line)
      (end-of-line))))
