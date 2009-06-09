% =========================================================================
% *** FUNCTION matlab2tikz
% ***
% *** Convert figures to TikZ (using pgfplots) for inclusion in LaTeX
% *** documents.
% ***
% *** Workflow:
% ***    0.) Place this file in one of the MATLAB paths
% **         (for example the current directory).
% ***    1.) Create your 2D plot in MATLAB.
% ***    2.) Invoke matlab2tikz by
% ***
% ***        >> matlab2tikz( 'test.tikz' );
% ***
% ***
% *** -------
% ***  Note:
% *** -------
% ***    This program is a rewrite on Paul Wagenaars' Matlab2PGF which
% ***    itself uses pure PGF as output format <paul@wagenaars.org>, see
% ***
% ***       http://www.mathworks.com/matlabcentral/fileexchange/12962
% ***
% ***    In an attempt to simplify and extend things, the idea for
% ***    matlab2tikz has emerged. The goal is to provide the user with a 
% ***    clean interface between the very handy figure creation in MATLAB
% ***    and the powerful means that TikZ with pgfplots has to offer.
% ***
% ***
% *** TODO: * tex(t) annotations
% ***       * 3D plots
% ***
% =========================================================================
% ***
% *** Copyright (c) 2008, 2009, Nico Schlömer <nico.schloemer@ua.ac.be>
% *** All rights reserved.
% ***
% *** Redistribution and use in source and binary forms, with or without 
% *** modification, are permitted provided that the following conditions are 
% *** met:
% ***
% ***    * Redistributions of source code must retain the above copyright 
% ***      notice, this list of conditions and the following disclaimer.
% ***    * Redistributions in binary form must reproduce the above copyright 
% ***      notice, this list of conditions and the following disclaimer in 
% ***      the documentation and/or other materials provided with the distribution
% ***
% *** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% *** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% *** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% *** ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% *** LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% *** CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% *** SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% *** INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% *** CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% *** ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% *** POSSIBILITY OF SUCH DAMAGE.
% ***
% =========================================================================
function matlab2tikz( varargin )

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define some global variables
  clear global matlab2tikzName;
  clear global matlab2tikzVersion;
  clear global tol;
  clear global matlab2tikzOpts;
  clear global currentHandles;

  global matlab2tikzOpts;

  global currentHandles;

  global matlab2tikzName;
  matlab2tikzName = 'matlab2tikz';

  global matlab2tikzVersion;
  matlab2tikzVersion = '0.0.4';

  global tikzOptions; % for the arrow style -- TODO: see if we can get this removed
  tikzOptions = cell(0);

  global tol;
  tol = 1e-15; % global round-off tolerance;
               % used, for example, in equality test for doubles
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % scan the options
  matlab2tikzOpts = inputParser;
  matlab2tikzOpts.addOptional( 'filename', ...
                               [], ...
                               @(x) filenameValidation(x,matlab2tikzOpts) );

  % possibility to give a file handle file as argument
  matlab2tikzOpts.addOptional( 'filehandle', [], @filehandleValidation );

  % whether to strictly stick to the default MATLAB plot appearance:
  matlab2tikzOpts.addOptional( 'strict', 0, @isnumeric );

  % width and height of the figure
  matlab2tikzOpts.addParamValue( 'height', [], @ischar );
  matlab2tikzOpts.addParamValue( 'width' , [], @ischar );

  % file encoding
  matlab2tikzOpts.addParamValue( 'encoding' , '', @ischar );

  matlab2tikzOpts.parse( varargin{:} );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % add extra elements
  currentHandles.gca      = gca;
  currentHandles.gcf      = gcf;
  currentHandles.colormap = colormap;

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle output file handle/file name
  if ~isempty( matlab2tikzOpts.Results.filehandle )
      fid     = matlab2tikzOpts.Results.filehandle;
      fileWasOpen = 1;
      if ~isempty(matlab2tikzOpts.Results.filename)
          warning( 'matlab2tikz:fileHandleFileNameConflict', ...
                   'File handle AND file name for output given. File handle used, file name discarded.')
      end
  else
      fileWasOpen = 0;
      % set filename
      if ~isempty(matlab2tikzOpts.Results.filename)
          filename = matlab2tikzOpts.Results.filename;
      else
          filename = uiputfile( {'*.tikz'; '*.*'}, ...
                                'Save File' );
      end
      % open the file for writing
      fid = fopen( filename, ...
                  'w', ...
                  'native', ... 
                  matlab2tikzOpts.Results.encoding ...
                );
      if fid == -1
          error( 'matlab2tikz:fileOpenError', ...
                 'Unable to open file ''%s'' for writing.', ...
                 filename );
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % print some version info to the screen
  sprintf( '%s v%s\n', matlab2tikzName, matlab2tikzVersion );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Save the figure as pgf to file -- here's where the work happens
  saveToFile( fid, fileWasOpen );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  sprintf( '\nRemember to load \\usepackage{tikz} and \\usepackage{pgfplots} in the preamble of your LaTeX document.\n\n' );

  % clean up
  clear global matlab2tikzName;
  clear global matlab2tikzVersion;
  clear global matlab2tikzOpts;
  clear global tol;
  clear global currentHandles;
  clear all;

  % -----------------------------------------------------------------------
  % validates the optional argument 'filename' to not be another
  % another keyword
  function l = filenameValidation( x, p )
    l = ischar(x) && ~any( strcmp(x,p.Parameters) );
  end
  % -----------------------------------------------------------------------

  % -----------------------------------------------------------------------
  % validates the optional argument 'filehandle' to be the handle of
  % an open file
  function l = filehandleValidation( x, p )
      l = isnumeric(x) && any( x==fopen('all') );
  end
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END OF FUNCTION matlab2tikz
% =========================================================================



