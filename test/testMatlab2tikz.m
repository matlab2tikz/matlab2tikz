function testMatlab2tikz(varargin)
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
% TESTMATLAB2TIKZ('report', CHAR, ...)
%   sets what kind of report should be generated. Possible choices are:
%    - 'latex': creates a LaTeX report
%    - 'travis': for Travis CI
%   Default: 'latex'
%
% TESTMATLAB2TIKZ('callMake', LOGICAL, ...)
%   uses "make" to further automate running the test suite, i.e.
%    - runs "make distclean" in the ./test/tex folder before
%   Your path must contain "make", this usually isn't the case on Windows!
%   Default: false
% 
% TESTMATLAB2TIKZ('exitAfterTests', LOGICAL, ...)
%   Shuts down MATLAB/Octave after running the test suite. The exit code is the
%   number of errors caught. Default: false.
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
  ipp = ipp.addParamValue(ipp, 'testsuite', @ACID, @(x)(isa(x,'function_handle')));
  ipp = ipp.addParamValue(ipp, 'cleanBefore', true, @islogical);
  ipp = ipp.addParamValue(ipp, 'callMake', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'report', 'travis', @isValidReportMode);
  ipp = ipp.addParamValue(ipp, 'exitAfterTests', false, @islogical);
  
  ipp = ipp.deprecateParam(ipp,'cleanBefore', {'callMake'});

  ipp = ipp.parse(ipp, varargin{:});
  
  ipp = sanitizeReportMode(ipp);
  ipp = sanitizeFunctionIndices(ipp);
  
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
  
  startFold(ipp,'all-tests');
  status = runIndicatedTests(ipp, env);
  endFold(ipp,'all-tests');
  
  makeReport(ipp, status);

  % print out overall timing
  elapsedTimeOverall = toc(elapsedTimeOverall);
  fprintf(stdout, 'overall time: %4.2fs\n\n', elapsedTimeOverall);

  exitAfterRunningTests(ipp, status);
end
% INPUT VALIDATION =============================================================
function bool = isValidReportMode(str)
% validation of the report mode (i.e. LaTeX or Travis)
    bool = ischar(str) && ismember(lower(str), {'latex','travis'});
end
% =========================================================================
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
% =========================================================================
function ipp = sanitizeReportMode(ipp)
    % sanitizes the report mode
    ipp.Results.report = lower(ipp.Results.report);
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
        status{k} = emptyStatus();
        status{k} = execute_plot_stage(status{k}, ipp, env, testNumber);
        
        % plot not successful
        if status{k}.skip
            continue
        end
        
        elapsedTime = tic;
        
        status{k} = execute_save_stage(status{k}, ipp, env, testNumber);
        status{k} = execute_tikz_stage(status{k}, ipp, env, testNumber);
        status{k} = execute_hash_stage(status{k}, ipp, env, testNumber);
        
        if ~status{k}.closeall
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
function [status] = execute_plot_stage(defaultStatus, ipp, env, testNumber)
% plot a test figure
    testsuite = ipp.Results.testsuite;
    % open a window
    fig_handle = figure('visible',onOffBoolean(ipp.Results.figureVisible));
    errorHasOccurred = false;

    % plot the figure
    try
        status = testsuite(testNumber);
        
    catch %#ok
        e = lasterror('reset'); %#ok
        
        status.description = '\textcolor{red}{Error during plot generation.}';
        if isempty(status) || ~isfield(status, 'function') ...
                || isempty(status.function)
            status.function = extractFunctionFromError(e, testsuite);
        end
        
        [status.plotStage, errorHasOccurred] = errorHandler(e, env);
    end
    
    status = fillStruct(status, defaultStatus);
    status.plotStage.fig_handle = fig_handle;
    
    if status.skip || errorHasOccurred
        close(fig_handle);
    end
