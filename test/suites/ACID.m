% =========================================================================
% *** FUNCTION ACID
% ***
% *** MATLAB2TikZ ACID test functions
% ***
% =========================================================================
function [status] = ACID(k)

  % assign the functions to test
  testfunction_handles = {                        ...
                           @multiline_labels    , ...
                           @plain_cos           , ...
                           @sine_with_markers   , ...
                           @markerSizes         , ...
                           @markerSizes2        , ...
                           @sine_with_annotation, ...
                           @linesWithOutliers   , ...
                           @peaks_contour       , ...
                           @contourPenny        , ...
                           @peaks_contourf      , ...
                           @many_random_points  , ...
                           @double_colorbar     , ...
                           @randomWithLines     , ...
                           @double_axes         , ...
                           @double_axes2        , ...
                           @logplot             , ...
                           @colorbarLogplot     , ...
                           @legendplot          , ...
                           @legendplotBoxoff    , ...
                           @plotyyLegends         , ...
                           @zoom                , ...
                           @quiveroverlap       , ...
                           @quiverplot          , ...
                           @quiver3plot         , ...
                           @logicalImage        , ...
                           @imagescplot         , ...
                           @imagescplot2        , ...
                           @stairsplot          , ...
                           @polarplot           , ...
                           @roseplot            , ...
                           @compassplot         , ...
                           @stemplot            , ...
                           @stemplot2           , ...
                           @bars                , ...
                           @xAxisReversed       , ...
                           @errorBars           , ...
                           @errorBars2          , ...
                           @subplot2x2b         , ...
                           @manualAlignment     , ...
                           @subplotCustom       , ...
                           @legendsubplots      , ...
                           @bodeplots           , ...
                           @rlocusPlot          , ...
                           @mandrillImage       , ...
                           @besselImage         , ...
                           @clownImage          , ...
                           @zplanePlot1         , ...
                           @zplanePlot2         , ...
                           @freqResponsePlot    , ...
                           @axesLocation        , ...
                           @axesColors          , ...
                           @multipleAxes        , ...
                           @scatterPlotRandom   , ...
                           @scatterPlot         , ...
                           @scatter3Plot        , ...
                           @spherePlot          , ...
                           @surfPlot            , ...
                           @surfPlot2           , ...
                           @superkohle          , ...
                           @meshPlot            , ...
                           @ylabels             , ...
                           @spectro             , ... % takes pretty long to LuaLaTeX-compile
                           @mixedBarLine        , ...
                           @decayingharmonic    , ...
                           @texcolor            , ...
                           @textext             , ...
                           @texrandom           , ...
                           @latexInterpreter    , ...
                           @latexmath2          , ...
                           @parameterCurve3d    , ...
                           @parameterSurf       , ...
                           @fill3plot           , ...
                           @rectanglePlot       , ...
                           @herrorbarPlot       , ...
                           @hist3d              , ...
                           @myBoxplot           , ...
                           @areaPlot            , ...
                           @customLegend        , ...
                           @pixelLegend         , ...
                           @croppedImage        , ...
                           @pColorPlot          , ...
                           @hgTransformPlot     , ...
                           @scatterPlotMarkers  , ...
                           @multiplePatches     , ...
                           @logbaseline         , ...
                           @alphaImage          , ...
                           @annotationAll       , ...
                           @annotationSubplots  , ...
                           @annotationText      , ...
                           @annotationTextUnits , ...
                           @imageOrientation_PNG, ...
                           @imageOrientation_inline, ...
                           @texInterpreter      , ...
                           @stackedBarsWithOther, ...
                           @colorbarLabelTitle  , ...
                           @textAlignment       , ...
                           @overlappingPlots    , ...
                           @histogramPlot       , ...
                           @alphaTest           , ...
                           @removeOutsideMarker , ...
                           @colorbars           , ...
                           @colorbarManualLocationRightOut , ...
                           @colorbarManualLocationRightIn  , ...
                           @colorbarManualLocationLeftOut  , ...
                           @colorbarManualLocationLeftIn
                         };


  numFunctions = length( testfunction_handles );

  if (k<=0)
      status = testfunction_handles;
      return;  % This is used for querying numFunctions.

  elseif (k<=numFunctions)
      status = testfunction_handles{k}();
      status.function = func2str(testfunction_handles{k});

  else
      error('testfunctions:outOfBounds', ...
            'Out of bounds (number of testfunctions=%d)', numFunctions);
  end

end
% =========================================================================
function data = ACID_data()
  % Data to be used for various ACID tests
  % This ensures the tests don't rely on functions that yield
  % non-deterministic output, e.g. `rand` and `svd`.
  data = [    11    11     9
               7    13    11
              14    17    20
              11    13     9
              43    51    69
              38    46    76
              61   132   186
              75   135   180
              38    88   115
              28    36    55
              12    12    14
              18    27    30
              18    19    29
              17    15    18
              19    36    48
              32    47    10
              42    65    92
              57    66   151
              44    55    90
             114   145   257
              35    58    68
              11    12    15
              13     9    15
              10     9     7];
end
% =========================================================================
function [stat] = multiline_labels()
  stat.description = 'Test multiline labels and plot some points.';
  stat.unreliable = isOctave || isMATLAB(); %FIXME: `width` is inconsistent, see #552

  m = [0 1 1.5 1 -1];
  plot(m,'*-'); hold on;
  plot(m(end:-1:1)-0.5,'x--');

  title({'multline','title'});
  legend({sprintf('multi-line legends\ndo work 2^2=4'), ...
        sprintf('second\nplot')});
  xlabel(sprintf('one\ntwo\nthree'));
  ylabel({'one','° ∞', 'three'});

  set(gca,'YTick', []);
  set(gca,'XTickLabel',{});
end
% =========================================================================
function [stat] = plain_cos()
  stat.description = 'Plain cosine function.';

  t = linspace(0, 2*pi, 1e5);
  x = cos(t);

  % Explicitely cut the line into segments
  x([2e4, 5e4, 8e4]) = NaN;

  % Plot the cosine
  plot(t, x);
  xlim([0, 2*pi]);

  % also add some patches to test their border color reproduction
  hold on;
  h(1) = fill(pi*[1/4 1/4 1/2 1/2]   ,  [-2 1 1 -2], 'y');
  h(2) = fill(pi*[1/4 1/4 1/2 1/2]+pi, -[-2 1 1 -2], 'y');

  set(h(1), 'EdgeColor', 'none', 'FaceColor', 0.8*[1 1 1]);
  set(h(2), 'EdgeColor', 'k', 'FaceColor', 0.5*[1 1 1]);

  if isMATLAB
      uistack(h, 'bottom'); % patches below the line plot
      % this is not supported in Octave
  end

  % add some minor ticks
  set(gca, 'XMinorTick', 'on');
  set(gca, 'YTick', []);

  % Adjust the aspect ratio when in MATLAB(R) or Octave >= 3.4.
  if isOctave('<=', [3,4])
      % Octave < 3.4 doesn't have daspect unfortunately.
  else
      daspect([ 1 2 1 ])
  end
end
% =========================================================================
function [stat] = sine_with_markers ()
  % Standard example plot from MATLAB's help pages.
  stat.description = [ 'Twisted plot of the sine function. '                   ,...
         'Pay particular attention to how markers and Infs/NaNs are treated.' ];

  x = -pi:pi/10:pi;
  y = sin(x);
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
end
% =========================================================================
function [stat] = markerSizes()
  stat.description = 'Marker sizes.';

  hold on;

  h = fill([1 1 2 2],[1 2 2 1],'r');
  set(h,'LineWidth',10);

  plot([0],[0],'go','Markersize',14,'LineWidth',10)
  plot([0],[0],'bo','Markersize',14,'LineWidth',1)
end
% =========================================================================
function [stat] = markerSizes2()
  stat.description = 'Line plot with with different marker sizes.';

  hold on;
  grid on;

  n = 1:10;
  d = 10;
  s = round(linspace(6,25,10));
  e = d * ones(size(n));
  style = {'bx','rd','go','c.','m+','y*','bs','mv','k^','r<','g>','cp','bh'};
  nStyles = numel(style);

  for ii = 1:nStyles
      for jj = 1:10
        plot(n(jj), ii * e(jj),style{ii},'MarkerSize',s(jj));
      end
  end
  xlim([min(n)-1 max(n)+1]);
  ylim([0 d*(nStyles+1)]);
  set(gca,'XTick',n,'XTickLabel',s,'XTickLabelMode','manual');
end
% =========================================================================
function [stat] = sine_with_annotation ()
  stat.description = [ 'Plot of the sine function. ',...
        'Pay particular attention to how titles and annotations are treated.' ];
  stat.unreliable = isOctave || isMATLAB('>=',[8,4]) ... %FIXME: investigate
                    || isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)

  x = -pi:.1:pi; %TODO: the 0.1 step is probably a bad idea (not representable in float)
  y = sin(x);
  h = plot(x,y);
  set(gca,'XTick',-pi:pi/2:pi);

  set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'});

  xlabel('-\pi \leq \Theta \leq \pi');
  ylabel('sin(\Theta)');
  title({'Plot of sin(\Theta)','subtitle','and here''s one really long subtitle' });
  text(-pi/4,sin(-pi/4),'\leftarrow sin(-\pi\div4)',...
      'HorizontalAlignment','left');

  % Doesn't work in Octave
  %set(findobj(gca,'Type','line','Color',[0 0 1]),...
  %    'Color','red',...
  %    'LineWidth',10);

end
% =========================================================================
function [stat] = linesWithOutliers()
    stat.description = 'Lines with outliers.';
    stat.issues = [392,400];

    far = 200;
    x = [ -far, -1,   -1,  -far, -10, -0.5, 0.5, 10,  far, 1,   1,    far, 10,   0.5, -0.5, -10,  -far ];
    y = [ -10,  -0.5, 0.5, 10,   far, 1,    1,   far, 10,  0.5, -0.5, -10, -far, -1,  -1,   -far, -0.5 ];
    plot( x, y,'o-');
    axis( [-2,2,-2,2] );
end
% =========================================================================
function [stat] = peaks_contour()
  stat.description = 'Test contour plots.';
  stat.unreliable = isMATLAB('<', [8,4]) || isOctave; %R2014a and older
  % FIXME: see #604; contour() produces inconsistent output

  subplot(121)
  [C, h] = contour(peaks(20),10);
  clabel(C, h);

  % remove y-ticks
  set(gca,'YTickLabel',[]);
  set(gca,'YTick',[]);

  colormap winter;

  % Contour layers with predefined color
  subplot(122)
  contour(peaks(20), 10,'r', 'LineWidth', 5)
  set(gca,'YTickLabel',[]);
  set(gca,'YTick',[]);
