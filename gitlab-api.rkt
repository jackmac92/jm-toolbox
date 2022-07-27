#lang racket/base

(require net/http-easy
         json
         racket/contract
         racket/string
         racket/list
         net/uri-codec)

(define gitlab-api-token (make-parameter ""))
(define gitlab-host (make-parameter "gitlab.com"))

(define (gitlab-api-url)
  (format "https://~a/api/v4/" (gitlab-host)))

(define (unbox-if-needed x)
  (if (box? x) (unbox x) x))

(define (hash->queryparams x)
  (for/list ([a (hash->list x)])
    (cons (car a) (format "~a" (cdr a)))))

(define/contract (gitlab-request-raw path #:method [method get] #:params [params (hasheq)])
                 (->* (non-empty-string?) (#:method any/c #:params (or/c hash? list?)) response?)
                 (define gl-token (gitlab-api-token))
                 (unless (non-empty-string? gl-token)
                   (error "No token found in parameter"))
                 (set! params (if (hash? params) (hash->queryparams params) params))
                 (method (format "https://~a/api/v4/~a" (gitlab-host) path)
                         #:params params
                         #:headers (hasheq 'Private-Token gl-token)))

(define/contract (gitlab-request path #:method [method get] #:params [params (hasheq)])
                 (->* (non-empty-string?) (#:method any/c #:params (or/c hash? list?)) jsexpr?)
                 (response-json (gitlab-request-raw path #:method method #:params params)))

(define/contract (symbol->keyword a) (-> symbol? keyword?) (string->keyword (symbol->string a)))

(define (hash->keyapply-pair x)
  (define keys (list))
  (define valz (list))
  (for ([a (hash->list x)])
    (set! keys (cons (symbol->keyword (car a)) keys))
    (set! valz (cons (cdr a) valz)))
  (list keys valz))

(define/contract (bytes-header->pair s)
                 (-> bytes? pair?)
                 (define parts (string-split (bytes->string/utf-8 s) ":"))
                 (when (empty? parts)
                   (error "Invalid header string"))
                 (define key (car parts))
                 (define val (string-join (cdr parts)))
                 (cons (string->symbol (string-downcase key)) val))

(define (gitlab-api-exhaust-pagination endpoint argshash)
  (define result
    (apply keyword-apply
           (append (list gitlab-request-raw) (hash->keyapply-pair argshash) (list (list endpoint)))))
  (define respbody (response-json result))
  (define respheaders
    (for/hasheq ([h (response-headers result)])
      (let ([x (bytes-header->pair h)]) (values (car x) (cdr x)))))

  (define is-last-page (equal? (hash-ref respheaders 'x-page) (hash-ref respheaders 'x-total-pages)))
  (if is-last-page
      respbody
      (cons respbody
            (gitlab-api-exhaust-pagination
             endpoint
             (hash-set argshash
                       'params
                       (hash-set (hash-ref argshash 'params)
                                 'page
                                 (string-trim (hash-ref respheaders 'x-next-page))))))))

(define (gitlab-list-all-projects)
  (gitlab-api-exhaust-pagination
   "projects"
   (hasheq 'params (hasheq 'sort "asc" 'order_by "id" 'min_access_level 30 'archived "false"))))

(define (gitlab-project-api-url proj-name)
  (format "projects/~a" (if (string-contains? proj-name "/") (uri-encode proj-name) proj-name)))

(define (gitlab-project-request project-id path #:method [method get])
  (gitlab-request (format "~a/~a" (gitlab-project-api-url project-id) path) #:method method))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (parameterize* ([gitlab-host "gitlab.com"] [gitlab-api-token (getenv "GITLAB_API_TOKEN")])
    (check-not-exn (lambda () (gitlab-request "projects")))
    (check-not-exn (lambda () (gitlab-list-all-projects)))))
