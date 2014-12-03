[![Build Status](https://travis-ci.org/matlab2tikz/matlab2tikz.svg?branch=master)](https://travis-ci.org/matlab2tikz/matlab2tikz)
![matlab2tikz](https://raw.githubusercontent.com/wiki/matlab2tikz/matlab2tikz/matlab2tikz.png)

`matlab2tikz` is a MATLAB(R) script to convert native MATLAB(R) figures to TikZ/Pgfplots figures that integrate seamlessly in LaTeX documents.

To download the official releases and rate `matlab2tikz`, please visit its page on [FileExchange](http://www.mathworks.com/matlabcentral/fileexchange/22022).

`matlab2tikz` converts most MATLAB(R) figures, including 2D and 3D plots. 
For plots constructed with third-party packages, however, your mileage may vary.

Installation
============

Place the `matlab2tikz` functions (contents of `src/` folder) somewhere where MATLAB(R) can find them: either your working directory or add `src/` to the path using `addpath`.

Make sure that your LaTeX installation is up-to-date and includes:

* [TikZ/PGF](http://www.ctan.org/pkg/pgf) version 3.0 or higher
* [Pgfplots](http://www.ctan.org/pkg/pgfplots) version 1.11 or higher
* [Standalone](http://www.ctan.org/pkg/standalone) (optional)

It is recommended to use the latest stable version of these packages.
Older versions may work depending on the actual MATLAB(R) figure you are converting.

Usage
=====

Typical usage of `matlab2tikz` consists of converting your MATLAB plot to a TikZ/LaTeX file and then running a LaTeX compiler to produce your document.

MATLAB
------
  1. Generate your plot in MATLAB(R).

  2. Run `matlab2tikz`, e.g. using

```matlab
matlab2tikz('myfile.tex');
```

LaTeX
-----
Add the contents of `myfile.tex` into your LaTeX source code, for example using `\input{myfile.tex}`. 
Make sure that the required packages (such as `pgfplots`) are loaded in the preamble of your document as in the example:

```latex
\documentclass{article}

  \usepackage{pgfplots}
  \pgfplotsset{compat=newest}
  %% the following commands are sometimes needed
  \usetikzlibrary{plotmarks}
  \usepackage{grffile}
  \usepackage{amsmath}
  %% you may also want the following commands
  %\pgfplotsset{plot coordinates/math parser=false}
  %\newlength\figureheight
  %\newlength\figurewidth

\begin{document}
  \input{myfile.tex}
\end{document}
```

Remarks
-------
Most functions accept numerous options; you can check them out by inspecting their help:

```matlab
help matlab2tikz
```

Sometimes, MATLAB(R) plots contain some features that impede conversion to LaTeX; e.g. points that are far outside of the actual bounding box.
You can invoke the `cleanfigure` function to remove such unwanted entities before calling `matlab2tikz`:

```matlab
cleanfigure;
matlab2tikz('myfile.tex');
```

More information
================

* For more information about `matlab2tikz`, have a look at our [GitHub repository](https://github.com/matlab2tikz/matlab2tikz). If you are a good MATLAB(R) programmer or LaTeX writer, you are always welcome to help improving `matlab2tikz`!
* Some common problems and pit-falls are documented in our [wiki](https://github.com/matlab2tikz/matlab2tikz/wiki/Common-problems).
* If you experience (other) bugs or would like to request a feature, please visit our [issue tracker](https://github.com/matlab2tikz/matlab2tikz/issues). 
