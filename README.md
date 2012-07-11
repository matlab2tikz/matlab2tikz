This is matlab2tikz, a MATLAB(R) script for converting MATLAB(R) figures into native
TikZ/Pgfplots figures.

To download and rate matlab2tikz, go to its page on MathWorks 
http://www.mathworks.com/matlabcentral/fileexchange/22022.

matlab2tikz supports the conversion of most MATLAB figures,
including 2D and 3D plots. For plots constructed with third-
party packages, your mileage may vary.

The workflow is as follows.

0. a. Place the matlab2tikz scripts (contents of src/ folder) in a directory where 
         MATLAB can find it (the current directory, for example).
   b. Make sure that your LaTeX installation includes the packages
     * TikZ (aka PGF, >=2.00) and
     * Pgfplots (>=1.3).

1. Generate your plot in MATLAB.

2. Invoke matlab2tikz by
```matlab
>> matlab2tikz();
```
   or
```matlab
>> matlab2tikz( 'myfile.tex' );
```
  The script accepts numerous options; check them out by invoking the help,
```matlab
>> help matlab2tikz
```
  for example 'height', 'width', 'encoding', and some more. Invoke by
```matlab
>> matlab2tikz( 'myfile.tex', 'height', '4cm', 'width', '3in' );
```
  To specify the dimension of the plot from within the LaTeX document, try
```matlab
>> matlab2tikz( 'myfile.tex', 'height', '\figureheight', 'width', '\figurewidth' );
```

3. Add the contents of `myfile.tex` into your LaTeX source code; a
   convenient way of doing so is to use `\input{/path/to/myfile.tex}`.
   Also make sure that at the header of your document the Pgfplots package
   is included:
```latex
\documentclass{article}
\usepackage{pgfplots}
% and optionally (as of Pgfplots 1.3):
\pgfplotsset{compat=newest}
\pgfplotsset{plot coordinates/math parser=false}
\newlength\figureheight
\newlength\figurewidth
\begin{document}
% Setting the figure dimensions is optional (see above).
\setlength\figureheight{4cm}
\setlength\figurewidth{6cm}
\input{myfile.tex}
\end{document}
```

There are reported incompatibilties with the follwing LaTeX packages:
   * signalflowdiagram <http://www.texample.net/tikz/examples/signal-flow-building-blocks/>
     (Check out <http://sourceforge.net/tracker/?func=detail&aid=3312653&group_id=224188&atid=1060656>.)

If you experience bugs, have nice examples of what matlab2tikz can do, or if
you are just looking for more information, please visit the web page of
matlab2tikz <https://github.com/nschloe/matlab2tikz>.
