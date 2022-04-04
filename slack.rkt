#lang racket/base

(require racket/cmdline net/http-easy
         gregor)


(define (slack-api-req path body)
  (post (format "https://slack.com/api/~a" path)
        #:auth (bearer-auth (getenv "SLACK_API_TOKEN"))
        #:json body))

;; (slack-api-req "users.profile.set" (hasheq 'profile "PROFILE_STUFF"))

;; (post "https://slack.com/api/users.profile.set"
;;       #:form (list (cons 'profile "PROFILE_STUFF") (cons 'token "TOKEN")))
;; PROFILE="{\"status_emoji\":\"$EMOJI\",\"status_text\":\"$TEXT\"}"
;; RESPONSE=$(curl -s --data token="$TOKEN" \
;;     --data-urlencode profile="$PROFILE" \
;;     https://slack.com/api/users.profile.set)
;; let profile = json!({
;;                      "status_emoji": status.emoji,
;;                      "status_text": status.text,
;;                      "status_expiration": expiration})
;;     ;

(define forty-five-min (* 60 45))

(command-line
  #:program "slacker"
  #:args (action)
  (cond
    [(string=? action "status") (slack-api-req "users.profile.set" (hasheq
                                                                    'profile
                                                                    (hasheq 'status_emoji ":hellmo:"
                                                                            'status_expiration (+ (current-posix-seconds) forty-five-min)
                                                                            'status_text "test")))]))
