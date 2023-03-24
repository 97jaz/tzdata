#lang info

;; `tzdata-zoneinfo-dir` is for backward compatibility with
;; older versions of tzinfo. It can be removed in future
;; versions.
(define iana-tz-version "2023b")
(define tzdata-zoneinfo-dir "tzdata/zoneinfo")
(define tzdata-zoneinfo-module-path (quote (lib "tzinfo/tzdata/zoneinfo")))
(define copy-shared-files (quote ("tzdata")))
