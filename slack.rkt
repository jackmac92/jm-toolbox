#lang racket/base

(require racket/cmdline
         net/http-easy)


(define (slack-api-req path body)
  (post (format "https://slack.com/api/~a" path)
        #:auth (bearer-auth (getenv "SLACK_API_TOKEN"))
        #:json body))

(define forty-five-min (* 60 45))

(define presets (hasheq
                 'reset (hasheq 'status_emoji ""
                                'status_expiration 0
                                'status_text "")
                 'taz (hasheq 'status_emoji ":jump:"
                              'status_expiration (floor (+ (current-seconds) forty-five-min))
                              'status_text "walking Taz")
                 'zoom (hasheq 'status_emoji ":zoom:"
                               'status_expiration 0
                               'status_text "In a zoom meeting")
                 'lunch (hasheq 'status_emoji ":chompy:"
                                'status_expiration (floor (+ (current-seconds) forty-five-min))
                                'status_text "eating")
                 'testing (hasheq 'status_emoji ":hellmo:"
                                  'status_expiration (floor (+ (current-seconds) forty-five-min))
                                  'status_text "test")))

(command-line
 #:program "slacker"
 #:args (action [subcommand #f])
 (cond
   [(string=? action "status") (slack-api-req
                                "users.profile.set"
                                (hasheq 'profile
                                        (hash-ref
                                         presets
                                         (string->symbol (or subcommand "reset")))))]))
