#lang racket/base

(require basedir
         json
         "./utils.rkt")

(define (find-chrome-executable)
  (if (eq? (system-type 'os) 'unix)
      (for/first ([c (list "google-chrome-stable" "google-chrome" "google-chrome-beta")])
        (find-executable-path c))
      (format "~a -a \"Google Chrome\"" (find-executable-path "open"))))

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

;; (account_categories . 0)
;; (active_time . 1654206425.769405)
;; (avatar_icon . "chrome://theme/IDR_PROFILE_AVATAR_26")
;; (background_apps . #f)
;; (default_avatar_fill_color . -13945027)
;; (default_avatar_stroke_color . -1)
;; (first_account_name_hash . 481)
;; (force_signin_profile_locked . #f)
;; (gaia_given_name . "Jack")
;; (gaia_id . "113159224992409151946")
;; (gaia_name . "Jack McCown")
;; (gaia_picture_file_name . "Google Profile Picture.png")
;; (hosted_domain . "NO_HOSTED_DOMAIN")
;; (is_consented_primary_account . #t)
;; (is_ephemeral . #f)
;; (is_using_default_avatar . #t)
;; (is_using_default_name . #f)
;; (last_downloaded_gaia_picture_url_with_size . "https://lh3.googleusercontent.com/a-/AOh14GguBk05LaqwHsywHrbXLtAJeGHOHqnm7g3YRauTe-Q=s256-c-ns")
;; (managed_user_id . "")
;; (metrics_bucket_index . 1)
;; (name . "personal")
;; (profile_highlight_color . -13945027)
;; (signin.with_credential_provider . #f)
;; (user_name . "jackmac79@gmail.com")

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
