#lang racket/base

(require reprovide/reprovide)

(reprovide racket/format
           racket/file
           racket/list
           racket/string
           racket/logging
           racket/port
           basedir
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

(define-syntax-rule (wheredoicomefrom)
  (variable-reference->namespace (#%variable-reference)))

(define-syntax-rule (whereami)
  (variable-reference->module-source (#%variable-reference)))

(define-syntax-rule (with-project-logging body)
  (parameterize ([current-basedir-program-name (whereami)])
    (with-logging-to-port (make-log-file (writable-runtime-file "out.log"))
                          ;; TODO somehow run body
                          'debug)))

(provide (all-defined-out))
