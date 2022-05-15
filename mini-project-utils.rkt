#lang racket/base

(require
 racket/file
 racket/port)

(define make-log-file
  (lambda components
    (let ([logfilepath (apply build-path components)])
      (make-parent-directory* logfilepath)
      (open-output-file logfilepath #:exists 'append))))

(provide (all-defined-out))
