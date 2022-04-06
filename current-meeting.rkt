#lang racket

(require json)
(require debug/repl)
(require gregor)

(define n (now))
(define all-mtgs (read-json (current-input-port)))
(define (to-datetime slist)
  (parse-datetime (string-join slist) "yyyy-MM-dd H:m"))

(define (meeting-ongoing? m)
  (let ((start (to-datetime (hash-ref m 'start)))
        (end (to-datetime (hash-ref m 'end))))
    (and (datetime>=? n start) (datetime<=? n end))))

(write-json (filter meeting-ongoing? all-mtgs) (current-output-port))
