#lang racket/base

(require
 racket/system
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


(define repeat-notif-interval-sec (make-parameter 300))

(define (get-colors-from-wallpaper n)
  (command->output-lines (format "magick /home/jmccown/.cache/styli.sh/wallpaper.jpg -colors ~a -unique-colors txt: | grep -v enumeration | choose 2" n)))




(define (generate-periodic-email-notifs acct id color [last-check-email-count 0] [last-notif-ts 0])
  (define email-infos (notmuch-list-unread acct))
  (define email-count (length email-infos))
  (define email-ids (for/list ([e email-infos])
                      (last (string-split e))))
  (define font-color (if (use-light-font? color) "#000000" "#ffffff"))
  (log-debug (format "~a has ~a new messages" acct email-count))
  (define new-email-count (- email-count last-check-email-count))
  (define (dunstify-helper title subtitle)
    (define response (dunstify (stringify-flag-pairs (list
                                                      (cons "--timeout" (* 1000 60 20))
                                                      (cons "--icon" "/usr/share/icons/HighContrast/scalable/apps-extra/internet-mail.svg")
                                                      (cons "--hints" "string:category:email.arrived")
                                                      (cons "--hints" (format "string:bgcolor:~a" color))
                                                      (cons "--hints" (format "string:fgcolor:~a" font-color))
                                                      (cons "--replace" id)
                                                      (cons "--action" (format "~s" "default,Open Notmuch"))))
                               #:title title
                               #:subtitle subtitle))
    (case response
        [("1") (begin (log-info "Handling timeout"))]
        [("2") (begin (log-info "Handling dismissed"))]
        [("default") (begin
                       (log-debug "Handling default action")
                       (displayln (call-with-output-string (lambda (p)
                                                             (parameterize ([current-error-port p]
                                                                            [current-output-port p]
                                                                            [current-input-port (open-input-string (string-join email-ids "\n"))])
                                                               (system (format "/home/jmccown/.local/sysspecific_scripts/gui/emacs-view-emails ~s" acct)))))))]))
                                                               

  (when (> email-count 0)
    (if (> new-email-count 0)
        (begin
          (set! last-notif-ts (current-seconds))
          (thread (lambda () (dunstify-helper (format "~a NEW email" acct) (format "~a new emails" email-count)))))
        (when (and
               (< (repeat-notif-interval-sec) (- (current-seconds) last-notif-ts))
               (not (= 0 last-notif-ts)))
          (set! last-notif-ts (current-seconds))
          (thread (lambda () (dunstify-helper (format "~a still has email" acct) (format "~a total emails" email-count)))))))
  (sleep 15)
  (generate-periodic-email-notifs acct id color email-count last-notif-ts))

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
  (define id (for/sum
                 ([c (string->list acct)])
               (char->integer c)))
  (define color (list-ref colors (index-of accts acct)))
  (thread (lambda () (generate-periodic-email-notifs acct id color))))

(define (start-all-notifiers)
  (displayln "Starting")
  (for ([t (for/list ([acct accts]) (start-email-notifier acct))])
    (thread-wait t)))


(define (init)
  (parameterize ([current-basedir-program-name "email-notifier"])
   (define logging-output-port (make-log-file (writable-runtime-file "out.log")))
   (with-logging-to-port
     logging-output-port
     start-all-notifiers
     'debug)))

(init)

;; (module+ test
;;   (require rackunit)
;;   (check-not-exn (lambda ()
;;                    empty)))
