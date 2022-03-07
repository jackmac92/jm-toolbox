#lang racket/base

(require
 racket/system
 racket/math
 racket/port
 racket/string
 racket/list
 "./notmuch.rkt" "./notify.rkt" "./list-utils.rkt" "./shellpers.rkt")

(define accts '("cbi" "jackmccown7" "pitchapp" "personalj79" "colgate"))

(define (generate-periodic-email-notifs acct id color [last-check-email-count 0])
  (define email-infos (notmuch-list-unread acct))
  (define email-count (length email-infos))
  (define email-ids (for/list ([e email-infos])
                      (last (string-split e))))
  (displayln (format "~a has ~a new messages" acct email-count))
  (define new-email-count (- email-count last-check-email-count))
  (when ( > new-email-count 0)
    (thread (lambda ()
              (let ((response (dunstify (stringify-flag-pairs (list
                                                               (cons "--timeout" (* 1000 60 20))
                                                               (cons "--icon" "/usr/share/icons/HighContrast/scalable/apps-extra/internet-mail.svg")
                                                               (cons "--hints" "string:category:email.arrived")
                                                               (cons "--hints" (format "string:bgcolor:~a" color))
                                                               (cons "--hints" "string:fgcolor:#000000")
                                                               (cons "--replace" id)
                                                               (cons "--action" (format "~s" "default,Open Notmuch"))))
                                        #:title (format "~a received email" acct)
                                        #:subtitle (format "~a new emails" email-count))))
                (case (string-trim response)
                  [("1") (begin (displayln "Handling timeout"))]
                  [("2") (begin (displayln "Handling dismissed"))]
                  [("default") (begin
                                 (displayln "Handling default action")
                                 (define email-ids-as-stdin (string-join email-ids "\n"))
                                 (displayln email-ids-as-stdin)
                                 (with-input-from-string email-ids-as-stdin
                                   (lambda ()
                                     (system "/home/jmccown/.local/sysspecific_scripts/gui/emacs-view-emails"))))])))))
  (sleep 15)
  (generate-periodic-email-notifs acct id color email-count))

(define colors (shuffle '("#ff71ce" "#01cdfe" "#05ffa1" "#b967ff" "#fffb96")))

(define (start-email-notifier acct)
  (define id (exact-floor (* 20000 (random))))
  (define color (list-ref colors (index-of accts acct)))
  (thread (lambda () (generate-periodic-email-notifs acct id color))))

(for ([t (for/list ([acct accts]) (start-email-notifier acct))])
  (thread-wait t))
