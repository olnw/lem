(in-package :lem-core)

(defun window-recenter (window)
  (unless (= (window-cursor-y window)
             (floor (window-height-without-modeline window) 2))
    (line-start
     (move-point (window-view-point window)
                 (window-buffer-point window)))
    (let* ((height (window-height-without-modeline window))
           (n      (- (window-cursor-y window)
                      (floor height 2))))
      (window-scroll window n)
      n)))

(defun %calc-window-cursor-x (point window)
  "Return (values cur-x next). the 'next' is a flag if the cursor goes to
next line because it is at the end of width."
  (unless (variable-value 'line-wrap :default (window-buffer window))
    (return-from %calc-window-cursor-x (values (point-column point) nil)))
  (let* ((tab-size (variable-value 'tab-width :default (window-buffer window)))
         (charpos (point-charpos point))
         (line    (line-string point))
         (width   (1- (window-width window)))
         (cur-x   0)
         (add-x   (if (< charpos (length line))
                      (char-width (schar line charpos) 0 :tab-size tab-size)
                      1)))
    (loop :for i :from 0 :below charpos
          :for c := (schar line i)
          :do (setf cur-x (char-width c cur-x :tab-size tab-size))
              (when (< width cur-x)
                (setf cur-x (char-width c 0 :tab-size tab-size))))
    (if (< width (+ cur-x add-x))
        (values 0     t)
        (values cur-x nil))))

(defun window-cursor-x (window)
  (multiple-value-bind (x next)
      (%calc-window-cursor-x (window-buffer-point window) window)
    (declare (ignore next))
    x))

(defun cursor-goto-next-line-p (point window)
  "Check if the cursor goes to next line because it is at the end of width."
  (multiple-value-bind (x next)
      (%calc-window-cursor-x point window)
    (declare (ignore x))
    next))

(defun map-wrapping-line (window string fn)
  (let ((tab-size (variable-value 'tab-width :default (window-buffer window))))
    (loop :with start := 0
          :and width := (1- (window-width window))
          :for i := (wide-index string width :start start :tab-size tab-size)
          :while i
          :do (funcall fn i)
              (setq start i))))

(defun window-wrapping-offset (window start-point end-point)
  (unless (variable-value 'line-wrap :default (window-buffer window))
    (return-from window-wrapping-offset 0))
  (let ((offset 0))
    (labels ((inc (arg)
               (declare (ignore arg))
               (incf offset)))
      (map-region start-point
                  end-point
                  (lambda (string lastp)
                    (declare (ignore lastp))
                    (map-wrapping-line window
                                       string
                                       #'inc)))
      offset)))

(defun window-cursor-y-not-wrapping (window)
  (count-lines (window-buffer-point window)
               (window-view-point window)))

(defun window-cursor-y (window)
  (if (point< (window-buffer-point window)
              (window-view-point window))
      ;; return minus number
      (- (+ (window-cursor-y-not-wrapping window)
            (window-wrapping-offset window
                                    (backward-line-wrap
                                     (copy-point (window-buffer-point window)
                                                 :temporary)
                                     window t)
                                    (window-view-point window))
            (if (cursor-goto-next-line-p (window-view-point window) window)
                1 0)))
      ;; return zero or plus number
      (+ (window-cursor-y-not-wrapping window)
         (window-wrapping-offset window
                                 (window-view-point window)
                                 (window-buffer-point window))
         (if (and (point< (window-view-point window)
                          (window-buffer-point window))
                  (cursor-goto-next-line-p (window-buffer-point window) window))
             1 0))))

(defun forward-line-wrap (point window)
  (assert (eq (point-buffer point) (window-buffer window)))
  (when (variable-value 'line-wrap :default (point-buffer point))
    (map-wrapping-line window
                       (line-string point)
                       (lambda (i)
                         (when (< (point-charpos point) i)
                           (line-offset point 0 i)
                           (return-from forward-line-wrap point))))))

(defun backward-line-wrap-1 (point window contain-same-line-p)
  (if (and contain-same-line-p (start-line-p point))
      point
      (let (previous-charpos)
        (map-wrapping-line window
                           (line-string point)
                           (lambda (i)
                             (cond ((and contain-same-line-p (= i (point-charpos point)))
                                    (line-offset point 0 i)
                                    (return-from backward-line-wrap-1 point))
                                   ((< i (point-charpos point))
                                    (setf previous-charpos i))
                                   (previous-charpos
                                    (line-offset point 0 previous-charpos)
                                    (return-from backward-line-wrap-1 point))
                                   ((or contain-same-line-p (= i (point-charpos point)))
                                    (line-start point)
                                    (return-from backward-line-wrap-1 point)))))
        (cond (previous-charpos
               (line-offset point 0 previous-charpos))
              (contain-same-line-p
               (line-start point))))))

(defun backward-line-wrap (point window contain-same-line-p)
  (assert (eq (point-buffer point) (window-buffer window)))
  (cond ((variable-value 'line-wrap :default (point-buffer point))
         (backward-line-wrap-1 point window contain-same-line-p))
        (contain-same-line-p
         (line-start point))))

(defun move-to-next-virtual-line-1 (point window)
  (assert (eq (point-buffer point) (window-buffer window)))
  (or (forward-line-wrap point window)
      (line-offset point 1)))

(defun move-to-previous-virtual-line-1 (point window)
  (assert (eq (point-buffer point) (window-buffer window)))
  (backward-line-wrap point window t)
  (or (backward-line-wrap point window nil)
      (progn
        (and (line-offset point -1)
             (line-end point)
             (backward-line-wrap point window t)))))

(defun move-to-next-virtual-line-n (point window n)
  (assert (eq (point-buffer point) (window-buffer window)))
  (when (<= n 0)
    (return-from move-to-next-virtual-line-n point))
  (unless (variable-value 'line-wrap :default (point-buffer point))
    (return-from move-to-next-virtual-line-n (line-offset point n)))
  (loop :with n1 := n
        :do (map-wrapping-line
             window
             (line-string point)
             (lambda (i)
               (when (< (point-charpos point) i)
                 (decf n1)
                 (when (<= n1 0)
                   ;; cursor-x offset is recovered by cursor-saved-column
                   (line-offset point 0 i)
                   (return-from move-to-next-virtual-line-n point)))))
            ;; go to next line
            (unless (line-offset point 1)
              (return-from move-to-next-virtual-line-n nil))
            (decf n1)
            (when (<= n1 0)
              (return-from move-to-next-virtual-line-n point))))

(defun move-to-previous-virtual-line-n (point window n)
  (assert (eq (point-buffer point) (window-buffer window)))
  (when (<= n 0)
    (return-from move-to-previous-virtual-line-n point))
  (unless (variable-value 'line-wrap :default (point-buffer point))
    (return-from move-to-previous-virtual-line-n (line-offset point (- n))))
  (let ((pos-ring  (make-array (1+ n))) ; ring buffer of wrapping position
        (pos-size  (1+ n))
        (pos-count 0)
        (pos-next  0)
        (pos-last  0))
    (flet ((pos-ring-push (pos)
             (setf (aref pos-ring pos-next) pos)
             (incf pos-next)
             (when (>= pos-next pos-size) (setf pos-next 0))
             (incf pos-count)
             (when (> pos-count pos-size)
               (setf pos-count pos-size)
               (incf pos-last)
               (when (>= pos-last pos-size) (setf pos-last 0)))))
      (loop :with n1 := n
            :with first-line := t
            :do (block outer
                  (pos-ring-push 0)
                  (map-wrapping-line
                   window
                   (line-string point)
                   (lambda (i)
                     (when (and first-line
                                (< (point-charpos point) i))
                       (return-from outer))
                     (pos-ring-push i))))
                (when (>= pos-count (1+ n1))
                  ;; cursor-x offset is recovered by cursor-saved-column
                  (line-offset point 0 (aref pos-ring pos-last))
                  (return-from move-to-previous-virtual-line-n point))
                ;; go to previous line
                (unless (line-offset point -1)
                  (return-from move-to-previous-virtual-line-n nil))
                (setf first-line nil)
                (decf n1 pos-count)
                (setf pos-size  (1+ n1)) ; shrink ring-buffer
                (setf pos-count 0)
                (setf pos-next  0)
                (setf pos-last  0)))))

(defun move-to-next-virtual-line (point &optional n (window (current-window)))
  (unless n (setf n 1))
  (unless (zerop n)

    ;; workaround for cursor movement problem
    (when (and *use-cursor-movement-workaround*
               (eq point (window-buffer-point window))
               (variable-value 'line-wrap :default (point-buffer point))
               (numberp (cursor-saved-column point))
               (>= (cursor-saved-column point) (- (window-width window) 3)))
      (setf (cursor-saved-column point) 0))

    (if *use-new-vertical-move-function*
        (if (plusp n)
            (move-to-next-virtual-line-n point window n)
            (move-to-previous-virtual-line-n point window (- n)))
        (multiple-value-bind (n f)
            (if (plusp n)
                (values n #'move-to-next-virtual-line-1)
                (values (- n) #'move-to-previous-virtual-line-1))
          (loop :repeat n
                :do (unless (funcall f point window)
                      (return-from move-to-next-virtual-line nil)))
          point))))

(defun move-to-previous-virtual-line (point &optional n (window (current-window)))
  (move-to-next-virtual-line point (if n (- n) -1) window))

(defun point-virtual-line-column (point &optional (window (current-window)))
  (if (variable-value 'line-wrap :default (point-buffer point))
      (let ((column (point-column point)))
        (with-point ((start point))
          (backward-line-wrap start window t)
          (- column (point-column start))))
      (point-column point)))

(defun move-to-virtual-line-column (point column &optional (window (current-window)))
  (backward-line-wrap point window t)
  (let ((w 0))
    (loop
      :while (< w column)
      :do (setf w (char-width (character-at point) w))
          (when (end-line-p point) (return nil))
          (character-offset point 1)
      :finally (return t))))

(defun window-scroll-down (window)
  (move-to-next-virtual-line (window-view-point window) 1 window))

(defun window-scroll-up (window)
  (move-to-previous-virtual-line (window-view-point window) 1 window))

(defun window-scroll-down-n (window n)
  (move-to-next-virtual-line (window-view-point window) n window))

(defun window-scroll-up-n (window n)
  (move-to-previous-virtual-line (window-view-point window) n window))

(defun window-scroll (window n)
  (need-to-redraw window)
  (prog1 (if *use-new-vertical-move-function*
             (if (plusp n)
                 (window-scroll-down-n window n)
                 (window-scroll-up-n window (- n)))
             (dotimes (_ (abs n))
               (if (plusp n)
                   (window-scroll-down window)
                   (window-scroll-up window))))
    (run-hooks *window-scroll-functions* window)))
