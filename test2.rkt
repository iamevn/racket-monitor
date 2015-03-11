#lang racket
#| I don't think I know how macros work exactly. This runs
   if you explicitly (inherit make-cv cv-wait) inside the
   monitor definition but the make-monitor macro which should
   be inheriting these methods, does not actually inherit them |#
(require "monitor.rkt")

(define timer
  (make-monitor
   (inherit make-cv cv-empty? cv-wait cv-signal cv-signal-all) ;why is this necessary? make-monitor should take care of this???
   
   (public delay tick)
   
   (define check (make-cv))
   (define tod 0)
   
   (define (delay interval)
     (let loop ([wake_time (+ tod interval)])
       (when (> wake_time tod)
         (cv-wait check)
         (loop wake_time))))
   
   (define (tick)
     (set! tod (add1 tod))
     (cv-signal-all check))))

(define clock (thread
               (lambda ()
                 (let loop ()
                   (sleep 1)
                   (monitor-call timer tick)
                   (loop)))))

(display "see you in 5 seconds...")
(monitor-call timer delay 5)
(display "hello!")
