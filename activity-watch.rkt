#lang racket/base
(require db deta racket/string)

(define-schema bucketmodel
  ([key id/f]
   [id id/f]
   [created date/f]
   [name string/f]
   [type string/f #:contract non-empty-string?]
   [client string/f #:contract non-empty-string?]
   [hostname string/f #:contract non-empty-string?]))

(define-schema eventmodel
  ([id id/f]
   [timestamp date/f]
   [duration real/f]
   [bucket_id id/f]
   [datastr string/f]))



(module+ main
  (define dbc
    (sqlite3-connect #:database "/home/jmccown/laptop-aw.db"))

  (query-rows dbc "select * from bucketmodel"))
