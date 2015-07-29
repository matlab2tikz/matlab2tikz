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
function str = gfmTable(data, header, alignment)
    % Construct a Github-flavored Markdown table
    %
    % Arguments:
    %   - data: nRows x nCols cell array that represents the data
    %   - header: cell array with the (nCol) column headers
    %   - alignment: alignment specification per column
    %       * 'l': left-aligned (default)
    %       * 'c': centered
    %       * 'r': right-aligned
    %     When not enough entries are specified, the specification is repeated
    %     cyclically.
    %
    % Output: table as a string
    %
    % See https://help.github.com/articles/github-flavored-markdown/#tables

    % input argument validation and normalization
    [nRows, nCols] = size(data);
    if ~exist('alignment','var') || isempty(alignment)
        alignment = 'l';
    end
    if numel(alignment) < nCols
        % repeat the alignment specifications to along the columns
        alignment = repmat(alignment, 1, nCols);
        alignment = alignment(1:nCols);
    end

    % calculate the required column width
    cellWidth   = cellfun(@length, [header(:)' ;data]);
    columnWidth = max(max(cellWidth, [], 1),3); % use at least 3 places

    % prepare the table format
    COLSEP = '|'; ROWSEP = sprintf('\n');
    rowformat = [COLSEP sprintf([' %%%ds ' COLSEP], columnWidth) ROWSEP];
    alignmentRow = formatAlignment(alignment, columnWidth);

    % actually print the table
    fullTable = [header; alignmentRow; data];
    strs = cell(size(fullTable,1), 1);
    for iRow = 1:numel(strs)
        thisRow = fullTable(iRow,:);
        %TODO: maybe preprocess thisRow with strjust first
        strs{iRow} = sprintf(rowformat, thisRow{:});
    end
    str = [strs{:}];
    function alignRow = formatAlignment(alignment, columnWidth)
        DASH = '-'; COLON = ':';
        N = numel(columnWidth);
        alignRow = arrayfun(@(w) repmat(DASH, 1, w), columnWidth, ...
                        'UniformOutput', false);
        for iColumn = 1:N
            thisAlign = alignment(iColumn);
            thisSpec = alignRow{iColumn};
            switch lower(thisAlign)
                case 'l'
                    thisSpec(1) = COLON;
                case 'r'
                    thisSpec(end) = COLON;
                case 'c'
                    thisSpec([1 end]) = COLON;
                otherwise
                    error('gfmTable:BadAlignment','Unknown alignment "%s"',...
                          thisAlign);
            end
            alignRow{iColumn} = thisSpec;
        end
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
