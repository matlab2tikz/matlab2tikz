function makeLatexReport(status, output)
% generate a LaTeX report
%
% 
    if ~exist('output','var')
        output = m2troot('test','output','current');
    end
    % first, initialize the tex output
    SM = StreamMaker();
    stream = SM.make(fullfile(output, 'acid.tex'), 'w');

    texfile_init(stream);

    printFigures(stream, status);
    printSummaryTable(stream, status);
    printErrorMessages(stream, status);
    printEnvironmentInfo(stream, status);

    texfile_finish(stream);
end
% =========================================================================
function texfile_init(stream)

    stream.print(['\\documentclass[landscape]{scrartcl}\n'                , ...
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
function texfile_finish(stream)
    stream.print('\\end{document}');
end
% =========================================================================
function printFigures(stream, status)
    for k = 1:length(status)
        texfile_addtest(stream, status{k});
    end
end
% =========================================================================
function printSummaryTable(stream, status)
    texfile_tab_completion_init(stream)
    for k = 1:length(status)
        stat = status{k};
        testNumber = stat.index;
        % Break table up into pieces if it gets too long for one page
        %TODO: use booktabs instead
        %TODO: maybe just write a function to construct the table at once
        % from a cell array (see makeTravisReport for GFM counterpart)
        if ~mod(k,35)
            texfile_tab_completion_finish(stream);
            texfile_tab_completion_init(stream);
        end

        stream.print('%d & \\texttt{%s}', testNumber, name2tex(stat.function));
        if stat.skip
            stream.print(' & --- & skipped & ---');
        else
            for err = [stat.plotStage.error, ...
                       stat.saveStage.error, ...
                       stat.tikzStage.error]
                if err
                    stream.print(' & \\textcolor{red}{failed}');
                else
                    stream.print(' & \\textcolor{green!50!black}{passed}');
                end
            end
        end
        stream.print(' \\\\\n');
    end
    texfile_tab_completion_finish(stream);
end
% =========================================================================
function printErrorMessages(stream, status)
    if errorHasOccurred(status)
        stream.print('\\section*{Error messages}\n\\scriptsize\n');
        for k = 1:length(status)
            stat = status{k};
            testNumber = stat.index;
            if isempty(stat.plotStage.message) && ...
               isempty(stat.saveStage.message) && ...
               isempty(stat.tikzStage.message)
                continue % No error messages for this test case
            end

            stream.print('\n\\subsection*{Test case %d: \\texttt{%s}}\n', testNumber, name2tex(stat.function));
            print_verbatim_information(stream, 'Plot generation', stat.plotStage.message);
            print_verbatim_information(stream, 'PDF generation' , stat.saveStage.message);
            print_verbatim_information(stream, 'matlab2tikz'    , stat.tikzStage.message);
        end
        stream.print('\n\\normalsize\n\n');
    end
end
% =========================================================================
function printEnvironmentInfo(stream, status)
    [env,versionString] = getEnvironment();

    testsuites = unique(cellfun(@(s) func2str(s.testsuite) , status, ...
                       'UniformOutput', false));
    testsuites = name2tex(m2tstrjoin(testsuites, ', '));

    stream.print(['\\newpage\n',...
                  '\\begin{tabular}{ll}\n',...
                  '  Suite    & ' testsuites ' \\\\ \n', ...
                  '  Created  & ' datestr(now) ' \\\\ \n', ...
                  '  OS       & ' OSVersion ' \\\\ \n',...
                  '  ' env '  & ' versionString ' \\\\ \n', ...
                  VersionControlIdentifier, ...
                  '  TikZ     & \\expandafter\\csname ver@tikz.sty\\endcsname \\\\ \n',...
                  '  Pgfplots & \\expandafter\\csname ver@pgfplots.sty\\endcsname \\\\ \n',...
                  '\\end{tabular}\n']);

end
% =========================================================================
function print_verbatim_information(stream, title, contents)
    if ~isempty(contents)
        stream.print(['\\subsubsection*{%s}\n', ...
                      '\\begin{verbatim}\n%s\\end{verbatim}\n'], ...
                     title, contents);
    end
end
% =========================================================================
function texfile_addtest(stream, status)
% Actually add the piece of LaTeX code that'll later be used to display
% the given test.
    if ~status.skip

        ref_error = status.plotStage.error;
        gen_error = status.tikzStage.error;

        ref_file  = status.saveStage.texReference;
        gen_file  = status.tikzStage.pdfFile;

        stream.print(...
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
                strFormat = '\\includegraphics[width=\\figurewidth]{%s}';
            case 'input'
                strFormat = '\\input{%s}';
            otherwise
                error('Matlab2tikz_acidtest:UnknownFigureCommand', ...
                      'Unknown figure command "%s"', command);
        end
        str = sprintf(strFormat, filename);
    end
end
% =========================================================================
function texfile_tab_completion_init(stream)

    stream.print(['\\clearpage\n\n'                            , ...
                  '\\begin{table}\n'                           , ...
                  '\\centering\n'                              , ...
                  '\\caption{Test case completion summary}\n'  , ...
                  '\\begin{tabular}{rlccc}\n'                  , ...
                  'No. & Test case & Plot & PDF & TikZ \\\\\n' , ...
                  '\\hline\n']);

end
% =========================================================================
function texfile_tab_completion_finish(stream)

    stream.print( ['\\end{tabular}\n' , ...
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
