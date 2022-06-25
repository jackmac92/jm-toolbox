#lang racket/base

(require basedir
         json
         "./utils.rkt")

(define (find-chrome-executable)
  (if (eq? (system-type 'os) 'unix)
      (for/first ([c (list "google-chrome-stable" "google-chrome" "google-chrome-beta")])
        (find-executable-path c))
      (build-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")))

(define (debug-port-flag port)
  (format "--remote-debugging-port=~a" port))

(define (get-chrome-default-flags)
  (if (eq? (system-type 'os) 'unix) "--use-gl=desktop --disable-gpu" ""))

(define (find-chrome-root-config-dir)
  (if (eq? (system-type 'os) 'unix)
      (car (list-config-dirs #:program "google-chrome"))
      (build-path (find-system-path 'home-dir) "Library/Application Support/Google/Chrome")))

(struct chrome-profile (id email display-name directory icon))

(define (chrome-read-json-state-file)
  (hash-ref (call-with-input-file (build-path (find-chrome-root-config-dir) "Local State")
                                  (lambda (in) (read-json in)))
            'profile))

;; (active_time . 1654206425.769405)
(define (read-chrome-profile-cache)
  (define profile-info-all (chrome-read-json-state-file))
  (define profile-info (hash-ref profile-info-all 'info_cache))
  (for/list ([profi (hash->list profile-info)])
    (define i (cdr profi))
    (chrome-profile (hash-ref i 'gaia_id)
                    (hash-ref i 'user_name)
                    (hash-ref i 'name)
                    (symbol->string (car profi))
                    (maybe-hash-ref i 'last_downloaded_gaia_picture_url_with_size))))

(define (chrome-profile-email->profile-path--strict target-email)
  (for/first ([p (read-chrome-profile-cache)] #:when (equal? (chrome-profile-email p) target-email))
    (chrome-profile-directory p)))

(define (chrome-profile-email->profile-path chrome-profile)
  (with-handlers ([exn:fail? (lambda (_) "Default")])
    (chrome-profile-email->profile-path--strict chrome-profile)))

(define (chrome-profile-id-from-email email)
  (for/first ([p (read-chrome-profile-cache)] #:when (equal? (chrome-profile-email p) email))
    (chrome-profile-directory p)))

(provide (all-defined-out))

(module+ test
  (require rackunit)
  (when (find-chrome-executable)
    (check-not-exn (lambda () (chrome-profile-email->profile-path "jmccown@cbinsights.com")))
    (check-not-exn (lambda () (read-chrome-profile-cache)))))
