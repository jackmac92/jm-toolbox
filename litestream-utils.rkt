#lang racket/base
(require basedir "./shellpers.rkt")

(define litestream-base-bucket (make-parameter "racket-toolbox-litestream"))

(define (litestream-s3-replica-path)
  (format "s3://~a/~a" (litestream-base-bucket) (current-basedir-program-name)))

(define (restore-litestream-at-path path)
  (cmd! "litestream restore -if-replica-exists -v -o ~a ~a" path (litestream-s3-replica-path)))

(define (start-litestream-backup-at-path path)
  (cmd! "litestream replicate ~a ~a" path (litestream-s3-replica-path)))

(provide (all-defined-out))
