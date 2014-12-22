function makeTravisReport(status)
% make a readable Travis report
    stdout = 1;

    displayDetailsOnFailure(stdout, status);
    displaySummaryTable(stdout, status);
end
% ==============================================================================
function displayDetailsOnFailure(stream, status)
    % for each test case, it output the generated output when failures are
    % detected
    didOutput = false;
    for iTest = 1:numel(status)
        stat = status{iTest};
        if errorHasOccurred(stat)
            didOutput = true;
            fprintf(stream, '\n%s(%d): %s failed\n', ...
                    func2str(stat.testsuite), stat.index, stat.function);
            displayOutputFile(stream, stat);
        end
    end
    if didOutput
        fprintf(stream, '\n\n');
    end
end
% ==============================================================================
function displayOutputFile(stream, stat)
    % display a (generated TikZ) file if it exists
    filename = stat.tikzStage.texFile;
    if exist(filename, 'file')
        fprintf(stream, '\n%%%%%%%% BEGIN FILE "%s" %%%%%%%%\n', filename);
        type(filename); %NOTE: better read and output to the stream
        fprintf(stream, '\n%%%%%%%% END   FILE "%s" %%%%%%%%\n', filename);
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