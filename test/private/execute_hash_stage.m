function [status] = execute_hash_stage(status, ipp)
    % test stage: check recorded hash checksum
    calculated = '';
    expected = '';
    try
        expected = getReferenceHash(status, ipp);
        calculated = calculateMD5Hash(status.tikzStage.texFile);

        % do the actual check
        if ~strcmpi(expected, calculated)
            % throw an error to signal the testing framework
            error('testMatlab2tikz:HashMismatch', ...
                'The hash "%s" does not match the reference hash "%s"', ...
                calculated, expected);
        end
    catch %#ok
        e = lasterror('reset'); %#ok
        [status.hashStage] = errorHandler(e);
    end
    status.hashStage.expected = expected;
    status.hashStage.found    = calculated;
end
% ==============================================================================
function hash = getReferenceHash(status, ipp)
    % retrieves a reference hash from a hash table
    % WARNING: do not make `hashTable` persistent, since this is slower

    hashTable = loadHashTable(ipp.Results.testsuite);
    if isfield(hashTable.contents, status.function)
        hash = hashTable.contents.(status.function);
    else
        hash = '';
    end
end
