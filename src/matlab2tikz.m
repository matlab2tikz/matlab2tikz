function matlab2tikz( varargin )
%MATLAB2TIKZ    Save figure in native LaTeX (TikZ/Pgfplots).
%   MATLAB2TIKZ() saves the current figure as LaTeX file.
%   MATLAB2TIKZ comes with several options that can be combined at will.
%
%   MATLAB2TIKZ(FILENAME,...) or MATLAB2TIKZ('filename',FILENAME,...)
%   stores the LaTeX code in FILENAME.
%
%   MATLAB2TIKZ('filehandle',FILEHANDLE,...) stores the LaTeX code in the file
%   referenced by FILEHANDLE. (default: [])
%
%   MATLAB2TIKZ('figurehandle',FIGUREHANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   MATLAB2TIKZ('colormap',DOUBLE,...) explicitly specifies the colormap to be
%   used. (default: current color map)
%
%   MATLAB2TIKZ('strict',BOOL,...) tells MATLAB2TIKZ to adhere to MATLAB(R)
%   conventions wherever there is room for relaxation. (default: FALSE)
%
%   MATLAB2TIKZ('showInfo',BOOL,...) turns informational output on or off.
%   (default: true)
%
%   MATLAB2TIKZ('showWarning',BOOL,...) turns warnings on or off.
%   (default: true)
%
%   MATLAB2TIKZ('imagesAsPng',BOOL,...) stores MATLAB(R) images as (lossless)
%   PNG files. This is more efficient than storing the image color data as TikZ
%   matrix. (default: true)
%
%   MATLAB2TIKZ('relativePngPath',CHAR, ...) tells MATLAB2TIKZ to use the given
%   path to follow the PNG file. If LaTeX source and PNG file will reside in
%   the same directory, this can be set to '.'. (default: [])
%
%   MATLAB2TIKZ('height',CHAR,...) sets the height of the image. This can be any
%   LaTeX-compatible length, e.g., '3in' or '5cm' or '0.5\textwidth'.
%   If unspecified, MATLAB2TIKZ tries to make a reasonable guess.
%
%   MATLAB2TIKZ('width',CHAR,...) sets the width of the image.
%   If unspecified, MATLAB2TIKZ tries to make a reasonable guess.
%
%   MATLAB2TIKZ('minimumPointsDistance',DOUBLE,...) gives a minimum distance at
%   which two nodes are considered different. This can help with plots that
%   contain a large amount of data points not all of which need to be plotted.
%   (default: 0.0)
%
%   MATLAB2TIKZ('extraAxisOptions',CHAR or CELLCHAR,...) explicitly adds extra
%   options to the Pgfplots axis environment. (default: [])
%
%   MATLAB2TIKZ('extraTikzpictureSettings',CHAR or CELLCHAR,...)
%   explicitly adds extra settings to the tikzpicture environment. (default: [])
%
%   MATLAB2TIKZ('encoding',CHAR,...) sets the encoding of the output file.
%
%   MATLAB2TIKZ('parseStrings',BOOL,...) determines whether title, axes labels
%   and the like are parsed into LaTeX by MATLAB2TIKZ's parser.
%   If you want greater flexibility, set this to false and use straight LaTeX
%   for your labels. (default: true)
%
%   MATLAB2TIKZ('parseStringsAsMath',BOOL,...) determines whether to use TeX's
%   math mode for more characters (such as operators and figures).
%   (default: false)
%
%   MATLAB2TIKZ('interpretTickLabelsAsTex',BOOL,...) determines whether to
%   interpret tick labels as TeX. MATLAB(R) doesn't do that by default.
%   (default: false)
%
%   MATLAB2TIKZ('tikzFileComment',CHAR,...) adds a custom comment to the header
%   of the output file.
%
%   Example
%      x = -pi:pi/10:pi;
%      y = tan(sin(x)) - sin(tan(x));
%      plot(x,y,'--rs');
%      matlab2tikz( 'myfile.tex' );
%

%   Copyright (c) 2008--2012, Nico Schlömer <nico.schloemer@gmail.com>
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the distribution
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.

% *** -------
% ***  Note:
% *** -------
% ***    This program is a rewrite on Paul Wagenaars' Matfig2PGF which
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
% *** TODO: * Replace slow strcat() in loops with Julien Ridoux' idea.
% ***         (See function plotLine().)
% ***
% =========================================================================
  % Check if we are in MATLAB or Octave.
  m2t.env = getEnvironment();
  warningMessage = [ '\n',...
                     '================================================================================\n\n', ...
                     '  matlab2tikz is tested and developed on   %s   and\n', ...
                     '  later versions of %s.\n', ...
                     '  This script may still be able to handle your plots, but if you\n', ...
                     '  hit a bug, please consider upgrading your environment first.\n', ...
                     '\n', ...
                     '  Every time you submit a bug report with a deprecated environment...\n', ...
                     '  God kills a kitten.\n', ...
                     '\n', ...
                     '================================================================================' ];

  envVersion = findEnvironmentVersion( m2t.env );
  if isempty( envVersion )
      warning( 'Could not determine enviroment version. Continuing and hoping for the best.' );
  else
      switch m2t.env
          case 'MATLAB'
              % Make sure we're running MATLAB >= 2008b.
              if isVersionBelow(m2t.env, envVersion, [7, 7])
                  warning(warningMessage, 'MATLAB 2008b', 'MATLAB');
              end
          case 'Octave'
              % Make sure we're running Octave >= 3.4.0.
              if isVersionBelow(m2t.env, envVersion, [3, 4, 0])
                  warning(warningMessage, 'Octave 3.4.0', 'Octave');
              end
          otherwise
              error( 'Unknown environment. Need MATLAB(R) or Octave.' )
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  m2t.cmdOpts = [];

  m2t.currentHandles = [];

  m2t.name = 'matlab2tikz';
  m2t.version = '0.2.1';
  m2t.author = 'Nico Schlömer';
  m2t.authorEmail = 'nico.schloemer@gmail.com';
  m2t.years = '2008--2012';
  m2t.website = 'http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz';

  m2t.tikzOptions = cell(0); % for the arrow style -- TODO: see if we can get this removed
  m2t.tol = 1.0e-15; % global round-off tolerance;
                     % used, for example, in equality test for doubles
  m2t.relativePngPath = [];

  % The following color RBG-values which will need to be defined.
  % 'extraRgbColorNames' contains their designated names, 'extraRgbColorSpecs'
  % their specifications.
  m2t.extraRgbColorSpecs = cell(0);
  m2t.extraRgbColorNames = cell(0);

  % the actual contents of the TikZ file go here
  m2t.content = structWithCell( 'name',     [], ...
                                'comment',  [], ...
                                'options',  cell(0), ...
                                'content',  cell(0), ...
                                'children', cell(0)  ...
                              );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % scan the options
  m2t.cmdOpts = matlab2tikzInputParser;
  m2t.cmdOpts = m2t.cmdOpts.addOptional( m2t.cmdOpts, ...
                                         'filename', ...
                                         [], ...
                                         @(x) filenameValidation(x,m2t.cmdOpts) );

  % possibility to give a file handle as argument
  m2t.cmdOpts = m2t.cmdOpts.addOptional( m2t.cmdOpts, 'filehandle', [], @filehandleValidation );

  % explicitly specify which figure to use
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'figurehandle', gcf, @ishandle );
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'colormap', [], @isnumeric );

  % whether to strictly stick to the default MATLAB plot appearance:
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'strict', false, @islogical );

  % deprecated parameter -- keep it to allow warning further down
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'silent', false, @islogical );

  % don't print warning messages
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'showInfo', true, @islogical );

  % don't print informational messages
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'showWarnings', true, @islogical );

  % Whether to save images in PNG format or to natively draw filled squares
  % using TikZ itself.
  % Default it PNG.
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'imagesAsPng', true, @islogical );
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'relativePngPath', [], @ischar );

  % width and height of the figure
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'height', [], @ischar );
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'width' , [], @ischar );

  % minimum distance for two points to be plotted separately
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'minimumPointsDistance', 0.0, @isnumeric );

  % extra axis options
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'extraAxisOptions', {}, @isCellOrChar );

  % extra tikzpicture settings
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'extraTikzpictureSettings', {}, @isCellOrChar );

  % file encoding
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'encoding' , '', @ischar );

  % deprecated parameter -- keep it to allow warning further down
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'mathmode', true, @islogical );

  % By default strings like axis labels are parsed to match the appearance of
  % strings as closely as possible to that generated by MATLAB.
  % If the user wants to have particular strings in the matlab2tikz output that
  % can't be generated in MATLAB, they can disable string parsing. In that case
  % all strings are piped literally to the LaTeX output.
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'parseStrings', true, @islogical );

  % In addition to regular string parsing, an additional stage can be enabled
  % which uses TeX's math mode for more characters like figures and operators.
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'parseStringsAsMath', false, @islogical );

  % As opposed to titles, axis labels and such, MATLAB(R) does not interpret tick
  % labels as TeX. matlab2tikz retains this behavior, but if it is desired to
  % interpret the tick labels as TeX, set this option to true.
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'interpretTickLabelsAsTex', false, @islogical );

  % Allow a string to be added to the header of the generated TikZ file.
  m2t.cmdOpts = m2t.cmdOpts.addParamValue( m2t.cmdOpts, 'tikzFileComment', '', @ischar );

  m2t.cmdOpts = m2t.cmdOpts.parse( m2t.cmdOpts, varargin{:} );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % warn for deprecated options
  deprecatedParameter(m2t,'silent'  ,'showInfo'    ,'showWarnings');
  deprecatedParameter(m2t,'mathmode','parseStrings','parseStringsAsMath');

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % inform users of potentially dangerous options
  if m2t.cmdOpts.Results.parseStringsAsMath
      userInfo( m2t, [ '\n==========================================================================\n', ...
                       'You are using the parameter ''parseStringsAsMath''.\n', ...
                       'This may produce undesirable string output. For full control over output\n', ...
                       'strings please set the parameter ''parseStrings'' to false.\n', ...
                       '==========================================================================' ] );
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % add global elements
  m2t.currentHandles.gcf = m2t.cmdOpts.Results.figurehandle;
  if m2t.cmdOpts.Results.colormap
      m2t.currentHandles.colormap = m2t.cmdOpts.Results.colormap;
  else
      m2t.currentHandles.colormap = get(m2t.currentHandles.gcf, 'colormap');
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle output file handle/file name
  if ~isempty( m2t.cmdOpts.Results.filehandle )
      fid     = m2t.cmdOpts.Results.filehandle;
      fileWasOpen = 1;
      if ~isempty(m2t.cmdOpts.Results.filename)
          userWarning( m2t, ...
                       'File handle AND file name for output given. File handle used, file name discarded.')
      end
  else
      fileWasOpen = 0;
      % set filename
      if ~isempty(m2t.cmdOpts.Results.filename)
          filename = m2t.cmdOpts.Results.filename;
      else
          filename = uiputfile( {'*.tex'; '*.*'}, ...
                                'Save File' );
      end

      % open the file for writing
      if strcmp( m2t.env, 'MATLAB' );
          fid = fopen( filename, ...
                       'w', ...
                       'native', ...
                       m2t.cmdOpts.Results.encoding ...
                     );
      elseif strcmp( m2t.env, 'Octave' );
          fid = fopen( filename, 'w' );
      else
          error( 'Unknown environment. Need MATLAB(R) or Octave.' )
      end

      if fid == -1
          error( 'matlab2tikz:fileOpenError', ...
                 'Unable to open file ''%s'' for writing.', ...
                 filename );
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  m2t.tikzFileName = fopen( fid );

  % By default, reference the PNG (if required) from the TikZ file
  % as the file path of the TikZ file itself. This works if the MATLAB script
  % is executed in the same folder where the TeX file sits.
  if isempty(m2t.cmdOpts.Results.relativePngPath)
      m2t.relativePngPath = fileparts(m2t.tikzFileName);
  else
      m2t.relativePngPath = m2t.cmdOpts.Results.relativePngPath;
  end

  userInfo(m2t, ['(To disable info messages, pass [''showInfo'', false] to matlab2tikz.)\n', ...
                 '(For all other options, type ''help matlab2tikz''.)\n']);

  userInfo( m2t, '\nThis is %s v%s.\n', m2t.name, m2t.version)

  % Conditionally check for a new matlab2tikz version.
  updateNotePrinted = false;
  if m2t.cmdOpts.Results.showInfo
      try
          html = urlread([m2t.website, '/all_files']);
      catch
          % Couldn't load the URL -- never mind.
          html = [];
      end
      if ~isempty(html)
          % Extract the version information from the html.
          m2tMostRecent = regexp(html, 'matlab2tikz-(\d+\.\d+\.\d+)', 'tokens');
          if ~isempty(m2tMostRecent)
              if isVersionBelow(m2t.env, m2t.version, m2tMostRecent{1}{1})
                  userInfo(m2t, '**********************************************\n');
                  userInfo(m2t, 'New version available! (%s)\n', m2tMostRecent{1}{1});
                  userInfo(m2t, '**********************************************\n');
                  userInfo(m2t, 'Get it now from\n   %s', m2t.website);
                  updateNotePrinted = true;
              end
          end
      end
  end
  if ~updateNotePrinted
      % print some version info to the screen
      userInfo( m2t, [ 'The latest updates can be retrieved from\n   %s' ], m2t.website );
  end

  % print some version info to the screen
  userInfo( m2t, 'where you can also make suggestions and rate %s.\n', m2t.name );
  userInfo( m2t, ['For usage instructions, bug reports, the latest development versions and more, see\n',...
                  '   https://github.com/nschloe/matlab2tikz,\n', ...
                  '   https://github.com/nschloe/matlab2tikz/wiki,\n', ...
                  '   https://github.com/nschloe/matlab2tikz/issues.\n']);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Save the figure as pgf to file -- here's where the work happens
  saveToFile( m2t, fid, fileWasOpen );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% validates the optional argument 'filename' to not be another
% keyword
function l = filenameValidation( x, p )
  l = ischar(x) && ~any( strcmp(x,p.Parameters) );
end
% =========================================================================
% validates the optional argument 'filehandle' to be the handle of
% an open file
function l = filehandleValidation( x, p )
    l = isnumeric(x) && any( x==fopen('all') );
end
% =========================================================================
function l = isCellOrChar( x, p )
    l = iscell(x) || ischar(x);
