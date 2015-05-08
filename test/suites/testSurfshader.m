function status = testSurfshader(k)
% TESTSURFSHADER Test suite for Surf/mesh shaders (coloring)
%
% See also: ACID, matlab2tikz_acidtest

  testfunction_handles = {
      @surfShader1;
      @surfShader2;
      @surfShader3;
      @surfShader4;
      @surfShader5;
      @surfNoShader;
      @surfNoPlot;
      @surfMeshInterp;
      @surfMeshRGB;
      };

  numFunctions = length( testfunction_handles );

  if nargin < 1 || isempty(k) || k <= 0
      status = testfunction_handles;
      return;  % This is used for querying numFunctions.

  elseif (k<=numFunctions)
      status = testfunction_handles{k}();
      status.function = func2str(testfunction_handles{k});

  else
      error('patchTests:outOfBounds', ...
            'Out of bounds (number of testfunctions=%d)', numFunctions);
  end

end

% =========================================================================
function [stat] = surfShader1()
  stat.description = 'shader=flat/(flat mean) | Fc: flat | Ec: none';

  [X,Y,Z]  = peaks(5);
  surf(X,Y,Z,'FaceColor','flat','EdgeColor','none')
end
% =========================================================================
function [stat] = surfShader2()
  stat.description = 'shader=interp | Fc: interp | Ec: none';

  [X,Y,Z]  = peaks(5);
  surf(X,Y,Z,'FaceColor','interp','EdgeColor','none')
end
% =========================================================================
function [stat] = surfShader3()
  stat.description = 'shader=faceted | Fc: flat | Ec: RGB';

  [X,Y,Z]  = peaks(5);
  surf(X,Y,Z,'FaceColor','flat','EdgeColor','green')
end
% =========================================================================
function [stat] = surfShader4()
stat.description = 'shader=faceted | Fc: RGB | Ec: interp';
if isMATLAB('<', [8,4]); %R2014a and older
    warning('m2t:ACID:surfShader4',...
        'The MATLAB EPS export may behave strangely for this case');
end

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','blue','EdgeColor','interp')
end
% =========================================================================
function [stat] = surfShader5()
stat.description = 'shader=faceted interp | Fc: interp | Ec: flat';

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','interp','EdgeColor','flat')
end
% =========================================================================
function [stat] = surfNoShader()
stat.description = 'no shader | Fc: RGB | Ec: RGB';

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','blue','EdgeColor','yellow')
end
% =========================================================================
function [stat] = surfNoPlot()
stat.description = 'no plot | Fc: none | Ec: none';

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','none','EdgeColor','none')
end
% =========================================================================
function [stat] = surfMeshInterp()
stat.description = 'mesh | Fc: none | Ec: interp';

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','none','EdgeColor','interp')
end
% =========================================================================
function [stat] = surfMeshRGB()
stat.description = 'mesh | Fc: none | Ec: RGB';

[X,Y,Z]  = peaks(5);
surf(X,Y,Z,'FaceColor','none','EdgeColor','green')
end
% =========================================================================
