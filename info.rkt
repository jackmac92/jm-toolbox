#lang info
(define collection "jm-toolbox")
(define deps
  '("base" "basedir"
           "csp"
           "debug"
           "google"
           "gregor"
           "choose-out"
           "data-frame"
           "thread-utils"
           "deferred"
           "html-parsing"
           "hash-lambda"
           "math-lib"
           "db-lib"
           "sql"
           "racquel"
           "deta"
           "sxml"
           "rackunit-lib"
           "behavior"
           "casemate"
           "ulid"
           "seq"
           "anaphoric"
           "threading"
           "reprovide-lang-lib"
           "typed-racket-lib"
           "splitflap-lib"
           "http-easy"
           "sxml"
           "argo"
           "webscraperhelper"
           "web-server-lib"
           "html-parsing"))

(define build-deps '("scribble-lib" "racket-doc" "at-exp-lib" "rackjure"))
(define scribblings '(("scribblings/jm-toolbox.scrbl" ())))
(define pkg-desc "Description Here")
(define version "1000.0")
(define pkg-authors '(jmccown))
(define license '(Apache-2.0 OR MIT))
