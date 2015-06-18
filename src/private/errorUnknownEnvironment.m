function errorUnknownEnvironment()
% Throw an error to indicate an unknwon environment (i.e. notMATLAB/Octave/...).
    error('matlab2tikz:unknownEnvironment',...
          'Unknown environment "%s". Need MATLAB(R) or Octave.', getEnvironment);
end
