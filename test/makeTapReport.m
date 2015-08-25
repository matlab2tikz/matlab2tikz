function makeTapReport(status, varargin)
% Makes a Test Anything Protocol report
%
% This function produces a testing report of HEADLESS tests for
% display on Jenkins (or any other TAP-compatible system)
%
% MAKETAPREPORT(status) produces the report from the `status` output of
% `testHeadless`.
%
% MAKETAPREPORT(status, 'stream', FID, ...) changes the filestream to use
%  to output the report to. (Default: 1 (stdout)).
%
% TAP Specification: https://testanything.org
%
% See also: testHeadless, makeTravisReport, makeLatexReport

    %% Parse input arguments
    ipp = m2tInputParser;

    ipp = ipp.addRequired(ipp, 'status', @iscell);
    ipp = ipp.addParamValue(ipp, 'stream', 1,  @isStream);

    ipp = ipp.parse(ipp, status, varargin{:});
    arg = ipp.Results;

    %% open/close file if needed
    if ischar(arg.stream)
        arg.filename = arg.stream;
        fprintf('\nSaving TAP report in %s\n', arg.filename);
        arg.stream = fopen(arg.filename, 'w');
        arg.finallyCloseFile = onCleanup(@() fclose(arg.stream));
    end

    %% build report
    printTAPVersion(arg.stream);
    printTAPPlan(arg.stream, status);
    for iStatus = 1:numel(status)
        printTAPReport(arg.stream, status{iStatus});
    end
end
% == INPUT VALIDATOR FUNCTIONS =================================================
function bool = isStream(val)
    % returns true if it is a valid (file) stream or stdout/stderr stream
    bool = isnumeric(val) || ischar(val);
end
% ==============================================================================
function printTAPVersion(stream)
    % prints the TAP version
    fprintf(stream,'TAP version 13\n');
end
function printTAPPlan(stream, statuses)
    % prints the TAP test plan
    firstTest = 1;
    lastTest = numel(statuses); % just assume we are testing everything
    fprintf(stream,'%d..%d\n', firstTest, lastTest);
end
function printTAPReport(stream, status)
    % prints a TAP test case report
    directive = '';
    result = 'not ok';
    message = status.function;
    testNum = status.index;

    if status.unreliable
        result = 'ok';
        directive = '# TODO unreliable';
    elseif status.skip
        result = 'ok';
        directive = '# SKIP skipped';
    elseif countNumberOfErrors(status) == 0
        result = 'ok';
    end

    fprintf(stream, '%s %d %s %s\n', result, testNum, message, directive);

    %TODO: we can provide more information on the failure using YAML syntax
end
% ==============================================================================
