#lang racket/base

(require splitflap
         ;; group-by conflicts with racket/list
         (except-in deta group-by)
         racket/string
         gregor
         basedir
         "./litestream.rkt")

;; one json file is one feed
;; feed schema
;; name: string
;; id: string
;; items: FeedItem[]

(define-schema persistent-feed-item
  ([id id/f #:primary-key #:auto-increment]
   ;; [feed-id id/f]
   [title string/f #:wrapper string-titlecase]
   [url string/f #:contract non-empty-string?]
   [content string/f]
   [author-name string/f]
   [author-email string/f]
   [published-date date/f]
   [updated-date date/f]))

(define (mint-subfeed-tag topic)
  (mint-tag-uri "jackmac79@gmail.com" "2022" topic))

(define (make-feed feed-id feed-url feed-title feed-items)
  (feed feed-id feed-url feed-title feed-items))

(define (add-dummy-feed)
  (make-persistent-feed-item
   #:title "Hello world"
   #:url "Hello world"
   #:author-name "Hello world"
   #:author-email "Hello world"
   #:published-date (date 2000 1 1)
   #:updated-date (date 2000 1 1)
   #:content "Hello world"))




(define (init)
  (parameterize ([current-basedir-program-name "rss-feed-generator"])
    (define conn (litestream-dwim))
    (create-table! conn 'persistent-feed-item)

    ;; (insert! conn (add-dummy-feed))
    (in-entities conn (from persistent-feed-item #:as potato))))


(module+ main
  (init))
