function status = runtests
%% This file runs the complete MATLAB2TIKZ test suite.
% It is mainly used for testing on a continuous integration server, but it can
% also be used on a development machine.

%% Set path
addpath(fullfile(pwd,'..','src'));
addpath(fullfile(pwd,'suites'));

CI_MODE = strcmpi(getenv('CONTINUOUS_INTEGRATION'),'true');

%% Select functions to run
suite = @ACID;
allTests = 1:numel(suite(0));

switch getEnvironment
    case 'Octave'
        m2tFailing   = [29:31];       %FIXME: these are actual M2T problems 
        nondeterministic = [32 67];   %FIXME: these should be made deterministic 
        plotFailing  = [74 81:83 95]; %FIXME: these plots fail
    case 'MATLAB'
        plotFailing = [];
        m2tFailing  = [];
        % R2014a
        nondeterministicHG1 = [8];
        % R2014b
        nondeterministicHG2 = [14 20 34 38:40 42 89 92 93 95];
        
        nondeterministic = unique([nondeterministicHG1 nondeterministicHG2]);
end
testsKnownToFail = [plotFailing m2tFailing nondeterministic];

if CI_MODE
    stagesArg = {'stages', {'plot', 'tikz', 'hash', 'type'}};
else
    stagesArg = {}; % use default
end

%% Run tests
statusAll = testMatlab2tikz('testFunctionIndices', allTests,...
                            'testsuite',           suite, ...
                            stagesArg{:});

%% Divide between known-to-fail and other tests
statusKnownToFail = statusAll( ismember(allTests, testsKnownToFail));
statusNormalTests = statusAll(~ismember(allTests, testsKnownToFail));

%% Generate a report                        
if ~isempty(statusKnownToFail)
    disp('The following tests are known to fail. They do not block the build!');
    makeTravisReport(statusKnownToFail);
end
makeTravisReport(statusNormalTests)

%% Calculate exit code
nErrors = countNumberOfErrors(statusNormalTests);
if CI_MODE 
    exit(nErrors);
end