function nErrors = makeTravisReport(status)
% make a readable Travis report
    stdout = 1;

    [reliableTests, unreliableTests] = splitUnreliableTests(status);

    if ~isempty(unreliableTests)
        fprintf(stdout, gfmHeader('Unreliable tests',2));
        fprintf(stdout, 'These do not cause the build to fail.\n\n');
        displayTestResults(stdout, unreliableTests);
    end
    
    fprintf(stdout, gfmHeader('Reliable tests',2));
    fprintf(stdout, 'Only the following tests determine the build outcome.\n\n');
    [passed,failed,skipped] = splitPassFailSkippedTests(reliableTests); %#ok
    displayTestResults(stdout, [failed;skipped]);
    
    displayTestSummary(stdout, status);

    if nargout == 0
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
    nCols = size(data, 2);
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
function str = gfmCode(str, inline, language)
    % Constructs a GFM code fragment
    %
    % Arguments:
    %   - str: code to be displayed
    %   - inline:  - true  -> formats inline
    %              - false -> formats as code block
    %              - []    -> automatic mode (default): picks one of the above
    %   - language: which language the code is (enforces a code block)
    % 
    % Output: GFM formatted string
    if ~exist('inline','var')
        inline = [];
    end
    if ~exist('language','var') || isempty(language)
        language = '';
    else
        inline = false; % highlighting is not supported for inline code
    end
    if isempty(inline)
        inline = isempty(strfind(str, sprintf('\n')));
    end
    
    if inline
        prefix = '`';
        postfix = '`';
    else
        prefix = sprintf('\n```%s\n', language);
        postfix = sprintf('\n```\n');
    end
    
    str = sprintf('%s%s%s', prefix, str, postfix);
end
function str = gfmHeader(str, level)
    if ~exist('level','var')
        level = 1;
    end
    str = sprintf('\n%s %s\n', repmat('#', 1, level), str);
end
% ==============================================================================
function displayTestResults(stream, status)
    % display a table of specific test outcomes
    headers = {'Testcase', 'Name', 'OK', 'Status'};
    data = cell(numel(status), numel(headers));
    for iTest = 1:numel(status)
        data(iTest,:) = fillTestOutcomeRow(status{iTest});
    end
    str = gfmTable(data, headers, 'llcl');
    fprintf(stream, '%s', str);
end
% ==============================================================================
function displayTestSummary(stream, status)
    % display a table of # of failed/passed/skipped tests vs (un)reliable
    
    % split statuses
    [reliable, unreliable] = splitUnreliableTests(status);
    [passR, failR, skipR] = splitPassFailSkippedTests(  reliable);
    [passU, failU, skipU] = splitPassFailSkippedTests(unreliable);
    
    % compute number of cases per category
    reliableSummary   = cellfun(@numel, {passR, failR, skipR});
    unreliableSummary = cellfun(@numel, {passU, failU, skipU});
    
    % make summary table + calculate totals
    summary = [  reliableSummary                 numel(reliable);
               unreliableSummary                 numel(unreliable);
               reliableSummary+unreliableSummary numel(status)];
           
    % put results into cell array with proper layout
    summary = arrayfun(@(v) sprintf('%d',v), summary, 'UniformOutput', false);
    table = repmat({''}, 3, 5);
    header = {'','Pass','Fail','Skip','Total'};
    table(:,1) = {'Reliable','Unreliable','Total'};
    table(:,2:end) = summary;
    
    % print table
    fprintf(stream, '%s\n', gfmHeader('Test summary', 2));
    fprintf(stream, gfmTable(table, header, 'lrrrr'));
    
    % print overall outcome
    if numel(failR) == 0
        fprintf(stream, '\nBuild passes. :heavy_check_mark:\n');
    else
        fprintf(stream, '\nBuild fails with %d errors. :heavy_exclamation_mark:\n', nErrors);
    end
end
% ==============================================================================
function row = fillTestOutcomeRow(oneStatus)
    % format the status of a single test for the summary table
    testNumber = oneStatus.index;
    testSuite  = func2str(oneStatus.testsuite);
    summary = '';
    if oneStatus.skip
        summary = 'SKIPPED';
        passOrFail = ':grey_question:';
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
            passOrFail = ':heavy_check_mark:';
        else
            passOrFail = ':heavy_exclamation_mark:';
        end
        summary = strtrim(summary);
    end
    row = { gfmCode(sprintf('%s(%d)', testSuite, testNumber)), ...
            gfmCode(oneStatus.function), ...
            passOrFail, ...
            summary};
end
% ==============================================================================
