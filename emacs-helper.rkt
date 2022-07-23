#lang racket


(require "./shellpers.rkt")

(define emacs-socket (make-parameter "default"))

(define (run-elisp elisp)
  (proc-command->string "emacsclient" "-s" (emacs-socket) "--eval" elisp))


(provide (all-defined-out))
