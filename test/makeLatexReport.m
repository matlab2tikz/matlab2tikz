function makeLatexReport(status)
% generate a LaTeX report

    % first, initialize the tex output
    texfile = 'tex/acid.tex';
    fh = fopen(texfile, 'w');
    finally_fclose_fh = onCleanup(@() fclose(fh));

    assert(fh ~= -1, 'Could not open TeX file ''%s'' for writing.', texfile);
    texfile_init(fh);

    for k = 1:length(status)
        % ...and finally write the bits to the LaTeX file
        texfile_addtest(fh, status{k});
    end

    % Write the summary table to the LaTeX file
    texfile_tab_completion_init(fh)
    for k = 1:length(status)
        stat = status{k};
        testNumber = stat.index;
        % Break table up into pieces if it gets too long for one page
        if ~mod(k,35)
            texfile_tab_completion_finish(fh);
            texfile_tab_completion_init(fh);
        end

        fprintf(fh, '%d & \\texttt{%s}', testNumber, name2tex(stat.function));
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
        for k = 1:length(status)
            stat = status{k};
            testNumber = stat.index;
            if isempty(stat.plotStage.message) && ...
               isempty(stat.saveStage.message) && ...
               isempty(stat.tikzStage.message)
                continue % No error messages for this test case
            end

            fprintf(fh, '\n\\subsection*{Test case %d: \\texttt{%s}}\n', testNumber, name2tex(stat.function));
            print_verbatim_information(fh, 'Plot generation', stat.plotStage.message);
            print_verbatim_information(fh, 'PDF generation' , stat.saveStage.message);
            print_verbatim_information(fh, 'matlab2tikz'    , stat.tikzStage.message);
        end
        fprintf(fh, '\n\\normalsize\n\n');
    end

    texfile_finish(fh, status);
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
function texfile_finish(texfile_handle, status)

    [env,versionString] = getEnvironment();

    testsuites = unique(cellfun(@(s) func2str(s.testsuite) , status, ...
                       'UniformOutput', false));                 
    testsuites = name2tex(m2tstrjoin(testsuites, ', '));

    fprintf(texfile_handle, ...
        [
        '\\newpage\n',...
        '\\begin{tabular}{ll}\n',...
        '  Suite    & ' testsuites ' \\\\ \n', ...
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
function texfile_addtest(texfile_handle, status)
% Actually add the piece of LaTeX code that'll later be used to display
% the given test.
    if ~status.skip

        ref_error = status.plotStage.error;
        gen_error = status.tikzStage.error;

        ref_file  = status.saveStage.texReference;
        gen_file  = status.tikzStage.pdfFile;

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
                include_figure(gen_error, 'includegraphics', gen_file), ...
                status.description, ...
                name2tex(status.function), name2tex(status.testsuite), status.index, ...
                formatIssuesForTeX(status.issues));
    end
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
function texName = name2tex(matlabIdentifier)
% convert a MATLAB identifier/function handle to a TeX string
    if isa(matlabIdentifier, 'function_handle')
        matlabIdentifier = func2str(matlabIdentifier);
    end
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
% ==============================================================================
