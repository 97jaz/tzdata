#lang racket/base

(require racket/runtime-path
         (for-syntax racket/base))
(provide tzdata-zoneinfo-dir)

(define-runtime-path tzdata-zoneinfo-dir (build-path "private" "data"))
