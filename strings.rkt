#lang racket/base

(require racket/string)

(define (kebab-to-camel-legacy s)
  (string-join
   (for/list ([w (string-split s "-")]
              [i (in-naturals)])
    (if (eq? 0 i)
        w
        (string-titlecase w)))
   ""))

(define kebab-to-camel ->camelCase)
