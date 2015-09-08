function [nErrors] = makeTravisReport(status, varargin)
% Makes a readable report for Travis/Github of test results
%
% This function produces a testing report of HEADLESS tests for
% display on GitHub and Travis.
%
% MAKETRAVISREPORT(status) produces the report from the `status` output of
% `testHeadless`.
%
% MAKETRAVISREPORT(status, 'stream', FID, ...) changes the filestream to use
%  to output the report to. (Default: 1 (stdout)).
%
% MAKETRAVISREPORT(status, 'length', CHAR, ...) changes the report length.
%  A few values are possible that cover different aspects in less/more detail.
%    - 'default': all unreliable tests, failed & skipped tests and summary
%    - 'short'  : only show the brief summary
%    - 'long'   : all tests + summary
%
% See also: testHeadless, makeLatexReport

    SM = StreamMaker();
    %% Parse input arguments
    ipp = m2tInputParser();

    ipp = ipp.addRequired(ipp, 'status', @iscell);
    ipp = ipp.addParamValue(ipp, 'stream', 1,  SM.isStream);
    ipp = ipp.addParamValue(ipp, 'length', 'default', @isReportLength);

    ipp = ipp.parse(ipp, status, varargin{:});
    arg = ipp.Results;
    arg.length = lower(arg.length);
    stream = SM.make(arg.stream, 'w');

    %% transform status data into groups
    S = splitStatuses(status);

    %% build report
    stream.print(gfmHeader(describeEnvironment));
    reportUnreliableTests(stream, arg, S);
    reportReliableTests(stream, arg, S);
    displayTestSummary(stream, S);

    %% set output arguments if needed
    if nargout >= 1
        nErrors = countNumberOfErrors(S.reliable);
    end
end
% == INPUT VALIDATOR FUNCTIONS =================================================
function bool = isReportLength(val)
    % validates the report length
    bool = ismember(lower(val), {'default','short','long'});
end
% == GITHUB-FLAVORED MARKDOWN FUNCTIONS ========================================
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
        % repeat the alignment specifications along the columns
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

    %---------------------------------------------------------------------------
    function alignRow = formatAlignment(alignment, columnWidth)
        % Construct a row of dashes to specify the alignment of each column
        % See https://help.github.com/articles/github-flavored-markdown/#tables
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
    % Construct a GFM code fragment
    %
    % Arguments:
    %   - str: code to be displayed
    %   - inline:  - true  -> formats inline
    %              - false -> formats as code block
    %              - []    -> automatic mode (default): picks one of the above
    %   - language: which language the code is (enforces a code block)
    %
    % Output: GFM formatted string
    %
    % See https://help.github.com/articles/github-flavored-markdown
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
        if str(end) == sprintf('\n')
            postfix = postfix(2:end); % remove extra endline
        end
    end

    str = sprintf('%s%s%s', prefix, str, postfix);
end
function str = gfmHeader(str, level)
    % Constructs a GFM/Markdown header
    if ~exist('level','var')
        level = 1;
    end
    str = sprintf('\n%s %s\n', repmat('#', 1, level), str);
end
function symbols = githubEmoji()
    % defines the emojis to signal the test result
    symbols = struct('pass', ':white_check_mark:', ...
                     'fail', ':heavy_exclamation_mark:', ...
                     'skip', ':grey_question:');
end
% ==============================================================================
function S = splitStatuses(status)
    % splits a cell array of statuses into a struct of cell arrays
    % of statuses according to their value of "skip", "reliable" and whether
    % an error has occured.
    % See also: splitUnreliableTests, splitPassFailSkippedTests
    S = struct('all', {status}); % beware of cell array assignment to structs!

    [S.reliable, S.unreliable]  = splitUnreliableTests(status);
    [S.passR, S.failR, S.skipR] = splitPassFailSkippedTests(S.reliable);
    [S.passU, S.failU, S.skipU] = splitPassFailSkippedTests(S.unreliable);
end
% ==============================================================================
function [short, long] = describeEnvironment()
    % describes the environment in a short and long format
    [env, ver] = getEnvironment;
    [dummy, VCID] = VersionControlIdentifier(); %#ok
    if ~isempty(VCID)
        VCID = [' commit ' VCID(1:10)];
    end
    OS = OSVersion;
    short = sprintf('%s %s (%s)', env, ver, OS, VCID);
    long  = sprintf('Test results for m2t%s running with %s %s on %s.', ...
                    VCID, env, ver, OS);
end
% ==============================================================================
function reportUnreliableTests(stream, arg, S)
    % report on the unreliable tests
    if ~isempty(S.unreliable) && ~strcmpi(arg.length, 'short')
        stream.print(gfmHeader('Unreliable tests',2));
        stream.print('These do not cause the build to fail.\n\n');
        displayTestResults(stream, S.unreliable);
    end
