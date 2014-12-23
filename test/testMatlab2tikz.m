function status = testMatlab2tikz(varargin)
%TESTMATLAB2TIKZ    unit test driver for matlab2tikz
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
% TESTMATLAB2TIKZ('stages', CELLSTR, ...)
%   where the elements of the cellstr should be either
%    - 'plot': to make the plot
%    - 'tikz': to run matlab2tikz
%    - 'save': to export the MATLAB figure as EPS/PDF
%    - 'hash': to check the hash of the output
%    - 'type': type-out the generatex file on failures
%  Default: {'plot', 'tikz', 'save', 'hash', 'type'}
%
% TESTMATLAB2TIKZ('callMake', LOGICAL, ...)
%   uses "make" to further automate running the test suite, i.e.
%    - runs "make distclean" in the ./test/tex folder before
%   Your path must contain "make", this usually isn't the case on Windows!
%   Default: false
%
% TESTMATLAB2TIKZ('saveHashTable', LOGICAL, ...)
%   saves ALL hashes that were found to disk. Hence, the output file should
%   be checked carefully (e.g. with diff) against the previous version.
%   Default: false
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

  defaultStages = {'plot','tikz','save','hash','type'};
  
  ipp = ipp.addOptional(ipp, 'testFunctionIndices', [], @isfloat);
  ipp = ipp.addParamValue(ipp, 'extraOptions', {}, @iscell);
  ipp = ipp.addParamValue(ipp, 'figureVisible', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'testsuite', @ACID, @(x)(isa(x,'function_handle')));
  ipp = ipp.addParamValue(ipp, 'cleanBefore', true, @islogical);
  ipp = ipp.addParamValue(ipp, 'callMake', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'stages', defaultStages, @isValidStageDef);
  ipp = ipp.addParamValue(ipp, 'saveHashTable', false, @islogical);
  
  ipp = ipp.deprecateParam(ipp,'cleanBefore', {'callMake'});

  ipp = ipp.parse(ipp, varargin{:});
  
  ipp = sanitizeInputs(ipp);
  
  % -----------------------------------------------------------------------

  % try to clean the output
  cleanFiles(ipp.Results.callMake);

  % output streams
  stdout = 1;
  if strcmp(env, 'Octave') && ~ipp.Results.figureVisible
      % Use the gnuplot backend to work around an fltk bug, see
      % <http://savannah.gnu.org/bugs/?43429>.
      graphics_toolkit gnuplot
  end

  % start overall timing
  elapsedTimeOverall = tic;
  
  status = runIndicatedTests(ipp, env);
  
  % print out overall timing
  elapsedTimeOverall = toc(elapsedTimeOverall);
  fprintf(stdout, 'overall time: %4.2fs\n\n', elapsedTimeOverall);

  if ipp.Results.saveHashTable
      fprintf(stdout, 'Saving reference hash table...\n');
      saveHashTable(status, ipp);
  end
end
% INPUT VALIDATION =============================================================
function bool = isValidStageDef(val)
    % determine whether a cell str contains only valid stages
    validStages = {'plot','tikz','save','hash','type'};
    bool = iscellstr(val) && ...
           all(cellfun(@(c)ismember(lower(c), validStages), val));
end
% ==============================================================================
function ipp = sanitizeInputs(ipp)
    % sanitize all input arguments
    ipp = sanitizeStagesDefinition(ipp);
    ipp = sanitizeFunctionIndices(ipp);
    ipp = sanitizeFigureVisible(ipp);
