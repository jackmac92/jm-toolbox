#lang racket/base

(require
  splitflap
  json
  (prefix-in http-client: net/http-easy)
  web-server/servlet
  web-server/servlet-env)

(define custom-feeds-file (make-parameter (build-path (find-system-path 'home-dir) ".local/custom-feeds")))

(define (read-custom-feed-json feedid)
  (with-input-from-file (custom-feeds-file)
    (lambda () (read-json))))

(define (add-to-custom-feed req)
  (let ((reqjson (bytes->jsexpr (request-post-data/raw req))))
    (let ((feedid (hash-ref reqjson 'feed))
          (url (hash-ref reqjson 'url)))

      (log-info "Feed ~a adding ~s" feedid url)))


  ;; 
  (response/empty))

(define (write-feed-response req feed)
  ;; TODO how to auto define the url below based on the feed-id and basename?
  (response/output (express-xml feed 'atom "")))

(define (make-feed feed-id feed-url feed-title feed-items)
  (feed feed-id feed-url feed-title feed-items))

(define-values (dispatch _generate-url)
  (dispatch-rules
   [("custom") #:method "post" add-to-custom-feed]
   ;; [("custom") my-custom-feed]
   ;; [("reddit-best-of") reddit-best-of]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

(define (fetch-reddit-best-of-json)
  (http-client:response-json (http-client:get "https://www.reddit.com/r/bestof.json")))

(define f (fetch-reddit-best-of-feed))

(provide init)

(define (start-server)
  (serve/servlet
   dispatch
   #:launch-browser? #f
   #:quit? #t
   #:stateless? #t
   #:listen-ip "0.0.0.0"
   #:port 3986
   #:servlet-regexp #rx""))

(define (init)
  (parameterize ([current-basedir-program-name "custom-feed-server"])
   (define logging-output-port (make-log-file (writable-runtime-file "out.log")))
   (with-logging-to-port
     logging-output-port
     start-server
     'debug)))

;; (init)
