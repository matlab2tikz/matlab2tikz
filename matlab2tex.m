% =========================================================================
% *** FUNCTION matlab2latex
% ***
% *** Convert figures to TikZ (using pgfplots) for inclusion in LaTeX
% *** documents.
% ***
% =========================================================================  
% ***
% *** Copyright (c) 2008, 2009, Nico Schlömer <nico.schloemer@ua.ac.be>
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
function matlab2xxx_acidtest( matlab2xxx_handle )

  % first, initialize the tex output
  texfile = 'tex/acid.tex';
  fh = fopen( texfile, 'w' );
  texfile_init( fh );

  k = 0;
  while 1
      k = k+1;

      % open a window
      fig_handle = figure;

      pdf_file = sprintf( 'data/test%d-reference' , k );
      gen_file = sprintf( 'data/test%d-converted.tikz', k );

      % plot the figure
      [ desc, error ] = testfunctions( k );

      if error
          close( fig_handle );
          break;
      end

      % now, test matlab2xxx
      matlab2xxx_handle( gen_file );

      % Create a copy, which we can modify (which 'savefig' does)
      savefig( pdf_file, 'pdf' );

      % ...and finally write the bits to the LaTeX file
      texfile_addtest( fh, pdf_file, gen_file, desc );

      % After 10 floats, but a \clearpage to avoid
      %
      %   ! LaTeX Error: Too many unprocessed floats.
      if ~mod(k,10)
          fprintf( fh, '\\clearpage\n\n' );
      end

      close( fig_handle );
  end

  % now, finish off the file and close file and window
  texfile_finish( fh );
  fclose( fh );

end
% =========================================================================
% *** END OF FUNCTION matlab2xxx_acidtest
% =========================================================================



% =========================================================================
% *** FUNCTION texfile_init
% =========================================================================
function texfile_init( texfile_handle )

  fprintf( texfile_handle                                             , ...
           [ '\\documentclass{scrartcl}\n\n'                          , ...
             '\\usepackage{graphicx}\n'                               , ...
             '\\usepackage{tikz}\n'                                   , ...
             '\\usetikzlibrary{plotmarks}\n\n'                        , ...
             '\\usepackage{pgfplots}\n\n'                              , ...
             '\\begin{document}\n\n'         ] );

end
% =========================================================================
% *** END OF FUNCTION texfile_init
% =========================================================================



% =========================================================================
% *** FUNCTION texfile_finish
% =========================================================================
function texfile_finish( texfile_handle )

  fprintf( texfile_handle, '\\end{document}' );

end
% =========================================================================
% *** END OF FUNCTION texfile_finish
% =========================================================================



% =========================================================================
% *** FUNCTION texfile_addtest
% ***
% *** Actually add the piece of LaTeX code that'll later be used to display
% *** the given test.
% ***
% =========================================================================
function texfile_addtest( texfile_handle, ref_file, gen_file, desc )

  fprintf ( texfile_handle                                            , ...
            [ '\\begin{figure}\n'                                     , ...
              '\\centering\n'                                         , ...
              '\\begin{tabular}{cc}\n'                                , ...
              '\\includegraphics[width=7cm]{../%s}\n'                 , ...
              '&\n'                                                   , ...
              '\\input{../%s}\\\\\n'                                  , ...
              'reference rendering & generated\n'                     , ...
              '\\end{tabular}\n'                                      , ...
              '\\caption{%s}\n'                                       , ...
              '\\end{figure}\n\n'                                    ], ...
              ref_file, gen_file, desc                                  ...
          );

end
% =========================================================================
% *** END OF FUNCTION texfile_addtest
% =========================================================================