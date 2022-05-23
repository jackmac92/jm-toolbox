#lang racket/base

(require basedir
         gregor
         racket/logging
         splitflap
         json
         argo
         (prefix-in http-client: net/http-easy)
         web-server/servlet
         web-server/servlet-env
         "./mini-project-utils.rkt")

;; one json file is one feed
;; feed schema
;; name: string
;; id: string
;; items: FeedItem[]
;;
;; FeedItem schema
;; url: string
;; title: string
;; content: string
;; author-name?: string
;; author-email?: string
;; published-date?: Date
;; updated-date?: Date

(define custom-feeds-directory
  (make-parameter (build-path (find-system-path 'home-dir) ".local/custom-feeds")))

(define (mint-subfeed-tag topic)
  (mint-tag-uri "jackmac79@gmail.com" "2022" topic))

(define (reify-feed-from-file feed-topic)
  (define feeds-info
    (with-input-from-file (build-path (custom-feeds-directory) (format "~a.json" feed-topic))
                          (read-json)))
  (define custom-feed-uri (mint-subfeed-tag feed-topic))
  (define (create-custom-feed-item item-def)
    (define item-id (hash-ref item-def 'id))
    (define item-url (hash-ref item-def 'url))
    (define item-title (hash-ref item-def 'title))
    (define item-author-name (hash-ref item-def 'author-name))
    (define item-author-email (hash-ref item-def 'author-email))
    (define item-publish-date (hash-ref item-def 'publish-date))
    (define item-update-date (hash-ref item-def 'update-date))
    (define content (hash-ref item-def 'content))
    (feed-item (append-specific custom-feed-uri item-id)
               item-url
               item-title
               (person item-author-name item-author-email)
               (infer-moment item-publish-date)
               (infer-moment item-update-date)
               content))
  (feed custom-feed-uri
        "https://feedz.jackdmc.com"
        (format "Racket autogen ~a" feed-topic)
        (for/list ([feed-item-def (hash-ref feeds-info 'items)])
          (create-custom-feed-item feed-item-def))))

;; (define (add-to-custom-feed req)
;;   (let* ([reqjson (bytes->jsexpr (request-post-data/raw req))]
;;          [feedid (hash-ref reqjson 'feed)]
;;          [url (hash-ref reqjson 'url)])

;;     (log-info "Feed ~a adding ~s" feedid url)
;;     ;; TODO how to add to
;;     (hash-set! all-feeds-info feedid (append current-feed-info (list (hasheq 'url url))))
;;     (unless (adheres-to-schema? all-feeds-info custom-feeds-schema)
;;       (error "addition does not adhere to schema"))))

(define (write-feed-response req feed)
  ;; TODO how to auto define the url below based on the feed-id and basename?
  (response/output (express-xml feed 'atom "")))

(define (make-feed feed-id feed-url feed-title feed-items)
  (feed feed-id feed-url feed-title feed-items))

(define-values (dispatch _generate-url)
  (dispatch-rules ;; [("custom") #:method "post" add-to-custom-feed]
   ;; [("custom") my-custom-feed]
   ;; [("reddit-best-of") reddit-best-of]
   [("health") (lambda (_) (response/empty))]
   [else (error "There is no procedure to handle the url.")]))

(define (fetch-reddit-best-of-json)
  (http-client:response-json (http-client:get "https://www.reddit.com/r/bestof.json")))

(define reddit-feed-uri (mint-subfeed-tag "bestofreddit"))

(define (reddit-post->feed-itm p)
  (define (create-custom-feed-item item-def)
    (define item-id (hash-ref item-def 'id))
    (define item-url (hash-ref item-def 'url))
    (define item-title (hash-ref item-def 'title))
    (define item-author-name (hash-ref item-def 'author-name))
    (define item-publish-date (~t (posix->datetime (hash-ref item-def 'publish-date)) "yyyy-MM-dd"))

    (define content (hash-ref item-def 'content))
    (feed-item (append-specific reddit-feed-uri item-id)
               item-url
               item-title
               (person item-author-name "jackmac79@gmail.com")
               (infer-moment item-publish-date)
               (infer-moment item-publish-date)
               content))
  (create-custom-feed-item (hasheq 'url
                                   (hash-ref p 'url)
                                   'id
                                   (hash-ref p 'id)
                                   'title
                                   (hash-ref p 'title)
                                   'content
                                   (hash-ref p 'url_overridden_by_dest)
                                   'author-name
                                   (hash-ref p 'author_fullname)
                                   'publish-date
                                   (hash-ref p 'created_utc))))

(feed reddit-feed-uri
      "https://feedz.jackdmc.com/reddit"
      "Racket autogen reddt"
      (for/list ([p (hash-ref (hash-ref (fetch-reddit-best-of-json) 'data) 'children)])
        (reddit-post->feed-itm (hash-ref p 'data))))
;; FeedItem schema
;; url: string
;; title: string
;; content: string
;; author-name?: string
;; author-email?: string
;; published-date?: Date
;; updated-date?: Date

(provide init)

(mint-subfeed-tag "bestofreddit")

;; id
;; title
;; url_overridden_by_dest
;; author_is_blocked
;; score
;; likes
;; downs
;; gildings
;; num_crossposts
;; category
;; subreddit_id
;; is_video
;; upvote_ratio
;; created_utc
;; subreddit
;; media_embed
;; awarders
;; author
;; name
;; view_count
;; author_fullname
;; url
;; created
;; gilded
;; all_awardings
;; content_categories
;; subreddit_type

(define (start-server)
  (serve/servlet dispatch
                 #:launch-browser? #f
                 #:quit? #t
                 #:stateless? #t
                 #:listen-ip "0.0.0.0"
                 #:port 3986
                 #:servlet-regexp #rx""))

(define (init)
  (parameterize ([current-basedir-program-name "custom-feed-server"])
    (define logging-output-port (make-log-file (writable-runtime-file "out.log")))
    (with-logging-to-port logging-output-port start-server 'debug)))

;; (init)
