function nErrors = makeTravisReport(status)
% make a readable Travis report
    stdout = 1;

    [reliableTests, unreliableTests] = splitUnreliableTests(status);

    if ~isempty(unreliableTests)
        fprintf(stdout, ...
                ['\nThe following tests are known to be unreliable. ' ...
                 'They, however, do not cause the build to fail.\n\n']);
        displaySummaryTable(stdout, unreliableTests);
        fprintf(stdout, ...
                '\n\nOnly the following tests determine the build outcome:\n');
    end
    displaySummaryTable(stdout, reliableTests);

    if nargout >= 1
        nErrors = countNumberOfErrors(reliableTests);
    end
end
% ==============================================================================
function displaySummaryTable(stream, status)
    % display a summary table of all tests
    for iTest = 1:numel(status)
        fprintf(stream, '%s\n', formatSummaryRow(status{iTest}));
    end

    nErrors = countNumberOfErrors(status);
    if nErrors > 0
        fprintf(stream,'\n%3d of %3d tests failed. :-( \n', nErrors, numel(status));
    else
        fprintf(stream,'\nAll tests were successful. :-) \n');
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
