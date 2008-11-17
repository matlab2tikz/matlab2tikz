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
% =========================================================================
% ***
% ***    Copyright (c) 2008  by Nico Schl"omer <nico.schloemer@ua.ac.be>
% ***    All rights reserved.
% ***
% ***    This program is free software: you can redistribute it and/or
% ***    modify it under the terms of the GNU General Public License as
% ***    published by the Free Software Foundation, either version 3 of the
% ***    License, or (at your option) any later version.
% ***
% ***    This program is distributed in the hope that it will be useful,
% ***    but WITHOUT ANY WARRANTY; without even the implied warranty of
% ***    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ***    GNU General Public License for more details.
% ***
% ***    You should have received a copy of the GNU General Public License
% ***    along with this program.  If not, see
% ***    <http://www.gnu.org/licenses/>.
% ***
% =========================================================================
function matlab2tikz( fn )

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define some global variables
  clear global matlab2tikz_name;
  clear global matlab2tikz_version;
  clear global tol;
  clear global matlab2tikz_opts;

  global matlab2tikz_name;
  matlab2tikz_name = 'matlab2tikz';

  global matlab2tikz_version;
  matlab2tikz_version = '0.0.1';

  global tol;
  tol = 1e-15; % global round-off tolerance;
               % used, for example, in equality test for doubles

  global matlab2tikz_opts;
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  matlab2tikz_opts.filename = fn;
  matlab2tikz_opts.gca      = gca;
  matlab2tikz_opts.gcf      = gcf;

  fprintf( '%s v%s\n', matlab2tikz_name, matlab2tikz_version );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Save the figure as pgf to file -- here's where the work happens
  save_to_file();
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fprintf( '\nRemember to load \\usepackage{tikz} and \\usepackage{pgfplots} in the preamble of your LaTeX document.\n\n' );

  % clean up
  clear global matlab2tikz_name;
  clear global matlab2tikz_version;
  clear global tol;
  clear global matlab2tikz_opts;

end
% =========================================================================
% *** END OF FUNCTION matlab2tikz
% =========================================================================



% =========================================================================
% *** FUNCTION save_to_file
% ***
% *** Save the figure as TikZ to a file.
% ***
% =========================================================================
function save_to_file()

  global filename;
  global matlab2tikz_name;
  global matlab2tikz_version;
  global matlab2tikz_opts

  fid = fopen( matlab2tikz_opts.filename, 'w' );
  if fid == -1
      error( 'matlab2tikz:save_to_file', ...
             'Unable to open %s for writing', filename );
  end

  % -----------------------------------------------------------------------
  % start writing the file
  fprintf( fid, '% This file was created by %s v%s.\n\n',               ...
                                   matlab2tikz_name, matlab2tikz_version );

  fprintf( fid, '\\begin{tikzpicture}[scale=0.5]\n' );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % enter plot recursion
  fh = gcf;
  handle_all_children( fh, fid );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fprintf( fid, '\\end{tikzpicture}');
  % -----------------------------------------------------------------------

  fclose( fid );
end
% =========================================================================
% *** END OF FUNCTION save_to_file
% =========================================================================
 


% =========================================================================
% *** FUNCTION handle_all_children
% ***
% *** Draw all children of a graphics object (if they need to be drawn).
% ***
% =========================================================================
function handle_all_children( handle, fid )

  children = get( handle, 'Children' );

  for i = length(children):-1:1
      child = children(i);

      switch get( child, 'Type' )
	  case 'axes'
	      draw_axes ( child, fid );
	  case 'line'
	      draw_line ( child, fid );
	  case 'patch'
	      draw_patch( child, fid );
	  case 'hggroup'
	      draw_hggroup( child, fid );
	  case { 'hgtransform' }
              % don't handle those directly but descend to its children
              % (which could for example be patch handles)
%                fprintf( '\n *** Not handling %s. ***\n',                 ...
%                                                  get(child_handle,'Type') );
              handle_all_children( child, fid );
          case { 'uitoolbar', 'uimenu', 'uicontextmenu', 'uitoggletool',...
                 'uitogglesplittool', 'uipushtool', 'hgjavacomponent',  ...
                 'image', 'text', 'surface' }
              % don't to anything for these handles and its children
%                fprintf( '\n *** Not handling %s. ***\n',                 ...
%                                                  get(child_handle,'Type') );
	  otherwise
	      error( 'matfig2tikz:handle_all_children',                 ...
                     'I don''t know how to handle this object: %s\n',   ...
                                                       get(child,'Type') );
      end
  end

end
% =========================================================================
% *** END OF FUNCTION handle_all_children
% =========================================================================