end
% =========================================================================
function [status] = execute_save_stage(status, ipp, env, testNumber)
% save stage: saves the figure to EPS/PDF depending on env
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
        [status.saveStage, errorHasOccurred] = errorHandler(e, env);
    end
    status.saveStage.epsFile = reference_eps;
    status.saveStage.pdfFile = reference_pdf;
    status.saveStage.texReference = reference_fig;
end
% =========================================================================
function [status] = execute_tikz_stage(status, ipp, env, testNumber)
% test stage: TikZ file generation
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
        [status.tikzStage, errorHasOccurred] = errorHandler(e, env);
    end
    status.tikzStage.texFile = gen_tex;
    status.tikzStage.pdfFile = gen_pdf;
end
% =========================================================================
function [status] = execute_hash_stage(status, ipp, env, testNumber)
    expected = '';
    calculated = '';
    try
        if isfield(status,'md5')
            %TODO: we should use a more robust mechanisme than passing the hash
            % from the test 
            expected = status.md5;
        else
            error('testMatlab2tikz:NoHashProvided', 'No reference hash provided');
        end
        
        switch env
            case 'Octave'
                calculated = md5sum(status.tikzStage.texFile);
            case 'MATLAB'
                %TODO: implement MD5 for MATLAB (this exists somewhere online)
                error('testMatlab2tikz:NoHashAlgorithm', ...
                      'MD5 algorithm is not implemented in MATLAB');
        end
        
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
% =========================================================================
function exitAfterRunningTests(ipp, status)
% (conditionally) closes MATLAB/Octave after running the test suite. The 
% error code used, indicates how many errors were found.
    if ipp.Results.exitAfterTests
        nErrors = countNumberOfErrors(status);
        exit(nErrors);
    end
end
% REPORT GENERATION ============================================================
function makeReport(ipp, status)
    switch ipp.Results.report
        case 'latex'
            makeLatexReport(ipp, status);
        case 'travis'
            makeTravisReport(ipp, status);
    end 
end
% =========================================================================
function makeTravisReport(ipp, status)
    
end
% =========================================================================
function startFold(ipp, name)
% starts a folding region in Travis
    if strcmpi(ipp.Results.report,'travis')
        stdout = 1;
        fprintf(stdout, 'travis_fold:start:#{%s}\n', name);
    end
end
% =========================================================================
function endFold(ipp, name)
% ends a folding region in Travis
    if strcmpi(ipp.Results.report,'travis')
        stdout = 1;
        fprintf(stdout, 'travis_fold:end:#{%s}\n', name);
    end
end
% =========================================================================
function makeLatexReport(ipp, status)
% generate a LaTeX report
  indices = ipp.Results.testFunctionIndices;
  testsuite = ipp.Results.testsuite;
  testsuiteName = func2str(testsuite);

  % first, initialize the tex output
  texfile = 'tex/acid.tex';
  fh = fopen(texfile, 'w');
  assert(fh ~= -1, 'Could not open TeX file ''%s'' for writing.', texfile);
  texfile_init(fh);
  
  for k = 1:length(indices)
      testNumber = indices(k);
      % ...and finally write the bits to the LaTeX file
      reference_fig = status{k}.saveStage.texReference;
      gen_pdf = status{k}.tikzStage.pdfFile;
      texfile_addtest(fh, reference_fig, gen_pdf, status{k}, testNumber, testsuiteName);
  end

  % Write the summary table to the LaTeX file
  texfile_tab_completion_init(fh)
  for k = 1:length(indices)
      stat = status{k};
      % Break table up into pieces if it gets too long for one page
      if ~mod(k,35)
          texfile_tab_completion_finish(fh);
          texfile_tab_completion_init(fh);
      end

      fprintf(fh, '%d & \\texttt{%s}', indices(k), name2tex(stat.function));
      if stat.skip
          fprintf(fh, ' & --- & skipped & ---');
      else
          for err = [stat.plotStage.error, ...
                     stat.saveStage.error, ...
                     stat.tikzStage.error]
              if err
                  fprintf(fh, ' & \\textcolor{red}{failed}');
              else
                  fprintf(fh, ' & \\textcolor{green!50!black}{passed}');
              end
          end
      end
      fprintf(fh, ' \\\\\n');
  end
  texfile_tab_completion_finish(fh);

  % Write the error messages to the LaTeX file if there are any
  if errorHasOccurred(status)
      fprintf(fh, '\\section*{Error messages}\n\\scriptsize\n');
      for k = 1:length(indices)
          stat = status{k};
          if isempty(stat.plotStage.message) && ...
             isempty(stat.saveStage.message) && ...
             isempty(stat.tikzStage.message)
              continue % No error messages for this test case
          end

          fprintf(fh, '\n\\subsection*{Test case %d: \\texttt{%s}}\n', indices(k), name2tex(stat.function));
          print_verbatim_information(fh, 'Plot generation', stat.plotStage.message);
          print_verbatim_information(fh, 'PDF generation' , stat.saveStage.message);
          print_verbatim_information(fh, 'matlab2tikz'    , stat.tikzStage.message);
      end
      fprintf(fh, '\n\\normalsize\n\n');
  end

  % now, finish off the file and close file and window
  texfile_finish(fh, testsuite);
  fclose(fh);
