Implementation of [monitors](https://en.wikipedia.org/wiki/Monitor_%28synchronization%29) in racket. Monitors are signal and continue.
Example usage:

    (define my_monitor%
        (class monitor%
            (public p1 p2)
            (define cv1 (make-cv))
            (define cv2 (make-cv))
            (define (p1)
                (display "hello")
                (if (cv-empty? cv1) (cv-wait cv2) (cv-signal cv1)))
            (define (p2)
                (cv-signal cv2)
                (cv-wait cv1)
                (display "world"))
            (super-new)))
    
    (define m (new my_monitor%))
    
    (monitor-call m p1)

A timer that delays callers by however many seconds:

    (define timer%
        (class monitor%
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
                (cv-signal-all check))

            (super-new)))
    (define timer (new timer%))

    (define clock (thread
                (lambda ()
                    (let loop ()
                        (sleep 1)
                        (monitor-call timer tick)
                        (loop)))))

    (monitor-call timer delay 5)

TODO:
 - [ ] monitor%
 - [ ] \(monitor-call monitor procedure)
 - [ ] \(make-cv)
 - [ ] \(cv-empty?)
 - [ ] \(cv-wait cv)
 - [ ] \(cv-wait cv rank) ?
 - [ ] \(cv-signal cv)
 - [ ] \(cv-signal-all cv)
 - [ ] \(cv-minrank cv) ?
