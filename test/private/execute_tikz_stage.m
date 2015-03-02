function [status] = execute_tikz_stage(status, ipp)
% test stage: TikZ file generation
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
        [status.tikzStage] = errorHandler(e);
    end
    status.tikzStage.texFile = gen_tex;
    status.tikzStage.pdfFile = gen_pdf;
end