end
% =========================================================================
function texfile_init(texfile_handle)

  fprintf(texfile_handle, ...
           ['\\documentclass[landscape]{scrartcl}\n'                , ...
            '\\pdfminorversion=6\n\n'                               , ...
            '\\usepackage{amsmath} %% required for $\\text{xyz}$\n\n', ...
            '\\usepackage{hyperref}\n'                              , ...
            '\\usepackage{graphicx}\n'                              , ...
            '\\usepackage{epstopdf}\n'                              , ...
            '\\usepackage{tikz}\n'                                  , ...
            '\\usetikzlibrary{plotmarks}\n\n'                       , ...
            '\\usepackage{pgfplots}\n'                              , ...
            '\\pgfplotsset{compat=newest}\n\n'                      , ...
            '\\usepackage[margin=0.5in]{geometry}\n'                , ...
            '\\newlength\\figurewidth\n'                            , ...
            '\\setlength\\figurewidth{0.4\\textwidth}\n\n'          , ...
            '\\begin{document}\n\n']);

end
% =========================================================================
function texfile_finish(texfile_handle, testsuite)

  [env,versionString] = getEnvironment();


  fprintf(texfile_handle, ...
      [
      '\\newpage\n',...
      '\\begin{tabular}{ll}\n',...
      '  Suite    & ' name2tex(func2str(testsuite)) ' \\\\ \n', ...
      '  Created  & ' datestr(now) ' \\\\ \n', ...
      '  OS       & ' OSVersion ' \\\\ \n',...
      '  ' env '  & ' versionString ' \\\\ \n', ...
      VersionControlIdentifier, ...
      '  TikZ     & \\expandafter\\csname ver@tikz.sty\\endcsname \\\\ \n',...
      '  Pgfplots & \\expandafter\\csname ver@pgfplots.sty\\endcsname \\\\ \n',...
      '\\end{tabular}\n',...
      '\\end{document}']);

end
% =========================================================================
function print_verbatim_information(texfile_handle, title, contents)
    if ~isempty(contents)
        fprintf(texfile_handle, ...
                ['\\subsubsection*{%s}\n', ...
                 '\\begin{verbatim}\n%s\\end{verbatim}\n'], ...
                title, contents);
    end
end
% =========================================================================
function texfile_addtest(texfile_handle, ref_file, gen_tex, status, funcId, testsuiteName)
  % Actually add the piece of LaTeX code that'll later be used to display
  % the given test.

  ref_error = status.plotStage.error;
  gen_error = status.tikzStage.error;

  fprintf(texfile_handle, ...
          ['\\begin{figure}\n'                                          , ...
           '  \\centering\n'                                            , ...
           '  \\begin{tabular}{cc}\n'                                   , ...
           '    %s & %s \\\\\n'                                         , ...
           '    reference rendering & generated\n'                      , ...
           '  \\end{tabular}\n'                                         , ...
           '  \\caption{%s \\texttt{%s}, \\texttt{%s(%d)}.%s}\n', ...
          '\\end{figure}\n'                                             , ...
          '\\clearpage\n\n'],...
          include_figure(ref_error, 'includegraphics', ref_file), ...
          include_figure(gen_error, 'includegraphics', gen_tex), ...
          status.description, ...
          name2tex(status.function), name2tex(testsuiteName), funcId, ...
          formatIssuesForTeX(status.issues));

