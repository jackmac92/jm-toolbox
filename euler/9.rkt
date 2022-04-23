#lang racket
(require csp)
(require math/number-theory)
;; #lang datalog
;; edge(a, b). edge(b, c). edge(c, d). edge(d, a).
;; path(X, Y) :- edge(X, Y).
;; path(X, Y) :- edge(X, Z), path(Z, Y).
;; path(X, Y)?


(define triples-sum-value 1000)


(define triples (make-csp))

(add-var! triples 'a (range 1 1000))
(add-var! triples 'b (range 1 1000))
(add-var! triples 'c (range 1 1000))

(define (valid-triple? x y z)
  (= (expt z 2) (+ (expt x 2) (expt y 2))))

(define (sum-1000? x y z)
  (= 1000 (+ x (+ y z))))

(add-constraint! triples sum-1000? '(a b c))
(add-constraint! triples valid-triple? '(a b c))



(apply * (map cdr (solve triples)))
