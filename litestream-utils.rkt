#lang racket/base
(require racket/file racket/system)

(define (ensure-db-dir-exists path)
  (unless (file-exists? path)
    (make-parent-directory* path)))

(define (litestream-is-ready?)
  (and (andmap getenv '("LITESTREAM_ACCESS_KEY_ID" "LITESTREAM_SECRET_ACCESS_KEY" "LITESTREAM_REGION")) (ensure-db-dir-exists)))

(define (restore-litestream-at-path path)
  (make-parent-directory* path)
  (system (format "litestream restore -if-replica-exists -v ~a" path)))

(define (start-litestream-backup-at-path path)
  (system (format "litestream replicate ~a" path)))

(provide (all-defined-out))
