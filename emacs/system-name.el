(defun sanitize-node-name (s)
  (substring s 1 -2))

(defun system-name ()
  (let ((i-name (getenv "INTERNET_HOST_NAME"))
	(l-name (getenv "SYS$NODE")))
    (if (not (string-equal i-name ""))
	i-name
      (sanitize-node-name l-name))))