% =========================================================================
% *** FUNCTION saveToFile
% ***
% *** Save the figure as TikZ to a file.
% *** All other routines are called from here.
% ***
% =========================================================================
function saveToFile( fid, fileWasOpen )

  global matlab2tikzName
  global matlab2tikzVersion
  global matlab2tikzOpts
  global currentHandles
  global tikzOptions

  global requiredRgbColors

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % enter plot recursion --
  % It is important to turn hidden handles on, as visible lines (such as the
  % axes in polar plots, for example), are otherwise hidden from their
  % parental handles (and can hence not be discovered by matlab2tikz).
  % With ShowHiddenHandles 'on', there is no escape. :)
  set( 0, 'ShowHiddenHandles', 'on' );

  % get all axes handles
  fh          = currentHandles.gcf;
  axesHandles = findobj( fh, 'type', 'axes' );

  % remove all legend handles as they are treated separately
  rmList = [];
  for k = 1:length(axesHandles)
     if strcmp( get(axesHandles(k),'Tag'), 'legend' )
        rmList = [ rmList, k ];
     end
  end
  axesHandles(rmList) = [];


  % Turn around the handles vector to make sure that plots that appeared
  % first also appear first in the vector. This has effects on the alignment
  % and the order in which the plots appear in the final TikZ file.
  % In fact, this is not really important but makes things more 'natural'.
  axesHandles = axesHandles(end:-1:1);

  % find alignments
  [alignmentOptions,ix] = alignSubPlots( axesHandles );

  str = [];
  for k = 1:length(axesHandles)
      str = [ str, drawAxes(axesHandles(ix(k)),alignmentOptions(ix(k))) ];
  end

  set( 0, 'ShowHiddenHandles', 'off' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % actually print the stuff
  fprintf( fid, '%% This file was created by %s v%s.\n\n',              ...
                                   matlab2tikzName, matlab2tikzVersion );

  if isempty(tikzOptions)
      fprintf( fid, '\\begin{tikzpicture}\n' );
  else
      fprintf( fid, '\\begin{tikzpicture}[%s]\n', collapse(tikzOptions,',') );
  end

  % don't forget to define the colors
  if size(requiredRgbColors,1)
      fprintf( fid, '\n%% defining custom colors\n' );
  end
  for k = 1:size(requiredRgbColors,1)
      fprintf( fid, '\\definecolor{mycolor%d}{rgb}{%g,%g,%g}\n', k,     ...
                                                    requiredRgbColors(k,:) );
  end

  % print the content
  fprintf( fid, '%s', str );

  fprintf( fid, '\\end{tikzpicture}');
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % close the file if necessary
  if ~fileWasOpen
      fclose( fid );
  end
end
% =========================================================================
% *** END OF FUNCTION saveToFile
% =========================================================================
 


% =========================================================================
% *** FUNCTION handleAllChildren
% ***
% *** Draw all children of a graphics object (if they need to be drawn).
% ***
% =========================================================================
function str = handleAllChildren( handle )

  str = [];

  children = get( handle, 'Children' );

  % It's important that we go from back to front here, as this is
  % how MATLAB does it, too. Significant for patch (contour) plots,
  % and the order of plotting the colored patches.
  for i = length(children):-1:1
      child = children(i);

      switch get( child, 'Type' )
          case 'axes'
              str = [ str, drawAxes( child ) ];

          case 'line'
              str = [ str, drawLine( child ) ];

          case 'patch'
              str = [ str, drawPatch( child ) ];

          case 'image'
              str = [ str, drawImage( child ) ];

          case 'hggroup'
              str = [ str, drawHggroup( child ) ];

          case { 'hgtransform' }
              % don't handle those directly but descend to its children
              % (which could for example be patch handles)
              str = [ str, handleAllChildren( child ) ];

          case { 'uitoolbar', 'uimenu', 'uicontextmenu', 'uitoggletool',...
                 'uitogglesplittool', 'uipushtool', 'hgjavacomponent',  ...
                 'text', 'surface' }
              % TODO: text, surface
              % TODO: bail out with warning in case of a 3D-plot (parameter plots!)
              % don't to anything for these handles and its children

          otherwise
              error( 'matfig2tikz:handleAllChildren',                 ...
                     'I don''t know how to handle this object: %s\n', ...
                                                       get(child,'Type') );

      end
  end

end
% =========================================================================
% *** END OF FUNCTION handleAllChildren
% =========================================================================



% =========================================================================
% *** FUNCTION drawAxes
% ***
% *** Input arguments:
% ***    handle.................The axes environment handle.
% ***    alignmentOptions.......The alignment options as defined in the
% ***                           function `alignSubPlots()`.
% ***                           This argument is optional.
% ***
% =========================================================================
function str = drawAxes( handle, alignmentOptions )

  global matlab2tikzOpts;

  % Make the axis options a global variable as plot objects further below
  % in the hierarchy might want to append something.
  % One example is the required 'ybar stacked' option for stacked bar
  % plots.
  global axisOpts;

  str = [];
  axisOpts = cell(0);

  if ~isVisible( handle )
      % An invisible axes container *can* have visible children, so don't
      % immediately bail out here.
      if ~isempty(get(handle,'Children'))
          env  = 'axis';
          dim = getAxesDimensions( handle );
          axisOpts = [ axisOpts, ...
                       'hide x axis, hide y axis', ...
                       sprintf('width=%g%s, height=%g%s', dim.x, dim.unit,   ...
                                                          dim.y, dim.unit ), ...
                       'scale only axis' ];
          str = plotAxisEnvironment( handle, env );
      end
      return
  end

  if strcmp( get(handle,'Tag'), 'Colorbar' )
      % handle a colorbar separately
      str = drawColorbar( handle, alignmentOptions );
      return
  end

  if strcmp( get(handle,'Tag'), 'legend' )
      % Don't handle the legend here, but further below in the 'axis'
      % environment.
      % In MATLAB, an axes environment and it's corresponding legend are
      % children of the same figure (siblings), while in pgfplots, the
      % \legend (or \addlegendentry) command must appear within the axis
      % environment.
      return
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get scales
  xScale = get( handle, 'XScale' );
  yScale = get( handle, 'YScale' );

  isXLog = strcmp( xScale, 'log' );
  isYLog = strcmp( yScale, 'log' );

  if  ~isXLog && ~isYLog
      env = 'axis';
  elseif isXLog && ~isYLog
      env = 'semilogxaxis';
  elseif ~isXLog && isYLog
      env = 'semilogyaxis';
  else
      env = 'loglogaxis';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % set alignment options
  if alignmentOptions.isRef
      axisOpts = [ axisOpts, sprintf('name=%s',alignmentOptions.name) ];
  end
  if ~isempty(alignmentOptions.opts)
      axisOpts = [ axisOpts, alignmentOptions.opts ];
  end

  % the following is general MATLAB behavior
  axisOpts = [ axisOpts, 'axis on top', 'scale only axis' ];

  xLim = get( handle, 'XLim' );
  yLim = get( handle, 'YLim' );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get the axes dimensions
  dim = getAxesDimensions( handle );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % until the advent of a proper 'reverse axis' option in pgfplots, use
  % the possibility to set the unit vectors in x- and y-direction
  xAxisOrientation = get( handle, 'XDir' );
  switch xAxisOrientation
      case 'normal'
          isXAxisRev = 0;
          if isempty( matlab2tikzOpts.Results.width )
              axisOpts = [ axisOpts,                                ...
                           sprintf( 'width=%g%s' , dim.x, dim.unit ) ];
          else
              axisOpts = [ axisOpts,             ...
                           sprintf( 'width=%s' , ...
                                    escapeCharacters(matlab2tikzOpts.Results.width) ) ];
          end
      case 'reverse'
          isXAxisRev = 1;
          xUnitSize = dim.x/ (xLim(2)-xLim(1));
          axisOpts = [ axisOpts,                                   ...
                       sprintf( 'x=-%g%s' , xUnitSize, dim.unit ), ...
                       'yticklabel pos=right',                     ...
                       'yticklabel style=left' ];
      otherwise
          error( 'drawAxes:unknOrient', ...
                 'Unknown axis orientation ''%s''.', xAxisOrientation );
  end

  yAxisOrientation = get( handle, 'YDir' );
  switch yAxisOrientation
      case 'normal'
          isYAxisRev = 0;
          if isempty( matlab2tikzOpts.Results.height )
              axisOpts = [ axisOpts,                                ...
                           sprintf( 'height=%g%s' , dim.y, dim.unit ) ];
          else
              axisOpts = [ axisOpts,             ...
                           sprintf( 'height=%s' , ...
                                    escapeCharacters(matlab2tikzOpts.Results.height) ) ];
          end
      case 'reverse'
          isYAxisRev = 1;
          yUnitSize = dim.y/ (yLim(2)-yLim(1));
          axisOpts = [ axisOpts,                                   ...
                       sprintf( 'y=-%g%s' , yUnitSize, dim.unit ), ...
                       'xticklabel pos=right',                     ...
                       'xticklabel style=below' ];
      otherwise
          error( 'drawAxes:unknOrient', ...
                 'Unknown axis orientation ''%s''.', yAxisOrientation );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis limits
  axisOpts = [ axisOpts,                           ...
               sprintf('xmin=%g, xmax=%g', xLim ), ...
               sprintf('ymin=%g, ymax=%g', yLim ) ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ ticks, tickLabels ] = getTicks( handle );
  if ~isempty( ticks.x )
      axisOpts = [ axisOpts,                              ...
                    sprintf( 'xtick={%s}', ticks.x ) ];
  end
  if ~isempty( tickLabels.x )
      axisOpts = [ axisOpts,                              ...
                    sprintf( 'xticklabels={%s}', tickLabels.x ) ];
  end
  if ~isempty( ticks.y )
      axisOpts = [ axisOpts,                              ...
                    sprintf( 'ytick={%s}', ticks.y ) ];
  end
  if ~isempty( tickLabels.y )
      axisOpts = [ axisOpts,                              ...
                    sprintf( 'yticklabels={%s}', tickLabels.y ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis labels
  axisLabels = getAxisLabels( handle );
  if ~isempty( axisLabels.x )
      axisOpts = [ axisOpts,                              ...
                          sprintf( 'xlabel={$%s$}',       ...
                                   escapeCharacters(axisLabels.x) ) ];
  end
  if ~isempty( axisLabels.y )
      axisOpts = [ axisOpts,                              ...
                   sprintf( 'ylabel={$%s$}',              ...
                             escapeCharacters(axisLabels.y) ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get title
  title = get( get( handle, 'Title' ), 'String' );
  if ~isempty(title)
      axisOpts = [ axisOpts,                              ...
                   sprintf( 'title={$%s$}', escapeCharacters(title) ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get grids
  isGrid = 0;
  if strcmp( get( handle, 'XGrid'), 'on' );
      axisOpts = [ axisOpts, 'xmajorgrids' ];
      isGrid = 1;
  end
  if strcmp( get( handle, 'XMinorGrid'), 'on' );
      axisOpts = [ axisOpts, 'xminorgrids' ];
      isGrid = 1;
  end
  if strcmp( get( handle, 'YGrid'), 'on' )
      axisOpts = [ axisOpts, 'ymajorgrids' ];
      isGrid = 1;
  end
  if strcmp( get( handle, 'YMinorGrid'), 'on' );
      axisOpts = [ axisOpts, 'yminorgrids' ];
      isGrid = 1;
  end

  % set the line style
  if isGrid
      matlabGridLineStyle = get( handle, 'GridLineStyle' );

      % take over the grid line style in any case when in strict mode;
      % if not, don't add anything in case of default line grid line style
      % and effectively take pgfplots' default
      defaultMatlabGridLineStyle = ':';
      if matlab2tikzOpts.Results.strict ...
         || ~strcmp(matlabGridLineStyle,defaultMatlabGridLineStyle)
         gls = translateLineStyle( matlabGridLineStyle );
         str = [ str, ...
                 sprintf( '\n\\pgfplotsset{every axis grid/.style={style=%s}}\n\n', gls ) ];
      end

  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % See if there are any legends that need to be plotted.
  c = get( get(handle,'Parent'), 'Children' ); % siblings of this handle
  
  % Since the legends are at the same level as axes in the hierarchy,
  % we can't work out which relates to which using the tree
  % so we have to do it by looking for a plot inside which the legend sits.
  % This could be done better with a heuristic of finding
  % the nearest legend to a plot, which would cope with legends outside
  % plot boundaries.

  % TODO: How to uniquely connect a legend with a pair of axes?
  
  axisDims = get(handle,'Position');
  axisLeft = axisDims(1);
  axisBot  = axisDims(2);
  axisWid  = axisDims(3);
  axisHei  = axisDims(4);
  legendHandle = 0;
  for k=1:size(c)
      if  strcmp( get(c(k),'Type'), 'axes'   ) && ...
          strcmp( get(c(k),'Tag' ), 'legend' )
          legendHandle = c(k);
          if (legendHandle)              
              legDims = get( legendHandle, 'Position' );
              legLeft = legDims(1);
              legBot  = legDims(2);
              legWid  = legDims(3);
              legHei  = legDims(4);
              if (    legLeft > axisLeft ...
                   && legBot > axisBot ...  
                   && legLeft+legWid < axisLeft+axisWid ...
                   && legBot+legHei  < axisBot+axisHei )
                  axisOpts = [ axisOpts, ...
                       getLegendOpts( legendHandle, isXAxisRev, isYAxisRev ) ];
              end
          end
      end
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % actually begin drawing
  str = [ str, ...
          plotAxisEnvironment( handle, env ) ];

  % -----------------------------------------------------------------------
  function str = plotAxisEnvironment( handle, env )

      str = [];

      % First, run through all the children to give them the chance to
      % contribute to 'axisOpts'.
      matfig2pgfOpt.CurrentAxesHandle = handle;
      childrenStr = handleAllChildren( handle );

      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % Format 'axisOpts' nicely.
      opts = [ '\n', collapse( axisOpts, ',\n' ), '\n' ];
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      % if a tag is given, use it as comment
      tag = get(handle, 'tag');
      if ~isempty(tag)
          str = [ str, ...
                  sprintf( '\n%% Axis "%s"', tag ) ];
      else
          str = [ str, ...
                  sprintf( '\n%% Axis at [%.2g %.2f %.2g %.2g]', ...
                           get(handle, 'position' ) ) ];
      end
    
      % Now, return the whole axis environment.
      str = [ str, ...
              sprintf( ['\n\\begin{%s}[',opts,']\n\n'], env ), ...
              childrenStr, ...
              sprintf( '\\end{%s}\n\n', env ) ];
  end
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END OF FUNCTION drawAxes
% =========================================================================



% =========================================================================
% *** FUNCTION drawLine
% ***
% *** Returns the code for drawing a regular line.
% *** This is an extremely common operation and takes place in most of the
% *** not too fancy plots.
% ***
% *** This function handles error bars, too.
% ***
% =========================================================================
function str = drawLine( handle, yDeviation )

  global currentHandles

  % check if the *optional* argument 'yDeviation' was given
  errorbarMode = 0;
  if nargin>1
      errorbarMode = 1;
  end

  str = [];

  if ~isVisible( handle )
      return
  end

  lineStyle = get( handle, 'LineStyle' );
  lineWidth = get( handle, 'LineWidth' );
  marker    = get( handle, 'Marker' );

  if ( strcmp(lineStyle,'none') || lineWidth==0 ) && strcmp(marker,'none')
      return
  end


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % deal with draw options
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  color  = get( handle, 'Color' );
  xcolor = getColor( handle, color, 'patch' );
  drawOptions = [ sprintf( 'color=%s', xcolor ),           ... % color
                   getLineOptions( lineStyle, lineWidth ), ... % line options
                   getMarkerOptions( handle )              ... % marker options
                 ];

  % insert draw options
  opts = [ '\n', collapse( drawOptions, ',\n' ), '\n' ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the actual line data
  % -- Check for any node if it needs to be included at all. For zoomed
  %    plots, lots can be omitted.
  p      = currentHandles.gca;
  xLim   = get( p, 'XLim' );
  yLim   = get( p, 'YLim' );
  xData  = get( handle, 'XData' );
  yData  = get( handle, 'YData' );
  segvis = segmentVisible( [xData', yData'], xLim, yLim );

  n = length(xData);

  if errorbarMode
      if n~=length(yDeviation)
          error( 'drawLine:arrayLengthsMismatch', ...
                 '''drawline'' was called with errors bars turned on, but array lengths do not match.' );
      end
  end

  % The line gets actually broken up into several as some parts of it may
  % be outside the visible area (the plot box).
  % 'segvis' tells us which segment are actually visible, and the
  % following construction loops through it and makes sure that each
  % point that is necessary gets actually printed.
  % 'printPrevious' tells whether or not the previous segment is visible;
  % this information is used for determining when a new 'addplot' needs
  % to be opened.
  printPrevious = 0;
  for k = 1:n-1
      if segvis(k) % segment is visible
          %  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          if ~printPrevious % .. the previous wasn't, hence start a plot
              str = [ str, ...
                      sprintf( ['\\addplot [',opts,']'] ) ];
              if errorbarMode
                  str = [ str, ...
                          sprintf('\nplot[error bars/.cd, y dir = both, y explicit]\n') ];
              end
              str = [ str, ...
                      sprintf('coordinates{\n') ];

              str = [ str, ...
                      sprintf( ' (%g,%g)', xData(k), yData(k) ) ];
              if errorbarMode
                  str = [ str, ...
                          sprintf( ' +- (%g,%g)\n', 0, yDeviation(k) ) ];
              end
              printPrevious = 1;
          end

          str = [ str, sprintf( ' (%g,%g)', xData(k+1), yData(k+1) ) ];
          if errorbarMode
              str = [ str, ...
                      sprintf( ' +- (%g,%g)\n', 0, yDeviation(k+1) ) ];
          end
          %  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
      else
          %  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          if printPrevious  % that was the last entry for now
              if ~errorbarMode % error bars already create newline characters
                  str = [ str, ...
                          sprintf('\n') ];
              end
              str = [ str, sprintf('};\n\n') ];
              printPrevious = 0;
          end
          %  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
      end
  end
  if printPrevious % don't forget to print the closing bracket
      if ~errorbarMode % error bars already create newline characters
          str = [ str, ...
                  sprintf('\n') ];
      end
      str = [ str, sprintf('};\n\n') ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  str = [ str, handleAllChildren( handle ) ];


  % -----------------------------------------------------------------------
  % FUNCTION segmentVisible
  %
  % Given a series of points 'p', this routines determines which inter-'p'
  % connections are visible in the box given by 'xLim', 'yLim'.
  %
  % -----------------------------------------------------------------------
  function out = segmentVisible( p, xLim, yLim )

      n   = size( p, 1 ); % number of points
      out = zeros( n-1, 1 );

      % Find out where (with respect the the box) the points 'p' sit.
      % Consider the documentation for 'boxWhere' to find out about
      % the meaning of the return values.
      boxpos = boxWhere( p, xLim, yLim );

      for k = 1:n-1
          if any(boxpos{k}==1) || any(boxpos{k+1}==1) % one of the two is strictly inside the box
              out(k) = 1;
          elseif any(boxpos{k}==2) || any(boxpos{k+1}==2) % one of the two is strictly outside the box
              % does the segment intersect with any of the four boundaries?
              out(k) =  segmentsIntersect( [p(k:k+1,1)',xLim(1),xLim(1)], ...   % with the left?
                                           [p(k:k+1,2)',yLim] ) ...
                     || segmentsIntersect( [p(k:k+1,1)',xLim],  ...             % with the bottom?
                                           [p(k:k+1,2)',yLim(1),yLim(1)] ) ...
                     || segmentsIntersect( [p(k:k+1,1)',xLim(2),xLim(2)],  ...  % with the right?
                                           [p(k:k+1,2)',yLim] ) ...
                     || segmentsIntersect( [p(k:k+1,1)',xLim],  ...             % with the top?
                                           [p(k:k+1,2)',yLim(2),yLim(2)] );
          else % both neighboring points lie on the boundary
              % This is kind of tricky as there may be nodes *exactly*
              % in a corner of the domain. boxpos & commonEntry handle
              % this, though.
              out(k) =  ~commonEntry( boxpos{k},boxpos{k+1} );
          end
      end

  end
  % -----------------------------------------------------------------------
  % END FUNCTION segmentVisible
  % -----------------------------------------------------------------------

  % -----------------------------------------------------------------------
  % *** FUNCTION segmentsIntersect
  % ***
  % *** Checks whether the segments P1--P2 and P3--P4 intersect.
  % *** The x- and y- coordinates of Pi are in x(i), y(i), respectively.
  % ***
  % -----------------------------------------------------------------------
  function out = segmentsIntersect( x, y )

    % Technically, one writes down the 2x2 equation system to solve the
    %
    %   x1 + lambda (x2-x1)  =  x3 + mu (x4-x3)
    %   y1 + lambda (y2-y1)  =  y3 + mu (y4-y3)
    %
    % for lambda and mu. If a solution exists, check if   0 < lambda,mu < 1.

    det = (x(4)-x(3))*(y(2)-y(1)) - (y(4)-y(3))*(x(2)-x(1));

    out = det;

    if det % otherwise the segments are parallel
        rhs1   = x(3) - x(1);
        rhs2   = y(3) - y(1);
        lambda = ( -rhs1* (y(4)-y(3)) + rhs2* (x(4)-x(3)) ) / det;
        mu     = ( -rhs1* (y(2)-y(1)) + rhs2* (x(2)-x(1)) ) / det;
        out    =   0<lambda && lambda<1 ...
                &&  0<mu     && mu    <1;
    end

  end
  % -----------------------------------------------------------------------
  % *** END FUNCTION segmentsIntersect
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END OF FUNCTION drawLine
% =========================================================================



% =========================================================================
% *** FUNCTION getLineOptions
% ***
% *** Gathers the line options.
% ***
% =========================================================================
function lineOpts = getLineOptions( lineStyle, lineWidth )

  global tol
  global matlab2tikzOpts;

  lineOpts = cell(0);

  if ~strcmp(lineStyle,'none') && abs(lineWidth-tol)>0

      lineOpts = [ lineOpts,                                           ...
                   sprintf('%s', translateLineStyle(lineStyle) ) ];

      % take over the line width in any case when in strict mode;
      % if not, don't add anything in case of default line width
      % and effectively take pgfplots' default
      matlabDefaultLineWidth = 0.5;
      if matlab2tikzOpts.Results.strict ...
         || ~abs(lineWidth-matlabDefaultLineWidth) <= tol
          lineOpts = [ lineOpts,                                       ...
                       sprintf('line width=%.1fpt', lineWidth ) ];
      end

  end

end
% =========================================================================
% *** END FUNCTION getLineOptions
% =========================================================================



% =========================================================================
% *** FUNCTION getMarkerOptions
% ***
% *** Handles the marker properties of a line (or any other) plot.
% ***
% =========================================================================
function drawOptions = getMarkerOptions( h )

  global matlab2tikzOpts

  drawOptions = cell(0);

  marker = get( h, 'Marker' );

  if ~strcmp( marker, 'none' )
      markerSize = get( h, 'MarkerSize' );
      lineStyle  = get( h, 'LineStyle' );
      lineWidth  = get( h, 'LineWidth' );

      [ tikzMarkerSize, isDefault ] = ...
                               translateMarkerSize( marker, markerSize );

      % take over the marker size in any case when in strict mode;
      % if not, don't add anything in case of default marker size
      % and effectively take pgfplots' default
      if matlab2tikzOpts.Results.strict || ~isDefault
         drawOptions = [ drawOptions,                                 ...
                         sprintf( 'mark size=%.1fpt', tikzMarkerSize ) ];
      end

      markOptions = cell( 0 );
      % make sure that the markers get painted in solid (and not dashed)
      % if the 'lineStyle' is not solid (otherwise there is no problem)
      if ~strcmp( lineStyle, 'solid' )
          markOptions = [ markOptions, 'solid' ];
      end

      % print no lines
      if strcmp(lineStyle,'none') || lineWidth==0
          drawOptions = [ drawOptions, 'only marks' ] ;
      end

      % get the marker color right
      markerFaceColor = get( h, 'markerfaceColor' );
      markerEdgeColor = get( h, 'markeredgeColor' );
      [ tikzMarker, markOptions ] = translateMarker( marker,         ...
                           markOptions, ~strcmp(markerFaceColor,'none') );
      if ~strcmp(markerFaceColor,'none')
          xcolor = getColor( h, markerFaceColor, 'patch' );
          markOptions = [ markOptions,  sprintf( 'fill=%s', xcolor ) ];
      end
      if ~strcmp(markerEdgeColor,'none') && ~strcmp(markerEdgeColor,'auto')
          xcolor = getColor( h, markerEdgeColor, 'patch' );
          markOptions = [ markOptions, sprintf( 'draw=%s', xcolor ) ];
      end

      % add it all to drawOptions
      drawOptions = [ drawOptions, sprintf( 'mark=%s', tikzMarker ) ];

      if ~isempty( markOptions )
          mo = collapse( markOptions, ',' );
          drawOptions = [ drawOptions, [ 'mark options={', mo, '}' ] ];
      end
  end


  % -----------------------------------------------------------------------
  % *** FUNCTION translateMarker
  % -----------------------------------------------------------------------
  function [ tikzMarker, markOptions ] =                                ...
             translateMarker( matlabMarker, markOptions, faceColorToggle )

    if( ~ischar(matlabMarker) )
        error( [ 'Function translateMarker:',                           ...
                 'Variable matlabMarker is not a string.' ] );
    end

    switch ( matlabMarker )
        case 'none'
            tikzMarker = '';
        case '+'
            tikzMarker = '+';
        case 'o'
            if faceColorToggle
                tikzMarker = '*';
            else
                tikzMarker = 'o';
            end
        case '.'
            tikzMarker = '*';
        case 'x'
            tikzMarker = 'x';
        otherwise  % the following markers are only available with PGF's
                   % plotmarks library
            fprintf( '\nMake sure to load \\usetikzlibrary{plotmarks} in the preamble.\n' );
            switch ( matlabMarker )

                    case '*'
                            tikzMarker = 'asterisk';

                    case {'s','square'}
                    if faceColorToggle
                                tikzMarker = 'square*';
                    else
                        tikzMarker = 'square';
                    end

                    case {'d','diamond'}
                    if faceColorToggle
                                tikzMarker = 'diamond*';
                    else
                                tikzMarker = 'diamond';
                    end

                case '^'
                    if faceColorToggle
                                tikzMarker = 'triangle*';
                    else
                                tikzMarker = 'triangle';
                    end

                    case 'v'
                    if faceColorToggle
                        tikzMarker = 'triangle*';
                    else
                                tikzMarker = 'triangle';
                    end
                    markOptions = [ markOptions, ',rotate=180' ];

                    case '<'
                    if faceColorToggle
                        tikzMarker = 'triangle*';
                    else
                                tikzMarker = 'triangle';
                    end
                    markOptions = [ markOptions, ',rotate=270' ];

                case '>'
                    if faceColorToggle
                                tikzMarker = 'triangle*';
                    else
                                tikzMarker = 'triangle';
                    end
                    markOptions = [ markOptions, ',rotate=90' ];

                case {'p','pentagram'}
                    if faceColorToggle
                                tikzMarker = 'star*';
                    else
                                tikzMarker = 'star';
                    end

                    case {'h','hexagram'}
                    warning( 'matlab2tikz:translateMarker',              ...
                            'MATLAB''s marker ''hexagram'' not available in TikZ. Replacing by ''star''.' );
                    if faceColorToggle
                                tikzMarker = 'star*';
                    else
                                tikzMarker = 'star';
                    end

                otherwise
                    error( [ ' Function translateMarker:',               ...
                            ' Unknown matlabMarker ''',matlabMarker,'''.' ] );
            end
    end

  end
  % -----------------------------------------------------------------------
  % *** END OF FUNCTION translateMarker
  % -----------------------------------------------------------------------


  % -----------------------------------------------------------------------
  % *** FUNCTION translateMarkerSize
  % ***
  % *** The markersizes of Matlab and TikZ are related, but not equal. This
  % *** is because
  % ***
  % ***  1.) MATLAB uses the MarkerSize property to describe something like
  % ***      the diameter of the mark, while TikZ refers to the 'radius',
  % ***  2.) MATLAB and TikZ take different measures (, e.g., the
  % ***      edgelength of a square vs. the diagonal length of it).
  % ***
  % -----------------------------------------------------------------------
  function [ tikzMarkerSize, isDefault ] =                              ...
                      translateMarkerSize( matlabMarker, matlabMarkerSize )

    global tol

    if( ~ischar(matlabMarker) )
        error( 'matlab2tikz:translateMarkerSize',                      ...
               'Variable matlabMarker is not a string.' );
    end

    if( ~isnumeric(matlabMarkerSize) )
        error( 'matlab2tikz:translateMarkerSize',                      ...
               'Variable matlabMarkerSize is not a numeral.' );
    end

    % 6pt is the default MATLAB marker size for all markers
    defaultMatlabMarkerSize = 6;
    isDefault = abs(matlabMarkerSize-defaultMatlabMarkerSize)<tol;

    switch ( matlabMarker )
        case 'none'
            tikzMarkerSize = [];
        case {'+','o','x','*','p','pentagram','h','hexagram'}
            % In MATLAB, the marker size refers to the edge length of a
            % square (for example) (~diameter), whereas in TikZ the
            % distance of an edge to the center is the measure (~radius).
            % Hence divide by 2.
            tikzMarkerSize = matlabMarkerSize / 2;
        case '.'
            % as documented on the Matlab help pages:
            %
            % Note that MATLAB draws the point marker (specified by the '.'
            % symbol) at one-third the specified size.
            % The point (.) marker type does not change size when the
            % specified value is less than 5.
            %
            tikzMarkerSize = matlabMarkerSize / 2 / 3;
        case {'s','square'}
            % Matlab measures the diameter, TikZ half the edge length
            tikzMarkerSize = matlabMarkerSize / 2 / sqrt(2);
        case {'d','diamond'}
            % MATLAB measures the width, TikZ the height of the diamond;
            % the acute angle (at the top and the bottom of the diamond)
            % is a manually measured 75 degrees (in TikZ, and MATLAB
            % probably very similar); use this as a base for calculations
            tikzMarkerSize = matlabMarkerSize / 2 / atan( 75/2 *pi/180 );
        case {'^','v','<','>'}
            % for triangles, matlab takes the height
            % and tikz the circumcircle radius;
            % the triangles are always equiangular
            tikzMarkerSize = matlabMarkerSize / 2 * (2/3);
        otherwise
            error( 'matlab2tikz:translateMarkerSize',                   ...
                   'Unknown matlabMarker ''%s''.', matlabMarker );
    end

  end
  % -----------------------------------------------------------------------
  % *** END OF FUNCTION translateMarkerSize
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END FUNCTION getMarkerOptions
% =========================================================================



% =========================================================================
% *** FUNCTION drawPatch
% ***
% *** Draws a 'patch' graphics object (as found in contourf plots, for
% *** example).
% ***
% *** TODO: Declare common patch properties (like `draw=none`) once for
% ***       for all patches.
% ***
% =========================================================================
function str = drawPatch( handle )

  str = [];

  if ~isVisible( handle )
      return
  end

  % -----------------------------------------------------------------------
  % gather the draw options
  drawOptions = cell(0);

  % fill color
  faceColor  = get( handle, 'FaceColor' );
  if ~strcmp( faceColor, 'none' )
      xFaceColor = getColor( handle, faceColor, 'patch' );
      drawOptions = [ drawOptions,                                    ...
                       sprintf( 'fill=%s', xFaceColor ) ];
  end

  % draw color
  edgeColor = get( handle, 'EdgeColor' );
  lineStyle = get( handle, 'LineStyle' );
  if strcmp( lineStyle, 'none' ) || strcmp( edgeColor, 'none' )
      drawOptions = [ drawOptions, 'draw=none' ];
  else
      xEdgeColor = getColor( handle, edgeColor, 'patch' );
      drawOptions = [ drawOptions, sprintf( 'draw=%s', xEdgeColor ) ];
  end

  drawOpts = collapse( drawOptions, ',' );
  % -----------------------------------------------------------------------


  % MATLAB's patch elements are matrices in which each column represents a
  % a distinct graphical object. Usually there is only one column, but
  % there may be more (-->hist plots, although they are now handled
  % within the barplot framework).
  xData = get( handle, 'XData' );
  yData = get( handle, 'YData' );
  m = size(xData,1);
  n = size(xData,2); % is n ever ~=1? if yes, think about replacing
                     % the drawOpts by one \pgfplotsset{}

  for j=1:n
      str = [ str, ...
              sprintf(['\\addplot [',drawOpts,'] coordinates{']) ];
      for i=1:m
          if ~isnan(xData(i,j)) && ~isnan(yData(i,j))
              % don't print NaNs
              str = [ str, ...
                      sprintf( ' (%g,%g)', xData(i,j), yData(i,j) ) ];
          end
      end
      str = [ str, sprintf('};\n') ];
  end
  str = [ str, sprintf('\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  str = [ str, handleAllChildren(handle) ];

end
% =========================================================================
% *** END OF FUNCTION drawPatch
% =========================================================================



% =========================================================================
% *** FUNCTION drawImage
% ***
% *** Draws an 'image' graphics object (which is essentially just a matrix
% *** containing the RGB color values for a spot).
% ***
% =========================================================================
function str = drawImage( handle )

  str = [];

  if ~isVisible( handle )
      return
  end

  % read x-, y-, and color-data
  xData = get( handle, 'XData' );
  yData = get( handle, 'YData' );
  cdata = get( handle, 'CData' );

  m = size(cdata,1);
  n = size(cdata,2);

  % Generate uniformly distributed X, Y, although xData and yData may be non-uniform.
  % This is MATLAB(R) behaviour.
  switch length(xData)
      case 2 % only the limits given; common for generic image plots
          hX = 1;
      case m % specific x-data is given
          hX = (xData(end)-xData(1)) / (length(xData)-1);
      otherwise
          error( 'drawImage:arrayLengthMismatch', ...
                 sprintf( 'Array lengths not matching (%d = size(cdata,1) ~= length(xData) = %d).', m, length(xData) ) );
  end
  X = xData(1):hX:xData(end);

  switch length(yData)
      case 2 % only the limits given; common for generic image plots
          hY = 1;
      case n % specific y-data is given
          hY = (yData(end)-yData(1)) / (length(yData)-1);
      otherwise
          error( 'drawImage:arrayLengthMismatch', ...
                 sprintf( 'Array lengths not matching (%d = size(cdata,2) ~= length(yData) = %d).', n, length(yData) ) );
  end
  Y = yData(1):hY:yData(end);


  % draw the thing
  m = length(X);
  n = length(Y);
  xcolor = cell(m,n);
  for i = 1:m
      for j = 1:n
          xcolor{i,j} = getColor( handle, cdata(i,j,:), 'image' );
      end
  end

  % The following section takes pretty long to execute, although in principle it is
  % discouraged to use TikZ for those; LaTeX will take forever to compile.
  % Still, a bug has been filed on MathWorks to allow for one-line sprintf'ing with
  % (string+num) cells.
  for i = 1:m
      for j = 1:n
          str = [ str, ...
                  sprintf( '\\fill [%s] (axis cs:%g,%g) rectangle (axis cs:%g,%g);\n', ...
                           xcolor{i,j}, Y(j)-hY/2,  X(i)-hX/2, Y(j)+hY/2, X(i)+hX/2  ) ];
      end
  end

end
% =========================================================================
% *** END OF FUNCTION drawImage
% =========================================================================



% =========================================================================
% *** FUNCTION drawHggroup
% =========================================================================
function str = drawHggroup( h )

  cl = class( handle(h) );

  switch( cl )
      case 'specgraph.barseries'
          % hist plots and friends
          str = drawBarseries( h );

      case 'specgraph.stemseries'
          % stem plots
          str = drawStemseries( h );

      case 'specgraph.stairseries'
          % stair plots
          str = drawStairSeries( h );

      case {'specgraph.contourgroup'}
          % handle all those the usual way
          str = handleAllChildren( h );

      case {'specgraph.quivergroup'}
          % quiver arrows
          str = drawQuiverGroup( h );

      case {'specgraph.errorbarseries'}
          % error bars
          str = drawErrorBars( h );

      otherwise
          warning( 'matlab2tikz:drawHggroup',                          ...
                   'Don''t know class ''%s''. Default handling.', cl );
          str = handleAllChildren( h );
  end

end
% =========================================================================
% *** END FUNCTION drawHggroup
% =========================================================================



% =========================================================================
% *** FUNCTION drawBarseries
% ***
% *** Takes care of plots like the ones produced by MATLAB's hist.
% *** The main pillar is pgfplots's '{x,y}bar' plot.
% ***
% *** NOTE: There is code duplication with 'drawAxes'. Try to get rid of
% ***       that!
% ***
% =========================================================================
function str = drawBarseries( h )

  global axisOpts;

  % 'barplotId' provides a consecutively numbered ID for each
  % barseries plot. This allows for properly handling multiple bars.
  persistent barplotId
  persistent barplotTotalNumber
  persistent barWidth
  persistent barShifts

  persistent addedAxisOption
  persistent nonbarPlotPresent

  str = [];

  % -----------------------------------------------------------------------
  % The bar plot implementation in pgfplots lacks certain functionalities;
  % for example, it can't plot bar plots and non-bar plots in the same
  % axis (while MATLAB can).
  % The following checks if this is the case and cowardly bails out if so.
  % On top of that, the number of bar plots is counted.
  if isempty(barplotTotalNumber)
      nonbarPlotPresent  = 0;
      barplotTotalNumber = 0;
      parent             = get( h, 'Parent' );
      siblings           = get( parent, 'Children' );
      for k = 1:length(siblings)

          % skip invisible objects
          if ~isVisible(siblings(k))
              continue
          end

          t = get( siblings(k), 'Type' );
          switch t
              case {'line','patch'}
                  nonbarPlotPresent = 1;
              case 'text'
                  % this is pretty harmless: don't complain about ordinary text
              case 'hggroup'
                  cl = class(handle(siblings(k)));
                  switch cl
                      case 'specgraph.barseries'
                          barplotTotalNumber = barplotTotalNumber + 1;
                      case 'specgraph.errorbarseries'
                          % TODO:
                          % Unfortunately, MATLAB(R) treats error bars and corresponding
                          % bar plots as siblings of a common axes object.
                          % For error bars to work with bar plots -- which is trivially
                          % possible in pgfplots -- one has to match errorbar and bar
                          % objects (probably by their values).
                          warning( 'matlab2tikz:drawBarseries',        ...
                                   'Error bars discarded (to be implemented).'  );
                      otherwise
                          error( 'matlab2tikz:drawBarseries',          ...
                                 'Unknown class''%s''.', cl  );
                  end
              otherwise
                  error( 'matlab2tikz:drawBarseries',                  ...
                         'Unknown type ''%s''.', t );
          end
      end
  end
  % -----------------------------------------------------------------------


  xData = get( h, 'XData' );
  yData = get( h, 'YData' );

  % init drawOptions
  drawOptions = cell(0);

  barlayout = get( h, 'BarLayout' );
  switch barlayout
      case 'grouped'
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          % grouped plots
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          groupWidth = 0.8; % MATLAB's default value, see makebars.m

          % set ID
          if isempty(barplotId)
              barplotId = 1;
          else
              barplotId = barplotId + 1;
          end

          % ---------------------------------------------------------------
          % Calculate the width of each bar and the center point shift.
          % The following is taken from MATLAB (see makebars.m) without
          % the special handling for hist plots or other fancy options.
          % ---------------------------------------------------------------
          if isempty( barWidth ) || isempty(barShifts)
              dx = min( diff(xData) );
              groupWidth = dx * groupWidth;

              % this is the barWidth with no interbar spacing yet
              barWidth = groupWidth / barplotTotalNumber;

              barShifts = -0.5* groupWidth                              ...
                        + ( (0:barplotTotalNumber-1)+0.5) * barWidth;

              bWFactor = get( h, 'BarWidth' );
              barWidth  = bWFactor* barWidth;
          end
          % ---------------------------------------------------------------

          % MATLAB treats shift and width in normalized coordinate units,
          % whereas pgfplots requires physical units (pt,cm,...); hence
          % have the units converted.
          ulength = normalized2physical();
          drawOptions = [ drawOptions,                                                ...
                           'ybar',                                                      ...
                           sprintf( 'bar width=%g%s, bar shift=%g%s',                   ...
                                    barWidth            *ulength.value, ulength.unit , ...
                                    barShifts(barplotId)*ulength.value, ulength.unit  ) ];
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          % end grouped plots
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      case 'stacked'
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          % Stacked plots --
          % Add option 'ybar stacked' to the options of the surrounding
          % axis environment (and disallow anything else but stacked
          % plots).
          % Make sure this happens exactly *once*.
          if isempty(addedAxisOption) || ~addedAxisOption
              if nonbarPlotPresent
                  warning( 'matlab2tikz:drawBarseries',                 ...
                        [ 'Pgfplots can''t deal with stacked bar plots', ...
                          ' and non-bar plots in one axis environment.', ...
                          ' There *may* be unexpected results.'         ] );
              end
              bWFactor = get( h, 'BarWidth' );
              ulength   = normalized2physical();
              axisOpts = [ axisOpts,                                   ...
                            'ybar stacked',                              ...
                            sprintf( 'bar width=%g%s',                   ...
                                  ulength.value*bWFactor, ulength.unit ) ];
              addedAxisOption = 1;
          end
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      otherwise
          error( 'matlab2tikz:drawBarseries',                          ...
                 'Don''t know how to handle BarLayout ''%s''.', barlayout );
  end


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define edge color
  edgeColor  = get( h, 'EdgeColor' );
  xEdgeColor = getColor( h, edgeColor, 'patch' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define face color;
  % quite oddly, this value is not coded in the handle itself, but in its
  % child patch.
  child      = get( h, 'Children' );
  faceColor  = get( child, 'FaceColor');
  xFaceColor = getColor( h, faceColor, 'patch' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % gather the draw options
  lineStyle = get( h, 'LineStyle' );

  drawOptions = [ drawOptions, sprintf( 'fill=%s', xFaceColor ) ];
  if strcmp( lineStyle, 'none' )
      drawOptions = [ drawOptions, 'draw=none' ];
  else
      drawOptions = [ drawOptions, sprintf( 'draw=%s', xEdgeColor ) ];
  end
  drawOpts = collapse( drawOptions, ',' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  for k=1:length(xData)
      str = [ str, ...
              sprintf( ' (%g,%g)', xData(k), yData(k) ) ];
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION drawBarseries
% =========================================================================



% =========================================================================
% *** FUNCTION drawStemseries
% ***
% *** Takes care of MATLAB's stem plots.
% ***
% *** NOTE: There is code duplication with 'drawAxes'. Try to get rid of
% ***       that!
% ***
% =========================================================================
function str = drawStemseries( h )

  str = [];

  lineStyle = get( h, 'LineStyle' );
  lineWidth = get( h, 'LineWidth' );
  marker    = get( h, 'Marker' );

  if (    ( strcmp(lineStyle,'none') || lineWidth==0 )                  ...
       && strcmp(marker,'none') )
      % nothing to plot!
      return
  end

  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  % deal with draw options
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  color     = get( h, 'Color' );
  plotColor = getColor( h, color, 'patch' );

  drawOptions = [ 'ycomb',                                  ...
                   sprintf( 'color=%s', plotColor ),         ... % color
                   getLineOptions( lineStyle, lineWidth ), ... % line options
                   getMarkerOptions( h )                   ... % marker options
                 ];

  % insert draw options
  drawOpts =  collapse( drawOptions, ',' );
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =



  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  xData = get( h, 'XData' );
  yData = get( h, 'YData' );

  for k=1:length(xData)
      str = [ str, ...
              sprintf( ' (%g,%g)', xData(k), yData(k) ) ];
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION drawStemseries
% =========================================================================



% =========================================================================
% *** FUNCTION drawStairSeries
% ***
% *** Takes care of MATLAB's stairs plots.
% ***
% *** NOTE: There is code duplication with 'drawAxes'. Try to get rid of
% ***       that!
% ***
% =========================================================================
function str = drawStairSeries( h )

  str = [];

  lineStyle = get( h, 'LineStyle');
  lineWidth = get( h, 'LineWidth');
  marker    = get( h, 'Marker');

  if (    ( strcmp(lineStyle,'none') || lineWidth==0 )                  ...
       && strcmp(marker,'none') )
      return
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % deal with draw options
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  color     = get( h, 'Color' );
  plotColor = getColor( h, color, 'patch' );

  drawOptions = [ 'const plot',                             ...
                   sprintf( 'color=%s', plotColor ),         ... % color
                   getLineOptions( lineStyle, lineWidth ), ... % line options
                   getMarkerOptions( h )                   ... % marker options
                 ];

  % insert draw options
  drawOpts =  collapse( drawOptions, ',' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  xData = get( h, 'XData' );
  yData = get( h, 'YData' );

  for k=1:length(xData)
      str = [ str, ...
              sprintf( ' (%g,%g)', xData(k), yData(k) ) ];
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION drawStairSeries
% =========================================================================



% =========================================================================
% *** FUNCTION drawQuiverGroup
% ***
% *** Takes care of MATLAB's quiver plots.
% ***
% =========================================================================
function str = drawQuiverGroup( h )

  global tikzOptions
  persistent quiverId  % used for arrow styles, in case there are more than one quiver fields

  if isempty(quiverId)
     quiverId = 0;
  else
     quiverId = quiverId + 1;
  end

  str = [];

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % One could get(h,'{X,Y,U,V}Data') in which the intended arrow lengths are stored.
  % MATLAB(R) however applies some quite sophisticated scaling here to avoid overlap
  % of arrows.
  % The actual length of the arrows is stored in c(1) of
  %
  %  c = get(h,'Children');
  %
  % 'XData' and 'YData' of c(1) will be of the form
  %
  % [arrow1point1, arrow1point2, NaN, arrow2point1, arrow2point2, NaN].
  %
  c = get( h, 'Children' );

  xData = get( c(1), 'XData' );
  yData = get( c(1), 'YData' );

  step = 3;
  m = length(xData(1:step:end));   % number of arrows

  XY = zeros(4,m);

  XY(1,:) = xData(1:step:end);
  XY(2,:) = yData(1:step:end);
  XY(3,:) = xData(2:step:end);
  XY(4,:) = yData(2:step:end);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % gather the arrow options
  showArrowHead = get( h, 'ShowArrowHead' );
  lineStyle     = get( h, 'LineStyle' );
  lineWidth     = get( h, 'LineWidth' );

  if ( strcmp(lineStyle,'none') || lineWidth==0 )  && ~showArrowHead
      return
  end

  arrowOpts = cell(0);
  if showArrowHead
      arrowOpts = [ arrowOpts, '->' ];
  else
      arrowOpts = [ arrowOpts, '-' ];
  end

  color      = get( h, 'Color');
  arrowcolor = getColor( h, color, 'patch' );
  arrowOpts = [ arrowOpts,                               ...
                 sprintf( 'color=%s', arrowcolor ),      ... % color
                 getLineOptions( lineStyle, lineWidth ), ... % line options
               ];

  % define arrow style
  arrowOptions = collapse( arrowOpts, ',' );

  % Append the arrow style to the TikZ options themselves.
  % TODO: Look into replacing this by something more 'local',
  % (see \pgfplotset{}).
  arrowStyle  = [ 'arrow',num2str(quiverId),'/.style={',arrowOptions,'}' ];
  tikzOptions = [ tikzOptions, arrowStyle ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % return the vector field code
  str = [ str, ...
          sprintf( [ '\\addplot [arrow',num2str(quiverId)  ,...
                     '] coordinates{ (%g,%g) (%g,%g) };\n'],...
                   XY ) ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION drawQuiverGroup
% =========================================================================



% =========================================================================
% *** FUNCTION drawErrorBars
% ***
% *** Takes care of MATLAB's error bar plots.
% ***
% =========================================================================
function str = drawErrorBars( h )

  str = [];

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % 'errorseries' plots have two line-plot children, one of which contains
  % the information about the center points; 'XData' and 'YData' components
  % are both of length n.
  % The other contains the information about the deviations (errors).
  % 'XData' and 'YData' are of length 9*n and contain redundant info which
  % is only needed by MATLAB itself to explicitly draw the error bars.
  c = get( h, 'Children' );

  n1 = length( get(c(1),'XData') );
  n2 = length( get(c(2),'XData') );

  if n2 - 9*n1 == 0
      % n1 contains centerpoint info
      dataIdx  = 1;
      errorIdx = 2;
  elseif n1 - 9*n2 == 0
      % n2 contains centerpoint info
      dataIdx  = 2;
      errorIdx = 1;
  else
      error( 'drawErrorBars:errorMatch', ...
             'Sizes of and error data not matching (9*%d ~= %d and 9*%d ~= %d).', ...
             n1, n2, n2, n1 );
  end

  % prepare error array (that is, gather the y-deviations)
  yValues = get( c(dataIdx) , 'YData' );
  yErrors = get( c(errorIdx), 'YData' );

  n = length(yValues);

  yDeviations = zeros(n,1);

  for k = 1:n
      % upper deviation
      kk = 9*(k-1) + 1;
      upDev = abs(yValues(k) - yErrors(kk));

      % lower deviation
      kk = 9*(k-1) + 2;
      loDev = abs(yValues(k) - yErrors(kk));

      if abs(upDev-loDev) >= 1e-10 % don't use 'tol' here as is seems somewhat too strict
          error( 'drawErrorBars:uneqDeviations', ...
                 'Upper and lower error deviations not equal (%g ~= %g); matlab2tikz can''t deal with that yet. Using upper deviations.', upDev, loDev );
      end         

      yDeviations(k) = upDev;

  end

  % now, pull line plot with deviation information
  str = drawLine( c(dataIdx), yDeviations );

end
% =========================================================================
% *** END FUNCTION drawErrorBars
% =========================================================================



% =========================================================================
% *** FUNCTION drawColorbar
% ***
% *** TODO: * Declare common properties (like `draw=none`) once for
% ***         for all badges.
% ***       * Look into orignal pgfplots color bars.
% ***
% =========================================================================
function str = drawColorbar( handle, alignmentOptions )

  global currentHandles

  str = [];

  if ~isVisible( handle )
      return
  end

  % The dimensions returned by  'getAxesDimensions' are not entirely
  % correct: When looking closely, one will see that the colorbar actually
  % (very slightly) overshoots the size of its parental axis.
  % For now, leave it like this as the overshoot is really small
  dim = getAxesDimensions( handle );

  % get the upper and lower limit of the colorbar
  clim = caxis;

  % begin collecting axes options
  cbarOptions = cell( 0 );
  cbarOptions = [ cbarOptions, 'axis on top' ];

  % set alignment options
  if alignmentOptions.isRef
      cbarOptions = [ cbarOptions, sprintf('name=%s',alignmentOptions.name) ];
  end
  if ~isempty(alignmentOptions.opts)
      cbarOptions = [ cbarOptions, alignmentOptions.opts ];
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set position, ticks etc. of the colorbar
  loc = get( handle, 'Location' );
  switch loc
      case { 'North', 'South', 'East', 'West' }
          warning( 'matlab2tikz:drawColorbar',                         ...
                   'Don''t know how to deal with inner colorbars yet.' );
          return;

      case {'NorthOutside','SouthOutside'}
%            dim.y = dim.x / ratio;
          cbarOptions = [ cbarOptions,                                ...
                           sprintf( 'width=%g%s, height=%g%s',          ...
                                     dim.x, dim.unit, dim.y, dim.unit ),...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%g, xmax=%g', clim ),         ...
                           sprintf( 'ymin=%g, ymax=%g', [0,1] )         ...
                         ];

          if strcmp( loc, 'NorthOutside' )
              cbarOptions = [ cbarOptions,                            ...
                              'xticklabel pos=right, ytick=\\empty' ];
                              % we actually wanted to set pos=top here,
                              % but pgfplots doesn't support that yet.
                              % pos=right does the same thing, really.
          else
              cbarOptions = [ cbarOptions,                            ...
                               'xticklabel pos=left, ytick=\\empty' ];
                               % we actually wanted to set pos=bottom here,
                               % but pgfplots doesn't support that yet. 
                               % pos=left does the same thing, really.
          end

      case {'EastOutside','WestOutside'}
          cbarOptions = [ cbarOptions,                                ...
                           sprintf( 'width=%g%s, height=%g%s',          ...
                                     dim.x, dim.unit, dim.y, dim.unit ),...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%g, xmax=%g', [0,1] ),        ...
                           sprintf( 'ymin=%g, ymax=%g', clim )          ...
                         ];
          if strcmp( loc, 'EastOutside' )
               cbarOptions = [ cbarOptions,                           ...
                               'xtick=\\empty, yticklabel pos=right' ];
           else
               cbarOptions = [ cbarOptions,                           ...
                               'xtick=\\empty, yticklabel pos=left' ];
           end

      otherwise
          error( 'drawColorbar: Unknown ''Location'' %s.', loc )
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ ticks, tickLabels ] = getTicks( handle );
  if ~isempty( ticks.x )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'xtick={%s}', ticks.x ) ];
  end
  if ~isempty( tickLabels.x )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'xticklabels={%s}', tickLabels.x ) ];
  end
  if ~isempty( ticks.y )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'ytick={%s}', ticks.y ) ];
  end
  if ~isempty( tickLabels.y )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'yticklabels={%s}', tickLabels.y ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % actually begin drawing the thing
  str = [ str, ...
          sprintf( '\n%% the colorbar\n' ) ];
  cbarOpts = collapse( cbarOptions, ',\n' );
  str = [ str, ...
          sprintf( [ '\\begin{axis}[\n', cbarOpts, '\n]\n' ] ) ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % get the colormap
  cmap = currentHandles.colormap;

  cbarLength = clim(2) - clim(1);

  m = size( cmap, 1 );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot tiny little badges for the respective colors
  for i=1:m
      badgeColor = rgb2tikzcol( cmap(i,:) );

      switch loc
          case {'NorthOutside','SouthOutside'}
              x1 = clim(1) + cbarLength/m *(i-1);
              x2 = clim(1) + cbarLength/m *i;
              y1 = 0;
              y2 = 1; 
          case {'WestOutside','EastOutside'}
              x1 = 0;
              x2 = 1;
              y1 = clim(1) + cbarLength/m *(i-1);
              y2 = clim(1) + cbarLength/m *i;
      end
      str = [ str, ...
              sprintf( '\\addplot [fill=%s,draw=none] coordinates{ (%g,%g) (%g,%g) (%g,%g) (%g,%g) };\n', ...
                         badgeColor, x1, y1, x2, y1, x2, y2, x1, y2    ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % do _not_ handle colorbar's children

  % close & good-bye
  str = [ str, sprintf('\\end{axis}\n\n') ];

end
% =========================================================================
% *** END FUNCTION drawColorbar
% =========================================================================



% =========================================================================
% *** FUNCTION getColor
% ***
% *** Handles MATLAB colors and makes them available to TikZ.
% *** This includes translation of the color value as well as explicit
% *** definition of the color if it is not available in TikZ by default.
% ***
% *** The variable 'mode' essentially determines what format 'color' can
% *** have. Possible values are (as strings) 'patch' and 'image'.
% ***
% =========================================================================
function xcolor = getColor( handle, color, mode )

  % check if the color is straight given in rgb
  % -- notice that we need the extra NaN test with respect to the QUIRK
  %    below
  if ( isreal(color) && length(color)==3 && ~any(isnan(color)) )

      % everything alright: rgb color here
      xcolor = rgb2tikzcol( color );

  else
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      switch mode
          case 'patch'
              colorindex = patchcolor2colorindex ( color, handle );
          case 'image'
              colorindex = imagecolor2colorindex ( color, handle );
          otherwise
              error( [ 'matlab2tikz:getColor',                          ...
                       'Argument ''mode'' has illegal value ''%s''.' ], ...
                       mode );
      end
      xcolor = colorindex2tikzcol( colorindex );
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  end

end
% =========================================================================
% *** END FUNCTION getColor
% =========================================================================



% =========================================================================
% *** FUNCTION rgb2tikzcol
% ***
% *** This function takes and RGB coded color as input and returns a string
% *** describing the color that can be used in the TikZ file.
% *** It checks if the color is predefined (by xcolor.sty) or if it needs
% *** to be custom defined. It keeps all the self-defined colors in
% *** 'requiredRgbColors' to avoid redundant definitions.
% ***
% =========================================================================
function xcolor = rgb2tikzcol( rgbcol )

  % Remember the color rbgvalues which will need to be redefined.
  % Each row of 'requiredRgbColors' contains the RGB values of a needed
  % color.
  global requiredRgbColors

  [xcolor,errorcode] = rgb2xcolor( rgbcol );
  if errorcode
      if isempty(requiredRgbColors)
          % initialize the matrix
          requiredRgbColors = [];
      end

      % check if the color has appeared before
      n  = size(requiredRgbColors,1);
      for k = 1:n
          if isequal( requiredRgbColors(k,:), rgbcol )
              % take that former color and return
              xcolor = sprintf( 'mycolor%d', k );
              return
          end
      end

      % color not found: have a new one defined
      requiredRgbColors = [ requiredRgbColors; ...
                            rgbcol ];
      xcolor = sprintf( 'mycolor%d', n+1 );
  end

end
% =========================================================================
% *** FUNCTION rgb2tikzcol
% =========================================================================



% =========================================================================
% *** FUNCTION colorindex2tikzcol
% ***
% *** This function takes a color index of the active MATLAB(R) color map
% *** and returns a string describing the color that can be used in the
% *** TikZ file.
% *** 
% *** Does caching, too.
% ***
% =========================================================================
function xcolor = colorindex2tikzcol( colorindex )

  % Remember the color rbgvalues which will need to be redefined.
  % Each row of 'requiredRgbColors' contains the RGB values of a needed
  % color.
  global requiredRgbColors
  global currentHandles

  persistent colorindex_cache

  cmap = currentHandles.colormap;

  rgbcol = cmap( colorindex, : );
  [xcolor,errorcode] = rgb2xcolor( rgbcol );

  if errorcode % non-standard xcolor

      if isempty(requiredRgbColors)
          % initialize the matrix
          requiredRgbColors = [];
      end
      if isempty(colorindex_cache)
          colorindex_cache = zeros( size(cmap,1), 1 );
      end

      % check if the color has appeared before
      if colorindex_cache(colorindex)
          xcolor = sprintf( 'mycolor%d', colorindex_cache(colorindex) );
      else
          % color not found: have a new one defined
          n  = size(requiredRgbColors,1);
          requiredRgbColors = [ requiredRgbColors; ...
                                rgbcol ];
          xcolor = sprintf( 'mycolor%d', n+1 );
          colorindex_cache(colorindex) = n+1;
      end

  end

end
% =========================================================================
% *** FUNCTION colorindex2tikzcol
% =========================================================================



% =========================================================================
% *** FUNCTION patchcolor2colorindex
% ***
% *** Transforms a color of the edge or the face of a patch to a 1x3 rgb 
% *** color vector.
% ***
% =========================================================================
function colorindex = patchcolor2colorindex ( color, patchhandle )

  if ~ischar( color )
      error( 'patchcolor2colorindex:illegalInput', ...
             'Input argument ''color'' not a string.' );
  end

  switch color
      case 'flat'
          % look for CData at different places
          cdata = get( patchhandle, 'CData' );
          if isempty(cdata) || ~isnumeric(cdata)
              c     = get( patchhandle, 'Children' );
              cdata = get( c, 'CData' );
          end

          % QUIRK: With contour plots (not contourf), cdata will be a vector of
          %        equal values, except the last one which is a NaN. To work 
          %        around this oddity, just take the first entry.
          %        With barseries plots, data has been observed to return a
          %        *matrix* with all equal entries.
          cdata = cdata( 1, 1 );
          colorindex = cdata2colorindex( cdata, patchhandle );

      case 'none'
          error( [ 'matlab2tikz:anycolor2rgb',                       ...
                   'Color model ''none'' not allowed here. ',        ...
                   'Make sure this case gets intercepted before.' ] );

      otherwise
          error( [ 'matlab2tikz:anycolor2rgb',                          ...
                   'Don''t know how to handle the color model ''%s''.' ],  ...
                   color );
  end

end
% =========================================================================
% *** END OF FUNCTION patchcolor2colorindex
% =========================================================================



% =========================================================================
% *** FUNCTION imagecolor2colorindex
% ***
% *** Transforms a color in image color format to a 1x3 rgb color vector.
% ***
% =========================================================================
function colorindex = imagecolor2colorindex ( color, imagehandle )

  if ~isnumeric( color ) && length(color)==1
      error( 'imagecolor2colorindex:illegalInput', ...
             'Input argument ''color'' is not a scalar.' );
  end

  % color *must* be a single cdata value already
  colorindex = cdata2colorindex( color, imagehandle );

end
% =========================================================================
% *** END OF FUNCTION imagecolor2colorindex
% =========================================================================



% =========================================================================
% *** FUNCTION cdata2colorindex
% ***
% *** Transforms a color in CData format to a 1x3 rgb color vector.
% ***
% =========================================================================
function colorindex = cdata2colorindex ( cdata, imagehandle )

  global currentHandles;

  if ~isnumeric(cdata)
      error( 'matlab2tikz:cdata2colorindex',                        ...
             [ 'Don''t know how to handle cdata ''',cdata,'''.' ] )
  end

  axeshandle = currentHandles.gca;

  cmap = currentHandles.colormap;

  % -----------------------------------------------------------------------
  % For the following, see, for example, the MATLAB help page for 'image',
  % section 'Image CDataMapping'.
  switch get( imagehandle, 'CDataMapping' )
      case 'scaled'
          % need to scale within clim
          % see MATLAB's manual page for caxis for details
          clim = get( axeshandle, 'clim' );
          m = size( cmap, 1 );
          if cdata<=clim(1)
              colorindex = 1;
          elseif cdata>=clim(2)
              colorindex = m;
          else
              colorindex = fix( (cdata-clim(1))/(clim(2)-clim(1)) *m ) ...
                         + 1;
          end

      case 'direct'
          % direct index
          colorindex = cdata;

      otherwise
            error( [ 'matlab2tikz:anycolor2rgb',                ...
                     'Unknown CDataMapping ''%s''.' ],          ...
                     cdatamapping );
  end
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END OF FUNCTION cdata2colorindex
% =========================================================================



% =========================================================================
% *** FUNCTION getLegendOpts
% =========================================================================
function lOpts = getLegendOpts( handle, isXAxisReversed, isYAxisReversed )

  % Need to check that there's nothing inside visible before we
  % abandon this legend -- an invisible property of the parent just
  % means the legend has no box.
  children = get( handle, 'Children' );
  if ~isVisible( handle ) && ~any( isVisible(children) )
      return
  end

  % read the legend text
  entries = get( handle, 'String' );

  n = length( entries );

  lOpts = cell( 0 );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle legend entries
  if n
      for k=1:n
          % Escape all legend entries to math mode for now.
          % The reason for this is that entries as "cos_x" are legal MATLAB
          % code, but won't compile in (La)TeX except in Math mode.
          entries{k} = [ '$', escapeCharacters(entries{k}), '$' ];
          % Surround the entry by braces if a comma is contained.
          if strfind( entries{k}, ',' )
              entries{k} = [ '{', entries{k}, '}' ];
          end
      end

      lOpts = [ lOpts,                                                  ...
                [ 'legend entries={', collapse(entries,','), '}' ] ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle legend location
  loc  = get( handle, 'Location' );
  dist = 0.03;  % distance to to axes in normalized coordinated
  switch loc
      case 'NorthEast'
          % only append something in this (default) case
          % if any of the axes is reversed
          if isXAxisReversed || isYAxisReversed
              position = [1-dist, 1-dist];
              anchor   = 'north east';
    else
      anchor = [];
          end
      case 'NorthWest'
          position = [dist, 1-dist];
          anchor   = 'north west';
      case 'SouthWest'
          position = [dist, dist];
          anchor   = 'south west';
      case 'SouthEast'
          position = [1-dist, dist];
          anchor   = 'south east';
      case 'North'
          position = [0.5, 1-dist];
          anchor   = 'north';
      case 'East'
          position = [1-dist, 0.5];
          anchor   = 'east';
      case 'South'
          position = [0.5, dist];
          anchor   = 'south';
      case 'West'
          position = [dist, 0.5];
          anchor   = 'west';
      otherwise
          warning( 'matlab2tikz:getLegendOpts',                       ...
                   [ ' Unknown legend location ''',loc,''             ...
                     '. Choosing default.' ] );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  lStyle = cell(0);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % modify for reversed axes and append to lOpts
  if ~isempty(anchor)
      if isXAxisReversed
          position(1) = 1-position(1);
      end
      if isYAxisReversed
          position(2) = 1-position(2);
      end
      lStyle = [ lStyle, ...
                 sprintf( 'at={(%g,%g)}',position ), ...
                 sprintf( 'anchor=%s', anchor ) ];
  end
  
  % If the plot has 'legend boxoff', we have the 'not visible'
  % property, so turn off line and background fill.
  if ( ~isVisible(handle) )
      lStyle=[lStyle, 'fill=none', 'draw=none' ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if ~isempty(lStyle)
      lOpts = [ lOpts, ...
                'legend style={' collapse(lStyle,',') '}' ];
  end

end
% =========================================================================
% *** FUNCTION getLegendOpts
% =========================================================================



% =========================================================================
% *** FUNCTION getTicks
% ***
% *** Return axis tick marks pgfplot style. Nice: Tick lengths and such
% *** details are taken care of by pgfplot.
% ***
% =========================================================================
function [ ticks, tickLabels ] = getTicks( handle )

  global tol
  global matlab2tikzOpts

  xTickMode = get( handle, 'XTickMode' );
  if strcmp(xTickMode,'auto') && ~matlab2tikzOpts.Results.strict
      % If the ticks are set automatically, and strict conversion is
      % not required, then let pgfplots take care of the ticks.
      % In most cases, this looks a lot better anyway.
      ticks.x      = [];
      tickLabels.x = [];
  else % strcmp(xTickMode,'manual') || matlab2tikzOpts.Results.strict
      xTick      = get( handle, 'XTick' );
      xTickLabel = get( handle, 'XTickLabel' );
      isXAxisLog = strcmp( get(handle,'XScale'), 'log' );
      [ticks.x, tickLabels.x] = getAxisTicks( xTick, xTickLabel, isXAxisLog );
  end

  yTickMode = get( handle, 'YTickMode' );
  if strcmp(yTickMode,'auto') && ~matlab2tikzOpts.Results.strict
      % If the ticks are set automatically, and strict conversion is
      % not required, then let pgfplots take care of the ticks.
      % In most cases, this looks a lot better anyway.
      ticks.y      = [];
      tickLabels.y = [];
  else % strcmp(yTickMode,'manual') || matlab2tikzOpts.Results.strict
      yTick      = get( handle, 'YTick' );
      yTickLabel = get( handle, 'YTickLabel' );
      isYAxisLog = strcmp( get(handle,'YScale'), 'log' );
      [ticks.y, tickLabels.y] = getAxisTicks( yTick, yTickLabel, isYAxisLog );
  end

  % -----------------------------------------------------------------------
  % *** FUNCTION getAxisTicks
  % ***
  % *** Converts MATLAB style ticks and tick labels to pgfplots style
  % *** ticks and tick labels (if at all necessary).
  % ***
  % -----------------------------------------------------------------------
  function [ticks, tickLabels] = getAxisTicks( tick, tickLabel, isLogAxis )

    if isempty( tick )
        ticks      = [];
        tickLabels = [];
        return
    end

    % set ticks + labels
    ticks = collapse( num2cell(tick), ',' );

    % sometimes tickLabels are cells, sometimes plain arrays
    % -- unify this to cells
    if ischar( tickLabel )
        tickLabel = strtrim( mat2cell(tickLabel,                        ...
                            ones(size(tickLabel,1),1),size(tickLabel,2)) );
    end

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Check if tickLabels are really necessary (and not already covered by
    % the tick values themselves).
    plotLabelsNecessary = 0;
    
    if isLogAxis
        scalingFactor = 1;
    else
        % When plotting axis, MATLAB might scale the axes by a factor of ten,
        % say 10^n, and plot a 'x 10^k' next to th respective axis. This is
        % common practice when the tick marks are really large or small
        % numbers.
        % Unfortunately, MATLAB doesn't contain the information about the
        % scaling anywhere in the plot, and at the same time the {x,y}TickLabels
        % are given as t*10^k, thus no longer corresponding to the actual
        % value t.
        % Try to find the scaling factor here. This is then used to check
        % whether or not explicit {x,y}TickLabels are really necessary.
        k = find( tick, 1 ); % get an index with non-zero tick value
        s = str2double( tickLabel{k} );
        scalingFactor = tick(k)/s;
        % check if the factor is indeed a power of 10
        S = log10(scalingFactor);
        if abs(round(S)-S) > tol
            scalingFactor = 1;
        end
    end

    for k = 1:min(length(tick),length(tickLabel))
        % Don't use str2num here as then, literal strings as 'pi' get
        % legally transformed into 3.14... and the need for an explicit
        % label will not be recognized. str2double returns a NaN for 'pi'.
        if isLogAxis
            s = 10^( str2double(tickLabel{k}) );
        else
            s = str2double( tickLabel{k} );
        end
        if isnan(s)  ||  abs(tick(k)-s*scalingFactor) > tol
            plotLabelsNecessary = 1;
            break
        end
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if plotLabelsNecessary
        % if the axis is logscaled, MATLAB does not store the labels,
        % but the exponents to 10
        if isLogAxis
            for k = 1:length(tickLabel)
                if isnumeric( tickLabel{k} )
                    str = num2str( tickLabel{k} );
                else
                    str = tickLabel{k};
                end
                tickLabel{k} = sprintf( '$10^{%s}$', str );
            end
        end
        tickLabels = collapse( tickLabel, ',' );
    else
        tickLabels = [];
    end

  end
  % -----------------------------------------------------------------------
  % *** END FUNCTION getAxisTicks
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END FUNCTION getTicks
% =========================================================================



% % =========================================================================
% % *** FUNCTION drawText
% % =========================================================================
% function str = drawText( handle )
% 
%   str = [];
% 
%   if ~isVisible( handle )
%       return
%   end
% 
%   text = get( handle, 'String' );
%   if isempty(strtrim(text))
%       return
%   end
%   
%   str = [ str, sprintf( fid, '%% Draw a text handle\n' ) ];
%   text = regexprep( text, '\', '\\' );
% 
%   position = get( handle, 'Position' );
% 
%   nodeOptions = '';
%   rotate = get( handle, 'Rotation' );
%   if rotate~=0
%       nodeOptions = [nodeOptions, sprintf(',rotate=%.1f',rotate) ];
%   end
% 
%   % we're not really accurate here: stricly speaking, bottom and baseline
%   % alignments are different; not being handled, yet
%   valign = get( handle, 'VerticalAlignment' );
%   switch valign
%       case {'bottom','baseline'}
%               nodeOptions = [nodeOptions, sprintf(',anchor=south') ];
%       case {'top','cap'}
%               nodeOptions = [nodeOptions, sprintf(',anchor=north') ];
%       case 'middle'
%       otherwise
%               warning( 'matlab2tikz:drawText',                         ...
%                   'Don''t know what VerticalAlignment %s means.', valign );
%   end
%   
%   halign = get( handle, 'HorizontalAlignment' );
%   switch halign
%       case 'left'
%               nodeOptions = [nodeOptions, sprintf(',anchor=west') ];
%       case 'right'
%               nodeOptions = [nodeOptions, sprintf(',anchor=east') ];
%       case 'center'
%       otherwise
%           warning( 'matlab2tikz:drawText',                             ...
%                 'Don''t know what HorizontalAlignment %s means.', halign );
%   end
% 
%   str = [ str, ...
%           sprintf( '\\draw (%g,%g) node[%s] {$%s$};\n\n',               ...
%                    position(1), position(2), nodeOptions, text ) ];
% 
%   str = [ str, ...
%           handleAllChildren( handle ) ];
%   
% end
% % =========================================================================
% % *** END OF FUNCTION drawText
% % =========================================================================



% % =========================================================================
% % *** FUNCTION translateText
% % ***
% % *** This function converts MATLAB text strings to valid LaTeX ones.
% % ***
% % =========================================================================
% function newstr = translateText( handle )
% 
%   str = get( handle, 'String' );
% 
%   int = get( handle, 'Interpreter' );
%   switch int
%       case 'none'
%           newstr = str;
%           newstr = strrep( newstr, '''', '\''''' );
%           newstr = strrep( newstr, '%' , '%%'    );
%           newstr = strrep( newstr, '\' , '\\'    );
%       case {'tex','latex'}
%           newstr = str;
%       otherwise
%           error( 'matlab2tikz:translateText',                          ...
%                  'Unknown text interpreter ''%s''.', int )
%   end
% 
% end
% % =========================================================================
% % *** FUNCTION translateText
% % =========================================================================



% =========================================================================
% *** FUNCTION translateLineStyle
% =========================================================================
function tikzLineStyle = translateLineStyle( matlabLineStyle )
  
  if( ~ischar(matlabLineStyle) )
      error( [ ' Function translateLineStyle:',                        ...
               ' Variable matlabLineStyle is not a string.' ] );
  end

  switch ( matlabLineStyle )
      case 'none'
          tikzLineStyle = '';
      case '-'
          tikzLineStyle = 'solid';
      case '--'
          tikzLineStyle = 'dashed';
      case ':'
          tikzLineStyle = 'dotted';
      case '-.'
          tikzLineStyle = 'dash pattern=on 1pt off 3pt on 3pt off 3pt';
      otherwise
          error( [ 'Function translateLineStyle:',                    ...
                   'Unknown matlabLineStyle ''',matlabLineStyle,'''.']);
  end
end
% =========================================================================
% *** END OF FUNCTION translateLineStyle
% =========================================================================



% =========================================================================
% *** FUNCTION rgb2xcolor
% ***
% *** Translates and rgb value to a xcolor literal -- if possible!
% *** If not, it returns the empty string.
% *** This allows for a cleaner output in cases where predefined colors are
% *** being used.
% ***
% *** Take a look at xcolor.sty for the color definitions.
% ***
% =========================================================================
function [xcolorLiteral,errorcode] = rgb2xcolor( rgb )

  if isequal( rgb, [1,0,0] )
      xcolorLiteral = 'red';
      errorcode = 0;
  elseif isequal( rgb, [0,1,0] )
      xcolorLiteral = 'green';
      errorcode = 0;
  elseif isequal( rgb, [0,0,1] )
      xcolorLiteral = 'blue';
      errorcode = 0;
  elseif isequal( rgb, [0.75,0.5,0.25] )
      xcolorLiteral = 'brown';
      errorcode = 0;
  elseif isequal( rgb, [0.75,1,0] )
      xcolorLiteral = 'lime';
      errorcode = 0;
  elseif isequal( rgb, [1,0.5,0] )
      xcolorLiteral = 'orange';
      errorcode = 0;
  elseif isequal( rgb, [1,0.75,0.75] )
      xcolorLiteral = 'pink';
      errorcode = 0;
  elseif isequal( rgb, [0.75,0,0.25] )
      xcolorLiteral = 'pink';
      errorcode = 0;
  elseif isequal( rgb, [0.75,0,0.25] )
      xcolorLiteral = 'purple';
      errorcode = 0;
  elseif isequal( rgb, [0,0.5,0.5] )
      xcolorLiteral = 'teal';
      errorcode = 0;
  elseif isequal( rgb, [0.5,0,0.5] )
      xcolorLiteral = 'violet';
      errorcode = 0;
  elseif isequal( rgb, [0,1,1] )
      xcolorLiteral = 'cyan';
      errorcode = 0;
  elseif isequal( rgb, [1,0,1] )
      xcolorLiteral = 'magenta';
      errorcode = 0;
  elseif isequal( rgb, [1,1,0] )
      xcolorLiteral = 'yellow';
      errorcode = 0;
  elseif isequal( rgb, [0.5,0.5,0] )
      xcolorLiteral = 'olive';
      errorcode = 0;
  elseif isequal( rgb, [0,0,0] )
      xcolorLiteral = 'black';
      errorcode = 0;
  elseif isequal( rgb, [0.5,0.5,0.5] )
      xcolorLiteral = 'gray';
      errorcode = 0;
  elseif isequal( rgb, [0.75,0.75,0.75] )
      xcolorLiteral = 'lightgray';
      errorcode = 0;
  elseif isequal( rgb, [1,1,1] )
      xcolorLiteral = 'white';
      errorcode = 0;
  else
      xcolorLiteral = '';
      errorcode = 1;
  end

end
% =========================================================================
% *** FUNCTION rgb2xcolor
% =========================================================================



% =========================================================================
% *** FUNCTION collapse
% ***
% *** This function collapses a cell of strings to a single string (with a
% *** given delimiter inbetween two strings, if desired).
% ***
% *** Example of usage:
% ***              collapse( cellstr, ',' )
% ***
% =========================================================================
function newstr = collapse( cellstr, delimiter )

  if length(cellstr)<1
     newstr = [];
     return
  end

  if isnumeric( cellstr{1} )
      newstr = my_num2str( cellstr{1} );
  else
      newstr = cellstr{1};
  end

  for k = 2:length( cellstr )
      if isnumeric( cellstr{k} )
          str = my_num2str( cellstr{k} );
      else
          str = cellstr{k};
      end
      newstr = [ newstr, delimiter, str ];
  end

end
% =========================================================================
% *** END FUNCTION collapse
% =========================================================================



% =========================================================================
% *** FUNCTION getAxisLabels
% =========================================================================
function axisLabels = getAxisLabels( handle )

  axisLabels.x = get( get( handle, 'XLabel' ), 'String' );
  axisLabels.y = get( get( handle, 'YLabel' ), 'String' );

end
% =========================================================================
% *** END FUNCTION getAxisLabels
% =========================================================================



% =========================================================================
% *** FUNCTION my_num2str
% ***
% *** Returns a number to a string in a *short* form.
% ***
% =========================================================================
function str = my_num2str( num )

  if ~isnumeric( num )
      error( 'num2str_short: Invalid input.' )
  end

  str = num2str( num, '%g' );

end
% =========================================================================
% *** END FUNCTION my_num2str
% =========================================================================



%  % =========================================================================
%  % *** FUNCTION getAxesScaling
%  % ***
%  % *** Returns the scaling of the axes.
%  % ***
%  % =========================================================================
%  function scaling = getAxesScaling( handle )
%  
%    % arbitrarily chosen: the longer edge of the plot has length 50(mm)
%    % (the other is calculated according to the aspect ratio)
%    longerEdge = 50;
%  
%    xyscaling = daspect;
%  
%    xLim = get( handle, 'XLim' );
%    yLim = get( handle, 'YLim' );
%  
%    % [x,y]length are the actual lengths of the axes in some obscure unit
%    xlength = (xLim(2)-xLim(1)) / xyscaling(1);
%    ylength = (yLim(2)-yLim(1)) / xyscaling(2);
%  
%    if ( xlength>=ylength )
%        baselength = xlength;
%    else
%        baselength = ylength;
%    end
%    
%    % one of the quotients cancels to longerEdge
%    physicalLength.x = longerEdge * xlength / baselength;
%    physicalLength.y = longerEdge * ylength / baselength;
%  
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    % For log-scaled axes, the pgfplot scaling means scaling powers of exp(1)
%    % (see pgfplot manual p. 55). Hence, take the natural logarithm in those
%    % cases.
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    xScale  = get( handle, 'XScale' );
%    yScale  = get( handle, 'YScale' );
%    isXLog = strcmp( xScale, 'log' );
%    isYLog = strcmp( yScale, 'log' );
%    if isXLog
%        q.x = log( xLim(2)/xLim(1) );
%    else
%        q.x = xLim(2) - xLim(1);
%    end
%  
%    if isYLog
%        q.y = log( yLim(2)/yLim(1) );
%    else
%        q.y = yLim(2) - yLim(1);
%    end
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  
%    % finally, set the scaling
%    scaling.x = sprintf( '%gmm', physicalLength.x / q.x );
%    scaling.y = sprintf( '%gmm', physicalLength.y / q.y );
%  
%  
%    % The only way to reliably get the aspect ratio of the axes is
%    % the 'Position' property. Neither 'DataAspectRatio' nor
%    % 'PlotBoxAspectRatio' seem to always  yield the correct ratio.
%    % Critital are for example figures with subplots.
%  %    position = get( handle, 'Position' )
%  %  
%  %    xscaling = 1;
%  %    yscaling = position(4)/position(3) * (xLim(2)-xLim(1))/(yLim(2)-yLim(1));
%  %  
%  %    % normalize: make sure the smaller side is always 1(cm)
%  %    xscaling = xscaling/min(xscaling,yscaling);
%  %    yscaling = yscaling/min(xscaling,yscaling);
%  
%    % well, it seems that MATLAB's very own print functions doesn't preserve
%    % aspect ratio when printing -- we do! hence the difference in the output
%  %    dar = get( handle, 'DataAspectRatio' );
%  %    xyscaling = 1 ./ dar;
%  
%  end
%  % =========================================================================
%  % *** END FUNCTION getAxesScaling
%  % =========================================================================



% =========================================================================
% *** FUNCTION getAxesDimensions
% ***
% *** Returns the physical dimension of the axes.
% ***
% =========================================================================
function dimension = getAxesDimensions( handle )

  daspectmode = get( handle, 'DataAspectRatioMode' );
  position    = get( handle, 'Position' );
  units       = get( handle, 'Units' );

  if strcmp( daspectmode, 'auto' )
      % The plot will use the full size of the current figure.,

      if strcmp( units, 'normalized' )

          % The dpi is needed to associate the size on the screen (in pixels)
          % to the physical size of the plot (on a pdf, for example).
          % Unfortunately, MATLAB doesn't seem to be able to always make a
          % good guess about the current DPI (a bug is filed for this on
          % mathworks.com).
          dpi = get( 0, 'ScreenPixelsPerInch' );

          dimension.unit = 'in';
          figuresize = get( gcf, 'Position' );

          dimension.x = position(3) * figuresize(3) / dpi;
          dimension.y = position(4) * figuresize(4) / dpi;

      else % assume that TikZ knows the unit (in, cm,...)
          dimension.unit = units;
          dimension.x    = position(3);
          dimension.y    = position(4);
      end

  else % strcmp( daspectmode, 'manual' )

      % When daspect was manually set, stick to it.
      % This is achieved here by explicitly determining the x-axis size
      % and adjusting the y-axis size based on this length.

      if strcmp( units, 'normalized' )
          % The dpi is needed to associate the size on the screen (in pixels)
          % to the physical size of the plot (on a pdf, for example).
          % Unfortunately, MATLAB doesn't seem to be able to always make a
          % good guess about the current DPI (a bug is filed for this on
          % mathworks.com).
          dpi = get( 0, 'ScreenPixelsPerInch');

          dimension.unit = 'in';
          figuresize = get( gcf, 'Position' );

          dimension.x = position(3) * figuresize(3) / dpi;

      else % assume that TikZ knows the unit
          dimension.unit = units;
          dimension.x    = position(3);
      end

      % set y-axis length
      xLim        = get ( handle, 'XLim' );
      yLim        = get ( handle, 'YLim' );
      aspectRatio = get ( handle, 'DataAspectRatio' ); % = daspect

      % Actually, we'd have
      %
      %    xlength = (xLim(2)-xLim(1)) / aspectRatio(1);
      %    ylength = (yLim(2)-yLim(1)) / aspectRatio(2);
      %
      % but as xlength is scaled to a fixed 'dimension.x', 'dimension.y'
      % needs to be rescaled accordingly.
      dimension.y = dimension.x                                          ...
                  * aspectRatio(1)    / aspectRatio(2)                   ...
                  * (yLim(2)-yLim(1)) / (xLim(2)-xLim(1));

  end

%    % arbitrarily chosen: maximal width and height (in mm)
%    % this seems to be pretty much what the PDF/EPS print functions in MATLAB
%    % do
%    maxwidth  = 150;
%    maxheight = 120;
%  
%    xyscaling = daspect;
%  %    xyscaling = get( handle, 'DataAspectRatio' )
%  
%    xLim = get( handle, 'XLim' );
%    yLim = get( handle, 'YLim' );
%  
%    % {x,y}length are the actual lengths of the axes in some obscure unit
%    xlength = (xLim(2)-xLim(1)) / xyscaling(1);
%    ylength = (yLim(2)-yLim(1)) / xyscaling(2);
%  
%    if ( xlength/ylength >= maxwidth/maxheight )
%        dim.x = maxwidth;
%        dim.y = maxwidth * ylength / xlength;
%    else
%        dim.x = maxheight * xlength / ylength;
%        dim.y = maxheight;
%    end
%  
%    dimension.x = dim.x;
%    dimension.y = dim.y;


%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    % For log-scaled axes, the pgfplot scaling means scaling powers of exp(1)
%    % (see pgfplot manual p. 55). Hence, take the natural logarithm in those
%    % cases.
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    xScale  = get( handle, 'XScale' );  isXLog = strcmp( xScale, 'log' );
%    yScale  = get( handle, 'YScale' );  isYLog = strcmp( yScale, 'log' );
%    if isXLog
%        q.x = log( xLim(2)/xLim(1) );
%    else
%        q.x = xLim(2) - xLim(1);
%    end
%  
%    if isYLog
%        q.y = log( yLim(2)/yLim(1) );
%    else
%        q.y = yLim(2) - yLim(1);
%    end
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  
%    % finally, set the scaling
%    scaling.x = sprintf( '%gmm', physicalLength.x / q.x );
%    scaling.y = sprintf( '%gmm', physicalLength.y / q.y );


  % The only way to reliably get the aspect ratio of the axes is
  % the 'Position' property. Neither 'DataAspectRatio' nor
  % 'PlotBoxAspectRatio' seem to always  yield the correct ratio.
  % Critital are for example figures with subplots.
%    position = get( handle, 'Position' )
%  
%    xscaling = 1;
%    yscaling = position(4)/position(3) * (xLim(2)-xLim(1))/(yLim(2)-yLim(1));
%  
%    % normalize: make sure the smaller side is always 1(cm)
%    xscaling = xscaling/min(xscaling,yscaling);
%    yscaling = yscaling/min(xscaling,yscaling);

  % well, it seems that MATLAB's very own print functions doesn't preserve
  % aspect ratio when printing -- we do! hence the difference in the output
%    dar = get( handle, 'DataAspectRatio' );
%    xyscaling = 1 ./ dar;

end
% =========================================================================
% *** END FUNCTION getAxesDimensions
% =========================================================================




% =========================================================================
% *** FUNCTION escapeCharacters
% ***
% *** Replaces the single characters %, ', \ by their escaped versions
% *** \'', %%, \\, respectively.
% ***
% =========================================================================
function newstr = escapeCharacters( str )

  newstr = str;
  newstr = strrep( newstr, '''', '\''''' );
  newstr = strrep( newstr, '%' , '%%'    );
  newstr = strrep( newstr, '\' , '\\'    );

end
% =========================================================================
% *** END FUNCTION escapeCharacters
% =========================================================================



% =========================================================================
% *** FUNCTION boxWhere
% ***
% *** Given one or more points in 2D space 'p' and a retangular box given
% *** by 'xLim', 'yLim', this routine determines where the point sits with
% *** respect to the box.
% ***
% *** Possibilities:
% ***      1 ...... inside
% ***      2 ...... outside
% ***     -1 ...... left boundary
% ***     -2 ...... lower boundary
% ***     -3 ...... right boundary
% ***     -4 ...... top boundary
% ***
% *** If a node happens to sit in the corner of a box, return *two* values.
% ***
% =========================================================================
function l = boxWhere( p, xLim, yLim )

  global tol

  n = size(p,1);

  l = cell(n,1);
  for k = 1:n

      if    p(k,1)>xLim(1) && p(k,1)<xLim(2) ...   % inside
         && p(k,2)>yLim(1) && p(k,2)<yLim(2);
          l{k} = 1;
      elseif    p(k,1)<xLim(1) || p(k,1)>xLim(2) ...  % outside
             || p(k,2)<yLim(1) || p(k,2)>yLim(2);
          l{k} = 2;
      else % is on boundary -- but which?

          if abs(p(k,1)-xLim(1)) < tol
              l{k} = [ l{k}, -1 ];
          end
          if abs(p(k,2)-yLim(1)) < tol
              l{k} = [ l{k}, -2 ];
          end
          if abs(p(k,1)-xLim(2)) < tol
              l{k} = [ l{k}, -3 ];
          end
          if abs(p(k,2)-yLim(2)) < tol
              l{k} = [ l{k}, -4 ];
          end

          if isempty(l{k})
              error( 'matlab2tikz:boxWhere',                    ...
                     [ 'Point appears to neither sit inside, ', ...
                       'nor outsize, nor on the boundary of the box.' ] );
          end
      end

  end

end
% =========================================================================
% *** END FUNCTION boxWhere
% =========================================================================



% =========================================================================
% *** FUNCTION commonEntry
% ***
% *** Returns TRUE if and only if the two vectors u, v have at least one
% *** common entry.
% ***
% =========================================================================
function out = commonEntry( u, v )

  out = 0;

  usort = sort(u);
  vsort = sort(v);

  k = 1;
  l = 1;
  while k<=length(u) && l<=length(v)
      if usort(k) < vsort(l)
          k = k+1;
      elseif usort(k) > vsort(l)
          l = l+1;
      else
          out = 1;
          return
      end
  end

end
% =========================================================================
% *** END FUNCTION commonEntry
% =========================================================================



% =========================================================================
% *** FUNCTION isVisible
% ***
% *** Determines whether an object is actually visible or not.
% ***
% =========================================================================
function out = isVisible( handle )

  out = strcmp( get(handle,'Visible'), 'on' );

end
% =========================================================================
% *** END FUNCTION isVisible
% =========================================================================



% =========================================================================
% *** FUNCTION normalized2physical
% ***
% *** Determines the physical width of one unit on the x-axis.
% ***
% =========================================================================
function out = normalized2physical()

  global currentHandles

  fig  = currentHandles.gcf;
  axes = currentHandles.gca;

  % width of the full window
  fpos = get( fig, 'Position' );

  % width of the axes inside the window
  apos = get( axes, 'Position' );

  % width of the x-axis in pixels
  pwidth = fpos(3) * apos(3);

  % width of one unit on the x-axis on pixels
  xLim = get( axes, 'XLim' );
  unitpwidth = pwidth / (xLim(2)-xLim(1));

  dpi = get( 0, 'ScreenPixelsPerInch' );

  out.unit  = 'in';
  out.value = unitpwidth / dpi;

end
% =========================================================================
% *** END FUNCTION normalized2physical
% =========================================================================



% =========================================================================
% *** FUNCTION alignSubPlots
% ***
% *** Returns the alignment options for all the axes enviroments.
% *** The question whether two plots are aligns on left, right, top, or
% *** bottom is answered by looking at the 'Position' property of the
% *** axes object.
% ***
% *** The second output argument `ix` is the order in which the axes
% *** environments need to be created. This is to make sure that plots
% *** which act as a reference are processed first.
% ***
% *** The output vector `alignmentOptions` contains:
% ***     - whether or not it is a reference (.isRef)
% ***     - axes name  (.name), only set if .isRef is true
% ***     - the actual pgfplots options (.opts)
% ***
% *** The routine is quite smart in the sense that it will detect that in
% *** a setup such as
% ***
% ***  [ AXES3 AXES2 ]
% ***  [ AXES1       ]
% ***
% *** 'AXES1' will serve as a reference for AXES2 and AXES3.
% *** It does so by first computing a 'dependency' graph, then traversing
% *** the graph starting from a node (AXES) with maximal connections.
% ***
% *** TODO:
% ***     - diagonal connections a la
% ***              [ AXES1       ]
% ***              [       AXES2 ]
% ***
% =========================================================================
function [alignmentOptions,ix] = alignSubPlots( axesHandles )

  % TODO: fix this function
  % TODO: look for unique IDs of the axes env. which could be returned along
  %       with its properties

  global tol

  n = length(axesHandles);

  % return immediately if nothing is to be aligned
  if n<=1
     alignmentOptions(1).isRef = 0;
     alignmentOptions(1).opts  = cell(0);
     ix = 1;
     return
  end

  % Connectivity matrix of the graph.
  % Contains 0's where the axes environments are not aligned, and
  % positive integers where they are. The integer codes how the axes
  % are aligned (top right:bottom left, and so on).
  C = zeros(n,n);


  % `isRef` tells whether the respective plot acts as a position reference
  % for another plot.
  % TODO: preallocate this
  % Also, gather all the positions.
  axesPos     = zeros(n,4);
  cbarHandles = [];  % indices of color bar handles;
                     % they need to be treated separately
  for k = 1:n
      alignmentOptions(k).isRef = 0;
      alignmentOptions(k).opts  = cell(0);

      % `axesPos(i,:)` contains the x-value of the left and the right axis
      % (indices 1,3) and the y-value of the bottom and top axis
      % (indices 2,4) of plot no. `i`
      if strcmp( get(axesHandles(k),'Tag'), 'Colorbar' )
          cbarHandles = [cbarHandles,k]; % treat color bars later
          continue
      else
          axesPos(k,:) = get( axesHandles(k), 'Position' );
      end

      axesPos(k,3) = axesPos(k,1) + axesPos(k,3);
      axesPos(k,4) = axesPos(k,2) + axesPos(k,4);
  end

  % Unfortunately, MATLAB doesn't seem to exactly align color bars
  % to its parent plot. Hence, some quirking is needed..
  nonCbarHandles              = (1:n);
  nonCbarHandles(cbarHandles) = [];
  for k = cbarHandles
      axesPos(k,:) = correctColorbarPos( axesHandles(k), ...
                                         axesPos(nonCbarHandles,:) );
  end
  % now, the color bars are nicely aligned with the plots

  % Loop over all figures to see if axes are aligned.
  % Look for exactly *one* alignment, also if there might be more.
  %
  % Among all the {x,y}-alignments choose the one with the closest
  % {y,x}-distance. This is important, for example, in situations where
  % there are 3 plots on top of each other:
  % we want no. 2 to align below no. 1, and no. 3 below no. 2
  % (and not no. 1 again).
  %
  % There are eight alignments this algorithm can deal with:
  %
  %    3|             |4
  %  __  _____________   __
  %  -2 |             |  2
  %     |             |
  %     |             |
  %     |             |
  %     |             |
  % -1_ |_____________|  1_
  %
  %   -3|             |-4
  %
  % They are coded in numbers 1 to 8. The matrix C will contain the
  % corresponding code at position (i,j), if plot number i and j are
  % aligned in such a way.
  % If two plots happen to coincide at both left and right axes, for
  % example, only one relation is stored.
  %
  for i = 1:n
      for j = i+1:n

          if abs( axesPos(i,1)-axesPos(j,1) ) < tol;
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % left axes align
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -3;
                  C(j,i) =  3;
              else
                  C(i,j) =  3;
                  C(j,i) = -3;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,1)-axesPos(j,3) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % left axis of `i` aligns with right axis of `j`
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -3;
                  C(j,i) =  4;
              else
                  C(i,j) =  3;
                  C(j,i) = -4;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,3)-axesPos(j,1) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % right axis of `i` aligns with left axis of `j`
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -4;
                  C(j,i) =  3;
              else
                  C(i,j) =  4;
                  C(j,i) = -3;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,3)-axesPos(j,1) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % right axes of `i` and `j` align
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -4;
                  C(j,i) =  4;
              else
                  C(i,j) =  4;
                  C(j,i) = -4;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,2)-axesPos(j,2) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % lower axes of `i` and `j` align
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -1;
                  C(j,i) =  1;
              else
                  C(i,j) =  1;
                  C(j,i) = -1;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,2)-axesPos(j,4) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % lower axis of `i` aligns with upper axis of `j`
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -1;
                  C(j,i) =  2;
              else
                  C(i,j) =  1;
                  C(j,i) = -2;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,4)-axesPos(j,2) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % upper axis of `i` aligns with lower axis of `j`
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -2;
                  C(j,i) =  1;
              else
                  C(i,j) =  2;
                  C(j,i) = -1;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,4)-axesPos(j,4) ) < tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % upper axes of `i` and `j` align
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -2;
                  C(j,i) =  2;
              else
                  C(i,j) =  2;
                  C(j,i) = -2;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          end

      end
  end

  % Now, the matrix C contains all alignment information.
  % If, for any node, there is more than one plot that aligns with it in the
  % same way (e.g., upper left), then pick exactly *one* of them.
  % Take the one that is closest to the correspondig plot.
  for i = 1:n
      for j = 1:n % everything except `i`

          if ~C(i,j)  % don't check of there double "no relation"'s
              continue
          end

          % find doubles, and count C(i,j) in
          doub = find( C(i,j:n)==C(i,j) );

          if length(doub)>1
              % Uh-oh, found doubles:
              % Pick the one with the minimal distance, delete the other
              % relations.
              switch C(i,j)
                  case {1,2}    % all plots sit right of `i`
                      dist = axesPos(doub,1) - axesPos(i,3);
                  case {-1,-2}  % all plots sit left of `i`
                      dist = axesPos(i,1) - axesPos(doub,3);
                  case {3,4}    % all plots sit above `i`
                      dist = axesPos(doub,2) - axesPos(i,4);
                  case {-3,-4}  % all plots sit below `i`
                      dist = axesPos(i,2) - axesPos(doub,4);
                  otherwise
                      error( 'alignSubPlots:uknoCode', ...
                             'Unknown alignment code %d.', C(i,j) );
              end

              [m,idx]   = min( dist );   % `idx` holds the index of the minimum
              doub(idx) = [];            % delete the index from the 'remove list'
              C(i,doub) = 0;
              C(doub,i) = 0;
          end

      end
  end

  % Alright. The matrix `C` now contains exactly the alignment info that
  % we are looking for.

  % Is each axes environment connected to at least one other?
  noConn = find( ~any(C,2) );
  if ~isempty(noConn)
      for k = 1:length(noConn)
          warning( 'alignSubPlots:isoAxes', ...
                    [ 'The axes environment no. %d is not aligned with',...
                      ' any other axes environment and will be plotted',...
                      ' right in the middle.' ], noConn(k) );
      end
  end

  % Now, actually go ahead and process the info to return pgfplots alignment
  % options.

  % tells if the respective axes environment is processed already:
  isProcessed = zeros(n,1);

  % Sort the axes environments by the number of connections they have.
  % That means: start with the plot which has the most connections.
  [s,ix] = sort( sum(C~=0,2), 'descend' );
  for k = 1:n
      setOptionsRecursion( ix(k) );
  end

  % -----------------------------------------------------------------------
  % sets the alignment options for a specific node
  % and passes on the its children
  % -----------------------------------------------------------------------
  function setOptionsRecursion( k, parent )

      % return immediately if is has been processed before
      if isProcessed(k), return, end

      % find the non-zeros elements in the k-th row
      children = find( C(k,:) );

      if any( ~isProcessed(children) ) % are there unprocessed children?
          % then, give these axes a name
          alignmentOptions(k).opts = [ alignmentOptions(k).opts, ...
                                       sprintf( 'name=plot%d', k ) ];
      end

      if nargin==2 % if a parent is given
          % See were this node sits with respect to its parent,
          % and adapt the option accordingly.
          anchor = cornerCode2pgfplotOption( C(k,parent) );
          refPos = cornerCode2pgfplotOption( C(parent,k) );

          % add the option
          alignmentOptions(k).opts = [ alignmentOptions(k).opts, ...
                                       sprintf( 'at=(plot%d.%s), anchor=%s', ...
                                               parent, refPos, anchor ) ];
      end

      isProcessed(k) = 1;

      % recursively loop over all dependent 'child' axes
      for i = children
          setOptionsRecursion( i, k );
      end

  end
  % -----------------------------------------------------------------------


  % -----------------------------------------------------------------------
  % translates the corner code in a real option to pgfplots
  function pgfOpt = cornerCode2pgfplotOption( code )

    switch code
        case 1
            pgfOpt = 'right of south east';
        case 2
            pgfOpt = 'right of north east';
        case 3
            pgfOpt = 'above north west';
        case 4
            pgfOpt = 'above north east';
        case -1
            pgfOpt = 'left of south west';
        case -2
            pgfOpt = 'left of north west';
        case -3
            pgfOpt = 'below south west';
        case -4
            pgfOpt = 'below south east';
        otherwise
            error( 'cornerCode2pgfplotOption:unknRelCode',...
                   'Illegal alignment code %d.', code );
    end

  end
  % -----------------------------------------------------------------------


  % -----------------------------------------------------------------------
  % The handle `colBarHandle` is the handle of a color bar,
  % `axesHandlesPos` a (nx4)-matrix containing the positions of all
  % *non-colorbar* handles.
  % The function looks for the color bar's parent and returnes the position
  % "as it should be".
  function pos = correctColorbarPos( colBarHandle, axesHandlesPos )

    colBarPos    = get( colBarHandle, 'Position' );
    colBarPos(3) = colBarPos(1) + colBarPos(3);
    colBarPos(4) = colBarPos(2) + colBarPos(4);

    loc = get( colBarHandle, 'Location' );

    switch loc
        case { 'North', 'South', 'East', 'West' }
            warning( 'alignSubPlots:getColorbarPos',                     ...
                     'Don''t know how to deal with inner colorbars yet.' );
            return;

        case {'NorthOutside'}
            % scan in `axesHandlesPos` for the handle number that lies
            % directly below colBarHandle
            [mn,idx]  = min( colBarPos(2) ...
                             - axesHandlesPos(axesHandlesPos(:,4)<colBarPos(2),4) );
            pos = [ axesHandlesPos(idx,1), ...
                    colBarPos(2)         , ...
                    axesHandlesPos(idx,3), ...
                    colBarPos(4)           ];

        case {'SouthOutside'}
            % scan in `axesHandlesPos` for the handle number that lies
            % directly above colBarHandle
            [mn,idx]  = min( axesHandlesPos(axesHandlesPos(:,2)>colBarPos(4),2)...
                             - colBarPos(4) );
            pos = [ axesHandlesPos(idx,1), ...
                    colBarPos(2)         , ...
                    axesHandlesPos(idx,3), ...
                    colBarPos(4)           ];

        case {'EastOutside'}
            % scan in `axesHandlesPos` for the handle number that lies
            % directly left of colBarHandle
            [mn,idx]  = min( colBarPos(1) ...
                             - axesHandlesPos(axesHandlesPos(:,3)<colBarPos(1),3) );
            pos = [ colBarPos(1),          ...
                    axesHandlesPos(idx,2), ...
                    colBarPos(3),          ...
                    axesHandlesPos(idx,4)  ];

        case {'WestOutside'}
            % scan in `axesHandlesPos` for the handle number that lies
            % directly right of colBarHandle
            [mn,idx]  = min( axesHandlesPos(axesHandlesPos(:,1)>colBarPos(3),1) ...
                             - colBarPos(3)  );
            pos = [ colBarPos(1),          ...
                    axesHandlesPos(idx,2), ...
                    colBarPos(3),          ...
                    axesHandlesPos(idx,4)  ];

        otherwise
            error( 'alignSubPlots:getColorbarPos',    ...
                   'Unknown ''Location'' %s.', loc  )
    end

  end
  % -----------------------------------------------------------------------

end
% =========================================================================
% *** END FUNCTION alignSubPlots
% =========================================================================