#lang racket

(require anaphoric)
(require debug/repl)
(require hash-lambda)
(require racket/pretty)
(require racket/contract)
(require net/uri-codec)

(require google)
(require google/oauth)
(require google/oauth/cli)
(require google/profile)
(require google/calendar)
(require google/simple-token-store)

;; Download client_secret.json from your application's credentials
;; console, https://console.developers.google.com/
(define c (file->client "client_secret.json"))
(define target-cal "ff1v4j7spb546rmg1ile414j0g@group.calendar.google.com")

;; You can use google/oauth/cli's "main" submodule to get a token for
;; yourself for dev/test purposes and store it in the racket prefs
;; (which is where lookup-google-token gets it from).
;; (provide list-my-cals)
;; (define/contract list-events
;;    (->*
;;     (string?)
;;     (#:always-include-email boolean?
;;      #:i-cal-uid string?
;;      #:max-attendees string?
;;      #:max-results string?
;;      #:order-by string?
;;      #:page-token (or/c string? #f)
;;      #:private-extended-property any/c
;;      #:q string?
;;      #:shared-extended-property any/c
;;      #:show-deleted boolean?
;;      #:show-hidden-invitations boolean?
;;      #:single-events boolean?
;;      #:sync-token string?
;;      #:time-max string?
;;      #:time-min string?
;;      #:time-zone string?
;;      #:updated-min any/c)
;;     any/c)
;;    (hash-lambda args
;;                 ;; (displayln args)
;;                 (displayln
;;                  (alist->form-urlencoded
;;                   (for/list
;;                       ([(i j) args] #:when (keyword? i))
;;                     (cons i j))))
;;                 (json-api-get (string->url
;;                                (format
;;                                 "https://www.googleapis.com/calendar/v3/calendars/~a/events?~a"
;;                                 (form-urlencoded-encode (hash-ref args 0))
;;                                 (format "pageToken=~a" (hash-ref args '#:page-token))))
;;                               #:token (hash-ref args '#:token))))




(module+ main
 (define t (or
            (lookup-google-token c)
            (let ((newtoken (simple-cli-oauth-login c (list profile-scope calendar-scope))))
              (store-google-token! c "main" newtoken)
              newtoken)))

 (define (list-my-cals [nextpgtoken #f])
  (with-handlers [(exn:fail:google?
                   (lambda (e)
                     ;; Printing the exception shows all of the detail
                     ;; of it in a way that the default exception
                     ;; printer does not; conversely, letting the
                     ;; default exception printer print it too gets us a
                     ;; pretty stack trace.
                     (pretty-print e)
                     (raise e)))]
    (parameterize ((invalid-token-handler
                    (lambda (old-token retry-counter)
                      ;; When a configured token fails, the
                      ;; invalid-token-handler parameter is called. Here
                      ;; we can try to refresh the token, and if that
                      ;; fails we could also ask the user to sign in
                      ;; again if we wanted. In this instance, we only
                      ;; try the refresh, and if that fails, we fail
                      ;; permanently.
                      (printf "Failed token (retry ~a): ~v\n" retry-counter old-token)
                      (if (zero? retry-counter)
                          (let ((new-token (refresh-token c old-token)))
                            (when new-token
                              (replace-google-token! c new-token)
                              (set! t new-token))
                            new-token)
                          #f))))
      (define r (list-events
                 target-cal
                 #:token t
                 #:order-by "startTime"
                 #:single-events #t
                 #:page-token nextpgtoken))
      (append
       (hash-ref r 'items)
       (aif (hash-ref r 'nextPageToken #f)
            (list-my-cals it)
            empty)))))

 (let ((events (list-my-cals)))
   (displayln (length events))
   (displayln (car events))))
