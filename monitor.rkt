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
     (new (class monitor% 
            (inherit make-cv cv-empty? cv-wait cv-signal cv-signal-all)
            body ...
            (super-new))))))

(define-syntax monitor-call
  (syntax-rules ()
    ((_ mon proc ...)
     (begin 
       (send mon monitor%-lock)
       (send mon proc ...)
       (send mon monitor%-unlock)))))

(define monitor%
  (class object%
    (public monitor%-call monitor%-lock monitor%-unlock
            make-cv cv-empty? cv-wait cv-signal cv-signal-all)
    
    (define monitor%-guard (make-semaphore 1))
    
    (define monitor%-call 
      (λ (f ...)
        (semaphore-wait monitor%-guard)
        (f ...)
        (semaphore-post monitor%-guard)))
    
    (define monitor%-lock
      (λ () (semaphore-wait monitor%-guard)))
    
    (define monitor%-unlock
      (λ () (semaphore-post monitor%-guard)))
    
    (define make-cv
      (λ () (vector (make-semaphore) 0)))
    
    (define cv-empty?
      (λ (cv) (zero? (vector-ref cv 1))))
    
    (define cv-wait
      (λ (cv) (vector-set! cv 1 (add1 (vector-ref cv 1)))
        (monitor%-unlock)
        (semaphore-wait (vector-ref cv 0))
        (vector-set! cv 1 (sub1 (vector-ref cv 1)))
        (monitor%-lock)))
    
    (define cv-signal
      (λ (cv) (unless (cv-empty? cv) (semaphore-post (vector-ref cv 0)))))
    
    (define cv-signal-all
      (λ (cv) (let loop ([i (vector-ref cv 1)])
                (unless (zero? i)
                  (semaphore-post (vector-ref cv 0))
                  (loop (sub1 i))))))
    
    (super-new)))