function [formatted, OSType, OSVersion] = OSVersion()
    % determines the OS type and its (kernel) version number
    if ismac
        OSType = 'Mac OS';
        [dummy, OSVersion] = system('sw_vers -productVersion'); %#ok
        % Output like "10.10.4" for OS X Yosemite

    elseif ispc
        OSType = 'Windows';
        [dummy, rawVersion] = system('ver'); %#ok
        % Output like "Microsoft Windows [Version 6.3.9600]" for Win8.1
        pattern = '(?<=Version )[0-9.]+';
        OSVersion = regexpi(rawVersion, pattern, 'match', 'once');

    elseif isunix
        [dummy, OSType] = system('uname -s'); %#ok
        % This returns the kernal name
        % e.g. "Linux" on Linux, "Darwin" on Mac, "SunOS" on Solaris
        [dummy, OSVersion] = system('uname -r'); %#ok
        % Returns the kernel version. Many Linux distributions
        % include an identifier, e.g. "4.0.7-2-ARCH" on Arch Linux

        % TODO: also use `lsb_release` in Linux for distro info
    else
        warning('OSVersion:UnknownOS', 'Could not recognize OS.');
        OSType = 'Unknown OS';
        OSVersion = '';

    end

    EOL = sprintf('\n');
    OSType = strrep(OSType, EOL, '');
    OSVersion = strrep(OSVersion, EOL, '');

    formatted = strtrim([OSType ' ' OSVersion]);
end
