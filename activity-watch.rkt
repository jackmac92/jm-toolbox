#lang racket/base
(require db)

(define dbc
  (sqlite3-connect #:database "/home/jmccown/laptop-aw.db"))

(query-rows dbc "select * from bucketmodel")


