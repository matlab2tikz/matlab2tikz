function upgradeSuccess = m2tUpdater(name, fileExchangeUrl, version, verbose, env)
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
  
  % Read in the Github releases page
  url = 'https://github.com/matlab2tikz/matlab2tikz/releases/';
  try
      html = urlread(url);
  catch %#ok
      % Couldn't load the URL -- never mind.
      html = '';
  end
  
  % Parse tag names which are the version number in the format ##.##.##
  % It assumes that releases will always be tagged with the version number
  expression = '(?<=matlab2tikz\/matlab2tikz\/releases\/tag\/)\d+\.\d+\.\d+';
  tags       = regexp(html, expression, 'match');
  ntags      = numel(tags);
  
  % Keep only new releases
  inew = false(ntags,1);
  for ii = 1:ntags
      inew(ii) = isVersionBelow(env, version, tags{ii});
  end
  nnew = nnz(inew);
  
  % One new release
  if nnew == 1
      mostRecentVersion = tags{inew};
  % Several new release, pick latest
  elseif nnew > 1
      tags   = tags(inew);
      tagnum = zeros(nnew,1);
      for ii = 1:nnew
          tagnum(ii) = [10000,100,1] * versionArray(env, tags{ii});
      end
      [~, imax]         = max(tagnum);
      mostRecentVersion = tags{imax};
  % No new 
  else
      mostRecentVersion = '';
  end
  
  upgradeSuccess = false;
  if ~isempty(mostRecentVersion)
      userInfo(verbose, '**********************************************\n');
      userInfo(verbose, 'New version available! (%s)\n', mostRecentVersion);
      userInfo(verbose, '**********************************************\n');
      
      userInfo(verbose, 'By upgrading you may lose any custom changes.\n');
      reply = input([' *** Would you like ', name, ' to self-upgrade? y/n [n]:'],'s');
      if strcmpi(reply, 'y')
          % Download the files and unzip its contents into two folders
          % above the folder that contains the current script.
          % This assumes that the file structure is something like
          %
          %   src/matlab2tikz.m
          %   src/[...]
          %   src/private/m2tUpdater
          %   src/private/[...]
          %   AUTHORS
          %   ChangeLog
          %   [...]
          %
          % on the hard drive and the zip file. In particular, this assumes
          % that the folder on the hard drive is writable by the user
          % and that matlab2tikz.m is not symlinked from some other place.
          pathstr    = fileparts(mfilename('fullpath'));
          targetPath = fullfile(pathstr, '..', '..');
          
          % Let the user know where the .zip is downloaded to
          if ispc
              printPath = strrep(targetPath,'\','\\');
          else
              printPath = targetPath;
          end
          userInfo(verbose, ['Downloading and unzipping to ''', printPath, ''' ...']);
          
          % Try upgrading
          try
              % List current folder structure. Will use last for cleanup
              currentFolderFiles = rdirfiles(targetPath);
              
              % The FEX now forwards the download request to Github.
              % Go through the forwarding to update the download count and
              % unzip
              html          = urlread([fileExchangeUrl, '?download=true']);
              expression    = '(?<=\<a href=")[\w\-\/:\.]+(?=">redirected)';
              url           = regexp(html, expression,'match','once');
              unzippedFiles = unzip(url, targetPath);
              
              % The folder structure is additionally packed into the 
              % 'MATLAB Search Path' folder defined in FEX. Retrieve the 
              % top folder name
              tmp          = strrep(unzippedFiles,[targetPath, filesep],'');
              tmp          = regexp(tmp, filesep,'split','once');
              tmp          = cat(1,tmp{:});
              topZipFolder = unique(tmp(:,1));
              
              % If packed into the top folder, overwrite files into m2t
              % main directory
              if numel(topZipFolder) == 1
                  unzippedFilesTarget = fullfile(targetPath, tmp(:,2));
                  for ii = 1:numel(unzippedFiles)
                      movefile(unzippedFiles{ii}, unzippedFilesTarget{ii})
                  end
                  % Add topZipFolder to current folder structure
                  currentFolderFiles = [currentFolderFiles; fullfile(targetPath, topZipFolder{1})];
              end
              
              % Cleanup
              newFolderStructure = [getFolders(unzippedFilesTarget);  unzippedFilesTarget];
              deleteFolderFiles  = setdiff(currentFolderFiles, newFolderStructure);
              for ii = 1:numel(deleteFolderFiles)
                  x = deleteFolderFiles{ii};
                  if exist(x, 'file')
                      delete(x);
                  elseif exist(x, 'dir')
                      rmdir(x,'s');
                  end
              end
              
              upgradeSuccess = true; %~isempty(unzippedFiles);
              userInfo(verbose, 'UPDATED: the current conversion will be terminated. Please, re-run it.');
          catch
              userInfo(verbose, ['FAILED: continuing with the' name ' conversion.']);
          end
      end
      userInfo(verbose, '');
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
function list = rdirfiles(rootdir)
  % Recursive files listing
  s    = dir(rootdir);
  list = {s.name}';
  
  % Exclude .git, .svn, . and ..
  [list, idx] = setdiff(list, {'.git','.svn','.','..'});
  
  % Add root
  list = fullfile(rootdir, list);
  
  % Loop for sub-directories
  pdir = find([s(idx).isdir]);
  for ii = pdir
      list = [list; rdirfiles(list{ii})]; %#ok<AGROW>
  end
  
  % Drop directories
  list(pdir) = [];
end
% =========================================================================
function list = getFolders(list) 
  % Extract the folder structure from a list of files and folders
  
  for ii = 1:numel(list)
      if exist(list{ii},'file') == 2
          list{ii} = fileparts(list{ii});
      end
  end
  list = unique(list);
end
% =========================================================================
