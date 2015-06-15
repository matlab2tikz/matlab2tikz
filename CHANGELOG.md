# 2015-06-15 Version 1.0.0 [Egon Geerardyn](egon.geerardyn@gmail.com)

 * Added support for:
      - Annotations (except arrows) in R2014b (#534)
      - `Histogram` in R2014b (#525)
      - Filled contour plots in R2014b (#379, #500)
      - Contour plots with color maps in R2014b (#380, #500)
      - Axes background color and overlap (#6, #509, #510)
      - Horizontal/Vertical text alignment (#491)
 * Extra requirements:
      - Patch plots now require `\usepgfplotslibrary{patchplots}` (#386, #497)
 * Bug fixes:
      - Pgfplots 1.12 (`row sep=crcr`) in combination with `externalData==true` (#548)
      - Updater has been fixed (#502)
      - 3D plot sizing takes viewing angle into account (#560, #630, #631)
      - Alpha channel (transparency) in images (#561)
      - Colorbar labels in R2014b (#429, #488)
      - Scaling of color data at axes level (#486)
      - Text formatting (for `TeX` parser) is improved (#417)
      - Support for `|` character in labels (#587, #589)
      - Legends for `stairs` and `area` plots (#601, #602)
      - `cleanfigure()` removes points outside of the axes for `stairs` plots (#226, #533)
      - `cleanfigure()` removes points outside of the axes better (#392, #400, #547)
      - Support `>` and `<` in text (#522)
      - Better text positioning (#518)
      - Text boxes on 3D graphs (#528)
      - File closing is more robust (#496, #555)
      - TikZ picture output, i.e.`imageAsPng==false`, improved (#581, #596)
      - `standalone==true` sets the font and input encoding in LaTeX (#590)
      - Legend text alignment in Octave (#668)
      - Improved Octave legend if not all lines have an entry (#607, #619, #653)
      - Legend without a drawn box in R2014b+ (#652)
      - Misc. fixes: #426, #513, #520, #665
 * For developers:
      - The testing framework has been revamped (see also `test/README.md`)
      - A lot of the tests have been updated (#604, #614, #638, ...)
      - Cyclomatic complexity of the code has been reduced (#391)
      - Repository has been moved to [matlab2tikz/matlab2tikz](https://github.com/matlab2tikz/matlab2tikz)
      - Extra files have been pruned (#616)

# 2014-11-02 Version 0.6.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Annotation support in R2014a and earlier
 * New subplot positioning approach (by Klaus Broelemann) that uses absolute instead of relative positions.
 * Support stacked bar plots and others in the same axes (needs pgfplots 1.11).
 * Support legends with multiline entries.
 * Support for the alpha channel in PNG output.
 * Test framework updated and doesn't display figures by default.
 * Major code clean-up and code complexity checks.
 * Bug fixes:
     - Cycle paths only when needed (#317, #49, #404)
     - Don't use infinite xmin/max, etc. (#436)
     - Warn about the `noSize` parameter (#431)
     - Images aren't flipped anymore (#401)
     - No scientific notation in width/height (#396)
     - Axes with custom colors (#376)
     - Mesh plots are exported properly (#382)
     - Legend colors are handled better (#389)
     - Handle Z axis properties for quiver3 (#406)
     - Better text handling, e.g. degrees (#402)
     - Don't output absolute paths into TikZ by default
     - ...

# 2014-10-20 Version 0.5.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for MATLAB 2014b (with it's substantial graphics changes).
   All credit goes to Egon Geerardyn.
 * Bugfixes:
     - single bar width
     - invisible bar plots
     - surface options
     - patch plots and cycling
     - patches with literal colors

# 2014-03-07 Version 0.4.7 [Nico Schlömer](nico.schloemer@gmail.com)

 * Acid tests: Remove MATLAB-based `eps2pdf`.
 * Bugfixes:
     - multiple patches
     - log plot with nonzero baseline
     - marker options for scatter plots
     - table data formatting
     - several fixes for Octave

# 2014-02-07 Version 0.4.6 [Nico Schlömer](nico.schloemer@gmail.com)

 * Set `externalData` default to `false`.
 * Properly check for required Pgfplots version.
 * Marker scaling in scatter plots.

# 2014-02-02 Version 0.4.5 [Nico Schlömer](nico.schloemer@gmail.com)

 * Arrange data in tables.
 * Optionally define custom colors.
 * Allow for strict setting of font sizes.
 * Bugfixes:
     - tick labels for log plots
     - tick labels with commas

# 2014-01-02 Version 0.4.4 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for color maps with scatter plots.
 * Support for different-length up-down error bars.
 * Input options validation.
 * Bugfixes:
     - legends for both area and line plots
     - invisible text fields

# 2013-10-20 Version 0.4.3 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for 3D quiver plots.
 * Extended support for colorbar axis options.
 * New logo!
 * Bugfixes:
     - text generation
     - extraCode option
     - join strings
     - ...

# 2013-09-12 Version 0.4.2 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for explicit color specification in 3D plots.
 * Better color handling for patch plots.
 * Support for various unicode characters.
 * Bugfixes:
     - edge colors for bar plots
     - multiple color bars
     - ...

# 2013-08-14 Version 0.4.1 [Nico Schlömer](nico.schloemer@gmail.com)

 * Replaced option `extraTikzpictureCode` by `extraCode`
   for inserting code at the beginning of the file.
 * Support for relative text positioning.
 * Improved documentation.
 * Code cleanup: moved all figure manipulations over to cleanfigure()
 * Bugfixes:
     - error bars
     - empty tick labels
     - ...

# 2013-06-26 Version 0.4.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Added `cleanfigure()` for removing unwanted entities from a plot
   before conversion
 * Add option `floatFormat` to allow for custom specification of the format
   of float numbers
 * Bugfixes:
     - linewidth for patches
     - ...

# 2013-04-13 Version 0.3.3 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for:
     - pictures in LaTeX subfloats
 * Bugfixes:
     - axes labels
     - extra* options
     - logscaled axes
     - ...

# 2013-03-14 Version 0.3.2 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for:
     - waterfall plots
 * Bugfixes:
     - axis locations
     - color handling
     - stacked bars
     - ...

# 2013-02-15 Version 0.3.1 [Nico Schlömer](nico.schloemer@gmail.com)

 * Use `table{}` for plots for cleaner output files.
 * Support for:
     - hg transformations
     - pcolor plots
 * Removed command line options:
     - `minimumPointsDistance`
 * Bugfixes:
     - legend positioning and alignment
     - tick labels
     - a bunch of fixed for Octave
     - line width for markers
     - axis labels for color bars
     - image trimming
     - subplots with bars
     - ...

# 2012-11-19 Version 0.3.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for:
     - area plots
     - legend position
     - inner color bars
     - log-scaled color bars
 * New command line options:
     - `standalone` (create compilable TeX file)
     - `checkForUpdates`
 * `mlint` cleanups.
 * Removed deprecated options.
 * Bugfixes:
     - colorbar-axis association
     - option parsing
     - automatic updater
     - unit 'px'
     - ...

# 2012-09-01 Version 0.2.3 [Nico Schlömer](nico.schloemer@gmail.com)

 * Multiline text for all entities.
 * Support for logical images.
 * Support for multiple legends (legends in subplots).
 * Fixed version check bug.
 * Fix `minimumPointsDistance`.

# 2012-07-19 Version 0.2.2 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for multiline titles and axis labels.
 * Respect log-scaled axes for `minimumPointsDistance`.
 * Add support for automatic graph labels via new option.
 * About 5 bugfixes.

# 2012-05-04 Version 0.2.1 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for color maps.
 * Support for native color bars.
 * Partial support for hist3 plots.
 * Support for spectrogram plots.
 * Support for rotated text.
 * Native handling of `Inf`s and `NaN`s.
 * Better info text.
 * matlab2tikz version checking.
 * Line plotting code cleanup.
 * About 10 bugfixes.

# 2012-03-17 Version 0.2.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Greatly overhauled text handling. (Burkhart Lingner)
 * Added option `tikzFileComment`.
 * Added option `parseStrings`.
 * Added option `extraTikzpictureSettings`.
 * Added proper documetion (for `help matlab2tikz`).
 * Improved legend positioning, orientation.
 * Support for horizontal bar plots.
 * Get bar widths right.
 * Doubles are plottet with 15-digit precision now.
 * Support for rectangle objects.
 * Better color handling.
 * Testing framework improvements.
 * Several bugfixes:
     - ticks handled more concisely
     - line splitting bugs
     - ...

# 2011-11-22 Version 0.1.4 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for scatter 3D plots.
 * Support for 3D parameter curves.
 * Support for 3D patches.
 * Support for minor ticks.
 * Add option `interpretTickLabelsAsTex` (default `false`).
 * Several bugfixes:
     - `%` sign in annotations
     - fixed `\omega` and friends in annotations
     - proper legend for bar plots
     - don't override PNG files if there is more than one image plot
     - don't always close patch paths

# 2011-08-22 Version 0.1.3 [Nico Schlömer](nico.schloemer@gmail.com)

 * Greatly overhauled text handling.
 * Better Octave compatibility.
 * Several bugfixes:
     - subplot order
     - environment detection


# 2011-06-02 Version 0.1.2 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for logscaled color bar.
 * Support for truecolor images.
 * Initial support for text handles.
 * Speed up processing for line plots.
 * Several bugfixes:
     - axis labels, tick labels, etc. for z-axis
     - marker handling for scatter plots
     - fix for unicolor scatter plots

# 2011-04-06 Version 0.1.1 [Nico Schlömer](nico.schloemer@gmail.com)

 * Improved Octave compatibility.
 * Several bugfixes:
     - input parser

# 2011-01-31 Version 0.1.0 [Nico Schlömer](nico.schloemer@gmail.com)

 * Basic Octave compatibility.
 * Several bugfixes:
     - bar plots fix (thanks to Christoph Rüdiger)
     - fix legends with split graphs

# 2010-09-10 Version 0.0.7 [Nico Schlömer](nico.schloemer@gmail.com)

 * Compatibility fixes for older MATLAB installations.
 * Several bugfixes:
     - line plots with only one point
     - certain surface plots
     - orientation of triangle markers (`<` vs. `>`)
     - display of the color `purple`

# 2010-05-06 Version 0.0.6 [Nico Schlömer](nico.schloemer@gmail.com)

 * Support for scatter plots.
 * Preliminary support for surface plots; thanks to Pooya.
 * Large changes in the codebase:
     - next to `matlab2tikz.m`, the file `pgfplotsEnvironment.m` is now needed as well; it provides a much better structured approach to storing and writing environments when parsing the MATLAB(R) figure
 * proper MATLAB(R) version check
 * lots of small fixes

# 2009-12-21 Version 0.0.5 [Nico Schlömer](nico.schloemer@ua.ac.be)

 * Improvements in axis handling:
     - colored axes
     - allow different left and right ordinates
 * Improvements for line plots:
     - far outliers are moved toward the plot,
     avoiding `Dimension too large`-type errors in LaTeX
     - optional point reduction by new option `minimumPointsDistance`
 * Improvements for image handling:
     - creation of a PNG file, added by `\addplot graphics`
     - fixed axis orientation bug
 * Bugfixes for:
     - multiple axes
     - CMYK colors
     - legend text alignment (thanks Dragan Mitrevski)
     - transparent patches (thanks Carlos Russo)
 * Added support for:
     - background color
     - Bode plots
     - zplane plots
     - freqz plots

# 2009-06-09 Version 0.0.4 [Nico Schlömer](nico.schloemer@ua.ac.be)

 * Added support for:
     - error bars (thanks Robert Whittlesey for the suggestion)
 * Improvents in:
     - legends (thanks Theo Markettos for the patch),
     - images,
     - quiver plots (thanks Robert for spotting this).
 * Improved options handling.
 * Allow for custom file encoding (thanks Donghua Wang for the suggestion).
 * Numerous bugfixes (thanks Andreas Gäb).

# 2009-03-08 Version 0.0.3 [Nico Schlömer](nico.schloemer@ua.ac.be)

 * Added support for:
     - subplots
     - reverse axes
 * Completed support for:
     - images

# 2009-01-08 Version 0.0.2 [Nico Schlömer](nico.schloemer@ua.ac.be)

 * Added support for:
     - quiver (arrow) plots
     - bar plots
     - stem plots
     - stairs plots
 * Added preliminary support for:
     - images
     - rose plots
     - compass plots
     - polar plots
 * Moreover, large code improvement have been introduced, notably:
     - aspect ratio handling
     - color handling
     - plot options handling

# 2008-11-07 Version 0.0.1 [Nico Schlömer](nico.schloemer@ua.ac.be)

 * Initial version
