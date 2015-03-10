#lang racket
; implements a synchronization montior
(provide 
  ; initialize the monitor (make-monitor (public p1 p2 ...) (define (p1) ...) (define (p2 arg1) ...) ...)
  make-monitor 
  ; call method in monitor synchronously (monitor-call monitor-name procedure-name [arg1 ...])
  monitor-call)
(define-syntax make-monitor
  (syntax-rules ()
    ((_ body ...)
     (new (class monitor% body ... (super-new))))))

(define-syntax monitor-call
  (syntax-rules ()
    ((_ mon proc ...)
     (begin 
       (send mon monitor%-p)
       (send mon proc ...)
       (send mon monitor%-v)))))

(define monitor%
  (class object%
    (public monitor%-call monitor%-p monitor%-v)
    (define monitor%-guard (make-semaphore 1))
    (define monitor%-call 
      (λ (f ...)
        (semaphore-wait monitor%-guard)
        (f ...)
        (semaphore-post monitor%-guard)))
    (define monitor%-p
      (λ () (semaphore-wait monitor%-guard)))
    (define monitor%-v
      (λ () (semaphore-post monitor%-guard)))
    
    (super-new)))
