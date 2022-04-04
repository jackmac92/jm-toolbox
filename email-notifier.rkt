#lang racket/base

(require
 racket/system
 racket/math
 racket/port
 racket/string
 racket/list
 racket/file
 racket/logging

 basedir

 "./notmuch.rkt" "./notify.rkt" "./shellpers.rkt")


(define accts (string-split (file->string (build-path (find-system-path 'home-dir) ".local/maildir-email-acct-short-names"))))

(define make-log-file (lambda components (let ((logfilepath (apply build-path components)))
                                           (make-parent-directory* logfilepath)
                                           (open-output-file logfilepath #:exists 'append))))

(define logging-output-port (make-log-file (writable-runtime-file "email-notifier")))

(define (get-colors-from-wallpaper n)
  (command->output-lines (format "magick /home/jmccown/.cache/styli.sh/wallpaper.jpg -colors ~a -unique-colors txt: | grep -v enumeration | choose 2" n)))

(define (generate-periodic-email-notifs acct id color [last-check-email-count 0])
  (define email-infos (notmuch-list-unread acct))
  (define email-count (length email-infos))
  (define email-ids (for/list ([e email-infos])
                      (last (string-split e))))
  (define font-color (if (use-light-font? color) "#000000" "#ffffff"))
  (log-debug (format "~a has ~a new messages" acct email-count))
  ;; (define new-email-count (- email-count last-check-email-count))
  (when (> email-count 0)
    (thread (lambda ()
              (let ((response (dunstify (stringify-flag-pairs (list
                                                               (cons "--timeout" (* 1000 10))
                                                               (cons "--icon" "/usr/share/icons/HighContrast/scalable/apps-extra/internet-mail.svg")
                                                               (cons "--hints" "string:category:email.arrived")
                                                               (cons "--hints" (format "string:bgcolor:~a" color))
                                                               (cons "--hints" (format "string:fgcolor:~a" font-color))
                                                               (cons "--replace" id)
                                                               (cons "--action" (format "~s" "default,Open Notmuch"))))
                                        #:title (format "~a received email" acct)
                                        #:subtitle (format "~a new emails" email-count))))
                (case (string-trim response)
                  [("1") (begin (log-info "Handling timeout"))]
                  [("2") (begin (log-info "Handling dismissed"))]
                  [("default") (begin
                                 (log-debug "Handling default action")
                                 (define email-ids-as-stdin (string-join email-ids "\n"))
                                 (displayln (call-with-output-string (lambda (p)
                                                                       (parameterize ([current-error-port p]
                                                                                      [current-input-port (open-input-string email-ids-as-stdin)]
                                                                                      [current-output-port p])
                                                                         (system (format "/home/jmccown/.local/sysspecific_scripts/gui/emacs-view-emails ~s" acct))
                                                                         (port->string p))))))])))))
  (sleep 15)
  (generate-periodic-email-notifs acct id color email-count))

(define colors (shuffle (get-colors-from-wallpaper (length accts))))

(define (hex-str->number hex)
  (string->number (format "#x~a" hex)))

(define (use-light-font? hex-code)
  (let ((ltrs (string->list hex-code)))
     (define red-hex (string (list-ref ltrs 1) (list-ref ltrs 2)))
     (define green-hex (string (list-ref ltrs 3) (list-ref ltrs 4)))
     (define blue-hex (string (list-ref ltrs 5) (list-ref ltrs 6)))
     (define red (hex-str->number red-hex))
     (define green (hex-str->number green-hex))
     (define blue (hex-str->number blue-hex))
     (> (+ (* red 0.299) (* green 0.587) (* blue 0.114)) 186)))

(define (start-email-notifier acct)
  (define id (exact-floor (* 20000 (random))))
  (define color (list-ref colors (index-of accts acct)))
  (thread (lambda () (generate-periodic-email-notifs acct id color))))

(log-debug "Starting")
(with-logging-to-port
  logging-output-port
  (lambda ()
    (for ([t (for/list ([acct accts]) (start-email-notifier acct))])
      (thread-wait t)))
  'debug)
