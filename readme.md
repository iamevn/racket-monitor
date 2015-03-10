Implementation of [monitors](https://en.wikipedia.org/wiki/Monitor_%28synchronization%29) in racket. Monitors are signal and continue.
Example usage:

    (define m (make-monitor
                (public p1 p2)
                (define cv1 (make-cv))
                (define cv2 (make-cv))
                (define (p1)
                  (display "hello")
                  (if (cv-empty? cv1) (cv-wait cv2) (cv-signal cv1)))
                (define (p2)
                  (cv-signal cv2)
                  (cv-wait cv1)
                  (display "world"))))
    
    (thread (lambda ()
              (let loop ()
                (monitor-call m p1))))
    
    (thread (lambda ()
              (let loop ()
                (monitor-call m p2))))

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
