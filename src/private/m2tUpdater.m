function updater(name, fileExchangeUrl, version, verbose, env)
%UPDATER   Auto-update matlab2tikz.
%   Only for internal usage.

%   Copyright (c) 2012--2014, Nico Schlömer <nico.schloemer@gmail.com>
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the distribution
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.
% =========================================================================
  try
      html = urlread([fileExchangeUrl, '/all_files']);
  catch %#ok
      % Couldn't load the URL -- never mind.
      html = '';
  end
  % Search for a string "/version-1.6.3" in the HTML. This assumes
  % that the package author has added a file by that name to
  % to package. This is a rather dirty hack around FileExchange's
  % lack of native versioning information.
  mostRecentVersion = regexp(html, '/version-(\d+\.\d+\.\d+)', 'tokens');
  if ~isempty(mostRecentVersion)
      if isVersionBelow(env, version, mostRecentVersion{1}{1})
          userInfo(verbose, '**********************************************\n');
          userInfo(verbose, 'New version available! (%s)\n', mostRecentVersion{1}{1});
          userInfo(verbose, '**********************************************\n');

          reply = input([' *** Would you like ', name, ' to self-upgrade? y/n [n]:'],'s');
          if strcmp(reply, 'y')
              % Download the files and unzip its contents into the folder
              % above the folder that contains the current script.
              % This assumes that the file structure is something like
              %
              %   src/matlab2tikz.m
              %   src/[...]
              %   AUTHORS
              %   ChangeLog
              %   [...]
              %
              % on the hard drive and the zip file. In particular, this assumes
              % that the folder on the hard drive is writable by the user
              % and that matlab2tikz.m is not symlinked from some other place.
              pathstr = fileparts(mfilename('fullpath'));
              targetPath = [pathstr, filesep, '..', filesep];
              userInfo(verbose, ['Downloading and unzipping to ', targetPath, '...']);
              upgradeSuccess = false;
              try
                  unzippedFiles = unzip([fileExchangeUrl, '?download=true'], targetPath);
                  upgradeSuccess = true; %~isempty(unzippedFiles);
                  userInfo(verbose, 'done.');
              catch
                  userInfo(verbose, 'FAILED.');
              end
              if upgradeSuccess
                  % TODO explicitly delete all of the old content
                  % Delete old version number file.
                  versionFile = [pathstr, filesep, 'version-', version];
                  if exist(versionFile, 'file') == 2
                      delete(versionFile);
                  end
                  % TODO anything better than error()?
                  error('Upgrade successful. Please re-execute.');
              else
                  error('Upgrade failed.');
              end
          end
          userInfo(verbose, '');
      end
  end
end
% =========================================================================
function isBelow = isVersionBelow(env, versionA, versionB)
  % Checks if version string or vector versionA is smaller than
  % version string or vector versionB.

  vA = versionArray(env, versionA);
  vB = versionArray(env, versionB);

  isBelow = false;
  for i = 1:min(length(vA), length(vB))
    if vA(i) > vB(i)
      isBelow = false;
      break;
    elseif vA(i) < vB(i)
      isBelow = true;
      break
    end
  end

end
% =========================================================================
function arr = versionArray(env, str)
  % Converts a version string to an array, e.g.,
  % '2.62.8.1' to [2, 62, 8, 1].

  if ischar(str)
    if strcmpi(env, 'MATLAB')
        split = regexp(str, '\.', 'split');
    elseif strcmpi(env, 'Octave')
        split = strsplit(str, '.');
    end
    arr = str2num(char(split)); %#ok
  else
    arr = str;
  end

end
% =========================================================================
function userInfo(verbose, message, varargin)
  % Display usage information.

  if ~verbose
      return
  end

  mess = sprintf(message, varargin{:});

  % Replace '\n' by '\n *** ' and print.
  mess = strrep( mess, sprintf('\n'), sprintf('\n *** ') );
  fprintf( ' *** %s\n', mess );

end
% =========================================================================
