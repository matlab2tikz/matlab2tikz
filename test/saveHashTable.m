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

    % sort by file names to allow humans better traversal of such files
    funcNames = cellfun(@(s) s.function, status, 'UniformOutput', false);
    [dummy, iSorted] = sort(funcNames); %#ok
    status = status(iSorted);

    % write to file
    fid = fopen(filename,'w+');
    for iFunc = 1:numel(status)
        S = status{iFunc};
        thisFunc = S.function;
        if isfield(S.hashStage,'found')
            thisHash = S.hashStage.found;
        else
            thisHash = ''; % FIXME: when does this happen??
        end
        if ~isempty(thisHash)
            fprintf(fid, '%s : %s\n', thisFunc, thisHash);
        end
    end
    fclose(fid);
end
