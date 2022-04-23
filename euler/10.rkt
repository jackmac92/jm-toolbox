#lang racket
(require math)


(for/sum ([i (in-naturals)]
          #:when (prime? i)
          #:break (> i 2000000))
  i)
