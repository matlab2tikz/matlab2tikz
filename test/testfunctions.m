% =========================================================================
% *** FUNCTION testfunctions
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
% ***
% *** Copyright (c) 2008--2012, Nico Schlömer <nico.schloemer@gmail.com>
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
function [ desc, extraOpts, funcName, numFunctions ] = testfunctions ( k )

  % assign the functions to test
  testfunction_handles = {                        ...
                           @one_point           , ...
                           @plain_cos           , ...
                           @sine_with_markers   , ...
                           @sine_with_annotation, ...
                           @linesWithOutliers   , ...
                           @peaks_contour       , ...
                           @contourPenny        , ...
                           @peaks_contourf      , ...
                           @many_random_points  , ...
                           @randomWithLines     , ...
                           @double_axes         , ...
                           @logplot             , ...
                           @colorbarLogplot     , ...
                           @legendplot          , ...
                           @legendplotBoxoff    , ...
                           @zoom                , ...
                           @quiveroverlap       , ...
                           @quiverplot          , ...
                           @imageplot           , ...
                           @logicalImage        , ...
                           @imagescplot         , ...
                           @stairsplot          , ...
                           @polarplot           , ...
                           @roseplot            , ...
                           @compassplot         , ...
                           @stemplot            , ...
                           @groupbars           , ...
                           @bars                , ...
                           @hbars                , ...
...%                             @stackbars           , ...
                           @xAxisReversed       , ...
                           @errorBars           , ...
                           @errorBars2          , ...
                           @subplot2x2          , ...
                           @subplot2x2b         , ...
                           @manualAlignment     , ...
                           @subplot3x1          , ...
                           @subplotCustom       , ...
                           @legendsubplots      , ...
                           @bodeplots           , ...
                           @mandrillImage       , ...
                           @besselImage         , ...
                           @clownImage          , ...
                           @zplanePlot1         , ...
                           @zplanePlot2         , ...
                           @freqResponsePlot    , ...
                           @multipleAxes        , ...
                           @scatterPlotRandom   , ...
                           @scatterPlot         , ...
                           @scatter3Plot        , ...
                           @scatter3Plot2       , ...
                           @surfPlot            , ...
                           @surfPlot2           , ...
                           @meshPlot            , ...
                           @ylabels             , ...
                           @spectro             , ... % takes pretty long to LuaLaTeX-compile
                           @mixedBarLine        , ...
                           @decayingharmonic    , ...
                           @texcolor            , ...
                           @textext             , ...
                           @texrandom           , ...
                           @latexmath1          , ...
                           @latexmath2          , ...
                           @parameterCurve3d    , ...
                           @parameterSurf       , ...
                           @fill3plot           , ...
                           @rectanglePlot       , ...
                           @herrorbarPlot       , ...
                           @hist3d              , ...
                           @myBoxplot
                         };

  numFunctions = length( testfunction_handles );
  if (k<=0)
      % This is used for querying numFunctions.
      desc = '';
      funcName = '';
      extraOpts = {};
  elseif (k<=numFunctions)
      [desc, extraOpts] = testfunction_handles{ k } ();
      funcName = func2str( testfunction_handles{ k } );
  else
      error( 'testfunctions:outOfBounds', ...
             'Out of bounds (number of testfunctions=%d)', numFunctions );
  end

end
% =========================================================================
% *** FUNCTION one_point
function [description, extraOpts] = one_point ()

  plot(1:10)
  title({'title', 'multline'})
  legend(char('Multi-Line Legend Entry','Wont Work 2^2=4'))
  xlabel({'one','two','three'});
  ylabel({'one','two','three'});

%  plot(0.123, 0.145, 'x');
  set(gca, 'YTick', []);

  description = 'Plot only one single point.';
  extraOpts = {};

end
% =========================================================================
% *** FUNCTION plain_cos
% ***
% *** Most simple example.
% ***
function [description, extraOpts] = plain_cos()

  fplot( @cos, [0,2*pi] );

  % add some minor ticks
  set( gca, 'XMinorTick', 'on' );
  set( gca, 'YTick', [] );

  % Adjust the aspect ratio when in MATLAB(R) or Octave >= 3.4.
  env = getEnvironment();
  switch env
      case 'MATLAB'
          daspect([ 1 2 1 ])
      case 'Octave'
          if isVersionBelow( env, 3, 4 )
              % Octave < 3.4 doesn't have daspect unfortunately.
          else
              daspect([ 1 2 1 ])
          end
      otherwise
          error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
  end

  description = 'Plain cosine function with minimumPointsDistance of $0.5$.' ;
  extraOpts = {'minimumPointsDistance', 0.5};

end
% =========================================================================
% *** FUNCTION sine_with_markers
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function [description, extraOpts] = sine_with_markers ()

  x = -pi:pi/10:pi;
  y = tan(sin(x)) - sin(tan(x));
  y(3) = NaN;
  y(7) = Inf;
  y(11) = -Inf;
  plot(x,y,'--o', 'Color', [0.6,0.2,0.0], ...
                  'LineWidth', 1*360/127,...
                  'MarkerEdgeColor','k',...
                  'MarkerFaceColor',[0.3,0.1,0.0],...
                  'MarkerSize', 5*360/127 );

  set( gca, 'Color', [0.9 0.9 1], ...
            'XTickLabel', [], ...
            'YTickLabel', [] ...
     );

  set(gca,'XTick',[0]);
  set(gca,'XTickLabel',{'null'});

  description = [ 'Twisted plot of the sine function. '                   ,...
                  'Pay particular attention to how markers and Infs/NaNs are treated.' ];
  extraOpts = {};

end
% =========================================================================
% *** FUNCTION sine_with_annotation
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function [description, extraOpts] = sine_with_annotation ()

  x = -pi:.1:pi;
  y = sin(x);
  plot(x,y);
  set(gca,'XTick',-pi:pi/2:pi);
  set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'});

  xlabel('-\pi \leq \Theta \leq \pi');
  ylabel('sin(\Theta)');
  title({'Plot of sin(\Theta)','subtitle','and here''s one really long subtitle' });
  text(-pi/4,sin(-pi/4),'\leftarrow sin(-\pi\div4)',...
      'HorizontalAlignment','left');

  set(findobj(gca,'Type','line','Color',[0 0 1]),...
      'Color','red',...
      'LineWidth',2)

  description = [ 'Plot of the sine function. '                        ,...
                  'Pay particular attention to how titles and annotations are treated.' ];
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = linesWithOutliers()
    far = 200;
    x = [ -far, -1,   -1,  -far, -10, -0.5, 0.5, 10,  far, 1,   1,    far, 10,   0.5, -0.5, -10,  -far ];
    y = [ -10,  -0.5, 0.5, 10,   far, 1,    1,   far, 10,  0.5, -0.5, -10, -far, -1,  -1,   -far, -0.5 ];
    plot( x, y,'o-');
    axis( [-2,2,-2,2] );

    description = 'Lines with outliers.';
  extraOpts = {};
