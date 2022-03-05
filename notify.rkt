#lang racket/base

(require racket/system)
(require racket/port)
(require racket/string)

(provide dunstify)

(define (dunstify n)
  (with-output-to-string (lambda () (system (format "dunstify ~a" n)))))

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
