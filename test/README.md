This test module is part of matlab2tikz.

It provides the

Manual Tests
============

The manual tests allow easy comparison of a native PDF `print` output and the
output produced by `matlab2tikz`. For the large amount of cases, however,
this comparison has become somewhat unwieldly.
For a good impression of the results, this test suite should be run in as 
many different environments as possible: Octave, MATLAB 2014a or older, and,
MATLAB 2014b or newer.

  1. Open MATLAB or Octave
  2. Make sure `matlab2tikz`, `testMatlab2tikz` are on your path, e.g. with
       
        addpath(pwd);                       % for the test harness
        addpath(fullfile(pwd,'..','src'));  % for matlab2tikz
        addpath(fullfile(pwd,'suites'));    % for the test suites

  3. Call the test functions

        testMatlab2tikz( 'testsuite', @ACID );

     What happens is that MATLAB generates a number of figures as defined in
     `testsuites/ACID.m`, and exports them to PDF/EPS using the `print` command
     and using `matlab2tikz`. Both are displayed side-by-side in a LaTeX file.

  4. You can compile `tex/acid.tex` with 'make' (making use of 'tex/Makefile').

If all goes well, the result will be the file `tex/acid.pdf` which contains a
list of the test figures, exported as PDF and right next to it the matlab2tikz
generated plot.

Dependencies
------------

 - all requirements of `matlab2tikz`
 - a recent LaTeX distribution with `LuaLaTeX`
 - `make`
 - [`pdftk` (Server)](https://www.pdflabs.com/tools/pdftk-server/)
 - all those executables available on your `PATH` (as in most Unices)

Automated Tests
===============

The automated tests run using [Travis-CI](https://travis-ci.org)