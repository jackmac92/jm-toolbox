#lang racket/base

(require racket/system)
(require racket/list)
(require racket/port)
(require racket/string)

(provide notmuch-count-unread notmuch-dump-message-ids)

(define (notmuch-dump q)
  (for/list ([line (string-split (with-output-to-string (lambda () (system (format "notmuch dump ~s" q)))) "\n")]
             #:when (not (string-prefix? line "#notmuch-dump")))
      line))

(define (notmuch-dump-message-ids q)
  (for/list ([line (notmuch-dump q)])
    (last (string-split line))))

(define (notmuch-count-unread acct)
  (length (notmuch-dump (format "is:unread AND is:inbox AND tag:~a" acct))))


(module+ test
  (require rackunit)
  (check-not-exn (lambda () (notmuch-dump-message-ids "tag:unread"))))
