#lang racket/base

(require racket/system)
(require racket/port)
(require racket/string)

(provide dunstify)

(define (dunstify n #:title title #:subtitle [subtitle ""])
  (with-output-to-string (lambda () (system (format "dunstify ~a ~s ~s" n title subtitle)))))

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
