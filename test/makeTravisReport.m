function makeTravisReport(status)
% make a readable Travis report    
stdout = 1;
fprintf(stdout,'\n\n');

    displayDetailsOnFailure(stdout, status);
    displaySummaryTable(stdout, status);
end
% ==============================================================================
function displayDetailsOnFailure(stream, status)
    %FIXME: echo a file when an error has occurred
end
% ==============================================================================
function displaySummaryTable(stream, status)
    % display a summary table
    for iTest = 1:numel(status)
        fprintf(stream, '%s\n', formatSummaryRow(status{iTest}));
    end
    
    nErrors = countNumberOfErrors(status);
    if nErrors > 0
        fprintf(stream,'\n%3d of %3d tests failed\n', nErrors, numel(status));
    end
end
% ==============================================================================
function str = formatSummaryRow(oneStatus)
    % format the status of a single test for the summary table
    testNumber = oneStatus.index;
    testSuite  = func2str(oneStatus.testsuite);
    summary = '';
    if oneStatus.skip
        summary = 'SKIPPED';
    else
        stages = getStagesFromStatus(oneStatus);
        for jStage = 1:numel(stages)
            thisStage = oneStatus.(stages{jStage});
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
    functionName = strjust(sprintf('%25s', oneStatus.function), 'left');
    
    str = sprintf('%15s(%3d) %s: %s', ...
          testSuite, testNumber, functionName, summary);
end
% ==============================================================================