end
% =========================================================================
% *** FUNCTION peaks_contour
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function [description, extraOpts] = peaks_contour()

  [C, h] = contour(peaks(20),10);
  clabel(C, h);

  % remove y-ticks
  set(gca,'YTickLabel',[]);
  set(gca,'YTick',[]);

  colormap winter;

  description = 'Test contour plots.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = contourPenny()

  if ~exist('penny.mat','file')
      fprintf( 'penny data set not found. Abort.\n\n' );
      description = [];
      return
  end

  load penny;
  contour(flipud(P));
  axis square;

  description = 'Contour plot of a US\$ Penny.';
  extraOpts = {};

end
% =========================================================================
% *** FUNCTION peaks_contourf
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function [description, extraOpts] = peaks_contourf ()

  contourf( peaks(20), 10 );
  colorbar();
%    colorbar('NorthOutside');
%    colorbar('SouthOutside');
%    colorbar('WestOutside');

%  colormap([0:0.1:1; 1:-0.1:0; 0:0.1:1]')
  colormap hsv;

  description = 'Test the contourfill plots.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = randomWithLines()

  X = randn(150,2);
  X(:,1) = (X(:,1) * 90) + 75;
  plot(X(:,1),X(:,2),'o');
  hold on;
  M(1)=min(X(:,1));
  M(2)=max(X(:,1));
  plot(M,[mean(X(:,2)) mean(X(:,2))],'k-');
  plot(M,[2*std(X(:,2)) 2*std(X(:,2))],'k--');
  plot(M,[-2*std(X(:,2)) -2*std(X(:,2))],'k--');
  axis('tight');

  description = 'Random points with lines.';
  extraOpts = {};
end
% =========================================================================
% *** FUNCTION many_random_points
% ***
% *** Test the performance when drawing many points.
% ***
% =========================================================================
function [description, extraOpts] = many_random_points ()

  n = 1e3;

  xy = rand(n,2);
  plot ( xy(:,1), xy(:,2), '.r' );
  axis([ 0, 1, 0, 1 ])

  description = 'Test the performance when drawing many points.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = double_axes()
  dyb = 0.1;   % normalized units, bottom offset
  dyt = 0.1;   % separation between subsequent axes bottoms

  x = [0; 24; 48; 72; 96;];
  y = [7.653 7.473 7.637 7.652 7.651];

  figure(1)
  grid on
  h1 = plot(x,y,'Color','k');

  % following code is taken from `floatAxisX.m'

  % get position of axes
  allAxes = get(gcf,'Children');
  naxes = length(allAxes);
  ax1Pos = get(allAxes(naxes),'position');

  % rescale and reposition all axes to handle additional axes
  for an=1:naxes-1
     if isequal(rem(an,2),0)
        % even ones in array of axes handles represent axes on which lines are plotted
        set(allAxes(an),'Position',[ax1Pos(1,1) ax1Pos(1,2)+dyb ax1Pos(1,3) ax1Pos(1,4)-dyt])
     else
        % odd ones in array of axes handles represent axes on which floating x-axss exist
        axPos = get(allAxes(an),'Position');
        set(allAxes(an),'Position',[axPos(1,1) axPos(1,2)+dyb axPos(1,3) axPos(1,4)])
     end
  end
  % first axis a special case (doesn't fall into even/odd scenario of figure children)
  set(allAxes(naxes),'Position',[ax1Pos(1,1) ax1Pos(1,2)+dyb ax1Pos(1,3) ax1Pos(1,4)-dyt])
  ylimit1 = get(allAxes(naxes),'Ylim');

  % get new position for plotting area of figure
  ax1Pos = get(allAxes(naxes),'position');

  % axis to which the floating axes will be referenced
  ref_axis = allAxes(1);
  refPosition = get(ref_axis,'position');

  % overlay new axes on the existing one
  ax2 = axes('Position',ax1Pos);
  % plot data and return handle for the line
  hl1 = plot(x,y,'k');
  % make the new axes invisible, leaving only the line visible
  set(ax2,'visible','off','ylim',ylimit1)

  % set the axis limit mode so that it does not change if the
  % user resizes the figure window
  set(ax2,'xLimMode','manual')

  % set up another set of axes to act as floater
  ax3 = axes('Position',[refPosition(1) refPosition(2)-dyb refPosition(3) 0.01]);

  set(ax3,'box','off','ycolor','w','yticklabel',[],'ytick',[])
  set(ax3,'XMinorTick','on','color','none','xcolor',get(hl1,'color'))

  xlabel('secondary axis')

  description = 'Double axes';
  extraOpts = {};
end
% =========================================================================
% *** FUNCTION logplot
% ***
% *** Test logscaled axes.
% ***
% =========================================================================
function [description, extraOpts] = logplot ()

  x = logspace(-1,2);
  loglog(x,exp(x),'-s')
  grid on

  description = 'Test logscaled axes.';
  extraOpts = {};

end
% =========================================================================
% *** FUNCTION colorbarLogplot
% ***
% *** Logscaled colorbar.
% ***
% =========================================================================
function [description, extraOpts] = colorbarLogplot ()

  imagesc([1 10 100]);
  set(colorbar(), 'YScale', 'log');

  description = 'Logscaled colorbar.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = legendplot ()

%    x = -pi:pi/20:pi;
%    plot(x,cos(x),'-ro',x,sin(x),'-.b');
%    h = legend('one pretty long legend cos_x','sin_x',2);
%    set(h,'Interpreter','none');

  x = 0:0.01:2*pi;
  plot( x, sin(x), 'b', ...
        x, cos(x), 'r' );
  xlim( [0 2*pi] )
  ylim( [-0.9 0.9] )
  title( '{tikz test}' )
  xlabel( '{x-Values}' )
  ylabel( '{y-Values}' )
  legend( 'sin(x)', 'cos(x)', 'Location','NorthOutside', ...
                              'Orientation', 'Horizontal' );
  grid on

  description = 'Test inserting of legends.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = legendplotBoxoff ()

  x = -pi:pi/20:pi;
  plot( x, cos(x),'-ro',...
        x, sin(x),'-.b' ...
      );
  h = legend( 'cos_x', 'one pretty long legend sin_x', 2 );
  set( h, 'Interpreter', 'none' );
  legend boxoff;

  description = 'Test inserting of legends.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = zoom()

  fplot( @sin, [0,2*pi], '-*' );
  hold on;
  delta = pi/10;

  plot( [pi/2, pi/2], [1-2*delta, 1+2*delta], 'r' ); % vertical line
  plot( [pi/2-2*delta, pi/2+2*delta], [1, 1], 'g' ); % horizontal line

  % diamond
  plot( [ pi/2-delta, pi/2 , pi/2+delta, pi/2 , pi/2-delta ], ...
        [ 1       , 1-delta,        1, 1+delta, 1        ], 'y'      );

  % boundary lines with markers
  plot([ pi/2-delta, pi/2 , pi/2+delta, pi/2+delta pi/2+delta, pi/2, pi/2-delta, pi/2-delta ], ...
       [ 1-delta, 1-delta, 1-delta, 1, 1+delta, 1+delta, 1+delta, 1 ], ...
       'ok', ...
       'MarkerSize', 20, ...
       'MarkerFaceColor', 'g' ...
       );

  hold off;

  axis([pi/2-delta, pi/2+delta, 1-delta, 1+delta] );

  description = 'Plain cosine function, zoomed in.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = bars()
  bins = -0.5:0.1:0.5;
  bins = 10 * bins;
  numEntries = length(bins);
  numBars = 3;
  data = round(100 * rand(numEntries, numBars));

  bar(bins,data, 1.5);

  description = 'Plot with bars.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = hbars()
  y = [75.995 91.972 105.711 123.203 131.669 ...
     150.697 179.323 203.212 226.505 249.633 281.422];
  barh(y);
  description = 'Horizontal bars.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = groupbars()
  X = [1,2,3,4,5];
  Y = round(rand(5,2)*20);
%    bar(X,Y,'group','BarWidth',1.0);
  makebars(X,Y,1.0,'grouped');
%    set(gca,'XTick',[4,4.2,4.25,4.3,4.4,4.45,4.5]);
  title 'Group';
  description = 'Plot with bars in groups.';
  extraOpts = {};
end
% =========================================================================
%  function [description, extraOpts] = stackbars()
%
%    Y = round(rand(5,3)*10);
%    bar(Y,'stack');
%    title 'Stack';
%
%    description = 'Plot of stacked bars.' ;
%
%  end
% =========================================================================
function [description, extraOpts] = stemplot ()

  x = 0:25;
  y = [exp(-.07*x).*cos(x);
       exp(.05*x).*cos(x)]';
  h = stem(x,y);
  legend( 'exp(-.07x)*cos(x)', 'exp(.05*x)*cos(x)', 'Location', 'NorthWest');
  set(h(1),'MarkerFaceColor','blue')
  set(h(2),'MarkerFaceColor','red','Marker','square')

  description = 'A simple stem plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = stairsplot ()

  x = linspace(-2*pi,2*pi,40);
  stairs(x,sin(x))

  description = 'A simple stairs plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = quiverplot ()

  [X,Y] = meshgrid(-2:.2:2);
  Z = X.*exp(-X.^2 - Y.^2);
  [DX,DY] = gradient(Z,.2,.2);
  contour(X,Y,Z);
  hold on
  quiver(X,Y,DX,DY);
  colormap hsv;
  hold off

  description = 'A combined quiver/contour plot of $x\exp(-x^2-y^2)$.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = quiveroverlap ()

  x = [0 1];
  y = [0 0];
  u = [1 -1];
  v = [1 1];

  quiver(x,y,u,v);

  description = 'Quiver plot with avoided overlap.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = polarplot ()

  t = 0:.01:2*pi;
  polar(t,sin(2*t).*cos(2*t),'--r')

  description = 'A simple polar plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = roseplot ()

  theta = 2*pi*rand(1,50);
  rose(theta);

  description = 'A simple rose plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = compassplot ()

  Z = eig(randn(20,20));
  compass(Z);

  description = 'A simple compass plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = imageplot ()

  n       = 10;
  density = 0.5;

  subplot( 1, 2, 1 );
  A       = sprand( n, n, density );
  imagesc( A );

  subplot( 1, 2, 2 );
  A       = sprand( n, n, density );
  imagesc( A );

  description = 'An image plot of matrix values.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = logicalImage()
  data = rand(10,10);
  imagesc(data > 0.5);
  description = 'An image plot of logical matrix values.' ;
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = imagescplot ()

  pointsX = 10;
  pointsY = 20;
  x       = 0:1/pointsX:1;
  y       = 0:1/pointsY:1;
  z       = sin(x)'*cos(y);
  imagesc(x,y,z);

  description = 'An imagesc plot of $\sin(x)\cos(y)$.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = xAxisReversed ()

  n = 100;
  x = (0:1/n:1);
  y = exp(x);
  plot(x,y);
  set(gca,'XDir','reverse');
  set(gca,'YDir','reverse');
  legend( 'Location', 'SouthWest' );

  description = 'Reversed axes with legend.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = subplot2x2 ()

  x = (1:5);

  subplot(2,2,1);
  y = rand(1,5);
  plot(x,y);

  subplot(2,2,2);
  y = rand(1,5);
  plot(x,y);

  subplot(2,2,3);
  y = rand(1,5);
  plot(x,y);

  subplot(2,2,4);
  y = rand(1,5);
  plot(x,y);


  description = 'Four aligned subplots on a $2\times 2$ subplot grid.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = subplot2x2b ()

  x = (1:5);

  subplot(2,2,1);
  y = rand(1,5);
  plot(x,y);

  subplot(2,2,2);
  y = rand(1,5);
  plot(x,y);

  subplot(2,2,3:4);
  y = rand(1,5);
  plot(x,y);


  description = 'Three aligned subplots on a $2\times 2$ subplot grid.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = manualAlignment()

  xrange = linspace(-3,4,2*1024);

  axes('Position', [0.1 0.1 0.85 0.15]);
  plot(xrange);
  ylabel('$n$');
  xlabel('$x$');

  axes('Position', [0.1 0.25 0.85 0.6]);
  plot(xrange);
  set(gca,'XTick',[]);

  description = 'Manually aligned figures.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = subplot3x1 ()

  x = (1:5);

  subplot(3,1,1);
  y = rand(1,5);
  plot(x,y);

  subplot(3,1,2);
  y = rand(1,5);
  plot(x,y);

  subplot(3,1,3);
  y = rand(1,5);
  plot(x,y);

  description = 'Three aligned subplots on a $3\times 1$ subplot grid.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = subplotCustom ()

  x = (1:5);

  y = rand(1,5);
  subplot( 'Position', [0.05 0.1 0.3 0.3] )
  plot(x,y);


  y = rand(1,5);
  subplot( 'Position', [0.35 0.5 0.3 0.3] )
  plot(x,y);

  y = rand(1,5);
  subplot( 'Position', [0.65 0.1 0.3 0.3] )
  plot(x,y);

  description = 'Three customized aligned subplots.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = errorBars ()

  X = 0:pi/10:pi;
  Y = sin(X);
  E = std(Y)*ones(size(X));
  errorbar(X,Y,E)

  description = 'Generic error bar plot.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = errorBars2 ()

  data = load( 'myCount.dat' );
  y = mean( data, 2 );
  e = std( data, 1, 2 );
  errorbar( y, e, 'xr' );

  description = 'Another error bar example.' ;
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = legendsubplots ()
  % size of upper subplot
  rows = 4;
  % number of points.  A large number here (eg 1000) will stress-test
  % matlab2tikz and your TeX installation.  Be prepared for it to run out of
  % memory
  length = 100;


  % generate some spurious data
  t=0:(4*pi)/length:4*pi;
  x=t;
  a=t;
  y=sin(t)+0.1*randn(1,length+1);
  b=sin(t)+0.1*randn(1,length+1)+0.05*cos(2*t);

  % plot the top figure
  subplot(rows+2,1,1:rows);

  % first line
  sigma1=std(y);
  tracey=mean(y,1);
  plot123=plot(x,tracey,'b-');

  hold on

  % second line
  sigma2=std(b);
  traceb=mean(b,1);
  plot456=plot(a,traceb,'r-');

  spec0=['Mean V(t)_A (\sigma \approx ' num2str(sigma1,'%0.4f') ')'];
  spec1=['Mean V(t)_B (\sigma \approx ' num2str(sigma2,'%0.4f') ')'];

  hold off
  %plot123(1:2)
  legend([plot123; plot456],spec0,spec1)
  legend boxoff
  xlabel('Time/s')
  ylabel('Voltage/V')
  title('Time traces');

  % now plot a differential trace
  subplot(rows+2,1,rows+1:rows+2)
  plot7=plot(a,traceb-tracey,'k');

  legend(plot7,'\Delta V(t)')
  legend boxoff
  xlabel('Time/s')
  ylabel('\Delta V')
  title('Differential time traces');

  description = [ 'Subplots with legends. '                             , ...
                  'Increase value of "length" in the code to stress-test your TeX installation.' ];
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = bodeplots()

  % check if the control toolbox is installed
  if length(ver('control')) ~= 1
      fprintf( 'Control toolbox not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  g = tf([1 0.1 7.5],[1 0.12 9 0 0]);
  bode(g)
  description = 'Bode diagram of frequency response.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = mandrillImage()

  if ~exist('mandrill.mat','file')
      fprintf( 'mandrill data set not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  data = load( 'mandrill' );
  set( gcf, 'color', 'k' )
  image( data.X )
  colormap( data.map )
  axis off
  axis image

  description = 'Picture of a mandrill.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = besselImage()

  nu   = -5:0.25:5;
  beta = 0:0.05:2.5;

  m = length(beta);
  n = length(nu);
  trace = zeros(m,n);
  for i=1:length(beta);
      for j=1:length(nu)
              if (floor(nu(j))==nu(j))
                  trace(i,j)=abs(besselj(nu(j),beta(i)));
              end
      end
  end

  imagesc(nu,beta,trace);
  colorbar()
  xlabel('Order')
  ylabel('\beta')
  set(gca,'YDir','normal')

  description = 'Bessel function.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = clownImage()

  if ~exist('clown.mat','file')
      fprintf( 'clown data set not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  data = load( 'clown' );
  imagesc( data.X )
  colormap( gray )

  description = 'Picture of a clown.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = zplanePlot1()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  [z,p] = ellip(4,3,30,200/500);
  zplane(z,p);
  title('4th-Order Elliptic Lowpass Digital Filter');

  description = 'Representation of the complex plane with zplane.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = zplanePlot2()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  [b,a] = ellip(4,3,30,200/500);
  Hd = dfilt.df1(b,a);
  zplane(Hd) % FIXME: This opens a new figure that doesn't get closed automatically

  description = 'Representation of the complex plane with zplane.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = freqResponsePlot()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  b  = fir1(80,0.5,kaiser(81,8));
  hd = dfilt.dffir(b);
  freqz(hd); % FIXME: This opens a new figure that doesn't get closed automatically

  description = 'Frequency response plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = multipleAxes()
  x1 = 0:.1:40;
  y1 = 4.*cos(x1)./(x1+2);
  x2 = 1:.2:20;
  y2 = x2.^2./x2.^3;

  line(x1,y1,'Color','r');
  ax1 = gca;
  set(ax1,'XColor','r','YColor','r')

  ax2 = axes('Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

  line(x2,y2,'Color','k','Parent',ax2);

  xlimits = get(ax1,'XLim');
  ylimits = get(ax1,'YLim');
  xinc = (xlimits(2)-xlimits(1))/5;
  yinc = (ylimits(2)-ylimits(1))/5;

  % Now set the tick mark locations.
  set(ax1,'XTick',xlimits(1):xinc:xlimits(2) ,...
          'YTick',ylimits(1):yinc:ylimits(2) )
  description = 'Multiple axes.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = scatterPlotRandom()

  x = randn( 10, 2 );
  scatter( x(:,1), x(:,2)  );
  description = 'Generic scatter plot.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = scatterPlot()

  if ~exist('seamount.mat','file')
      fprintf( 'seamount data set not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  data = load( 'seamount' );
  scatter( data.x, data.y, 5, data.z, '^' );
  description = 'Scatter plot with MATLAB(R) data.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = scatter3Plot()

  [x,y,z] = sphere(16);
  X = [x(:)*.5 x(:)*.75 x(:)];
  Y = [y(:)*.5 y(:)*.75 y(:)];
  Z = [z(:)*.5 z(:)*.75 z(:)];
  S = repmat([1 .75 .5]*10,numel(x),1);
  C = repmat([1 2 3],numel(x),1);
  scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
  view(40,35)

  description = 'Scatter3 plot with MATLAB(R) data.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = scatter3Plot2()

  % Read image (Note: "peppers.png" is available with MATLAB)
  InpImg_RGB = imread('peppers.png');

  % Subsample image ("scatter3" can't cope with too many points)
  InpImg_RGB = InpImg_RGB(1:100:end, 1:100:end, 1:100:end );

  InpImg_RGB = reshape(InpImg_RGB, [], 1, 3);

  % Split up into single components
  r = InpImg_RGB(:,:,1);
  g = InpImg_RGB(:,:,2);
  b = InpImg_RGB(:,:,3);

  % Scatter-plot points
  scatter3(r,g,b,15,[r g b]);
  xlabel('R');
  ylabel('G');
  zlabel('B');

  description = 'Another Scatter3 plot.';
  extraOpts = {};

  return
end
% =========================================================================
function [description, extraOpts] = surfPlot()
  [X,Y,Z] = peaks(30);
  surf(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])
  set(gca,'View',[-37.5,36]);

  colorbar

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Surface plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = surfPlot2()
  z = [ ones(15, 5) zeros(15,5); ...
        zeros(5,5) zeros(5,5)
      ];

  surf( abs( fftshift(fft2(z)) ) )

  legend( 'legendary', 'Location', 'NorthEastOutside' );

  description = 'Another surface plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = meshPlot()
  [X,Y,Z] = peaks(30);
  mesh(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Mesh plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = ylabels()

  x = 0:.01:2*pi;
  H = plotyy(x,sin(x),x,3*cos(x));

  ylabel(H(1),'sin(x)');
  ylabel(H(2),'3cos(x)');

  xlabel(gca,'time')

  description = 'Separate y-labels.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = spectro()

  % In the original test case, this is 0:0.001:2, but that takes forever
  % for LaTeX to process.
  if ~exist('chirp', 'builtin')
      fprintf( 'chirp() not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  T = 0:0.005:2;
  X = chirp(T,100,1,200,'q');
  spectrogram(X,128,120,128,1E3);
  title('Quadratic Chirp');

  description = 'Spectrogram plot';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = mixedBarLine()

  x = rand(1000,1)*10;
  hist(x,10)
  y = ylim;
  hold on;
  plot([3 3], y, '-r');
  hold off;

  description = 'Mixed bar/line plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = decayingharmonic()
  % Based on an example from
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  A = 0.25;
  alpha = 0.007;
  beta = 0.17;
  t = 0:901;
  y = A * exp(-alpha*t) .* sin(beta*t);
  plot(t, y)
  title('{\itAe}^{-\alpha\itt}sin\beta{\itt}, \alpha<<\beta')
  xlabel('Time \musec.')
  ylabel('Amplitude')

  description = 'Decaying harmonic oscillation with \TeX{} title.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = texcolor()
  % Taken from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  text(.1, .5, ['\fontsize{16}black {\color{magenta}magenta '...
                '\color[rgb]{0 .5 .5}teal \color{red}red} black again'])

  description = 'Multi-colored text using \TeX{} commands.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = textext()
  % Taken from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28303
  txstr(1) = { 'Each cell is a quoted string' };
  txstr(2) = { 'You can specify how the string is aligned' };
  txstr(3) = { 'You can use LaTeX symbols like \pi \chi \Xi' };
  txstr(4) = { '\bfOr use bold \rm\itor italic font\rm' };
  txstr(5) = { '\fontname{courier}Or even change fonts' };
  plot( 0:6, sin(0:6) )
  text( 5.75, sin(2.5), txstr, 'HorizontalAlignment', 'right' )

  description = 'Formatted text and special characters using \TeX{}.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = texrandom()

  num = 20; % number of symbols per line
  symbols = {'\it', '\bf', '\rm', '\sl',                                ...
             '\alpha', '\angle', '\ast', '\beta', '\gamma', '\delta',   ...
             '\epsilon', '\zeta', '\eta', '\theta', '\vartheta',        ...
             '\iota', '\kappa', '\lambda', '\mu', '\nu', '\xi', '\pi',  ...
             '\rho', '\sigma', '\varsigma', '\tau', '\equiv', '\Im',    ...
             '\otimes', '\cap', '{\int}', '\rfloor', '\lfloor', '\perp',...
             '\wedge', '\rceil', '\vee', '\langle', '\upsilon', '\phi', ...
             '\chi', '\psi', '\omega', '\Gamma', '\Delta', '\Theta',    ...
             '\Lambda', '\Xi', '\Pi', '\Sigma', '\Upsilon', '\Phi',     ...
             '\Psi', '\Omega', '\forall', '\exists', '\ni', '{\cong}',  ...
             '\approx', '\Re', '\oplus', '\cup', '\subseteq', '\lceil', ...
             '\cdot', '\neg', '\times', '\surd', '\varpi', '\rangle',   ...
             '\sim', '\leq', '\infty', '\clubsuit', '\diamondsuit',     ...
             '\heartsuit', '\spadesuit', '\leftrightarrow',             ...
             '\leftarrow', '\Leftarrow', '\uparrow', '\rightarrow',     ...
             '\Rightarrow', '\downarrow', '\circ', '\pm', '\geq',       ...
             '\propto', '\partial', '\bullet', '\div', '\neq',          ...
             '\aleph', '\wp', '\oslash', '\supseteq', '\nabla',         ...
             '{\ldots}', '\prime', '\0', '\mid', '\copyright',          ...
             '\o', '\in', '\subset', '\supset',                         ...
             '\_', '\^', '\{', '\}', '$', '%', '#',                     ...
             '(', ')', '+', '-', '=', '/', ',', '.', '<', '>',          ...
             '!', '?', ':', ';', '*', '[', ']', '§', '"', '''',         ...
             '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',          ...
             'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',     ...
             'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',     ...
             'w', 'x', 'y', 'z',                                        ...
             'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',     ...
             'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',     ...
             'W', 'X', 'Y', 'Z'                                         ...
            };
      % Note: Instead of '\ldots' the list of symbols contains the entry
      %       '{\ldots}'. This is because TeX gives an error if it
      %       encounters the sequence '$a_\ldots$' or '$a^\ldots$'. It
      %       looks like that is a TeX bug. Nevertheless this sequence
      %       could appear in the random output, therefore \ldots is
      %       wrapped in braces since '$a_{\ldots}$' and '$a^{\ldots}$'
      %       don't crash TeX.
      %       Same thing with '\cong' and '\int'.
      % \color{red} etc. isn't included
      % \fontname{Times} etc. isn't included
      % \fontsize{12} etc. isn't included

  switch getEnvironment()
      case 'MATLAB'
          % MATLAB expects tilde and ampersand to be un-escaped and backslashes
          % to be escaped
          symbols = [ symbols, {'~', '&', '\\'} ];
      case 'Octave'
          % Octave expects tilde and ampersand to be escaped for regular
          % output. If either are used un-escaped, that creates odd output in
          % Octave itself, but since matlab2tikz should be able to handle
          % those cases, let's include the un-escaped symbols in the list.
          symbols = [ symbols, {'\~', '\&', '~', '&'} ];
          % Octave's backslash handling is weird to say the least. However,
          % matlab2tikz treats backslashes the same in Octave as it does in
          % MATLAB. Therefore, let's add an escaped backslash to the list
          symbols = [ symbols, {'\\'} ];
      otherwise
          error( 'Unknown environment. Need MATLAB(R) or Octave.' )
  end

  for ypos = [0.9:-.2:.1]
      % Generate `num' random indices to the list of symbols
      index = max(ceil(rand(1, num)*length(symbols)), 1);
      % Assemble symbols into one cell string array
      string = symbols(index);

      % Add random amount of balanced braces in random positions to `string'.
      % By potentially generating more than one set of braces randomly, it's
      % possible to create more complex patterns of nested braces. Increase
      % `braceprob' to get more braces, but don't use values greater than or
      % equal 1 which would result in an infinite loop.
      braceprob = 0.6;
      while rand(1,1) < braceprob
          % Generate two random numbers ranging from 1 to n with n = number
          % of symbols in `string'
          bracepos = max(ceil(rand(1, 2)*length(string)), 1);
          % Modify `string' so that an opening brace is inserted before
          % min(bracepos) symbols and a closing brace after max(bracepos)
          % symbols. That way any number of symbols from one to all in
          % `string' are wrapped in braces for min(bracepos) == max(bracepos)
          % and min(bracepos) == 1 && max(bracepos) == length(string),
          % respectively.
          string = [string(1:min(bracepos)-1), {'{'},    ...
                    string(min(bracepos):max(bracepos)), ...
                    {'}'}, string(max(bracepos)+1:end)   ];
      end
      % Clean up: remove '{}', '{{}}', etc.
      clean = false;
      while clean == false
          clean = true;
          for i = 1:length(string)-1
              if strcmp( string(i), '{' ) && strcmp( string(i+1), '}' )
                  string = [string(1:i-1), string(i+2:end)];
                  clean = false;
                  break
              end
          end
      end

      % Subscripts '_' and superscripts '^' in TeX are tricky in that certain
      % combinations are not allowed and there are some subtleties in regard
      % to more complicated combinations of sub/superscripts:
      % - ^a or _a at the beginning of a TeX math expression is permitted.
      % - a^ or a_ at the end of a TeX math expression is not.
      % - a__b, a_^b, a^_b, or a^^b is not allowed, as is any number of
      %   consecutive sub/superscript operators. Actually a^^b does not
      %   crash TeX, but it produces seemingly random output instead of `b',
      %   therefore it should be avoided, too.
      % - a^b^c or a_b_c is not allowed as it results in a "double subscript/
      %   superscript" error.
      % - a^b_c or a_b^c, however, does work.
      % - a^bc^d or a_bc_d also works.
      % - a^b_c^d or a_b^c_d is not allowed and results in a "double
      %   subscript/superscript" error.
      % - a{_}b, a{^}b, {a_}b or {a^}b is not permitted.
      % - a{_b} or a{^b} is valid TeX code.
      % - {a_b}_c produces the same output as a_{bc}. Likewise for '^'.
      % - a_{b_c} results in "a index b sub-index c". Likewise for '^'.
      % - a^{b}^c or a_{b}_c is not allowed as it results in a "double
      %   subscript/superscript" error.
      %
      % From this we can derive a number of rules:
      % 1)  The last symbol in a TeX string must not be '^' or '_'.
      % 2a) There must be at least one non-brace symbol between any '^' and '_'.
      % 2b) There must be at least one non-brace symbol between any '_' and '^'.
      % 3a) There must either be at least two non-brace, non-'_' symbols or at
      %     least one non-brace, non-'_' symbol and one brace (opening or
      %     closing) between any two '^'.
      % 3b) There must either be at least two non-brace, non-'^' symbols or at
      %     least one brace (opening or closing) between any two '_'.
      % 4)  '^' or '_' must not appear directly before '}'.
      % 5)  '^' or '_' must not appear directly after '}'.
      % 6)  Whenever braces were mentioned, that refers to non-empty braces,
      %     i.e. '{}' counts as nothing. Printable/escaped braces '\{' and '\}'
      %     also don't count as braces but as regular symbols.
      % 7)  '^' or '_' must not appear directly before '\it', '\bf', '\rm', or
      %     '\sl'.
      % 8)  '^' or '_' must not appear directly after '\it', '\bf', '\rm', or
      %     '\sl'.
      %
      % A few test cases:
      % Permitted: ^a...  _a...  a^b_c  a_b^c  a^bc^d  a_bc_d  a{_b}  a{^b}
      %            {a_b}_c  a_{bc}  {a^b}^c  a^{bc}  a_{b_c}  a^{b^c}
      % Forbidden: ...z^  ...z_  a__b  a_^b  a^_b  [a^^b]  a^b^c  a_b_c
      %            a^b_c^d  a_b^c_d  a{_}b  a{^}b  {a_}b  {a^}b
      %            a^{_b}  a_{^b}  a^{b}^c  a_{b}_c
      %
      % Now add sub/superscripts according to these rules
      subsupprob   = 0.1;  % Probability for insertion of a sub/superscript
      caretdist    = Inf;  % Distance to the last caret
      underscdist  = Inf;  % Distance to the last underscore
      bracedist    = Inf;  % Distance to the last brace (opening or closing)
      pos = 0;
      % Making sure the post-update `pos' in the while loop is less than the
      % number of symbols in `string' enforces rule 1: The last symbol in
      % a TeX string must not be '^' or '_'.
      while pos+1 < length(string)
         % Move one symbol further
         pos = pos + 1;
         % Enforce rule 7: No sub/superscript directly before '\it', '\bf',
         %                 '\rm', or '\sl'.
         if strcmp( string(pos), '\it' ) || strcmp( string(pos), '\bf' ) ...
         || strcmp( string(pos), '\rm' ) || strcmp( string(pos), '\sl' )
             continue
         end
         % Enforce rule 8: No sub/superscript directly after '\it', '\bf',
         %                 '\rm', or '\sl'.
         if (pos > 1)                           ...
         && (    strcmp( string(pos-1), '\it' ) ...
              || strcmp( string(pos-1), '\bf' ) ...
              || strcmp( string(pos-1), '\rm' ) ...
              || strcmp( string(pos-1), '\sl' ) ...
            )
             continue
         end
         bracedist = bracedist + 1;
         % Enforce rule 4: No sub/superscript directly before '}'
         if strcmp( string(pos), '}' )
             bracedist = 0; % Also update braces distance
             continue
         end
         % Enforce rule 5: No sub/superscript directly after '}'
         if (pos > 1) && strcmp( string(pos-1), '}' )
             continue
         end
         % Update distances for either braces or caret/underscore depending
         % on whether the symbol currently under scrutiny is a brace or not.
         if strcmp( string(pos), '{' )
             bracedist = 0;
         else
             caretdist = caretdist + 1;
             underscdist = underscdist + 1;
         end
         % Generate two random numbers, then check if any of them is low
         % enough, so that with probability `subsupprob' a sub/superscript
         % operator is inserted into `string' at the current position. In
         % case both random numbers are below the threshold, whether a
         % subscript or superscript operator is to be inserted depends on
         % which of the two numbers is smaller.
         randomnums = rand(1, 2);
         if min(randomnums) < subsupprob
             if randomnums(1) < randomnums(2)
                 % Enforce rule 2b: There must be at least one non-brace
                 % symbol between previous '_' and to-be-inserted '^'.
                 if underscdist < 1
                     continue
                 end
                 % Enforce rule 3a: There must either be at least two
                 % non-brace, non-'_' symbols or at least one brace (opening
                 % or closing) between any two '^'.
                 if ~( ((caretdist >= 2) && (underscdist >= 2)) ...
                       || ((bracedist < 2) && (caretdist >= 2)) )
                     continue
                 end
                 % Insert '^' before `pos'th symbol in `string' now that
                 % we've made sure all rules are honored.
                 string = [ string(1:pos-1), {'^'}, string(pos:end) ];
                 caretdist = 0;
                 pos = pos + 1;
             else
                 % Enforce rule 2a: There must be at least one non-brace
                 % symbol between previous '^' and to-be-inserted '_'.
                 if caretdist < 1
                     continue
                 end
                 % Enforce rule 3b: There must either be at least two
                 % non-brace, non-'^' symbols or at least one brace (opening
                 % or closing) between any two '_'.
                 if ~( ((caretdist >= 2) && (underscdist >= 2)) ...
                       || ((bracedist < 2) && (underscdist >= 2)) )
                     continue
                 end
                 % Insert '_' before `pos'th symbol in `string' now that
                 % we've made sure all rules are honored.
                 string = [ string(1:pos-1), {'_'}, string(pos:end) ];
                 underscdist = 0;
                 pos = pos + 1;
             end
         end
      end % while pos+1 < length(string)

      % Now convert the cell string array of symbols into one regular string
      string = [string{:}];
      % Print the string in the figure to be converted by matlab2tikz
      text( .05, ypos, string, 'interpreter', 'tex' )
      % And print it to the console, too, in order to enable analysis of
      % failed tests
      fprintf( 'Original string: %s\n', string )
  end

  title('Random TeX symbols \\\{\}\_\^$%#&')

  description = 'Random TeX symbols';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = latexmath1()
  % Adapted from an example at
  % http://www.mathworks.com/help/techdoc/ref/text_props.html#Interpreter
  axes
  title( '\omega\subseteq\Omega' );
  text( 0.5, 0.5, '$$\int_0^x\!\int_{\Omega} dF(u,v) d\omega$$', ...
        'Interpreter', 'latex',                   ...
        'FontSize', 16                            )

  description = 'A formula typeset using the \LaTeX{} interpreter.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = latexmath2()
  % Adapted from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#bq558_t
  set(gcf, 'color', 'white')
  set(gcf, 'units', 'inches')
  set(gcf, 'position', [2 2 4 6.5])
  set(gca, 'visible', 'off')

  % Note: Most likely due to a bug in matlab2tikz the pgfplots output will
  %       appear empty even though the LaTeX strings are contained in the
  %       output file. This is because the following (or something like it)
  %       is missing from the axis environment properties:
  %       xmin=0, xmax=4, ymin=-1, ymax=6
  % Note: The matrices in h(1) and h(2) cannot be compiled inside pgfplots.
  %       They are therefore disabled.
