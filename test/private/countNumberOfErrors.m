function nErrors = countNumberOfErrors(status)
% counts the number of errors in a status cell array
    nErrors = sum(hasTestFailed(status));
end
