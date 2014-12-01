function matlab2tikz_acidtest(varargin)
%MATLAB2TIKZ_ACIDTEST    unit test driver for matlab2tikz
%
% MATLAB2TIKZ_ACIDTEST('testFunctionIndices', INDICES, ...) or
%   MATLAB2TIKZ_ACIDTEST(INDICES, ...) runs the test only for the specified
%   indices. When empty, all tests are run. (Default: []).
%
% MATLAB2TIKZ_ACIDTEST('extraOptions', {'name',value, ...}, ...)
%   passes the cell array of options to MATLAB2TIKZ. Default: {}
%
% MATLAB2TIKZ_ACIDTEST('figureVisible', LOGICAL, ...)
%   plots the figure visibly during the test process. Default: false
%
% MATLAB2TIKZ_ACIDTEST('cleanBefore', LOGICAL, ...)
%   tries to run "make clean" in the ./tex folder. Default: true
%
% MATLAB2TIKZ_ACIDTEST('testsuite', FUNCTION_HANDLE, ...)
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
  if ~strcmp(env, 'MATLAB') && ~strcmp(env, 'Octave')
      error('Unknown environment. Need MATLAB(R) or GNU Octave.')
  end


  % -----------------------------------------------------------------------
  ipp = m2tInputParser;

  ipp = ipp.addOptional(ipp, 'testFunctionIndices', [], @isfloat);
  ipp = ipp.addParamValue(ipp, 'extraOptions', {}, @iscell);
  ipp = ipp.addParamValue(ipp, 'figureVisible', false, @islogical);
  ipp = ipp.addParamValue(ipp, 'testsuite', @ACID, @(x)(isa(x,'function_handle')));
  ipp = ipp.addParamValue(ipp, 'cleanBefore', true, @islogical);

  ipp = ipp.parse(ipp, varargin{:});
  % -----------------------------------------------------------------------

  testsuite = ipp.Results.testsuite;
  testsuiteName = func2str(testsuite);

  % try to clean the output
  cleanFiles(ipp.Results.cleanBefore);

  % first, initialize the tex output
  texfile = 'tex/acid.tex';
  fh = fopen(texfile, 'w');
  assert(fh ~= -1, 'Could not open TeX file ''%s'' for writing.', texfile);
  texfile_init(fh);

  % output streams
  stdout = 1;
  if strcmp(env, 'Octave') && ~ipp.Results.figureVisible
      % Use the gnuplot backend to work around an fltk bug, see
      % <http://savannah.gnu.org/bugs/?43429>.
      graphics_toolkit gnuplot
  end

  % query the number of test functions
  n = length(testsuite(0));

  defaultStatus = emptyStatus();

  if ~isempty(ipp.Results.testFunctionIndices)
      indices = ipp.Results.testFunctionIndices;
      % kick out the illegal stuff
      I = find(indices>=1 & indices<=n);
      indices = indices(I); %#ok
  else
      indices = 1:n;
  end

  % start overall timing
  elapsedTimeOverall = tic;

  errorHasOccurred = false;

  % cell array to accomodate different structure
  status = cell(length(indices), 1);

  for k = 1:length(indices)
      fprintf(stdout, 'Executing %s test no. %d...\n', testsuiteName, indices(k));

      % open a window
      fig_handle = figure('visible',onOffBoolean(ipp.Results.figureVisible));

      % plot the figure
      try
          status{k} = testsuite(indices(k));

      catch %#ok
          e = lasterror('reset'); %#ok

          status{k}.description = '\textcolor{red}{Error during plot generation.}';
          if isempty(status{k}) || ~isfield(status{k}, 'function') ...
                  || isempty(status{k}.function)
              status{k}.function = extractFunctionFromError(e, testsuite);
          end

          [status{k}.plotStage, errorHasOccurred] = errorHandler(e, env);
      end

      status{k} = fillStruct(status{k}, defaultStatus);

      % plot not successful
      if status{k}.skip
          close(fig_handle);
          continue
      end

      reference_eps = sprintf('data/reference/test%d-reference.eps', indices(k));
      reference_pdf = sprintf('data/reference/test%d-reference.pdf', indices(k));
      reference_fig = sprintf('data/reference/test%d-reference', indices(k));
      gen_tex = sprintf('data/converted/test%d-converted.tex', indices(k));
      gen_pdf  = sprintf('data/converted/test%d-converted.pdf', indices(k));

      elapsedTime = tic;

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
          [status{k}.saveStage, errorHasOccurred] = errorHandler(e, env);
      end
      % now, test matlab2tikz
      try
          cleanfigure(status{k}.extraCleanfigureOptions{:});
          matlab2tikz('filename', gen_tex, ...
                      'showInfo', false, ...
                      'checkForUpdates', false, ...
                      'dataPath', 'data/converted/', ...
                      'standalone', true, ...
                      ipp.Results.extraOptions{:}, ...
                      status{k}.extraOptions{:} ...
                     );
      catch %#ok
          e = lasterror('reset'); %#ok
          % Remove (corrupted) output file. This is necessary to avoid that the
          % Makefile tries to compile it and fails.
          delete(gen_tex)
          [status{k}.tikzStage, errorHasOccurred] = errorHandler(e, env);
      end

      % ...and finally write the bits to the LaTeX file
      texfile_addtest(fh, reference_fig, gen_pdf, status{k}, indices(k), testsuiteName);

      if ~status{k}.closeall
          close(fig_handle);
      else
          close all;
      end

      elapsedTime = toc(elapsedTime);
      fprintf(stdout, '%s ', status{k}.function);
      fprintf(stdout, 'done (%4.2fs).\n\n', elapsedTime);
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
  if errorHasOccurred
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

  % print out overall timing
  elapsedTimeOverall = toc(elapsedTimeOverall);
  fprintf(stdout, 'overall time: %4.2fs\n\n', elapsedTimeOverall);

end
% =========================================================================
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
  alternatives = {'MATLAB','Octave'};
  for iCase = 1:numel(alternatives)
      env   = alternatives{iCase};
      vData = ver(env);
      if ~isempty(vData)
          versionString = vData.Version;
          return; % found the right environment
      end
  end
  % otherwise:
  env = [];
  versionString = [];
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
                       'tikzStage',              emptyStage());
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
