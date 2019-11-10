#lang racket/base

(require racket/runtime-path
         racket/file
         racket/system
         net/ftp
         file/gunzip
         file/untar)

(define FILENAMES '("tzcode-latest.tar.gz"
                    "tzdata-latest.tar.gz"))

(define-runtime-path pkg-base-path ".")
(define build-dir (build-path pkg-base-path "build"))
(define src-dir (build-path build-dir "tzinstall" "usr" "share" "zoneinfo"))
(define install-dir (build-path pkg-base-path "tzinfo" "tzdata" "zoneinfo"))
(define info-file (build-path pkg-base-path "tzinfo" "info.rkt"))

(define (clean)
  (delete-directory/files build-dir #:must-exist? #f))

(define (make-build-dir)
  (make-directory build-dir))

(define (download)
  (define con (ftp-establish-connection "ftp.iana.org" 21 "anonymous" ""))
  (ftp-cd con "tz")
  (for ([name (in-list FILENAMES)])
    (ftp-download-file con build-dir name))
  (ftp-close-connection con))

(define (unarchive)
  (for ([name (in-list FILENAMES)])
    (with-input-from-file (build-path build-dir name)
      (λ ()
        (define-values (in out) (make-pipe))
        (gunzip-through-ports (current-input-port) out)
        (untar in #:dest build-dir)))))

(define (make)
  (parameterize ([current-directory build-dir])
    (or (system "make TOPDIR=tzinstall install")
        (raise "build failed"))))

;; requires the unarchive step to have been executed
(define (version)
  (regexp-replace #rx"\n"
                  (file->string (build-path build-dir "version"))
                  ""))

(define (install-data)
  (delete-directory/files install-dir #:must-exist? #f)
  (copy-directory/files src-dir install-dir))

(define (manifest)
  (map path->string
       (parameterize ([current-directory install-dir])
         (for/list ([f (in-directory)])
           f))))

(define (install-info)
  (with-output-to-file info-file #:exists 'replace
    (λ ()
      (displayln "#lang info")
      (newline)
      (display
       (string-append ";; `tzdata-zoneinfo-dir` is for backward compatibility with\n"
                      ";; older versions of tzinfo. It can be removed in future\n"
                      ";; versions.\n"))
      (writeln `(define iana-tz-version ,(version)))
      (writeln `(define tzdata-zoneinfo-dir "tzdata/zoneinfo"))
      (writeln `(define tzdata-zoneinfo-module-path '(lib "tzinfo/tzdata/zoneinfo"))))))

(define (run)
  (clean)
  (make-build-dir)
  (download)
  (unarchive)
  (make)
  (install-data)
  (install-info)
  (clean))
