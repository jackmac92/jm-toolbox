#lang racket/base

(require reprovide/reprovide)

(reprovide racket/format racket/file racket/list racket/string racket/logging racket/port basedir "./shellpers.rkt" "./json.rkt")

(define make-log-file
  (lambda components
    (let ([logfilepath (apply build-path components)])
      (make-parent-directory* logfilepath)
      ;; TODO use (make-pipe) to create a pipe which also logs to stdout before the logfile
      ;; or maybe dup-output-port
      ;;or maybe start a thread, where copy-port streams to current-output-port?
      (open-output-file logfilepath #:exists 'append))))

(provide (all-defined-out))
