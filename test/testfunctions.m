% =========================================================================
% *** FUNCTION testfunctions
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================  
% ***
% *** Copyright (c) 2008--2011, Nico Schl\"omer <nico.schloemer@gmail.com>
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
function [ desc, numFunctions ] = testfunctions ( k )

  % assign the functions to test
  testfunction_handles = {                        ...
                           @one_point           , ...
                           @plain_cos           , ...
                           @sine_with_markers   , ...
                           @sine_with_annotation, ...
                           @peaks_contour       , ...
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
                           @stackbars           , ...
                           @xAxisReversed       , ...
                           @errorBars           , ...
                           @errorBars2          , ...
                           @subplot2x2          , ...
                           @subplot3x1          , ...
                           @subplotCustom       , ...
                           @legendsubplots      , ...
                           @imageplot           , ...
                           @mandrillImage       , ...
                           @besselImage         , ...
                           @clownImage          , ...
                           @zplanePlot1         , ...
                           @zplanePlot2         , ...
                           @multipleAxes        , ...
                           @scatterPlot         , ...
                           @surfPlot            , ...
                           @surfPlot2           , ...
                           @meshPlot            , ...
                           @ylabels
                         };
%                             @spectro
                           %@freqResponsePlot    , ...
                           %@bodeplots           , ...

%                             @groupbars           , ...
%                             @bars                , ...

  numFunctions = length( testfunction_handles );
  if (k<=0) 
      desc = '';
  elseif (k<=numFunctions)
      desc = testfunction_handles{ k } ();
  else
      error( 'testfunctions:outOfBounds', ...
             'Out of bounds (number of testfunctions=%d)', numFunctions ); 
  end

end
% =========================================================================
% *** END FUNCTION testfunctions
% =========================================================================


% =========================================================================
% *** FUNCTION one_point
% =========================================================================
function description = one_point ()

  plot(0.1, 0.1, 'x')

  description = 'Plot only one single point.' ;

end
% =========================================================================
% *** END FUNCTION one_point
% =========================================================================


% =========================================================================
% *** FUNCTION plain_cos
% ***
% *** Most simple example.
% ***
% =========================================================================
function description = plain_cos ()


  fplot( @cos, [0,2*pi] );

  % Adjust the aspect ration when in MATLAB(R).
  version_data = ver;
  if length( version_data ) > 1 % assume MATLAB
      daspect([ 1 2 1 ])
  elseif strcmp( version_data.Name, 'Octave' )
      % Octave doesn't have daspect unfortunately.
  else
      error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
  end

  description = 'Plain cosine function, no particular extras.' ;

end
% =========================================================================
% *** END FUNCTION plain_cos
% =========================================================================



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


  description = [ 'Twisted plot of the sine function. '                   ,...
                  'Pay particular attention to how markers are treated.'    ];

end
% =========================================================================
% *** END FUNCTION sine_with_markers
% =========================================================================



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
  set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'});

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
% *** END FUNCTION sine_with_annotation
% =========================================================================


% =========================================================================
% *** FUNCTION peaks_contour
% ***
% *** Standard example plot from MATLAB's help pages.
% ***
% =========================================================================
function description = peaks_contour ()

  contour(peaks(20),10);

  colormap winter;

  description = 'Test contour plots.';

end
% =========================================================================
% *** END FUNCTION peaks_contour
% =========================================================================


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
% *** END FUNCTION peaks_contourf
% =========================================================================



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
% *** END FUNCTION many_random_points
% =========================================================================



% =========================================================================
% *** FUNCTION logplot
% ***
% *** Test the performance when drawing many points.
% ***
% =========================================================================
function description = logplot ()

  x = logspace(-1,2);
  loglog(x,exp(x),'-s')
  grid on

  description = 'Test logscaled axes.';

end
% =========================================================================
% *** END FUNCTION logplot
% =========================================================================


% =========================================================================
% *** FUNCTION logplot
% ***
% *** Test the performance when drawing many points.
% ***
% =========================================================================
function description = colorbarLogplot ()

  imagesc([1 10 100]);
  set(colorbar(), 'YScale', 'log');

  description = 'Logscaled colorbar.';

end
% =========================================================================
% *** END FUNCTION logplot
% =========================================================================

% =========================================================================
% *** FUNCTION legendplot
% =========================================================================
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
  legend( '\sin(x)', '\cos(x)' );
  grid on

  description = 'Test inserting of legends.';

end
% =========================================================================
% *** END FUNCTION legendplot
% =========================================================================


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
% *** END FUNCTION legendplotBoxoff
% =========================================================================



% =========================================================================
% *** FUNCTION zoom
% ***
% *** Most simple example.
% ***
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
% *** END FUNCTION zoom
% =========================================================================



% =========================================================================
% *** FUNCTION bars
% ***
% *** Bar plot.
% ***
% =========================================================================
function description = bars ()

  x = -2.9:0.2:2.9;
  bar(x,exp(-x.*x),'r')

  description = 'Plot with bars.' ;

