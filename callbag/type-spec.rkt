#lang typed/racket

(struct None ())
(struct (a) Some ([v : a]))

(define-type (Opt a) (U None (Some a)))

(define-type START 0)
(define-type DATA 1)
(define-type END 2)

(define-type (CallbagArgs i o)
  (U
   ;; handshake
   (Pair DATA (Callbag o i))
   ;; data from source
   (Pair DATA i)
   ;; data pull request
   (List DATA)
   ;; exit with error
   (Pair END Any)
   ;; exit with error
   (Pair END (Opt #f))))

;; (define-type (Callbag i o) (-> (CallbagArgs i o) * Null))
(struct (i o) Callbag ([fn : (-> (CallbagArgs i o) * Null)]))

(define-type (Source t) (Callbag Null t))
(define-type (Sink t) (Callbag t Null))
(define-type (SourceFactory t) (-> Any * (Source t)))
(define-type (SourceOperator t r) (-> Any * (-> (Source t) (Source r))))
