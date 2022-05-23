#lang racket/base

(require racket/system
         racket/port
         racket/string
         racket/list
         racket/file
         racket/logging

         json
         basedir

         "./notmuch.rkt"
         "./mini-project-utils.rkt"
         "./notify.rkt"
         "./shellpers.rkt")

(define accts
  (string-split (file->string (build-path (find-system-path 'home-dir)
                                          ".local/maildir-email-acct-short-names"))))

(define root-output-port (make-parameter (current-output-port)))

(define repeat-notif-interval-sec (make-parameter (* 60 60 2)))

(define (get-colors-from-wal-cache)
  (define colors-cache
    (with-input-from-file (build-path (find-system-path 'home-dir) ".cache/wal/colors.json")
                          (lambda () (read-json))))
  (hash-values (hash-ref colors-cache 'colors)))

(define (get-colors-from-wallpaper-via-imagemagick n)
  (command->output-lines
   (format
    "magick /home/jmccown/.cache/styli.sh/wallpaper.jpg -colors ~a -unique-colors txt: | grep -v enumeration | choose 2"
    n)))

(define (get-colors-from-wallpaper n)
  (or (get-colors-from-wal-cache) (get-colors-from-wallpaper-via-imagemagick n)))

(define (generate-periodic-email-notifs acct id color [last-check-email-count 0] [last-notif-ts 0])
  (define email-infos (notmuch-list-unread acct))
  (define email-count (length email-infos))
  (define email-ids
    (for/list ([e email-infos])
      (last (string-split e))))
  (define font-color (if (use-light-font? color) "#000000" "#ffffff"))
  (log-debug (format "~a has ~a new messages" acct email-count))
  (define new-email-count (- email-count last-check-email-count))
  (define (dunstify-helper title subtitle)
    (define response
      (dunstify
       (stringify-flag-pairs
        (list (cons "--timeout" (* 1000 60 20))
              (cons "--icon" "/usr/share/icons/HighContrast/scalable/apps-extra/internet-mail.svg")
              (cons "--hints" "string:category:email.arrived")
              (cons "--hints" (format "string:bgcolor:~a" color))
              (cons "--hints" (format "string:fgcolor:~a" font-color))
              (cons "--replace" id)
              (cons "--action" (format "~s" "default,Open Notmuch"))))
       #:title title
       #:subtitle subtitle))
    (case response
      [("1")
       (begin
         (log-info "Handling timeout"))]
      [("2")
       (begin
         (log-info "Handling dismissed"))]
      [("default")
       (with-input-from-string (string-join email-ids "\n")
         (lambda ()
           (system (format "DISPLAY=:1 s notmuch open-new-msgs-in-emacs ~a" acct))))]))

  (when (> email-count 0)
    (if (not (= new-email-count 0))
        (begin
          (set! last-notif-ts (current-seconds))
          (thread (lambda ()
                    (dunstify-helper (format "~a NEW email" acct)
                                     (if (eq? new-email-count email-count)
                                         (format "~a unread emails" email-count)
                                         (format "~a/~a NEW/total unread emails" new-email-count email-count))))))
        (when (and (< (repeat-notif-interval-sec) (- (current-seconds) last-notif-ts))
                   (not (= 0 last-notif-ts)))
          (set! last-notif-ts (current-seconds))
          (thread (lambda ()
                    (dunstify-helper (format "~a still has email" acct)
                                     (format "~a total emails" email-count)))))))
  (sleep 15)
  (generate-periodic-email-notifs acct id color email-count last-notif-ts))

(define colors (shuffle (get-colors-from-wallpaper (length accts))))

(define (hex-str->number hex)
  (string->number (format "#x~a" hex)))

(define (use-light-font? hex-code)
  (let ([ltrs (string->list hex-code)])
    (define red-hex (string (list-ref ltrs 1) (list-ref ltrs 2)))
    (define green-hex (string (list-ref ltrs 3) (list-ref ltrs 4)))
    (define blue-hex (string (list-ref ltrs 5) (list-ref ltrs 6)))
    (define red (hex-str->number red-hex))
    (define green (hex-str->number green-hex))
    (define blue (hex-str->number blue-hex))
    (> (+ (* red 0.299) (* green 0.587) (* blue 0.114)) 186)))

(define (start-email-notifier acct)
  (define id (for/sum ([c (string->list acct)]) (char->integer c)))
  (define color (list-ref colors (index-of accts acct)))
  (thread (lambda () (generate-periodic-email-notifs acct id color))))

(define (start-all-notifiers)
  (displayln "Starting")
  (for ([t (for/list ([acct accts])
             (start-email-notifier acct))])
    (thread-wait t)))

(define (init)
  (parameterize ([current-basedir-program-name "email-notifier"])
    (define logging-output-port (make-log-file (writable-runtime-file "out.log")))
    (with-logging-to-port logging-output-port start-all-notifiers 'debug)))

(init)
