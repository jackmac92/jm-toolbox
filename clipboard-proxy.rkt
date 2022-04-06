#lang racket/base

(require racket/system)
(require json)
(require web-server/servlet)
(require web-server/servlet-env)

(define (extract-payload req)
  (hash-ref (bytes->jsexpr (request-post-data/raw req)) 'payload))

;; (define (extract-payload req)
;;   "Extracts payload from POST body or query params"
;;   (let ((data (request-post-data/raw req)))
;;     (if (not (null data))
;;         (hash-ref (bytes->jsexpr data) 'payload)
;;         (bindings-assq #"payload" (request-bindings/raw req)))))

(define (write-port->clipboard port)
  (parameterize ([current-input-port port])
    (system "xsel --clipboard --input")))

(define (write-system-pasteboard req)
  (write-port->clipboard (open-input-string (extract-payload req)))
  (response/jsexpr (list "ok")))

(define (xdg-open req)
  (system (format "xdg-open '~a'" (extract-payload req)))
  (response/jsexpr (list "ok")))

;; URL routing table (URL dispatcher).
(define-values (dispatch _generate-url)
  (dispatch-rules
   [("clipcopy") #:method "post" write-system-pasteboard]
   [("open") xdg-open]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

(define (request-handler request)
  (dispatch request))

(serve/servlet
 request-handler
 #:launch-browser? #f
 #:quit? #t
 #:stateless? #t
 #:listen-ip "0.0.0.0"
 #:port 3986
 #:servlet-regexp #rx"")