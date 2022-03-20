#lang racket/base

(require racket/system racket/port racket/string)

(define (command->output-lines cmd)
  (string-split (with-output-to-string (lambda () (system cmd))) "\n"))

(define (stringify-flag-pairs ps)
  (for/fold ([acc ""]) ([p ps])
    (format "~a ~a=~a" acc (car p) (cdr p))))

(provide (all-defined-out))
