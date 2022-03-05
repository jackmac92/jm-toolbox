#lang racket/base

(require racket/math "./notmuch.rkt" "./notify.rkt" "./list-utils.rkt")

(define accts '("cbi" "jackmccown7" "pitchapp" "personalj79" "colgate"))

(define (generate-periodic-email-notifs acct id color [last-check-email-count 0])
 (define email-count (notmuch-count-unread acct))
 (displayln (format "~a has ~a new messages" acct email-count))
 (define new-email-count (- email-count last-check-email-count))
 (when ( > email-count  0)
   ;; 1 is timeout
   ;; 2 is right click
   (thread (lambda ()
             (let ((response (dunstify (format "--icon /usr/share/icons/HighContrast/scalable/apps-extra/internet-mail.svg --hints=string:category:email.arrived --replace=~a --hints=string:bgcolor:~a --hints=string:fgcolor:#000000 --action ~s ~s ~s" id color "default,Open Notmuch" (format "~a received email" acct) (format "~a new emails" email-count)))))
               (displayln (format "Notif action ~a" response)))))
   (sleep 5))
 (generate-periodic-email-notifs acct id color email-count))

(define (start-email-notifier acct)
  (define id (exact-floor (* 20000 (random))))
  (define color (pick '("#ff71ce" "#01cdfe" "#05ffa1" "#b967ff" "#fffb96")))
  (thread (lambda () (generate-periodic-email-notifs acct id color))))

(define notif-threads (for/list ([acct accts])
                        (start-email-notifier acct)))

(for ([t notif-threads])
  (thread-wait t))

;; "$addr received email" "$msgcount new emails" | rg -q launchEmail ; then echo "$newmessages" | s gui emacs-view-emails ; fi &
