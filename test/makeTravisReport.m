function makeTravisReport(status)
% make a readable Travis report    
stdout = 1;
fprintf(stdout,'\n\n');
for iTest = 1:numel(status)
    S = status{iTest};
    testNumber = S.index;
    summary = '';
    if S.skip
        summary = 'SKIPPED';
    else
        stages = getStagesFromStatus(S);
        for jStage = 1:numel(stages)
            thisStage = S.(stages{jStage});
            if ~thisStage.error
                continue;
            end
            stageName = strrep(stages{jStage},'Stage','');
            switch stageName
                case 'plot'
                    summary = sprintf('%s plot failed', summary);
                case 'tikz'
                    summary = sprintf('%s m2t failed', summary);
                case 'hash'
                    summary = sprintf('hash %32s != (%32s) %s', ...
                        thisStage.found, thisStage.expected, summary);
                otherwise
                    summary = sprintf('%s %s FAILED', summary, thisStage);
            end
        end
        if isempty(summary)
            summary = 'OK';
        end
        summary = strtrim(summary);
    end
    functionName = strjust(sprintf('%25s', S.function), 'left');
    fprintf(stdout, 'Test %3d %s: %s\n', testNumber, functionName, summary);
end
    nErrors = countNumberOfErrors(status);
    if nErrors > 0
        fprintf(stdout,'\n%3d of %3d tests failed\n', nErrors, numel(status));
    end
end
