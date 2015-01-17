function bool = isMATLAB(operator, version)
%ISMATLAB Determines whether (a certain) version of Octave is being used
[env, thisVersion] = getEnvironment();
bool = strcmpi(env, 'MATLAB');

    switch nargin
        case 0 % nothing to be done
        case 1 % check equality
            version = operator;
            operator = '==';
            bool = bool && versionCompare(thisVersion, operator, version);
        case 2
            bool = bool && versionCompare(thisVersion, operator, version);
    end
end
