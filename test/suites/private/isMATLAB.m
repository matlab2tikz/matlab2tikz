function bool = isMATLAB(varargin)
%ISMATLAB Determines whether (a certain) version of MATLAB is being used
% See also: isEnvironment, isOctave
bool = isEnvironment('MATLAB', varargin{:});
