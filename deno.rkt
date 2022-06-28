#lang racket/base

(require "./shellpers.rkt")

(provide (all-defined-out))

(define deno-run-flags (make-parameter '("-A" "--reload")))

(define (deno-run-from-url url flags)
  (system->string (format "deno run ~a ~a" url (stringify-flag-pairs flags))))

(define (deno-gitlab-repo-to-url reponame [branchname "master"] [filename "mod.ts"])
  (format "https://gitlab.com/~a/-/raw/~a/~a" reponame branchname filename))

(define (deno-run-dwim my-repo)
  (deno-run-from-url (deno-gitlab-repo-to-url (format "jackmac92/~a" my-repo)) (deno-run-flags)))

(module+ test
  (require rackunit)
  (check-not-exn (lambda ()
                   ;; (deno-run-dwim "fetch-tweet")
                   (displayln "skipped test"))))