end
% =========================================================================
function [stat] = contourPenny()
  stat.description = 'Contour plot of a US\$ Penny.';
  stat.unreliable  = isMATLAB('<', [8,4]);
  % FIXME: see #604; contour() produces inconsistent output (mac/windows of PeterPablo)
  stat.issues = [49 404];

  if ~exist('penny.mat','file')
      fprintf( 'penny data set not found. Skipping.\n\n' );
      stat.skip = true;
      return;
  end

  load penny;
  contour(flipud(P));
  axis square;

end
% =========================================================================
function [stat] = peaks_contourf ()
  stat.description = 'Test the contourfill plots.';
  stat.unreliable = isMATLAB('>=', [8,4]); % FIXME: inspect this
  stat.issues = 582;

  [trash, h] = contourf(peaks(20), 10);
  hold on
  plot(1:20)
  colorbar();
  legend(h, 'Contour');
  colormap hsv;
end
% =========================================================================
function [stat] = double_colorbar()
  stat.description = 'Double colorbar.';

  if isOctave()
      fprintf( 'Octave can''t handle tight axes.\n\n' );
      stat.skip = true;
      return
  end

  vspace = linspace(-40,40,20);
  speed_map = magic(20).';
  Q1_map = magic(20);

  subplot(1, 2, 1);
  contour(vspace(9:17),vspace(9:17),speed_map(9:17,9:17),20)
  colorbar
  axis tight
  axis square
  xlabel('$v_{2d}$')
  ylabel('$v_{2q}$')

  subplot(1, 2, 2)
  contour(vspace(9:17),vspace(9:17),Q1_map(9:17,9:17),20)
  colorbar
  axis tight
  axis square
  xlabel('$v_{2d}$')
  ylabel('$v_{2q}$')
end
% =========================================================================
function [stat] = randomWithLines()
  stat.description = 'Lissajous points with lines.';

  beta = 42.42;
  t = 1:150;
  X = [sin(t); cos(beta * t)].';

  X(:,1) = (X(:,1) * 90) + 75;
  plot(X(:,1),X(:,2),'o');
  hold on;
  M(1)=min(X(:,1));
  M(2)=max(X(:,1));
  mn = mean(X(:,2));
  s  = std(X(:,2));
  plot(M,[mean(X(:,2)) mean(X(:,2))],'k-');
  plot(M,mn + 1*[s s],'--');
  plot(M,mn - 2*[s s],'--');
  axis('tight');
end
% =========================================================================
function [stat] = many_random_points ()
  stat.description = 'Test the performance when drawing many points.';

  n = 1e3;
  alpha = 1024;
  beta = 1;
  gamma = 5.47;

  x = cos( (1:n) * alpha );
  y = sin( (1:n) * beta + gamma);

  plot ( x, y, '.r' );
  axis([ 0, 1, 0, 1 ])
