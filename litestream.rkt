#lang racket/base
(require db basedir "litestream-utils.rkt")

(define (litestream-dwim)
  (define p (writable-runtime-file "litestream.sqlite"))
  (restore-litestream-at-path p)
  (define conn (sqlite3-connect #:database p #:mode 'create))
  (thread (lambda () (start-litestream-backup-at-path p)))
  conn)

(provide
 (all-from-out db)
 (all-defined-out))
