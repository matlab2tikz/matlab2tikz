function saveHashTable(status, varargin)
% SAVEHASHTABLE saves the references hashes for the Matlab2Tikz tests
%
% Usage:
%  SAVEHASHTABLE(status)
%
%  SAVEHASHTABLE(status, 'dryrun', BOOL, ...) determines whether or not to
%  write the constructed hash table to file (false) or to stdout (true).
%  Default: false
%
%  SAVEHASHTABLE(status, 'removedTests', CHAR, ...) specifies which action to
%  execute on "removed tests" (i.e. test that have a hash recorded in the file,
%  but which are not present in `status`). Three values are possible:
%   - 'ask' (default): Ask what to do for each such test.
%   - 'remove': Remove the test from the file.
%               This is appropriate if the test has been removed from the suite.
%   - 'keep': Keep the test hash in the file.
%             This is appropriate when the test has not executed all tests.
%
% Inputs:
%   - status: output cell array of the testing functions
%
% See also: runMatlab2TikzTests, testMatlab2tikz
    ipp = m2tInputParser();
    ipp = ipp.addRequired(ipp, 'status', @iscell);
    ipp = ipp.addParamValue(ipp, 'dryrun', false, @islogical);
    ipp = ipp.addParamValue(ipp, 'removedTests', 'ask', @isValidAction);
    ipp = ipp.parse(ipp, status, varargin{:});

    %% settings
    suite = status{1}.testsuite; %TODO: handle multiple test suites in a single array
    filename = hashTableName(suite);
    READFORMAT = '%s : %s';
    WRITEFORMAT = [READFORMAT '\n'];

    %% process the hash table
    oldHashes = readHashesFromFile(filename);
    newHashes = updateHashesFromStatus(oldHashes, status);
    writeHashesToFile(filename, newHashes);

    % --------------------------------------------------------------------------
    function hashes = updateHashesFromStatus(hashes, status)
        % update hashes from the test results in status
        oldFunctions = fieldnames(hashes);
        newFunctions = cellfun(@(s) s.function, status, 'UniformOutput', false);

        % add hashes from all executed tests
        for iFunc = 1:numel(status)
            S = status{iFunc};
            thisFunc = S.function;
            thisHash = '';
            if isfield(S.hashStage,'found')
                thisHash = S.hashStage.found;
            elseif S.skip
                if isfield(hashes, thisFunc)
                    % Test skipped, but reference hash present in file
                    % Probably this means that the developer doesn't have access
                    % to a certain toolbox.
                    warning('SaveHashTable:CannotUpdateSkippedTest', ...
                            'Test "%s" was skipped. Cannot update hash!',...
                            thisFunc);
                else
                    % Test skipped and reference hash absent.
                    % Probably the test is skipped because something is tested
                    % that relies on HG1/HG2/Octace-specific features and we are
                    % in the wrong environment for the test.
                end
            else
                warning('SaveHashTable:NoHashFound',...
                        'No hash found for "%s"!', thisFunc);
            end
            if ~isempty(thisHash)
                hashes.(thisFunc) = thisHash;
            end
        end

        % ask what to do with tests for which we have a hash, but no test results
        removedTests = setdiff(oldFunctions, newFunctions);
        if ~isempty(removedTests)
            fprintf(1, 'Some tests in the file were not in the build status.\n');
        end
        for iTest = 1:numel(removedTests)
            thisTest = removedTests{iTest};

            action = askActionToPerformOnRemovedTest(thisTest);
            switch action
                case 'remove'
                    % useful for test that no longer exist
                    fprintf(1, 'Removed hash for "%s"\n', thisTest);
                    hashes = rmfield(hashes, thisTest);

                case 'keep'
                    % useful when not all tests were executed by the tester
                    fprintf(1, 'Kept hash for "%s"\n', thisTest);

            end
        end
    end
    function action = askActionToPerformOnRemovedTest(testName)
        % ask which action to carry out on a removed test
        action = lower(ipp.Results.removedTests);
        while ~isActualAction(action)
            query = sprintf('Keep or remove "%s"? [Kr]:', testName);
            answer = strtrim(input(query,'s'));

            if isempty(answer) || strcmpi(answer(1), 'K')
                action = 'keep';
            elseif strcmpi(answer(1), 'R')
                action = 'remove';
            else
                action = 'ask again';
                % just keep asking until we get a reasonable answer
            end
        end
    end
    function writeHashesToFile(filename, hashes)
        % write hashes to a file (or stdout when dry-running)
        if ~ipp.Results.dryrun
            fid = fopen(filename, 'w+');
            finally_fclose_fid = onCleanup(@() fclose(fid));
        else
            fid = 1; % Use stdout to print everything
            fprintf(fid, '\n\n Output: \n\n');
        end

        funcNames = sort(fieldnames(hashes));
        for iFunc = 1:numel(funcNames)
            func = funcNames{iFunc};
            fprintf(fid, WRITEFORMAT, func, hashes.(func));
        end
    end
    function hashes = readHashesFromFile(filename)
        % read hashes from a file
        if exist(filename,'file')
            fid = fopen(filename, 'r');
            finally_fclose_fid = onCleanup(@() fclose(fid));

            data = textscan(fid, READFORMAT);
            % data is now a cell array with 2 elements, each a (row) cell array
            %  - the first is all the function names
            %  - the second is all the hashes

            % Transform `data` into {function1, hash1, function2, hash2, ...}'
            % First step is to transpose the data concatenate both fields under
            % each other. Since MATLAB indexing uses "column major order",
            % traversing the concatenated array is in the order we want.
            data      = [data{:}]';
            allValues = data(:)';
        else
            allValues = {};
        end
        hashes = struct(allValues{:});
    end
end
% ==============================================================================
function bool = isValidAction(str)
    % returns true for valid actions (keep/remove/ask) on "removedTests":
    bool = ismember(lower(str), {'keep','remove','ask'});
end
function bool = isActualAction(str)
    % returns true for actual actions (keep/remove) on "removedTests"
    bool = ismember(lower(str), {'keep','remove'});
end
% ==============================================================================
