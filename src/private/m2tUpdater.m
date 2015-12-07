function m2tUpdater(about, verbose)
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
  fileExchangeUrl = about.website;
  version = about.version;

  mostRecentVersion = determineLatestRelease(version, fileExchangeUrl);
  if askToUpgrade(mostRecentVersion, version, verbose)
      tryToUpgrade(fileExchangeUrl, verbose);
      userInfo(verbose, '');
  end
end
% ==============================================================================
function shouldUpgrade = askToUpgrade(mostRecentVersion, version, verbose)
  shouldUpgrade = false;
  if ~isempty(mostRecentVersion)
      userInfo(verbose, '**********************************************\n');
      userInfo(verbose, 'New version (%s) available!\n', mostRecentVersion);
      userInfo(verbose, '**********************************************\n');

      warnAboutUpgradeImplications(version, mostRecentVersion, verbose);
      askToShowChangelog(version);
      reply = input(' *** Would you like to upgrade? y/n [n]:','s');
      shouldUpgrade = ~isempty(reply) && strcmpi(reply(1),'y');
      if ~shouldUpgrade
        userInfo(verbose, ['\nTo disable the self-updater in the future, add ' ...
                           '"''checkForUpdates'',false" to the parameters.\n'] );
      end
  end
end
% ==============================================================================
function tryToUpgrade(fileExchangeUrl, verbose)
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
  userInfo(verbose, 'Downloading and unzipping to ''%s'' ...', targetPath);

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

      cleanupOldFiles(currentFolderFiles, unzippedFilesTarget);

      userInfo(verbose, 'Upgrade has completed successfully.');
  catch
      err = lasterror(); %#ok needed for Octave
      
      userInfo(verbose, ...
               ['Upgrade has failed with error message "%s".\n', ...
                'Please install the latest version manually from %s !'], ...
                err.message, fileExchangeUrl);
  end
end
% ==============================================================================
function cleanupOldFiles(currentFolderFiles, unzippedFilesTarget)
% Delete files that were there in the old folder, but that are no longer
% present in the new release.
    newFolderStructure = [getFolders(unzippedFilesTarget);  unzippedFilesTarget];
    deleteFolderFiles  = setdiff(currentFolderFiles, newFolderStructure);
    for ii = 1:numel(deleteFolderFiles)
        x = deleteFolderFiles{ii};
        if exist(x, 'dir') == 7
            % First check for directories since
            % `exist(x, 'file')` also checks for directories!
            rmdir(x,'s');
        elseif exist(x, 'file') == 2
            delete(x);
        end
    end
end
% ==============================================================================
function mostRecentVersion = determineLatestRelease(version, fileExchangeUrl)
  % Read in the Github releases page
  url = 'https://github.com/matlab2tikz/matlab2tikz/releases/';
  try
      html = urlread(url);
  catch %#ok
      % Couldn't load the URL -- never mind.
      html = '';
      warning('m2tUpdate:siteNotFound', ...
              ['Cannot determine the latest version.\n', ...
               'Either your internet is down or something went wrong.\n', ...
               'You might want to check for updates by hand at %s.\n'], ...
               fileExchangeUrl);
  end

  % Parse tag names which are the version number in the format ##.##.##
  % It assumes that releases will always be tagged with the version number
  expression = '(?<=matlab2tikz\/matlab2tikz\/releases\/tag\/)\d+\.\d+\.\d+';
  tags       = regexp(html, expression, 'match');
  ntags      = numel(tags);

  % Keep only new releases
  inew = false(ntags,1);
  for ii = 1:ntags
      inew(ii) = isVersionBelow(version, tags{ii});
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
          tagnum(ii) = [10000,100,1] * versionArray(tags{ii});
      end
      [~, imax]         = max(tagnum);
      mostRecentVersion = tags{imax};
  % No new
  else
      mostRecentVersion = '';
  end
