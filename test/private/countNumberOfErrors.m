function nErrors = countNumberOfErrors(status)
% counts the number of errors in a status cell array
    nErrors = 0;
    % probably this can be done more compactly using cellfun, etc.
    for iTest = 1:numel(status)
        S = status{iTest};
        stages = getStagesFromStatus(S);
        errorInThisTest = false;
        for jStage = 1:numel(stages)
            errorInThisTest = errorInThisTest || S.(stages{jStage}).error;
        end
        if errorInThisTest
            nErrors = nErrors + 1;
        end
    end
end
