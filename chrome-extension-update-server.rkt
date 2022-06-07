#lang at-exp racket/base

(require xml)
(require web-server/servlet)
(require web-server/servlet-env)

(define ( create-xml url id ver) @~a{
                                     <?xml version='1.0' encoding='UTF-8'?>
                                     <gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
                                     <app appid='@id'>
                                         <updatecheck codebase='@url' version='@ver' />
                                     </app>
                                     </gupdate>})

(define (request-handler req)
  (define ext (hash-ref (bindings-assq #"payload" (request-bindings/raw req)) 'name))
  (xexpr->xml (hasheq 'hello "world")))

(module+ main
  (serve/servlet request-handler
                 #:launch-browser? #f
                 #:quit? #t
                 #:stateless? #t
                 #:listen-ip "0.0.0.0"
                 #:port 5576
                 #:servlet-regexp #rx""))
