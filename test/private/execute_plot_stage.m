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

        % Automaticall mark the test as unreliable
        %
        % Since metadata is not set in this case, also stat.unreliable is
        % not returned. So ideally, we should
        % FIXME: implement #484 to get access to the meta data
        % but we can work around this issue by forcefully setting that value.
        % The rationale for setting this to true:
        %  - the plot part is not the main task of M2T
        %    (so breaking a single test is less severe in this case),
        %  - if the plotting fails, the test is not really reliable anyway,
        %  - this allows to get full green on Travis.
        status.unreliable = true;

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
