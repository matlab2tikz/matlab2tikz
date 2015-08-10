function saveHashTable(status)
% SAVEHASHTABLE saves the references hashes for the Matlab2Tikz tests
%
% Usage:
%  SAVEHASHTABLE(status)
%
% Inputs:
%   - status: output cell array of the testing functions
%
% See also: runMatlab2TikzTests, testMatlab2tikz
    suite = status{1}.testsuite; %TODO: handle multiple test suites in a single array
    filename = hashTableName(suite);
    FILEFORMAT = '%s : %s\n';
    oldHashes = readHashesFromFile(filename);

    % sort by file names to allow humans better traversal of such files
    funcNames = cellfun(@(s) s.function, status, 'UniformOutput', false);
    [dummy, iSorted] = sort(funcNames); %#ok
    status = status(iSorted);

    % write to file
    fid = fopen(filename,'w+');
    finally_fclose_fid = onCleanup(@() fclose(fid));

    for iFunc = 1:numel(status)
        S = status{iFunc};
        thisFunc = S.function;
        if isfield(S.hashStage,'found')
            thisHash = S.hashStage.found;
        else
            warning('SaveHashTable:NoHashFound',...
                    'No hash found for "%s". Assuming empty.', S.function);
            thisHash = ''; % FIXME: when does this happen??
        end
        if ~isempty(thisHash)
            fprintf(fid, FILEFORMAT, thisFunc, thisHash);
        end
    end
    function hashes = readHashesFromFile(filename)
        if exist(filename','file')
            fid = fopen(filename, 'r');
            closeFileAfterwards = onCleanup(@() fclose(fid));

            data = textscan(fid, FILEFORMAT);
            % data is now a cell array with 2 elements, each a (row) cell array
            %  - the first is all the function names
            %  - the second is all the hashes

            % Transform `data` into {function1, hash1, function2, hash2, ...}'
            % First step is to transpose the data concatenate both fields under
            % each other. Since MATLAB indexing uses "column major order",
            % traversing the concatenated array is in the order we want.
            dataTransposed = cellfun(@transpose, data, 'UniformOutput', false);
            allValues = vertcat(dataTransposed{:});
        else
            allValues = {};
        end
        hashes = struct(allValues{:});
    end
end