% =========================================================================
% *** FUNCTION draw_axes
% =========================================================================
function draw_axes( handle, fid )

  if ~strcmp( get(handle,'Visible'), 'on' )
      return
  end

  if strcmp( get(handle,'Tag'), 'Colorbar' )
      % handle a colorbar separately
      draw_colorbar( handle, fid );
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
  xscale = get( handle, 'XScale' );
  yscale = get( handle, 'YScale' );

  is_xlog = strcmp( xscale, 'log' );
  is_ylog = strcmp( yscale, 'log' );

  if  ~is_xlog && ~is_ylog
      env = 'axis';
  elseif is_xlog && ~is_ylog
      env = 'semilogxaxis';
  elseif ~is_xlog && is_ylog
      env = 'semilogyaxis';
  else
      env = 'loglogaxis';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pgfplot_options{1} = 'name=main plot';

  % the following is general MATLAB behavior
  pgfplot_options = [ pgfplot_options, 'axis on top' ];

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get the axes dimensions
  dim = get_axes_dimensions( handle );
  pgfplot_options = [ pgfplot_options,                                  ...
                      sprintf( 'width=%gmm' , dim.x ),                  ...
                      sprintf( 'height=%gmm', dim.y ),                  ...
                      'scale only axis' ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ ticks, ticklabels ] = get_ticks( handle );
  if ~isempty( ticks.x )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'xtick={%s}', ticks.x ) ];
  end
  if ~isempty( ticklabels.x )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'xticklabels={%s}', ticklabels.x ) ];
  end
  if ~isempty( ticks.y )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'ytick={%s}', ticks.y ) ];
  end
  if ~isempty( ticklabels.y )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'yticklabels={%s}', ticklabels.y ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis labels
  axislabels = get_axislabels( handle );
  if ~isempty( axislabels.x )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'xlabel={$%s$}',                     ...
                                   escape_characters(axislabels.x) ) ];
  end
  if ~isempty( axislabels.y )
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'ylabel={$%s$}',                     ...
                                  escape_characters(axislabels.y) ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get title
  title = get( get( handle, 'Title' ), 'String' );
  if ~isempty(title)
      pgfplot_options = [ pgfplot_options,                              ...
                          sprintf( 'title={$%s$}',                      ...
                                   escape_characters(title) ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get axis limits
  xlim = get( handle, 'XLim' );
  ylim = get( handle, 'YLim' );
  pgfplot_options = [ pgfplot_options,                                  ...
                      sprintf('xmin=%g, xmax=%g', xlim ),               ...
                      sprintf('ymin=%g, ymax=%g', ylim ) ];
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get grids
  if strcmp( get( handle, 'XGrid'), 'on' );
      pgfplot_options = [ pgfplot_options, 'xmajorgrids' ];
  end
  if strcmp( get( handle, 'XMinorGrid'), 'on' );
      pgfplot_options = [ pgfplot_options, 'xminorgrids' ];
  end
  if strcmp( get( handle, 'YGrid'), 'on' )
      pgfplot_options = [ pgfplot_options, 'ymajorgrids' ];
  end
  if strcmp( get( handle, 'YMinorGrid'), 'on' );
      pgfplot_options = [ pgfplot_options, 'yminorgrids' ];
  end

  % set the linestyle
  gridlinestyle = get( handle, 'GridLineStyle' );
  gls           = translate_linestyle( gridlinestyle );
  fprintf( fid, '\n\\pgfplotsset{every axis grid/.style={style=%s}}\n\n',...
                                                                     gls );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % See if there are any legends that need to be plotted.
  c = get( get(handle,'Parent'), 'Children' ); % siblings of this handle
  leghandle = 0;
  for k=1:size(c)
      if  strcmp( get(c(k),'Type'), 'axes'   ) && ...
          strcmp( get(c(k),'Tag' ), 'legend' )
          leghandle = c(k);
          break
      end
  end

  if leghandle
      pgfplot_options = [ pgfplot_options, get_legend_opts( leghandle ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % treat each axis as separate scope;
  % eventually introduce xshift, yshift variables here to position the axis
  % in the figure
  % -- put 'opts' directly in the format string to have escape characters
  %    correctly identified
  opts = [ '%%\n', collapse( pgfplot_options, ',%%\n' ), '%%\n' ];
  fprintf( fid, ['\\begin{%s}[',opts,']\n'], env );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% don't use background yet as it interferes with the grid and the axes
%
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    % fill background
%    bgcolor = get( handle, 'Color' );
%    if any( bgcolor~=[1,1,1] )
%        xcolor = rgb2xcolor( bgcolor );
%        if isempty(xcolor)
%  	  fprintf( fid, '\\definecolor{bgcolor}{rgb}{%.2f,%.2f,%.2f}\n',    ...
%  								    bgcolor );
%  	  xcolor = 'bgcolor';
%        end
%        fprintf( fid, '\\addplot [fill=%s] coordinates{ (%e,%e) (%e,%e) (%e,%e) (%e,%e) (%e,%e) };\n', xcolor,     ...
%  							 xlim(1), ylim(1), xlim(2), ylim(1), xlim(2), ylim(2), ...
%  							 xlim(1), ylim(2), xlim(1), ylim(1)  );
%    end
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % handle all children
  matfig2pgf_opt.CurrentAxesHandle = handle;
  handle_all_children( handle, fid );

  % finally close this axis' scope
  fprintf( fid, '\\end{%s}\n', env );

end
% =========================================================================
% *** END OF FUNCTION draw_axes
% =========================================================================



% =========================================================================
% *** FUNCTION draw_line
% =========================================================================
function draw_line( handle, fid )

  if ~strcmp(get( handle, 'Visible'), 'on')
      return
  end

  linestyle = get( handle, 'LineStyle');
  linewidth = get( handle, 'LineWidth');
  marker    = get( handle, 'Marker');

  if ( (strcmp(linestyle,'none')||linewidth==0) && strcmp(marker,'none') )
      return
  end

  fprintf( fid, '%% Line plot\n' );

  xdata = get( handle, 'XData' );
  ydata = get( handle, 'YData' );

  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  % deal with draw options
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  color     = get( handle, 'Color');
  plotcolor = rgb2xcolor( color );
  if isempty( plotcolor )
      fprintf( fid, '\\definecolor{plotcolor}{rgb}{%6f,%6f,%6f}\n',     ...
                                            color(1), color(2), color(3) );
      plotcolor = 'plotcolor';
  end

  draw_options{1} = sprintf( 'color=%s', plotcolor );

  if ~strcmp(linestyle,'none') && linewidth~=0
      draw_options = [ draw_options,                                    ...
                       sprintf('%s', translate_linestyle(linestyle) ),  ...
                       sprintf('line width=%.1fpt', linewidth ) ];
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % marker (with its own options)
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ~strcmp( marker, 'none' )
      marker_size = get( handle, 'MarkerSize');

      % In MATLAB, the marker size refers to the edge length of a square
      % (for example) (~diameter), whereas in TikZ the distance of an edge
      % to the center is the measure (~radius). Hence divide by 2.
      tikz_marker_size = translate_markersize( marker, marker_size );
      draw_options = [ draw_options,                                    ...
                       sprintf( 'mark size=%.1fpt', tikz_marker_size ) ];
      
      mark_options = cell( 0 );
      % make sure that the markers get painted in solid (and not dashed)
      if ~strcmp( linestyle, 'solid' )
          mark_options = [ mark_options, 'solid' ];
      end

      % print no lines
      if strcmp(linestyle,'none') || linewidth==0
          draw_options = [ draw_options, 'only marks' ] ;
      end

      % get the marker color right
      markerfacecolor = get( handle, 'MarkerFaceColor' );
      markeredgecolor = get( handle, 'MarkerEdgeColor' );
      [ tikz_marker, mark_options ] = translate_marker( marker,         ...
                           mark_options, ~strcmp(markerfacecolor,'none') );
      if ~strcmp(markerfacecolor,'none')
	  xcolor = rgb2xcolor( markerfacecolor );
	  if isempty( xcolor )
              fprintf( fid, '\\definecolor{markerfacecolor}{rgb}{%.2f,%.2f,%.2f}\n',...
                                                         markerfacecolor );
	      xcolor = 'markerfacecolor';
	  end
          mark_options = [ mark_options,  sprintf( 'fill=%s', xcolor ) ];
      end
      if ~strcmp(markeredgecolor,'none') && ~strcmp(markeredgecolor,'auto')
	  xcolor = rgb2xcolor( markeredgecolor );
	  if isempty( xcolor )
              fprintf( fid, '\\definecolor{markeredgecolor}{rgb}{%.2f,%.2f,%.2f}\n',...
                                                         markeredgecolor );
	      xcolor = 'markeredgecolor';
	  end
          mark_options = [ mark_options, sprintf( 'draw=%s', xcolor ) ];
      end

      % add it all to draw_options
      draw_options = [ draw_options, sprintf( 'mark=%s', tikz_marker ) ];

      if ~isempty( mark_options )
          mo = collapse( mark_options, ',' );
	  draw_options = [ draw_options, [ 'mark options={', mo, '}' ] ];
      end
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % insert draw options
  opts = [ '%%\n', collapse( draw_options, ',%%\n' ), '%%\n' ];
  fprintf( fid, ['\\addplot [',opts,'] coordinates{\n' ] );
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the actual line data
  % -- Check for any node if it needs to be included at all. For zoomed
  %    plots, lots can be omitted.

  % get parent axes
  p = get( handle, 'Parent' );

  xlim = get( p, 'XLim' );
  ylim = get( p, 'YLim' );

  n = length(xdata);

  % check which nodes lie inside the axes
  inside = is_inside_box( [xdata', ydata'], xlim, ylim );

  if inside(1) || inside(2)
      fprintf( fid, ' (%g,%g)', xdata(1), ydata(1) );
  end
  for k=2:n-1
      if inside(k-1) || inside(k) || inside(k+1)
          fprintf( fid, ' (%g,%g)', xdata(k), ydata(k) );
      end
  end
  if inside(n-1) || inside(n)
      fprintf( fid, ' (%g,%g)', xdata(n), ydata(n) );
  end

  fprintf( fid, '\n};\n\n' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  handle_all_children( handle, fid );

end
% =========================================================================
% *** END OF FUNCTION draw_line
% =========================================================================



% =========================================================================
% *** FUNCTION draw_patch
% ***
% *** Draws a 'patch' graphic object.
% ***
% =========================================================================
function draw_patch( handle, fid )

  global matlab2tikz_opts;

  % the colorcount counter is a workaround for a missing feature in
  % pgfplots:
  % redefining a color (such as 'facecolor') doesn't work, hence define
  % colors subsequently (such as 'facecolor1', 'facecolor2', ...)
  persistent colorcount

  if ~strcmp( get(handle,'Visible'), 'on' )
      return
  end

  %  linewidth = get( handle, 'LineWidth');
  linestyle = get( handle, 'LineStyle' );

  fprintf( fid, '%% patch object\n' );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define edge color
  edgecolor = get( handle, 'EdgeColor' );
  edgecolor = anycolor2rgb ( edgecolor, handle, matlab2tikz_opts.gcf,   ...
					            matlab2tikz_opts.gca );
  xedgecolor = rgb2xcolor( edgecolor );
  if isempty( xedgecolor )
      fprintf( fid, '\\definecolor{edgecolor}{rgb}{%g,%g,%g}\n',        ...
                                                               edgecolor );
      xedgecolor = 'edgecolor';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define face color
  facecolor = get( handle, 'FaceColor');
  facecolor = anycolor2rgb ( facecolor, handle, matlab2tikz_opts.gcf,   ...
					            matlab2tikz_opts.gca );
  xfacecolor = rgb2xcolor( facecolor );
  if isempty( xfacecolor )
      if isempty(colorcount)
          colorcount = 0;
      end
      colorcount = colorcount + 1;
      fprintf( fid, '\\definecolor{facecolor%d}{rgb}{%g,%g,%g}\n',      ...
                                                   colorcount, facecolor );
      xfacecolor = sprintf( 'facecolor%d', colorcount );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % gather the draw options
  draw_options{1} = sprintf( 'fill=%s', xfacecolor );
  if strcmp( linestyle, 'none' )
      draw_options{2} = 'draw=none';
  else
      draw_options{2} = sprintf( 'draw=%s', xedgecolor );
  end
  draw_opts = collapse( draw_options, ',' );
  % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


  % MATLAB's patch elements are matrices in which each column represents a
  % a distinct graphical object. Usually there is only one column, but
  % there may be more (-->hist plots).
  xdata = get( handle, 'XData' );
  ydata = get( handle, 'YData' );
  m = size(xdata,1);
  n = size(xdata,2);
  for j=1:n
      fprintf( fid, [ '\\addplot [',draw_opts,'] coordinates{'] );
      for i=1:m
	  fprintf( fid, ' (%f,%f)', xdata(i,j), ydata(i,j) );
      end
      fprintf( fid, '};\n' );
  end
  fprintf( fid, '\n' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  handle_all_children( handle, fid );

end
% =========================================================================
% *** END OF FUNCTION draw_patch
% =========================================================================



% =========================================================================
% *** FUNCTION draw_hggroup
% =========================================================================
function draw_hggroup( h, fid );

  cl = class( handle(h) );

  switch( cl )
      case 'specgraph.barseries'
	  % hist plots and friends
          draw_barseries( h, fid );
      case {'specgraph.contourgroup'}
	  % handle all those the usual way
          handle_all_children( h, fid );
      otherwise
	  warning( 'matlab2tikz:draw_hggroup',                          ...
                       'Don''t know class ''%s''. Default handling.', cl );
          handle_all_children( h, fid );
  end

end
% =========================================================================
% *** END FUNCTION draw_hggroup
% =========================================================================



% =========================================================================
% *** FUNCTION draw_barseries
% ***
% *** Takes care of plots like the ones produced by MATLAB's hist.
% *** The main pillar is pgfplots's '{x,y}bar' plot.
% ***
% *** NOTE: There is code duplication with 'draw_axes'. Try to get rid of
% ***       that!
% ***
% =========================================================================
function draw_barseries( h, fid );

  global matlab2tikz_opts;

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define edge color
  edgecolor = get( h, 'EdgeColor' );
  edgecolor = anycolor2rgb ( edgecolor, h, matlab2tikz_opts.gcf,   ...
					            matlab2tikz_opts.gca );
  xedgecolor = rgb2xcolor( edgecolor );
  if isempty( xedgecolor )
      fprintf( fid, '\\definecolor{edgecolor}{rgb}{%g,%g,%g}\n',        ...
                                                               edgecolor );
      xedgecolor = 'edgecolor';
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % define face color
  facecolor = get( h, 'FaceColor');
  facecolor = anycolor2rgb ( facecolor, h, matlab2tikz_opts.gcf,   ...
					            matlab2tikz_opts.gca );
  xfacecolor = rgb2xcolor( facecolor );
  if isempty( xfacecolor )
      if isempty(colorcount)
          colorcount = 0;
      end
      colorcount = colorcount + 1;
      fprintf( fid, '\\definecolor{facecolor%d}{rgb}{%g,%g,%g}\n',      ...
                                                   colorcount, facecolor );
      xfacecolor = sprintf( 'facecolor%d', colorcount );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % gather the draw options
  linestyle = get( h, 'LineStyle' );

  draw_options{1} = 'ybar';
  draw_options{2} = sprintf( 'fill=%s', xfacecolor );
  if strcmp( linestyle, 'none' )
      draw_options{3} = 'draw=none';
  else
      draw_options{3} = sprintf( 'draw=%s', xedgecolor );
  end
  draw_opts = collapse( draw_options, ',' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot the thing
  fprintf( fid, '\\addplot[%s] plot coordinates{', draw_opts );

  xdata = get( h, 'XData' );
  ydata = get( h, 'YData' );

  for k=1:length(xdata)
      fprintf( fid, ' (%f,%f)', xdata(k), ydata(k) );
  end

  fprintf( fid, ' };\n\n' );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION draw_barseries
% =========================================================================



% =========================================================================
% *** FUNCTION draw_colorbar
% =========================================================================
function draw_colorbar( handle, fid )

  if ~strcmp( get(handle,'Visible'), 'on' )
      return
  end

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Try to find the parent axes of this colorbar for height/width info.
  % Unfortunately, all axes in a figure (and hence colorbar, too) are
  % siblings, and there doesn't _seem_ to be info about the refering axes
  % in the colorbar axes.
  % Hence, go back to parent and search for the (one?) non-colorbar axes
  % pair.
  c = get( get(handle,'Parent'), 'Children' ); % siblings of handle
  parent = 0;
  for k=1:size(c)
      if  strcmp( get(c(k),'Type'), 'axes'     ) && ...
         ~strcmp( get(c(k),'Tag' ), 'Colorbar' )
          parent = c(k);
          break
      end
  end

  if ~parent
      warning( 'matlab2tikz:draw_colorbar',                             ...
               'Unable to find the colorbar''s parental axes. Skip.' );
      return;
  end

  % get the size of 'parent'
  dim = get_axes_dimensions( parent );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % Define the height/width (or width/height) ratio of the colorbar;
  % this value is manually measured. Unfortunately, this seems to be
  % necessary as   get_axes_dimensions( handle )   defines a colorbar which
  % is a lot too wide.
  ratio = 109/7;

  % get the upper and lower limit of the colorbar
  clim = caxis;

  % begin collecting axes options
  cbar_options = cell( 0 );
  cbar_options = [ cbar_options,                                        ...
                   'at={(colorbar anchor)}',                            ...
                   'axis on top' ];

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set position, ticks etc. of the colorbar
  loc = get( handle, 'Location' );
  switch loc
      case { 'North', 'South', 'East', 'West' }
          warning( 'matlab2tikz:draw_colorbar',                         ...
                   'Don''t know how to deal with inner colorbars yet.' );
          return;

      case {'NorthOutside','SouthOutside'}
          dim.y = dim.x / ratio;
          cbar_options = [ cbar_options,                                ...
	                   sprintf('width=%gmm, height=%gmm',dim.x,dim.y), ...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%g, xmax=%g', clim ),         ...
                           sprintf( 'ymin=%g, ymax=%g', [0,1] )         ...
                         ];

          if strcmp( loc, 'NorthOutside' )
              anchorparent = 'above north west';
              cbar_options = [ cbar_options,                            ...
                               'anchor=south west',                     ...
                               'xticklabel pos=right, ytick=\\empty' ];
                               % we actually wanted to set pos=top here,
                               % but pgfplots doesn't support that yet.
                               % pos=right does the same thing, really.
          else
              anchorparent = 'below south west';
              cbar_options = [ cbar_options,                            ...
                               'anchor=north west',                     ...
                               'xticklabel pos=left, ytick=\\empty' ];
                               % we actually wanted to set pos=bottom here,
                               % but pgfplots doesn't support that yet. 
                               % pos=left does the same thing, really.
          end

      case {'EastOutside','WestOutside'}
          dim.x = dim.y / ratio;
          cbar_options = [ cbar_options,                                ...
	                   sprintf( 'width=%gmm, height=%gmm',dim.x,dim.y),...
                           'scale only axis',                           ...
                           sprintf( 'xmin=%g, xmax=%g', [0,1] ),        ...
                           sprintf( 'ymin=%g, ymax=%g', clim )          ...
                         ];
          if strcmp( loc, 'EastOutside' )
               anchorparent = 'right of south east';
               cbar_options = [ cbar_options,                           ...
                                'anchor=south west',                    ...
                                'xtick=\\empty, yticklabel pos=right' ];
           else
               anchorparent = 'left of south west';
               cbar_options = [ cbar_options,                           ...
                                'anchor=south east',                    ...
                                'xtick=\\empty, yticklabel pos=left' ];
           end

      otherwise
          error( 'draw_colorbar: Unknown ''Location'' %s.', loc )
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % get ticks along with the labels
  [ ticks, ticklabels ] = get_ticks( handle );
  if ~isempty( ticks.x )
      cbar_options = [ cbar_options,                                    ...
                       sprintf( 'xtick={%s}', ticks.x ) ];
  end
  if ~isempty( ticklabels.x )
      cbar_options = [ cbar_options,                                    ...
                       sprintf( 'xticklabels={%s}', ticklabels.x ) ];
  end
  if ~isempty( ticks.y )
      cbar_options = [ cbar_options,                                    ...
                       sprintf( 'ytick={%s}', ticks.y ) ];
  end
  if ~isempty( ticklabels.y )
      cbar_options = [ cbar_options,                                    ...
                       sprintf( 'yticklabels={%s}', ticklabels.y ) ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % introduce an anchor coordinate;
  % as an extra, one could add a ++(5mm,0) or something like that to increase
  % the space between the colorbar and the main plot
  fprintf( fid, [ '\n\n%% introduce named coordinate:\n',               ... 
                 '\\path (main plot.%s)',                               ...
                 ' coordinate (colorbar anchor);\n' ], anchorparent );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % actually begin drawing the thing
  fprintf( fid, '\n%% draw the colorbar\n' );
  cbar_opts = collapse( cbar_options, ',\n' );
  fprintf( fid, [ '\\begin{axis}[\n', cbar_opts, '\n]\n' ] );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % get the colormap
  cmap = colormap;

  cbar_length = clim(2) - clim(1);

  m = size( cmap, 1 );
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % plot tiny little badges for the respective colors
  for i=1:m
      fprintf( fid, '\\definecolor{ccolor%d}{rgb}{%g,%g,%g}\n',         ...
                                       i, cmap(i,1), cmap(i,2), cmap(i,3));

      switch loc
          case {'NorthOutside','SouthOutside'}
              x1 = clim(1) + cbar_length/m *(i-1);
              x2 = clim(1) + cbar_length/m *i;
              y1 = 0;
              y2 = 1; 
          case {'WestOutside','EastOutside'}
              x1 = 0;
              x2 = 1;
              y1 = clim(1) + cbar_length/m *(i-1);
              y2 = clim(1) + cbar_length/m *i; 
      end
      fprintf( fid, '\\addplot [fill=ccolor%d,draw=none] coordinates{ (%g,%g) (%g,%g) (%g,%g) (%g,%g) };\n', i,    ...
                                          x1, y1, x2, y1, x2, y2, x1, y2    ); 
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % do _not_ handle colorbar's children

  % close & good-bye
  fprintf( fid, '\\end{axis}\n\n' );

end
% =========================================================================
% *** END FUNCTION draw_colorbar
% =========================================================================



% =========================================================================
% *** FUNCTION get_legend_opts
% =========================================================================
function lopts = get_legend_opts( handle )

  if ~strcmp( get(handle,'Visible'), 'on' )
      return
  end

  entries = get( handle, 'String' );

  n = length( entries );

  lopts = cell( 0 );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle legend entries
  if n
      for k=1:n
          % escape all lenged entries to math mode for now
          % -- this is later to be removed
          entries{k} = [ '$', entries{k}, '$' ];
      end

      lopts = [ lopts,                                                  ...
                [ 'legend entries={', collapse(entries,','), '}' ] ];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % handle legend location
  loc = get( handle, 'Location' );
  switch loc
      case 'NorthEast'
          % don't append any options in this (default) case
      case 'NorthWest'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.03,0.97)},anchor=north west}' ]; 
      case 'SouthWest'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.03,0.03)},anchor=south west}' ];
      case 'SouthEast'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.97,0.03)},anchor=south east}' ];
      case 'North'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.5,0.97)},anchor=north}' ];
      case 'East'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.97,0.5)},anchor=east}' ];
      case 'South'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.5,0.03)},anchor=south}' ];
      case 'West'
          lopts = [ lopts,                                              ...
                    'legend style={at={(0.03,0.5)},anchor=west}' ];
      otherwise
	  warning( 'matlab2tikz:get_legend_opts',                       ...
                   [ ' Function get_legend_opts:',                      ...
		     ' Unknown legend location ''',loc,''               ...
                     '. Choosing default.' ] );
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** FUNCTION get_legend_opts
% =========================================================================



