#lang racket/base

(require racket/system racket/port racket/string)

(define my-shell-debug (make-parameter #f))

(define cmd! (lambda cmd-fmt-args
               (define c (apply format cmd-fmt-args))
               (when (my-shell-debug)
                 (displayln c))
               (system c)))

(define (system->string cmd)
  (with-output-to-string (lambda ()
                           (unless (system cmd)
                             (error "shell command failed")))))

(define (command->output-lines cmd #:trim [trim-output #t])
  (let ((rawout (string-split (system->string cmd) "\n")))
    (if trim-output
        (map string-trim rawout)
        rawout)))

(define (stringify-flag-pairs ps)
  (for/fold ([acc ""])
            ([p ps])
    (format "~a ~a" acc (if (string? p) p (format "~a=~a" (car p) (cdr p))))))

(provide (all-defined-out))
