function [status] = execute_plot_stage(defaultStatus, ipp)
% plot a test figure
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
        [status.plotStage, errorHasOccurred] = errorHandler(e);
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
