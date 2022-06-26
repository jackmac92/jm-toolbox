#lang racket/base
(require db basedir "litestream-utils.rkt")

(define (litestream-dwim)
  (define p (writable-runtime-file "litestream.sqlite"))
  (restore-litestream-at-path p)
  (define conn (sqlite3-connect #:database p))
  (thread (lambda () (start-litestream-backup-at-path p)))
  conn)

(provide (all-defined-out))
