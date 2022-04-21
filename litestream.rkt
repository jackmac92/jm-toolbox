#lang racket/base
(require "litestream-utils.rkt")

(define litestream-db-path (make-parameter #f))

(define (restore-litestream)
  (restore-litestream-at-path (litestream-db-path)))

(define (start-litestream-backup)
  (thread (lambda () (start-litestream-backup-at-path (litestream-db-path)))))

(provide (all-defined-out))
