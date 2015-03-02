function isBelow = isVersionBelow(env, versionA, versionB)
% Checks if versionA is smaller than versionB
    vA         = versionArray(env, versionA);
    vB         = versionArray(env, versionB);
    n          = min(length(vA), length(vB));
    deltaAB    = vA(1:n) - vB(1:n);
    difference = find(deltaAB, 1, 'first');
    if isempty(difference)
        isBelow = false; % equal versions
    else
        isBelow = (deltaAB(difference) < 0);
    end
end
% ==============================================================================
function arr = versionArray(env, str)
% Converts a version string to an array.
    if ischar(str)
        % Translate version string from '2.62.8.1' to [2; 62; 8; 1].
        switch env
            case 'MATLAB'
                split = regexp(str, '\.', 'split'); % compatibility MATLAB < R2013a
            case  'Octave'
                split = strsplit(str, '.');
            otherwise
                errorUnknownEnvironment();
        end
        arr = str2num(char(split)); %#ok
    else
        arr = str;
    end
    arr = arr(:)';
end
% ==============================================================================
