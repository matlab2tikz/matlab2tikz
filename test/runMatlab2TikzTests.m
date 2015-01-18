function statusAll = runMatlab2TikzTests(varargin)
%% This file runs the complete MATLAB2TIKZ test suite.
% It is mainly used for testing on a continuous integration server, but it can
% also be used on a development machine.

CI_MODE = strcmpi(getenv('CONTINUOUS_INTEGRATION'),'true');

%% Set path
addpath(fullfile(pwd,'..','src'));
addpath(fullfile(pwd,'suites'));

%% Select functions to run
suite = @ACID;
allTests = 1:numel(suite(0));

if CI_MODE
    stagesArg = {'stages', {'plot', 'tikz', 'hash', 'type'}};
else
    stagesArg = {}; % use default
end

%% Run tests
% The width and height are specified to circumvent different DPIs in developer
% machines. The float format reduces the probability that numerical differences
% in the order of numerical precision disrupt the output.
extraOptions = {'width' ,'\figurewidth' ,...
                'height','\figureheight',...
                'floatFormat', '%8.6g'  ,...
               };

statusAll = testMatlab2tikz('testFunctionIndices', allTests,...
                            'testsuite',           suite, ...
                            'extraOptions',        extraOptions, ...
                            stagesArg{:}, varargin{:});

%% Divide between known-to-fail and other tests
knownToFail = cellfun(@(s)s.unreliable, statusAll);

statusKnownToFail = statusAll( knownToFail);
statusNormalTests = statusAll(~knownToFail);

%% Generate a report                        
if ~isempty(statusKnownToFail)
    fprintf(1, ['\nThe following tests are known to fail.' ...
                'They do not cause the build to fail, however.\n\n']);
    makeTravisReport(statusKnownToFail);
    fprintf('\n\nOnly the following tests determine the build outcome:\n');
end
makeTravisReport(statusNormalTests)

%% Calculate exit code
nErrors = countNumberOfErrors(statusNormalTests);
if CI_MODE 
    exit(nErrors);
end