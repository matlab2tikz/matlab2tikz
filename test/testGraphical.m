function [ status ] = testGraphical( varargin )
%TESTGRAPHICAL Runs the M2T test suite to produce graphical output
%
% This is quite a thin wrapper around testMatlab2tikz to run the test suite to
% produce a PDF side-by-side report.
%
% Its allowed arguments are the same as those of testMatlab2tikz.
%
% Usage:
%
%     status = testGraphical(...) % gives programmatical access to the data
%
%     testGraphical(...); % automatically invokes makeLatexReport afterwards
%
% See also: testMatlab2tikz, testHeadless, makeLatexReport

    [state] = initializeGlobalState();
    finally_restore_state = onCleanup(@() restoreGlobalState(state));

    [status, args] = testMatlab2tikz('actionsToExecute', @actionsToExecute, ...
                                     varargin{:});

    if nargout == 0
        makeLatexReport(status, args.output);
    end
end
% ==============================================================================
function status = actionsToExecute(status, ipp)
    status = execute_plot_stage(status, ipp);

    if status.skip
        return
    end

    status = execute_save_stage(status, ipp);
    status = execute_tikz_stage(status, ipp);
    %status = execute_hash_stage(status, ipp); %cannot work with files in
    %standalone mode!
    status = execute_type_stage(status, ipp);

    if ~status.closeall && ~isempty(status.plotStage.fig_handle)
        close(status.plotStage.fig_handle);
    else
        close all;
    end
end
% ==============================================================================
