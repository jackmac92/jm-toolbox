#lang racket/base

(require
  splitflap
  (prefix-in http-client: net/http-easy)
  web-server/servlet
  web-server/servlet-env)


(define (write-feed-response req feed)
  ;; TODO how to auto define the url below based on the feed-id and basename?
  (response/output (express-xml feed 'atom "")))

(define (make-feed feed-id feed-url feed-title feed-items)
  (feed feed-id feed-url feed-title feed-items))

URL routing table (URL dispatcher)
(define-values (dispatch _generate-url)
  (dispatch-rules
   ;; [("custom") #:method "post" add-to-custom-feed]
   ;; [("custom") my-custom-feed]
   ;; [("reddit-best-of") reddit-best-of]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

(define (fetch-reddit-best-of-feed)
  (http-client:response-xexpr (http-client:get "https://www.reddit.com/r/bestof.rss")))

(define f (fetch-reddit-best-of-feed))

(define (start-server)
  (serve/servlet
   dispatch
   #:launch-browser? #f
   #:quit? #t
   #:stateless? #t
   #:listen-ip "0.0.0.0"
   #:port 3986
   #:servlet-regexp #rx""))

(provide start-server)
