#lang racket/base

(require racket/system)
(require racket/port)
(require racket/string)
(require "./shellpers.rkt")

(provide (all-defined-out))

(define notif-bg-color (make-parameter #f))
(define notif-font-color (make-parameter #f))
(define notif-timeout (make-parameter (* 1000 45)))
(define notif-replace-id (make-parameter #f))

(define (dunstify n #:title title #:subtitle [subtitle ""])
  (string-trim (with-output-to-string (lambda () (system (format "dunstify ~a ~s ~s" n title subtitle))))))

(define (dunstify-param title [subtitle ""])
  (dunstify (stringify-flag-pairs (list
                                   (cons "--replace" (notif-replace-id))
                                   (cons "--timeout" (notif-timeout))
                                   (cons "--hints" (format "string:bgcolor:~a" (notif-bg-color)))
                                   (cons "--hints" (format "string:fgcolor:~a" (notif-font-color)))))
           #:title title #:subtitle subtitle))
;; timeout
;;icon
;;hints
;;replaceid
;;action
;;; bgcolor
;;; category: email
;;; fgcolor

(module+ test
  (require rackunit))
