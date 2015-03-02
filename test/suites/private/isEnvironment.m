function bool = isEnvironment(wantedEnvironment, varargin)
% ISENVIRONMENT check for a particular environment (MATLAB/Octave)
%
% This function returns TRUE when it is run within the "wantedEnvironment"
% (e.g. MATLAB or Octave). This environment can be tested to be a particular
% version or be older/newer than a specified version.
%
% Usage:
%
%  ISENVIRONMENT(ENV)
%  ISENVIRONMENT(ENV, VERSION)
%  ISENVIRONMENT(ENV, OP, VERSION)
%
% Parameters:
%  - `ENV`: the expected environment (e.g. 'MATLAB' or 'Octave')
%  - `VERSION`: a version number or string to compare against
%               e.g. "3.4" or equivalently [3,4]
%  - `OP`: comparison operator (e.g. '==', '<=', '<', ...) to define a range
%          of version numbers that return a TRUE value
%
% When `OP` is not specified, "==" is used.
% When no `VERSION` is specified, all versions pass the check.
%
% See also: isMATLAB, isOctave, versionCompare
    [env, thisVersion] = getEnvironment();
    bool = strcmpi(env, wantedEnvironment);

    switch numel(varargin)
        case 0 % nothing to be done
        	return

        case 1 % check equality
        	version = varargin{1};
            operator = '==';
            bool = bool && versionCompare(thisVersion, operator, version);

        case 2
        	operator = varargin{1};
        	version = varargin{2};
            bool = bool && versionCompare(thisVersion, operator, version);

		otherwise
			error('isEnvironment:BadNumberOfArguments', ...
			      '"isEnvironment" was called with an incorrect number of arguments.');
    end
end
