#lang racket/base

(require (prefix-in gui: mrlib/snip-canvas)
         racket/class
         racket/match
         "../observable.rkt"
         "common.rkt"
         "view.rkt")

(provide
 snip)

(define snip%
  (class* object% (view<%>)
    (init-field @data @label @enabled? @margin @min-size @stretch style make-snip update-snip)
    (super-new)

    (define/public (dependencies)
      (filter obs? (list @data @label @enabled? @margin @min-size @stretch)))

    (define snip #f)
    (define/public (create parent)
      (match-define (list h-m v-m) (peek @margin))
      (match-define (list min-w min-h) (peek @min-size))
      (match-define (list w-s? h-s?) (peek @stretch))
      (new gui:snip-canvas%
           [parent parent]
           [make-snip (let ([data (peek @data)])
                        (λ (w h)
                          (set! snip (make-snip data w h))
                          snip))]
           [label (peek @label)]
           [style style]
           [enabled (peek @enabled?)]
           [horiz-margin h-m]
           [vert-margin v-m]
           [min-width min-w]
           [min-height min-h]
           [stretchable-width w-s?]
           [stretchable-height h-s?]))

    (define/public (update v what val)
      (case/dep what
        [@data (when snip (update-snip snip val))]
        [@label (send v set-label val)]
        [@enabled? (send v enable val)]
        [@margin
         (match-define (list h v) val)
         (send* v
           (horiz-margin h)
           (vert-margin v))]
        [@min-size
         (match-define (list w h) val)
         (send* v
           (min-width w)
           (min-height h))]
        [@stretch
         (match-define (list w-s? h-s?) val)
         (send* v
           (stretchable-width w-s?)
           (stretchable-height h-s?))]))

    (define/public (destroy _v)
      (void))))

(define (snip @data make-snip
              [update-snip void]
              #:label [@label #f]
              #:style [style '(no-border)]
              #:enabled? [@enabled? #t]
              #:margin [@margin '(0 0)]
              #:min-size [@min-size '(#f #f)]
              #:stretch [@stretch '(#t #t)])
  (new snip%
       [@data @data]
       [@label @label]
       [@enabled? @enabled?]
       [@margin @margin]
       [@min-size @min-size]
       [@stretch @stretch]
       [make-snip make-snip]
       [update-snip update-snip]
       [style style]))