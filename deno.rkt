#lang racket/base

(require racket/system)
(require racket/port)
(require racket/string)
(require "./shellpers.rkt")

(provide (all-defined-out))

(define (deno-run-from-url url flags)
  (system->string (format "deno run ~a ~a" url (stringify-flag-pairs flags))))

(define (deno-gitlab-repo-to-url reponame [branchname "master"] [filename "mod.ts"])
  (format "https://gitlab.com/~a/-/raw/~a/~a" reponame branchname filename))

(define (deno-run-dwim my-repo)
  (deno-run-from-url (deno-gitlab-repo-to-url (format "jackmac92/~a" my-repo)) '("-A")))

(module+ test
  (require rackunit)
  (deno-run-dwim "fetch-tweet"))