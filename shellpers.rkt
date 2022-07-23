#lang racket/base

(require racket/system racket/contract racket/port racket/string)

(define my-shell-debug (make-parameter #f))

(define cmd! (lambda cmd-fmt-args
               (define c (apply format cmd-fmt-args))
               (when (my-shell-debug)
                 (displayln c))
               (system c)))

(define/contract (system->string cmd)
  (-> non-empty-string? string?)
  (with-output-to-string (lambda ()
                           (unless (system cmd)
                             (error "shell command failed")))))

(define/contract (command->output-lines cmd #:trim [trim-output #t])
  (->* (non-empty-string?) (#:trim boolean?) (non-empty-listof string?))
  (let ((rawout (string-split (system->string cmd) "\n")))
    (if trim-output
        (map string-trim rawout)
        rawout)))

(define (stringify-flag-pairs ps)
  (for/fold ([acc ""])
            ([p ps])
    (format "~a ~a" acc (if (string? p) p (format "~a=~a" (car p) (cdr p))))))

(define (proc-command->string command . args)
  (let-values (((sub stdout _stdin _stderr) (apply subprocess
                                                   `(#f
                                                     ,(current-input-port)
                                                     ,(current-error-port)
                                                     ,(find-executable-path command)
                                                     ,@args))))
    (subprocess-wait sub)
    (let ((output (port->string stdout)))
      (if (eqv? 0 (subprocess-status sub))
          output
          (error "Command failed:" (cons command args))))))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (check-not-exn (lambda () (proc-command->string "ls"))))