% h(1) = text( 'units', 'inch', 'position', [.2 5],                    ...
%       'fontsize', 14, 'interpreter', 'latex', 'string',              ...
%       [ '$$\hbox {magic(3) is } \left( {\matrix{ 8 & 1 & 6 \cr'      ...
%         '3 & 5 & 7 \cr 4 & 9 & 2 } } \right)$$'                      ]);
% h(2) = text( 'units', 'inch', 'position', [.2 4],                    ...
%       'fontsize', 14, 'interpreter', 'latex', 'string',              ...
%       [ '$$\left[ {\matrix{\cos(\phi) & -\sin(\phi) \cr'             ...
%         '\sin(\phi) & \cos(\phi) \cr}} \right]'                      ...
%         '\left[ \matrix{x \cr y} \right]$$'                          ]);
  h(3) = text( 'units', 'inch', 'position', [.2 3],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        [ '$$L\{f(t)\}  \equiv  F(s) = \int_0^\infty\!\!{e^{-st}'      ...
          'f(t)dt}$$'                                                  ]);
  h(4) = text( 'units', 'inch', 'position', [.2 2],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        '$$e = \sum_{k=0}^\infty {1 \over {k!} } $$'                   );
  h(5) = text( 'units', 'inch', 'position', [.2 1],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        [ '$$m \ddot y = -m g + C_D \cdot {1 \over 2}'                 ...
          '\rho {\dot y}^2 \cdot A$$'                                  ]);
  h(6) = text( 'units', 'inch', 'position', [.2 0],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        '$$\int_{0}^{\infty} x^2 e^{-x^2} dx = \frac{\sqrt{\pi}}{4}$$' );

  % TODO: On processing the matlab2tikz_acidtest output, LaTeX complains
  %       about the use of \over:
  %         Package amsmath Warning: Foreign command \over;
  %         (amsmath)                \frac or \genfrac should be used instead

  description = 'Some nice-looking formulas typeset using the \LaTeX{} interpreter.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = parameterCurve3d()
  ezplot3('sin(t)','cos(t)','t',[0,6*pi]);
  description = 'Parameter curve in 3D.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = parameterSurf()
  x = rand(100,1)*4-2;
  y = rand(100,1)*4-2;
  z = x.*exp(-x.^2-y.^2);

  % Construct the interpolant
  % F = TriScatteredInterp(x,y,z,'nearest');
  % F = TriScatteredInterp(x,y,z,'natural');
  F = TriScatteredInterp(x,y,z,'linear');

  % Evaluate the interpolant at the locations (qx, qy), qz
  % is the corresponding value at these locations.
  ti = -2:.25:2;
  [qx,qy] = meshgrid(ti,ti);
  qz = F(qx,qy);

  hold on
  surf(qx,qy,qz)
  plot3(x,y,z,'o')
  view(gca,[-69 14]);
  hold off

  description = 'Parameter and surface plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = fill3plot()

  if ~exist('fill3','builtin')
      fprintf( 'fill3() not found. Abort.\n\n' );
      description = [];
      return
  end

  x1 = -10:0.1:10;
  x2 = -10:0.1:10;
  p = sin(x1);
  d = zeros(1,numel(p));
  d(2:2:end) = 1;
  h = p.*d;
  grid on;
  fill3(x1,x2,h,'k');
  view(45,22.5);

  description = 'fill3 plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = rectanglePlot()
  rectangle('Position', [0.59,0.35,3.75,1.37],...
            'Curvature', [0.8,0.4],...
            'LineWidth', 2, ...
            'LineStyle', '--' ...
           );
  daspect([1,1,1]);

  description = 'Rectangle handle.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = herrorbarPlot()
  hold on;
  X = 1:10;
  Y = 1:10;
  err = repmat(0.2, 1, 10);
  h1 = errorbar(X, Y, err, 'r');
  h_vec = herrorbar(X, Y, err);
  for h=h_vec
      set(h, 'color', [1 0 0]);
  end
  h2 = errorbar(X, Y+1, err, 'g');
  h_vec = herrorbar(X, Y+1, err);
  for h=h_vec
      set(h, 'color', [0 1 0]);
  end
  legend([h1 h2], {'test1', 'test2'})

  description = 'herrorbar plot.';
  extraOpts = {};
