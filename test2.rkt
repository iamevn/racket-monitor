; doesn't run yet
(define timer%
  (class monitor%
         (public delay tick)

         (define check (make-cv))
         (define tod 0)
         (define min +inf.0)

         (define (delay interval)
           (set! min (min min (+ tod interval)))
           (let loop ([wake_time (+ tod interval)])
             (when (> wake_time tod)
               (cv-wait check)
               (loop wake_time))))

         (define (tick)
           (set! tod (add1 tod))
           (when (>= tod min) (cv-signal-all check)))

         (super-new)))
(define timer (new timer%))

(define clock (thread
                (lambda ()
                  (let loop ()
                    (sleep 1)
                    (monitor-call timer tick)
                    (loop)))))

(display "see you in 5 seconds...")
(monitor-call timer delay 5)
(display "hello!")
