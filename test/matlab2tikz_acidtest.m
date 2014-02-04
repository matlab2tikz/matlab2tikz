function matlab2tikz_acidtest( varargin )
%MATLAB2TIKZ_ACIDTEST    unit test driver for matlab2tikz
%
% MATLAB2TIKZ_ACIDTEST('testFunctionIndices', INDICES, ...) or
%   MATLAB2TIKZ_ACIDTEST(INDICES, ...) runs the test only for the specified
%   indices. When empty, all tests are run. (Default: []).
%
% MATLAB2TIKZ_ACIDTEST('extraOptions', {'name',value, ...}, ...)
%   passes the cell array of options to MATLAB2TIKZ. Default: {}
%
% See also matlab2tikz, testfunctions


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
  if ~strcmp( env, 'MATLAB' ) && ~strcmp( env, 'Octave' )
      error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
  end

  % -----------------------------------------------------------------------
  matlab2tikzOpts = matlab2tikzInputParser;

  matlab2tikzOpts = matlab2tikzOpts.addOptional( matlab2tikzOpts, ...
                                                 'testFunctionIndices', ...
                                                 [], @isfloat );
  matlab2tikzOpts = matlab2tikzOpts.addParamValue( matlab2tikzOpts, ...
                                                 'extraOptions', {}, @iscell);

  matlab2tikzOpts = matlab2tikzOpts.parse( matlab2tikzOpts, varargin{:} );
  % -----------------------------------------------------------------------

  % first, initialize the tex output
  texfile = 'tex/acid.tex';
  fh = fopen( texfile, 'w' );
  texfile_init( fh );

  % output streams
  stdout = 1;
  stderr = 2;

  % query the number of test functions
  [dummya, dummyb, dummyc, dummy, n] = testfunctions(0);

  if ~isempty(matlab2tikzOpts.Results.testFunctionIndices)
      indices = matlab2tikzOpts.Results.testFunctionIndices;
      % kick out the illegal stuff
      I = find(indices>=1) & find(indices<=n);
      indices = indices(I);
  else
      indices = 1:n;
  end

  ploterrmsg = cell( length(indices), 1 );
  tikzerrmsg = cell( length(indices), 1 );
  pdferrmsg  = cell( length(indices), 1 );
  ploterror = false( length(indices), 1 );
  tikzerror = false( length(indices), 1 );
  pdferror  = false( length(indices), 1 );
  desc = cell( length(indices), 1 );
  funcName = cell( length(indices), 1 );
  for k = 1:length(indices)
      fprintf( stdout, 'Executing test case no. %d...\n', indices(k) );

      % open a window
      fig_handle = figure;

      % plot the figure
      try
          [desc{k}, extraOpts, extraCFOpts, funcName{k}] = testfunctions( indices(k) );
      catch %#ok
          e = lasterror( 'reset' ); %#ok
          if ~isempty( e.message )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: called from:\n' ) ];
          end
          for j = 1:length( e.stack )
              ploterrmsg{k} = [ ploterrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(j).file, e.stack(j).line, e.stack(j).name ) ];
              if isempty(funcName{k}) && ~isempty(regexp(e.stack(j).name, '^testfunctions>','once'))
                  % extract function name
                  funcName{k} = regexprep(e.stack(j).name, '^testfunctions>(.*)', '$1');
              end
          end
          desc{k} = '\textcolor{red}{Error during plot generation.}';
          % When displaying the error message in MATLAB, all backslashes
          % have to be replaced by two backslashes. This must not, however,
          % be applied constantly as the string that's saved to the LaTeX
          % output must have only one backslash.
          if strcmp( env, 'MATLAB' )
              fprintf( stderr,  strrep( ploterrmsg{k}, '\', '\\' ) );
          else
              fprintf( stderr, ploterrmsg{k} );
          end
          ploterror(k) = true;
      end

      % plot not sucessful
      if isempty(desc{k})
          close( fig_handle );
          continue
      end

      pdf_file = sprintf( 'data/test%d-reference.pdf' , indices(k) );
      eps_file = sprintf( 'data/test%d-reference.eps' , indices(k) );
      gen_file = sprintf( 'data/test%d-converted.tex', indices(k) );

      tic;
      % Save reference output as PDF
      try
          switch env
              case 'MATLAB'
                  %% Make the inset tight.
                  %ti = get(gca, 'TightInset');
                  %set(gca, ...
                  %    'Position', [ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

                  %set(gca, 'units', 'centimeters')
                  %pos = get(gca, 'Position');
                  %ti = get(gca, 'TightInset');

                  %set(gcf, ...
                  %    'PaperUnits', 'centimeters');
                  %set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
                  %set(gcf, 'PaperPositionMode', 'manual');
                  %set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
                  %print(pdf_file, '-dpdf');
                  % Create a cropped PDF.
                  % Unfortunately, MATLAB cannot do that directly, so first
                  % create an EPS (which has a tight bounding box) and then
                  % convert it to PDF.
                  print(gcf, '-depsc2', eps_file);
                  eps2pdf(eps_file);
                  %print(gcf, '-dpdf', pdf_file);
                  %savefig( pdf_file, 'pdf' );
              case 'Octave'
                  % In Octave, figures are automatically cropped when using print().
                  print(pdf_file, '-dpdf', '-S415,311', '-r150' );
                  pause( 1.0 )
              otherwise
                  error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
          end
      catch %#ok
          e = lasterror('reset'); %#ok
          if ~isempty( e.message )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf('error: called from:\n') ];
          end
          for j = 1:length(e.stack)
              pdferrmsg{k} = [ pdferrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(j).file, e.stack(j).line, e.stack(j).name ) ];
          end
          % When displaying the error message in MATLAB, all backslashes
          % have to be replaced by two backslashes. This must not, however,
          % be applied constantly as the string that's saved to the LaTeX
          % output must have only one backslash.
          if strcmp( env, 'MATLAB' )
              fprintf( stderr, strrep( pdferrmsg{k}, '\', '\\' ) );
          else
              fprintf( stderr, pdferrmsg{k} );
          end
          pdferror(k) = true;
      end
      % now, test matlab2tikz
      try
          cleanfigure(extraCFOpts{:});
          matlab2tikz('filename', gen_file, ...
                      'showInfo', false, ...
                      'checkForUpdates', false, ...
                      'relativeDataPath', '../data/', ...
                      'width', '\figurewidth', ...
                      matlab2tikzOpts.Results.extraOptions{:}, ...
                      extraOpts{:} ...
                      );
      catch %#ok
          e = lasterror('reset'); %#ok
          if ~isempty( e.message )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf('error: called from:\n') ];
          end
          for j = 1:length(e.stack)
              tikzerrmsg{k} = [ tikzerrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(j).file, e.stack(j).line, e.stack(j).name ) ];
          end
          % When displaying the error message in MATLAB, all backslashes
          % have to be replaced by two backslashes. This must not, however,
          % be applied constantly as the string that's saved to the LaTeX
          % output must have only one backslash.
          if strcmp( env, 'MATLAB' )
              fprintf( stderr, strrep( tikzerrmsg{k}, '\', '\\' ) );
          else
              fprintf( stderr, tikzerrmsg{k} );
          end
          tikzerror(k) = true;
      end
      
      % Add new entries as they should be discovered
      manualCloseFuncs = {'freqResponsePlot', ... 
                          'zplanePlot2'}; 
      
      if ismember(funcName{k},manualCloseFuncs)
          closeAll = true;
      else
          closeAll = false;
      end

      % Make underscores in function names TeX compatible
      funcName{k} = strrep( funcName{k}, '_', '\_' );

      % ...and finally write the bits to the LaTeX file
      texfile_addtest(fh, pdf_file, gen_file, desc{k}, funcName{k}, ...
                      indices(k), pdferror(k), tikzerror(k));

      if ~closeAll
          close( fig_handle );
      else
          close all;
      end

      elapsedTime = toc;
      fprintf( stdout, '%s ', strrep( funcName{k}, '\_', '_' ) );
      fprintf( stdout, 'done (%4.2fs).\n\n', elapsedTime );
  end

  % Write the summary table to the LaTeX file
  texfile_tab_completion_init( fh )
  for k = 1:length(indices)
      % Break table up into pieces if it gets too long for one page
      if ~mod(k,35)
          texfile_tab_completion_finish( fh );
          texfile_tab_completion_init( fh );
      end

      fprintf( fh, '%d & \\texttt{%s}', indices(k), funcName{k} );
      if isempty( desc{k} )
          fprintf( fh, ' & --- & skipped & ---' );
      else
          for err = [ ploterror(k), pdferror(k), tikzerror(k) ]
              if err
                  fprintf( fh, ' & \\textcolor{red}{failed}' );
              else
                  fprintf( fh, ' & \\textcolor{green!50!black}{passed}' );
              end
          end
      end
      fprintf( fh, ' \\\\\n' );
  end
  texfile_tab_completion_finish( fh );

  % Write the error messages to the LaTeX file if there are any
  if any( [ploterror ; tikzerror ; pdferror ] )
      fprintf( fh, '\\section*{Error messages}\n\\scriptsize\n' );
      for k = 1:length(indices)
          if ~isempty( ploterrmsg{k} ) || ~isempty( tikzerrmsg{k} ) || ~isempty( pdferrmsg{k} )
              % There are error messages for this test case
              fprintf( fh, '\n\\subsection*{Test case %d: \\texttt{%s}}\n', indices(k), funcName{k} );
          else
              % No error messages for this test case
              continue
          end
          if ~isempty( ploterrmsg{k} )
              fprintf( fh, [ '\\subsubsection*{Plot generation}\n'  , ...
                             '\\begin{verbatim}\n'                  , ...
                             '%s'                                   , ...
                             '\\end{verbatim}\n'                   ], ...
                             ploterrmsg{k}                         );
          end
          if ~isempty( pdferrmsg{k} )
              fprintf( fh, [ '\\subsubsection*{PDF generation}\n'   , ...
                             '\\begin{verbatim}\n'                  , ...
                             '%s'                                   , ...
                             '\\end{verbatim}\n'                   ], ...
                             pdferrmsg{k}                          );
          end
          if ~isempty( tikzerrmsg{k} )
              fprintf( fh, [ '\\subsubsection*{matlab2tikz}\n'      , ...
                             '\\begin{verbatim}\n'                  , ...
                             '%s'                                   , ...
                             '\\end{verbatim}\n'                   ], ...
                             tikzerrmsg{k}                         );
          end
      end
      fprintf( fh, '\n\\normalsize\n\n' );
  end

  % now, finish off the file and close file and window
  texfile_finish( fh );
  fclose( fh );

end
% =========================================================================
function texfile_init( texfile_handle )

  fprintf( texfile_handle                                            , ...
           [ '\\documentclass[landscape]{scrartcl}\n'                , ...
             '\\pdfminorversion=6\n\n', ...
             '\\usepackage{amsmath} %% required for $\text{xyz}$\n\n', ...
             '\\usepackage{graphicx}\n'                              , ...
             '\\usepackage{tikz}\n'                                  , ...
             '\\usetikzlibrary{plotmarks}\n\n'                       , ...
             '\\usepackage{pgfplots}\n'                              , ...
             '\\pgfplotsset{compat=newest}\n\n'                      , ...
             '\\usepackage[margin=0.5in]{geometry}\n'                , ...
             '\\newlength\\figurewidth\n'                            , ...
             '\\setlength\\figurewidth{0.4\\textwidth}\n\n'          , ...
             '\\begin{document}\n\n'         ] );

end
% =========================================================================
function texfile_finish( texfile_handle )

  fprintf( texfile_handle, '\\end{document}' );

end
% =========================================================================
function texfile_addtest( texfile_handle, ref_file, gen_file, desc, ...
                          funcName, funcId, ref_error, gen_error )
  % Actually add the piece of LaTeX code that'll later be used to display
  % the given test.

  fprintf ( texfile_handle                                            , ...
            [ '\\begin{figure}\n'                                     , ...
              '\\centering\n'                                         , ...
              '\\begin{tabular}{cc}\n'                               ]  ...
          );
  if ~ref_error
      fprintf ( texfile_handle                                        , ...
                  '\\includegraphics[width=\\figurewidth]{../%s}\n'   , ...
                  ref_file                                              ...
              );
  else
      fprintf ( texfile_handle                                        , ...
                [ '\\tikz{\\draw[red,thick] '                         , ...
                  '(0,0) -- (\\figurewidth,\\figurewidth) '           , ...
                  '(0,\\figurewidth) -- (\\figurewidth,0);}\n'       ]  ...
              );
  end
      fprintf ( texfile_handle                                        , ...
                  '&\n'                                                 ...
              );
  if ~gen_error
      fprintf ( texfile_handle                                        , ...
                  '\\input{../%s}\\\\\n'                              , ...
                  gen_file                                              ...
              );
  else
      fprintf ( texfile_handle                                        , ...
                [ '\\tikz{\\draw[red,thick] '                         , ...
                  '(0,0) -- (\\figurewidth,\\figurewidth) '           , ...
                  '(0,\\figurewidth) -- (\\figurewidth,0);}\\\\\n'   ]  ...
              );
  end
  fprintf ( texfile_handle                       , ...
            [ 'reference rendering & generated\n', ...
              '\\end{tabular}\n'                 , ...
              '\\caption{%s \\texttt{%s}, \\texttt{testFunctions(%d)}}\n', ...
              '\\end{figure}\n'                  , ...
              '\\clearpage\n\n'                 ], ...
              desc, funcName, funcId               ...
          );

end
% =========================================================================
function texfile_tab_completion_init( texfile_handle )

  fprintf( texfile_handle                                             , ...
           [ '\\clearpage\n\n'                                        , ...
             '\\begin{table}\n'                                       , ...
             '\\centering\n'                                          , ...
             '\\caption{Test case completion summary}\n'              , ...
             '\\begin{tabular}{rlccc}\n'                              , ...
             'No. & Test case & Plot & PDF & TikZ \\\\\n'           , ...
             '\\hline\n'                                             ] );

end
% =========================================================================
function texfile_tab_completion_finish( texfile_handle )

  fprintf( texfile_handle                                             , ...
           [ '\\end{tabular}\n'                                       , ...
             '\\end{table}\n\n'                                      ] );

end
% =========================================================================
function env = getEnvironment()
  env = '';
  % Check if we are in MATLAB or Octave.
  % `ver' in MATLAB gives versioning information on all installed packages
  % separately, and there is no guarantee that MATLAB itself is listed first.
  % Hence, loop through the array and try to find 'MATLAB' or 'Octave'.
  versionData = ver;
  for k = 1:max(size(versionData))
      if strcmp( versionData(k).Name, 'MATLAB' )
          env = 'MATLAB';
          break;
      elseif strcmp( versionData(k).Name, 'Octave' )
          env = 'Octave';
          break;
      end
  end
end
% =========================================================================
