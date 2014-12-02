This test module is part of matlab2tikz.

It provides the means for easily comparing the results of a native PDF print of
a figure in MATLAB as opposed to having it exported by matlab2tikz.

USAGE
=====
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