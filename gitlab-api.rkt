#lang racket/base

(require net/http-easy
         "./mini-project-utils.rkt")

(define gitlab-api-token (make-parameter ""))
(define gitlab-host (make-parameter "gitlab.com"))

(define (gitlab-request path)
  (response-json (get (format "https://~a/api/v4/~a" (gitlab-host) path)
                      #:headers (hasheq "Private-Token" (gitlab-api-token)))))

(provide (all-defined-out))
