function hashTable = loadHashTable(suite)
    % loads a reference hash table from disk
    hashTable.suite = suite;
    hashTable.contents = struct();
    filename = hashTableName(suite);
    if exist(filename, 'file')
        fid = fopen(filename, 'r');
        finally_fclose_fid = onCleanup(@() fclose(fid));

        data = textscan(fid, '%s : %s');
        if ~isempty(data) && ~all(cellfun(@isempty, data))
            functions = cellfun(@strtrim, data{1},'UniformOutput', false);
            hashes    = cellfun(@strtrim, data{2},'UniformOutput', false);
            for iFunc = 1:numel(functions)
                hashTable.contents.(functions{iFunc}) = hashes{iFunc};
            end
        end
    end
end