% =========================================================================
% *** FUNCTION anycolor2rgb
% ***
% *** Transforms a color of whichever format to a 1x3 rgb color vector.
% ***
% =========================================================================
function rgbcolor = anycolor2rgb ( color, imagehandle, fighandle,       ...
                                                               axeshandle )

  if ( isreal(color) && length(color)==3 )
      % everything allright: bail out
      rgbcolor = color;
      return
  end

  if strcmp( color, 'flat')
      colormap = get( fighandle  , 'ColorMap' );
      cdata    = get( imagehandle, 'CData'    );
      if strcmp( get( imagehandle, 'CDataMapping'), 'scaled' )
          % need to scale within clim
          % see MATLAB's manual page for caxis for details
          clim = get( axeshandle, 'clim' );
          m = size( colormap, 1 );
          if cdata<=clim(1)
              colorindex = 1;
          elseif cdata>=clim(2)
              colorindex = m;
          else
              colorindex = fix((cdata-clim(1))/(clim(2)-clim(1))*m)+1;
          end
      else
          % direct index
          colorindex = cdata(1, 1);
      end
      rgbcolor = colormap( colorindex, : );
  else
      error( [ 'Function color2index: ',                                ...
               'I don''t know how to handle the color value of %s .' ], ...
                color );
  end

