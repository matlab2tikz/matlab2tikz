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
