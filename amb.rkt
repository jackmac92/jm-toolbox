#lang racket

(define $backtrack-points (list))

(define (backtrack)
  (if (empty? $backtrack-points)
      (error "can't backtrack")
      (begin
        (apply (eval (first $backtrack-points) (make-base-namespace)) (list))
        (set! $backtrack-points (cdr $backtrack-points)))))

(define amb (lambda choices
              (when (empty? choices)
                (backtrack))
              (let/cc here
                (set! $backtrack-points (append $backtrack-points (list here)))
                (first choices))
              (apply amb (cdr choices))))

(define (cut)
  (set! $backtrack-points (list)))


(define x (amb 3 5 9))
(define y (amb 5 7 3))
(when (not (equal? (* x y) (* 3 5)))
  (amb))
(displayln "Done")
