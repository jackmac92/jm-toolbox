#lang racket/base
(require net/http-easy
         racket/string
         racket/list
         net/uri-codec)

(define gitlab-api-token (make-parameter (getenv "GITLAB_API_TOKEN")))
(define gitlab-host (make-parameter "gitlab.com"))

(define (gitlab-api-url)
  (format "https://~a/api/v4/" (gitlab-host)))

(define (unbox-if-needed x)
  (if (box? x)
      (unbox x)
      x))

(define (gitlab-request path #:method [method get] #:params [params #f] #:payload [payload #f])
  (response-json (method (format "https://~a/api/v4/~a" (gitlab-host) path)
                         #:params params
                         #:json payload
                         #:headers (hasheq (string->symbol "Private-Token") (gitlab-api-token)))))

(define (gitlab-api-exhaust-pagination endpoint kw-keys kw-values)
  (define result (keyword-apply gitlab-request kw-keys kw-values (list endpoint)))
  (if (empty? result)
      result
      (begin
        (let ((last-id (hash-ref (last result) 'id)))
          ;; set id_after as the first value in kw-keys
          ;; and the id as the first value in kw-values

          (displayln result)
          (cons result (gitlab-api-exhaust-pagination endpoint kw-keys kw-values))))))
;; (keyword-apply f '(#:y) '(2) '(1))
(define (gitlab-list-all-projects)
  (gitlab-api-exhaust-pagination "projects" '(#:params) (list (list (cons 'sort "asc") (cons 'order_by "id")  (cons 'min_access_level "30") (cons 'archived #f)))))

(define (gitlab-project-api-url proj-name)
  (format "projects/~a" (if (string-contains? proj-name "/") (uri-encode proj-name) proj-name)))

(define (gitlab-project-request project-id path #:method [method get])
  (gitlab-request (format "~a/~a" (gitlab-project-api-url project-id) path) #:method method))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (check-not-exn (lambda ()
                   (gitlab-list-all-projects))))
