function saveHashTable(status, ipp)
    % saves a reference hash table to disk
    suite = ipp.Results.testsuite;
    filename = hashTableName(suite);
    
    % sort by file names to allow humans better traversal of such files
    funcNames = cellfun(@(s) s.function, status, 'UniformOutput', false);
    [dummy, iSorted] = sort(funcNames);
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
