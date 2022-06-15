#lang debug racket/base
(require debug/repl)


(require net/http-easy
         net/uri-codec)

(define gitlab-api-token (make-parameter (getenv "LAB_CORE_TOKEN")))
(define gitlab-host (make-parameter "gitlab.com"))

(define (gitlab-api-url)
  (format "https://~a/api/v4/" (gitlab-host)))

(define (gitlab-request path)
  (response-json (get (format "https://~a/api/v4/~a" (gitlab-host) path)
                      #:headers (hasheq (string->symbol "Private-Token") (gitlab-api-token)))))

(define (gitlab-project-api-url proj-name)
  (format "projects/~a" (uri-encode proj-name)))

(define (gitlab-project-request project-id path)
  (gitlab-request (format "~a/~a" (gitlab-project-api-url project-id) path)))

(provide (all-defined-out))
