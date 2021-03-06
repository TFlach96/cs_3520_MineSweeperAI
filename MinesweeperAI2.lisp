;source code from
;https://rosettacode.org/wiki/Minesweeper_game
(defclass minefield ()
  ((mines :initform (make-hash-table :test #'equal))
   (width :initarg :width)
   (height :initarg :height)
   (grid :initarg :grid)))
 
(defun make-minefield (width height num-mines)
  (let ((minefield (make-instance 'minefield
                                  :width width
                                  :height height
                                  :grid (make-array
                                          (list width height)
                                          :initial-element #\.)))
        (mine-count 0))
    (with-slots (grid mines) minefield
      (loop while (< mine-count num-mines)
            do (let ((coords (list (random width) (random height))))
                 (unless (gethash coords mines)
                   (setf (gethash coords mines) T)
                   (incf mine-count))))
      minefield)))
 
(defun print-field (minefield)
  (with-slots (width height grid) minefield
    (dotimes (y height)
      (dotimes (x width)
        (princ (aref grid x y)))
      (format t "~%"))))
 
(defun mine-list (minefield)
  (loop for key being the hash-keys of (slot-value minefield 'mines) collect key))

(defun adjacent-clear (minefield coords)
  (with-slots (width height grid) minefield
    (dotimes (y height)
      (dotimes (x width)
        (let ((adjCoords (list x y))) 
          (when ;if the x and y loop are withing 1 space of the coordinates
            (and
              (> 2 (abs (- (car coords) x)))
              (> 2 (abs (- (cadr coords) y)))
            )
              (clear minefield adjCoords) ;clear the adjacent location
          )
        )
      )
    )
    (setf (aref grid (car coords) (cadr coords)) (aref grid (car coords) (cadr coords)))
  )
)
 
(defun count-nearby-mines (minefield coords)
  (length (remove-if-not
            (lambda (mine-coord)
              (and
                (> 2 (abs (- (car coords) (car mine-coord))))
                (> 2 (abs (- (cadr coords) (cadr mine-coord))))))
            (mine-list minefield))))
 
(defun clear (minefield coords)
  (with-slots (mines grid) minefield
    (if (or (equalp (aref grid (car coords) (cadr coords)) #\.) (equalp (aref grid (car coords) (cadr coords)) #\?)) ;If coords have not already been cleared or is marked, continue.
      (if (gethash coords mines)
        (progn
          (format t "MINE! You lose.~%")
          (dolist (mine-coords (mine-list minefield))
            (setf (aref grid (car mine-coords) (cadr mine-coords)) #\x))
          (setf (aref grid (car coords) (cadr coords)) #\X)
          nil)
        (let ((x (count-nearby-mines minefield coords))) ;store the number of adjacent mines in x
          (setf (aref grid (car coords) (cadr coords))
              (elt "0123456789" x))
          (if (eql x 0) ;if no mines clear adjacent areas recursively.
            (adjacent-clear minefield coords) 
            (setf (aref grid (car coords) (cadr coords)) (aref grid (car coords) (cadr coords))))))
      ;else ignore and set to itself
      (setf (aref grid (car coords) (cadr coords)) (aref grid (car coords) (cadr coords)))))) ;ignore this space but don't terminate
 
(defun mark (minefield coords)
  (with-slots (mines grid) minefield
    (setf (aref grid (car coords) (cadr coords)) #\?)))
 
(defun win-p (minefield)
  (with-slots (width height grid mines) minefield
    (let ((num-uncleared 0))
      (dotimes (y height)
        (dotimes (x width)
          (let ((square (aref grid x y)))
            (when (member square '(#\. #\?) :test #'char=)
              (incf num-uncleared)))))
      (= num-uncleared (hash-table-count mines)))))
 
(defun play-game ()
    (let ((minefield (make-minefield 8 8 8))) ;make-minefield col row mines
        (format t "Greetings player, there are ~a mines.~%"
            (hash-table-count (slot-value minefield 'mines)))
        (loop
            (print-field minefield)
            (terpri)
            (unless (clear minefield (list (random 8) (random 8)))
                (print-field minefield)
                (terpri)
                (return-from play-game nil)
            )
            (when (win-p minefield)
                (format t "Congratulations, you've won!")
                (return-from play-game T))
        )
    )
)
 
(play-game)