% ==============================================================================
function pointReductionTest()

  breakTime = 5.0;

  testPlots = {@testPlot1, ...
              };
               %@testPlot2};

  for testPlot = testPlots
      testPlot();
      'a'
      %pause(breakTime);
      %pointReduction2d(0.1);
      pause(breakTime);
      'b'
  end

  close all;

end
% ==============================================================================
function testPlot1()
  x = -pi:pi/1000:pi;
  y = tan(sin(x)) - sin(tan(x));
  plot(x,y,'--rs');
end
% ==============================================================================
function testPlot2()
  x = -pi:pi/1000:pi;
  y = exp(tan(sin(x)) - sin(tan(x)));
  semilogy(x,y,'--rs');
end
% ==============================================================================
