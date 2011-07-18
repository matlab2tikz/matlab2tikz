% =========================================================================
% *** FUNCTION matlab2xxx_acidtest
% ***
% *** Choose the EPS output driver as the PDF will yield a the plot on a
% *** full page, rather than nicely cropped around the figure.
% ***
% =========================================================================  
% ***
% *** Copyright (c) 2008--2011, Nico Schl\"omer <nico.schloemer@gmail.com>
% *** All rights reserved.
% ***
% *** Redistribution and use in source and binary forms, with or without 
% *** modification, are permitted provided that the following conditions are 
% *** met:
% ***
% ***    * Redistributions of source code must retain the above copyright 
% ***      notice, this list of conditions and the following disclaimer.
% ***    * Redistributions in binary form must reproduce the above copyright 
% ***      notice, this list of conditions and the following disclaimer in 
% ***      the documentation and/or other materials provided with the distribution
% ***
% *** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% *** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% *** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% *** ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% *** LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% *** CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% *** SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% *** INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% *** CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% *** ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% *** POSSIBILITY OF SUCH DAMAGE.
% ***
% =========================================================================
function matlab2tikz_acidtest( varargin )

  % In which environment are we?
  version_data = ver;
  env = version_data(1).Name;
  if ~strcmp( env, 'MATLAB' ) && ~strcmp( env, 'Octave' )
      error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
  end

  % -----------------------------------------------------------------------
  matlab2tikzOpts = matlab2tikzInputParser;

  matlab2tikzOpts = matlab2tikzOpts.addOptional( matlab2tikzOpts, ...
                                                 'testFunctionIndices', ...
                                                 [], @isfloat );

  matlab2tikzOpts = matlab2tikzOpts.parse( matlab2tikzOpts, varargin{:} );
  % -----------------------------------------------------------------------

  % first, initialize the tex outputploterrmsg
  texfile = 'tex/acid.tex';
  fh = fopen( texfile, 'w' );
  texfile_init( fh );

  % query the number of test functions
  [m, n] = testfunctions(0);

  if ~isempty(matlab2tikzOpts.Results.testFunctionIndices)
      indices = matlab2tikzOpts.Results.testFunctionIndices;
      % kick out the illegal stuff
      I = find(indices>=1) & find(indices<=n);
      indices = indices(I);
  else
      indices = 1:n;
  end

  k = 0;
  ploterrmsg = cell( length(indices), 1 );
  tikzerrmsg = cell( length(indices), 1 );
  pdferrmsg  = cell( length(indices), 1 );
  desk = cell( length(indices), 1 );
  for i = indices
      k = k+1;

      fprintf('Treating test function no. %d...\n', i );

      % open a window
      fig_handle = figure;

      % plot the figure
      try
          desc{k} = testfunctions( i );
          ploterror{k} = false;
      catch
          e = lasterror( 'reset' );
          if ~isempty( e.message )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              ploterrmsg{k} = [ ploterrmsg{k}, sprintf( 'error: called from:\n' ) ];
          end
          for i = 1:length( e.stack )
              ploterrmsg{k} = [ ploterrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(i).file, e.stack(i).line, e.stack(i).name ) ];
              if isempty(desc{k}) && ~isempty(regexp(e.stack(i).name, '^testfunctions>'))
                  % extract function name
                  desc{k} = regexprep(e.stack(i).name, '^testfunctions>(.*)', '$1');
                  desc{k} = regexprep(desc{k}, '_', '\_');   % make underscores TeX compatible
              end
          end
          if isempty(desc{k})
              desc{k} = [ '\textcolor{red}{Error during plot generation.}', ...
                          sprintf(' \\texttt{testfunctions( %d )}', k) ];
          else
              desc{k} = [ '\textcolor{red}{Error during plot generation.}', ...
                          sprintf(' \\texttt{%s}', desc{k}) ];
          end
          fprintf( ploterrmsg{k} )
          ploterror{k} = true;
      end

      % plot not sucessful
      if isempty(desc{k})
          close( fig_handle );
          continue
      end

      pdf_file = sprintf( 'data/test%d-reference' , k );
      gen_file = sprintf( 'data/test%d-converted.tikz', k );

      tic;

      % now, test matlab2xxx
      try
          matlab2tikz( gen_file, 'silent', true,...
                                 'relativePngPath', '../data/', ...
                                 'width', '\figurewidth' );
          tikzerror{k} = false;
      catch
          e = lasterror('reset');
          if ~isempty( e.message )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              tikzerrmsg{k} = [ tikzerrmsg{k}, sprintf('error: called from:\n') ];
          end
          for i = 1:length(e.stack)
              tikzerrmsg{k} = [ tikzerrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(i).file, e.stack(i).line, e.stack(i).name ) ];
          end
          fprintf( tikzerrmsg{k} )
          tikzerror{k} = true;
      end

      % Save reference output as PDF
      try
          switch env
              case 'MATLAB'
                  % Create a cropped print.
                  savefig( pdf_file, 'pdf' );
              case 'Octave'
                  % In Octave, figures are automatically cropped when using print().
                  print( strcat(pdf_file,'.pdf'), '-dpdf', '-S415,311', '-r150' );
                  pause( 1.0 )
              otherwise
                  error( 'Unknown environment. Need MATLAB(R) or GNU Octave.' )
          end
          pdferror{k} = false;
      catch
          e = lasterror('reset');
          if ~isempty( e.message )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf( 'error: %s\n', e.message ) ];
          end
          if ~isempty( e.identifier )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf( 'error: %s\n', e.identifier ) ];
          end
          if ~isempty( e.stack )
              pdferrmsg{k} = [ pdferrmsg{k}, sprintf('error: called from:\n') ];
          end
          for i = 1:length(e.stack)
              pdferrmsg{k} = [ pdferrmsg{k}, ...
                                sprintf( 'error:   %s at line %d, in function %s\n', ...
                                         e.stack(i).file, e.stack(i).line, e.stack(i).name ) ];
          end
          fprintf( pdferrmsg{k} )
          pdferror{k} = true;
      end

      % ...and finally write the bits to the LaTeX file
      texfile_addtest( fh, pdf_file, gen_file, desc{k}, pdferror{k}, tikzerror{k} );

      % After 10 floats, put a \clearpage to avoid
      %
      %   ! LaTeX Error: Too many unprocessed floats.
      if ~mod(k,10)
          fprintf( fh, '\\clearpage\n\n' );
      end

      close( fig_handle );

      elapsedTime = toc;
      fprintf( 'done (%4.2fs).\n\n', elapsedTime );
  end

  % Write the summary table to the LaTeX file
  texfile_tab_completion_init( fh )
  k = 0;
  for i = indices
      k = k+1;
      % Break table up into pieces if it gets too long for one page
      if ~mod(k,35)
          texfile_tab_completion_finish( fh );
          texfile_tab_completion_init( fh );
      end

      fprintf( fh, '%d &', i );
      if isempty( desc{k} )
          fprintf( fh, ' & --- & skipped & ---' );
      else
          fprintf( fh, ' %s', regexprep(desc{k}, '.*(\\texttt{.*}).*', '$1') );
          for err = [ ploterror{k}, pdferror{k}, tikzerror{k} ]
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

  % Write the error messages to the LaTeX file
  fprintf( fh, '\\section*{Error messages}\n\\scriptsize\n' );
  k = 0;
  for i = indices
      k = k+1;
      if ~isempty( ploterrmsg{k} ) || ~isempty( tikzerrmsg{k} ) || ~isempty( pdferrmsg{k} )
          % There are error messages for this test case
          fprintf( fh, '\n\\subsection*{Test case %d}\n', i );
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

  % now, finish off the file and close file and window
  texfile_finish( fh );
  fclose( fh );