end
% =========================================================================
% *** END FUNCTION bars
% =========================================================================



% =========================================================================
% *** FUNCTION groupbars
% ***
% *** Bar plot.
% ***
% =========================================================================
function description = groupbars ()
  X = [1,2,3,4,5];
  Y = round(rand(5,3)*20);
  bar(X,Y,'group','BarWidth',1)
  title 'Group'

  description = 'Plot with bars in groups.' ;

end
% =========================================================================
% *** END FUNCTION groupbars
% =========================================================================



% =========================================================================
% *** FUNCTION stackbars
% =========================================================================
function description = stackbars ()

  Y = round(rand(5,3)*10);
  bar(Y,'stack');
  title 'Stack';

  description = 'Plot of stacked bars.' ;

end
% =========================================================================
% *** END FUNCTION stackbars
% =========================================================================



% =========================================================================
% *** FUNCTION stemplot
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
% *** END FUNCTION stemplot
% =========================================================================



% =========================================================================
% *** FUNCTION stairsplot
% =========================================================================
function description = stairsplot ()

  x = linspace(-2*pi,2*pi,40);
  stairs(x,sin(x))

  description = 'A simple stairs plot.' ;

end
% =========================================================================
% *** END FUNCTION stairsplot
% =========================================================================



% =========================================================================
% *** FUNCTION quiverplot
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
% *** END FUNCTION quiverplot
% =========================================================================


% =========================================================================
% *** FUNCTION quiveroverlap
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
% *** END FUNCTION quiveroverlap
% =========================================================================


% =========================================================================
% *** FUNCTION polarplot
% =========================================================================
function description = polarplot ()

  t = 0:.01:2*pi;
  polar(t,sin(2*t).*cos(2*t),'--r')

  description = 'A simple polar plot.' ;

end
% =========================================================================
% *** END FUNCTION polarplot
% =========================================================================



% =========================================================================
% *** FUNCTION roseplot
% =========================================================================
function description = roseplot ()

  theta = 2*pi*rand(1,50);
  rose(theta);

  description = 'A simple rose plot.' ;

end
% =========================================================================
% *** END FUNCTION roseplot
% =========================================================================



% =========================================================================
% *** FUNCTION compassplot
% =========================================================================
function description = compassplot ()

  Z = eig(randn(20,20));
  compass(Z);

  description = 'A simple compass plot.' ;

end
% =========================================================================
% *** END FUNCTION compassplot
% =========================================================================


% =========================================================================
% *** FUNCTION imageplot
% =========================================================================
function description = imageplot ()

  n       = 10;
  density = 0.5;
  A       = sprand( n, n, density );
  imagesc( A );

  description = 'An image plot of matrix values.' ;

end
% =========================================================================
% *** END FUNCTION imageplot
% =========================================================================



% =========================================================================
% *** FUNCTION imagescplot
% =========================================================================
function description = imagescplot ()

  pointsX = 10;
  pointsY = 20;
  x       = 0:1/pointsX:1;
  y       = 0:1/pointsY:1;
  z       = sin(x)'*cos(y);
  imagesc(x,y,z);

  description = 'An imagesc plot os $\sin(x)\cos(y)$.' ;

end
% =========================================================================
% *** END FUNCTION imagescplot
% =========================================================================


% =========================================================================
% *** FUNCTION xAxisReversed
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
% *** END FUNCTION xAxisReversed
% =========================================================================



% =========================================================================
% *** FUNCTION subplot2x2
% =========================================================================
function description = subplot2x2 ()

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
% *** END FUNCTION subplot2x2
% =========================================================================


% =========================================================================
% *** FUNCTION subplot3x1
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
% *** END FUNCTION subplot3x1
% =========================================================================


% =========================================================================
% *** FUNCTION subplotCustom
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
% *** END FUNCTION subplotCustom
% =========================================================================



% =========================================================================
% *** FUNCTION errorBars
% =========================================================================
function description = errorBars ()

  X = 0:pi/10:pi;
  Y = sin(X);
  E = std(Y)*ones(size(X));
  errorbar(X,Y,E)

  description = 'Generic error bar plot.' ;

end
% =========================================================================
% *** END FUNCTION errorBars
% =========================================================================



% =========================================================================
% *** FUNCTION errorBars2
% =========================================================================
function description = errorBars2 ()

  data = load( 'myCount.dat' );
  y = mean( data, 2 );
  e = std( data, 1, 2 );
  errorbar( y, e, 'xr' );

  description = 'Another error bar example.' ;

end
% =========================================================================
% *** END FUNCTION errorBars2
% =========================================================================



% =========================================================================
% *** FUNCTION legendsubplots
% =========================================================================
function description = legendsubplots ()
% size of upper subplot
rows = 4;
% number of points.  A large number here (eg 1000) will stress-test
% matlab2tikz and your TeX installation.  Be prepared for it to run out of
% memory
length = 100;


