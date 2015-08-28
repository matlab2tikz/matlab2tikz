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
    SM = StreamMaker();
    ipp = m2tInputParser();

    ipp = ipp.addRequired(ipp, 'status', @iscell);
    ipp = ipp.addParamValue(ipp, 'stream', 1,  SM.isStream);

    ipp = ipp.parse(ipp, status, varargin{:});
    arg = ipp.Results;

    %% Construct stream
    stream = SM.make(arg.stream, 'w');

    %% build report
    printTAPVersion(stream);
    printTAPPlan(stream, status);
    for iStatus = 1:numel(status)
        printTAPReport(stream, status{iStatus}, iStatus);
    end
end
% ==============================================================================
function printTAPVersion(stream)
    % prints the TAP version
    stream.print('TAP version 13\n');
end
function printTAPPlan(stream, statuses)
    % prints the TAP test plan
    firstTest = 1;
    lastTest = numel(statuses);
    stream.print('%d..%d\n', firstTest, lastTest);
end
function printTAPReport(stream, status, testNum)
    % prints a TAP test case report
    message = status.function;

    if hasTestFailed(status)
        result = 'not ok';
    else
        result = 'ok';
    end
    directives = getTAPDirectives(status);

    stream.print('%s %d %s %s\n', result, testNum, message, directives);

    %TODO: we can provide more information on the failure using YAML syntax
end
function directives = getTAPDirectives(status)
    % add TAP directive (a todo or skip) to the test directives
    directives = {};
    if status.skip
        directives{end+1} = '# SKIP skipped';
    end
    if status.unreliable
        directives{end+1} = '# TODO unreliable';
    end
    directives = strtrim(m2tstrjoin(directives, ' '));
end
% ==============================================================================
