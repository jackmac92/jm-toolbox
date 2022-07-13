#lang racket/base
(require net/http-easy
         json
         racket/string
         racket/list
         net/uri-codec)

(define gitlab-api-token (make-parameter (getenv "GITLAB_API_TOKEN")))
(define gitlab-host (make-parameter "gitlab.com"))

(define (gitlab-api-url)
  (format "https://~a/api/v4/" (gitlab-host)))

(define (unbox-if-needed x)
  (if (box? x) (unbox x) x))

(define (hash->queryparams x)
  (for/list ([a (hash->list x)])
    (cons (car a) (format "~a" (cdr a)))))

(define (gitlab-request path #:method [method get] #:params [params #f])
  (set! params (if (hash? params) (hash->queryparams params) params))
  (response-json (method (format "https://~a/api/v4/~a" (gitlab-host) path)
                         #:params params
                         #:headers (hasheq 'Private-Token (gitlab-api-token)))))

(define (symbol->keyword a)
  (string->keyword (symbol->string a)))

(define (hash->keyapply-pair x)
  (define keys (list))
  (define valz (list))
  (for ([a (hash->list x)])
    (set! keys (cons (symbol->keyword (car a)) keys))
    (set! valz (cons (cdr a) valz)))
  (list keys valz))

(define (gitlab-api-exhaust-pagination endpoint argshash)
  (define result
    (apply keyword-apply
           (append (list gitlab-request) (hash->keyapply-pair argshash) (list (list endpoint)))))

  (if (empty? result)
      result
      (cons result
            (gitlab-api-exhaust-pagination
             endpoint
             (hash-set argshash 'params
                           (hash-set (hash-ref argshash 'params) 'id_after (hash-ref (last result) 'id)))))))


(define (gitlab-list-all-projects)
  (gitlab-api-exhaust-pagination
   "projects"
   (hasheq 'params (hasheq 'sort "asc" 'order_by "id" 'min_access_level "30" 'archived "false"))))

(define (gitlab-project-api-url proj-name)
  (format "projects/~a" (if (string-contains? proj-name "/") (uri-encode proj-name) proj-name)))

(define (gitlab-project-request project-id path #:method [method get])
  (gitlab-request (format "~a/~a" (gitlab-project-api-url project-id) path) #:method method))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (check-not-exn (lambda () (write-json (gitlab-list-all-projects)))))
