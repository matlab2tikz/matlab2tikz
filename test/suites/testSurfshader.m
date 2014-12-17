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
env = getEnvironment();
if strcmpi(env, 'MATLAB') && isVersionBelow(env, 8, 4) %R2014a and older
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
function env = getEnvironment
  if ~isempty(ver('MATLAB'))
     env = 'MATLAB';
  elseif ~isempty(ver('Octave'))
     env = 'Octave';
  else
     env = [];
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