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
    SM = StreamMaker;
    ipp = m2tInputParser;

    ipp = ipp.addRequired(ipp, 'status', @iscell);
    ipp = ipp.addParamValue(ipp, 'stream', 1,  SM.isStream);

    ipp = ipp.parse(ipp, status, varargin{:});
    arg = ipp.Results;

    %% Construct stream
    Stream = SM.make(arg.stream, 'w');
    fid = Stream.fid;

    %% build report
    printTAPVersion(fid);
    printTAPPlan(fid, status);
    for iStatus = 1:numel(status)
        printTAPReport(fid, status{iStatus});
    end
end
% ==============================================================================
function printTAPVersion(fid)
    % prints the TAP version
    fprintf(fid, 'TAP version 13\n');
end
function printTAPPlan(fid, statuses)
    % prints the TAP test plan
    firstTest = 1;
    lastTest = numel(statuses); % just assume we are testing everything
    fprintf(fid, '%d..%d\n', firstTest, lastTest);
end
function printTAPReport(fid, status)
    % prints a TAP test case report
    directive = '';
    message = status.function;
    testNum = status.index;

    if hasTestFailed(status)
        result = 'not ok';
    else
        result = 'ok';
    end

    directive = addDirective(status.skip, directive, '# SKIP skipped');
    directive = addDirective(status.unreliable, directive, '# TODO unreliable');

    fprintf(fid, '%s %d %s %s\n', result, testNum, message, directive);

    %TODO: we can provide more information on the failure using YAML syntax
end
function directive = addDirective(condition, directive, addition)
    if condition
        directive = strtrim([directive ' ' addition]);
    end
end
% ==============================================================================
