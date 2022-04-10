#lang racket/base

(require racket/system racket/port racket/string)

(define (command->output-lines cmd #:trim [trim-output #t])
  (let ((rawout (string-split (with-output-to-string (lambda () (system cmd))) "\n")))
    (if trim-output
        (map string-trim rawout)
        rawout)))

(define (stringify-flag-pairs ps)
  (for/fold ([acc ""])
            ([p ps]
             #:when (cdr p))
    (format "~a ~a=~a" acc (car p) (cdr p))))

(provide (all-defined-out))