end
% ==============================================================================
function askToShowChangelog(currentVersion)
% Asks whether the user wants to see the changelog and then shows it.
    reply = input(' *** Would you like to see the changelog? y/n [y]:' ,'s');
    shouldShow =  isempty(reply) || ~strcmpi(reply(1),'n') ;
    if shouldShow
        fprintf(1, '\n%s\n', changelogUntilVersion(currentVersion));
    end
end
% ==============================================================================
function changelog = changelogUntilVersion(currentVersion)
% This function retrieves the chunk of the changelog until the current version.
    URL = 'https://github.com/matlab2tikz/matlab2tikz/raw/master/CHANGELOG.md';
    changelog = urlread(URL);
    currentVersion = versionString(currentVersion);

    % Header is "# YYYY-MM-DD Version major.minor.patch [Manager](email)"
    % Just match for the part until the version number. Here, we're actually
    % matching a tiny bit too broad due to the periods in the version number
    % but the outcome should be the same if we keep the changelog format
    % identical.
    pattern = ['\#\s*[\d-]+\s*Version\s*' currentVersion];
    idxVersion = regexpi(changelog, pattern);
    if ~isempty(idxVersion)
        changelog = changelog(1:idxVersion-1);
    else
        % Just show the whole changelog if we don't find the old version.
    end
    changelog = replaceIssuesWithUrls(changelog);
end
% ==============================================================================
function changelog = replaceIssuesWithUrls(changelog)
% Replaces GitHub issues ("#...") with URLs
    baseurl = 'https://github.com/matlab2tikz/matlab2tikz/issues/';
    if strcmpi(getEnvironment(), 'MATLAB')
        replacement = sprintf('<a href="%s$1">#$1</a>', baseurl);
        changelog = regexprep(changelog, '\#(\d+)', replacement);
    end
end
% ==============================================================================
function warnAboutUpgradeImplications(currentVersion, latestVersion, verbose)
% This warns the user about the implications of upgrading as dictated by
% Semantic Versioning.
    switch upgradeSize(currentVersion, latestVersion);
        case 'major'
          % The API might have changed in a backwards incompatible way.
          userInfo(verbose, 'This is a MAJOR upgrade!\n');
          userInfo(verbose, ' - New features may have been introduced.');
          userInfo(verbose, ' - Some old code/options may no longer work!\n');

        case 'minor'
          % The API may NOT have changed in a backwards incompatible way.
          userInfo(verbose, 'This is a MINOR upgrade.\n');
          userInfo(verbose, ' - New features may have been introduced.');
          userInfo(verbose, ' - Some options may have been deprecated.');
          userInfo(verbose, ' - Old code should continue to work but might produce warnings.\n');

        case 'patch'
          % No new functionality is introduced
          userInfo(verbose, 'This is a PATCH.\n');
          userInfo(verbose, ' - Only bug fixes are included in this upgrade.');
          userInfo(verbose, ' - Old code should continue to work as before.')
    end
    userInfo(verbose, 'Please check the changelog for detailed information.\n');
    userWarn(verbose, '\n!! By upgrading you will lose any custom changes !!\n');
end
% ==============================================================================
function cls = upgradeSize(currentVersion, latestVersion)
% Determines whether the upgrade is major, minor or a patch.
    currentVersion = versionArray(currentVersion);
    latestVersion = versionArray(latestVersion);
    description = {'major', 'minor', 'patch'};
    for ii = 1:numel(description)
        if latestVersion(ii) > currentVersion(ii)
            cls = description{ii};
            return
        end
    end
    cls = 'unknown';
end
% ==============================================================================
function userInfo(verbose, message, varargin)
    % Display information (i.e. to stdout)
    if verbose
        userPrint(1, message, varargin{:});
    end
end
function userWarn(verbose, message, varargin)
    % Display warnings (i.e. to stderr)
    if verbose
        userPrint(2, message, varargin{:});
    end
end
function userPrint(fid, message, varargin)
    % Print messages (info/warnings) to a stream/file.
    mess = sprintf(message, varargin{:});
    
    % Replace '\n' by '\n *** ' and print.
    mess = strrep( mess, sprintf('\n'), sprintf('\n *** ') );
    fprintf(fid, ' *** %s\n', mess );
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
