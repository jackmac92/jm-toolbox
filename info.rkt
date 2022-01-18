#lang info
(define collection "jm-toolbox")
(define deps '("base" "html-parsing" "db-lib" "sxml" "deta" "rackunit-lib" "behavior" "casemate" "ulid" "anaphoric" "threading" "reprovide-lang-lib"))
(define build-deps '("scribble-lib" "racket-doc" "at-exp-lib"))
(define scribblings '(("scribblings/jm-toolbox.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(jmccown))
(define license '(Apache-2.0 OR MIT))