end
% =========================================================================
% *** END OF FUNCTION anycolor2rgb
% =========================================================================



% % =========================================================================
% % *** FUNCTION draw_grid
% % ***
% % *** Draw the grid, if the XGrid and/or YGrid property are set 'on'
% % ***
% % *** draw_grid( handle, fid )
% % ***
% % =========================================================================
% function draw_grid( handle, fid )
% 
%   xgrid = get( handle, 'XGrid' );
%   ygrid = get( handle, 'YGrid' );
% 
%   % plot x-grid
%   if strcmp(xgrid,'on')
%       ylim  = get( handle, 'YLim'  );
%       xtick = get( handle, 'XTick' );
% 
%       fprintf( fid, '%% MY y-grid\n');
%       fprintf( fid, '\\foreach \\x in {');
%       fprintf( fid, '%f', xtick(1) );
%       for i=2:length(xtick)
%           fprintf( fid, ',%f', xtick(i) );
%       end
%       fprintf( fid, '}\n');
%       fprintf( fid, '	\\draw [dotted] ( \\x, %f ) -- ( \\x, %f );\n', ylim(1), ylim(2) );
%   end
% 
%   % plot y-grid
%   if strcmp(ygrid,'on')
%       xlim       = get( handle, 'XLim');
%       ytick      = get( handle, 'YTick');
% 
%       fprintf( fid, '%% x-grid\n');
%       fprintf( fid, '\\foreach \\y in {');
%       fprintf( fid, '%f', ytick(1) );
%       for i=2:length(ytick)
%           fprintf( fid, ',%f', ytick(i) );
%       end
%       fprintf( fid, '}\n');
%       fprintf( fid, '    \\draw [dotted] ( %f, \\y ) -- ( %f, \\y );\n',    ...
%                                                            xlim(1), xlim(2) );
%   end
% 
% end
% % =========================================================================
% % *** END OF FUNCTION draw_grid
% % =========================================================================