end
% =========================================================================
function texfile_init( texfile_handle )

  fprintf( texfile_handle                                             , ...
           [ '\\documentclass{scrartcl}\n\n'                          , ...
             '\\usepackage{graphicx}\n'                               , ...
             '\\usepackage{tikz}\n'                                   , ...
             '\\usetikzlibrary{plotmarks}\n\n'                        , ...
             '\\usepackage{pgfplots}\n'                               , ...
             '\\pgfplotsset{compat=newest}\n\n'                       , ...
             '\\newlength\\figurewidth\n'                             , ...
             '\\setlength\\figurewidth{7cm}\n\n'                      , ...
             '\\begin{document}\n\n'         ] );

end
% =========================================================================
function texfile_finish( texfile_handle )

  fprintf( texfile_handle, '\\end{document}' );

end
% =========================================================================
% *** FUNCTION texfile_addtest
% ***
% *** Actually add the piece of LaTeX code that'll later be used to display
% *** the given test.
% ***
function texfile_addtest( texfile_handle, ref_file, gen_file, desc, ...
                          ref_error, gen_error )

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
  fprintf ( texfile_handle                                            , ...
            [ 'reference rendering & generated\n'                     , ...
              '\\end{tabular}\n'                                      , ...
              '\\caption{%s}\n'                                       , ...
              '\\end{figure}\n\n'                                    ], ...
              desc                                                      ...
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