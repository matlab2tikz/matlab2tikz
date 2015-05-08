function bool = isOctave(varargin)
%ISOCTAVE Determines whether (a certain) version of Octave is being used
%
% See also: isEnvironment, isMATLAB
bool = isEnvironment('Octave', varargin{:});