% make some spurious data
t=0:(4*pi)/length:4*pi;
x=t;
a=t;
y=sin(t)+0.1*randn(1,length+1);
b=sin(t)+0.1*randn(1,length+1)+0.05*cos(2*t);

% plot the top figure
subplot(rows+2,1,1:rows);

% first line
sigma1=std(y,0,1);
tracey=mean(y,1);
plot123=plot(x,tracey,'b-'); 

hold on

% second line
sigma2=mean(std(b,0,1));
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

description = 'Subplots with legends.  Increase value of "length" in the code to stress-test your TeX installation.';

end
% =========================================================================
% *** END FUNCTION legendsubplots
% =========================================================================


% =========================================================================
% *** FUNCTION bodeplots
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
% *** END FUNCTION bodeplots
% =========================================================================


% =========================================================================
% *** FUNCTION mandrillImage
% =========================================================================
function description = mandrillImage()
  data = load( 'mandrill' );
  figure('color','k')
  image( data.X )
  colormap( data.map )
  axis off
  axis image

  description = 'Picture of a mandrill';
end
% =========================================================================
% *** END FUNCTION mandrillImage
% =========================================================================


% =========================================================================
% *** FUNCTION besselImage
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
  
  description = 'Bessel function';
end
% =========================================================================
% *** END FUNCTION besselImage
% =========================================================================


% =========================================================================
% *** FUNCTION clownImage
% =========================================================================
function description = clownImage()
  data = load( 'clown' );
  imagesc( data.X )
  colormap( gray )

  description = 'Picture of a clown';
end
% =========================================================================
% *** END FUNCTION clownImage
% =========================================================================


% =========================================================================
% *** FUNCTION zplanePlot1
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
% *** END FUNCTION zplanePlot1
% =========================================================================


% =========================================================================
% *** FUNCTION zplanePlot2
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
  zplane(Hd)

  description = 'Representation of the complex plane with zplane.';
end
% =========================================================================
% *** END FUNCTION zplanePlot2
% =========================================================================


% =========================================================================
% *** FUNCTION freqResponsePlot
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
  freqz(hd);

  description = 'Frequency response plot';
end
% =========================================================================
% *** END FUNCTION freqResponsePlot
% =========================================================================


% =========================================================================
% *** FUNCTION multipleAxes
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
  description = 'Multiple axes';
end
% =========================================================================
% *** END FUNCTION multipleAxes
% =========================================================================


% =========================================================================
% *** FUNCTION scatterPlot
% =========================================================================
function description = scatterPlot()
  data = load( 'seamount' );
  scatter( data.x, data.y, 5, data.z, '^' );
  description = 'Scatter plot';
end
% =========================================================================
% *** END FUNCTION scatterPlot
% =========================================================================


% =========================================================================
% *** FUNCTION surfPlot
% =========================================================================
function description = surfPlot()
  [X,Y,Z] = peaks(30);
  surf(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Surface plot';
end
% =========================================================================
% *** END FUNCTION surfPlot
% =========================================================================


% =========================================================================
% *** FUNCTION surfPlot2
% =========================================================================
function description = surfPlot2()
  z = [ ones(15, 5) zeros(15,5); ...
        zeros(5,5) zeros(5,5)
      ];

  surf( abs( fftshift(fft2(z)) ) )

  legend( 'legendary', 'Location', 'NorthEastOutside' );

  description = 'Another surface plot';
end
% =========================================================================
% *** END FUNCTION surfPlot2
% =========================================================================


% =========================================================================
% *** FUNCTION meshPlot
% =========================================================================
function description = meshPlot()
  [X,Y,Z] = peaks(30);
  mesh(X,Y,Z)
  colormap hsv
  axis([-3 3 -3 3 -10 5])

  xlabel( 'x' )
  ylabel( 'y' )
  zlabel( 'z' )

  description = 'Mesh plot';
end
% =========================================================================
% *** END FUNCTION meshPlot
% =========================================================================


% =========================================================================
% *** FUNCTION ylabels
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
% *** END FUNCTION ylabels
% =========================================================================



% =========================================================================
% *** FUNCTION spectro
% =========================================================================
%  function description = spectro()
%    % check of the signal processing toolbox is installed
%    if length(ver('signal')) ~= 1
%        fprintf( 'Signal toolbox not found. Abort.\n\n' );
%        description = [];
%        return
%    end
%  
%    load chirp; %audio-file in vector 'y'
%    spectrogram( y, hann(1024), 512, 1024, Fs, 'yaxis' )
%    description = 'Spectrogram plot';
%  end
% =========================================================================
% *** END FUNCTION spectro
% =========================================================================


%  % =========================================================================
%  % *** FUNCTION spyplot
%  % =========================================================================
%  function description = spyplot()
%  
%    spy
%  
%    description = 'Sparsity pattern';
%  end
%  % =========================================================================
%  % *** END FUNCTION spyplot
%  % =========================================================================