end
% =========================================================================
function [description, extraOpts] = hist3d()

  if ~exist('hist3','builtin') && isempty(which('hist3'))
      fprintf( 'Statistics toolbox not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

%  load carbig
%  X = [MPG,Weight];
%  hist3(X,[7 7]);
%  xlabel('MPG'); ylabel('Weight');
%  set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');

  load carbig
  X = [MPG,Weight];
  hist3(X,[7 7]);
  xlabel('MPG'); ylabel('Weight');
  hist3(X,[7 7],'FaceAlpha',.65);
  xlabel('MPG'); ylabel('Weight');
  % Linux crashed with OpenGL.
  %%set(gcf,'renderer','opengl');

%  load seamount
%  dat = [-y,x]; % Grid corrected for negative y-values
%  n = hist3(dat); % Extract histogram data;
%                  % default to 10x10 bins
%  view([-37.5, 30]);

  description = '3D histogram plot.';
  extraOpts = {};

end
% =========================================================================
function [description, extraOpts] = myBoxplot()

  if ~exist('boxplot','builtin') && isempty(which('boxplot'))
      fprintf( 'Statistics toolbox not found. Abort.\n\n' );
      description = [];
      extraOpts = {};
      return
  end

  errors =[
     0.810000   3.200000   0.059500
     0.762500  -3.200000   0.455500
     0.762500   4.000000   0.901000
     0.762500   3.600000   0.406000
     0.192500   3.600000   0.307000
     0.810000  -3.600000   0.604000
     1.000000  -2.400000   0.505000
     0.430000  -2.400000   0.455500
     1.000000   3.200000   0.158500
  ];

  boxplot(errors);

  description = 'Boxplot.';
  extraOpts = {};
end
% =========================================================================
function env = getEnvironment
  env = '';
  % Check if we are in MATLAB or Octave.
  % `ver' in MATLAB gives versioning information on all installed packages
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
function [below, noenv] = isVersionBelow ( env, threshMajor, threshMinor )
  % get version string for `env' by iterating over all toolboxes
  versionData = ver;
  versionString = '';
  for k = 1:max(size(versionData))
      if strcmp( versionData(k).Name, env )
          % found it: store and exit the loop
          versionString = versionData(k).Version;
          break
      end
  end

  if isempty( versionString )
      % couldn't find `env'
      below = true;
      noenv = true;
      return
  end

  majorVer = str2double(regexprep( versionString, '^(\d+)\..*', '$1' ));
  minorVer = str2double(regexprep( versionString, '^\d+\.(\d+\.?\d*)[^\d]*.*', '$1' ));

  if (majorVer < threshMajor) || (majorVer == threshMajor && minorVer < threshMinor)
      % version of `env' is below threshold
      below = true;
  else
      % version of `env' is same as or above threshold
      below = false;
  end
  noenv = false;
end
% =========================================================================
