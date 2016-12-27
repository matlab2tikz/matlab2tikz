function [status, parameters] = testMatlab2tikz(varargin)
%TESTMATLAB2TIKZ    unit test driver for matlab2tikz
%
% This function should NOT be called directly by the user (or even developer).
% If you are a developer, please use some of the following functions instead:
%  * `testHeadless`
%  * `testGraphical`
%
% The following arguments are supported, also for the functions above.
%
% TESTMATLAB2TIKZ('testFunctionIndices', INDICES, ...) or
%   TESTMATLAB2TIKZ(INDICES, ...) runs the test only for the specified
%   indices. When empty, all tests are run. (Default: []).
%
% TESTMATLAB2TIKZ('extraOptions', {'name',value, ...}, ...)
%   passes the cell array of options to MATLAB2TIKZ. Default: {}
%
% TESTMATLAB2TIKZ('figureVisible', LOGICAL, ...)
%   plots the figure visibly during the test process. Default: false
%
% TESTMATLAB2TIKZ('testsuite', FUNCTION_HANDLE, ...)
%   Determines which test suite is to be run. Default: @ACID
%   A test suite is a function that takes a single integer argument, which:
%     when 0: returns a cell array containing the N function handles to the tests
%     when >=1 and <=N: runs the appropriate test function
%     when >N: throws an error
%
% TESTMATLAB2TIKZ('output', DIRECTORY, ...)
%   Sets the output directory where the output files are places.
%   The default directory is $M2TROOT/test/output/current
%
% See also matlab2tikz, ACID

  % In which environment are we?
  env = getEnvironment();

  % -----------------------------------------------------------------------
  ipp = m2tInputParser;

  ipp = ipp.addOptional(ipp, 'testFunctionIndices', [], @isfloat);
  ipp = ipp.addParamValue(ipp, 'extraOptions', {}, @iscell);
  ipp = ipp.addParamValue(ipp, 'figureVisible', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'actionsToExecute', @(varargin) varargin{1}, @isFunction);
  ipp = ipp.addParamValue(ipp, 'testsuite', @ACID, @isFunction );
  ipp = ipp.addParamValue(ipp, 'output', m2troot('test','output','current'), @ischar);

  ipp = ipp.parse(ipp, varargin{:});

  ipp = sanitizeInputs(ipp);
  parameters = ipp.Results;

  % -----------------------------------------------------------------------
  if strcmpi(env, 'Octave')
      if ~ipp.Results.figureVisible
          % Use the gnuplot backend to work around an fltk bug, see
          % <http://savannah.gnu.org/bugs/?43429>.
          graphics_toolkit gnuplot
      end

      if ispc
          % Prevent three digit exponent on Windows Octave
          % See https://github.com/matlab2tikz/matlab2tikz/pull/602
          setenv ('PRINTF_EXPONENT_DIGITS', '2')
      end
  end
  
  % copy output template into output directory
  if ~exist(ipp.Results.output,'dir')
      mkdir(ipp.Results.output);
  end
  template = m2troot('test','template');
  copyfile(fullfile(template,'*'), ipp.Results.output);

  % start overall timing
  elapsedTimeOverall = tic;
  status = runIndicatedTests(ipp);

  % print out overall timing
  elapsedTimeOverall = toc(elapsedTimeOverall);
  stdout = 1;
  fprintf(stdout, 'overall time: %4.2fs\n\n', elapsedTimeOverall);
end
% INPUT VALIDATION =============================================================
function bool = isFunction(f)
    bool = isa(f,'function_handle');
end
function ipp = sanitizeInputs(ipp)
    % sanitize all input arguments
    ipp = sanitizeFunctionIndices(ipp);
    ipp = sanitizeFigureVisible(ipp);
end
function ipp = sanitizeFunctionIndices(ipp)
% sanitize the passed function indices to the range of the test suite
  % query the number of test functions
  testsuite = ipp.Results.testsuite;
  n = length(testsuite(0));

  if ~isempty(ipp.Results.testFunctionIndices)
      indices = ipp.Results.testFunctionIndices;
      % kick out the illegal stuff
      I = find(indices>=1 & indices<=n);
      indices = indices(I); %#ok
  else
      indices = 1:n;
  end
  ipp.Results.testFunctionIndices = indices;
end
function ipp = sanitizeFigureVisible(ipp)
    % sanitizes the figure visible option from boolean to ON/OFF
    if ipp.Results.figureVisible
        ipp.Results.figureVisible = 'on';
    else
        ipp.Results.figureVisible = 'off';
    end
end
% TEST RUNNER ==================================================================
function status = runIndicatedTests(ipp)
% run all indicated tests in the test suite
    % cell array to accomodate different structure
    indices = ipp.Results.testFunctionIndices;
    testsuite = ipp.Results.testsuite;
    testsuiteName = func2str(testsuite);
    stdout = 1;
    status = cell(length(indices), 1);

    for k = 1:length(indices)
        testNumber = indices(k);

        fprintf(stdout, 'Executing %s test no. %d...\n', testsuiteName, indices(k));

        status{k} = emptyStatus(testsuite, testNumber);

        elapsedTime = tic;

        status{k} = feval(ipp.Results.actionsToExecute, status{k}, ipp);

        elapsedTime = toc(elapsedTime);
        status{k}.elapsedTime = elapsedTime;
        fprintf(stdout, '%s ', status{k}.function);
        if status{k}.skip
            fprintf(stdout, 'skipped (%4.2fs).\n\n', elapsedTime);
        else
            fprintf(stdout, 'done (%4.2fs).\n\n', elapsedTime);
        end
    end
end