end
% =========================================================================
function deprecatedParameter(m2t, oldParameter, varargin)
  if any( ismember( m2t.cmdOpts.Parameters, oldParameter ) )
      switch numel(varargin)
          case 0
              replacements = '';
          case 1
              replacements = ['''' varargin{1} ''''];
          otherwise
              replacements = deblank(sprintf('''%s'' and ',varargin{:}));
              replacements = regexprep(replacements,' and$','');
      end
      if ~isempty(replacements)
          replacements = sprintf('From now on, please use %s to control the output.\n',replacements);
      end

      message = ['\n===============================================================================\n', ...
                  'You are using the deprecated parameter ''%s''.\n', ...
                  '%s', ...
                  '===============================================================================' ];
      warning('matlab2tikz:deprecatedParameter', ...
                message, oldParameter, replacements);
  end
end
% =========================================================================
function m2t = saveToFile( m2t, fid, fileWasOpen )
  % Save the figure as TikZ to a file.
  % All other routines are called from here.

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % enter plot recursion --
  % It is important to turn hidden handles on, as visible lines (such as the
  % axes in polar plots, for example), are otherwise hidden from their
  % parental handles (and can hence not be discovered by matlab2tikz).
  % With ShowHiddenHandles 'on', there is no escape. :)
  set( 0, 'ShowHiddenHandles', 'on' );

  % get all axes handles
  fh          = m2t.currentHandles.gcf;
  axesHandles = findobj( fh, 'type', 'axes' );

  % Find all legend handles. This is MATLAB-only.
  legendHandleIdx = strcmp( get(axesHandles,'Tag'), 'legend' );
  m2t.legendHandles = axesHandles(legendHandleIdx);
  % Remove all legend handles as they are treated separately.
  axesHandles = axesHandles(~legendHandleIdx);

  % Turn around the handles vector to make sure that plots that appeared
  % first also appear first in the vector. This has effects on the alignment
  % and the order in which the plots appear in the final TikZ file.
  % In fact, this is not really important but makes things more 'natural'.
  axesHandles = axesHandles(end:-1:1);

  % find alignments
  [visibleAxesHandles,alignmentOptions,ix] = alignSubPlots( m2t, axesHandles );
  m2t.axesContainers = {};
  for k = 1:length(visibleAxesHandles)
      m2t = drawAxes( m2t, visibleAxesHandles(ix(k)), alignmentOptions(ix(k)) );
  end
  % Add all axes containers to the file contents.
  for axesContainer =  m2t.axesContainers
      m2t.content = addChildren( m2t.content, axesContainer );
  end

  set( 0, 'ShowHiddenHandles', 'off' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % actually print the stuff
  m2t.content.comment = sprintf( [ 'This file was created by %s v%s.\n', ...
                                   'Copyright (c) %s, %s <%s>\n', ...
                                   'All rights reserved.\n' ], ...
                                   m2t.name, m2t.version, ...
                                   m2t.years, m2t.author, m2t.authorEmail );

  if ~m2t.cmdOpts.Results.silent && m2t.cmdOpts.Results.showInfo
      % disable this info if silent=true or showInfo=false
      m2t.content.comment = [ m2t.content.comment, ...
                              sprintf( [ '\n',...
                                         'The latest updates can be retrieved from\n', ...
                                         '  %s\n', ...
                                         'where you can also make suggestions and rate %s.\n' ], ...
                                       m2t.website, m2t.name  ) ...
                            ];
  end

  % Add custom comment.
  m2t.content.comment = [ m2t.content.comment, ...
                          sprintf( '\n%s\n', m2t.cmdOpts.Results.tikzFileComment )
                        ];

  m2t.content.name = 'tikzpicture';

  m2t.content.options = { m2t.content.options{:}, m2t.tikzOptions{:} };

  % Add custom TikZ options if any given.
  if ~isempty( m2t.cmdOpts.Results.extraTikzpictureSettings )
      if ischar(m2t.cmdOpts.Results.extraTikzpictureSettings)
          m2t.cmdOpts.Results.extraTikzpictureSettings = ...
             {m2t.cmdOpts.Results.extraTikzpictureSettings};
      end
      for k = 1:length(m2t.cmdOpts.Results.extraTikzpictureSettings)
          m2t.content = append( m2t.content, ...
                                sprintf('%s\n', m2t.cmdOpts.Results.extraTikzpictureSettings{k}) ...
                              );
      end
  end

  % Don't forget to define the colors.
  if ~isempty(m2t.extraRgbColorNames)
      m2t.content.colors = sprintf('\n%% defining custom colors\n');
      for k = 1:length(m2t.extraRgbColorNames)
          m2t.content.colors = [m2t.content.colors sprintf('\\definecolor{%s}{rgb}{%.15g,%.15g,%.15g}\n', ...
                                        m2t.extraRgbColorNames{k}', m2t.extraRgbColorSpecs{k})];
      end
      m2t.content.colors = [m2t.content.colors sprintf('\n')];
  end

  % finally print it to the file
  printAll( m2t.content, fid );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % close the file if necessary
  if ~fileWasOpen
      fclose( fid );
  end
end
% =========================================================================
function [ m2t, pgfEnvironments ] = handleAllChildren( m2t, handle )
  % Draw all children of a graphics object (if they need to be drawn).

  children = get( handle, 'Children' );

  % prepare cell array of pgfEnvironments
  pgfEnvironments = cell(length(children),1);

  % It's important that we go from back to front here, as this is
  % how MATLAB does it, too. Significant for patch (contour) plots,
  % and the order of plotting the colored patches.

  % initialize counter to store environments in reverse order so that it's
  % consistent with the comment above.
  n = 1;
  for i = length(children):-1:1
      child = children(i);
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % First of all, check if 'child' is referenced in a legend.
      % If yes, some plot types may want to add stuff (e.g. 'forget plot').
      % Add '\addlegendentry{...}' then after the plot.
      legendString = [];
      if ~isempty(m2t.legendHandles)
          % Check if current handle is referenced in a legend.
          ud = get(m2t.legendHandles(1), 'UserData');
          % Octave names the structure member in singular and not in plural.
          % Do not distinguish between Octave and Matlab to not break when
          % Octave adapts the naming.
          if ~isfield('ud', 'handles')
              ud.handles = ud.handle;
          end

          k = find(child == ud.handles);
          if isempty(k)
              % Lines of error bar plots are not referenced directly in legends
              % as an error bars plot contains two "lines": the data and the
              % deviations. Here, the legends refer to the specgraph.errorbarseries
              % handle which is 'Parent' to the line handle.
              k = find(get(child,'Parent') == ud.handles);
          end
          if ~isempty(k)
              % Legend entry found. Add it to the plot.
              switch m2t.env
                  case 'MATLAB'
                    interpreter = get( m2t.legendHandles(1), 'Interpreter' );
                    legendString = ud.lstrings(k);
                  case 'Octave'
                      % TODO: The MATLAB way to acquire the interpreter for legend
                      %       entries always yields 'none' even if Octave (or gnuplot)
                      %       itself interprets the strings as 'tex' strings. Maybe the
                      %       value is stored somewhere else or maybe Octave doesn't
                      %       store it at all. For now the quick'n'dirty solution is to
                      %       forcefully set the interpreter for all legend entries to
                      %       'tex' -- which is the default value anyway.
                      interpreter = 'tex';
                      % In Octave there is no ud.lstrings property, so use this
                      % approach to get the legend's content.
                      legendString = get(child, 'displayname');
                  otherwise
                      error( 'Unknown environment. Need MATLAB(R) or Octave.' )
              end
              % The legend finding logic above generates some empty legends in
              % addition to the correct legend for Octave.
              % As this confuses TikZ, do not print empty legends.
              if ~isempty(legendString)
                  legendString = [ '\addlegendentry{', prettyPrint( m2t, legendString, interpreter ), sprintf('};\n\n')];
                  % insert it below after plotting the data
              end
          end
      end
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      switch get( child, 'Type' )
          % 'axes' environments are treated separately.

          case 'line'
              [m2t, env] = drawLine( m2t, child, ~isempty(legendString) );

          case 'patch'
              [m2t, env] = drawPatch( m2t, child );

          case 'image'
              [m2t, env] = drawImage( m2t, child );

          case 'hggroup'
              [m2t, env] = drawHggroup( m2t, child );

          case 'hgtransform'
              % don't handle those directly but descend to its children
              % (which could for example be patch handles)
              [m2t, env] = handleAllChildren( m2t, child );

          case 'surface'
              [m2t, env] = drawSurface( m2t, child );

          case 'text'
              [m2t, env] = drawText( m2t, child );

          case 'rectangle'
              [m2t, env] = drawRectangle( m2t, child );

          case { 'uitoolbar', 'uimenu', 'uicontextmenu', 'uitoggletool',...
                 'uitogglesplittool', 'uipushtool', 'hgjavacomponent'}
              % don't to anything for these handles and its children
              env = [];

          otherwise
              error( 'matlab2tikz:handleAllChildren',                 ...
                     'I don''t know how to handle this object: %s\n', ...
                                                       get(child,'Type') );

      end

      % add legend after the plot data
      if ~isempty(legendString)
          env = [env, legendString];
      end

      % append the environment
      pgfEnvironments{n} = env;
      n = n+1;
  end

end
% =========================================================================
function m2t = drawAxes( m2t, handle, alignmentOptions )
  % Input arguments:
  %    handle.................The axes environment handle.
  %    alignmentOptions.......The alignment options as defined in the
  %                           function 'alignSubPlots()'.
  %                           This argument is optional.

  % Handle special cases.
  % MATLAB(R) uses 'Tag', Octave 'tag' for their tags. :/
  tagKeyword      = switchMatOct(m2t,'Tag','tag');
  colorbarKeyword = switchMatOct(m2t,'Colorbar','colorbar');
  switch get( handle, tagKeyword )
      case colorbarKeyword
          % Handle a colorbar separately.
          m2t.axesContainers{end}.options{end+1} = ...
              matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap);
          m2t.axesContainers{end}.options = ...
              [m2t.axesContainers{end}.options,  getColorbarOptions(m2t, handle)];
          % Note that m2t.currentHandles.gca does *not* get updated.
          % Within drawColorbar(), m2t.currentHandles.gca is assumed to point
          % to the parent axes.
          %[m2t, m2t.axesContainers{end}] = drawColorbar( m2t, handle, alignmentOptions );
          return
      case 'legend'
          % Don't handle the legend here, but further below in the 'axis'
          % environment.
          % In MATLAB, an axes environment and its corresponding legend are
          % children of the same figure (siblings), while in pgfplots, the
          % \legend (or \addlegendentry) command must appear within the axis
          % environment.
          return
      otherwise
          % continue as usual
  end

  % Initialize empty enviroment.
  % Use a struct instead of a custom subclass of hgsetget (which would
  % facilitate writing clean code) as structs are more portable (old MATLAB(R)
  % versions, GNU Octave).
  m2t.axesContainers{end+1} = structWithCell( 'name',     [], ...
                                              'comment',  [], ...
                                              'options',  cell(0), ...
                                              'content',  cell(0), ...
                                              'children', cell(0)  ...
                                             );

  % update gca
  m2t.currentHandles.gca = handle;

  % get the view angle
  view = get( handle, 'View' );
  isViewFromAbove = all(view == [0,90]);

  % Unconditionally add the view specfication. This is unnecessary for
  % 2D plots as both MATLAB's and Pgfplots' default is [0,90] here.
  % At this point, it's hard to say whether or not we're dealing with a 3D
  % plot though.
  m2t.axesContainers{end}.options{end+1} = ...
      sprintf('view={%.15g}{%.15g}', view);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get the axes dimensions
  dim = getAxesDimensions( handle, ...
                           m2t.cmdOpts.Results.width, ...
                           m2t.cmdOpts.Results.height );
  % set the width
  if dim.x.unit(1)=='\' && dim.x.value==1.0
      % only return \figurewidth instead of 1.0\figurewidth
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf('width=%s', dim.x.unit);
  else
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf('width=%.15g%s', dim.x.value, dim.x.unit);
  end
  if dim.y.unit(1)=='\' && dim.y.value==1.0
      % only return \figureheight instead of 1.0\figureheight
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf('height=%s', dim.y.unit);
  else
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf('height=%.15g%s', dim.y.value, dim.y.unit);
  end

  % Add the physical dimension of one unit of length in the coordinate system.
  % This is used later on to translate lenghts to physical units where
  % necessary (e.g., in bar plots).
  m2t.unitlength.x.unit = dim.x.unit;
  xLim = get( m2t.currentHandles.gca, 'XLim' );
  m2t.unitlength.x.value = dim.x.value / (xLim(2)-xLim(1));
  m2t.unitlength.y.unit = dim.y.unit;
  yLim = get( m2t.currentHandles.gca, 'YLim' );
  m2t.unitlength.y.value = dim.y.value / (yLim(2)-yLim(1));
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % the following is general MATLAB behavior
  m2t.axesContainers{end}.options{end+1} = 'scale only axis';
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Get other axis options (ticks, axis color, label,...).
  % This is set here such that the axis orientation indicator in m2t is set
  % before -- if ~isVisible(handle) -- the handle's children are called.
  [ m2t, hasXGrid ] = getAxisOptions( m2t, handle, 'x' );
  [ m2t, hasYGrid ] = getAxisOptions( m2t, handle, 'y' );
  if ~isViewFromAbove
      [ m2t, hasZGrid ] = getAxisOptions( m2t, handle, 'z' );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ~isVisible( handle )
      % An invisible axes container *can* have visible children, so don't
      % immediately bail out here.
      c = get(handle,'Children');
      for k = 1:length(c)
          if isVisible( c(k) )
              % If the axes contain something that's visible, add an invisible
              % axes pair.
              m2t.axesContainers{end}.name = 'axis';
              m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
                                                 'hide x axis', 'hide y axis'};
              m2t.axesContainers{end}.comment = getTag( handle );
              break;
          end
      end
      % recurse into the children of this environment
      [ m2t, childrenEnvs ] = handleAllChildren( m2t, handle );
      m2t.axesContainers{end} = addChildren( m2t.axesContainers{end}, childrenEnvs );
      return
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if strcmp( get( handle, 'Box' ), 'off' )
      m2t.axesContainers{end}.options{end+1} = 'axis lines=left';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get scales
  isXLog = strcmp( get( handle, 'XScale' ), 'log' );
  isYLog = strcmp( get( handle, 'YScale' ), 'log' );
  if ~isViewFromAbove % 3D plot
      m2t.axesContainers{end}.name = 'axis';
  elseif  ~isXLog && ~isYLog
      m2t.axesContainers{end}.name = 'axis';
  elseif isXLog && ~isYLog
      m2t.axesContainers{end}.name = 'semilogxaxis';
  elseif ~isXLog && isYLog
      m2t.axesContainers{end}.name = 'semilogyaxis';
  else
      m2t.axesContainers{end}.name = 'loglogaxis';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set alignment options
  if ~isempty(alignmentOptions.opts)
      m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:},...
                                          alignmentOptions.opts{:}};
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % background color
  backgroundColor = get( handle, 'Color' );
  if ~strcmp( backgroundColor, 'none' )
      [ m2t, col ] = getColor( m2t, handle, backgroundColor, 'patch' );
      if ~strcmp( col, 'white' )
          m2t.axesContainers{end}.options{end+1} = ...
              sprintf( 'axis background/.style={fill=%s}', col);
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % title
  title = get( get( handle, 'Title' ), 'String' );
  if ~isempty(title)
      titleText = sprintf( '%s', title );
      titleInterpreter = get( get( handle, 'Title' ), 'Interpreter' );
      titleText = prettyPrint( m2t, titleText, titleInterpreter );
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf('title={%s}', titleText);
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % For double axes pairs, unconditionally put the ordinate left for the
  % first one, right for the second one.
  if alignmentOptions.isElderTwin
      m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
                                          'axis y line*=left', 'axis x line*=bottom'};
  elseif alignmentOptions.isYoungerTwin
      m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
                                          'axis y line*=right', 'axis x line*=top'};
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % grid line style
  if hasXGrid || hasYGrid || (exist('hasZGrid','var') && hasZGrid )
      matlabGridLineStyle = get( handle, 'GridLineStyle' );
      % Take over the grid line style in any case when in strict mode.
      % If not, don't add anything in case of default line grid line style
      % and effectively take pgfplots' default.
      defaultMatlabGridLineStyle = ':';
      if m2t.cmdOpts.Results.strict ...
         || ~strcmp(matlabGridLineStyle,defaultMatlabGridLineStyle)
          gls = translateLineStyle( matlabGridLineStyle );
          axisGridOpts = sprintf( 'grid style={%s}', gls );
          m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:},...
                                              axisGridOpts{:}};
      end
  else
      % When specifying 'axis on top', the axes stay above all graphs (which is
      % default MATLAB behavior), but so do the grids (which is not default
      % behavior).
      % To date (Dec 12, 2009) pgfplots is not able to handle those things
      % separately.
      % See also http://sourceforge.net/tracker/index.php?func=detail&aid=3510455&group_id=224188&atid=1060657
      % As a prelimary compromise, only pull this option if no grid is in use.
      if m2t.cmdOpts.Results.strict
          m2t.axesContainers{end}.options{end+1} = 'axis on top';
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % See if there are any legends that need to be plotted.
  % Since the legends are at the same level as axes in the hierarchy,
  % we can't work out which relates to which using the tree
  % so we have to do it by looking for a plot inside which the legend sits.
  % This could be done better with a heuristic of finding
  % the nearest legend to a plot, which would cope with legends outside
  % plot boundaries.
  if strcmp( m2t.env, 'MATLAB' )
      legendHandle = legend(handle);
      if ~isempty(legendHandle)
          [ m2t, legendOpts ] = getLegendOpts( m2t, legendHandle );
          m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, legendOpts{:}};
      end
  else
      % TODO: How to uniquely connect a legend with a pair of axes in Octave?
      axisDims = get(handle,'Position');
      axisLeft = axisDims(1);
      axisBot  = axisDims(2);
      axisWid  = axisDims(3);
      axisHei  = axisDims(4);
      % siblings of this handle:
      siblings = get( get(handle,'Parent'), 'Children' );
      % "siblings" always(?) is a column vector. Iterating over the column
      % with the for statement below wouldn't return the individual vector
      % elements but the same column vector, resulting in no legends exported.
      % So let's make sure "siblings" is a row vector by reshaping it:
      siblings = reshape( siblings, 1, [] );
      for sibling = siblings
          if sibling && strcmp(get(sibling,'Type'), 'axes') && strcmp(get(sibling,'Tag'), 'legend')
              legDims = get( sibling, 'Position' );
              legLeft = legDims(1);
              legBot  = legDims(2);
              legWid  = legDims(3);
              legHei  = legDims(4);
              % TODO The following logic does not work for 3D plots.
              %      => Commented out.
              %      This creates problems though for stacked plots with legends.
%                if (    legLeft > axisLeft ...
%                     && legBot > axisBot ...
%                     && legLeft+legWid < axisLeft+axisWid ...
%                     && legBot+legHei  < axisBot+axisHei )
                  [ m2t, legendOpts ] = getLegendOpts( m2t, sibling );
                  m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, legendOpts{:}};
%                end
          end
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % add manually given extra axis options
  if ~isempty( m2t.cmdOpts.Results.extraAxisOptions )
      m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
                                         m2t.cmdOpts.Results.extraAxisOptions{:}};
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % recurse into the children of this environment
  [ m2t, childrenEnvs ] = handleAllChildren( m2t, handle );
  m2t.axesContainers{end} = addChildren( m2t.axesContainers{end}, childrenEnvs );

  return
end
% =========================================================================
function tag = getTag( handle )

    % if a tag is given, use it as comment
    tag = get(handle, 'tag');
    if ~isempty(tag)
        tag = sprintf( 'Axis "%s"', tag );
    else
        tag = sprintf( 'Axis at [%.2g %.2f %.2g %.2g]', get(handle, 'position' ) );
    end

end
% =========================================================================
function [ m2t, hasGrid ] = getAxisOptions( m2t, handle, axis )
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ~strcmpi(axis,'x') && ~strcmpi(axis,'y') && ~strcmpi(axis,'z')
      error( 'Illegal axis specifier ''%s''.', axis );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % axis colors
  color = get( handle, [upper(axis),'Color'] );
  if ( any(color) ) % color not black [0,0,0]
       [ m2t, col ] = getColor( m2t, handle, color, 'patch' );
       m2t.axesContainers{end}.options = ...
           {m2t.axesContainers{end}.options{:}, ...
            ['every outer ',axis,' axis line/.append style={',col, '}'], ...
            ['every ',axis,' tick label/.append style={font=\color{',col,'}}' ]};
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle the orientation
  isAxisReversed = strcmp( get(handle,[upper(axis),'Dir']), 'reverse' );
  m2t.([axis 'AxisReversed']) = isAxisReversed;
  if isAxisReversed
      m2t.axesContainers{end}.options{end+1} = [axis,' dir=reverse'];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis limits
  limits = get( handle, [upper(axis),'Lim'] );
  m2t.axesContainers{end}.options{end+1} = ...
      sprintf([axis,'min=%.15g, ',axis,'max=%.15g'], limits);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ticks, tickLabels, hasMinorTicks] = getIndividualAxisTicks( m2t, handle, axis );

  % According to http://www.mathworks.com/help/techdoc/ref/axes_props.html,
  % the number of minor ticks is automatically determined by MATLAB(R) to
  % fit the size of the axis. Until we know how to extract this number, use
  % a reasonable default.
  matlabDefaultNumMinorTicks = 3;
  if ~isempty( ticks )
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf( [axis,'tick={%s}'], ticks );
  end
  if ~isempty( tickLabels )
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf([axis,'ticklabels={%s}'], tickLabels);
  end
  if hasMinorTicks
      m2t.axesContainers{end}.options{end+1} = [axis,'minorticks=true'];
      if m2t.cmdOpts.Results.strict
          m2t.axesContainers{end}.options{end+1} = ...
              sprintf('minor %s tick num={%d}', axis, matlabDefaultNumMinorTicks);
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis label
  axisLabel = get( get( handle, [upper(axis),'Label'] ), 'String' );
  if iscell(axisLabel)
      axisLabel = axisLabel{:};
  end
  if ~isempty( axisLabel )
      labelText = sprintf( '%s', axisLabel );
      axisLabelInterpreter = get( get( handle, [upper(axis),'Label'] ), 'Interpreter' );
      labelText = prettyPrint( m2t, labelText, axisLabelInterpreter );
      m2t.axesContainers{end}.options{end+1} = ...
          sprintf([axis,'label={%s}'], labelText);
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get grids
  hasGrid = false;
  if strcmp( get( handle, [upper(axis),'Grid']), 'on' );
      m2t.axesContainers{end}.options{end+1} = [axis,'majorgrids'];
      hasGrid = true;
  end
  if strcmp( get( handle, [upper(axis),'MinorGrid']), 'on' );
      m2t.axesContainers{end}.options{end+1} = [axis,'minorgrids'];
      hasGrid = true;
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  return;
end
% =========================================================================
function bool = axisIsVisible( axisHandle )

 if ~isVisible( axisHandle )
     % An invisible axes container *can* have visible children, so don't
     % immediately bail out here.
     c = get(axisHandle,'Children');
     bool = 0;
     for k=1:length(c)
         if isVisible( c(k) )
             bool = 1;
             return;
         end
     end
  else
      bool = true;
  end

end
% =========================================================================
function [ m2t, str ] = drawLine( m2t, handle, hasLegend, yDeviation )
  % Returns the code for drawing a regular line.
  % This is an extremely common operation and takes place in most of the
  % not too fancy plots.
  %
  % This function handles error bars, too.

  % TODO Check for "special" lines, e.g.:
  % if strcmp( get(handle,'Tag'), 'zplane_unitcircle' )
  %     % draw unit circle and axes
  % end

  str = [];

  if ~isVisible( handle )
      return
  end

  lineStyle = get( handle, 'LineStyle' );
  lineWidth = get( handle, 'LineWidth' );
  marker    = get( handle, 'Marker' );

  hasLines = ~strcmp(lineStyle,'none') && lineWidth>0.0;
  hasMarkers = ~strcmp(marker,'none');
  if ~hasLines && ~hasMarkers
      return
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % deal with draw options
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  color  = get( handle, 'Color' );
  [ m2t, xcolor ] = getColor( m2t, handle, color, 'patch' );
  lineOptions = getLineOptions( m2t, lineStyle, lineWidth );
  [ m2t, markerOptions ] = getMarkerOptions( m2t, handle );
  drawOptions = [ {sprintf( 'color=%s', xcolor )}, ... % color
                  lineOptions, ...
                  markerOptions ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Plot the actual line data.
  % First put them all together in one multiarray.
  % This also implicitly makes sure that the lengths match.
  xData  = get( handle, 'XData' );
  yData  = get( handle, 'YData' );
  zData  = get( handle, 'ZData' );
  % We would like to do
  %   data = [xData(:), yData(:), zData(:)],
  % but Octave fails. Hence this isempty() construction.
  if isempty(zData)
      data = [xData(:), yData(:)];
  else
      data = [xData(:), yData(:), zData(:)];
  end

  % check if the *optional* argument 'yDeviation' was given
  if nargin>3
      data = [data, yDeviation(:)];
  end

  % Check if any value is infinite/NaN. In that case, add appropriate option.
  if any(~isfinite(data(:)))
      m2t.axesContainers{end}.options{end+1} = 'unbounded coords=jump';
  end

  if ~isempty( zData )
      % Don't try to be smart in parametric 3d plots: Just plot all the data.
      opts = [ '\n', join(drawOptions, ',\n' ), '\n' ];
      str = [ str, ...
              plotLine3d( opts, data ) ];
  else
      xLim = get( m2t.currentHandles.gca, 'XLim' );
      yLim = get( m2t.currentHandles.gca, 'YLim' );
      % split the data into logical chunks
      dataCell = splitLine( m2t, hasLines, hasMarkers, data, xLim, yLim );

      % plot them
      for k = 1:length(dataCell)
          mask = pointReduction( m2t, dataCell{k}(:,1:2) );
          % If the line has a legend string, make sure to only include a legend
          % entry for the *last* occurence of the plot series.
          % Hence the condition k<length(xDataCell).
          if ~isempty(m2t.legendHandles) && (~hasLegend || k < length(dataCell))
              % No legend entry found. Don't include plot in legend.
              opts = [ '\n', join({drawOptions{:}, 'forget plot'}, ',\n' ), '\n' ];
          else
              opts = [ '\n', join(drawOptions, ',\n' ), '\n' ];
          end
          str = [ str, ...
                  plotLine2d( opts, dataCell{k}(mask,:) ) ];
      end
  end

end
% =========================================================================
function str = plotLine2d(opts, data)

    str = [];

    % check if the *optional* argument 'yDeviation' was given
    errorbarMode = false;
    if size(data,2) == 3
        errorbarMode = true;
    end

    str = [ str, ...
            sprintf( ['\\addplot [',opts,']\n'] ) ];
    if errorbarMode
        str = [ str, ...
                sprintf('plot [error bars/.cd, y dir = both, y explicit]\n') ];
    end

    str = [ str, ...
            sprintf('coordinates{\n') ];

    % Convert to string array then cell to call sprintf once (and no loops).
    if errorbarMode
        str_data = cellstr(num2str(data, '(%.15g,%.15g) +- (0.0,%.15g)'));
    else
        str_data = cellstr(num2str(data, '(%.15g,%.15g)'));
    end
    str_data = sprintf('%s', str_data{:});

    % The process above adds extra white spaces, remove them all
    str_data = str_data(~isspace(str_data));
    % Also, replace "Inf" by the Pgfplots-recognized "inf".
    % Remove this as soon as Pgfplots knows "Inf".
    str_data = strrep(str_data, 'Inf', 'inf');
    str = sprintf('%s %s \n};\n\n', str, str_data);

end
% =========================================================================
function str = plotLine3d(opts, data)

    str = sprintf( ['\\addplot3 [',opts,']\n'] );

    str = [ str, ...
            sprintf('coordinates{\n') ];

    % Convert to string array then cell to call sprintf once (and no loops).
    str_data = cellstr(num2str(data, '(%.15g,%.15g,%.15g)'));
    str_data = sprintf('%s', str_data{:});

    % The process above adds extra white spaces, remove them all
    str_data = str_data(~isspace(str_data));
    % Also, replace "Inf" by the Pgfplots-recognized "inf".
    % Remove this as soon as Pgfplots knows "Inf".
    str_data = strrep(str_data, 'Inf', 'inf');
    str = sprintf('%s %s \n};\n\n', str, str_data);

end
% =========================================================================
function dataCell = splitLine( m2t, hasLines, hasMarkers, data, xLim, yLim )
  % Split the xData, yData into several chunks of data for each of which
  % an \addplot will be generated.
  % Splitting criteria are:
  %    * Visibility.
  %    * Data set too large.

  dataCell{1} = data;

  % Split up each of the chunks along visible segments.
  dataCell = splitByVisibility(m2t, hasLines, hasMarkers, dataCell, xLim, yLim);

  % Move some points closer to the box to avoid TeX:DimensionTooLarge errors.
  % This may involve inserting extra points.
  dataCell = movePointsCloser(m2t, dataCell, xLim, yLim);

  % Split each of the current chunks further with respect to outliers.
  dataCell = splitByArraySize(dataCell);

end
% =========================================================================
function dataCellNew = ...
    splitByVisibility( m2t, hasLines, hasMarkers, dataCell, xLim, yLim )
  % Parts of the line data may sit outside the plotbox.
  % 'segvis' tells us which segment are actually visible, and the
  % following construction loops through it and makes sure that each
  % point that is necessary gets actually printed.
  % 'printPrevious' tells whether or not the previous segment is visible;
  % this information is used for determining when a new 'addplot' needs
  % to be opened.

  dataCellNew = cell(0);

  tol = 1.0e-10;
  relaxedXLim = xLim + [-tol, tol];
  relaxedYLim = yLim + [-tol, tol];

  for data = dataCell
      numPoints = size(data{1}, 1);

      % Get which points are inside a (slightly larger) box.
      dataIsInBox = isInBox(data{1}(:,1:2), ...
                            relaxedXLim, relaxedYLim );

      if hasMarkers
          shouldPlot = dataIsInBox;
      else
          % By default, don't plot any points.
          shouldPlot = false(numPoints,1);
      end
      if hasLines
          % Check if the connecting line is in the box.
          segvis = segmentVisible(data{1}(:,1:2), ...
                                  dataIsInBox, xLim, yLim);
          % Plot points which are next to an edge which is in the box.
          shouldPlot = shouldPlot | [false; segvis] | [segvis; false];
      end

      % Split the data in chunks of where 'shouldPlot' is 'true'.
      k = 1;
      while k <= numPoints
          % fast forward to shouldPlot==True
          while k<=numPoints && ~shouldPlot(k)
              k = k+1;
          end
          kStart = k;
          % fast forward to shouldPlot==False
          while k<=numPoints && shouldPlot(k)
              k = k+1;
          end
          kEnd = k-1;

          if kStart <= kEnd
              dataCellNew{end+1} = data{1}(kStart:kEnd,:);
          end
      end
  end

end
% =========================================================================
function dataCellNew = movePointsCloser(m2t, dataCell, xLim, yLim)
  % Move all points outside a box much larger than the visible one
  % to the boundary of that box and make sure that lines in the visible
  % box are preserved. This typically involved replacing one point by
  % two new ones.

  xWidth = xLim(2) - xLim(1);
  yWidth = yLim(2) - yLim(1);
  extendFactor = 20;
  largeXLim = xLim + extendFactor * [-xWidth, xWidth];
  largeYLim = yLim + extendFactor * [-yWidth, yWidth];

  dataCellNew = {};
  for data = dataCell
      % Get which points are in an extended box (the limits of which
      % don't exceed TeX's memory).
      dataIsInLargeBox = isInBox(data{1}(:,1:2), ...
                                 largeXLim, largeYLim );

      % Loop through all points which are to be included in the plot
      % yet do not fit into the extended box, and gather the points
      % by which they are to be replaced.
      replaceIndices = find(~dataIsInLargeBox)';
      m = length(replaceIndices);
      r = cell(m, 1);
      for k = 1:m
          i = replaceIndices(k);
          r{k} = [];
          if i > 1 && all(isfinite(data{1}(i-1,:)))
              newPoint = moveToBox(data{1}(i,:), data{1}(i-1,:), largeXLim, largeYLim);
              % Don't bother if the point is inf:
              % There's no intersection with the large box, so even the
              % connection between the two after they have been moved
              % won't be probably be visible.
              if all(isfinite(newPoint))
                  r{k} = [r{k}; newPoint];
              end
          end
          if i < size(data{1},1) && all(isfinite(data{1}(i+1,:)))
              newPoint = moveToBox(data{1}(i,:), data{1}(i+1,:), largeXLim, largeYLim);
              % Don't bother if the point is inf:
              % There's no intersection with the large box, so even the
              % connection between the two after they have been moved
              % won't be probably be visible.
              if all(isfinite(newPoint))
                  r{k} = [r{k}; newPoint];
              end
          end
      end

      % Insert all r{k}{:} at replaceIndices[k].
      dataCellNew{end+1} = [];
      lastReplIndex = 0;
      for k = 1:m
         dataCellNew{end} = [dataCellNew{end}; ...
                             data{1}(lastReplIndex+1:replaceIndices(k)-1,:);...
                             r{k}];
         lastReplIndex = replaceIndices(k);
      end
      dataCellNew{end} = [dataCellNew{end}; ...
                          data{1}(lastReplIndex+1:end,:)];
  end

end
% =========================================================================
function out = isInBox( data, xLim, yLim )

  out = data(:,1) > xLim(1) & data(:,1) < xLim(2) ...
      & data(:,2) > yLim(1) & data(:,2) < yLim(2);

end
% =========================================================================
function dataCellNew = splitByArraySize(dataCell)
  % TeX parses files line by line with a buffer of size buf_size. If the
  % plot has too many data points, the buffer size may be exceeded.
  % As a work-around, the plot is split into several smaller plots, and this
  % function does the job.
  %
  % What is a "large" array?
  % TeX parser buffer is buf_size=200000 char on Mac TeXLive, let's say
  % 100000 to be on the safe side.
  % 1 point is represented by 25 characters (estimation): 2 coordinates (10
  % char), 2 brackets, commma and white space, + 1 extra char.
  % That gives a magic arbitrary number of 4000 data points per array.

  % Unconditionally set this to true. This results in one extra point to be
  % plotted per chunk, which probably doesn't hurt too much. Anyways,
  % TODO Take hasLines as argument to splitByArraySize().
  hasLines = true;

  chunkLength = 4000;

  dataCellNew = cell(0);

  for data = dataCell

      chunkStart = 1;
      len = size(data{1}, 1);
      while chunkStart <= len
          chunkEnd = min( chunkStart + chunkLength - 1, len );

          % Copy over the data to the new containers.
          dataCellNew{end+1} = data{1}(chunkStart:chunkEnd,:);

          % If the plot has lines, add an extra (overlap) point to the data
          % stream; otherwise the line between two data chunks would be broken.
          if hasLines && chunkEnd~=len
              dataCellNew{end} = [ dataCellNew{end}, data{1}(:,chunkEnd+1) ];
          end

          chunkStart = chunkEnd + 1;
      end
  end

end
% =========================================================================
function xNew = moveToBox(x, xRef, xLim, yLim)
  % Takes a box defined by xLim, yLim, one point x and a reference point
  % xRef.
  % Returns the point xNew that sits on the line segment between x and xRef
  % *and* on the box. If several such points exist, take the closest one
  % to x.

  % Find out with which border the line x---xRef intersects, and determine
  % the smallest parameter alpha such that x + alpha*(xRef-x)
  % sits on the boundary.
  minAlpha = inf;
  % left boundary:
  lambda = crossLines(x, xRef, [xLim(1);yLim(1)], [xLim(1);yLim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % bottom boundary:
  lambda = crossLines(x, xRef, [xLim(1);yLim(1)], [xLim(2);yLim(1)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % right boundary:
  lambda = crossLines(x, xRef, [xLim(2);yLim(1)], [xLim(2);yLim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % top boundary:
  lambda = crossLines(x, xRef, [xLim(1);yLim(2)], [xLim(2);yLim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % create the new point
  xNew = x + minAlpha*(xRef-x);
end
% =========================================================================
function out = segmentVisible(data, dataIsInBox, xLim, yLim)
    % Given a bounding box {x,y}Lim, loop through all pairs of subsequent nodes
    % in p and determine whether the line between the pair crosses the box.

    n = size(data, 1);
    out = false(n-1, 1);
    for k = 1:n-1
        out(k) =  ( dataIsInBox(k) && all(isfinite(data(k+1,:))) ) ... % one of the neighbors is inside the box
               || ( dataIsInBox(k+1) && all(isfinite(data(k,:))) ) ... % and the other is finite
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(1)], [xLim(1);yLim(2)]) ... % left border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(1)], [xLim(2);yLim(1)]) ... % bottom border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(2);yLim(1)], [xLim(2);yLim(2)]) ... % right border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(2)], [xLim(2);yLim(2)]); % top border
    end

end
% =========================================================================
function out = segmentsIntersect(X1, X2, X3, X4)
  % Checks whether the segments X1--X2 and X3--X4 intersect.
  lambda = crossLines(X1, X2, X3, X4);
  out = all(lambda > 0.0) && all(lambda < 1.0);
  return
end
% =========================================================================
function lambda = crossLines(X1, X2, X3, X4)
  % Given four points X_k=(x_k,y_k), k\in{1,2,3,4}, and the two lines defined
  % by those,
  %
  %  L1(lambda) = X1 + lambda (X2 - X1)
  %  L2(lambda) = X3 + lambda (X4 - X3)
  %
  % returns the lambda for which they intersect (and Inf
  % if they are parallel).
  % Technically, one needs to solve the 2x2 equation system
  %
  %   x1 + lambda1 (x2-x1)  =  x3 + lambda2 (x4-x3)
  %   y1 + lambda1 (y2-y1)  =  y3 + lambda2 (y4-y3)
  %
  % for lambda and mu.

  rhs = X3(:) - X1(:);
  % Divide by det even if it's 0: Infs are returned.
  % A = [X2-X1, -(X4-X3)];
  detA = -(X2(1)-X1(1))*(X4(2)-X3(2)) + (X2(2)-X1(2))*(X4(1)-X3(1));
  invA = [-(X4(2)-X3(2)), X4(1)-X3(1);...
          -(X2(2)-X1(2)), X2(1)-X1(1)] / detA;
  lambda = invA * rhs;

end
% =========================================================================
function mask = pointReduction( m2t, data )
  % Generates a mask which is true for the first point, and all
  % subsequent points which have a greater norm2-distance from
  % the previous point than 'threshold'.

  threshold = m2t.cmdOpts.Results.minimumPointsDistance;
  n = size(data, 1);

  if ( threshold==0.0 )
      % bail out early
      mask = true(n,1);
      return
  end

  mask = false(n,1);

  XRef = data(1,:);
  mask(1) = true;
  for kk = 2:n
      if norm(XRef - data(kk,:)) > threshold
          XRef = data(kk,:);
          mask(kk) = true;
      end
  end

end
% =========================================================================
function lineOpts = getLineOptions( m2t, lineStyle, lineWidth )
  % Gathers the line options.

  lineOpts = cell(0);

  if ~strcmp(lineStyle,'none') && abs(lineWidth-m2t.tol)>0

      lineOpts{end+1} = sprintf('%s', translateLineStyle(lineStyle));

      % take over the line width in any case when in strict mode;
      % if not, don't add anything in case of default line width
      % and effectively take pgfplots' default
      matlabDefaultLineWidth = 0.5;
      if m2t.cmdOpts.Results.strict ...
         || ~abs(lineWidth-matlabDefaultLineWidth) <= m2t.tol
          lineOpts{end+1} = sprintf('line width=%.1fpt', lineWidth);
      end

  end

end
% =========================================================================
function [ m2t, drawOptions ] = getMarkerOptions( m2t, h )
  % Handles the marker properties of a line (or any other) plot.

  drawOptions = cell(0);

  marker = get( h, 'Marker' );

  if ~strcmp( marker, 'none' )
      markerSize = get( h, 'MarkerSize' );
      lineStyle  = get( h, 'LineStyle' );
      lineWidth  = get( h, 'LineWidth' );

      [ tikzMarkerSize, isDefault ] = ...
                               translateMarkerSize( m2t, marker, markerSize );

      % take over the marker size in any case when in strict mode;
      % if not, don't add anything in case of default marker size
      % and effectively take pgfplots' default
      if m2t.cmdOpts.Results.strict || ~isDefault
         drawOptions{end+1} = sprintf('mark size=%.1fpt', tikzMarkerSize);
      end

      markOptions = cell(0);
      % make sure that the markers get painted in solid (and not dashed)
      % if the 'lineStyle' is not solid (otherwise there is no problem)
      if ~strcmp( lineStyle, 'solid' )
          markOptions{end+1} = 'solid';
      end

      % print no lines
      if strcmp(lineStyle,'none') || lineWidth==0
          drawOptions{end+1} = 'only marks';
      end

      % get the marker color right
      markerFaceColor = get( h, 'markerfaceColor' );
      markerEdgeColor = get( h, 'markeredgeColor' );
      [ tikzMarker, markOptions ] = translateMarker( m2t, marker,         ...
                           markOptions, ~strcmp(markerFaceColor,'none') );
      if ~strcmp(markerFaceColor,'none')
          [ m2t, xcolor ] = getColor( m2t, h, markerFaceColor, 'patch' );
          markOptions{end+1} = sprintf('fill=%s', xcolor);
      end
      if ~strcmp(markerEdgeColor,'none') && ~strcmp(markerEdgeColor,'auto')
          [ m2t, xcolor ] = getColor( m2t, h, markerEdgeColor, 'patch' );
          markOptions{end+1} = sprintf('draw=%s', xcolor);
      end

      % add it all to drawOptions
      drawOptions{end+1} = sprintf('mark=%s', tikzMarker);

      if ~isempty( markOptions )
          mo = join( markOptions, ',' );
          drawOptions{end+1} = ['mark options={', mo, '}'];
      end
  end

end
% =========================================================================
function [ tikzMarkerSize, isDefault ] = ...
                    translateMarkerSize( m2t, matlabMarker, matlabMarkerSize )
  % The markersizes of Matlab and TikZ are related, but not equal. This
  % is because
  %
  %  1.) MATLAB uses the MarkerSize property to describe something like
  %      the diameter of the mark, while TikZ refers to the 'radius',
  %  2.) MATLAB and TikZ take different measures (, e.g., the
  %      edgelength of a square vs. the diagonal length of it).

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
  isDefault = abs(matlabMarkerSize-defaultMatlabMarkerSize)<m2t.tol;

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
% =========================================================================
function [ tikzMarker, markOptions ] = ...
         translateMarker( m2t, matlabMarker, markOptions, faceColorToggle )
  % This function is used for getMarkerOptions() as well as drawScatterPlot().

  if( ~ischar(matlabMarker) )
      error( [ 'Function translateMarker:', ...
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
          userInfo( m2t, '\nMake sure to load \\usetikzlibrary{plotmarks} in the preamble.\n' );
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
                  markOptions = [ markOptions, ',rotate=90' ];

              case '>'
                  if faceColorToggle
                      tikzMarker = 'triangle*';
                  else
                      tikzMarker = 'triangle';
                  end
                  markOptions = [ markOptions, ',rotate=270' ];

              case {'p','pentagram'}
                  if faceColorToggle
                      tikzMarker = 'star*';
                  else
                      tikzMarker = 'star';
                  end

              case {'h','hexagram'}
                  userWarning( m2t, 'MATLAB''s marker ''hexagram'' not available in TikZ. Replacing by ''star''.' );
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
% =========================================================================
function [ m2t, str ] = drawPatch( m2t, handle )
  % Draws a 'patch' graphics object (as found in contourf plots, for
  % example).
  %
  % TODO: Declare common patch properties (like 'draw=none') once for
  %       all patches.

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
      [ m2t, xFaceColor ] = getColor( m2t, handle, faceColor, 'patch' );
      drawOptions{end+1} = sprintf( 'fill=%s', xFaceColor );
      xFaceAlpha = get( handle, 'FaceAlpha' );
      if abs(xFaceAlpha-1.0)>m2t.tol
          drawOptions{end+1} = sprintf('opacity=%s', xFaceAlpha);
      end
  end

  % draw color
  edgeColor = get( handle, 'EdgeColor' );
  lineStyle = get( handle, 'LineStyle' );
  if strcmp( lineStyle, 'none' ) || strcmp( edgeColor, 'none' )
      drawOptions{end+1} = 'draw=none';
  else
      [ m2t, xEdgeColor ] = getColor( m2t, handle, edgeColor, 'patch' );
      drawOptions{end+1} = sprintf( 'draw=%s', xEdgeColor);
  end

  drawOpts = join( drawOptions, ',' );
  % -----------------------------------------------------------------------

  % MATLAB's patch elements are matrices in which each column represents a
  % a distinct graphical object. Usually there is only one column, but
  % there may be more (-->hist plots, although they are now handled
  % within the barplot framework).
  xData = get( handle, 'XData' );
  yData = get( handle, 'YData' );
  zData = get( handle, 'ZData' );

  if any(~isfinite(xData(:))) || any(~isfinite(yData(:))) || any(~isfinite(zData(:)))
      % Add 'unbounded coords=jump' to the axis options if it's not there
      % already.
      ucOpt = 'unbounded coords=jump';
      ucIsThere = false;
      for item = m2t.axesContainers{end}.options
          if strcmp(item, ucOpt)
              ucIsThere = true;
              break;
          end
      end
      if ~ucIsThere
          m2t.axesContainers{end}.options{end+1} = ucOpt;
      end
  end

  % n > 1 for certain patch plots, for example.
  n = size(xData,2);

  if isempty( zData )
      % 2d patch
      for j = 1:n
          str = strcat( str, ...
                        sprintf(['\n\\addplot [',drawOpts,'] coordinates{']) );

          % Convert to string array then cell to call sprintf once (and no loops).
          str_data = cellstr(num2str([xData(:,j),yData(:,j)],'(%.15g,%.15g)'));
          str_data = sprintf('%s', str_data{:});
          % The process adds extra white spaces, remove them all
          str_data = str_data(~isspace(str_data));
          str = sprintf('%s %s', str, str_data);

          % This path isn't necessarily closed, but Pgfplots
          % can deal with that.

          % Close environment.
          str = strcat( str, sprintf('};') );
      end
   else % ~isempty( zData )
      % 3d patch
      for j = 1:n
          str = strcat( str, ...
                        sprintf(['\n\\addplot3 [',drawOpts,'] coordinates{']) );

          % Convert to string array then cell to call sprintf once (and no loops).
          str_data = cellstr(num2str([xData(:,j),yData(:,j),zData(:,j)],'(%.15g,%.15g,%.15g)'));
          str_data = sprintf('%s', str_data{:});
          % The process adds extra white spaces, remove them all
          str_data = str_data(~isspace(str_data));
          str = sprintf('%s %s', str, str_data);

          % make sure the path is closed
          if xData(1,j)~=xData(end,j) || yData(1,j)~=yData(end,j) || zData(1,j)~=zData(end,j)
              str = strcat( str, ...
                            sprintf( ' (%.15g,%.15g,%.15g)', xData(1,j), yData(1,j), zData(1,j) ) );
          end
          % close it
          str = strcat( str, sprintf('};\n') );
      end
   end
   str = [ str, sprintf('\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawImage( m2t, handle )
  % Draws an 'image' graphics object (which is essentially just a matrix
%    % containing the RGB color values for a spot).

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

  if ~strcmp( get(m2t.currentHandles.gca,'Visible'), 'off' )
      % Flip the image over as the PNG gets written starting at (0,0) that is,
      % the top left corner.
      % MATLAB quirk: In case the axes are invisible, don't do this.
      cdata = cdata(m:-1:1,:,:);
  end

  if ( m2t.cmdOpts.Results.imagesAsPng )
      if ~isfield( m2t, 'imageAsPngNo' )
          m2t.imageAsPngNo = 1;
      else
          m2t.imageAsPngNo = m2t.imageAsPngNo + 1;
      end
      % ------------------------------------------------------------------------
      % draw a png image
      % Take the TikZ file base name and change the extension .png.
      [pathstr, name ] = fileparts( m2t.tikzFileName );
      pngFileName = fullfile( pathstr, [name '-' num2str(m2t.imageAsPngNo) '.png'] );
      pngReferencePath = fullfile( m2t.relativePngPath, [name '-' num2str(m2t.imageAsPngNo) '.png'] );
      if strcmp( filesep, '\' )
          % We're on a Windows system with the directory separator
          % character "\". It has to be changed into "/" for the TeX output
          pngReferencePath = strrep( pngReferencePath, filesep, '/' );
      end

      % Get color indices for indexed color images and truecolor values otherwise.
      if ndims( cdata ) == 2
          [ m2t, colorData ] = imagecolor2colorindex ( m2t, cdata, handle );
      else
          colorData = cdata;
      end

      % flip the image if reverse
      if m2t.xAxisReversed
          colorData = colorData(:,n:-1:1,:);
      end
      if m2t.yAxisReversed
          colorData = colorData(m:-1:1,:,:);
      end

      % write the image
      imwriteWrapperPNG( colorData, m2t.currentHandles.colormap, pngFileName );
      % ------------------------------------------------------------------------

      xLim = get( m2t.currentHandles.gca, 'XLim' );
      yLim = get( m2t.currentHandles.gca, 'YLim' );
      str = [ str, ...
              sprintf( '\\addplot graphics [xmin=%d, xmax=%d, ymin=%d, ymax=%d] {%s};\n', ...
                       xLim(1), xLim(2), yLim(1), yLim(2), pngReferencePath) ];
      userInfo( m2t, [ '\nA PNG file is stored at ''%s'' for which\n', ...
                       'the TikZ file contains a reference to ''%s''.\n', ...
                       'You may need to adapt this, depending on the relative\n', ...
                       'locations of the master TeX file and the included TikZ file.\n' ], ...
                     pngFileName, pngReferencePath );
  else
      % ------------------------------------------------------------------------
      % draw the thing

      % Generate uniformly distributed X, Y, although xData and yData may be non-uniform.
      % This is MATLAB(R) behaviour.
      switch length(xData)
          case 2 % only the limits given; common for generic image plots
              hX = 1;
          case m % specific x-data is given
              hX = (xData(end)-xData(1)) / (length(xData)-1);
          otherwise
              error( 'drawImage:arrayLengthMismatch', ...
                     'Array lengths not matching (%d = size(cdata,1) ~= length(xData) = %d).', m, length(xData) );
      end
      X = xData(1):hX:xData(end);

      switch length(yData)
          case 2 % only the limits given; common for generic image plots
              hY = 1;
          case n % specific y-data is given
              hY = (yData(end)-yData(1)) / (length(yData)-1);
          otherwise
              error( 'drawImage:arrayLengthMismatch', ...
                     'Array lengths not matching (%d = size(cdata,2) ~= length(yData) = %d).', n, length(yData) );
      end
      Y = yData(1):hY:yData(end);

      m = length(X);
      n = length(Y);
      [m2t xcolor] = getColor(m2t, handle, cdata, 'image' );

      % The following section takes pretty long to execute, although in principle it is
      % discouraged to use TikZ for those; LaTeX will take forever to compile.
      % Still, a bug has been filed on MathWorks to allow for one-line sprintf'ing with
      % (string+num) cells (Request ID: 1-9WHK4W).
      for i = 1:m
          for j = 1:n
              str = strcat( str, ...
                            sprintf( '\\fill [%s] (axis cs:%.15g,%.15g) rectangle (axis cs:%.15g,%.15g);\n', ...
                                     xcolor{i,j}, Y(j)-hY/2,  X(i)-hX/2, Y(j)+hY/2, X(i)+hX/2  ) );
          end
      end
      % ------------------------------------------------------------------------
  end

end
% =========================================================================
function [ m2t, str ] = drawHggroup( m2t, h )

  % Octave doesn't have the handle() function, so there's no way to
  % determine the nature of the plot anymore at this point.
  % Set to 'unknown' to force fallback handling. This produces something
  % for bar plots, for example.
  try
      cl = class( handle(h) );
  catch
      cl = 'unknown';
  end

  switch( cl )
      case 'specgraph.barseries'
          % hist plots and friends
          [m2t, str] = drawBarseries( m2t, h );

      case 'specgraph.stemseries'
          % stem plots
          [m2t, str] = drawStemseries( m2t, h );

      case 'specgraph.stairseries'
          % stair plots
          [m2t, str] = drawStairSeries( m2t, h );

      case {'specgraph.contourgroup', 'hggroup'}
          % handle all those the usual way
          [m2t, str] = handleAllChildren( m2t, h );

      case {'specgraph.quivergroup'}
          % quiver arrows
          [m2t, str] = drawQuiverGroup( m2t, h );

      case {'specgraph.errorbarseries'}
          % error bars
          [m2t,str] = drawErrorBars( m2t, h );

      case {'specgraph.scattergroup'}
          % scatter plots
          [m2t,str] = drawScatterPlot( m2t, h );

      otherwise
          userWarning( m2t, 'Don''t know class ''%s''. Default handling.', cl );
          [m2t, str] = handleAllChildren( m2t, h );
  end

end
% =========================================================================
function [m2t,env] = drawSurface( m2t, handle )

    str = [];
    [m2t, opts, plotType] = surfaceOpts( m2t, handle );
    str = [ str, sprintf( [ '\n\\addplot3[%%\n%s,\n', opts ,']' ], plotType ) ];

    str = [ str, sprintf( '\ncoordinates{ \n' ) ];

    dx = get(handle,'XData');
    dy = get(handle,'YData');
    dz = get(handle,'ZData');
    if any(~isfinite(dx(:))) || any(~isfinite(dy(:))) || any(~isfinite(dz(:)))
        m2t.axesContainers{end}.options{end+1} = 'unbounded coords=jump';
    end
    [col, row] = size(dz);

    % Check if surf plot is 'spectrogram' or 'surf' and run corresponding
    % algorithm.
    dz = dz';
    if isvector(dx)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Plot is 'spectrogram'.
        % Manually remove the grid in this case.
        m2t.axesContainers{end}.options{end+1} = 'grid=none';
        for i = 1:row
            for j = 1:col
                str = [ str, ...
                        sprintf('(%.15g,%.15g,%.15g)', dx(i), dy(j), dz(i,j) ) ];
            end
            % insert an empty line to tell Pgfplots about one row ending here
            str = [str, sprintf('\n\n')];
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    else
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % plot is 'surf'
        dx = dx';
        dy = dy';
        for i = 1:row
            str_data = sprintf('%s', num2str([dx(i,:)' dy(i,:)' dz(i,:)'],'(%.15g,%.15g,%.15g)')');
            % Remove the white space.
            str_data = str_data(~isspace(str_data));
            str = [str, str_data];
            % insert an empty line to tell Pgfplots about one row ending here
            str = [str, sprintf('\n\n')];
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    end %if-else

    % TODO:
    % - remove grids in spectrogram by either removing grid command
    %   or adding: 'grid=none' from/in axis options
    % - handling of huge data amounts in LaTeX.
    str = [str, sprintf('};\n\n')];
    env = str;

end
% =========================================================================
function [ m2t, str ] = drawText(m2t, handle)
  str = [];

  % there may be some text objects floating around a Matlab figure which
  % are handled by other subfunctions (labels etc.) or don't need to be
  % handled at all
  if     strcmp(get(handle, 'Visible'), 'off') ...
      || strcmp(get(handle, 'HandleVisibility'), 'off')
    return;
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get required properties
  color  = get( handle, 'Color' );
  [ m2t, tcolor ] = getColor( m2t, handle, color, 'patch' );
  EdgeColor = get( handle, 'EdgeColor' );
  HorizontalAlignment = get( handle, 'HorizontalAlignment' );
  pos = get( handle, 'Position' );
  String = get( handle, 'String' );
  Interpreter = get( handle, 'Interpreter' );
  String = prettyPrint( m2t, String, Interpreter );
  VerticalAlignment = get( handle, 'VerticalAlignment' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % translate them to pgf style
  style = cell(0);
  switch VerticalAlignment
      case {'top', 'cap'}
          style{end+1} = 'below';
      case {'baseline', 'bottom'}
          style{end+1} = 'above';
  end
  switch HorizontalAlignment
      case 'left'
          style{end+1} = 'right';
      case 'right'
          style{end+1} = 'left';
  end
  % remove invisible border around \node to make the text align precisely
  style{end+1} = 'inner sep=0mm';

  % Add rotation
  rot = get(handle, 'Rotation');
  if rot ~= 0.0
    style{end+1} = sprintf('rotate=%.15g', rot);
  end

  style{end+1} = ['text=' tcolor];
  if ~strcmp(EdgeColor, 'none')
    [ m2t, ecolor ] = getColor( m2t, handle, EdgeColor, 'patch' );
    style{end+1} = ['draw=', ecolor];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = sprintf( '\\node[%s]\nat (axis cs:%.15g, %.15g) {%s};\n', ...
                 join(style,', '), pos(1), pos(2), String );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end
% =========================================================================
function [ m2t, str ] = drawRectangle( m2t, handle )
  str = [];

  % there may be some text objects floating around a Matlab figure which
  % are handled by other subfunctions (labels etc.) or don't need to be
  % handled at all
  if     strcmp(get(handle, 'Visible'), 'off') ...
      || strcmp(get(handle, 'HandleVisibility'), 'off')
    return;
  end

  % TODO handle Curvature = [0.8 0.4]

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  lineStyle = get( handle, 'LineStyle' );
  lineWidth = get( handle, 'LineWidth' );
  if ( strcmp(lineStyle,'none') || lineWidth==0 )
      return
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Get draw options.
  lineOptions = getLineOptions( m2t, lineStyle, lineWidth );

  colorOptions = cell(0);
  % fill color
  faceColor  = get( handle, 'FaceColor' );
  if ~strcmp( faceColor, 'none' )
      [ m2t, xFaceColor ] = getColor( m2t, handle, faceColor, 'patch' );
      colorOptions{end+1} = sprintf('fill=%s', xFaceColor);
  end
  % draw color
  edgeColor = get( handle, 'EdgeColor' );
  lineStyle = get( handle, 'LineStyle' );
  if strcmp( lineStyle, 'none' ) || strcmp( edgeColor, 'none' )
      colorOptions{end+1} = 'draw=none';
  else
      [ m2t, xEdgeColor ] = getColor( m2t, handle, edgeColor, 'patch' );
      colorOptions{end+1} = sprintf( 'draw=%s', xEdgeColor );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  pos = get( handle, 'Position' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  drawOptions = [ lineOptions, colorOptions ];
  % plot the thing
  str = sprintf( '\\draw[%s] (axis cs:%.15g, %.15g) rectangle (axis cs:%.15g, %.15g);\n', ...
                 join(drawOptions,', '), pos(1), pos(2), pos(1)+pos(3), pos(2)+pos(4) ...
               );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end
% =========================================================================
function [m2t,surfOpts,plotType] = surfaceOpts( m2t, handle )

  faceColor = get( handle, 'FaceColor');
  edgeColor = get( handle, 'EdgeColor');

  % Check for surf or mesh plot. Second argument in if-check corresponds to
  % default values for mesh plot in MATLAB.
  if strcmpi( faceColor, 'none') || ...
     (strcmpi( edgeColor, 'flat' ) && isequal(faceColor, [1 1 1]))
      plotType = 'mesh';
  else
      plotType = 'surf';
  end

  surfOptions = cell(0);

  % Set opacity if FaceAlpha < 1 in MATLAB
  faceAlpha = get( handle, 'FaceAlpha');
  if isnumeric( faceAlpha ) && faceAlpha ~= 1.0
    surfOptions{end+1} = sprintf( 'opacity=%.15g', faceAlpha );
  end

  % Get color map.
  surfOptions{end+1} = matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap);

  if strcmpi(plotType, 'surf')
      % Set shader for surface plot.
      % TODO: find MATLAB equivalents for flat corner and flat mean
      if strcmpi( edgeColor, 'none' ) && strcmpi( faceColor, 'flat' )
          surfOptions{end+1} = 'shader=flat';
      elseif isnumeric(edgeColor) && strcmpi(faceColor, 'flat')
          [ m2t, xEdgeColor ] = getColor( m2t, handle, edgeColor, 'patch' );
          % same as shader=flat,draw=\pgfkeysvalueof{/pgfplots/faceted color}
          surfOptions{end+1} = 'shader=faceted';
          surfOptions{end+1} = sprintf('draw=%s', xEdgeColor);
      elseif strcmpi(edgeColor, 'none') && strcmpi(faceColor, 'interp')
          surfOptions{end+1} = 'shader=interp';
      else
          surfOptions{end+1} = 'shader=faceted';
      end
  elseif strcmpi(plotType, 'mesh')
      surfOptions{end+1} = 'shader=flat';
  end

  surfOpts = join( surfOptions , ',\n' );

  return
end
% =========================================================================
function [ m2t, str ] = drawScatterPlot( m2t, h )

  str = [];

  xData = get( h, 'XData' );
  yData = get( h, 'YData' );
  zData = get( h, 'ZData' );
  cData = get( h, 'CData' );

  matlabMarker    = get( h, 'Marker' );
  markerFaceColor = get( h, 'MarkerFaceColor' );
  hasFaceColor    = ~strcmp(markerFaceColor,'none');
  [tikzMarker, markOptions] = translateMarker( m2t, matlabMarker, [], hasFaceColor );

  if length(cData) == 3
      % No special treatment for the colors or markers are needed.
      % All markers have the same color.
      [ m2t, xcolor ] = getColor( m2t, h, cData, 'patch' );
      drawOptions = { 'only marks', ...
                      ['mark=' tikzMarker], ...
                      ['color=' xcolor ] };
  elseif size(cData,2) == 3
      drawOptions = { 'only marks' ...
      % TODO Get this in order as soon as pgfplots can do "scatter rgb".
%                        'scatter rgb' ...
                    };
  else
      markerOptions = { ['mark=', tikzMarker], ...
                        sprintf('draw=mapped color') };
      if hasFaceColor
          markerOptions{end+1} = 'fill=mapped color';
      end
      drawOptions = { 'scatter', ...
                      'only marks', ...
                      'scatter src=explicit', ...
                      ['scatter/use mapped color={', join(markerOptions,','), '}'] };
  end


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  drawOpts = join( drawOptions, ',' );
  if isempty(zData)
      env = 'addplot';
  else
      env = 'addplot3';
  end

  str = [ str, ...
          sprintf( '\\%s[%s] plot coordinates{', env, drawOpts ) ];

  for k = 1:length(xData)
      if isempty(zData)
          str = strcat( str, ...
                        sprintf( ' (%.15g,%.15g)', xData(k), yData(k) ) );
      else
          str = strcat( str, ...
                        sprintf( ' (%.15g,%.15g,%.15g)', xData(k), yData(k), zData(k) ) );
      end
      if length(cData) == 3
          % If size(cData,1)==1, then all the colors are the same and have
          % already been accounted for above.
          str = strcat( str, sprintf('\n') );
      elseif size(cData,2) == 3
          [m2t, col] = rgb2colorliteral( m2t, cData(k,:) );
          str = strcat( str, sprintf( ' [%s]\n', col ) );
      else
          str = strcat( str, sprintf( ' [%d]\n', cData(k) ) );
      end
  end

  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawBarseries( m2t, h )
  % Takes care of plots like the ones produced by MATLAB's hist.
  % The main pillar is pgfplots's '{x,y}bar' plot.
  %
  % TODO Get rid of code duplication with 'drawAxes'.

  if ~isfield( m2t, 'barplotId' )
      % 'barplotId' provides a consecutively numbered ID for each
      % barseries plot. This allows for properly handling multiple bars.
      m2t.barplotId = [];
      m2t.barplotTotalNumber = [];
      m2t.barShifts = [];
      m2t.addedAxisOption = [];
      m2t.nonbarPlotPresent = [];
  end

  str = [];

  % -----------------------------------------------------------------------
  % The bar plot implementation in pgfplots lacks certain functionalities;
  % for example, it can't plot bar plots and non-bar plots in the same
  % axis (while MATLAB can).
  % The following checks if this is the case and cowardly bails out if so.
  % On top of that, the number of bar plots is counted.
  if isempty(m2t.barplotTotalNumber)
      m2t.nonbarPlotPresent  = 0;
      m2t.barplotTotalNumber = 0;
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
                  m2t.nonbarPlotPresent = 1;
              case 'text'
                  % this is pretty harmless: don't complain about ordinary text
              case 'hggroup'
                  cl = class(handle(siblings(k)));
                  switch cl
                      case 'specgraph.barseries'
                          m2t.barplotTotalNumber = m2t.barplotTotalNumber + 1;
                      case 'specgraph.errorbarseries'
                          % TODO:
                          % Unfortunately, MATLAB(R) treats error bars and corresponding
                          % bar plots as siblings of a common axes object.
                          % For error bars to work with bar plots -- which is trivially
                          % possible in pgfplots -- one has to match errorbar and bar
                          % objects (probably by their values).
                          userWarning( m2t, 'Error bars discarded (to be implemented).'  );
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
  isHoriz = strcmp( get( h, 'Horizontal' ), 'on' );
  if (isHoriz)
      barType = 'xbar';
  else
      barType = 'ybar';
  end
  numBars = m2t.barplotTotalNumber;
  switch barlayout
      case 'grouped'
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          % grouped plots
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          % set ID
          if isempty(m2t.barplotId)
              m2t.barplotId = 1;
          else
              m2t.barplotId = m2t.barplotId + 1;
          end

%            % From <MATLAB>/toolbox/matlab/specgraph/makebars.m
%            % plottype==0 means 'grouped'
%            if m==1 || plottype~=0,
%                groupWidth = 1.0;
%            else
%                groupWidth = min(groupWidth, m/(m+1.5));
%            end
%            xx(:,3:4) = 1;
%            if plottype==0,
%                xx = (xx-0.5)*barwidth*groupwidth/m;
%            else
%                xx = (xx-0.5)*barwidth*groupwidth;
%            end

          % Maximum group with relative to the minumum distance between to
          % x-values.
          groupWidth = 0.8;
          if numBars == 1
              groupWidth = 1.0;
          else
              groupWidth = min(groupWidth, numBars/(numBars+1.5));
          end

          % ---------------------------------------------------------------
          % Calculate the width of each bar and the center point shift.
          % The following is taken from MATLAB (see makebars.m) without
          % the special handling for hist plots or other fancy options.
          % ---------------------------------------------------------------
          if isempty( m2t.barShifts )
              % Get the shifts of the bar centers.
              % In case of numBars==1, this returns 0,
              % In case of numBars==2, this returns [-1/4, 1/4],
              % In case of numBars==3, this returns [-1/3, 0, 1/3],
              % and so forth.
              % The bar width is assumed to be groupWidth/numBars.
              m2t.barShifts = ((1:numBars) - 0.5) * groupWidth / numBars ...
                            - 0.5* groupWidth;
          end
          % ---------------------------------------------------------------

          % From http://www.mathworks.com/help/techdoc/ref/bar.html:
          % bar(...,width) sets the relative bar width and controls the
          % separation of bars within a group. The default width is 0.8, so if
          % you do not specify X, the bars within a group have a slight
          % separation. If width is 1, the bars within a group touch one
          % another. The value of width must be a scalar.
          barWidth = get(h, 'BarWidth') * groupWidth / numBars;

          % The minimum distance between two x-values. This is the scaling
          % factor for all other lengths about the bars.
          dx = min( diff(xData) );

          % MATLAB treats shift and width in normalized coordinate units,
          % whereas pgfplots requires physical units (pt,cm,...); hence
          % have the units converted.
          if (isHoriz)
              physicalBarWidth = dx * barWidth * m2t.unitlength.y.value;
              physicalBarShift = dx * m2t.barShifts(m2t.barplotId) * m2t.unitlength.y.value;
              phyicalBarUnit = m2t.unitlength.y.unit;
          else
              physicalBarWidth = dx * barWidth * m2t.unitlength.x.value;
              physicalBarShift = dx * m2t.barShifts(m2t.barplotId) * m2t.unitlength.x.value;
              phyicalBarUnit = m2t.unitlength.x.unit;
          end
          drawOptions = {drawOptions{:}, ...
                         barType, ...
                         sprintf('bar width=%.15g%s', physicalBarWidth, phyicalBarUnit)};
          if physicalBarShift ~= 0.0
              drawOptions{end+1} = ...
                  sprintf('bar shift=%.15g%s', physicalBarShift, phyicalBarUnit);
          end
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
          if isempty(m2t.addedAxisOption) || ~m2t.addedAxisOption
              if m2t.nonbarPlotPresent
                  userWarning( m2t, [ 'Pgfplots can''t deal with stacked bar plots', ...
                                 ' and non-bar plots in one axis environment.', ...
                                 ' The file will probably not compile.'         ] );
              end
              bWFactor = get( h, 'BarWidth' );
              % Add 'ybar stacked' to the containing axes environment.
              m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
                                                  [barType,' stacked'], ...
                                                  sprintf('bar width=%.15g%s', ...
                                                          m2t.unitlength.x.value*bWFactor, m2t.unitlength.x.unit)};
              m2t.addedAxisOption = true;
          end
          % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      otherwise
          error( 'matlab2tikz:drawBarseries',                          ...
                 'Don''t know how to handle BarLayout ''%s''.', barlayout );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define edge color
  edgeColor  = get( h, 'EdgeColor' );
  [ m2t, xEdgeColor ] = getColor( m2t, h, edgeColor, 'patch' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define face color;
  % quite oddly, this value is not coded in the handle itself, but in its
  % child patch.
  child      = get( h, 'Children' );
  faceColor  = get( child, 'FaceColor');
  [ m2t, xFaceColor ] = getColor( m2t, h, faceColor, 'patch' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % gather the draw options
  lineStyle = get( h, 'LineStyle' );

  drawOptions{end+1} = sprintf( 'fill=%s', xFaceColor );
  if strcmp( lineStyle, 'none' )
      drawOptions{end+1} = 'draw=none';
  else
      drawOptions{end+1} = sprintf( 'draw=%s', xEdgeColor );
  end
  drawOpts = join( drawOptions, ',' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Add 'area legend' to the options as otherwise the legend indicators
  % will just highlight the edges.
  m2t.axesContainers{end}.options{end+1} = 'area legend';
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  if isHoriz
      % If the bars are horizontal, the values x and y are exchanged.
      for k=1:length(xData)
          str = strcat( str, ...
                        sprintf( ' (%.15g,%.15g)', yData(k), xData(k) ) );
      end
  else
      for k=1:length(xData)
          str = strcat( str, ...
                        sprintf( ' (%.15g,%.15g)', xData(k), yData(k) ) );
      end
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawStemseries( m2t, h )
  % Takes care of MATLAB's stem plots.
  %
  % TODO Get rid of code duplication with 'drawAxes'.

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
  [ m2t, plotColor ] = getColor( m2t, h, color, 'patch' );

  lineOptions = getLineOptions( m2t, lineStyle, lineWidth );
  [ m2t, markerOptions ] = getMarkerOptions( m2t, h );

  drawOptions = [ 'ycomb',                      ...
                   sprintf( 'color=%s', plotColor ),         ... % color
                   lineOptions, ...
                   markerOptions ];

  % insert draw options
  drawOpts =  join( drawOptions, ',' );
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =



  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  xData = get( h, 'XData' );
  yData = get( h, 'YData' );

  for k=1:length(xData)
      str = strcat( str, ...
                    sprintf( ' (%.15g,%.15g)', xData(k), yData(k) ) );
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawStairSeries( m2t, h )
  % Takes care of MATLAB's stairs plots.
  %
  % TODO Get rid of code duplication with 'drawAxes'.

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
  [ m2t, plotColor ] = getColor( m2t, h, color, 'patch' );

  lineOptions = getLineOptions( m2t, lineStyle, lineWidth );
  [ m2t, markerOptions ] = getMarkerOptions( m2t, h );

  drawOptions = [ 'const plot',         ...
                   sprintf( 'color=%s', plotColor ), ... % color
                   lineOptions, ...
                   markerOptions ];

  % insert draw options
  drawOpts =  join( drawOptions, ',' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  str = [ str, ...
          sprintf( '\\addplot[%s] plot coordinates{', drawOpts ) ];

  xData = get( h, 'XData' );
  yData = get( h, 'YData' );

  for k=1:length(xData)
      str = strcat( str, ...
                    sprintf( ' (%.15g,%.15g)', xData(k), yData(k) ) );
  end
  str = [ str, sprintf(' };\n\n') ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawQuiverGroup( m2t, h )
  % Takes care of MATLAB's quiver plots.

  if ~isfield( m2t, 'quiverId' )
      % used for arrow styles, in case there are more than one quiver fields
      m2t.quiverId = 0;
  else
      m2t.quiverId = m2t.quiverId + 1;
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
  [ m2t, arrowcolor ] = getColor( m2t, h, color, 'patch' );
  arrowOpts = [ arrowOpts,                               ...
                 sprintf( 'color=%s', arrowcolor ),      ... % color
                 getLineOptions( m2t, lineStyle, lineWidth ), ... % line options
               ];

  % define arrow style
  arrowOptions = join( arrowOpts, ',' );

  % Append the arrow style to the TikZ options themselves.
  % TODO: Look into replacing this by something more 'local',
  % (see \pgfplotset{}).
  arrowStyle  = [ 'arrow',num2str(m2t.quiverId),'/.style={',arrowOptions,'}' ];
  m2t.tikzOptions = [ m2t.tikzOptions, arrowStyle ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % return the vector field code
  str = [ str, ...
          sprintf( [ '\\addplot [arrow',num2str(m2t.quiverId)  ,...
                     '] coordinates{ (%.15g,%.15g) (%.15g,%.15g) };\n'],...
                   XY ) ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
function [ m2t, str ] = drawErrorBars( m2t, h )
  % Takes care of MATLAB's error bar plots.

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % 'errorseries' plots have two line-plot children, one of which contains
  % the information about the center points; 'XData' and 'YData' components
  % are both of length n.
  % The other contains the information about the deviations (errors).
  % 'XData' and 'YData' are of length 9*n and contain redundant info which
  % is only needed by MATLAB itself to explicitly draw the error bars.
  c = get( h, 'Children' );

  % Find out which contains the data and which the deviations.
  n1 = length( get(c(1),'XData') );
  n2 = length( get(c(2),'XData') );
  if n2 == 9*n1
      % n1 contains centerpoint info
      dataIdx  = 1;
      errorIdx = 2;
  elseif n1 == 9*n2
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

      if abs(upDev-loDev) >= 1e-10 % don't use 'm2t.tol' here as is seems somewhat too strict
          error( 'drawErrorBars:uneqDeviations', ...
                 'Upper and lower error deviations not equal (%.15g ~= %.15g); matlab2tikz can''t deal with that yet. Using upper deviations.', upDev, loDev );
      end

      yDeviations(k) = upDev;
  end

  % Now, pull drawLine() with deviation information.
  [ m2t, str ] = drawLine( m2t, c(dataIdx), false, yDeviations );

end
% ==============================================================================
function out = linearFunction(X, Y)
    % Return the linear function that goes through (X[1], Y[1]), (X[2], Y[2]).
    out = @(x) ( Y(2,:)*(x-X(1)) + Y(1,:)*(X(2)-x) ) / ( X(2)-X(1) );
    return
end
% ==============================================================================
function matlabColormap = pgfplots2matlabColormap(points, rgb, numColors)
    % Translates a Pgfplots colormap to a MATLAB color map.

    matlabColormap = zeros(numColors, 3);
    % Point indices between which to interpolate.
    I = [1, 2];
    f = linearFunction(points(I), rgb(I,:));
    for k = 1:numColors
        x = (k-1)/(numColors-1) * points(end);
        if x > points(I(2))
            I = I + 1;
            f = linearFunction(points(I), rgb(I,:));
        end
        matlabColormap(k,:) = f(x);
    end

    return
end
% ==============================================================================
function pgfplotsColormap = matlab2pgfplotsColormap(m2t, matlabColormap)
    % Translates a MATLAB color map into a Pgfplots colormap.

    % First check if we could use a default Pgfplots color map.
    % Unfortunately, MATLAB and Pgfplots color maps will never exactly coincide
    % except to the most simple cases such as blackwhite. This is because of a
    % slight incompatibility of Pgfplots and MATLAB colormaps:
    % In MATLAB, indexing goes from 1 through 64, whereas in Pgfplots you can
    % specify any range, the default ones having something like
    % (0: red, 1: yellow, 2: blue).
    % To specify this exact color map in MATLAB, one would have to put 'red' at
    % 1, blue at 64, and yellow in the middle of the two, 32.5 that is.
    % Not really sure how MATLAB rounds here: 32, 33? Anyways, it will be
    % slightly off and hence not match the Pgfplots color map.
    % As a workaround, build the MATLAB-formatted colormaps of Pgfplots default
    % color maps, and check if matlabColormap is close to it. If yes, take it.

    pgfmaps = { struct('name', 'colormap/hot', ...
                       'points', [0,1,2,3], ...
                       'values', [[0,0,1];[1,1,0];[1,0.5,0];[1,0,0]]), ... % TODO check this
                struct('name', 'colormap/hot2', ...
                       'points', [0,3,6,8], ...
                       'values', [[0,0,0];[1,0,0];[1,1,0];[1,1,1]]), ...
                struct('name', 'colormap/jet', ...
                       'points', [0,1,3,5,7,8], ...
                       'values', [[0,0,128];[0,0,255];[0,255,255];[255,255,0];[255,0,0];[128,0,0]]/255), ...
                struct('name', 'colormap/blackwhite', ...
                       'points', [0,1], ...
                       'values', [[0,0,0];[1,1,1]]), ...
                struct('name', 'colormap/bluered', ...
                       'points', [0,1,2,3,4,5], ...
                       'values', [[0,0,180];[0,255,255];[100,255,0];[255,255,0];[255,0,0];[128,0,0]]/255), ...
                struct('name', 'colormap/cool', ...
                       'points', [0,1,2], ...
                       'values', [[255,255,255];[0,128,255];[255,0,255]]/255), ...
                struct('name', 'colormap/greenyellow', ...
                       'points', [0,1], ...
                       'values', [[0,128,0];[255,255,0]]/255), ...
                struct('name', 'colormap/redyellow', ...
                       'points', [0,1], ...
                       'values', [[255,0,0];[255,255,0]]/255), ...
                struct('name', 'colormap/violet', ...
                       'points', [0,1,2], ...
                       'values', [[25,25,122];[255,255,255];[238,140,238]]/255), ...
              };

    % The tolerance is a subjective matter of course.
    % Some figures:
    %    * The norm-distance between MATLAB's gray and bone is 6.8e-2.
    %    * The norm-distance between MATLAB's jet and Pgfplots's jet is 2.8e-2.
    %    * The norm-distance between MATLAB's hot and Pgfplots's hot2 is 2.1e-2.
    tol = 5.0e-2;

    for map = pgfmaps
        numColors = size(matlabColormap, 1);
        mmap = pgfplots2matlabColormap(map{1}.points, map{1}.values, numColors);
        alpha = norm(matlabColormap - mmap) / sqrt(numColors);
        if alpha < tol
            userInfo(m2t, 'Found %s to be a pretty good match for your color map (||diff||=%g).', ...
                     map{1}.name, alpha);
            pgfplotsColormap = map{1}.name;
            return
        end
    end

    % Build a custom color map.
    % Loop over the data, stop at each spot where the linear
    % interpolation is interrupted, and set a color mark there.
    steps = [1, 2];
    colors = [matlabColormap(1,:); matlabColormap(2,:)];
    f = linearFunction(steps, colors);
    k = 3;
    m = size(matlabColormap, 1);
    while k <= m
        if norm(matlabColormap(k,:) - f(k)) > 1.0e-10
            % Add the previous step to the color list
            steps(end) = k-1;
            colors(end,:) = matlabColormap(k-1,:);
            steps = [steps, k];
            colors = [colors; matlabColormap(k,:)];
            f = linearFunction(steps(end-1:end), colors(end-1:end,:));
        end
        k = k+1;
    end
    steps(end) = m;
    colors(end,:) = matlabColormap(m,:);

    % Get it in Pgfplots-readable form.
    unit = 'pt';
    colSpecs = {};
    for k = 1:length(steps)
        x = steps(k)-1;
        sprintf( 'rgb(%d%s)=(%g, %g, %g)', x, unit, colors(k) );
        colSpecs{k} = sprintf( 'rgb(%d%s)=(%g,%g,%g)', x, unit, colors(k,:) );
    end
    pgfplotsColormap = sprintf('colormap={mymap}{[1%s] %s}', unit, join(colSpecs, '; '));

    return
end
% =========================================================================
function axisOptions = getColorbarOptions( m2t, handle )

  % begin collecting axes options
  axisOptions = {};
  cbarOptions = {};
  cbarStyleOptions = {};

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set position, ticks etc. of the colorbar
  loc = get( handle, 'Location' );

  % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
  % small cased ('northoutside'). Hence, use lower() for uniformity.
  switch lower( loc )
      case { 'north', 'south', 'east', 'west' }
          userWarning( m2t, 'Don''t know how to deal with inner colorbars yet.' );
          return;
      case 'eastoutside'
          %cbarOptions{end+1} = 'right';
      case 'westoutside'
          cbarOptions{end+1} = 'left';
      case 'northoutside'
          cbarOptions{end+1} = 'top';
      case 'southoutside'
          cbarOptions{end+1} = 'bottom';
      otherwise
          error( 'drawColorbar: Unknown ''Location'' %s.', loc )
  end

  if strcmp( get(handle, 'YScale'), 'log' )
      cbarStyleOptions{end+1} = 'ymode=log';
  end

  if m2t.cmdOpts.Results.strict
      % Sampled colors.
      numColors = size(m2t.currentHandles.colormap, 1);
      cbarOptions{end+1} = 'sampled';
      cbarStyleOptions{end+1} = sprintf('samples=%d', numColors+1);
  end

  % Merge them together in axisOptions.
  if isempty(cbarOptions)
      axisOptions{end+1} = 'colorbar';
  else
      if length(cbarOptions) > 1
          userWarning('Pgfplots cannot deal with more than one colorbar options yet.');
      end
      axisOptions{end+1} = ['colorbar ', cbarOptions{1}];
  end

  if ~isempty(cbarStyleOptions)
      axisOptions{end+1} = ['colorbar style={', join(cbarStyleOptions, ','), '}'];
  end

  % Append upper and lower limit of the colorbar.
  clim = caxis;
  axisOptions{end+1} = sprintf('point meta min=%.15g', clim(1));
  axisOptions{end+1} = sprintf('point meta max=%.15g', clim(2));

  % do _not_ handle colorbar's children
  return
end
% =========================================================================
function [ m2t, env ] = drawColorbar( m2t, handle, alignmentOptions )
  % TODO: * Declare common properties (like 'draw=none') once for
  %         all badges.

  if ~isVisible( handle )
      return
  end

  % the actual contents of the TikZ file go here
  env = structWithCell( 'name',     'axis', ...
                        'comment',  'colorbar', ...
                        'options',  cell(0), ...
                        'content',  cell(0), ...
                        'children', cell(0)  ...
                       );

  % Do log handling for color bars, too.
  xScale = get( handle, 'XScale' );
  yScale = get( handle, 'YScale' );
  isXLog = strcmp( xScale, 'log' );
  isYLog = strcmp( yScale, 'log' );
  if  ~isXLog && ~isYLog
      env.name = 'axis';
  elseif isXLog && ~isYLog
      env.name = 'semilogxaxis';
  elseif ~isXLog && isYLog
      env.name = 'semilogyaxis';
  else
      env.name = 'loglogaxis';
  end

  if ~isfield( m2t, 'colorbarNo' )
      % Keep track of how many colorbars there are, to avoid
      % file name collision in case PNGs are used.
      m2t.colorbarNo = [];
  end

  % Assume that the parent axes pair is m2t.currentHandles.gca.
  try
      m2t.currentHandles.gca;
  catch
      error( [ 'm2t.currentHandles.gca not set although needed ', ...
               'by the color bar. The parent axes have not been printed yet.' ] ...
           )
  end
  parentDim = getAxesDimensions( m2t.currentHandles.gca, ...
                                 m2t.cmdOpts.Results.width, ...
                                 m2t.cmdOpts.Results.height );

  % TODO Compute the colorbar width. This is pretty much a *guess* of what MATLAB(R) does.
  if ~strcmp(parentDim.x.unit, parentDim.y.unit)
      userWarning( m2t, ...
                   [ 'Physical units of x- and y-axis do not coincide (x: %s; y: %s).', ...
                     'Color bar sizes will likely need tweaking.' ], ...
                   parentDim.x.unit, parentDim.y.unit );
  end
  % Inherent MATLAB(R) parameter, indicating the ratio of the long
  % edge of a color bar versus the short one.
  matlabColorBarLongShortRatio = 14.8;
  width.value = max( parentDim.x.value, parentDim.y.value ) / matlabColorBarLongShortRatio;
  width.unit  = parentDim.x.unit;

  % get the upper and lower limit of the colorbar
  clim = caxis;

  % begin collecting axes options
  cbarOptions = cell( 0 );
  cbarOptions = [ cbarOptions, 'axis on top' ];

  % set alignment options
  if ~isempty(alignmentOptions.opts)
      cbarOptions = [ cbarOptions, alignmentOptions.opts ];
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set position, ticks etc. of the colorbar
  loc = get( handle, 'Location' );

  % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
  % small cased ('northoutside'). Hence, use lower() for uniformity.
  switch lower( loc )
      case { 'north', 'south', 'east', 'west' }
          userWarning( m2t, 'Don''t know how to deal with inner colorbars yet.' );
          return;

      case {'northoutside','southoutside'}
          cbarOptions = [ cbarOptions,                          ...
                           sprintf( 'width=%.15g%s, height=%.15g%s',  ...
                                     parentDim.x.value, parentDim.x.unit,   ...
                                     width.value      , width.unit           ), ...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%.15g, xmax=%.15g', clim ),         ...
                           sprintf( 'ymin=%.15g, ymax=%.15g', [0,1] )         ...
                         ];

          % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'),
          % in Octave small cased ('northoutside').
          if strcmpi( loc, 'northoutside' )
              cbarOptions = [ cbarOptions,                            ...
                              'xticklabel pos=right, ytick=\empty' ];
                              % we actually wanted to set pos=top here,
                              % but pgfplots doesn't support that yet.
                              % pos=right does the same thing, really.
          else
              cbarOptions = [ cbarOptions,                            ...
                               'xticklabel pos=left, ytick=\empty' ];
                               % we actually wanted to set pos=bottom here,
                               % but pgfplots doesn't support that yet.
                               % pos=left does the same thing, really.
          end

      case {'eastoutside','westoutside'}
          cbarOptions = [ cbarOptions,                          ...
                           sprintf( 'width=%.15g%s, height=%.15g%s',  ...
                                     width.value      , width.unit,  ...
                                     parentDim.y.value, parentDim.y.unit ), ...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%.15g, xmax=%.15g', [0,1] ),        ...
                           sprintf( 'ymin=%.15g, ymax=%.15g', clim )          ...
                         ];
          if strcmpi( loc, 'eastoutside' )
               cbarOptions = [ cbarOptions,                           ...
                               'xtick=\empty, yticklabel pos=right' ];
           else
               cbarOptions = [ cbarOptions,                           ...
                               'xtick=\empty, yticklabel pos=left' ];
           end

      otherwise
          error( 'drawColorbar: Unknown ''Location'' %s.', loc )
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ ticks, tickLabels, hasMinorTicks ] = getIndividualAxisTicks( m2t, handle, 'x' );
  if ~isempty( ticks )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'xtick={%s}', ticks ) ];
  end
  if ~isempty( tickLabels )
      cbarOptions = [ cbarOptions,                                    ...
                       sprintf( 'xticklabels={%s}', tickLabels ) ];
  end
  [ ticks, tickLabels, hasMinorTicks ] = getIndividualAxisTicks( m2t, handle, 'y' );
  if ~isempty( ticks )
      cbarOptions = [ cbarOptions,                                    ...
                      sprintf( 'ytick={%s}', ticks ) ];
  end
  if ~isempty( tickLabels )
      cbarOptions = [ cbarOptions,                                    ...
                      sprintf( 'yticklabels={%s}', tickLabels ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set the options
  env.options = {env.options{:}, cbarOptions{:}};
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get the colormap
  cmap = m2t.currentHandles.colormap;
  cbarLength = clim(2) - clim(1);
  m = size( cmap, 1 );

  if (m2t.cmdOpts.Results.imagesAsPng)
      if isempty( m2t.colorbarNo )
          m2t.colorbarNo = 1;
      else
          m2t.colorbarNo = m2t.colorbarNo + 1;
      end
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % plot a strip
      [pathstr,name]   = fileparts( m2t.tikzFileName );
      pngFileName      = fullfile( pathstr, [name '-colorbar' num2str(m2t.colorbarNo) '.png'] );
      pngReferencePath = fullfile( m2t.relativePngPath, [name '-colorbar' num2str(m2t.colorbarNo) '.png'] );
      if strcmp( filesep, '\' )
          % We're on a Windows system with the directory separator
          % character "\". It has to be changed into "/" for the TeX output
          pngReferencePath = strrep( pngReferencePath, filesep, '/' );
      end
      strip = 1:length(cmap);
      % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
      % small cased ('northoutside'). Hence, use lower() for uniformity.
      switch lower( loc )
          case {'northoutside','southoutside'}
              xLim = clim;
              yLim = [0, 1];
          case {'westoutside','eastoutside'}
              strip = strip(end:-1:1)';
              xLim = [0,1];
              yLim = clim;
      end
      imwriteWrapperPNG( strip, cmap, pngFileName );
      env = append( env, ...
                    sprintf( '\\addplot graphics [xmin=%d, xmax=%d, ymin=%d, ymax=%d] {%s};\n', ...
                             xLim(1), xLim(2), yLim(1), yLim(2), pngReferencePath) ...
                  );
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  else
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % plot tiny little badges for the respective colors
      for i=1:m
          [m2t, badgeColor] = rgb2colorliteral( m2t, cmap(i,:) );

          % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
          % small cased ('northoutside'). Hence, use lower() for uniformity.
          switch lower( loc )
              case {'northoutside','southoutside'}
                  x1 = clim(1) + cbarLength/m *(i-1);
                  x2 = clim(1) + cbarLength/m *i;
                  y1 = 0;
                  y2 = 1;
              case {'westoutside','eastoutside'}
                  x1 = 0;
                  x2 = 1;
                  y1 = clim(1) + cbarLength/m *(i-1);
                  y2 = clim(1) + cbarLength/m *i;
          end
          env = append( env, ...
                        sprintf( '\\addplot [fill=%s,draw=none] coordinates{ (%.15g,%.15g) (%.15g,%.15g) (%.15g,%.15g) (%.15g,%.15g) };\n', ...
                                 badgeColor, x1, y1, x2, y1, x2, y2, x1, y2  ) ...
                      );
      end
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % do _not_ handle colorbar's children
  return
end
% =========================================================================
function [m2t, xcolor] = getColor( m2t, handle, color, mode )
  % Handles MATLAB colors and makes them available to TikZ.
  % This includes translation of the color value as well as explicit
  % definition of the color if it is not available in TikZ by default.
  %
  % The variable 'mode' essentially determines what format 'color' can
  % have. Possible values are (as strings) 'patch' and 'image'.

  % check if the color is straight given in rgb
  % -- notice that we need the extra NaN test with respect to the QUIRK
  %    below
  if isreal(color) && length(color)==3 && ~any(isnan(color))
      % everything alright: rgb color here
      [m2t, xcolor] = rgb2colorliteral( m2t, color );
  else
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      switch mode
          case 'patch'
              [m2t, colorindex] = patchcolor2colorindex(m2t, color, handle);
          case 'image'
              [m2t, colorindex] = imagecolor2colorindex(m2t, color, handle);
          otherwise
              error( [ 'matlab2tikz:getColor',                          ...
                       'Argument ''mode'' has illegal value ''%s''.' ], ...
                       mode );
      end
      [m2t, xcolor] = rgb2colorliteral(m2t, m2t.currentHandles.colormap(colorindex, :));
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  end

end
% =========================================================================
function [ m2t, colorindex ] = patchcolor2colorindex( m2t, color, patchhandle )
  % Transforms a color of the edge or the face of a patch to a 1x3 rgb
  % color vector.

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
          [ m2t, colorindex ] = cdata2colorindex( m2t, cdata, patchhandle );

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
function [ m2t, colorindex ] = imagecolor2colorindex ( m2t, color, imagehandle )
  % Transforms a color in image color format to a 1x3 rgb color vector.

  [ m2t, colorindex ] = cdata2colorindex( m2t, color, imagehandle );

end
% =========================================================================
function [ m2t, colorindex ] = cdata2colorindex ( m2t, cdata, imagehandle )
  % Transforms a color in CData format to an index in the color map.
  % Only does something if CDataMapping is 'scaled', really.

  if ~isnumeric(cdata)
      error( 'matlab2tikz:cdata2colorindex',                        ...
             [ 'Don''t know how to handle cdata ''',cdata,'''.' ] );
  end

  axeshandle = m2t.currentHandles.gca;

  % -----------------------------------------------------------------------
  % For the following, see, for example, the MATLAB help page for 'image',
  % section 'Image CDataMapping'.
  switch get( imagehandle, 'CDataMapping' )
      case 'scaled'
          % need to scale within clim
          % see MATLAB's manual page for caxis for details
          clim = get( axeshandle, 'clim' );
          m = size( m2t.currentHandles.colormap, 1 );
          colorindex = zeros( size( cdata ) );
          idx1 = cdata <= clim(1);
          idx2 = cdata >= clim(2);
          idx3 = ~idx1 & ~idx2;
          colorindex(idx1) = 1;
          colorindex(idx2) = m;
          colorindex(idx3) = fix( (cdata(idx3)-clim(1)) / ( clim(2)-clim(1)) *m ) ...
                          + 1;
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
function [ m2t, lOpts ] = getLegendOpts( m2t, handle )

  % Need to check that there's nothing inside visible before we
  % abandon this legend -- an invisible property of the parent just
  % means the legend has no box.
  children = get( handle, 'Children' );
  if ~isVisible( handle ) && ~any( isVisible(children) )
      return
  end

  lOpts = cell( 0 );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle legend location
  loc  = get( handle, 'Location' );
  dist = 0.03;  % distance to to axes in normalized coordinated
  anchor = [];
  % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
  % small cased ('northoutside'). Hence, use lower() for uniformity.
  switch lower( loc )
      case 'northeast'
          % don't anything in this (default) case
      case 'northwest'
          position = [dist, 1-dist];
          anchor   = 'north west';
      case 'southwest'
          position = [dist, dist];
          anchor   = 'south west';
      case 'southeast'
          position = [1-dist, dist];
          anchor   = 'south east';
      case 'north'
          position = [0.5, 1-dist];
          anchor   = 'north';
      case 'east'
          position = [1-dist, 0.5];
          anchor   = 'east';
      case 'south'
          position = [0.5, dist];
          anchor   = 'south';
      case 'west'
          position = [dist, 0.5];
          anchor   = 'west';
      case 'northoutside'
          position = [0.5, 1+dist];
          anchor = 'south';
      case 'southoutside'
          position = [0.5, -dist];
          anchor = 'north';
      case 'eastoutside'
          position = [1+dist, 0.5];
          anchor = 'west';
      case 'westoutside'
          position = [-dist, 0.5];
          anchor = 'east';
      case 'northeastoutside'
          position = [1+dist, 1];
          anchor = 'north west';
      case 'northwestoutside'
          position = [-dist, 1];
          anchor = 'north east';
      case 'southeastoutside'
          position = [1+dist, 0];
          anchor = 'south west';
      case 'southwestoutside'
          position = [-dist, 0];
          anchor = 'south east';
      case {'best','bestoutside'}
          % TODO: Implement these.
          % The position could be determined by means of 'Position' and/or
          % 'OuterPosition' of the legend handle; in fact, this could be made
          % a general principle for all legend placements.
          userWarning( m2t, [ sprintf(' Option ''%s'' not yet implemented.',loc),         ...
                         ' Choosing default.' ] );
      otherwise
          userWarning( m2t, [ ' Unknown legend location ''',loc,''''           ...
                              '. Choosing default.' ] );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle alignment of legend text and pictograms
  textalign = [];
  pictalign = [];
  % Other than MATLAB, Octave allows to change the alignment of legend text and
  % pictograms using legend('left') and legend('right')
  if strcmp( m2t.env, 'Octave' )
      textpos = get( handle, 'textposition' );
      switch lower( textpos )
          case 'left'
              % pictogram right of flush right text
              textalign = 'left';
              pictalign = 'right';
          case 'right'
              % pictogram left of flush left text (default)
              textalign = 'right';
              pictalign = 'left';
          otherwise
              userWarning( m2t, [ ' Unknown legend text position ''',textpos,'''' ...
                                  '. Choosing default.' ] );
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  lStyle = cell(0);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % append to legend options
  if ~isempty(anchor)
      lStyle = {lStyle{:}, ...
                sprintf( 'at={(%.15g,%.15g)}',position ), ...
                sprintf( 'anchor=%s', anchor )};
  end
  % handle orientation
  ori = get( handle, 'Orientation' );
  switch lower( ori )
      case 'horizontal'
          numLegendEntries = length(get(handle, 'String'));
          lStyle{end+1} = sprintf('legend columns=%d', numLegendEntries);
      case 'vertical'
          % Use default.
      otherwise
          userWarning( m2t, [ ' Unknown legend orientation ''',ori,'''' ...
                              '. Choosing default (vertical).' ] );
  end

  % If the plot has 'legend boxoff', we have the 'not visible'
  % property, so turn off line and background fill.
  if ( ~isVisible(handle) )
      lStyle = {lStyle{:}, 'fill=none', 'draw=none'};
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % alignment of legend text and pictograms, if available
  if ~isempty( textalign ) && ~isempty( pictalign )
      lStyle = {lStyle{:}, ...
                sprintf( 'nodes=%s', textalign ), ...
                sprintf( 'legend plot pos=%s', pictalign )};
  else
      % make sure the entries are flush left (default MATLAB behavior)
      lStyle{end+1} = 'nodes=right';
  end

  if ~isempty( lStyle )
      lOpts{end+1} = ['legend style={' join(lStyle,',') '}'];
  end

end
% =========================================================================
function [pTicks, pTickLabels, hasMinorTicks] = ...
    getIndividualAxisTicks( m2t, handle, axis )
  % Return axis tick marks pgfplot style. Nice: Tick lengths and such
  % details are taken care of by Pgfplots.

  if ~strcmpi(axis,'x') && ~strcmpi(axis,'y') && ~strcmpi(axis,'z')
      error( 'Illegal axis specifier ''%s''.', axis );
  end

  if m2t.cmdOpts.Results.interpretTickLabelsAsTex
      labelInterpreter = 'tex';
  else
      % By default, MATLAB never interprets tick labels as TeX
      labelInterpreter = 'none';
  end

  % Create the keywords, e.g., 'XTickLabel', 'XScale', etc., that are used to
  % extract the information from the figure.
  keywordTickLabel = [ upper(axis), 'TickLabel' ];
  keywordTickMode  = [ upper(axis), 'TickMode' ];
  keywordTick      = [ upper(axis), 'Tick' ];
  keywordScale     = [ upper(axis), 'Scale' ];
  keywordMinorTick = [ upper(axis), 'MinorTick' ];

  tickLabels = cellstr( get( handle, keywordTickLabel ) );
  for k = 1:length(tickLabels)
      tickLabels{k} = prettyPrint(m2t, tickLabels{k}, labelInterpreter);
  end
  tickMode = get( handle, keywordTickMode );
  if strcmp(tickMode,'auto') && ~m2t.cmdOpts.Results.strict
      % If the ticks are set automatically, and strict conversion is
      % not required, then let pgfplots take care of the ticks.
      % In most cases, this looks a lot better anyway.
      pTicks      = [];
      if length(tickLabels) == 1 && isempty(tickLabels{1})
          pTickLabels = '\empty';
      else
          pTickLabels = [];
      end
  else % strcmp(zTickMode,'manual') || m2t.cmdOpts.Results.strict
      ticks     = get( handle, keywordTick );
      isAxisLog = strcmp( get(handle,keywordScale), 'log' );
      [pTicks, pTickLabels] = matlabTicks2pgfplotsTicks( m2t, ticks, tickLabels, isAxisLog );
  end
  hasMinorTicks = strcmp( get( handle, keywordMinorTick ), 'on' );

end
% =========================================================================
function [pTicks, pTickLabels] = ...
    matlabTicks2pgfplotsTicks( m2t, ticks, tickLabels, isLogAxis )
  % Converts MATLAB style ticks and tick labels to pgfplots style
  % ticks and tick labels (if at all necessary).

  if isempty( ticks )
      pTicks      = '\empty';
      pTickLabels = [];
      return
  end

  % set ticks + labels
  pTicks = join( num2cell(ticks), ',' );

  % if there's no specific labels, return empty
  if isempty( tickLabels ) || (length(tickLabels)==1 && isempty(tickLabels{1}))
      pTickLabels = [];
      return
  end

  % sometimes tickLabels are cells, sometimes plain arrays
  % -- unify this to cells
  if ischar( tickLabels )
      tickLabels = strtrim( mat2cell( tickLabels,                    ...
                                     ones( size(tickLabels,1), 1 ), ...
                                     size( tickLabels, 2 )          ...
                                   ) ...
                         );
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Check if tickLabels are really necessary (and not already covered by
  % the tick values themselves).
  plotLabelsNecessary = false;

  k = find( ticks ~= 0.0, 1 ); % get an index with non-zero tick value
  if isLogAxis || isempty( k ) % only a 0-tick
      scalingFactor = 1;
  else
      % When plotting axis, MATLAB might scale the axes by a factor of ten,
      % say 10^n, and plot a 'x 10^k' next to the respective axis. This is
      % common practice when the tick marks are really large or small
      % numbers.
      % Unfortunately, MATLAB doesn't contain the information about the
      % scaling anywhere in the plot, and at the same time the {x,y}TickLabels
      % are given as t*10^k, thus no longer corresponding to the actual
      % value t.
      % Try to find the scaling factor here. This is then used to check
      % whether or not explicit {x,y}TickLabels are really necessary.
      s = str2double( tickLabels{k} );
      scalingFactor = ticks(k)/s;
      % check if the factor is indeed a power of 10
      S = log10(scalingFactor);
      if abs(round(S)-S) > m2t.tol
          scalingFactor = 1.0;
      end
  end

  for k = 1:min(length(ticks),length(tickLabels))
      % Don't use str2num here as then, literal strings as 'pi' get
      % legally transformed into 3.14... and the need for an explicit
      % label will not be recognized. str2double returns a NaN for 'pi'.
      if isLogAxis
          s = 10^( str2double(tickLabels{k}) );
      else
          s = str2double( tickLabels{k} );
      end
      if isnan(s)  ||  abs(ticks(k)-s*scalingFactor) > m2t.tol
          plotLabelsNecessary = true;
          break;
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if plotLabelsNecessary
      % if the axis is logscaled, MATLAB does not store the labels,
      % but the exponents to 10
      if isLogAxis
          for k = 1:length(tickLabels)
              if isnumeric( tickLabels{k} )
                  str = num2str( tickLabels{k} );
              else
                  str = tickLabels{k};
              end
              tickLabels{k} = sprintf( '$10^{%s}$', str );
          end
      end
      pTickLabels = join( tickLabels, ',' );
  else
      pTickLabels = [];
  end

end
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
function [m2t, colorLiteral] = rgb2colorliteral( m2t, rgb )
  % Translates an rgb value to an xcolor literal -- if possible!
  % If not, it returns the empty string.
  % This allows for a cleaner output in cases where predefined colors are
  % being used.
  %
  % Take a look at xcolor.sty for the color definitions.
  % TODO Implement mixtures with colors other than 'black' such as red!50!green.

  xcolColorNames = { 'red', 'green', 'blue', 'brown', ...
                     'lime', 'orange', 'pink', 'purple', ...
                     'teal', 'violet', 'black', 'darkgray', ...
                     'gray', 'lightgray', 'white' };
  xcolColorSpecs = { [1,0,0], [0,1,0], [0,0,1], [0.75,0.5,0.25], ...
                     [0.75,1,0], [1,0.5,0], [1,0.75,0.75], [0.75,0,0.25], ...
                     [0,0.5,0.5], [0.5,0,0.5], [0,0,0], [0.25,0.25,0.25], ...
                     [0.5,0.5,0.5], [0.75,0.75,0.75], [1,1,1] };

% The colors 'cyan', 'magenta', 'yellow', and 'olive' within xcolor.sty
% are defined in the CMYK color space, with an approximation in RGB.
% Unfortunately, the approximation is not very close (particularly for
% cyan), so just redefine those colors.
%    'cyan', 'magenta', 'yellow', 'olive'
%    [0,1,1], [1,0,1], [1,1,0], [0.5,0.5,0]

  % Check 'rgb' against all xcolor literals and the already defined colors.
  colorNames = [xcolColorNames, m2t.extraRgbColorNames];
  colorSpecs = [xcolColorSpecs, m2t.extraRgbColorSpecs];

  numCols = length(colorSpecs);

  % Check if RGB is a multiple of a predefined color.
  for k = 1:numCols
      if colorSpecs{k}(1) ~= 0.0
          alpha = rgb(1) / colorSpecs{k}(1);
      elseif colorSpecs{k}(2) ~= 0.0
          alpha = rgb(2) / colorSpecs{k}(2);
      elseif colorSpecs{k}(3) ~= 0.0
          alpha = rgb(3) / colorSpecs{k}(3);
      else % colorSpecs{k} = [0,0,0]
          alpha = 0.0;
      end
      if isequal( rgb, alpha * colorSpecs{k} )
          if alpha == 1.0
              colorLiteral = colorNames{k};
              return
          elseif alpha == 0.0
              colorLiteral = 'black';
              return
          elseif 0.0 < alpha && alpha < 1.0 && round(alpha*100) == alpha*100
              % Not sure if that last condition is necessary.
              colorLiteral = [ colorNames{k}, sprintf('!%g!black', alpha*100) ];
              return
          end
      end
  end

  % Color was not found in the default set. Need to define it.
  colorLiteral = sprintf( 'mycolor%d', length(m2t.extraRgbColorNames)+1 );
  m2t.extraRgbColorNames{end+1} = colorLiteral;
  m2t.extraRgbColorSpecs{end+1} = rgb;

end
% =========================================================================
function newstr = join( cellstr, delimiter )
  % This function joins a cell of strings to a single string (with a
  % given delimiter inbetween two strings, if desired).
  %
  % Example of usage:
  %              join( cellstr, ',' )

  if ~iscellstr( cellstr ) && ~isnumeric( cellstr{1} )
      % display value of cellstr as debug information
      disp( cellstr )
      error( 'Expected cellstr or numeric.' );
  end

  if isempty(cellstr)
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
function str = my_num2str( num )
  % Returns a number to a string in a *short* form.

  if ~isnumeric( num )
      error( 'num2str_short: Invalid input.' )
  end

  str = num2str( num, '%.15g' );

end
% =========================================================================
function dimension = getAxesDimensions( handle, ...
                                        widthString, heightString ) % optional
  % Returns the physical dimension of the axes.

  [width, height, unit] = getNaturalAxesDimensions( handle );

  % get the natural width-height ration of the plot
  axesWidthHeightRatio = width / height;
  % check matlab2tikz arguments
  if ~isempty( widthString )
      width = extractValueUnit( widthString );
  end
  if ~isempty( heightString )
      height = extractValueUnit( heightString );
  end

  % prepare the output
  if ~isempty( widthString ) && ~isempty( heightString )
      dimension.x.unit  = width.unit;
      dimension.x.value = width.value;
      dimension.y.unit  = height.unit;
      dimension.y.value = height.value;
  elseif ~isempty( widthString )
      dimension.x.unit  = width.unit;
      dimension.x.value = width.value;
      dimension.y.unit  = width.unit;
      dimension.y.value = width.value / axesWidthHeightRatio;
  elseif ~isempty( heightString )
      dimension.y.unit  = height.unit;
      dimension.y.value = height.value;
      dimension.x.unit  = height.unit;
      dimension.x.value = height.value * axesWidthHeightRatio;
  else % neither width nor height given
      dimension.x.unit  = unit;
      dimension.x.value = width;
      dimension.y.unit  = unit;
      dimension.y.value = height;
  end

  return;
end
% =========================================================================
function [width, height, unit] = getNaturalAxesDimensions( handle )
  daspectmode = get( handle, 'DataAspectRatioMode' );
  position    = get( handle, 'Position' );
  units       = get( handle, 'Units' );

      % Convert the MATLAB unit strings into TeX unit strings.
      switch units
          case 'pixels'
                  units = 'px';
          case 'centimeters'
                  units = 'cm';
          case 'inches'
                  units = 'in';
          case 'points'
                  units = 'pt';
          case 'characters'
                  units = 'em';
      end

  switch daspectmode
      case 'auto'
        % ---------------------------------------------------------------------
        % The plot will use the full size of the current figure.,
        if strcmp( units, 'normalized' )
            % The dpi is needed to associate the size on the screen (in pixels)
            % to the physical size of the plot (on a pdf, for example).
            % Unfortunately, MATLAB doesn't seem to be able to always make a
            % good guess about the current DPI (a bug is filed for this on
            % mathworks.com).
            dpi = get( 0, 'ScreenPixelsPerInch' );

            unit = 'in';
            figuresize = get( gcf, 'Position' );

            width  = position(3) * figuresize(3) / dpi;
            height = position(4) * figuresize(4) / dpi;

        else % assume that TikZ knows the unit (in, cm,...)
            unit   = units;
            width  = position(3);
            height = position(4);
        end
        % ---------------------------------------------------------------------

      case 'manual'
        % ---------------------------------------------------------------------
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

            unit = 'in';
            figuresize = get( gcf, 'Position' );

            width = position(3) * figuresize(3) / dpi;

        else % assume that TikZ knows the unit
            unit  = units;
            width = position(3);
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
        height = width                                  ...
                * aspectRatio(1)    / aspectRatio(2)     ...
                * (yLim(2)-yLim(1)) / (xLim(2)-xLim(1));
        % ---------------------------------------------------------------------
      otherwise
        error( 'getAxesDimensions:illDaspectMode', ...
              'Illegal DataAspectRatioMode ''%s''.', daspectmode );
  end
end
% =========================================================================
% decompose m2t.cmdOpts.Results.width into value and unit
function out = extractValueUnit( str )

    % Regular expression to match '4.12cm', '\figurewidth', ...
    fp_regex = '[-+]?\d*\.?\d*(?:e[-+]?\d+)?';
    pattern = strcat( '(', fp_regex, ')?', '(\\?[a-z]+)' );

    [s,e,te,m,t,nm] = regexp( str, pattern, 'match' );

    if length(t)~=1
        error( 'getAxesDimensions:illegalLength', ...
               'The width string ''%s'' could not be decomposed into value-unit pair.', str );
    end

    if length(t{1}) == 1
        out.value = 1.0; % such as in '1.0\figurewidth'
        out.unit  = strtrim( t{1}{1} );
    elseif length(t{1}) == 2 && isempty(t{1}{1})
        % MATLAB(R) does this:
        % length(t{1})==2 always, but the first field may be empty.
        out.value = 1.0;
        out.unit  = strtrim( t{1}{2} );
    elseif length(t{1}) == 2
        out.value = str2double( t{1}{1} );
        out.unit  = strtrim( t{1}{2} );
    else
        error( 'getAxesDimensions:illegalLength', ...
               'The width string ''%s'' could not be decomposed into value-unit pair.', str );
    end
end
% =========================================================================
function newstr = escapeCharacters( str )
  % Replaces the single characters % and \ by their escaped versions
  % %% and \\, respectively.

  newstr = str;
  newstr = strrep( newstr, '%' , '%%'    );
  newstr = strrep( newstr, '\' , '\\'    );

end
% =========================================================================
function out = isVisible( handle )
  % Determines whether an object is actually visible or not.
  out = strcmp( get(handle,'Visible'), 'on' );
end
% =========================================================================
function [visibleAxesHandles,alignmentOptions,plotOrder] =...
    alignSubPlots( m2t, axesHandles )
  % Returns the alignment options for all the axes enviroments.
  % The question whether two plots are aligned on the left, right, top, or
  % bottom is answered by looking at the 'Position' property of the
  % axes object.
  %
  % The second output argument 'ix' is the order in which the axes
  % environments need to be created. This is to make sure that plots
  % which act as a reference are processed first.
  %
  % The output vector 'alignmentOptions' contains:
  %     - whether or not it is a reference (.isRef)
  %     - axes name  (.name), only set if .isRef is true
  %     - the actual pgfplots options (.opts)
  %
  % The routine tries to be smart in the sense that it will detect that in
  % a setup such as
  %
  %  [ AXES1 AXES2 ]
  %  [ AXES3       ]
  %
  % 'AXES1' will serve as a reference for AXES2 and AXES3.
  % It does so by first computing a 'dependency' graph, then traversing
  % the graph starting from a node (AXES) with maximal connections.
  %
  % TODO:
  %     - diagonal connections 'a la
  %              [ AXES1       ]
  %              [       AXES2 ]
  %
  % TODO: fix this function
  % TODO: look for unique IDs of the axes enviroments
  %       which could be returned along with its properties

  numVisibleHandles = 0;
  for k = 1:length(axesHandles)
      if axisIsVisible( axesHandles(k) )
          numVisibleHandles = numVisibleHandles+1;
          visibleAxesHandles(numVisibleHandles) = axesHandles(k);
      end
  end

  % initialize alignmentOptions
  alignmentOptions = struct([]);
  for k = 1:numVisibleHandles
      alignmentOptions(k).isElderTwin   = 0;
      alignmentOptions(k).isYoungerTwin = 0;
      alignmentOptions(k).opts          = cell(0);
  end

  % return immediately if nothing is to be aligned
  if numVisibleHandles <= 1
      plotOrder = 1;
      return
  end

  % Connectivity matrix of the graph.
  % Contains 0's where the axes environments are not aligned, and
  % positive integers where they are. The integer encodes how the axes
  % are aligned (top right:bottom left, and so on).
  C = zeros(numVisibleHandles,numVisibleHandles);

  % 'isRef' tells whether the respective plot acts as a position reference
  % for another plot.
  % TODO: preallocate this
  % Also, gather all the positions.
  axesPos     = zeros(numVisibleHandles,4);
  cbarHandles = [];  % indices of color bar handles;
                     % they need to be treated separately
  for k = 1:numVisibleHandles
      % treat color bars later
      if strcmp( get(visibleAxesHandles(k),'Tag'), 'Colorbar' )
          cbarHandles = [ cbarHandles, k ];
          continue
      end

      % 'axesPos(i,:)' contains
      %     (indices 1,3): the x-value of the left and the right axis, and
      %     (indices 2,4): the y-value of the bottom and top axis,
      % of plot no. 'i'
      axesPos(k,:) = get( visibleAxesHandles(k), 'Position' );
      axesPos(k,3) = axesPos(k,1) + axesPos(k,3);
      axesPos(k,4) = axesPos(k,2) + axesPos(k,4);
  end

  % Unfortunately, MATLAB doesn't seem to exactly align color bars
  % to its parent plot. Hence, some quirking is needed.
  nonCbarHandles              = (1:numVisibleHandles);
  nonCbarHandles(cbarHandles) = [];
  for k = cbarHandles
      axesPos(k,:) = correctColorbarPos( visibleAxesHandles(k), ...
                                         axesPos(nonCbarHandles,:) );
  end

  % now, the color bars are nicely aligned with the plots


  % Loop over all figures to see if axes are aligned.
  % Look for exactly *one* alignment, even if there might be more.
  %
  % Among all the {x,y}-alignments choose the one with the closest
  % {y,x}-distance. This is important, for example, in situations where
  % there are 3 plots on top of each other:
  % we want no. 2 to align below no. 1, and no. 3 below no. 2
  % (and not no. 1 again).
  %
  % There are nine alignments this algorithm can deal with:
  %
  %    3|             |4
  %  __  _____________   __
  %  -2 |             |  2
  %     |             |
  %     |      5      |
  %     |             |
  %     |             |
  % -1_ |_____________|  1_
  %
  %   -3|             |-4
  %
  % They are coded in numbers -4 through 5. The matrix C will contain the
  % corresponding code at position (i,j), if plot number i and j are
  % aligned in such a way.
  % If two plots happen to coincide at both left and right axes, for
  % example, only one relation is stored.
  %
  for i = 1:numVisibleHandles
      for j = i+1:numVisibleHandles
          if max(abs(axesPos(i,:)-axesPos(j,:))) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % twins
              C(i,j) =  5;
              C(j,i) = -5;
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,1)-axesPos(j,1) ) < m2t.tol;
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

          elseif abs( axesPos(i,1)-axesPos(j,3) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % left axis of 'i' aligns with right axis of 'j'
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -3;
                  C(j,i) =  4;
              else
                  C(i,j) =  3;
                  C(j,i) = -4;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,3)-axesPos(j,1) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % right axis of 'i' aligns with left axis of 'j'
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -4;
                  C(j,i) =  3;
              else
                  C(i,j) =  4;
                  C(j,i) = -3;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,3)-axesPos(j,1) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % right axes of 'i' and 'j' align
              if axesPos(i,2) > axesPos(j,2)
                  C(i,j) = -4;
                  C(j,i) =  4;
              else
                  C(i,j) =  4;
                  C(j,i) = -4;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,2)-axesPos(j,2) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % lower axes of 'i' and 'j' align
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -1;
                  C(j,i) =  1;
              else
                  C(i,j) =  1;
                  C(j,i) = -1;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,2)-axesPos(j,4) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % lower axis of 'i' aligns with upper axis of 'j'
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -1;
                  C(j,i) =  2;
              else
                  C(i,j) =  1;
                  C(j,i) = -2;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,4)-axesPos(j,2) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % upper axis of 'i' aligns with lower axis of 'j'
              if axesPos(i,1) > axesPos(j,1)
                  C(i,j) = -2;
                  C(j,i) =  1;
              else
                  C(i,j) =  2;
                  C(j,i) = -1;
              end
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          elseif abs( axesPos(i,4)-axesPos(j,4) ) < m2t.tol
              % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
              % upper axes of 'i' and 'j' align
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
  for i = 1:numVisibleHandles
      for j = 1:numVisibleHandles % everything except 'i'

          if C(i,j)==0 || abs(C(i,j))==5 % don't check for double zeros (aka "no relation"'s) or triplets, quadruplets,...
              continue
          end

          % find doubles, and count C(i,j) in
          doub = find( C(i,j:numVisibleHandles)==C(i,j) ) ...
               + j-1; % to get the actual index

          if length(doub)>1
              % Uh-oh, found doubles:
              % Pick the one with the minimal distance, delete the other
              % relations.
              switch C(i,j)
                  case {1,2}    % all plots sit right of 'i'
                      dist = axesPos(doub,1) - axesPos(i,3);
                  case {-1,-2}  % all plots sit left of 'i'
                      dist = axesPos(i,1) - axesPos(doub,3);
                  case {3,4}    % all plots sit above 'i'
                      dist = axesPos(doub,2) - axesPos(i,4);
                  case {-3,-4}  % all plots sit below 'i'
                      dist = axesPos(i,2) - axesPos(doub,4);
                  otherwise
                      error( 'alignSubPlots:illCode', ...
                             'Illegal alignment code %d.', C(i,j) );
              end

              [dummy,idx] = min( dist ); % 'idx' holds the index of the minimum.
                                         % If there is more than one, then
                                         % 'idx' has twins. min returns the one
                                         % with the lowest index.

              % delete the index from the 'remove list'
              doub(idx) = [];
              C(i,doub) = 0;
              C(doub,i) = 0;
          end

      end
  end

  % Alright. The matrix 'C' now contains exactly the alignment info that
  % we are looking for.

  % Is each axes environment connected to at least one other?
  noConn = find( ~any(C,2) );
  if ~isempty(noConn)
      for k = 1:length(noConn)
          userWarning( m2t, [ 'The axes environment no. %d is not aligned with',...
                              ' any other axes environment and will be plotted',...
                              ' right in the middle.' ], noConn(k) );
      end
  end

  % Now, actually go ahead and process the info to return pgfplots alignment
  % options.

  % Sort the axes environments by the number of connections they have.
  % That means: start with the plot which has the most connections.
  [dummy,ix] = sort( sum(C~=0, 2), 'descend' );
  plotOrder = zeros(1,numVisibleHandles);
  plotNumber = 0;
  for k = 1:numVisibleHandles
      [plotOrder,plotNumber,alignmentOptions] = setOptionsRecursion( plotOrder, plotNumber, C, alignmentOptions, ix(k), [] );
  end

  % Burkart, July 23, 2011:
  % Now let's rearrange the plot order.
  % Theoretically this should be harmful in that it would result in
  % subplots that refer to another named subplot to be drawn before the
  % named subplot itself is drawn. However, this reordering actually fixes
  % one such problem that only occurred in Octave with test case
  % subplot2x2b. Oddly enough the error only showed when certain other test
  % cases (including subplot2x2b itself) had been run beforehand and not if
  % subplot2x2b was the first / only test case to be run or if a harmless
  % test case like one_point preceded subplot2x2b.
  % The exact mechanism that led to this bug was not uncovered but a
  % differently ordered axesPos near the top of this function eventually
  % led to the wrong plotOrder and thus to a subplot referring to one that
  % came later in the TikZ output.
  % The reordering was tested against the test suite and didn't break any
  % of the test cases, neither on Octave nor on MATLAB.
  newPlotOrder = zeros(1,numVisibleHandles);
  for k = 1:numVisibleHandles
      newPlotOrder(plotOrder(k)) = k;
  end
  plotOrder = newPlotOrder;

  return
end
% -----------------------------------------------------------------------
% sets the alignment options for a specific node
% and passes on the its children
% -----------------------------------------------------------------------
function [plotOrder, plotNumber, alignmentOptions] = setOptionsRecursion( plotOrder, plotNumber, C, alignmentOptions, k, parent )

    % return immediately if is has been processed before
    if plotOrder(k)
        return
    end

    plotNumber = plotNumber + 1;

    % TODO not looking at twins is probably not the right thing to do
    % find the non-zero elements in the k-th row
    unprocessedFriends = find( C(k,:)~=0 & ~plotOrder );

    unprocessedChildren = unprocessedFriends( abs(C(k,unprocessedFriends))~=5 );
    unprocessedTwins    = unprocessedFriends( abs(C(k,unprocessedFriends))==5 );

    if length(unprocessedTwins) == 1
        alignmentOptions(k).isElderTwin = 1;
    elseif length(unprocessedTwins) > 1
        error( 'setOptionsRecursion:twoTwins',...
               'More than one twin axes discovered.' );
    end

    if ~isempty(unprocessedChildren) % Are there unprocessed children?
        % Give these axes a name.
        alignmentOptions(k).opts{end+1} = sprintf( 'name=plot%d', k );
    end

    if ~isempty( parent ) % if a parent is given
        if ( abs(C(parent,k))==5 ) % don't apply "at=" for younger twins
            alignmentOptions(k).isYoungerTwin = 1;
        else
            % See were this node sits with respect to its parent,
            % and adapt the option accordingly.
            anchor = cornerCode2pgfplotOption( C(k,parent) );
            refPos = cornerCode2pgfplotOption( C(parent,k) );

            % add the option
            alignmentOptions(k).opts{end+1} = ...
                sprintf('at=(plot%d.%s), anchor=%s', parent, refPos, anchor);
        end
    end

    plotOrder(k) = plotNumber;

    % Recursively loop over all dependent 'child' axes;
    % first the twins, though, to make sure they appear consecutively
    % in the TikZ file.
    for ii = unprocessedTwins
        [plotOrder,plotNumber,alignmentOptions] = setOptionsRecursion( plotOrder, plotNumber, C, alignmentOptions, ii, k );
    end
    for ii = unprocessedChildren
        [plotOrder,plotNumber,alignmentOptions] = setOptionsRecursion( plotOrder, plotNumber, C, alignmentOptions, ii, k );
    end

end
% =========================================================================
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
% =========================================================================
function pos = correctColorbarPos( colBarHandle, axesHandlesPos )
  % The handle 'colBarHandle' is the handle of a color bar,
  % 'axesHandlesPos' a (nx4)-matrix containing the positions of all
  % *non-colorbar* handles.
  % The function looks for the color bar's parent and returnes the position
  % "as it should be".

  colBarPos    = get( colBarHandle, 'Position' );
  colBarPos(3) = colBarPos(1) + colBarPos(3);
  colBarPos(4) = colBarPos(2) + colBarPos(4);

  loc = get( colBarHandle, 'Location' );

  % get the ID of the refence axes of the color bar
  refAxesId  = getReferenceAxes( loc, colBarPos, axesHandlesPos );
  refAxesPos = axesHandlesPos(refAxesId,:);

  % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
  % small cased ('northoutside'). Hence, use lower() for uniformity.
  switch lower( loc )
      case { 'north', 'south', 'east', 'west' }
          userWarning( m2t, 'alignSubPlots:getColorbarPos',                     ...
                        'Don''t know how to deal with inner colorbars yet.' );
          return;

      case {'northoutside','southoutside'}
          pos = [ refAxesPos(1), ...
                  colBarPos(2) , ...
                  refAxesPos(3), ...
                  colBarPos(4)       ];

      case {'eastoutside','westoutside'}
          pos = [ colBarPos(1) , ...
                  refAxesPos(2), ...
                  colBarPos(3) , ...
                  refAxesPos(4)      ];

      otherwise
          error( 'alignSubPlots:getColorbarPos',    ...
                  'Unknown ''Location'' %s.', loc  );
  end

end
% =========================================================================
function refAxesId = getReferenceAxes( loc, colBarPos, axesHandlesPos )

  % if there is only one axes reference handle, it must be the parent
  if size(axesHandlesPos,1) == 1
      refAxesId = 1;
      return;
  end

  % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
  % small cased ('northoutside'). Hence, use lower() for uniformity.
  switch lower( loc )
      case { 'north', 'south', 'east', 'west' }
          userWarning( m2t, 'Don''t know how to deal with inner colorbars yet.' );
          return;

      case {'northoutside'}
          % scan in 'axesHandlesPos' for the handle number that lies
          % directly below colBarHandle
          [m,refAxesId]  = min( colBarPos(2) ...
                                - axesHandlesPos(axesHandlesPos(:,4)<colBarPos(2),4) );

      case {'southoutside'}
          % scan in 'axesHandlesPos' for the handle number that lies
          % directly above colBarHandle
          [m,refAxesId]  = min( axesHandlesPos(axesHandlesPos(:,2)>colBarPos(4),2)...
                            - colBarPos(4) );

      case {'eastoutside'}
          % scan in 'axesHandlesPos' for the handle number that lies
          % directly left of colBarHandle
          [m,refAxesId]  = min( colBarPos(1) ...
                            - axesHandlesPos(axesHandlesPos(:,3)<colBarPos(1),3) );

      case {'westoutside'}
          % scan in 'axesHandlesPos' for the handle number that lies
          % directly right of colBarHandle
          [m,refAxesId]  = min( axesHandlesPos(axesHandlesPos(:,1)>colBarPos(3),1) ...
                            - colBarPos(3)  );

      otherwise
          error( 'getReferenceAxes:illLocation',    ...
                  'Illegal ''Location'' ''%s''.', loc  );
  end

end
% =========================================================================
function userInfo( m2t, message, varargin )
  % Display usage information.

  if m2t.cmdOpts.Results.silent || ~m2t.cmdOpts.Results.showInfo
      return
  end

  mess = sprintf(message, varargin{:});

  % Replace '\n' by '\n *** ' and print.
  mess = strrep( mess, sprintf('\n'), sprintf('\n *** ') );
  fprintf( ' *** %s\n', mess );

end
% =========================================================================
function userWarning( m2t, message, varargin )
  % Drop-in replacement for warning().

  if m2t.cmdOpts.Results.silent || ~m2t.cmdOpts.Results.showWarnings
      return
  end

  warning( 'matlab2tikz:userWarning', message, varargin{:} );

end
% =========================================================================
function root = append( root, appendix )
    if isempty(appendix)
        return;
    end
    if ~ischar(appendix)
        error( 'Argument must be of class ''string''.' );
    end

    root.content{end+1} = appendix;
    return;
end
% =========================================================================
function parent = addChildren( parent, children )

    if isempty(children)
        return;
    end

    if iscell(children)
        for k = 1:length(children)
            parent = addChildren( parent, children{k} );
        end
    else
        if isempty( parent.children )
            parent.children = {children};
        else
            parent.children = {parent.children{:} children};
        end
    end

    return;
end
% =========================================================================
function printAll( env, fid )

    if ~isempty(env.comment)
        fprintf( fid, '%% %s\n', strrep( env.comment, sprintf('\n'), sprintf('\n%% ') ) );
    end

    if isfield(env, 'colors') && ~isempty(env.colors)
        fprintf( fid, '%s', env.colors);
    end

    if isempty( env.options )
        fprintf( fid, '\\begin{%s}\n', env.name );
    else
        fprintf( fid, '\\begin{%s}[%%\n%s]\n', env.name, join(env.options, sprintf(',\n')) );
    end

    for k = 1:length(env.content)
        fprintf( fid, '%s', env.content{k} );
    end

    for k = 1:length( env.children )
        if ischar( env.children{k} )
            fprintf( fid, escapeCharacters( env.children{k}) );
        else
            fprintf( fid, '\n' );
            printAll( env.children{k}, fid );
        end
    end

    % End the tikpicture environment with an empty comment and no newline.
    % Thus no additional space is generated by the tikzpicture in TeX.
    % This is useful if something should immediately follow the picture,
    % e.g. another picture, with a separately defined spacing or without
    % any spacing at all between both pictures.
    if strcmp(env.name, 'tikzpicture')
        fprintf( fid, '\\end{%s}%%', env.name );
    else
        fprintf( fid, '\\end{%s}\n', env.name );
    end
end
% =========================================================================
function imwriteWrapperPNG( colorData, cmap, fileName )
    % Write an indexed or a truecolor image
    if ndims( colorData ) == 2
        % According to imwrite's documentation there is support for 1-bit,
        % 2-bit, 4-bit and 8-bit (i.e., 256 colors) indexed images only.
        % When having more colors, a truecolor image must be generated and
        % used instead.
        if size( cmap, 1 ) <= 256
            imwrite ( colorData, cmap, fileName, 'png' );
        else
            imwrite ( ind2rgb(colorData, cmap), fileName, 'png' );
        end
    else
        imwrite ( colorData, fileName, 'png' );
    end
end
% =========================================================================
function env = getEnvironment()
  env = '';
  % Check if we are in MATLAB or Octave.
  % 'ver' in MATLAB gives versioning information on all installed packages
  % separately, and there is no guarantee that MATLAB itself is listed first.
  % Hence, loop through the array and try to find 'MATLAB' or 'Octave'.
  versionData = ver;
  for k = 1:max(size(versionData))
      if strcmp( versionData(k).Name, 'MATLAB' )
          env = 'MATLAB';
          break;
      elseif strcmp( versionData(k).Name, 'Octave' )
          env = 'Octave';
          break;
      end
  end
end
% =========================================================================
function versionString = findEnvironmentVersion( env )
  % Get version string for 'env' by iterating over all toolboxes.
  versionString = [];
  for versionDatum = ver
      if strcmp( versionDatum.Name, env )
          % found it: store and exit the loop
          versionString = versionDatum.Version;
          break
      end
  end
end
% =========================================================================
function isBelow = isVersionBelow(env, versionA, versionB)
  % Checks if version string or vector versionA is smaller than
  % version string or vector versionB.

  if ischar(versionA)
      % Translate version string from '2.62.8.1' to [2, 62, 8, 1].
      if strcmpi(env, 'MATLAB')
          split = regexp(versionA, '\.', 'split');
      elseif strcmpi(env, 'Octave')
          split = strsplit(versionA, '.');
      end
      vA = str2num(char(split));
  else
      vA = versionA;
  end

  if ischar(versionB)
      % Translate version string from '2.62.8.1' to [2, 62, 8, 1].
      if strcmpi(env, 'MATLAB')
          split = regexp(versionB, '\.', 'split');
      elseif strcmpi(env, 'Octave')
          split = strsplit(versionB, '.');
      end
      vB = str2num(char(split));
  else
      vB = versionB;
  end

  m = min(length(vA), length(vB));
  vA = vA(1:m);
  vB = vB(1:m);
  isBelow = any(vA(:) < vB(:));
end
% =========================================================================
function [retval] = switchMatOct( m2t, matlabValue, octaveValue )
  % Returns one of two provided values depending on whether matlab2tikz is
  % run on MATLAB or on Octave.

  switch m2t.env
      case 'MATLAB'
          retval = matlabValue;
      case 'Octave'
          retval = octaveValue;
      otherwise
          error( 'Unknown environment. Need MATLAB(R) or Octave.' )
  end
end
% =========================================================================
function string = prettyPrint( m2t, string, interpreter )
  % Some resources on how MATLAB handles rich (TeX) markup:
  % http://www.mathworks.com/help/techdoc/ref/text_props.html#String
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  % http://www.mathworks.com/help/techdoc/ref/text_props.html#Interpreter
  % http://www.mathworks.com/help/techdoc/ref/text.html#f68-481120

  % If the user set the matlab2tikz parameter 'parseStrings' to false, no
  % parsing of strings takes place, thus making the user 100% responsible.
  if ~m2t.cmdOpts.Results.parseStrings
      return
  end

  % Make sure we have a valid interpreter set up
  if ~any( strcmpi( interpreter, {'latex', 'tex', 'none'} ))
      userWarning( m2t, 'Don''t know interpreter ''%s''. Default handling.', interpreter );
      interpreter = 'tex';
  end

  % The interpreter property of the text element defines how the string
  % is parsed
  switch lower( interpreter )
      case 'latex' % Basic subset of the LaTeX markup language

          % Replace $$...$$ with $...$ but otherwise leave untouched
          string = regexprep( string, '^\$\$(.*)\$\$$', '$$1$' );

      case 'tex' % Subset of plain TeX markup language

          % Parse string piece-wise in separate function.
          string = parseTexString( m2t, string );

      case 'none' % Literal characters

          % Only make special characters TeX compatible

          string = strrep( string, '\', '\textbackslash{}' );
          % Note: '{' and '}' can't be converted to '\{' and '\}',
          %       respectively, via strrep(...) as this would lead to
          %       backslashes converted to '\textbackslash\{\}' because
          %       the backslash was converted to '\textbackslash{}' in
          %       the previous step. Using regular expressions with
          %       negative look-behind makes sure any braces in 'string'
          %       were not introduced by escaped backslashes.
          %       Also keep in mind that escaping braces before backslashes
          %       would not remedy the issue -- in that case 'string' would
          %       contain backslashes introduced by brace escaping that are
          %       not supposed to be printable characters.
          repl = switchMatOct( m2t, '\\{', '\{' );
          string = regexprep( string, '(?<!\\textbackslash){', repl );
          repl = switchMatOct( m2t, '\\}', '\}' );
          string = regexprep( string, '(?<!\\textbackslash{)}', repl );
          string = strrep( string, '$', '\$' );
          string = strrep( string, '%', '\%' );
          string = strrep( string, '_', '\_' );
          string = strrep( string, '^', '\textasciicircum{}' );
          string = strrep( string, '#', '\#' );
          string = strrep( string, '&', '\&' );
          string = strrep( string, '~', '\textasciitilde{}' ); % or '\~{}'
          % Clean up: remove superfluous '{}' if it's followed by a backslash
          string = strrep( string, '{}\', '\' );
          % Clean up: remove superfluous '{}' at the end of 'string'
          string = regexprep( string, '\{\}$', '' );

          % Make sure to return a string and not a cellstr.
          if iscellstr( string )
              string = string{1};
          end

  end

end
% =========================================================================
function parsed = parseTexString ( m2t, string )

  % Convert cell string to regular string, otherwise MATLAB complains
  if iscellstr( string )
      string = string{:};
  end

  % Get the position of all braces
  bracesPos = regexp( string, '\{|\}' );

  % Exclude braces that are part of any of these MATLAB-supported TeX commands:
  % \color{...}  \color[...]{...}  \fontname{...}  \fontsize{...}
  [sCmd, eCmd] = regexp( string, '\\(color(\[[^\]]*\])?|fontname|fontsize)\{[^}]*\}' );
  for i = 1:length(sCmd)
      bracesPos( bracesPos >= sCmd(i) & bracesPos <= eCmd(i) ) = [];
  end

  % Exclude braces that are preceded by an odd number of backslashes which
  % means the brace is escaped and thus to be printed, not a grouping brace
  expr = '(?<!\\)(\\\\)*\\(\{|\})';
  escaped = regexp( string, expr, 'end' );
  % It's necessary to go over 'string' with the same RegEx again to catch
  % overlapping matches, e.g. string == '\{\}'. In such a case the simple
  % regexp(...) above only finds the first brace. What we have to do is look
  % only at the part of 'string' that starts with the first brace but doesn't
  % encompass its escaping backslash. Iterating over all previously found
  % matches makes sure all overlapping matches are found, too. That way even
  % cases like string == '\{\} \{\}' are handled correctly.
  % The call to unique(...) is not necessary to get the behavior described, but
  % by removing duplicates in 'escaped' it's cleaner than without.
  for i = escaped
      escaped = unique( [escaped, regexp( string(i:end), expr, 'end' ) + i-1] );
  end
  % Now do the actual removal of escaped braces
  for i = 1:length(escaped)
      bracesPos( bracesPos == escaped(i) ) = [];
  end

  parsed = '';
  % Have a virtual brace one character left of where the actual string
  % begins (remember, MATLAB strings start counting at 1, not 0). This is
  % to make sure substrings left of the first brace get parsed, too.
  prevBracePos = 0;
  % Iterate over all the brace positions in order to split up 'string'
  % at those positions and then parse the substrings. A virtual brace is
  % added right of where the actual string ends to make sure substrings
  % right of the right-most brace get parsed as well.
  for currBracePos = [ bracesPos, length(string)+1 ]
      if (prevBracePos + 1) < currBracePos
          % Parse the substring between (but not including) prevBracePos
          % and currBracePos, i.e. between the previous brace and the
          % current one (but only if there actually is a non-empty
          % substring). Then append it to the output string.
          substring = string( prevBracePos+1 : currBracePos-1 );
          parsed = [ parsed, parseTexSubstring( m2t, substring ) ];
      end
      if currBracePos <= length(string)
          % Append the brace itself to the output string, but only if the
          % current brace position is within the limits of the string, i.e.
          % don't append anything for the last, virtual brace that is only
          % there to enable parsing of substrings beyond the right-most
          % actual brace.
          brace = string( currBracePos );
          parsed = [ parsed, brace ];
      end
      % The current brace position will be next iteration's previous one
      prevBracePos = currBracePos;
  end

  % Enclose everything in $...$ to use math mode
  parsed = [ '$' parsed '$' ];
  % ...except when everything is text
  parsed = regexprep( parsed, '^\$\\text\{([^}]*)\}\$$', '$1' );
                       % start-> $ \text {(non-}) } $<-end
  % ...or when the parsed string is empty
  parsed = regexprep( parsed, '^\$\$$', '' );

end
% =========================================================================
function string = parseTexSubstring ( m2t, string )

  % Keep a copy of the original input string for potential warning messages
  % referring to the string as it was originally used in MATLAB/Octave and
  % not the current value of the variable 'string' halfway into the m2t
  % conversion.
  origstr = string;

  % Font families (italic, bold, etc.) get a trailing '{}' because in
  % MATLAB they may be followed by a letter which would produce an error
  % in (La)TeX.
  for i = {'it', 'bf', 'rm', 'sl'}
      string = strrep( string, ['\' i{:}], ['\' i{:} '{}'] );
  end

  % The same holds true for special characters like \alpha
  % The list of MATLAB-supported TeX characters was taken from
  % http://www.mathworks.com/help/techdoc/ref/text_props.html#String
  named = {'alpha', 'angle', 'ast', 'beta', 'gamma', 'delta',     ...
           'epsilon', 'zeta', 'eta', 'theta', 'vartheta', 'iota', ...
           'kappa', 'lambda', 'mu', 'nu', 'xi', 'pi', 'rho',      ...
           'sigma', 'varsigma', 'tau', 'equiv', 'Im', 'otimes',   ...
           'cap', 'int', 'rfloor', 'lfloor', 'perp', 'wedge',     ...
           'rceil', 'vee', 'langle', 'upsilon', 'phi', 'chi',     ...
           'psi', 'omega', 'Gamma', 'Delta', 'Theta', 'Lambda',   ...
           'Xi', 'Pi', 'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega', ...
           'forall', 'exists', 'ni', 'cong', 'approx', 'Re',      ...
           'oplus', 'cup', 'subseteq', 'lceil', 'cdot', 'neg',    ...
           'times', 'surd', 'varpi', 'rangle', 'sim', 'leq',      ...
           'infty', 'clubsuit', 'diamondsuit', 'heartsuit',       ...
           'spadesuit', 'leftrightarrow', 'leftarrow',            ...
           'Leftarrow', 'uparrow', 'rightarrow', 'Rightarrow',    ...
           'downarrow', 'circ', 'pm', 'geq', 'propto', 'partial', ...
           'bullet', 'div', 'neq', 'aleph', 'wp', 'oslash',       ...
           'supseteq', 'nabla', 'ldots', 'prime', '0', 'mid',     ...
           'copyright'                                            };
  for i = named
      string = strrep( string, ['\' i{:}], ['\' i{:} '{}'] );
      % FIXME: Only append '{}' if there's an odd number of backslashes
      %        in front of the items from 'named'. If it's an even
      %        number instead, that means there's an escaped (printable)
      %        backslash and some text like "alpha" after that.
  end
  % Some special characters' names are subsets of others, e.g. '\o' is
  % a subset of '\omega'. This would produce undesired double-escapes.
  % For example if '\o' was converted to '\o{}' after '\omega' has been
  % converted to '\omega{}' this would result in '\o{}mega{}' instead of
  % '\omega{}'. Had '\o' been converted to '\o{}' _before_ '\omega' is
  % converted then the result would be '\o{}mega' and thus also wrong.
  % To circumvent the problem all those special character names that are
  % subsets of others are now converted using a regular expression that
  % uses negative lookahead. The special handling of the backslash is
  % required for MATLAB/Octave compatibility.
  string = regexprep(string, '(\\)o(?!mega|times|plus|slash)', '$1o{}');
  string = regexprep(string, '(\\)in(?!t|fty)', '$1in{}');
  string = regexprep(string, '(\\)subset(?!eq)', '$1subset{}');
  string = regexprep(string, '(\\)supset(?!eq)', '$1supset{}');

  % Convert '\0{}' (TeX text mode) to '\emptyset{}' (TeX math mode)
  string = strrep( string, '\0{}', '\emptyset{}' );

  % Add skip to \fontsize
  % This is required for a successful LaTeX run on the output as in contrast
  % to MATLAB/Octave it requires the skip parameter (even if it's zero)
  string = regexprep( string, '(\\fontsize\{[^}]*\})', '$1{0}' );

  % Put '\o{}' inside \text{...} as it is a text mode symbol that does not
  % exist in math mode (and LaTeX gives a warning if you use it in math mode)
  string = strrep( string, '\o{}', '\text{\o{}}' );

  % Put everything that isn't a TeX command inside \text{...}
  expr = '(\\[a-zA-Z]+(\[[^\]]*\])?(\{[^}]*\}){1,2})';
        % |(  \cmd   )(  [...]?   )(  {...}{1,2}  )|
        % (               subset $1                )
  repl = switchMatOct( m2t, '}$1\\text{', '}$1\text{' );
  string = regexprep( string, expr, repl );
      % ...\alpha{}... -> ...}\alpha{}\text{...
  string = [ '\text{' string '}' ];
      % ...}\alpha{}\text{... -> \text{...}\alpha{}\text{...}

  % '_' has to be in math mode so long as it's not escaped as '\_' in which
  % case it remains as-is. Extra care has to be taken to make sure any
  % backslashes in front of the underscore are not themselves escaped and
  % thus printable backslashes. This is the case if there's an even number
  % of backslashes in a row.
  repl = switchMatOct( m2t, '$1}_\\text{', '$1}_\text{' );
  string = regexprep( string, '(?<!\\)((\\\\)*)_', repl );

  % '^' has to be in math mode so long as it's not escaped as '\^' in which
  % case it is expressed as '\textasciicircum{}' for compatibility with
  % regular TeX. Same thing here regarding even/odd number of backslashes
  % as in the case of underscores above.
  repl = switchMatOct( m2t, '$1\\textasciicircum{}', '$1\textasciicircum{}' );
  string = regexprep( string, '(?<!\\)((\\\\)*)\\\^', repl );
  repl = switchMatOct( m2t, '$1}^\\text{', '$1}^\text{' );
  string = regexprep( string, '(?<!\\)((\\\\)*)\^', repl );

  % '\\' has to be escaped to '\textbackslash{}'
  % This cannot be done with strrep(...) as it would replace e.g. 4 backslashes
  % with three times the replacement string because it finds overlapping matches
  % (see http://www.mathworks.de/help/techdoc/ref/strrep.html)
  % Note: Octave's backslash handling is broken. Even though its output does
  % not resemble MATLAB's, the same m2t code is used for either software. That
  % way MATLAB-compatible code produces the same matlab2tikz output no matter
  % which software it's executed in. So long as this MATLAB incompatibility
  % remains in Octave you're probably better off not using backslashes in TeX
  % text anyway.
  string = regexprep( string, '(\\)\\', '$1textbackslash{}' );

  % '_', '^', '{', and '}' are already escaped properly, even in MATLAB's TeX
  % dialect (and if they're not, that's intentional)

  % Escape "$", "%", and "#" to make them compatible to true TeX while in
  % MATLAB/Octave they are not escaped
  string = strrep( string, '$', '\$' );
  string = strrep( string, '%', '\%' );
  string = strrep( string, '#', '\#' );

  % Escape "§" as "\S" since it can give UTF-8 problems otherwise.
  % The TeX string 'a_§' in particular lead to problems in Octave 3.6.0.
  % m2t transcoded that string into '$\text{a}_\text{*}\text{#}$' with
  % * = 0xC2 and # = 0xA7 which corresponds with the two-byte UTF-8
  % encoding. Even though this looks like an Octave bug that shows
  % during the '..._\text{abc}' to '..._\text{a}\text{bc}' conversion,
  % it's best to include the workaround here.
  string = strrep( string, '§', '\S{}' );

  % Escape plain "&" in MATLAB and replace it and the following character with
  % a space in Octave unless the "&" is already escaped
  switch m2t.env
      case 'MATLAB'
          string = strrep( string, '&', '\&' );
      case 'Octave'
          % Ampersands should already be escaped in Octave.
          % Octave (tested with 3.6.0) handles un-escaped ampersands a little
          % funny in that it removes the following character, if there is one:
          % 'abc&def'      -> 'abc ef'
          % 'abc&\deltaef' -> 'abc ef'
          % 'abc&$ef'      -> 'abc ef'
          % 'abcdef&'      -> 'abcdef'
          % Don't remove closing brace after '&' as this would result in
          % unbalanced braces
          string = regexprep( string, '(?<!\\)&(?!})', ' ' );
          string = regexprep( string, '(?<!\\)&}', '}' );
          if regexp( string, '(?<!\\)&\\' )
              % If there's a backslash after the ampersand, that means not only
              % the backslash should be removed but the whole escape sequence,
              % e.g. '\delta' or '\$'. Actually the '\delta' case is the
              % trickier one since by now 'string' would have been turned from
              % 'abc&\deltaef' into '\text{abc&}\delta{}\text{ef}', i.e. after
              % the ampersand first comes a closing brace and then '\delta';
              % the latter as well as the ampersand itself should be removed
              % while the brace must remain in place to avoid unbalanced braces.
              userWarning( m2t,                                                ...
                           ['TeX string ''%s'' contains a special character '  ...
                            'after an un-escaped ''&''. The output generated ' ...
                            'by matlab2tikz will not precisely match that '    ...
                            'which you see in Octave itself in that the '      ...
                            'special character and the preceding ''&'' is '    ...
                            'not replaced with a space.'], origstr )
          end
      otherwise
          error( 'Unknown environment. Need MATLAB(R) or Octave.' )
  end
  % Escape plain "~" in MATLAB and replace escaped "\~" in Octave with a proper
  % escape sequence. An un-escaped "~" produces weird output in Octave, thus
  % give a warning in that case
  switch m2t.env
      case 'MATLAB'
          string = strrep( string, '~', '\textasciitilde{}' ); % or '\~{}'
      case 'Octave'
          string = strrep( string, '\~', '\textasciitilde{}' ); % ditto
          if regexp( string, '(?<!\\)~' )
              userWarning( m2t,                                             ...
                           ['TeX string ''%s'' contains un-escaped ''~''. ' ...
                            'For proper display in Octave you probably '    ...
                            'want to escape it even though that''s '        ...
                            'incompatible with MATLAB. '                    ...
                            'In the matlab2tikz output it will have its '   ...
                            'usual TeX function as a non-breaking space.'], ...
                           origstr )
          end
      otherwise
          error( 'Unknown environment. Need MATLAB(R) or Octave.' )
  end

  % Convert '..._\text{abc}' and '...^\text{abc}' to '..._\text{a}\text{bc}'
  % and '...^\text{a}\text{bc}', respectively.
  % Things get a little more complicated if instead of 'a' it's e.g. '$'. The
  % latter has been converted to '\$' by now and simply extracting the first
  % character from '\text{\$bc}' would result in '\text{$}\text{$bc}' which
  % is syntactically wrong. Instead the whole command '\$' has to be moved in
  % front of the \text{...} block, e.g. '..._\text{\$bc}' -> '..._\$\text{bc}'.
  % Note that the problem does not occur for the majority of special characters
  % like '\alpha' because they use math mode and therefore are never inside a
  % \text{...} block to begin with. This means that the number of special
  % characters affected by this issue is actually quite small:
  %   $ # % & _ { } \o § ~ \ ^
  expr = ['(_|\^)(\\text)\{([^}\\]|\\\$|\\#|\\%|\\&|\\_|\\\{|\\\}|', ...
   ... %   (_/^ )( \text) {(non-}\| \$ | \#| \%| \&| \_| \{ | \} |
   ... %   ( $1 )(  $2  )  (                  $3                      ->
          '\\o\{\}|\\S\{\}|\\textasciitilde\{\}|\\textbackslash\{\}|', ...
   ... %    \o{}  | \S{}  | \textasciitilde{}  | \textbackslash{}  |
   ... %  <-                         $3                                 ->
          '\\textasciicircum\{\})'];
       %    \textasciicircum{}  )
       %  <-      $3            )
  string = regexprep( string, expr, '$1$2{$3}$2{' );

  % Some further processing makes the output behave more like TeX math mode,
  % but only if the matlab2tikz parameter parseStringsAsMath=true.
  if m2t.cmdOpts.Results.parseStringsAsMath

      % Some characters should be in math mode: =-+/,.()<>0-9
      expr = '(\\text)\{([^}=\-+/,.()<>0-9]*)([=\-+/,.()<>0-9]+)([^}]*)\}';
           %    \text  {(any non-"x"/'}'char)(  any "x" char   )(non-}) }
           %  (  $1  )  (        $2         )(       $3        )(  $4 )
      while regexp( string, expr )
          % Iterating is necessary to catch all occurrences. See above.
          string = regexprep( string, expr, '$1{$2}$3$1{$4}' );
      end

      % \text{ } should be a math-mode space
      string = regexprep( string, '\\text\{(\s+)}', '$1' );

      % '<<' probably means 'much smaller than', i.e. '\ll'
      repl = switchMatOct( m2t, '$1\\ll{}$2', '$1\ll{}$2' );
      string = regexprep( string, '([^<])<<([^<])', repl );

      % Single letters are most likely variables and thus should be in math mode
      string = regexprep( string, '\\text\{([a-zA-Z])\}', '$1' );

  end % parseStringsAsMath

  % Clean up: remove empty \text{}
  string = strrep( string, '\text{}', '' );
      % \text{}\alpha{}\text{...} -> \alpha{}\text{...}

  % Clean up: convert '{}\' to '\' unless it's prefixed by a backslash which
  % means the opening brace is escaped and thus a printable character instead
  % of a grouping brace.
  string = regexprep( string, '(?<!\\)\{\}(\\)', '$1' );
      % \alpha{}\text{...} -> \alpha\text{...}

  % Clean up: convert '{}}' to '}' unless it's prefixed by a backslash
  string = regexprep( string, '(?<!\\)\{\}\}', '}' );

  % Clean up: remove '{}' at the end of 'string' unless it's prefixed by a
  % backslash
  string = regexprep( string, '(?<!\\)\{\}$', '' );

end
% =========================================================================
function newStruct = structWithCell(varargin)
  % Constructs a structure with cell variables as MATLAB would make a struct
  % array by using the equivalent struct() call
  % Setting values to cell() straight away doesn't work unfortunately
  % as MATLAB(R) interprets structs with cell values as a cell array of structs.
  assert(mod(nargin,2)==0,'An even number of arguments is expected');
  newStruct = struct();
  keys      = varargin(1:2:end-1);
  values    = varargin(2:2:end);
  for iKV = 1:numel(keys)
      newStruct.(keys{iKV}) = values{iKV};
  end
end
% =========================================================================