end
% =========================================================================
function str = include_figure(errorOccured, command, filename)
    if errorOccured
        str = sprintf(['\\tikz{\\draw[red,thick] ', ...
                       '(0,0) -- (\\figurewidth,\\figurewidth) ', ...
                       '(0,\\figurewidth) -- (\\figurewidth,0);}']);
    else
        switch command
            case 'includegraphics'
                strFormat = '\\includegraphics[width=\\figurewidth]{../%s}';
            case 'input'
                strFormat = '\\input{../%s}';
            otherwise
                error('Matlab2tikz_acidtest:UnknownFigureCommand', ...
                      'Unknown figure command "%s"', command);
        end
        str = sprintf(strFormat, filename);
    end
end
% =========================================================================
function texfile_tab_completion_init(texfile_handle)

  fprintf(texfile_handle, ['\\clearpage\n\n'                            , ...
                           '\\begin{table}\n'                           , ...
                           '\\centering\n'                              , ...
                           '\\caption{Test case completion summary}\n'  , ...
                           '\\begin{tabular}{rlccc}\n'                  , ...
                           'No. & Test case & Plot & PDF & TikZ \\\\\n' , ...
                           '\\hline\n']);

end
% =========================================================================
function texfile_tab_completion_finish(texfile_handle)

  fprintf(texfile_handle, ['\\end{tabular}\n' , ...
                           '\\end{table}\n\n' ]);

end
% =========================================================================
function [env,versionString] = getEnvironment()
  % Check if we are in MATLAB or Octave.
  % Calling ver with an argument: iterating over all entries is very slow
  supportedEnvironments = {'MATLAB', 'Octave'};
  for iCase = 1:numel(supportedEnvironments)
      env   = supportedEnvironments{iCase};
      vData = ver(env);
      if ~isempty(vData)
          versionString = vData.Version;
          return; % found the right environment
      end
  end
  % no suitable environment found
  if ~ismember(env, supportedEnvironments)
      error('testMatlab2tikz:UnknownEnvironment',...
            'Unknown environment. Only MATLAB and Octave are supported.')
  end
end
% =========================================================================
function [formatted, OSType, OSVersion] = OSVersion()
    if ismac
        OSType = 'Mac OS';
        [dummy, OSVersion] = system('sw_vers -productVersion');
    elseif ispc
        OSType = '';% will already contain Windows in the output of `ver`
        [dummy, OSVersion] = system('ver');
    elseif isunix
        OSType = 'Unix';
        [dummy, OSVersion] = system('uname -r');
    else
        OSType = '';
        OSVersion = '';
    end
    formatted = strtrim([OSType ' ' OSVersion]);
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
% =========================================================================
function [formatted,treeish] = VersionControlIdentifier()
% This function gives the (git) commit ID of matlab2tikz
%
% This assumes the standard directory structure as used by Nico's master branch:
%     SOMEPATH/src/matlab2tikz.m with a .git directory in SOMEPATH.
%
% The HEAD of that repository is determined from file system information only
% by following dynamic references (e.g. ref:refs/heds/master) in branch files
% until an absolute commit hash (e.g. 1a3c9d1...) is found.
% NOTE: Packed branch references are NOT supported by this approach
    MAXITER     = 10; % stop following dynamic references after a while
    formatted   = '';
    REFPREFIX   = 'ref:';
    isReference = @(treeish)(any(strfind(treeish, REFPREFIX)));
    treeish     = [REFPREFIX 'HEAD'];
    try
        % get the matlab2tikz directory
        m2tDir = fileparts(mfilename('fullpath'));
        gitDir = fullfile(m2tDir,'..','.git');

        nIter = 1;
        while isReference(treeish)
            refName    = treeish(numel(REFPREFIX)+1:end);
            branchFile = fullfile(gitDir, refName);

            if exist(branchFile, 'file') && nIter < MAXITER
                fid     = fopen(branchFile,'r');
                treeish = fscanf(fid,'%s');
                fclose(fid);
                nIter   = nIter + 1;
            else % no branch file or iteration limit reached
                treeish = '';
                return;
            end
        end
    catch %#ok
        treeish = '';
    end
    if ~isempty(treeish)
        formatted = ['  Commit & ' treeish ' \\\\ \n'];
    end
