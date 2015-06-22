(in-package :lem)

(define-key *global-keymap* "C-x#" 'filter-buffer)
(defcommand filter-buffer (str) ("sFilter buffer: ")
  (let ((outstr (make-array '(0)
                  :element-type 'character
                  :fill-pointer t)))
    (with-output-to-string (output outstr)
      (let ((temp-file-name (temp-file-name)))
        (write-to-file (window-buffer) temp-file-name)
        (shell-command (format nil "cat ~a | ~a" temp-file-name str)
          :output output)
        (delete-file temp-file-name)))
    (erase-buffer)
    (insert-string outstr)
    (beginning-of-buffer)))

(define-key *global-keymap* "C-x@" 'pipe-command)
(defcommand pipe-command (str) ("sPipe command: ")
  (let ((outstr (make-array '(0)
                  :element-type 'character
                  :fill-pointer t)))
    (with-output-to-string (output outstr)
      (shell-command str :output output))
    (let ((buffer (get-buffer-create "*Command*")))
      (let ((*current-window* (pop-to-buffer buffer)))
        (buffer-erase buffer)
        (insert-string outstr)
        (beginning-of-buffer)))))
