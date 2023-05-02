#lang racket/base

(require json
         racket/cmdline
         "./shellpers.rkt"
         net/http-easy)

(define (slack-resp-wrapper resp)
  (write-json
   (response-json resp)))

(define slack-token (or (getenv "SLACK_API_TOKEN") (system->string "s bitwarden get-field 'CBI Slack' 'status-script-token'")))

(define (slack-api-post path body)
  (slack-resp-wrapper (post (format "https://slack.com/api/~a" path)
                            #:auth (bearer-auth slack-token)
                            #:json body)))

(define (slack-api-get path [params (list)])
  (slack-resp-wrapper (get (format "https://slack.com/api/~a" path)
                           #:params params
                           #:auth (bearer-auth slack-token))))

(define forty-five-min (* 60 45))

(define presets
  (hasheq 'reset
          (hasheq 'status_emoji "" 'status_expiration 0 'status_text "")
          'taz
          (hasheq 'status_emoji
                  ":jump:"
                  'status_expiration
                  (floor (+ (current-seconds) forty-five-min))
                  'status_text
                  "walking Taz")
          'zoom
          (hasheq 'status_emoji ":zoom:" 'status_expiration 0 'status_text "In a zoom meeting")
          'lunch
          (hasheq 'status_emoji
                  ":chompy:"
                  'status_expiration
                  (floor (+ (current-seconds) forty-five-min))
                  'status_text
                  "eating")
          'testing
          (hasheq 'status_emoji
                  ":hellmo:"
                  'status_expiration
                  (floor (+ (current-seconds) forty-five-min))
                  'status_text
                  "test")))

(command-line
 #:program "slacker"
 #:args (action [subcommand #f])
 (cond
   [(string=? action "status")
    (slack-api-post "users.profile.set"
                    (hasheq 'profile (hash-ref presets (string->symbol (or subcommand "reset")))))]
   [(string=? action "ls-users") (slack-api-get "users.list")]))
