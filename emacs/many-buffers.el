; I got VMS GNU Emacs 18.41.42 up to over 200 buffers with this once...

;;;Build a bunch of buffers holding empty files
(let ((i 0))
  (while (< i 300)
    (find-file (format "%d.xx" i))
    (message (format "created buffer %d.xx" i))
    (setq i (1+ i))))

;;;Delete the buffers built above
(let ((i 0))
  (while (< i 300)
    (kill-buffer (format "%d.xx" i))
    (message (format "deleted buffer %d.xx" i))
    (setq i (1+ i))))
