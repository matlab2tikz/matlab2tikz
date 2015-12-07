function arr = versionArray(str)
% Converts a version string to an array.
    if ischar(str)
        % Translate version string from '2.62.8.1' to [2; 62; 8; 1].
        switch getEnvironment
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
