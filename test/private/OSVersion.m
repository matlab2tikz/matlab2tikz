function [formatted, OSType, OSVersion] = OSVersion()
    if ismac
        OSType = 'Mac OS';
        [dummy, OSVersion] = system('sw_vers -productVersion');
    elseif ispc
        OSType = '';% will already contain Windows in the output of `ver`
        [dummy, OSVersion] = system('ver');
    elseif isunix
        OSType = 'Unix';
        [dummy, OSVersion] = system('uname -r');
    else
        OSType = '';
        OSVersion = '';
    end
    formatted = strtrim([OSType ' ' OSVersion]);
end