end
function ipp = sanitizeStagesDefinition(ipp)
   % sanitize the passed stages definition field
   ipp.Results.stages = lower(ipp.Results.stages);
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
function status = runIndicatedTests(ipp, env)
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
        status{k} = execute_plot_stage(status{k}, ipp, env);
        
        % plot not successful
        if status{k}.skip
            continue
        end
        
        elapsedTime = tic;
        
        status{k} = execute_save_stage(status{k}, ipp, env);
        status{k} = execute_tikz_stage(status{k}, ipp, env);
        status{k} = execute_hash_stage(status{k}, ipp, env);
        status{k} = execute_type_stage(status{k}, ipp, env);
        
        if ~status{k}.closeall && ~isempty(status{k}.plotStage.fig_handle)
            close(status{k}.plotStage.fig_handle);
        else
            close all;
        end
        
        elapsedTime = toc(elapsedTime);
        status{k}.elapsedTime = elapsedTime;
        fprintf(stdout, '%s ', status{k}.function);
        fprintf(stdout, 'done (%4.2fs).\n\n', elapsedTime);
    end
end
% =========================================================================
function [status] = execute_plot_stage(defaultStatus, ipp, env)
% plot a test figure
    if ismember('plot', ipp.Results.stages)
        testsuite = ipp.Results.testsuite;
        testNumber = defaultStatus.index;

        % open a window
        fig_handle = figure('visible',ipp.Results.figureVisible);
        errorHasOccurred = false;

        % plot the figure
        try
            status = testsuite(testNumber);

        catch %#ok
            e = lasterror('reset'); %#ok

            status.description = '\textcolor{red}{Error during plot generation.}';
            [status.plotStage, errorHasOccurred] = errorHandler(e, env);
        end

        status = fillStruct(status, defaultStatus);
        if isempty(status.function)
            allFuncs = testsuite(0);
            status.function = func2str(allFuncs{testNumber});
        end
        status.plotStage.fig_handle = fig_handle;

        if status.skip || errorHasOccurred
            close(fig_handle);
        end
    end
end
% =========================================================================
function [status] = execute_save_stage(status, ipp, env)
% save stage: saves the figure to EPS/PDF depending on env
    if ismember('save', ipp.Results.stages)
        testNumber = status.index;

        reference_eps = sprintf('data/reference/test%d-reference.eps', testNumber);
        reference_pdf = sprintf('data/reference/test%d-reference.pdf', testNumber);
        reference_fig = sprintf('data/reference/test%d-reference', testNumber);

        % Save reference output as PDF
        try
            switch env
                case 'MATLAB'
                    % MATLAB does not generate properly cropped PDF files.
                    % So, we generate EPS files that are converted later on.
                    print(gcf, '-depsc2', reference_eps);

                    % On R2014b Win, line endings in .eps are Unix style
                    % https://github.com/matlab2tikz/matlab2tikz/issues/370
                    ensureLineEndings(reference_eps);

                case 'Octave'
                    % In Octave, figures are properly cropped when using  print().
                    print(reference_pdf, '-dpdf', '-S415,311', '-r150');
                    pause(1.0)
                otherwise
                    error('Unknown environment. Need MATLAB(R) or GNU Octave.')
            end
        catch %#ok
            e = lasterror('reset'); %#ok
            [status.saveStage] = errorHandler(e, env);
        end
        status.saveStage.epsFile = reference_eps;
        status.saveStage.pdfFile = reference_pdf;
        status.saveStage.texReference = reference_fig;
    end
end
function ensureLineEndings(filename)
% Read in one line and test the ending
fid = fopen(filename,'r+');
testline = fgets(fid);
if ispc && ~strcmpi(testline(end-1:end), sprintf('\r\n'))
    % Rewind, read the whole
    fseek(fid,0,'bof');
    str = fread(fid,'*char')';

    % Replace, overwrite and close
    str = strrep(str, testline(end), sprintf('\r\n'));
    fseek(fid,0,'bof');
    fprintf(fid,'%s',str);
    fclose(fid);
