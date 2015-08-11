function bool = hasTestFailed(status)
    % returns true when the test has failed

    if iscell(status) % allow for vectorization of the call
        bool = cellfun(@hasTestFailed, status, 'UniformOutput', true);
    else
        stages = getStagesFromStatus(status);
        bool = false;
        for jStage = 1:numel(stages)
            bool = bool || status.(stages{jStage}).error;
        end
    end
end
