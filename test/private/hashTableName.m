function filename = hashTableName(suite)
    % determines the file name of a hash table
    %
    % The MD5 file is assumed to be in the same directory as the test suite.
    % It has a file name "$SUITE.$ENV.$VER.md5"
    % where the following fields are filled:
    %   $ENV: the environment (either "MATLAB" or "Octave")
    %   $VER: the version (e.g. "3.8.0" for Octave, "8.3" for MATLAB 2014a)
    %   $SUITE: the name (and path) of the test suite
    %
    % For the $VER-part, a fall-back mechanism is present that prefers the exact
    % version but will use the closest available file if such file does not
    % exist.
    [pathstr,name, ext] = fileparts(which(func2str(suite)));
    [env, version] = getEnvironment();
    ext = sprintf('.%s.%s.md5', env, version);
    relFilename = [name ext];
    filename = fullfile(pathstr, relFilename);

    if ~exist(filename,'file')
        % To avoid having to create a file for each release of the environment,
        % also other versions are tried. The file for different releases are checked
        % in the following order:
        %   1. the currently running version (handled above!)
        %   2. the newest older version (e.g. use R2014b's file in R2015a)
        %   3. the oldest newer version (e.g. use R2014a's file in R2013a)
        pattern = sprintf('%s.%s.*.md5', name, env);
        candidates = dir(fullfile(pathstr, pattern));

        % We just need the file names.
        filenames = arrayfun(@(c)c.name, candidates, 'UniformOutput', false);

        % Add the expected version to the results, and sort the names by
        % version (this is the same as alphabetically).
        filenames = sort([filenames; {relFilename}]);
        nFiles       = numel(filenames);
        iCurrent     = find(ismember(filenames, relFilename));
        % determine the fall-back candidates:
        iNewestOlder = iCurrent - 1;
        iOldestNewer = iCurrent + 1;

        inRange = @(idx)(idx <= nFiles && idx >= 1);
        if inRange(iNewestOlder)
            % use the newest older version
            relFilename = filenames{iNewestOlder};
        elseif inRange(iOldestNewer)
            % use the oldest newer version
            relFilename = filenames{iOldestNewer};
        else
            % use the exact version anyhow
        end

        filename = fullfile(pathstr, relFilename);
    end
end
