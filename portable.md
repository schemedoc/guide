# Scheme standards

Discussion R5RS, R6RS, R7RS, which one to target in what circumstances, and what kinds of problems to expect with each one.

Mention IEEE Scheme in passing, since people who are interested in standards may wonder about it.

# SRFIs by popularity, which are the usual ones for common tasks

# How to choose an implementation

## If you need to embed Scheme in a lower-level language

If you need to embed Scheme in a C/C++/Rust/Go application, natural choices are...

## If you need a Scheme for one of the big VM platforms

JVM, .NET CLR, JavaScript, WebAssembly/Asm.js

## If you need a Scheme for fast native applications

If you need fast native code, your options are pretty much... You will be limited to the these computer architectures: Intel; ARM/PPC?

All Schemes have a fast startup time, or do they?

## If you need a Scheme for a niche application

Embedded systems

Scheme in Common Lisp, Ocaml, ...

## How many libraries are available for each Scheme

## How big the community is for each Scheme? Oriented to beginners/experts?

# Common portability pitfalls

## Text vs raw bytes; character encodings

## Terminals, ANSI color, resize events, etc.

## File system / OS interface

## GUI libraries