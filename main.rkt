#lang racket/base

(require reprovide/reprovide)
(reprovide (for-syntax anaphoric))
(reprovide (for-syntax threading))

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