end
function reportReliableTests(stream, arg, S)
    % report on the reliable tests
    switch arg.length
        case 'long'
            tests = S.reliable;
            message = '';
        case 'default'
            tests = [S.failR; S.skipR];
            message = 'Passing tests are not shown (only failed and skipped tests).\n\n';
        case 'short'
            return; % don't show this part
    end

    stream.print(gfmHeader('Reliable tests',2));
    stream.print('Only the reliable tests determine the build outcome.\n');
    stream.print(message);
    displayTestResults(stream, tests);
end
% ==============================================================================
function displayTestResults(stream, status)
    % display a table of specific test outcomes
    headers = {'Testcase', 'Name', 'OK', 'Status'};
    data = cell(numel(status), numel(headers));
    symbols = githubEmoji;
    for iTest = 1:numel(status)
        data(iTest,:) = fillTestResultRow(status{iTest}, symbols);
    end
    str = gfmTable(data, headers, 'llcl');
    stream.print('%s', str);
end
function row = fillTestResultRow(oneStatus, symbol)
    % format the status of a single test for the summary table
    testNumber = oneStatus.index;
    testSuite  = func2str(oneStatus.testsuite);
    summary = '';
    if oneStatus.skip
        summary = 'SKIPPED';
        passOrFail = symbol.skip;
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
                    summary = sprintf('new hash %32s != expected (%32s) %s', ...
                        thisStage.found, thisStage.expected, summary);
                otherwise
                    summary = sprintf('%s %s FAILED', summary, thisStage);
            end
        end
        if isempty(summary)
            passOrFail = symbol.pass;
        else
            passOrFail = symbol.fail;
        end
        summary = strtrim(summary);
    end
    row = { gfmCode(sprintf('%s(%d)', testSuite, testNumber)), ...
            gfmCode(oneStatus.function), ...
            passOrFail, ...
            summary};
end
% ==============================================================================
function displayTestSummary(stream, S)
    % display a table of # of failed/passed/skipped tests vs (un)reliable

    % compute number of cases per category
    reliableSummary   = cellfun(@numel, {S.passR, S.failR, S.skipR});
    unreliableSummary = cellfun(@numel, {S.passU, S.failU, S.skipU});

    % make summary table + calculate totals
    summary = [unreliableSummary                 numel(S.unreliable);
                 reliableSummary                 numel(S.reliable);
               reliableSummary+unreliableSummary numel(S.all)];

    % put results into cell array with proper layout
    summary = arrayfun(@(v) sprintf('%d',v), summary, 'UniformOutput', false);
    table = repmat({''}, 3, 5);
    header = {'','Pass','Fail','Skip','Total'};
    table(:,1) = {'Unreliable','Reliable','Total'};
    table(:,2:end) = summary;

    % print table
    [envShort, envDescription] = describeEnvironment(); %#ok
    stream.print(gfmHeader('Test summary', 2));
    stream.print('%s\n', envDescription);
    stream.print('%s\n', gfmCode(generateCode(S),false,'matlab'));
    stream.print(gfmTable(table, header, 'lrrrr'));

    % print overall outcome
    symbol = githubEmoji;
    nErrors = numel(S.failR);
    if nErrors == 0
        stream.print('\nBuild passes. %s\n', symbol.pass);
    else
        stream.print('\nBuild fails with %d errors. %s\n', nErrors, symbol.fail);
    end
end
function code = generateCode(S)
    % generates some MATLAB code to easily replicate the results
    code = sprintf('%s = %s;\n', ...
                   'suite', ['@' func2str(S.all{1}.testsuite)], ...
                   'alltests', testNumbers(S.all), ...
                   'reliable', testNumbers(S.reliable), ...
                   'unreliable', testNumbers(S.unreliable), ...
                   'failReliable', testNumbers(S.failR), ...
                   'passUnreliable', testNumbers(S.passU), ...
                   'skipped', testNumbers([S.skipR; S.skipU]));
    % --------------------------------------------------------------------------
    function str = testNumbers(status)
        str = intelligentVector( cellfun(@(s) s.index, status) );
    end
end
function str = intelligentVector(numbers)
    % Produce a string that is an intelligent vector notation of its arguments
    % e.g. when numbers = [ 1 2 3 4 6 7 8 9 ], it should return '[ 1:4 6:9 ]'
    % The order in the vector is not retained!

    if isempty(numbers)
        str = '[]';
    else
        numbers = sort(numbers(:).');
        delta  = diff([numbers(1)-1 numbers]);
        % place virtual bounds at the first element and beyond the last one
        bounds = [1 find(delta~=1) numel(numbers)+1];
        idx   = 1:(numel(bounds)-1); % start index of each segment
        start = numbers(bounds(idx  )  );
        stop  = numbers(bounds(idx+1)-1);
        parts = arrayfun(@formatRange, start, stop, 'UniformOutput', false);
        str = sprintf('[%s]', strtrim(sprintf('%s ', parts{:})));
    end
end
function str = formatRange(start, stop)
    % format a range [start:stop] of integers in MATLAB syntax
    if start==stop
        str = sprintf('%d',start);
    else
        str = sprintf('%d:%d',start, stop);
    end
end
% ==============================================================================
