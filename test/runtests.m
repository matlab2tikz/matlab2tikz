%% This file runs the complete MATLAB2TIKZ test suite.
% It is mainly used for testing on a continuous integration server, but it can
% also be used on a development machine.

%% Set path
addpath(fullfile(pwd,'..','src'));
addpath(fullfile(pwd,'suites'));

if isempty(which('countNumberOfErrors'))
    addpath(fullfile(pwd,'private')); % work-around
end

%% Select functions to run
suite = @ACID;
allTests = 1:numel(suite(0));

m2tFailing   = [29:31];       %FIXME: these are actual M2T problems 
nondeterministic = [32 67];   %FIXME: these should be made deterministic 
plotFailing  = [74 81:83 95]; %FIXME: these plots fail

testsToRun = setdiff(allTests, [plotFailing m2tFailing nondeterministic]);

if strcmpi(getenv('CONTINUOUS_INTEGRATION'),'true')
    stagesArg = {'stages', {'plot', 'tikz', 'hash'}};
else
    stagesArg = {}; % use default
end

%% Run tests
status = testMatlab2tikz('testFunctionIndices', testsToRun,...
                          'testsuite',           suite, ...
                          stagesArg{:});

makeTravisReport(status)

%% Calculate exit code
nErrors = countNumberOfErrors(status);
exit(nErrors);