#lang racket/base

(require
  racket/cmdline
  "./mini-project-utils.rkt"
  "./gitlab-api.rkt")

(define (gitlab-pipeline-status project-id pipeline-id)
  (gitlab-project-request project-id (format "pipelines/~a" pipeline-id)))

(define (gitlab-pipeline-status-for-commit project-id sha)
  (gitlab-project-request project-id (format "pipelines/~a" (gitlab-pipeline-id-for-commit project-id sha))))

(define (gitlab-pipeline-id-for-commit project-id sha)
  (hash-ref (car (gitlab-project-request project-id (format "pipelines?sha=~a" sha))) 'id))

(define (run-app)
  (command-line #:program "gitlab-ci-tracker"
                #:args (action [secondary #f])
                (cond
                  [(string=? action "for-sha")
                   (write-json (gitlab-pipeline-status-for-commit (car (command->output-lines "s gitlab get-url-encoded-project-name-from-remote")) secondary))])))
                   
(define (init)
  (parameterize ([current-basedir-program-name "gitlab-ci-tracker"])
    (with-logging-to-port
        (make-log-file (writable-runtime-file "out.log"))
      run-app
      'debug)))

(module+ main
  (init))

(module+ test
  (require rackunit)
  (check-not-exn (lambda () (gitlab-pipeline-status-for-commit "jackmac92/personal-super-cookie" "23ddf84acce31e348762ce7491f97cfb901ef5a4"))))
