#lang racket

(define (command->string command . args)
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

(define (run-elisp elisp)
  (command->string "emacsclient" "-s" "default" "--eval" elisp))

(module+ test
  (require rackunit)
  (check-not-exn (lambda () (command->string "ls"))))
