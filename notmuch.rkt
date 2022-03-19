#lang racket/base

(require racket/system)
(require racket/list)
(require racket/port)
(require racket/string)

(provide (all-defined-out))

(define (notmuch-dump q)
  (for/list ([line (string-split (with-output-to-string (lambda () (system (format "notmuch dump ~s" q)))) "\n")]
             #:when (not (string-prefix? line "#notmuch-dump")))
      line))

(define (notmuch-dump-extract-message-ids resp)
  (for/list ([line resp])
    (last (string-split line))))

(define (notmuch-dump-message-ids q)
  (notmuch-dump-extract-message-ids (notmuch-dump q)))

(define (notmuch-list-unread acct)
  (notmuch-dump (format "is:unread AND is:inbox AND not is:archive AND not is:trash AND not is:spam AND tag:~a" acct)))

(define (notmuch-count-unread acct)
  (length (notmuch-list-unread acct)))


(module+ test
  (require rackunit)
  (check-not-exn (lambda () (notmuch-dump-message-ids "tag:unread"))))
