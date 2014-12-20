This test module is part of matlab2tikz.

Its use is mainly of interest to the matlab2tikz developers to assert that 
the produced output is good.

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
 - all required binaries available on your `PATH` (as in most Unices)

Automated Tests
===============

The automated tests run using [Travis-CI](https://travis-ci.org) and the latest
results can be viewed at.
The script used is `runtests` that is interpreted using Octave (since MATLAB
requires a license). The basic principle is to iterate through the test suite.
For each test that has an associated MD5 hash of their TikZ output, this hash
is compared against the output generated.

Caveats
-------

 * Only Octave is tested, so MATLAB output has to be verified manually.
 * The MD5 hash is extremely brittle to small details in the output: e.g.
   extra whitespace or some other characters will change this.
 * This automated test does NOT test whether the output is desirable or not.
   It only checks whether the previous output is not altered! 
 * Hence, when structural changes are made, the reference hash should be changed.
   This SHOULD be motivated in the pull request (e.g. with a picture)!

Dependencies
------------

All dependencies should be taken care of using the standard Travis mechanisms, 
i.e. the `.travis.yml` file in the root of the repository. Run-time requirements
can be loaded explicitly in the `runtests` Octave file.
