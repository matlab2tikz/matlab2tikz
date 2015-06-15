function status = testMatlab2tikz(varargin)
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
% See also matlab2tikz, ACID

% Copyright (c) 2008--2014, Nico Schlömer <nico.schloemer@gmail.com>
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in
%      the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% =========================================================================

  % In which environment are we?
  env = getEnvironment();

  % -----------------------------------------------------------------------
  ipp = m2tInputParser;

  ipp = ipp.addOptional(ipp, 'testFunctionIndices', [], @isfloat);
  ipp = ipp.addParamValue(ipp, 'extraOptions', {}, @iscell);
  ipp = ipp.addParamValue(ipp, 'figureVisible', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'actionsToExecute', @(varargin) varargin{1}, @isFunction);
  ipp = ipp.addParamValue(ipp, 'testsuite', @ACID, @isFunction );

  ipp = ipp.parse(ipp, varargin{:});

  ipp = sanitizeInputs(ipp);

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
