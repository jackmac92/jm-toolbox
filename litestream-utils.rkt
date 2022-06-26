#lang racket/base
(require basedir racket/file racket/system)

(define (litestream-s3-replica-path)
  (format "s3://racket-toolbox-litestream/~a" (current-basedir-program-name)))

(define (restore-litestream-at-path path)
  (make-parent-directory* path)
  (system (format "litestream restore -if-replica-exists -v -o ~a ~a" path (litestream-s3-replica-path))))

(define (start-litestream-backup-at-path path)
  (system (format "litestream replicate ~a ~a" path (litestream-s3-replica-path))))

(provide (all-defined-out))
