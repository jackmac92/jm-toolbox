#lang at-exp racket/base

(require
 racket/format)
(require web-server/servlet)
(require web-server/servlet-env)
(require "./gitlab-api.rkt")

(define (print-xml url id ver) @~a{<?xml version='1.0' encoding='UTF-8'?>
                                   <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
                                   <app appid='@id'>
                                       <updatecheck codebase='@url' version='@ver' />
                                   </app>
                                   </gupdate>})

(define (create-xml-dwim name chrome-ext-id)
  (define latest-release (car (gitlab-project-request (format "jackmac92/~a" name) "releases")))
  (define latest-version (hash-ref latest-release 'tag_name))
  (define latest-release-details (gitlab-project-request (format "jackmac92/~a" name) (format "releases/~a" latest-version)))
  (define url (for/first ([l (hash-ref (hash-ref latest-release-details 'assets) 'links)]
                          #:when (equal? (hash-ref l 'name) "web-ext-dist.crx"))
                (hash-ref l 'url)))
  (print-xml url chrome-ext-id latest-version))

(define (lookup-ext-xml req)
  (define ext (binding:form-value (bindings-assq #"name" (request-bindings/raw req))))
  (define ext-id (binding:form-value (bindings-assq #"id" (request-bindings/raw req))))
  (response/output (lambda (op) (write-string (create-xml-dwim ext ext-id) op))))


(define-values (dispatch _generate-url)
  (dispatch-rules
   [("info") lookup-ext-xml]
   [("personal-super-cookie") (lambda (res) (response/output (lambda (op) (write-string (create-xml-dwim "personal-super-cookie" "odlameecjipmbmbejkplpemijjgpljce") op))))]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

(define (request-handler request)
  (dispatch request))

(module+ main
  (serve/servlet request-handler
                 #:launch-browser? #f
                 #:quit? #t
                 #:stateless? #t
                 #:listen-ip "0.0.0.0"
                 #:port 5576
                 #:servlet-regexp #rx""))