end
% =========================================================================
function [stat] = double_axes()
  stat.description = 'Double axes';

  dyb = 0.1;   % normalized units, bottom offset
  dyt = 0.1;   % separation between subsequent axes bottoms

  x = [0; 24; 48; 72; 96;];
  y = [7.653 7.473 7.637 7.652 7.651];

  grid on
  h1 = plot(x,y,'Color','k');

  % following code is taken from `floatAxisX.m'

  % get position of axes
  allAxes = findobj(gcf,'type','axes');
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
end
% =========================================================================
function [stat] = double_axes2()
  stat.description = 'Double overlayed axes with a flip.' ;

  ah1=axes;
  ph=plot([0 1],[0 1]);

  title('Title')
  ylabel('y')
  xlabel('x')

  % add a new set of axes
  % to make a gray grid
  ah2=axes;
  % make the background transparent
  set(ah1,'color','none')
  % move these axes to the back
  set(gcf,'Children',flipud(get(gcf,'Children')))
end
% =========================================================================
function [stat] = logplot()
  stat.description = 'Test logscaled axes.';
  % This was once unreliable (and linked to #590). Mac and Linux seem fine.

  x = logspace(-1,2);
  y = exp(x);
  loglog(x, y, '-s')

  ylim([1 1e45]);
  grid on;
  if isprop(gca,'GridColor')
      set(gca, 'GridColor', 'red');
      set(gca, 'MinorGridColor', 'blue');
  else
    %TODO equivalent HG1 settings (if those exist)
  end
end
% =========================================================================
function [stat] = colorbarLogplot()
  stat.description = 'Logscaled colorbar.';
  stat.unreliable = isOctave; % FIXME: investigate (Travis differs from Linux/Mac octave)
  % https://github.com/matlab2tikz/matlab2tikz/pull/641#issuecomment-120481564

  imagesc([1 10 100]);
  try
    set(colorbar(), 'YScale', 'log');
  catch
    warning('M2TAcid:LogColorBar',...
        'Logarithmic Colorbars are not documented in MATLAB R2014b and Octave');
    stat.skip = true;
  end
end
% =========================================================================
function [stat] = legendplot()
  stat.description = 'Test inserting of legends.';
  stat.unreliable = isMATLAB || isOctave; % FIXME: investigate

%    x = -pi:pi/20:pi;
%    plot(x,cos(x),'-ro',x,sin(x),'-.b');
%    h = legend('one pretty long legend cos_x','sin_x',2);
%    set(h,'Interpreter','none');

  x = linspace(0, 2*pi, 1e5);
  plot( x, sin(x), 'b', ...
        x, cos(x), 'r' );
  xlim( [0 2*pi] )
  ylim( [-0.9 0.9] )
  title( '{tikz test}' )
  xlabel( '{x-Values}' )
  ylabel( '{y-Values}' )
  legend( 'sin(x)', 'cos(x)', 'Location','NorthOutside', ...
                              'Orientation', 'Horizontal' );
  grid on;
end
% =========================================================================
function [stat] = legendplotBoxoff ()
  stat.description = 'Test inserting of legends.';
  stat.issues = [607,609];

  x = -pi:pi/20:pi;
  l = plot(x, cos(x),'-ro',...
           x, sin(x),'-.b');
  h = legend(l(2), 'one pretty long legend sin_x (dash-dot)', 'Location', 'northeast');
  set(h, 'Interpreter', 'none');
  legend boxoff
end
% =========================================================================
function [stat] = plotyyLegends()
  stat.description = 'More legends.';

  x = 0:.1:7;
  y1 = sin(x);
  y2 = cos(x);
  [ax,h1,h2] = plotyy(x,y1,x,y2);
  legend([h1;h2],'Sine','Cosine');
end
% =========================================================================
function [stat] = zoom()
    stat.description = ['Test function \texttt{pruneOutsideBox()} ', ...
                        'and \texttt{movePointsCloser()} ', ...
                        'of \texttt{cleanfigure()}.'];
    stat.unreliable = isOctave; %FIXME: investigate
    stat.issues = [226,392,400];

    % Setup
    subplot(311)
    plot(1:10,10:-1:1,'-r*',1:15,repmat(9,1,15),'-g*',[5.5,5.5],[1,9],'-b*')
    hold on;
    stairs(1:10,'-m*');
    plot([2,8.5,8.5,2,2],[2,2,7.5,7.5,2],'--k');
    title('setup');
    legend('cross with points','no cross','cross no points','stairs','zoom area');

    % Last comes before simple zoomin due to cleanfigure
    subplot(313)
    plot(1:10,10:-1:1,'-r*',1:10,repmat(9,1,10),'-g*',[5.5,5.5],[1,9],'-b*');
    hold on;
    stairs(1:10,'-m*');
    xlim([2, 8.5]), ylim([2,7.5]);
    cleanfigure(); % FIXME: this generates many "division by zero" in Octave
    plot([2,8.5,8.5,2,2],[2,2,7.5,7.5,2],'--k');
    xlim([0, 15]), ylim([0,10]);
    title('zoom in, cleanfigure, zoom out');

    % Simple zoom in
    subplot(312)
    plot(1:10,10:-1:1,'-r*',1:10,repmat(9,1,10),'-g*',[5.5,5.5],[1,9],'-b*');
    hold on;
    stairs(1:10,'-m*');
    xlim([2, 8.5]), ylim([2,7.5]);
    title('zoom in');
end
% =========================================================================
function [stat] = bars()
  stat.description = '2x2 Subplot with different bars';
  stat.unreliable = isOctave || isMATLAB('>=', [8,4]) || ... % FIXME: investigate
                    isMATLAB('<=', [8,3]); %FIXME: #749 (Jenkins)

  % dataset grouped
  bins = 10 * (-0.5:0.1:0.5);
  numEntries = length(bins);

  alpha = [13 11 7];
  numBars = numel(alpha);
  plotData   = zeros(numEntries, numBars);
  for iBar = 1:numBars
      plotData(:,iBar) = abs(round(100*sin(alpha(iBar)*(1:numEntries))));
  end

  % dataset stacked
  data = ACID_data;
  Y = round(abs(data(2:6,1:3))/10);

  subplot(2,2,1);
  b1 = bar(bins,plotData,'grouped','BarWidth',1.5);
  set(gca,'XLim',[1.25*min(bins) 1.25*max(bins)]);

  subplot(2,2,2);
  barh(bins, plotData, 'grouped', 'BarWidth', 1.3);

  subplot(2,2,3);
  bar(Y, 'stacked');

  subplot(2,2,4);
  b2= barh(Y,'stacked','BarWidth', 0.75);

  set(b1(1),'FaceColor','m','EdgeColor','none')
  set(b2(1),'FaceColor','c','EdgeColor','none')

end
% =========================================================================
function [stat] = stemplot()
  stat.description = 'A simple stem plot.' ;

  x = 0:25;
  y = [exp(-.07*x).*cos(x);
       exp(.05*x).*cos(x)]';
  h = stem(x, y);
  legend( 'exp(-.07x)*cos(x)', 'exp(.05*x)*cos(x)', 'Location', 'NorthWest');
  set(h(1),'MarkerFaceColor','blue');
  set(h(2),'MarkerFaceColor','red','Marker','square');

  % Octave 4 has some smart behavior: it only prints a single baseline.
  % Let's mimick this behavior everywhere else.
  baselines = findall(gca, 'Type', 'line', 'Color', [0 0 0]);
  if numel(baselines) > 1
      % We only need the last line in Octave 3.8, as that is where
      % Octave 4.0 places the baseline
      delete(baselines(1:end-1));
  end
end
% =========================================================================
function [stat] = stemplot2()
  stat.description = 'Another simple stem plot.';
  stat.unreliable = isOctave('>=', 4); %FIXME: see #759, #757/#759 and #687

  x = 0:25;
  y = [exp(-.07*x).*cos(x);
       exp(.05*x).*cos(x)]';
  h = stem(x, y, 'filled');
  legend( 'exp(-.07x)*cos(x)', 'exp(.05*x)*cos(x)', 'Location', 'NorthWest');
end
% =========================================================================
function [stat] = stairsplot()
  stat.description = 'A simple stairs plot.' ;

  X      = linspace(-2*pi,2*pi,40)';
  Yconst = [zeros(10,1); 0.5*ones(20,1);-0.5*ones(10,1)];
  Y      = [sin(X), 0.2*cos(X), Yconst];
  h = stairs(Y);
  legend(h(2),'second entry')
end
% =========================================================================
function [stat] = quiverplot()
  stat.description = 'A combined quiver/contour plot of $x\exp(-x^2-y^2)$.' ;
  stat.extraOptions = {'arrowHeadSize', 2};

  [X,Y] = meshgrid(-2:.2:2);
  Z = X.*exp(-X.^2 - Y.^2);
  [DX,DY] = gradient(Z,.2,.2);
  contour(X,Y,Z);
  hold on
  quiver(X,Y,DX,DY);
  %TODO: also show a `quiver(X,Y,DX,DY,0);` to test without scaling
  colormap hsv;
  hold off
end
% =========================================================================
function [stat] = quiver3plot()
  stat.description = 'Three-dimensional quiver plot.' ;
  stat.unreliable = isMATLAB(); %FIXME: #590

  vz = 10;            % Velocity
  a = -32;            % Acceleration

  t = 0:.1:1;
  z = vz*t + 1/2*a*t.^2;

  vx = 2;
  x = vx*t;
  vy = 3;
  y = vy*t;

  u = gradient(x);
  v = gradient(y);
  w = gradient(z);
  scale = 0;
  quiver3(x,y,z,u,v,w,scale)
  view([70 18])
end
% =========================================================================
function [stat] = quiveroverlap ()
  stat.description = 'Quiver plot with avoided overlap.';
  stat.issues = [679];
  % TODO: As indicated in #679, the native quiver scaling algorithm still isn't 
  % perfect. As such, in MATLAB the arrow heads may appear extremely tiny.
  % In Octave, they look fine though. Once the scaling has been done decently,
  % this reminder can be removed.
  if isOctave
    stat.extraOptions = {'arrowHeadSize', 20};
  end

  x = [0 1];
  y = [0 0];
  u = [1 -1];
  v = [1 1];

  hold all;
  qvr1 = quiver(x,y,u,v);
  qvr2 = quiver(x,y,2*u,2*v);
  set(qvr2, 'MaxHeadSize', get(qvr1, 'MaxHeadSize')/2);
end
% =========================================================================
function [stat] = polarplot ()
  stat.description = 'A simple polar plot.' ;
  stat.extraOptions = {'showHiddenStrings',true};
  stat.unreliable = isOctave('>=', 4) || ... %FIXME: see #759, #757/#759 and #687
                    isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)
  t = 0:.01:2*pi;
  polar(t,sin(2*t).*cos(2*t),'--r')
end
% =========================================================================
function [stat] = roseplot ()
  stat.description = 'A simple rose plot.' ;
  stat.extraOptions = {'showHiddenStrings',true};
  stat.unreliable = isOctave('>=', 4) || ... %FIXME: see #759, #757/#759 and #687
                    isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)

  theta = 2*pi*sin(linspace(0,8,100));
  rose(theta);
end
% =========================================================================
function [stat] = compassplot ()
  stat.description = 'A simple compass plot.' ;
  stat.extraOptions = {'showHiddenStrings',true};
  stat.unreliable = isOctave('>=', 4) || ... %FIXME: see #759, #757/#759 and #687
                    isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)

  Z = (1:20).*exp(1i*2*pi*cos(1:20));
  compass(Z);
end
% =========================================================================
function [stat] = logicalImage()
  stat.description = 'An image plot of logical matrix values.' ;
  stat.unreliable = isOctave; %FIXME: investigate
  % different `width`, see issue #552# (comment 76918634); (Travis differs from Linux/Mac octave)

  plotData = magic(10);
  imagesc(plotData > mean(plotData(:)));
  colormap('hot');
end
% =========================================================================
function [stat] = imagescplot()
  stat.description = 'An imagesc plot of $\sin(x)\cos(y)$.';
  stat.unreliable = isOctave; %FIXME: investigate (Travis differs from Linux/Mac octave)

  pointsX = 10;
  pointsY = 20;
  x = 0:1/pointsX:1;
  y = 0:1/pointsY:1;
  z = sin(x)'*cos(y);
  imagesc(x,y,z);
end
% =========================================================================
function [stat] = imagescplot2()
  stat.description = 'A trimmed imagesc plot.';
  stat.unreliable = isOctave; %FIXME: investigate (Travis differs from Linux/Mac octave)

  a=magic(10);
  x=-5:1:4;
  y=10:19;
  imagesc(x,y,a)

  xlim([-3,2])
  ylim([12,15])

  grid on;
end
% =========================================================================
function [stat] = xAxisReversed ()
  stat.description = 'Reversed axes with legend.' ;

  n = 100;
  x = (0:1/n:1);
  y = exp(x);
  plot(x,y);
  set(gca,'XDir','reverse');
  set(gca,'YDir','reverse');
  if isOctave('<=', [3,8])
      % TODO: see whether we can unify this syntax for all environments
      % at the moment, the generic syntax doesn't seem to work for Octave
      % 3.8 (it doesn't even show a legend in gnuplut).
      legend( 'data1', 'Location', 'SouthWest' );
  else
      legend( 'Location', 'SouthWest' );
  end
end
% =========================================================================
function [stat] = subplot2x2b ()
  stat.description = 'Three aligned subplots on a $2\times 2$ subplot grid.' ;
  stat.unreliable = isOctave || isMATLAB();
  % FIXME: this test is unreliable because the automatic axis limits
  % differ on different test platforms. Reckon this by creating the figure
  % using `ACID(97)` and then manually slightly modify the window size.
  % We should not set the axis limits explicitly rather find a better way.
  % #591
  
  x = (1:5);

  subplot(2,2,1);
  y = sin(x.^3);
  plot(x,y);

  subplot(2,2,2);
  y = cos(x.^3);
  plot(x,y);

  subplot(2,2,3:4);
  y = tan(x);
  plot(x,y);
end
% =========================================================================
function [stat] = manualAlignment()
  stat.description = 'Manually aligned figures.';

  xrange = linspace(-3,4,2*1024);

  axes('Position', [0.1 0.1 0.85 0.15]);
  plot(xrange);
  ylabel('$n$');
  xlabel('$x$');

  axes('Position', [0.1 0.25 0.85 0.6]);
  plot(xrange);
  set(gca,'XTick',[]);
end
% =========================================================================
function [stat] = subplotCustom ()
  stat.description = 'Three customized aligned subplots.';
  stat.unreliable = isMATLAB(); % FIXME: #590

  x = (1:5);

  y = cos(sqrt(x));
  subplot( 'Position', [0.05 0.1 0.3 0.3] )
  plot(x,y);

  y = sin(sqrt(x));
  subplot( 'Position', [0.35 0.5 0.3 0.3] )
  plot(x,y);

  y = tan(sqrt(x));
  subplot( 'Position', [0.65 0.1 0.3 0.3] )
  plot(x,y);
end
% =========================================================================
function [stat] = errorBars()
  stat.description = 'Generic error bar plot.';

  data = ACID_data;
  plotData = 1:10;

  eH = abs(data(1:10,1))/10;
  eL = abs(data(1:10,3))/50;

  x = 1:10;
  hold all;
  errorbar(x, plotData, eL, eH, '.')
  h = errorbar(x+0.5, plotData, eL, eH);
  set(h, 'LineStyle', 'none');
  % Octave 3.8 doesn't support passing extra options to |errorbar|, but
  % it does allow for changing it after the fact
end
% =========================================================================
function [stat] = errorBars2()
  stat.description = 'Another error bar example.';
  data = ACID_data;
  y = mean( data, 2 );
  e = std( data, 1, 2 );
  errorbar( y, e, 'xr' );
end
% =========================================================================
function [stat] = legendsubplots()
  stat.description = [ 'Subplots with legends. ' , ...
    'Increase value of "length" in the code to stress-test your TeX installation.' ];
  stat.unreliable = isOctave; %FIXME: investigate
  stat.issues = 609;

  % size of upper subplot
  rows = 4;
  % number of points.  A large number here (eg 1000) will stress-test
  % matlab2tikz and your TeX installation.  Be prepared for it to run out of
  % memory
  length = 100;

  % generate some spurious data
  t = 0:(4*pi)/length:4*pi;
  x = t;
  a = t;
  y = sin(t) + 0.1*sin(134*t.^2);
  b = sin(t) + 0.1*cos(134*t.^2) + 0.05*cos(2*t);

  % plot the top figure
  subplot(rows+2,1,1:rows);

  % first line
  sigma1 = std(y);
  tracey = mean(y,1);
  plot123 = plot(x,tracey,'b-');

  hold on

  % second line
  sigma2 = std(b);
  traceb = mean(b,1);
  plot456 = plot(a,traceb,'r-');

  spec0 = ['Mean V(t)_A (\sigma \approx ' num2str(sigma1,'%0.4f') ')'];
  spec1 = ['Mean V(t)_B (\sigma \approx ' num2str(sigma2,'%0.4f') ')'];

  hold off
  %plot123(1:2)
  legend([plot123; plot456],spec0,spec1)
  legend boxoff
  xlabel('Time/s')
  ylabel('Voltage/V')
  title('Time traces');

  % now plot a differential trace
  subplot(rows+2,1,rows+1:rows+2)
  plot7 = plot(a,traceb-tracey,'k');

  legend(plot7,'\Delta V(t)')
  legend boxoff
  xlabel('Time/s')
  ylabel('\Delta V')
  title('Differential time traces');
end
% =========================================================================
function [stat] = bodeplots()
  stat.description = 'Bode plots with legends.';
  stat.unreliable = isMATLAB(); % FIXME: inconsistent axis limits and
  % tick positions; see #641 (issuecomment-106241711)

  if isempty(which('tf'))
      fprintf( 'function "tf" not found. Skipping.\n\n' );
      stat.skip = true;
      return
  end

  Rc=1;
  C=1.5e-6; %F

  % Set inductors
  L1=4e-3;
  L2=0.8e-3;

  % Resistances of inductors
  R1=4;
  R2=2;

  % Transfer functions
  % Building transfer functions
  s=tf('s');
  Zc=1/(s*C)+Rc;
  Z1=s*L1+R1;
  Z2=s*L2+R2;
  LCLd=(Z2+Zc)/(Z1+Zc);
  LCL=(s^2*C*L2+1)/(s^2*C*L1+1);

  t=logspace(3,5,1000);
  bode(LCL,t)
  hold on
  bode(LCLd,t)
  title('Voltage transfer function of a LCL filter')
  set(findall(gcf,'type','line'),'linewidth',1.5)
  grid on

  legend('Perfect LCL',' Real LCL','Location','SW')

  % Work around a peculiarity in MATLAB: when the figure is invisible,
  % the XData/YData of all plots is NaN. It gets set to the proper values when
  % the figure is actually displayed. To do so, we temporarily toggle this
  % option. This triggers the call-back (and might flicker the figure).
  isVisible = get(gcf,'visible');
  set(gcf,'visible','on')
  set(gcf,'visible',isVisible);
end
% =========================================================================
function [stat] = rlocusPlot()
  stat.description = 'rlocus plot.';
  stat.unreliable = isMATLAB(); % FIXME: radial grid is not present on all
                                % environments (see #641)

  if isempty(which('tf'))
      fprintf( 'function "tf" not found. Skipping.\n\n' );
      stat.skip = true;
      return
  end

  if isMATLAB('<', [8,4])
      % in MATLAB R2014a and below, `rlocus` plots with no background color
      % are not supported. So, force that color to white to work around
      % that bug. Newer versions don't suffer from this.
      set(gca, 'Color', 'w');
  end

  rlocus(tf([1 1],[4 3 1]))

  % Work around a peculiarity in MATLAB: when the figure is invisible,
  % the XData/YData of all plots is NaN. It gets set to the proper values when
  % the figure is actually displayed. To do so, we temporarily toggle this
  % option. This triggers the call-back (and might flicker the figure).
  isVisible = get(gcf,'visible');
  set(gcf,'visible','on')
  set(gcf,'visible',isVisible);
end
% =========================================================================
function [stat] = mandrillImage()
  stat.description = 'Picture of a mandrill.';

  if ~exist('mandrill.mat','file')
      fprintf( 'mandrill data set not found. Skipping.\n\n' );
      stat.skip = true;
      return
  end

  data = load( 'mandrill' );
  image( data.X )       % show image
  colormap( data.map )  % adapt colormap
  axis image            % pixels should be square
  axis off              % disable axis
end
% =========================================================================
function [stat] = besselImage()
  stat.description = 'Bessel function.';
  stat.unreliable = isOctave(); % FIXME (Travis differs from Linux/Mac octave)

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
end
% =========================================================================
function [stat] = clownImage()
  stat.description = 'Picture of a clown.';

  if ~exist('clown.mat','file')
      fprintf( 'clown data set not found. Skipping.\n\n' );
      stat.skip = true;
      return
  end

  data = load( 'clown' );
  imagesc( data.X )
  colormap( gray )
end
% =========================================================================
function [stat] = zplanePlot1()
  stat.description = 'Representation of the complex plane with zplane.';
  stat.unreliable = isMATLAB('<', [8,4]); % FIXME: investigate

  % check of the signal processing toolbox is installed
  verInfo = ver('signal');
  if isempty(verInfo) || isempty(verInfo.Name)
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      stat.skip = true;

      return
  end

  [z,p] = ellip(4,3,30,200/500);
  zplane(z,p);
  title('4th-Order Elliptic Lowpass Digital Filter');
end
% =========================================================================
function [stat] = zplanePlot2()
  stat.description = 'Representation of the complex plane with zplane.';
  stat.unreliable = isMATLAB; % FIXME: #604; only difference is `width`
  stat.closeall = true;

  % check of the signal processing toolbox is installed
  verInfo = ver('signal');
  if isempty(verInfo) || isempty(verInfo.Name)
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      stat.skip = true;
      return
  end

  [b,a] = ellip(4,3,30,200/500);
  Hd = dfilt.df1(b,a);
  zplane(Hd) % FIXME: This opens a new figure that doesn't get closed automatically
end
% =========================================================================
function [stat] = freqResponsePlot()
  stat.description = 'Frequency response plot.';
  stat.closeall = true;
  stat.issues = [409];
  stat.unreliable = isMATLAB(); % FIXME: investigate
  % See also: https://github.com/matlab2tikz/matlab2tikz/pull/759#issuecomment-138477207
  % and https://gist.github.com/PeterPablo/b01cbe8572a9e5989037 (R2014b)

  % check of the signal processing toolbox is installed
  verInfo = ver('signal');
  if isempty(verInfo) || isempty(verInfo.Name)
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      stat.skip = true;
      return
  end

  b  = fir1(80,0.5,kaiser(81,8));
  hd = dfilt.dffir(b);
  freqz(hd); % FIXME: This opens a new figure that doesn't get closed automatically
end
% =========================================================================
function [stat] = axesLocation()
  stat.description = 'Swapped axis locations.';
  stat.issues = 259;

  plot(cos(1:10));
  set(gca,'XAxisLocation','top');
  set(gca,'YAxisLocation','right');
end
% =========================================================================
function [stat] = axesColors()
  stat.description = 'Custom axes colors.';

  plot(sin(1:15));
  set(gca,'XColor','g','YColor','b');
%  set(gca,'XColor','b','YColor','k');
  box off;
end
% =========================================================================
function [stat] = multipleAxes()
  stat.description = 'Multiple axes.';

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
end
% =========================================================================
function [stat] = scatterPlotRandom()
  stat.description = 'Generic scatter plot.';

  n = 1:100;

  % MATLAB: Use the default area of 36 points squared. The units for the
  %         marker area is points squared.
  % octave: If s is not given, [...] a default value of 8 points is used.
  % Try obtain similar behavior and thus apply square root: sqrt(36) vs. 8
  sArea = 1000*(1+cos(n.^1.5)); % scatter size in unit points squared
  sRadius = sqrt(sArea*pi);
  if isMATLAB()
    s = sArea;    % unit: points squared
  elseif isOctave()
    s = sRadius;  % unit: points
  end

  scatter(n, n, s, n.^8);
  colormap autumn;
end
% =========================================================================
function [stat] = scatterPlot()
  stat.description = 'Scatter plot with MATLAB(R) stat.';
  if ~exist('seamount.mat','file')
      fprintf( 'seamount data set not found. Skipping.\n\n' );
      stat.skip = true;
      return
  end

  data = load( 'seamount' );
  scatter( data.x, data.y, 5, data.z, '^' );
end
% =========================================================================
function [stat] = scatterPlotMarkers()
  stat.description = 'Scatter plot with with different marker sizes and legend.';
  % FIXME: octave: Output is empty?! Potentially fixed by #669

  n = 1:10;
  d = 10;
  e = d * ones(size(n));

  % MATLAB: Use the default area of 36 points squared. The units for the
  %         marker area is points squared.
  % octave: If s is not given, [...] a default value of 8 points is used.
  % Try obtain similar behavior and thus apply square root: sqrt(36) vs. 8
  sArea = d^2 * n; % scatter size in unit points squared
  sRadius = sqrt(sArea);
  if isMATLAB()
    s = sArea;    % unit: points squared
  elseif isOctave()
    s = sRadius;  % unit: points
  end

  grid on;
  hold on;

  style = {'bx','rd','go','c.','m+','y*','bs','mv','k^','r<','g>','cp','bh'};
  names = {'bx','rd','go','c.','m plus','y star','bs','mv',...
           'k up triangle','r left triangle','g right triangle','cp','bh'};

  nStyles = numel(style);
  for ii = 1:nStyles
      curr = style{ii};
      scatter(n, ii * e, s, curr(1), curr(2));
  end
  xlim([min(n)-1 max(n)+1]);
  ylim([0 d*(nStyles+1)]);
  set(gca,'XTick',n,'XTickLabel',sArea,'XTickLabelMode','manual');
end
% =========================================================================
function [stat] = scatter3Plot()
  stat.description = 'Scatter3 plot with MATLAB(R) stat.';

  [x,y,z] = sphere(16);
  X = [x(:)*.5 x(:)*.75 x(:)];
  Y = [y(:)*.5 y(:)*.75 y(:)];
  Z = [z(:)*.5 z(:)*.75 z(:)];
  S = repmat([1 .75 .5]*10,numel(x),1);
  C = repmat([1 2 3],numel(x),1);
  scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
  view(40,35)
end
% =========================================================================
function [stat] = spherePlot()
  stat.description = 'Stretched sphere with unequal axis limits.';
  stat.issues = 560;

  sphere(30);
  title('a sphere: x^2+y^2+z^2');
  xlabel('x');
  ylabel('y');
  zlabel('z');
  set(gca,'DataAspectRatio',[1,1,.5],'xlim',[-1 2], 'zlim',[-1 0.8])
end
% =========================================================================
function [stat] = surfPlot()
  stat.description = 'Surface plot.';

  [X,Y,Z] = peaks(30);
  surf(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])
  set(gca,'View',[-37.5,36]);

  hc = colorbar('YTickLabel', ...
                {'Freezing','Cold','Cool','Neutral',...
                 'Warm','Hot','Burning','Nuclear'});
  set(get(hc,'Xlabel'),'String','Multitude');
  set(get(hc,'Ylabel'),'String','Magnitude');
  set(hc,'YTick',0:0.7:7);
  set(hc,'YTickLabel',...
         {'-0.8' '-0.6' '-0.4' '-0.2' '0.0' ...
          '0.2' '0.4' '0.6' '0.8' '0.10' '0.12'});

  set(get(hc,'Title'),...
      'String', 'k(u,v)', ...
      'FontSize', 12, ...
      'interpreter', 'tex');

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )
end
% =========================================================================
function [stat] = surfPlot2()
  stat.description = 'Another surface plot.';
  stat.unreliable = isMATLAB || isOctave; % FIXME: investigate

  z = [ ones(15, 5) zeros(15,5);
        zeros(5, 5) zeros( 5,5)];

  surf(abs(fftshift(fft2(z))) + 1);
  set(gca,'ZScale','log');

  legend( 'legendary', 'Location', 'NorthEastOutside' );
end
% =========================================================================
function [stat] = superkohle()
  stat.description = 'Superkohle plot.';
  stat.unreliable = isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)

  if ~exist('initmesh')
      fprintf( 'initmesh() not found. Skipping.\n\n' );
      stat.skip = true;
      return;
  end

  x1=0;
  x2=pi;
  y1=0;
  y2=pi;
  omegashape = [2 2 2 2             % 2 = line segment; 1 = circle segment; 4 = elipse segment
              x1 x2 x2 x1         % start point x
              x2 x2 x1 x1         % end point x
              y1 y1 y2 y2         % start point y
              y1 y2 y2 y1         % end point y
              1 1 1 1
              0 0 0 0];
  [xy,edges,tri] = initmesh(omegashape,'Hgrad',1.05);
  mmin = 1;
  while size(xy,2) < mmin
      [xy,edges,tri] = refinemesh(omegashape,xy,edges,tri);
  end
  m = size(xy,2);
  x = xy(1,:)';
  y = xy(2,:)';
  y0 = cos(x).*cos(y);

  pdesurf(xy,tri,y0(:,1));
  title('y_0');
  xlabel('x1 axis');
  ylabel('x2 axis');
  axis([0 pi 0 pi -1 1]);
  grid on;
end
% =========================================================================
function [stat] = meshPlot()
  stat.description = 'Mesh plot.';

  [X,Y,Z] = peaks(30);
  mesh(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )
end
% =========================================================================
function [stat] = ylabels()
  stat.description = 'Separate y-labels.';

  x = 0:.01:2*pi;
  H = plotyy(x,sin(x),x,3*cos(x));

  ylabel(H(1),'sin(x)');
  ylabel(H(2),'3cos(x)');

  xlabel(H(1),'time');
end
% =========================================================================
function [stat] = spectro()
  stat.description = 'Spectrogram plot';
  stat.unreliable = isMATLAB('<', [8,4]); % FIXME: investigate

  % In the original test case, this is 0:0.001:2, but that takes forever
  % for LaTeX to process.
  if isempty(which('chirp'))
      fprintf( 'chirp() not found. Skipping.\n\n' );
      stat.description = [];
      stat.skip = true;
      return
  end

  T = 0:0.005:2;
  X = chirp(T,100,1,200,'q');
  spectrogram(X,128,120,128,1E3);
  title('Quadratic Chirp');
end
% =========================================================================
function [stat] = mixedBarLine()
  stat.description = 'Mixed bar/line plot.';
  stat.unreliable = isOctave; %FIXME: investigate (octave of egon)
  % unreliable, see issue #614 (comment 92263263)

  data = ACID_data;
  x = data(:);
  hist(x,10)
  y = ylim;
  hold on;
  plot([mean(x) mean(x)], y, '-r');
  hold off;
end
% =========================================================================
function [stat] = decayingharmonic()
  stat.description = 'Decaying harmonic oscillation with \TeX{} title.';
  stat.issues = 587;

  % Based on an example from
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  A = 0.25;
  alpha = 0.007;
  beta = 0.17;
  t = 0:901;
  y = A * exp(-alpha*t) .* sin(beta*t);
  plot(t, y)
  title('{\itAe}^{-\alpha\itt}sin\beta{\itt}, \alpha<<\beta, \beta>>\alpha, \alpha<\beta, \beta>\alpha, b>a')
  xlabel('Time \musec.')
  ylabel('Amplitude |X|')
end
% =========================================================================
function [stat] = texcolor()
  stat.description = 'Multi-colored text using \TeX{} commands.';

  % Taken from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  text(.1, .5, ['\fontsize{16}black {\color{magenta}magenta '...
                '\color[rgb]{0 .5 .5}teal \color{red}red} black again'])
end
% =========================================================================
function [stat] = textext()
  stat.description = 'Formatted text and special characters using \TeX{}.';

  % Taken from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28303
  txstr(1) = { 'Each cell is a quoted string' };
  txstr(2) = { 'You can specify how the string is aligned' };
  txstr(3) = { 'You can use LaTeX symbols like \pi \chi \Xi' };
  txstr(4) = { '\bfOr use bold \rm\itor italic font\rm' };
  txstr(5) = { '\fontname{courier}Or even change fonts' };
  txstr(5) = { 'and use umlauts like äöüßÄÖÜ and accents éèêŐőŰűç' };
  plot( 0:6, sin(0:6) )
  text( 5.75, sin(2.5), txstr, 'HorizontalAlignment', 'right' )
end
% =========================================================================
function [stat] = texrandom()
  stat.description = 'Random TeX symbols';

  try
      rng(42); %fix seed
      %TODO: fully test tex conversion instead of a random subsample!
  catch
      rand('seed', 42); %#ok (this is deprecated in MATLAB)
  end

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

  switch getEnvironment
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
end
% =========================================================================
function [stat] = latexInterpreter()
    stat.description = '\LaTeX{} interpreter test (display math not working)';
    stat.issues = 448;
    stat.unreliable = isMATLAB('<=', [8,3]); %FIXME: broken since decd496 (mac vs linux)

    plot(magic(3),'-x');

    % Adapted from an example at
    % http://www.mathworks.com/help/techdoc/ref/text_props.html#Interpreter
    text(1.5, 2.0, ...
        '$$\int_0^x\!\int_{\Omega} \mathrm{d}F(u,v) \mathrm{d}\omega$$', ...
        'Interpreter', 'latex', ...
        'FontSize', 26);

    title(['display math old: $$\alpha$$ and $$\sum_\alpha^\Omega$$; ', ...
    'inline math: $\alpha$ and $\sum_\alpha^\Omega$'],'Interpreter','latex');
end
% =========================================================================
function [stat] = latexmath2()
  stat.description = 'Some nice-looking formulas typeset using the \LaTeX{} interpreter.';
  stat.issues = 637;

  % Adapted from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#bq558_t
  set(gcf, 'color', 'white')
  set(gcf, 'units', 'inches')
  set(gcf, 'position', [2 2 4 6.5])
  set(gca, 'visible', 'off')

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
  h(3) = text( 'units', 'inches', 'position', [.2 3],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        [ '$$L\{f(t)\}  \equiv  F(s) = \int_0^\infty\!\!{e^{-st}'      ...
          'f(t)dt}$$'                                                  ]);
  h(4) = text( 'units', 'inches', 'position', [.2 2],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        '$$e = \sum_{k=0}^\infty {\frac{1}{k!}} $$'                   );
  h(5) = text( 'units', 'inches', 'position', [.2 1],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        [ '$$m \ddot y = -m g + C_D \cdot {\frac{1}{2}}'                 ...
          '\rho {\dot y}^2 \cdot A$$'                                  ]);
  h(6) = text( 'units', 'inches', 'position', [.2 0],                    ...
        'fontsize', 14, 'interpreter', 'latex', 'string',              ...
        '$$\int_{0}^{\infty} x^2 e^{-x^2} dx = \frac{\sqrt{\pi}}{4}$$' );
end
% =========================================================================
function [stat] = parameterCurve3d()
  stat.description = 'Parameter curve in 3D with text boxes in-/outside axis.';
  stat.issues = [378, 790] ;
  t = linspace(0, 20*pi, 1e5);
  plot3(t, sin(t), 50 * cos(t));
  text(0.5, 0.5, 10, 'text inside axis limits');
  text(5.0, 1.5, 50, 'text outside axis (will be removed by cleanfigure())');
end
% =========================================================================
function [stat] = parameterSurf()
  stat.description = 'Parameter and surface plot.';
  stat.unreliable = isMATLAB('<', [8,4]); % FIXME: investigate

  if ~exist('TriScatteredInterp')
      fprintf( 'TriScatteredInterp() not found. Skipping.\n\n' );
      stat.skip = true;
      return;
  end

  t = (1:100).';
  t1 = cos(5.75352*t).^2;
  t2 = abs(sin(t));

  x = t1*4 - 2;
  y = t2*4 - 2;
  z = x.*exp(-x.^2 - y.^2);

  %TODO: do we really need this TriScatteredInterp?
  % It will be removed from MATLAB

  % Construct the interpolant
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
end
% =========================================================================
function [stat] = fill3plot()
  stat.description = 'fill3 plot.';

  if ~exist('fill3','builtin')
      fprintf( 'fill3() not found. Skipping.\n\n' );
      stat.skip = true;
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
  box on;
end
% =========================================================================
function [stat] = rectanglePlot()
  stat.unreliable = isMATLAB('<=', [8,3]); %FIXME: #749 (Jenkins)
  stat.description = 'Rectangle handle.';

  rectangle('Position', [0.59,0.35,3.75,1.37],...
            'Curvature', [0.8,0.4],...
            'LineWidth', 2, ...
            'LineStyle', '--' ...
           );
  daspect([1,1,1]);
end
% =========================================================================
function [stat] = herrorbarPlot()
  stat.description = 'herrorbar plot.';
  % FIXME: octave is missing the legend 

  hold on;
  X = 1:10;
  Y = 1:10;
  err = repmat(0.2, 1, 10);
  h1 = errorbar(X, Y, err+X/30, 'r');
  h_vec = herrorbar(X, Y, err);
  for h=h_vec
      set(h, 'color', [1 0 0]);
  end
  h2 = errorbar(X, Y+1, err, 'g');
  h_vec = herrorbar(X, Y+1, err+Y/40);
  for h=h_vec
      set(h, 'color', [0 1 0]);
  end
  legend([h1 h2], {'test1', 'test2'})
end
% =========================================================================
function [stat] = hist3d()
  stat.description = '3D histogram plot.';

  if ~exist('hist3','builtin') && isempty(which('hist3'))
      fprintf( 'Statistics toolbox not found. Skipping.\n\n' );
      stat.skip = true;
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
end
% =========================================================================
function [stat] = myBoxplot()
  stat.description = 'Boxplot.';
  stat.unreliable = isMATLAB('<', [8,4]); % R2014a; #552 #414

  if ~exist('boxplot','builtin') && isempty(which('boxplot'))
      fprintf( 'Statistics toolbox not found. Skipping.\n\n' );
      stat.skip = true;
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
end
% =========================================================================
function [stat] = areaPlot()
  stat.description = 'Area plot.';

  M = magic(5);
  M = M(1:3,2:4);
  h = area(1:3, M);
  legend(h([1,3]),'foo', 'foobar');
end
% =========================================================================
function [stat] = customLegend()
  stat.description = 'Custom legend.';
  stat.unreliable = isMATLAB('<', [8,4]) || isOctave; %FIXME: investigate (Travis differs from Linux/Mac octave)

  x = -pi:pi/10:pi;
  y = tan(sin(x)) - sin(tan(x));
  plot(x,y,'--rs');

  lh=legend('y',4);
  set(lh,'color','g')
  set(lh,'edgecolor','r')
  set(lh, 'position',[.5 .6 .1 .05])
end
% =========================================================================
function [stat] = pixelLegend()
  stat.description = 'Legend with pixel position.';

  x = linspace(0,1);
  plot(x, [x;x.^2]);
  set(gca, 'units', 'pixels')
  lh=legend('1', '2');
  set(lh, 'units','pixels','position', [100 200 65 42])
end
% =========================================================================
function [stat] = croppedImage()
  stat.description = 'Custom legend.';

  if ~exist('flujet.mat','file')
      fprintf( 'flujet data set not found. Skipping.\n\n' );
      stat.skip = true;
      return;
  end

  load('flujet','X','map');
  image(X)
  colormap(map)
  %axis off
  axis image
  xlim([50 200])
  ylim([50 200])
  % colorbar at top
  colorbar('north');
  set(gca,'Units','normalized');
end
% =========================================================================
function [stat] = pColorPlot()
  stat.description = 'pcolor() plot.';

  ylim([-1 1]); xlim([-1 1]); hold on; % prevent error on octave
  n = 6;
  r = (0:n)'/n;
  theta = pi*(-n:n)/n;
  X = r*cos(theta);
  Y = r*sin(theta);
  C = r*cos(2*theta);
  pcolor(X,Y,C)
  axis equal tight
end
% =========================================================================
function [stat] = multiplePatches()
  stat.description = 'Multiple patches.';

  xdata = [2     2     0     2     5;
           2     8     2     4     5;
           8     8     2     4     8];
  ydata = [4     4     4     2     0;
           8     4     6     2     2;
           4     0     4     0     0];
  cdata = [15     0     4     6    10;
           1     2     5     7     9;
           2     3     0     8     3];
  p = patch(xdata,ydata,cdata,'Marker','o',...
            'MarkerFaceColor','flat',...
            'FaceColor','none');
end
% =========================================================================
function [stat] = hgTransformPlot()
  stat.description = 'hgtransform() plot.';

  if isOctave
      % Octave (3.8.0) has no implementation of `hgtransform`
      stat.skip = true;
      return;
  end
  % Check out
  % http://www.mathworks.de/de/help/matlab/ref/hgtransform.html.

  ax = axes('XLim',[-2 1],'YLim',[-2 1],'ZLim',[-1 1]);
  view(3);
  grid on;
  axis equal;

  [x,y,z] = cylinder([.2 0]);
  h(1) = surface(x,y,z,'FaceColor','red');
  h(2) = surface(x,y,-z,'FaceColor','green');
  h(3) = surface(z,x,y,'FaceColor','blue');
  h(4) = surface(-z,x,y,'FaceColor','cyan');
  h(5) = surface(y,z,x,'FaceColor','magenta');
  h(6) = surface(y,-z,x,'FaceColor','yellow');

  t1 = hgtransform('Parent',ax);
  t2 = hgtransform('Parent',ax);

  set(h,'Parent',t1);
  h2 = copyobj(h,t2);

  Txy = makehgtform('translate',[-1.5 -1.5 0]);
  set(t2,'Matrix',Txy)
  drawnow
end
% =========================================================================
function [stat] = logbaseline()
  stat.description = 'Logplot with modified baseline.';

  bar([0 1 2], [1 1e-2 1e-5],'basevalue', 1e-6);
  set(gca,'YScale','log');
end
% =========================================================================
function [stat] = alphaImage()
  stat.description = 'Images with alpha channel.';
  stat.unreliable = isOctave; %FIXME: investigate

  subplot(2,1,1);
  title('Scaled Alpha Data');
  N = 20;
  h_imsc = imagesc(repmat(1:N, N, 1));
  mask = zeros(N);
  mask(N/4:3*N/4, N/4:3*N/4) = 1;
  set(h_imsc, 'AlphaData', double(~mask));
  set(h_imsc, 'AlphaDataMapping', 'scaled');
  set(gca, 'ALim', [-1,1]);
  title('');

  subplot(2,1,2);
  title('Integer Alpha Data');
  N = 2;
  line([0 N]+0.5, [0 N]+0.5, 'LineWidth', 2, 'Color','k');
  line([0 N]+0.5, [N 0]+0.5, 'LineWidth', 2, 'Color','k');
  hold on
  imagesc([0,1;2,3],'AlphaData',uint8([64,128;192,256]))
end
% =========================================================================
function stat = annotationAll()
  stat.description = 'All possible annotations with edited properties';
  stat.unreliable = isMATLAB('<', [8,4]); % TODO: R2014a and older: #604

  if isempty(which('annotation'))
      fprintf( 'annotation() not found. Skipping.\n\n' );
      stat.skip = true;
      return;
  end

  % Create plot
  X1 = -5:0.1:5;
  plot(X1,log(X1.^2+1));

  % Create line
  annotation('line',[0.21 0.26], [0.63 0.76], 'Color',[0.47 0.3 0.44],...
             'LineWidth',4, 'LineStyle',':');

  % Create arrow
  if isOctave('>=', 4)
      headStyle = 'vback3'; %Octave does not support cback2 yet (2015-09)
  else
      headStyle = 'cback2';
  end

  annotation('arrow',[0.25 0.22], [0.96 0.05], 'LineStyle','-.',...
             'HeadStyle', headStyle);

  % Create textarrow
  annotation('textarrow',[0.46 0.35], [0.41 0.50],...
             'Color',[0.92 0.69 0.12], 'TextBackgroundColor',[0.92 0.83 0.83],...
             'String',{'something'}, 'LineWidth',2, 'FontWeight','bold',...
             'FontSize',20, 'FontName','Helvetica');

  % Create doublearrow
  annotation('doublearrow',[0.33 0.7], [0.56 0.55]);

  % Create textbox
  annotation('textbox', [0.41 0.69 0.17 0.10], 'String',{'something'},...
             'FitBoxToText','off');

  % Create ellipse
  if isOctave(4)
      colorSpec = 'EdgeColor';
  else
      colorSpec = 'Color';
  end
  annotation('ellipse',  [0.70 0.44 0.15 0.51], ...
            colorSpec, [0.63 0.07 0.18],...
            'LineWidth', 3, 'FaceColor',[0.80 0.87 0.96]);

  % Create rectangle
  annotation('rectangle', [0.3 0.26 0.53 0.58], 'LineWidth',8,...
             'LineStyle',':');
end
% =========================================================================
function [stat] = annotationSubplots()
  stat.description = 'Annotated and unaligned subplots';

  if isempty(which('annotation'))
    fprintf( 'annotation() not found. Skipping.\n\n' );
    stat.skip = true;
    return;
  end

  X1 = 0:0.01:1;
  Y1 = X1.^2;
  Y2 = Y1.^2;
  Y3 = X1.^(1/4);

  set(gcf, 'Position', [100 100 1500 600]);

  axes1 = axes('Parent',gcf, 'Position',[0.07 0.4015 0.2488 0.5146]);
  box(axes1,'on');
  hold(axes1,'all');

  title('f(x)=x^2');

  plot(X1,Y1,'Parent',axes1, 'DisplayName','(0:0.05:1).^2 vs 0:0.05:1');

  axes2 = axes('Parent',gcf, 'OuterPosition',[0.4062 0 0.2765 0.6314]);
  box(axes2,'on');
  hold(axes2,'all');

  plot(X1,Y2,'Parent',axes2,'DisplayName','(0:0.05:1).^4 vs 0:0.05:1');

  axes3 = axes('Parent',gcf, 'Position',[0.7421 0.3185 0.21 0.5480]);
  box(axes3,'on');
  hold(axes3,'all');

  plot(X1,Y3,'Parent',axes3,'DisplayName','(0:0.05:1).^(1/4) vs 0:0.05:1');

  annotation(gcf,'textbox',[0.3667 0.5521 0.0124 0.0393], ...
    'String',{'f^2'}, 'FitBoxToText','off');

  annotation(gcf,'arrow',[0.3263 0.4281], [0.6606 0.3519]);

  annotation(gcf,'textarrow',[0.6766 0.7229], [0.3108 0.6333],...
    'TextEdgeColor','none', 'HorizontalAlignment','center', ...
    'String',{'invert'});
end
% =========================================================================
function [stat] = annotationText()
  stat.description = 'Variations of textual annotations';
  stat.unreliable = isMATLAB('<', [8,4]); % FIXME: investigate

  if ~exist('annotation')
    fprintf( 'annotation() not found. Skipping.\n\n' );
    stat.skip = true;
    return;
  end

  X1 = -5:0.1:5;
  Y1 = log(X1.^2+1);

  % Resize figure to fit all text inside
  set(gcf,'Position', [100 100 1000 700]);

  % Otherwise the axes is plotted wrongly
  drawnow();

  % Create axes
  axes1 = axes('Parent',gcf);
  hold(axes1,'all');

  % Create plot
  plot(X1,Y1);

  % Create text
  text('Parent',axes1,'String',' \leftarrow some point on the curve',...
    'Position',[-2.01811125485123 1.5988219895288 7.105427357601e-15]);

  % Create text
  text('Parent',axes1,'String','another point \rightarrow',...
    'Position',[1 0.693147180559945 0],...
    'HorizontalAlignment','right');

  % Create textbox
  annotation(gcf,'textbox',...
    [0.305611222444885 0.292803442287824 0.122244488977956 0.0942562592047128],...
    'String',{'This boxes size','should adjust to','the text size'});

  % Create textbox
  annotation(gcf,'textbox',...
    [0.71643086172344 0.195876288659794 0.10020240480962 0.209240982129118],...
    'String',{'Multiple Lines due to fixed width'},...
    'FitBoxToText','off');

  % Create textbox
  annotation(gcf,'textbox',...
    [0.729456913827655 0.608247422680412 0.0851723446893787 0.104257797902974],...
    'String',{'Overlapping','and italic'},...
    'FontAngle','italic',...
    'FitBoxToText','off',...
    'BackgroundColor',[0.756862759590149 0.866666674613953 0.776470601558685]);

  % Create textbox
  annotation(gcf,'textbox',...
    [0.420000437011093 0.680170575692964 0.155149863590109 0.192171438527209],...
    'VerticalAlignment','middle',...
    'String',{'Text with a','thick and','dotted','border'},...
    'HorizontalAlignment','center',...
    'FitBoxToText','off',...
    'LineStyle',':',...
    'LineWidth',4);

  % Create textarrow
  annotation(gcf,'textarrow',[0.21943887775551 0.2625250501002],...
    [0.371002132196162 0.235640648011782],'TextEdgeColor','none',...
    'TextBackgroundColor',[0.678431391716003 0.921568632125854 1],...
    'TextRotation',30,...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'String',{'Rotated Text'});

  % Create textarrow
  annotation(gcf,'textarrow',[0.238436873747493 0.309619238476953],...
    [0.604315828808828 0.524300441826215],'TextEdgeColor','none',...
    'TextColor',[1 1 1],...
    'TextBackgroundColor',[0 0 1],...
    'TextRotation',30,...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'String',{'Rotated Text 2'},...
    'HeadStyle','diamond',...
    'Color',[1 0 0]);
end
% =========================================================================
function [stat] = annotationTextUnits()
  stat.description = 'Text with changed Units';
  stat.unreliable = isMATLAB('<', [8,4]); % FIXME: investigate

  if ~exist('annotation')
    fprintf( 'annotation() not found. Skipping.\n\n' );
    stat.skip = true;
    return;
  end

  X1 = -5:0.1:5;
  Y1 = log(X1.^2+1);

  % Resize figure to fit all text inside
  set(gcf,'Units', 'inches');
  set(gcf,'Position', [1.03125, 1.03125, 10.416666666666666, 7.291666666666666 ]);

  % Otherwise the axes is plotted wrongly
  drawnow();

  % Create axes
  axes1 = axes('Parent',gcf,'Units','centimeters',...
    'Position',[3.4369697916666664, 2.035743645833333 20.489627604166664 15.083009739583332]);
  hold(axes1,'all');

  % Create plot
  plot(X1,Y1);

  % Create text
  text('Parent',axes1,'Units','normalized',...
    'String',' \leftarrow some point on the curve',...
    'Position',[0.295865633074935 0.457364341085271 0]);

  % Create text
  text('Parent',axes1,'Units','centimeters',...
    'String','another point \rightarrow',...
    'Position',[12.2673383333333 2.98751989583333 0],...
    'HorizontalAlignment','right');

  % Create textbox
  annotation(gcf,'textbox',...
    [0.305611222444885 0.292803442287824 0.122244488977956 0.0942562592047128],...
    'String',{'This boxes size','should adjust to','the text size'},...
    'FitBoxToText','off',...
    'Units','pixels');


  % Create textarrow
  annotation(gcf,'textarrow',[0.21943887775551 0.2625250501002],...
    [0.371002132196162 0.235640648011782],'TextEdgeColor','none',...
    'TextBackgroundColor',[0.678431391716003 0.921568632125854 1],...
    'TextRotation',30,...
    'HorizontalAlignment','center',...
    'String',{'Rotated Text'},...
    'Units','points');

  % Create textarrow
  annotation(gcf,'textarrow',[0.238436873747493 0.309619238476953],...
    [0.604315828808828 0.524300441826215],'TextEdgeColor','none',...
    'TextColor',[1 1 1],...
    'TextBackgroundColor',[0 0 1],...
    'TextRotation',30,...
    'HorizontalAlignment','center',...
    'String',{'Rotated Text 2'},...
    'HeadStyle','diamond',...
    'Color',[1 0 0]);

  % Create textbox
  if ~isOctave(4)
      annotation(gcf,'textbox',...
        [0.71643086172344 0.195876288659794 0.10020240480962 0.209240982129118],...
        'String',{'Multiple Lines due to fixed width'},...
        'FitBoxToText','off',...
        'Units','characters');
  else
      % Octave 4 doesn't seem to like the "'Units','Characters'" in there
      % so just remove the object altogether.
      % This is strange, since it is documented: https://www.gnu.org/software/octave/doc/interpreter/Plot-Annotations.html#Plot-Annotations
  end

  % Create textbox
  annotation(gcf,'textbox',...
    [0.420000437011093 0.680170575692964 0.155149863590109 0.192171438527209],...
    'VerticalAlignment','middle',...
    'String',{'Text with a','thick and','dotted','border'},...
    'HorizontalAlignment','center',...
    'FitBoxToText','off',...
    'LineStyle',':',...
    'LineWidth',4);

  % Create textbox
  annotation(gcf,'textbox',...
    [0.729456913827655 0.608247422680412 0.0851723446893787 0.104257797902974],...
    'String',{'Overlapping','and italic'},...
    'FontAngle','italic',...
    'FitBoxToText','off',...
    'BackgroundColor',[0.756862759590149 0.866666674613953 0.776470601558685]);
end
% =========================================================================
function [stat] = imageOrientation_inline()
% Run test and save pictures as inline TikZ code
    [stat] = imageOrientation(false);
    stat.unreliable = isOctave; % FIXME
end
function [stat] = imageOrientation_PNG()
% Run test and save pictures as external PNGs
    [stat] = imageOrientation(true);
    stat.unreliable = isOctave; % FIXME
end
function [stat] = imageOrientation(imagesAsPng)
% Parameter 'imagesAsPng' is boolean
    stat.description = ['Systematic test of different axis', ...
      ' orientations and visibility (imagesAsPng = ', ...
      num2str(imagesAsPng), ').'];
    stat.extraOptions = {'imagesAsPng', imagesAsPng};

    data = magic(3);
    data = [[0,0,9]; data]; % ensure non-quadratic matrix

    subplot(3,2,1);
    imagesc(data); colormap(hot);
    set(gca,'XDir','normal');
    xlabel('XDir normal');
    set(gca,'YDir','normal');
    ylabel('YDir normal');

    subplot(3,2,2);
    imagesc(data); colormap(hot);
    set(gca,'XDir','reverse');
    xlabel('XDir reverse');
    set(gca,'YDir','normal');
    ylabel('YDir normal');

    subplot(3,2,3);
    imagesc(data); colormap(hot);
    set(gca,'XDir','normal');
    xlabel('XDir normal');
    set(gca,'YDir','reverse');
    ylabel('YDir reverse');

    subplot(3,2,4);
    imagesc(data); colormap(hot);
    set(gca,'XDir','reverse');
    xlabel('XDir reverse');
    set(gca,'YDir','reverse');
    ylabel('YDir reverse');

    subplot(3,2,5);
    imagesc(data); colormap(hot);
    set(gca,'XDir','normal');
    xlabel('XDir normal');
    set(gca,'YDir','reverse');
    ylabel('YDir reverse');
    axis off;
    title('like above, but axis off');

    subplot(3,2,6);
    imagesc(data); colormap(hot);
    set(gca,'XDir','reverse');
    xlabel('XDir reverse');
    set(gca,'YDir','reverse');
    ylabel('YDir reverse');
    axis off;
    title('like above, but axis off');
end
% =========================================================================
function [stat] = texInterpreter()
    stat.description = 'Combinations of tex commands';
    axes
    text(0.1,0.9, {'\bfBold text before \alpha and also afterwards.', 'Even the next line is bold \itand a bit italic.'});
    text(0.1,0.75, {'Changing \bfthe\fontname{Courier} font or \color[rgb]{0,0.75,0}color doesn''t', 'change the style. Resetting \rmthe style', 'doesn''t change the font or color.'});
    text(0.1,0.6, 'Styles can be {\bflimited} using \{ and \}.');
    text(0.1,0.45, {'But what happens to the output if there is', '{\bfuse an \alpha inside} the limitted style.'});
    text(0.1,0.3, 'Or if the\fontsize{14} size\color{red} and color are \fontsize{10}changed at different\color{blue} points.');
    text(0.1,0.15, {'Also_{some \bf subscripts} and^{superscripts} are possible.', 'Without brackets, it l^o_oks like t_his.' });
end
% =========================================================================
function [stat] = stackedBarsWithOther()
  stat.description = 'stacked bar plots and other plots';
  stat.issues = [442,648];
  stat.unreliable = isOctave || isMATLAB(); % FIXME: #614
  % details: https://github.com/matlab2tikz/matlab2tikz/pull/614#issuecomment-91844506

  % dataset stacked
  data = ACID_data;
  Y = round(abs(data(7:-1:3,1:3))/10);
  n = size(Y,1);
  xVals = (1:n).';
  yVals = min((xVals).^2, sum(Y,2));

  subplot(2,1,1); hold on;
  bar(Y,'stacked');
  plot(xVals, yVals, 'Color', 'r', 'LineWidth', 2);
  legend('show');

  subplot(2,1,2); hold on;
  b2 = barh(Y,'stacked','BarWidth', 0.75);
  plot(yVals, xVals, 'Color', 'b', 'LineWidth', 2);

  set(b2(1),'FaceColor','c','EdgeColor','none')
end
% =========================================================================
function [stat] = colorbarLabelTitle()
    stat.description = 'colorbar with label and title';
    stat.unreliable = isOctave; %FIXME: investigate
    stat.issues = 429;

    % R2014b handles colorbars smart:  `XLabel` and `YLabel` merged into `Label`
    % Use colormap 'jet' to create comparable output with MATLAB R2014b
    % * Check horizontal/vertical colorbar (subplots)
    % * Check if 'direction' is respected
    % * Check if multiline label and title works
    % * Check if latex interpreter works in label and title

    subplot(1,2,1)
    imagesc(magic(3));
    hc = colorbar;
    colormap('jet');
    title(hc,'title $\beta$','Interpreter','latex');
    ylabel(hc,'label $a^2$','Interpreter','latex');
    set(hc,'YDir','reverse');

    subplot(1,2,2)
    label_multiline = {'first','second','third'};
    title_multiline = {'title 1','title 2'};
    imagesc(magic(3));
    hc = colorbar('southoutside');
    colormap('jet');
    title(hc,title_multiline);
    xlabel(hc,label_multiline);
end
% =========================================================================
function [stat] = textAlignment()
    stat.description = 'alignment of text boxes and position relative to axis';
    stat.issues = 378;
    stat.unreliable = isOctave; %FIXME: investigate

    plot([0.0 2.0], [1.0 1.0],'k'); hold on;
    plot([0.0 2.0], [0.5 0.5],'k');
    plot([0.0 2.0], [1.5 1.5],'k');
    plot([1.0 1.0], [0.0 2.0],'k');
    plot([1.5 1.5], [0.0 2.0],'k');
    plot([0.5 0.5], [0.0 2.0],'k');

    text(1.0,1.0,'h=c, v=m', ...
        'HorizontalAlignment','center','VerticalAlignment','middle');
    text(1.5,1.0,'h=l, v=m', ...
        'HorizontalAlignment','left','VerticalAlignment','middle');
    text(0.5,1.0,'h=r, v=m', ...
        'HorizontalAlignment','right','VerticalAlignment','middle');

    text(0.5,1.5,'h=r, v=b', ...
        'HorizontalAlignment','right','VerticalAlignment','bottom');
    text(1.0,1.5,'h=c, v=b', ...
        'HorizontalAlignment','center','VerticalAlignment','bottom');
    text(1.5,1.5,'h=l, v=b', ...
        'HorizontalAlignment','left','VerticalAlignment','bottom');

    text(0.5,0.5,'h=r, v=t', ...
        'HorizontalAlignment','right','VerticalAlignment','top');
    text(1.0,0.5,'h=c, v=t', ...
        'HorizontalAlignment','center','VerticalAlignment','top');
    h_t = text(1.5,0.5,{'h=l, v=t','multiline'}, ...
        'HorizontalAlignment','left','VerticalAlignment','top');
    set(h_t,'BackgroundColor','g');

    text(0.5,2.1, 'text outside axis (will be removed by cleanfigure())');
    text(1.8,0.7, {'text overlapping', 'axis limits'});
    text(-0.2,0.7, {'text overlapping', 'axis limits'});
    text(0.9,0.0, {'text overlapping', 'axis limits'});
    h_t = text(0.9,2.0, {'text overlapping', 'axis limits'});

    % Set different units to test if they are properly handled
    set(h_t, 'Units', 'centimeters');
end
% =========================================================================
function [stat] = overlappingPlots()
    stat.description = 'Overlapping plots with zoomed data and varying background.';
    stat.unreliable = isMATLAB();
    % FIXME: this test is unreliable because the automatic axis limits of `ax2`
    % differ on different test platforms. Reckon this by creating the figure
    % using `ACID(97)` and then manually slightly modify the window size.
    % We should not set the axis limits explicitly rather find a better way.
    % Workaround: Slightly adapt width and height of `ax2`.
    % #591, #641 (issuecomment-106241711)
    stat.issues = 6;

    % create pseudo random data and convert it from matrix to vector
    l = 256;
    l_zoom = 64;
    wave = sin(linspace(1,10*2*pi,l));

    % plot data
    ax1 = axes();
    plot(ax1, wave);

    % overlapping plots with zoomed data
    ax3 = axes('Position', [0.2, 0.6, 0.3, 0.4]);
    ax4 = axes('Position', [0.7, 0.2, 0.2, 0.4]);
    ax2 = axes('Position', [0.25, 0.3, 0.3, 0.4]);

    plot(ax2, 1:l_zoom, wave(1:l_zoom), 'r');
    plot(ax3, 1:l_zoom, wave(1:l_zoom), 'k');
    plot(ax4, 1:l_zoom, wave(1:l_zoom), 'k');

    % set x-axis limits of main plot and first subplot
    xlim(ax1, [1,l]);
    xlim(ax3, [1,l_zoom]);

    % axis background color: ax2 = default, ax3 = green, ax4 = transparent
    set(ax3, 'Color', 'green');
    set(ax4, 'Color', 'none');
end
% =========================================================================
function [stat] = histogramPlot()
  if isOctave || isMATLAB('<', [8,4])
      % histogram() was introduced in Matlab R2014b.
      % TODO: later replace by 'isHG2()'
      fprintf('histogram() not found. Skipping.\n' );
      stat.skip = true;
      return;
  end
  stat.description = 'overlapping histogram() plots and custom size bins';
  stat.issues      = 525;

  x     = [-0.2, -0.484, 0.74, 0.632, -1.344, 0.921, -0.598, -0.727,...
           -0.708, 1.045, 0.37, -1.155, -0.807, 1.027, 0.053, 0.863,...
           1.131, 0.134, -0.017, -0.316];
  y     = x.^2;
  edges = [-2 -1:0.25:3];
  histogram(x,edges);
  hold on
  h = histogram(y);
  set(h, 'orientation', 'horizontal');
end
% =========================================================================
function [stat] = alphaTest()
  stat.description = 'overlapping objects with transparency and other properties';
  stat.issues      = 593;

  contourf(peaks(5)); hold on;              % background

  % rectangular patch with different properties
  h = fill([2 2 4 4], [2 3 3 2], 'r');
  set(h, 'FaceColor', 'r');
  set(h, 'FaceAlpha', 0.2);
  set(h, 'EdgeColor', 'g');
  set(h, 'EdgeAlpha', 0.4);
  set(h, 'LineStyle', ':');
  set(h, 'LineWidth', 4);
  set(h, 'Marker', 'x');
  set(h, 'MarkerSize', 16);
  set(h, 'MarkerEdgeColor', [1 0.5 0]);
  set(h, 'MarkerFaceColor', [1 0 0]);       % has no visual effect

  % line with different properties
  h = line([3 3.5], [1.5 3.5]);
  set(h, 'Color', [1 1 1]);
  if isMATLAB('>=', [8,4])
      % TODO: later replace by 'isHG2()'
      fprintf('Note: RGBA (with alpha channel) only in HG2.\n' );
      set(h, 'Color', [1 1 1 0.3]);
  end
  set(h, 'LineStyle', ':');
  set(h, 'LineWidth', 6);
  set(h, 'Marker', 'o');
  set(h, 'MarkerSize', 14);
  set(h, 'MarkerEdgeColor', [1 1 0]);
  set(h, 'MarkerFaceColor', [1 0 0]);
end
% =========================================================================
function [stat] = removeOutsideMarker()
  stat.description = 'remove markers outside of the box';
  stat.issues      = 788;

  % Create the data and plot it
  xdata          = -1 : 0.5 : 1.5;
  ydata_marker   = 1.5 * ones(size(xdata));
  ydata_line     = 1   * ones(size(xdata));  
  ydata_combined = 0.5 * ones(size(xdata));
  plot(xdata, ydata_marker, '*', ...
       xdata, ydata_line, '-', ...
       xdata, ydata_combined, '*-');
  title('Markers at -1 and 0.5 should be removed, the line shortened'); 

  % Change the limits, so one marker is outside the box
  ylim([0, 2]);
  xlim([0, 2]);
  
  % Remove it
  cleanfigure;
  
  % Change the limits back to check result
  xlim([-1, 2]);
end
% =========================================================================
function [stat] = colorbars()
  stat.description = 'Manual positioning of colorbars';
  stat.issues      = [933 937];
  stat.unreliable  = isOctave(); %FIXME: positions differ between Octave 3.2 and 4.0.

  shift = [0.2 0.8 0.2 0.8];
  axLoc = {'in','out','out','in'};

  for iAx = 1:4
    hAx(iAx) = subplot(2,2,iAx);
    axPos    = get(hAx(iAx), 'Position');
    cbPos    = [axPos(1)+shift(iAx)*axPos(3), axPos(2), 0.02, 0.2]; 

    hCb(iAx) = colorbar('Position', cbPos);
    try
        % only in HG2
        set(hCb(iAx), 'AxisLocation', axLoc{iAx});
    end
    title(['AxisLocation = ' axLoc{iAx}]);
    grid('on');
  end
end
% =========================================================================
function [stat] = colorbarManualLocationRightOut()
  stat.description = 'Manual positioning of colorbars - Right Out';
  stat.issues      = [933 937];

  axLoc      = 'out';
  figPos     = [1  , 1, 11  ,10];
  axPos(1,:) = [1  , 1,  8  , 3];
  axPos(2,:) = [1  , 5,  8  , 3];
  cbPos      = [9.5, 1,  0.5, 7]; 

  colorbarManualLocationHelper_(figPos, axPos, cbPos, axLoc);
end
function [stat] = colorbarManualLocationRightIn()
  stat.description = 'Manual positioning of colorbars - Right In';
  stat.issues      = [933 937];

  axLoc      = 'in';
  figPos     = [ 1  , 1, 11  ,10]; 
  axPos(1,:) = [ 1  , 1,  8  , 3];
  axPos(2,:) = [ 1  , 5,  8  , 3];
  cbPos      = [10.5, 1,  0.5, 7]; 

  colorbarManualLocationHelper_(figPos, axPos, cbPos, axLoc);
end
function [stat] = colorbarManualLocationLeftOut()
  stat.description = 'Manual positioning of colorbars - Left Out';
  stat.issues      = [933 937];

  axLoc      = 'out'; 
  figPos     = [1  , 1, 11  , 10];
  axPos(1,:) = [2.5, 1,  8  ,  3];
  axPos(2,:) = [2.5, 5,  8  ,  3];
  cbPos      = [1.5, 1,  0.5,  7]; 

  colorbarManualLocationHelper_(figPos, axPos, cbPos, axLoc);
end
function [stat] = colorbarManualLocationLeftIn()
  stat.description = 'Manual positioning of colorbars - Left In';
  stat.issues      = [933 937];

  axLoc      = 'in'; 
  figPos     = [1  , 1, 11  , 10];
  axPos(1,:) = [2.5, 1,  8  ,  3];
  axPos(2,:) = [2.5, 5,  8  ,  3];
  cbPos      = [0.5, 1,  0.5,  7]; 

  colorbarManualLocationHelper_(figPos, axPos, cbPos, axLoc);
end
function colorbarManualLocationHelper_(figPos, axPos, cbPos, axLoc)
  % this is a helper function, not a test case
  set(gcf, 'Units','centimeters','Position', figPos);

  hAx(1) = axes('Units', 'centimeters', 'Position', axPos(1,:));
  imagesc([1,2,3], [4,5,6], magic(3)/9, [0,1]);

  hAx(2) = axes('Units', 'centimeters', 'Position', axPos(2,:));
  imagesc([1,2,3], [4,5,6], magic(3)/9, [0,1]);

  hCb = colorbar('Units', 'centimeters', 'Position', cbPos);
  try
      % only in HG2
      %TODO: check if there are HG1 / Octave counterparts for this property
      set(hCb, 'AxisLocation', axLoc);
  end
  
  labelProperty = {'Label', 'YLabel'}; %YLabel as fallback for
  idxLabel      = find(cellfun(@(p) isprop(hCb, p), labelProperty), 1);
  if ~isempty(idxLabel)
      hLabel = get(hCb, labelProperty{idxLabel});
      set(hLabel, 'String', ['AxisLocation = ' axLoc]);
  end
end
% =========================================================================
