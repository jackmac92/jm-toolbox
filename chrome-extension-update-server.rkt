#lang at-exp racket/base

(require
 racket/format
  xml)
(require web-server/servlet)
(require web-server/servlet-env)
(require "./gitlab-api.rkt")

;; TODO codebase url should be a gitlab artifact
;; make gitlab request to check the version, should run on just the name
(define (create-xml url id ver) @~a{<?xml version='1.0' encoding='UTF-8'?>
                                    <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
                                    <app appid='@id'>
                                        <updatecheck codebase='@url' version='@ver' />
                                    </app>
                                    </gupdate>})
;; "https://gitlab.com/api/v4/projects/36836128/packages/generic/web-extension/0.0.1/chrome-dist.zip"

(define (create-xml-dwim name chrome-ext-id)
  (define latest-version (hash-ref (car (gitlab-project-request (format "jackmac92/~a" name) "releases")) 'tag_name))
  (define url (format "~a/~a/~a" (gitlab-host) (gitlab-project-api-url (format "jackmac92/~a" name)) (format "packages/generic/web-extension/~a/chrome-dist.zip" latest-version)))
  (create-xml url chrome-ext-id latest-version))

(define (request-handler req)
  (define ext (binding:form-value (bindings-assq #"name" (request-bindings/raw req))))
  (define ext-id (binding:form-value (bindings-assq #"chrome-id" (request-bindings/raw req))))
  (response/output (lambda (op) (write-bytes (string->bytes/utf-8 (create-xml-dwim ext ext-id)) op))))

(module+ main
  (serve/servlet request-handler
                 #:launch-browser? #f
                 #:quit? #t
                 #:stateless? #t
                 #:listen-ip "0.0.0.0"
                 #:port 5576
                 #:servlet-regexp #rx""))
