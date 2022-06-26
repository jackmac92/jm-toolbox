#lang racket/base
(require db basedir "litestream-utils.rkt")

(define (litestream-dwim)
  (define p (writable-runtime-file "litestream.sqlite"))
  (unless (litestream-is-ready?)
    (error "Litestream is not configured"))
  (restore-litestream-at-path p)
  (define conn (sqlite3-connect #:database p #:mode 'create))
  (thread (lambda () (start-litestream-backup-at-path p)))
  conn)

(provide (all-defined-out))