% =========================================================================
% *** FUNCTION get_ticks
% ***
% *** Return axis tick marks pgfplot style. Nice: Tick lengths and such
% *** details are taken care of by pgfplot.
% ***
% =========================================================================
function [ ticks, ticklabels ] = get_ticks( handle )

  global tol

  xtick      = get( handle, 'XTick' );
  xticklabel = get( handle, 'XTickLabel' );

  ytick      = get( handle, 'YTick' );
  yticklabel = get( handle, 'YTickLabel' );

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set xticks + labels
  ticks.x = collapse( num2cell(xtick), ',' );

  % sometimes ticklabels are cells, sometimes plain arrays
  % -- unify this to cells
  if ischar( xticklabel )
      xticklabel = strtrim( mat2cell(xticklabel,                        ...
                          ones(size(xticklabel,1),1),size(xticklabel,2)) );
  end

  % if the axis is logscaled, MATLAB does not store the labels, but the
  % exponents to 10
  if strcmp( get(handle,'XScale'),'log' )
      for k = 1:length(xticklabel)
          if isnumeric( xticklabel{k} )
              str = num2str( xticklabel{k} );
          else
              str = xticklabel{k};
          end
          xticklabel{k} = sprintf( '$10^{%s}$', str );
      end
  end

  % check if ticklabels are really necessary (and not already covered by
  % the tick values themselves)
  plot_labels_necessary = 0;
  for k = 1:min(length(xtick),length(xticklabel))
       % Don't use str2num here as then, literal strings as 'pi' get
       % legally transformed into 3.14... and the need for an explicit
       % label will not be recognized. str2double returns a NaN for 'pi'.
       s = str2double( xticklabel{k} );
       if isnan(s)  ||  abs(xtick(k)-s) > tol
           plot_labels_necessary = 1;
           break
       end
  end

  if plot_labels_necessary
      ticklabels.x = collapse( xticklabel, ',' );
  else
      ticklabels.x = [];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % set yticks + labels
  ticks.y = collapse( num2cell(ytick), ',' );

  if ischar( yticklabel )
      yticklabel = strtrim( mat2cell(yticklabel,                        ...
                          ones(size(yticklabel,1),1),size(yticklabel,2)) );
  end

  % if the axis is logscaled, MATLAB does not store the labels, but the
  % exponents to 10
  if strcmp( get(handle,'YScale'),'log' )
      for k = 1:length(yticklabel)
          if isnumeric( yticklabel{k} )
              str = num2str( yticklabel{k} );
          else
              str = yticklabel{k};
          end
          yticklabel{k} = sprintf( '$10^{%s}$', str );
      end
  end

  % check if ticklabels are really necessary (and not already covered by
  % the tick values themselves)
  plot_labels_necessary = 0;
  for k = 1:min(length(ytick),length(yticklabel))
       % Don't use str2num here as then, literal strings as 'pi' get
       % legally transformed into 3.14... and the need for an explicit
       % label will not be recognized. str2double returns a NaN for 'pi'.
       s = str2double( yticklabel{k} );
       if isnan(s)  ||  abs(ytick(k)-s) > tol
           plot_labels_necessary = 1;
           break
       end
  end

  if plot_labels_necessary
      ticklabels.y = collapse( yticklabel, ',' );
  else
      ticklabels.y = [];
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end
% =========================================================================
% *** END FUNCTION get_ticks
% =========================================================================



