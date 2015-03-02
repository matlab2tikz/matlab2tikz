function errorOccurred = errorHasOccurred(status)
% determines whether an error has occurred from a status struct OR cell array
% of status structs
    errorOccurred = false;
    if iscell(status)
        for iStatus = 1:numel(status)
            errorOccurred = errorOccurred || errorHasOccurred(status{iStatus});
        end
    else
        stages = getStagesFromStatus(status);
        for iStage = 1:numel(stages)
            thisStage = status.(stages{iStage});
            errorOccurred = errorOccurred || thisStage.error;
        end
    end
end
