#lang racket/base

(require
  splitflap
  racket/system
  json
  web-server/servlet
  web-server/servlet-env)

(provide start-server)

(define (write-feed-response req feed)
  ;; TODO how to auto define the url below based on the feed-id and basename?
  (response/output (express-xml feed 'atom "")))

(define (make-feed feed-id feed-url feed-title feed-items)
  (feed feed-id feed-url feed-title feed-items))

;; URL routing table (URL dispatcher).
(define-values (dispatch _generate-url)
  (dispatch-rules
   ;; [("clipcopy") #:method "post" write-system-pasteboard]
   [("reddit-best-of") reddit-best-of]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

;; Notice how request-handler has changed from the previous example.
;; It now directs all requests to the URL dispatcher.
(define (request-handler request)
  (dispatch request))

(define (start-server)
  (serve/servlet
   request-handler
   #:launch-browser? #f
   #:quit? #t
   #:stateless? #t
   #:listen-ip "0.0.0.0"
   #:port 3986
   #:servlet-regexp #rx""))
