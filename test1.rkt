#lang racket
; runs fine
(require "monitor.rkt")
(define test-mon
  (make-monitor (public test)
                (define n 0)
                (define test
                  (λ (idx)
                     (set! n (add1 n))
                     (display (~a idx" connected"))
                     (let loop ([j 5])
                       (sleep 0.5) (display ".")
                       (unless (zero? j) (loop (sub1 j))))
                     (display (~a ""n"th thread to connect.\n"))))))

(let loop ([n 5])
  (thread (λ () (let t-loop () 
                     (sleep 0.5) 
                     (monitor-call test-mon test n)
                     (t-loop))))
  (unless (zero? n) (loop (sub1 n))))
