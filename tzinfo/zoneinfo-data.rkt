#lang racket/base

(require racket/runtime-path
         tzinfo/zoneinfo)

(define ZONEINFO-DATA #t)

(provide ZONEINFO-DATA)

(define-runtime-path data-dir "private/data")

(current-zoneinfo-search-path (list data-dir))