end
end
% =========================================================================
function [status] = execute_tikz_stage(status, ipp, env)
% test stage: TikZ file generation
    if ismember('tikz', ipp.Results.stages)
        testNumber = status.index;
        gen_tex = sprintf('data/converted/test%d-converted.tex', testNumber);
        gen_pdf  = sprintf('data/converted/test%d-converted.pdf', testNumber);
        % now, test matlab2tikz
        try
            cleanfigure(status.extraCleanfigureOptions{:});
            matlab2tikz('filename', gen_tex, ...
                'showInfo', false, ...
                'checkForUpdates', false, ...
                'dataPath', 'data/converted/', ...
                'standalone', true, ...
                ipp.Results.extraOptions{:}, ...
                status.extraOptions{:} ...
                );
        catch %#ok
            e = lasterror('reset'); %#ok
            % Remove (corrupted) output file. This is necessary to avoid that the
            % Makefile tries to compile it and fails.
            delete(gen_tex)
            [status.tikzStage] = errorHandler(e, env);
        end
        status.tikzStage.texFile = gen_tex;
        status.tikzStage.pdfFile = gen_pdf;
    end
end
% =========================================================================
function [status] = execute_hash_stage(status, ipp, env)
    % test stage: check recorded hash checksum
    if ismember('hash', ipp.Results.stages)
        calculated = '';
        expected = '';
        try
            expected = getReferenceHash(status, ipp);
            calculated = calculateMD5Hash(status.tikzStage.texFile, env);

            % do the actual check
            if ~strcmpi(expected, calculated)
                % throw an error to signal the testing framework
                error('testMatlab2tikz:HashMismatch', ...
                      'The hash "%s" does not match the reference hash "%s"', ...
                       calculated, expected);
            end
        catch %#ok
            e = lasterror('reset'); %#ok
            [status.hashStage] = errorHandler(e, env);
        end
        status.hashStage.expected = expected;
        status.hashStage.found    = calculated;
    end
end
% =========================================================================
function [status] = execute_type_stage(status, ipp, env)
    if ismember('type', ipp.Results.stages)
        try 
            filename = status.tikzStage.texFile;
            stream = 1; % stdout
            if errorHasOccurred(status) && exist(filename, 'file')
                fprintf(stream, '\n%%%%%%%% BEGIN FILE "%s" %%%%%%%%\n', filename);
                type(filename);
                fprintf(stream, '\n%%%%%%%% END   FILE "%s" %%%%%%%%\n', filename);
            end
        catch
            e = lasterror('reset');
            [status.typeStage] = errorHandler(e, env);
        end
    end
end
% MD5 HASHING SUPPORT =====================================================
function hash = getReferenceHash(status, ipp)
    % retrieves a reference hash from a persistent hash table
    persistent hashTable
    if isempty(hashTable) || ~isequal(hashTable.suite, ipp.Results.testsuite)
        hashTable = loadHashTable(ipp.Results.testsuite);
    end
    if isfield(hashTable.contents, status.function)
        hash = hashTable.contents.(status.function);
    else
        hash = '';
    end
end
function filename = hashTableName(suite)
    % determines the file name of a hash table
    [pathstr,name, ext] = fileparts(which(func2str(suite)));
    [env, version] = getEnvironment();
    ext = sprintf('.%s.md5', env);
    %TODO: fallback mechanism for different versions
    % e.g. MATLAB R2015a should fall back to R2014b, R2013b to R2014a
    filename = fullfile(pathstr, [name ext]);
end
function hashTable = loadHashTable(suite)
    % loads a reference hash table from disk
    hashTable.suite = suite;
    hashTable.contents = struct();
    filename = hashTableName(suite);
    if exist(filename, 'file')
        fid = fopen(filename, 'r');
        data = textscan(fid, '%s : %s');
        fclose(fid);
        if ~isempty(data) && ~all(cellfun(@isempty, data))
            functions = cellfun(@strtrim, data{1},'UniformOutput', false);
            hashes    = cellfun(@strtrim, data{2},'UniformOutput', false);
            for iFunc = 1:numel(functions)
                hashTable.contents.(functions{iFunc}) = hashes{iFunc};
            end
        end
    end
