#lang racket/base

(define (stringify-flag-pairs ps)
  (for/fold ([acc ""]) ([p ps])
    (format "~a ~a=~a" acc (car p) (cdr p))))

(provide (all-defined-out))
