% =========================================================================
% *** FUNCTION testfunctions
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================  
% ***
% *** Copyright (c) 2008--2012, Nico Schl\"omer <nico.schloemer@gmail.com>
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
function [ desc, funcName, numFunctions ] = testfunctions ( k )

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
                           @logplot             , ...
                           @colorbarLogplot     , ...
                           @legendplot          , ...
                           @legendplotBoxoff    , ...
                           @zoom                , ...
                           @quiveroverlap       , ...
                           @quiverplot          , ...
                           @imageplot           , ...
                           @imagescplot         , ...
                           @stairsplot          , ...
                           @polarplot           , ...
                           @roseplot            , ...
                           @compassplot         , ...
                           @stemplot            , ...
                           @groupbars           , ...
                           @bars                , ...
                           @hbars                , ...
                           @stackbars           , ...
                           @xAxisReversed       , ...
                           @errorBars           , ...
                           @errorBars2          , ...
                           @subplot2x2          , ...
                           @subplot2x2b         , ...
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
                      ...% @spectro             , ... % easily exceeds TeX's memory
                           @mixedBarLine        , ...
                           @decayingharmonic    , ...
                           @texcolor            , ...
                           @textext             , ...
                           @latexmath1          , ...
                           @latexmath2          , ...
                           @parameterCurve3d    , ...
                           @fill3plot           , ...
                           @rectanglePlot
                         };

  numFunctions = length( testfunction_handles );
  if (k<=0) 
      desc = '';
      funcName = '';
  elseif (k<=numFunctions)
      desc = testfunction_handles{ k } ();
      funcName = func2str( testfunction_handles{ k } );
  else
      error( 'testfunctions:outOfBounds', ...
             'Out of bounds (number of testfunctions=%d)', numFunctions ); 
  end

end
% =========================================================================
% *** FUNCTION one_point
function description = one_point ()

  plot(0.1, 0.1, 'x')

  description = 'Plot only one single point.' ;

end
% =========================================================================
% *** FUNCTION plain_cos
% ***
% *** Most simple example.
% ***
function description = plain_cos ()

  fplot( @cos, [0,2*pi] );

  % add some minor ticks
  set( gca, 'XMinorTick', 'on' );

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

  description = 'Plain cosine function, no particular extras.' ;

end
% =========================================================================
% *** FUNCTION sine_with_markers
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function description = sine_with_markers ()

  x = -pi:pi/10:pi;
  y = tan(sin(x)) - sin(tan(x));
  plot(x,y,'--ro','LineWidth', 1*360/127,...
                  'MarkerEdgeColor','k',...
                  'MarkerFaceColor','g',...
                  'MarkerSize', 5*360/127 );

  set( gca, 'Color', [0.9 0.9 1], ...
            'XTickLabel', [], ...
            'YTickLabel', [] ...
     );

  set(gca,'XTick',[0]);
  set(gca,'XTickLabel',{'null'});

  description = [ 'Twisted plot of the sine function. '                   ,...
                  'Pay particular attention to how markers are treated.'    ];