end
function saveHashTable(status, ipp)
    % saves a reference hash table to disk
    suite = ipp.Results.testsuite;
    filename = hashTableName(suite);
    
    % sort by file names to allow humans better traversal of such files
    funcNames = cellfun(@(s) s.function, status, 'UniformOutput', false);
    [dummy, iSorted] = sort(funcNames);
    status = status(iSorted);
    
    % write to file
    fid = fopen(filename,'w+');
    for iFunc = 1:numel(status)
        S = status{iFunc};
        thisFunc = S.function;
        if isfield(S.hashStage,'found')
            thisHash = S.hashStage.found;
        else
            thisHash = ''; % FIXME: when does this happen??
        end
        if ~isempty(thisHash)
            fprintf(fid, '%s : %s\n', thisFunc, thisHash);
        end
    end
    fclose(fid);
end
% PREPARATION AND SHUTDOWN =====================================================
function cleanFiles(cleanBefore)
% clean output files in ./tex using make
    if cleanBefore && exist(fullfile('tex','Makefile'),'file')
        fprintf(1, 'Cleaning output files...\n');
        cwd = pwd;
        try
            cd('tex');
            [exitCode, output] = system('make distclean');
            fprintf(1,'%s\n', output);
            assert(exitCode==0, 'Exit code 0 means correct execution');
        catch
            % This might happen when make is not present
            fprintf(2, '\tNot completed succesfully\n\n');
        end
        cd(cwd);
    end
end
% HELPER FUNCTIONS =============================================================
function defaultStatus = emptyStatus(testsuite, testNumber)
% constructs an empty status struct
defaultStatus = struct('function',               '', ...
                       'description',            '',...
                       'testsuite',              testsuite ,...
                       'index',                  testNumber, ...
                       'issues',                 [],...
                       'skip',                   false, ... % skipped this test?
                       'closeall',               false, ... % call close all after?
                       'extraOptions',           {cell(0)}, ...
                       'extraCleanfigureOptions',{cell(0)}, ...
                       'plotStage',              emptyStage(), ...
                       'saveStage',              emptyStage(), ...
                       'tikzStage',              emptyStage(), ...
                       'hashStage',              emptyStage());
end
% =========================================================================
function stage = emptyStage()
% constructs an empty (workflow) stage struct
stage = struct('message', '', 'error'  , false);
end
% =========================================================================
function [status] = fillStruct(status, defaultStatus)
% fills non-existant fields of |data| with those of |defaultData|
  fields = fieldnames(defaultStatus);
  for iField = 1:numel(fields)
      field = fields{iField};
      if ~isfield(status,field)
          status.(field) = defaultStatus.(field);
      end
  end
end
% =========================================================================
function [stage, errorHasOccurred] = errorHandler(e,env)
% common error handler code: save and print to console
    errorHasOccurred = true;
    stage = emptyStage();
    stage.message = format_error_message(e);
    stage.error   = errorHasOccurred;
    
    disp_error_message(env, stage.message);
end
% =========================================================================
function msg = format_error_message(e)
    msg = '';
    if ~isempty(e.message)
        msg = sprintf('%serror: %s\n', msg, e.message);
    end
    if ~isempty(e.identifier)
        if strfind(lower(e.identifier),'testmatlab2tikz:')
            % When "errors" occur in the test framework, i.e. a hash mismatch
            % or no hash provided, there is no need to be very verbose.
            % So we don't return the msgid and the stack trace in those cases!
            return % only return the message
        end
        msg = sprintf('%serror: %s\n', msg, e.identifier);
    end
    if ~isempty(e.stack)
        msg = sprintf('%serror: called from:\n', msg);
        for ee = e.stack(:)'
            msg = sprintf('%serror:   %s at line %d, in function %s\n', ...
                          msg, ee.file, ee.line, ee.name);
        end
    end
end
% =========================================================================
function disp_error_message(env, msg)
    stderr = 2;
    % When displaying the error message in MATLAB, all backslashes
    % have to be replaced by two backslashes. This must not, however,
    % be applied constantly as the string that's saved to the LaTeX
    % output must have only one backslash.
    if strcmp(env, 'MATLAB')
        fprintf(stderr, strrep(msg, '\', '\\'));
    else
        fprintf(stderr, msg);
    end
end