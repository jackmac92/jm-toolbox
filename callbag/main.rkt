#lang typed/racket

(require "type-spec.rkt")

(: for-each (All A) (Source A))
(define (for-each op))

;; const forEach = operation => source => {
;;                                         let talkback;
;;                                         source(0, (t, d) => {
;;                                                              if (t === 0) talkback = d;
;;                                                              if (t === 1) operation(d);
;;                                                              if (t === 1 || t === 0) talkback(1)})};