end
% =========================================================================
% *** FUNCTION sine_with_annotation
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function description = sine_with_annotation ()

  x = -pi:.1:pi;
  y = sin(x);
  plot(x,y);
  set(gca,'XTick',-pi:pi/2:pi);
  set(gca,'XTickLabel',{'-{pi}','-pi/2','0#&\','\pi/2','\pi'});

  xlabel('-\pi \leq \Theta \leq \pi');
  ylabel('sin(\Theta)');
  title('Plot of sin(\Theta)');
  text(-pi/4,sin(-pi/4),'\leftarrow sin(-\pi\div4)',...
      'HorizontalAlignment','left');

  set(findobj(gca,'Type','line','Color',[0 0 1]),...
      'Color','red',...
      'LineWidth',2)

  description = [ 'Plot of the sine function. '                        ,...
                  'Pay particular attention to how titles and annotations are treated.' ];

end
% =========================================================================
function description = linesWithOutliers()
    far = 200;
    x = [ -far, -1,   -1,  -far, -10, -0.5, 0.5, 10,  far, 1,   1,    far, 10,   0.5, -0.5, -10,  -far ];
    y = [ -10,  -0.5, 0.5, 10,   far, 1,    1,   far, 10,  0.5, -0.5, -10, -far, -1,  -1,   -far, -0.5 ];
    plot( x, y,'o-');
    axis( [-2,2,-2,2] );

    description = 'Lines with outliers.';
end
% =========================================================================
% *** FUNCTION peaks_contour
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function description = peaks_contour ()

  contour(peaks(20),10);

  % remove y-ticks
  set(gca,'YTickLabel',[]);
  set(gca,'YTick',[]);

  colormap winter;

  description = 'Test contour plots.';

end
% =========================================================================
function description = contourPenny()

  load penny;
  contour(flipud(P));
  axis square;

  description = 'Contour plot of a US\$ Penny.';

end
% =========================================================================
% *** FUNCTION peaks_contourf
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function description = peaks_contourf ()

  contourf( peaks(20), 10 );
  colorbar();
%    colorbar('NorthOutside');
%    colorbar('SouthOutside');
%    colorbar('WestOutside');

%    colormap autumn;
  colormap jet;

  description = 'Test the contourfill plots.';

end
% =========================================================================
% *** FUNCTION many_random_points
% ***
% *** Test the performance when drawing many points.
% ***
% =========================================================================
function description = many_random_points ()

  n = 1e3;

  xy = rand(n,2);
  plot ( xy(:,1), xy(:,2), '.r' );
  axis([ 0, 1, 0, 1 ])

  description = 'Test the performance when drawing many points.';

end
% =========================================================================
% *** FUNCTION logplot
% ***
% *** Test logscaled axes.
% ***
% =========================================================================
function description = logplot ()

  x = logspace(-1,2);
  loglog(x,exp(x),'-s')
  grid on

  description = 'Test logscaled axes.';

end
% =========================================================================
% *** FUNCTION colorbarLogplot
% ***
% *** Logscaled colorbar.
% ***
% =========================================================================
function description = colorbarLogplot ()

  imagesc([1 10 100]);
  set(colorbar(), 'YScale', 'log');

  description = 'Logscaled colorbar.';

end
% =========================================================================
% *** FUNCTION legendplot
% ***
function description = legendplot ()

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
  legend( '\sin(x)', '\cos(x)', 'Location','NorthOutside', ...
                                'Orientation', 'Horizontal' );
  grid on

  description = 'Test inserting of legends.';

end
% =========================================================================
% *** FUNCTION legendplotBoxoff
% ***
% *** A legend with 'boxoff'.
% ***
% =========================================================================
function description = legendplotBoxoff ()

  x = -pi:pi/20:pi;
  plot( x, cos(x),'-ro',...
        x, sin(x),'-.b' ...
      );
  h = legend( 'cos_x', 'one pretty long legend sin_x', 2 );
  set( h, 'Interpreter', 'none' );
  legend boxoff;

  description = 'Test inserting of legends.';

end
% =========================================================================
function description = zoom ()

  fplot( @sin, [0,2*pi], '-*' );
  hold on;
  eps = pi/10;

  plot( [pi/2, pi/2], [1-2*eps, 1+2*eps], 'r' ); % vertical line
  plot( [pi/2-2*eps, pi/2+2*eps], [1, 1], 'g' ); % horizontal line

  plot( [ pi/2-eps, pi/2 , pi/2+eps, pi/2 , pi/2-eps ], ...
        [ 1       , 1-eps,        1, 1+eps, 1        ], 'y'      );
  hold off;
  
  axis([ pi/2-eps, pi/2+eps, 1-eps, 1+eps] );

  description = 'Plain cosine function, zoomed in.' ;

end
% =========================================================================
function description = bars ()
  x = -2.9:0.2:2.9;
  bar(x,exp(-x.*x),'r')
  legend( 'exp(-x^2)' )
  description = 'Plot with bars.' ;
end
% =========================================================================
function description = hbars ()
  y = [75.995 91.972 105.711 123.203 131.669 ...
     150.697 179.323 203.212 226.505 249.633 281.422];
  barh(y);
  description = 'Horizontal bars.' ;
end
% =========================================================================
function description = groupbars ()
  X = [1,2,3,4,5];
  Y = round(rand(5,3)*20);
  bar(X,Y,'group','BarWidth',1)
  title 'Group'

  description = 'Plot with bars in groups.' ;

end
% =========================================================================
function description = stackbars ()

  Y = round(rand(5,3)*10);
  bar(Y,'stack');
  title 'Stack';

  description = 'Plot of stacked bars.' ;

end
% =========================================================================
function description = stemplot ()

  x = 0:25;
  y = [exp(-.07*x).*cos(x);exp(.05*x).*cos(x)]';
  h = stem(x,y);
  set(h(1),'MarkerFaceColor','blue')
  set(h(2),'MarkerFaceColor','red','Marker','square')

  description = 'A simple stem plot.' ;

end
% =========================================================================
function description = stairsplot ()

  x = linspace(-2*pi,2*pi,40);
  stairs(x,sin(x))

  description = 'A simple stairs plot.' ;

end
% =========================================================================
function description = quiverplot ()

  [X,Y] = meshgrid(-2:.2:2);
  Z = X.*exp(-X.^2 - Y.^2);
  [DX,DY] = gradient(Z,.2,.2);
  contour(X,Y,Z);
  hold on
  quiver(X,Y,DX,DY);
  colormap hsv;
  hold off

  description = 'A combined quiver/contour plot of $x\exp(-x^2-y^2)$.' ;

end
% =========================================================================
function description = quiveroverlap ()

  x = [0 1];
  y = [0 0];
  u = [1 -1];
  v = [1 1];

  quiver(x,y,u,v);

  description = 'Quiver plot with avoided overlap.';

end
% =========================================================================
function description = polarplot ()

  t = 0:.01:2*pi;
  polar(t,sin(2*t).*cos(2*t),'--r')

  description = 'A simple polar plot.' ;

end
% =========================================================================
function description = roseplot ()

  theta = 2*pi*rand(1,50);
  rose(theta);

  description = 'A simple rose plot.' ;

end
% =========================================================================
function description = compassplot ()

  Z = eig(randn(20,20));
  compass(Z);

  description = 'A simple compass plot.' ;

end
% =========================================================================
function description = imageplot ()

  n       = 10;
  density = 0.5;

  subplot( 1, 2, 1 );
  A       = sprand( n, n, density );
  imagesc( A );

  subplot( 1, 2, 2 );
  A       = sprand( n, n, density );
  imagesc( A );

  description = 'An image plot of matrix values.' ;

end
% =========================================================================
function description = imagescplot ()

  pointsX = 10;
  pointsY = 20;
  x       = 0:1/pointsX:1;
  y       = 0:1/pointsY:1;
  z       = sin(x)'*cos(y);
  imagesc(x,y,z);

  description = 'An imagesc plot of $\sin(x)\cos(y)$.' ;

end
% =========================================================================
function description = xAxisReversed ()

  n = 100;
  x = (0:1/n:1);
  y = exp(x);
  plot(x,y);
  set(gca,'XDir','reverse');
  set(gca,'YDir','reverse');
  legend( 'Location', 'SouthWest' );

  description = 'Reversed axes with legend.' ;

end
% =========================================================================
function description = subplot2x2 ()

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

end
% =========================================================================
function description = subplot2x2b ()

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

end
% =========================================================================
function description = subplot3x1 ()

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

end
% =========================================================================
function description = subplotCustom ()

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

end
% =========================================================================
function description = errorBars ()

  X = 0:pi/10:pi;
  Y = sin(X);
  E = std(Y)*ones(size(X));
  errorbar(X,Y,E)

  description = 'Generic error bar plot.' ;

end
% =========================================================================
function description = errorBars2 ()

  data = load( 'myCount.dat' );
  y = mean( data, 2 );
  e = std( data, 1, 2 );
  errorbar( y, e, 'xr' );

  description = 'Another error bar example.' ;

end
% =========================================================================
function description = legendsubplots ()
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

end
% =========================================================================
function description = bodeplots()

  % check if the control toolbox is installed
  if length(ver('control')) ~= 1
      fprintf( 'Control toolbox not found. Abort.\n\n' );
      description = [];
      return
  end

  g = tf([1 0.1 7.5],[1 0.12 9 0 0]);
  bode(g)
  description = 'Bode diagram of frequency response.';
end
% =========================================================================
function description = mandrillImage()
  data = load( 'mandrill' );
  set( gcf, 'color', 'k' )
  image( data.X )
  colormap( data.map )
  axis off
  axis image

  description = 'Picture of a mandrill.';
end
% =========================================================================
function description = besselImage()

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
end
% =========================================================================
function description = clownImage()
  data = load( 'clown' );
  imagesc( data.X )
  colormap( gray )

  description = 'Picture of a clown.';
end
% =========================================================================
function description = zplanePlot1()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      return
  end

  [z,p] = ellip(4,3,30,200/500);
  zplane(z,p);
  title('4th-Order Elliptic Lowpass Digital Filter');

  description = 'Representation of the complex plane with zplane.';
end
% =========================================================================
function description = zplanePlot2()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      return
  end

  [b,a] = ellip(4,3,30,200/500);
  Hd = dfilt.df1(b,a);
  zplane(Hd) % FIXME: This opens a new figure that doesn't get closed automatically

  description = 'Representation of the complex plane with zplane.';
end
% =========================================================================
function description = freqResponsePlot()

  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Skip.\n\n' );
      description = [];
      return
  end

  b  = fir1(80,0.5,kaiser(81,8));
  hd = dfilt.dffir(b);
  freqz(hd); % FIXME: This opens a new figure that doesn't get closed automatically

  description = 'Frequency response plot.';
end
% =========================================================================
function description = multipleAxes()
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
end
% =========================================================================
function description = scatterPlotRandom()

  x = randn( 10, 2 );
  scatter( x(:,1), x(:,2)  );
  description = 'Generic scatter plot.';

end
% =========================================================================
function description = scatterPlot()

  data = load( 'seamount' );
  scatter( data.x, data.y, 5, data.z, '^' );
  description = 'Scatter plot with MATLAB(R) data.';

end
% =========================================================================
function description = scatter3Plot()

  [x,y,z] = sphere(16);
  X = [x(:)*.5 x(:)*.75 x(:)];
  Y = [y(:)*.5 y(:)*.75 y(:)];
  Z = [z(:)*.5 z(:)*.75 z(:)];
  S = repmat([1 .75 .5]*10,numel(x),1);
  C = repmat([1 2 3],numel(x),1);
  scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
  view(40,35)

  description = 'Scatter3 plot with MATLAB(R) data.';

end
% =========================================================================
function description = scatter3Plot2()

  % Read image (Note: "peppers.png" is available with MATLAB)
  InpImg_RGB = imread('peppers.png');

  % Subsample image ("scatter3" can't cope with too many points)
  InpImg_RGB = InpImg_RGB(1:100:end, 1:100:end );

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

  return
end
% =========================================================================
function description = surfPlot()
  [X,Y,Z] = peaks(30);
  surf(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Surface plot.';
end
% =========================================================================
function description = surfPlot2()
  z = [ ones(15, 5) zeros(15,5); ...
        zeros(5,5) zeros(5,5)
      ];

  surf( abs( fftshift(fft2(z)) ) )

  legend( 'legendary', 'Location', 'NorthEastOutside' );

  description = 'Another surface plot.';
end
% =========================================================================
function description = meshPlot()
  [X,Y,Z] = peaks(30);
  mesh(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Mesh plot.';
end
% =========================================================================
function description = ylabels()

  x = 0:.01:2*pi;
  H = plotyy(x,sin(x),x,3*cos(x));

  ylabel(H(1),'sin(x)');
  ylabel(H(2),'3cos(x)');

  xlabel(gca,'time')

  description = 'Separate y-labels.';
end
% =========================================================================
function description = spectro()
  % check of the signal processing toolbox is installed
  if length(ver('signal')) ~= 1
      fprintf( 'Signal toolbox not found. Abort.\n\n' );
      description = [];
      return
  end

  load chirp; %audio-file in vector 'y'
  spectrogram( y, hann(1024), 512, 1024, Fs, 'yaxis' )
  description = 'Spectrogram plot';
end
% =========================================================================
%  function description = spyplot()
%  
%    spy
%  
%    description = 'Sparsity pattern';
%  end
% =========================================================================
function description = mixedBarLine()

    x = rand(1000,1)*10;
    hist(x,10)
    y = ylim;
    hold on;
    plot([3 3], y, '-r');
    hold off;

    description = 'Mixed bar/line plot.';
end
% =========================================================================
function description = decayingharmonic()
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
end
% =========================================================================
function description = texcolor()
  % Taken from an example at
  % http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
  text(.1, .5, ['\fontsize{16}black {\color{magenta}magenta '...
                '\color[rgb]{0 .5 .5}teal \color{red}red} black again'])

  description = 'Multi-colored text using \TeX{} commands.';
end
% =========================================================================
function description = textext()
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
end
% =========================================================================
function description = latexmath1()
  % Adapted from an example at
  % http://www.mathworks.com/help/techdoc/ref/text_props.html#Interpreter
  axes
  title( '\omega\subseteq\Omega' );
  text( 0.5, 0.5, '$$\int_0^x\!\int_{\Omega} dF(u,v) d\omega$$', ...
        'Interpreter', 'latex',                   ...
        'FontSize', 16                            )

  description = 'A formula typeset using the \LaTeX{} interpreter.';
end
% =========================================================================
function description = latexmath2()
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

  description = 'Some nice-looking formulas typeset using the \LaTeX{} interpreter.';
end
% =========================================================================
function description = parameterCurve3d()
    ezplot3('sin(t)','cos(t)','t',[0,6*pi])
    description = 'Parameter curve in 3D.';
end
% =========================================================================
function description = fill3plot()
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
end
% =========================================================================
function description = rectanglePlot()
    rectangle('Position', [0.59,0.35,3.75,1.37],...
              'Curvature', [0.8,0.4],...
              'LineWidth', 2, ...
              'LineStyle', '--' ...
             );
    daspect([1,1,1]);

    description = 'Rectangle handle.';

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
function [below, error] = isVersionBelow ( env, threshMajor, threshMinor )
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
      error = true;
      return
  end

  majorVer = str2double(regexprep( versionString, '^(\d+)\..*', '$1' ));
  minorVer = str2double(regexprep( versionString, '^\d+\.(\d+)[^\d]*.*', '$1' ));
  
  if (majorVer < threshMajor) || (majorVer == threshMajor && minorVer < threshMinor)
      % version of `env' is below threshold
      below = true;
  else
      % version of `env' is same as or above threshold
      below = false;
  end
  error = false;
end
% =========================================================================