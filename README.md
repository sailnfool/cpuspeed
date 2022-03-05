# sysperf
An alternative to bogomips  By running a set of iterations of various cryptographic hashes against the default dictionary
the results can be compared to the bogomips for the systems tested.  The process of testing a computer system is much more
complex than just getting a measurement of CPU perormance.  This set of scripts were motivated by the fact that the
Linux Foundation in their "ready-for" scripts were using bogomips as a proxy for system performance.

1) Bogomips was never intended to be used this way.
2) Bogomips does NOT measure system performance, only the speed of a small timing loop.
3) Bogomips is broken with respect to CPUs that use variable clock rates

This is an attempt to create a proxy for system performance.  In the process of creating this I explored some alternative
ways of performing the metric.  The default dictionary is ~ 1 MB  (976,241 bytes) in size.  When you run 10,000 to 15,000 iterations over
the dictionary using either a cryptographic hash program (bssum, sha1sum, sha256sum, sha512sum) or the dd application it
becomes easy to see that the time spent loading the applications into memory will quickly dominate and have a skewing 
effect on the results.

By making 512 copies of the dictionary, the size is now 499,835,392 or just under 1/2 GB.  Using this larger file improved
the performance of all of the applications
