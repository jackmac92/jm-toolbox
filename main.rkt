#lang racket/base

(provide (for-syntax (all-from-out 'anaphoric)))
(provide (for-syntax (all-from-out 'threading)))

(module+ main
  (require racket/cmdline)
  (define who (box "world"))
  (command-line
    #:program "my-program"
    #:once-each
    [("-n" "--name") name "Who to say hello to" (set-box! who name)]
    #:args ()
    (printf "hello ~a~n" (unbox who))))

(module+ test
  (require rackunit)
  (check-equal? (+ 2 2) 4))
