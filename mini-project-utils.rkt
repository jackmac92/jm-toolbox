#lang racket

(require reprovide/reprovide)

(reprovide threading
           racket/format
           racket/file
           racket/list
           racket/string
           racket/logging
           racket/port
           basedir
           "./litestream.rkt"
           "./shellpers.rkt"
           "./json.rkt")

(define make-log-file
  (lambda components
    (define logfilepath (apply build-path components))
    (make-parent-directory* logfilepath)
    ;; TODO use (make-pipe) to create a pipe which also logs to stdout before the logfile
    ;; or maybe dup-output-port
    ;;or maybe start a thread, where copy-port streams to current-output-port?
    ;; (define log-file (open-output-file logfilepath #:exists 'append))
    ;; (thread (lambda () (copy-port log-file (current-output-port))))
    ;; log-file
    (open-output-file logfilepath #:exists 'append)))


(define (walk-up-path-until-info.rkt-found-1 p)
  (if (file-exists? (build-path p "info.rkt"))
      p
      (walk-up-path-until-info.rkt-found-1 (simplify-path (build-path p 'up)))))

(define (walk-up-path-until-info.rkt-found p)
  (define-values (_base name _must-be-dir) (split-path (walk-up-path-until-info.rkt-found-1 p)))
  (path->string name))

(define-syntax-rule (pkg-name!)
  (walk-up-path-until-info.rkt-found
   (variable-reference->module-source (#%variable-reference))))

(define (with-project-logging-fn cb)
  (parameterize ([current-basedir-program-name (pkg-name!)])
    (with-logging-to-port (make-log-file (writable-runtime-file "out.log")) (cb) 'debug)))

(define-syntax-rule (with-project-logging body)
  #'(parameterize ([current-basedir-program-name (pkg-name!)])
      (with-logging-to-port (make-log-file (writable-runtime-file "out.log"))
        body
        'debug)))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (check-not-exn (lambda () (displayln (pkg-name!))))
  (check-not-exn (lambda () (with-project-logging
                                (displayln "tada")))))