% =========================================================================
% *** FUNCTION draw_text
% =========================================================================
function draw_text( handle, fid )

  if ~strcmp(get( handle, 'Visible'), 'on')
      return
  end

  text = get( handle, 'String' );
  if isempty(strtrim(text))
      return
  end

  fprintf( fid, '%% Draw a text handle\n' );
  text = regexprep( text, '\', '\\' );

  position = get( handle, 'Position' );

  node_options = '';
  rotate = get( handle, 'Rotation' );
  if rotate~=0
      node_options = [node_options, sprintf(',rotate=%.1f',rotate) ];
  end

  % we're not really accurate here: stricly speaking, bottom and baseline
  % alignments are different; not being handled, yet
  valign = get( handle, 'VerticalAlignment' );
  switch valign
      case {'bottom','baseline'}
	      node_options = [node_options, sprintf(',anchor=south') ];
      case {'top','cap'}
	      node_options = [node_options, sprintf(',anchor=north') ];
      case 'middle'
      otherwise
	      warning( 'matlab2tikz:draw_text',                         ...
                  'Don''t know what VerticalAlignment %s means.', valign );
  end
  
  halign = get( handle, 'HorizontalAlignment' );
  switch halign
      case 'left'
	      node_options = [node_options, sprintf(',anchor=west') ];
      case 'right'
	      node_options = [node_options, sprintf(',anchor=east') ];
      case 'center'
      otherwise
          warning( 'matlab2tikz:draw_text',                             ...
	        'Don''t know what HorizontalAlignment %s means.', halign );
  end

  fprintf( fid, '\\draw (%f,%f) node[%s] {$%s$};\n\n',                  ...
                            position(1), position(2), node_options, text );

  handle_all_children( handle, fid);
  
end
% =========================================================================
% *** END OF FUNCTION draw_text
% =========================================================================



% =========================================================================
% *** FUNCTION translate_text
% ***
% *** This function converts MATLAB text strings to valid LaTeX ones.
% ***
% =========================================================================
function newstr = translate_text( handle )

  str = get( handle, 'String' );

  int = get( handle, 'Interpreter' );
  switch int
      case 'none'
          newstr = str;
          newstr = strrep( newstr, '''', '\''''' );
          newstr = strrep( newstr, '%' , '%%'    );
          newstr = strrep( newstr, '\' , '\\'    );
      case {'tex','latex'}
          newstr = str;
      otherwise
          error( 'matlab2tikz:translate_text',                          ...
                 'Unknown text interpreter ''%s''.', int )
  end

end
% =========================================================================
% *** FUNCTION translate_text
% =========================================================================



% =========================================================================
% *** FUNCTION translate_linestyle
% =========================================================================
function tikz_linestyle = translate_linestyle( matlab_linestyle )
  
  if( ~ischar(matlab_linestyle) )
      error( [ ' Function translate_linestyle:',                        ...
               ' Variable matlab_linestyle is not a string.' ] );
  end

  switch ( matlab_linestyle )
      case 'none'
          tikz_linestyle = '';
      case '-'
          tikz_linestyle = 'solid';
      case '--'
          tikz_linestyle = 'dashed';
      case ':'
          tikz_linestyle = 'dotted';           
      case '-.'
          tikz_linestyle = 'dash pattern=on 1pt off 3pt on 3pt off 3pt';
      otherwise
	  error( [ ' Function translate_linestyle:',                    ...
		   ' Unknown matlab_linestyle ''',matlab_linestyle,'''.']);
  end
end
% =========================================================================
% *** END OF FUNCTION translate_linestyle
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
function xcolor_literal = rgb2xcolor( rgb )

  if isequal( rgb, [1,0,0] )
      xcolor_literal = 'red';
  elseif isequal( rgb, [0,1,0] )
      xcolor_literal = 'green';
  elseif isequal( rgb, [0,0,1] )
      xcolor_literal = 'blue';
  elseif isequal( rgb, [0.75,0.5,0.25] )
      xcolor_literal = 'brown';
  elseif isequal( rgb, [0.75,1,0] )
      xcolor_literal = 'lime';
  elseif isequal( rgb, [1,0.5,0] )
      xcolor_literal = 'orange';
  elseif isequal( rgb, [1,0.75,0.75] )
      xcolor_literal = 'pink';
  elseif isequal( rgb, [0.75,0,0.25] )
      xcolor_literal = 'pink';
  elseif isequal( rgb, [0.75,0,0.25] )
      xcolor_literal = 'purple';
  elseif isequal( rgb, [0,0.5,0.5] )
      xcolor_literal = 'teal';
  elseif isequal( rgb, [0.5,0,0.5] )
      xcolor_literal = 'violet';
  elseif isequal( rgb, [0,1,1] )
      xcolor_literal = 'cyan';
  elseif isequal( rgb, [1,0,1] )
      xcolor_literal = 'magenta';
  elseif isequal( rgb, [1,1,0] )
      xcolor_literal = 'yellow';
  elseif isequal( rgb, [0.5,0.5,0] )
      xcolor_literal = 'olive';
  elseif isequal( rgb, [0,0,0] )
      xcolor_literal = 'black';
  elseif isequal( rgb, [0.5,0.5,0.5] )
      xcolor_literal = 'gray';
  elseif isequal( rgb, [0.75,0.75,0.75] )
      xcolor_literal = 'lightgray';
  elseif isequal( rgb, [1,1,1] )
      xcolor_literal = 'white';
  else
      xcolor_literal = '';
  end

end
% =========================================================================
% *** FUNCTION rgb2xcolor
% =========================================================================



% =========================================================================
% *** FUNCTION translate_marker
% =========================================================================
function [ tikz_marker, mark_options ] =                                ...
          translate_marker( matlab_marker, mark_options, facecolor_toggle )
  
  if( ~ischar(matlab_marker) )
      error( [ ' Function translate_marker:',                           ...
               ' Variable matlab_marker is not a string.' ] );
  end

  switch ( matlab_marker )
      case 'none'
          tikz_marker = '';
      case '+'
          tikz_marker = '+';
      case 'o'
	  if facecolor_toggle
	      tikz_marker = '*';
	  else
	      tikz_marker = 'o';
	  end
      case '.'
	  tikz_marker = '*';
      case 'x'
	  tikz_marker = 'x';
      otherwise  % the following markers are only available with PGF's
                 % plotmarks library
          fprintf( '\nMake sure to load \\usetikzlibrary{plotmarks} in the preamble.\n' );
          switch ( matlab_marker )
              
	          case '*'
		          tikz_marker = 'asterisk';
              
	          case {'s','square'}
                  if facecolor_toggle
		              tikz_marker = 'square*';
                  else
                      tikz_marker = 'square';
                  end

	          case {'d','diamond'}
                  if facecolor_toggle
		              tikz_marker = 'diamond*';
                  else
		              tikz_marker = 'diamond';
                  end
                  
              case '^'
                  if facecolor_toggle
		              tikz_marker = 'triangle*';
                  else
		              tikz_marker = 'triangle';
                  end

	          case 'v'
                  if facecolor_toggle
                      tikz_marker = 'triangle*';
                  else
		              tikz_marker = 'triangle';
                  end
                  mark_options = [ mark_options, ',rotate=180' ];

	          case '<'
                  if facecolor_toggle
                      tikz_marker = 'triangle*';
                  else
		              tikz_marker = 'triangle';
                  end
                  mark_options = [ mark_options, ',rotate=270' ];

              case '>'
                  if facecolor_toggle
		              tikz_marker = 'triangle*';
                  else
		              tikz_marker = 'triangle';
                  end
                  mark_options = [ mark_options, ',rotate=90' ];

              case {'p','pentagram'}
                  if facecolor_toggle
		              tikz_marker = 'star*';
                  else
		              tikz_marker = 'star';
                  end
                  
	          case {'h','hexagram'}
                  warning( 'matlab2tikz:translate_marker',              ...
                           'MATLAB''s marker ''hexagram'' not available in TikZ. Replacing by ''star''.' );
                  if facecolor_toggle
		              tikz_marker = 'star*';
                  else
		              tikz_marker = 'star';
                  end

              otherwise
                  error( [ ' Function translate_marker:',               ...
                           ' Unknown matlab_marker ''',matlab_marker,'''.' ] );
          end
  end
  
end
% =========================================================================
% *** END OF FUNCTION translate_marker
% =========================================================================



% =========================================================================
% *** FUNCTION translate_markersize
% ***
% *** The markersizes of Matlab and TikZ are related, but not equal. This is
% *** because
% ***
% ***  1.) MATLAB uses the MarkerSize property to describe something like the
% ***      diameter of the mark, while TikZ refers to the 'radius',
% ***  2.) MATLAB and TikZ take different measures (, e.g., the edgelength of
% ***      a square vs. the diagonal length of it).
% ***
% =========================================================================
function tikz_markersize =                                              ...
                   translate_markersize( matlab_marker, matlab_markersize )
  
  if( ~ischar(matlab_marker) )
      error( 'matlab2tikz:translate_markersize',                        ...
             'Variable matlab_marker is not a string.' );
  end

  if( ~isnumeric(matlab_markersize) )
      error( 'matlab2tikz:translate_markersize',                        ...
             'Variable matlab_markersize is not a numeral.' );
  end

  switch ( matlab_marker )
      case 'none'
          tikz_markersize = [];
      case {'+','o','x','*','p','pentagram','h','hexagram'}
          tikz_markersize = matlab_markersize / 2;
      case '.'
          % as documented on the Matlab help pages:
          %
          % Note that MATLAB draws the point marker (specified by the '.'
          % symbol) at one-third the specified size.
          % The point (.) marker type does not change size when the
          % specified value is less than 5. 
          % 
	  tikz_markersize = matlab_markersize / 2 / 3;
      case {'s','square'}
          % Matlab measures the diameter, TikZ half the edge length
          tikz_markersize = matlab_markersize / 2 / sqrt(2);
      case {'d','diamond'}
          % Matlab measures the width, TikZ the height of the diamond;
          % the acute angle (top and bottom) is a manually measured
          % 75 degrees (in TikZ, and Matlab probably very similar);
          % use this as a base for calculations
	  tikz_markersize = matlab_markersize / 2 / atan( 75/2 *pi/180 );
      case {'^','v','<','>'}
          % for triangles, matlab takes the height
          % and tikz the circumcircle radius;
          % the triangles are always equiangular
          tikz_markersize = matlab_markersize / 2 * (2/3);
      otherwise
	  error( 'matlab2tikz:translate_markersize',                    ...
                 'Unknown matlab_marker ''%s''.', matlab_marker  );
  end

end
% =========================================================================
% *** END OF FUNCTION translate_markersize
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
% *** FUNCTION get_axislabels
% =========================================================================
function axislabels = get_axislabels( handle )

  axislabels.x = get( get( handle, 'XLabel' ), 'String' );
  axislabels.y = get( get( handle, 'YLabel' ), 'String' );

end
% =========================================================================
% *** END FUNCTION get_axislabels
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



% =========================================================================
% *** FUNCTION get_axes_scaling
% ***
% *** Returns the scaling of the axes.
% ***
% =========================================================================
function scaling = get_axes_scaling( handle )

  % arbitrarily chosen: the longer edge of the plot has length 50(mm)
  % (the other is calculated according to the aspect ratio)
  longer_edge = 50;

  xyscaling = daspect;

  xlim = get( handle, 'XLim' );
  ylim = get( handle, 'YLim' );

  % [x,y]length are the actual lengths of the axes in some obscure unit
  xlength = (xlim(2)-xlim(1)) / xyscaling(1);
  ylength = (ylim(2)-ylim(1)) / xyscaling(2);

  if ( xlength>=ylength )
      baselength = xlength;
  else
      baselength = ylength;
  end
  
  % one of the quotients cancels to longer_edge
  physical_length.x = longer_edge * xlength / baselength;
  physical_length.y = longer_edge * ylength / baselength;

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % For log-scaled axes, the pgfplot scaling means scaling powers of exp(1)
  % (see pgfplot manual p. 55). Hence, take the natural logarithm in those
  % cases.
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  xscale  = get( handle, 'XScale' );
  yscale  = get( handle, 'YScale' );
  is_xlog = strcmp( xscale, 'log' );
  is_ylog = strcmp( yscale, 'log' );
  if is_xlog
      q.x = log( xlim(2)/xlim(1) );
  else
      q.x = xlim(2) - xlim(1);
  end

  if is_ylog
      q.y = log( ylim(2)/ylim(1) );
  else
      q.y = ylim(2) - ylim(1);
  end
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  % finally, set the scaling
  scaling.x = sprintf( '%gmm', physical_length.x / q.x );
  scaling.y = sprintf( '%gmm', physical_length.y / q.y );


  % The only way to reliably get the aspect ratio of the axes is
  % the 'Position' property. Neither 'DataAspectRatio' nor
  % 'PlotBoxAspectRatio' seem to always  yield the correct ratio.
  % Critital are for example figures with subplots.
%    position = get( handle, 'Position' )
%  
%    xscaling = 1;
%    yscaling = position(4)/position(3) * (xlim(2)-xlim(1))/(ylim(2)-ylim(1));
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
% *** END FUNCTION get_axes_scaling
% =========================================================================



% =========================================================================
% *** FUNCTION get_axes_dimensions
% ***
% *** Returns the physical dimension of the axes.
% ***
% =========================================================================
function dimension = get_axes_dimensions( handle )

  % arbitrarily chosen: maximal width and height (in mm)
  % this seems to be pretty much what the PDF/EPS print functions in MATLAB
  % do
  maxwidth  = 150;
  maxheight = 120;

  xyscaling = daspect;
%    xyscaling = get( handle, 'DataAspectRatio' )

  xlim = get( handle, 'XLim' );
  ylim = get( handle, 'YLim' );

  % {x,y}length are the actual lengths of the axes in some obscure unit
  xlength = (xlim(2)-xlim(1)) / xyscaling(1);
  ylength = (ylim(2)-ylim(1)) / xyscaling(2);

  if ( xlength/ylength >= maxwidth/maxheight )
      dim.x = maxwidth;
      dim.y = maxwidth * ylength / xlength;
  else
      dim.x = maxheight * xlength / ylength;
      dim.y = maxheight;
  end

  dimension.x = dim.x;
  dimension.y = dim.y;


%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    % For log-scaled axes, the pgfplot scaling means scaling powers of exp(1)
%    % (see pgfplot manual p. 55). Hence, take the natural logarithm in those
%    % cases.
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    xscale  = get( handle, 'XScale' );  is_xlog = strcmp( xscale, 'log' );
%    yscale  = get( handle, 'YScale' );  is_ylog = strcmp( yscale, 'log' );
%    if is_xlog
%        q.x = log( xlim(2)/xlim(1) );
%    else
%        q.x = xlim(2) - xlim(1);
%    end
%  
%    if is_ylog
%        q.y = log( ylim(2)/ylim(1) );
%    else
%        q.y = ylim(2) - ylim(1);
%    end
%    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  
%    % finally, set the scaling
%    scaling.x = sprintf( '%gmm', physical_length.x / q.x );
%    scaling.y = sprintf( '%gmm', physical_length.y / q.y );


  % The only way to reliably get the aspect ratio of the axes is
  % the 'Position' property. Neither 'DataAspectRatio' nor
  % 'PlotBoxAspectRatio' seem to always  yield the correct ratio.
  % Critital are for example figures with subplots.
%    position = get( handle, 'Position' )
%  
%    xscaling = 1;
%    yscaling = position(4)/position(3) * (xlim(2)-xlim(1))/(ylim(2)-ylim(1));
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
% *** END FUNCTION get_axes_dimensions
% =========================================================================




% =========================================================================
% *** FUNCTION escape_characters
% ***
% *** Replaces the single characters %, ', \ by their escaped versions
% *** \'', %%, \\, respectively.
% ***
% =========================================================================
function newstr = escape_characters( str )

  newstr = str;
  newstr = strrep( newstr, '''', '\''''' );
  newstr = strrep( newstr, '%' , '%%'    );
  newstr = strrep( newstr, '\' , '\\'    );

end
% =========================================================================
% *** END FUNCTION escape_characters
% =========================================================================


% =========================================================================
% *** FUNCTION is_inside_box
% ***
% *** Determines whether the point(s) 'p' is (are) inside the rectangular
% *** box defined by xlim, ylim.
% ***
% =========================================================================
function l = is_inside_box( p, xlim, ylim );

  n = size(p,1);

  l = zeros(n,1);
  for k=1:n
      l(k) =    p(k,1)>=xlim(1) && p(k,1)<=xlim(2) ...
             && p(k,2)>=ylim(1) && p(k,2)<=ylim(2);
  end

end
% =========================================================================
% *** END FUNCTION is_inside_box
% =========================================================================