end
% =========================================================================
function texName = name2tex(matlabIdentifier)
texName = strrep(matlabIdentifier, '_', '\_');
end
% =========================================================================
function str = formatIssuesForTeX(issues)
% make links to GitHub issues for the LaTeX output
  issues = issues(:)';
  if isempty(issues)
      str = '';
      return
  end
  BASEURL = 'https://github.com/matlab2tikz/matlab2tikz/issues/';
  SEPARATOR = sprintf(' \n');
  strs = arrayfun(@(n) sprintf(['\\href{' BASEURL '%d}{\\#%d}'], n,n), issues, ...
                  'UniformOutput', false);
  strs = [strs; repmat({SEPARATOR}, 1, numel(strs))];
  str = sprintf('{\\color{blue} \\texttt{%s}}', [strs{:}]);
end
% =========================================================================
function onOff = onOffBoolean(bool)
if bool
    onOff = 'on';
else
    onOff = 'off';
end
end
% =========================================================================
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
function nErrors = countNumberOfErrors(status)
% counts the number of errors in a status cell array
    nErrors = 0;
    % probably this can be done more compactly using cellfun, etc.
    for iTest = 1:numel(status)
        S = status{iTest};
        stages = getStagesFromStatus(S);
        errorInThisTest = false;
        for jStage = 1:numel(stages)
            errorInThisTest = errorInThisTest || S.(stages{jStage}).error;
        end
        if errorInThisTest
            nErrors = nErrors + 1;
        end
    end
end
% =========================================================================
function errorOccurred = errorHasOccurred(status)
% determines whether an error has occurred from a status struct OR cell array
% of status structs
    errorOccurred = false;
    if iscell(status)
        for iStatus = 1:numel(status)
            errorOccurred = errorOccurred || errorHasOccurred(status{iStatus});
        end
    else
        stages = getStagesFromStatus(status);
        for iStage = 1:numel(stages)
            thisStage = status.(stages{iStage});
            errorOccurred = errorOccurred || thisStage.error;
        end
    end
end
% =========================================================================
function stages = getStagesFromStatus(status)
% retrieves the different (names of) stages of a status struct 
    fields = fieldnames(status);
    stages = fields(cellfun(@(f) ~isempty(strfind(f,'Stage')), fields));
end
% =========================================================================
function defaultStatus = emptyStatus()
% constructs an empty status struct
defaultStatus = struct('function',               '', ...
                       'description',            '',...
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
function name = extractFunctionFromError(e, testsuite)
% extract function name from an error (using the stack)
    name = '';
    if isa(testsuite, 'function_handle')
        testsuite = func2str(testsuite);
    end
    for kError = 1:numel(e.stack);
        ee = e.stack(kError);
        if isempty(name)
            name = '';
            if ~isempty(regexp(ee.name, ['^' testsuite '>'],'once'))
                % extract function name
                name = regexprep(ee.name, ['^' testsuite '>(.*)'], '$1');
            elseif ~isempty(regexp(ee.name, ['^' testsuite],'once')) && ...
                    kError < numel(e.stack)
                % new stack trace format (R2014b)
                if kError > 1
                    name = e.stack(kError-1).name;
                end
            end
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
