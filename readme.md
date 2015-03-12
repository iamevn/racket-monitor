Implementation of [monitors](https://en.wikipedia.org/wiki/Monitor_%28synchronization%29) in racket. Monitors are signal and continue.
Example usage:

    (define test-mon (make-monitor (public test)
                        (define n 0)
                        (define test
                            (λ (idx)
                                (set! n (add1 n))
                                (display (~a idx" connected"))
                                (let loop ([j 5])
                                    (sleep 0.5) (display ".")
                                    (unless (zero? j) (loop (sub1 j))))
                            (display (~a n"th thread to connect.\n"))))))

    (let loop ([n 5])
        (thread (λ () (let t-loop ()
                        (sleep 0.5)
                        (monitor-call test-mon test n)
                        (t-loop))))
        (unless (zero? n) (loop (sub1 n))))

A timer that delays callers by however many seconds:

    (define timer (make-monitor
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
                      (when (>= tod min) (cv-signal-all check)))))
    
    (define clock
      (thread
        (lambda ()
          (let loop ()
            (sleep 1)
            (monitor-call timer tick)
            (loop)))))
    
    (display "see you in 5 seconds...")
    (monitor-call timer delay 5)
    (display "hello!")

TODO:
 - [x] ~~monitor%~~
 - [x] \(monitor-call monitor procedure)
 - [x] \(make-monitor monitor body)
 - [ ] \(make-cv)
 - [ ] \(cv-empty? cv)
 - [ ] \(cv-wait cv)
 - [ ] \(cv-signal cv)
 - [ ] \(cv-signal-all cv)
 - [ ] _\(cv-wait cv rank)_
 - [ ] _\(cv-minrank cv)_
 Initial CV stuff is in place mostly as a test to see if I can get things to make sense scope-wise before I actually implement the various CV queue operations.
