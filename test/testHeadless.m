function [ status ] = testHeadless( varargin )
%TESTGRAPHICAL Runs the M2T test suite without graphical output
%
% This is quite a thin wrapper around testMatlab2tikz to run the test suite to
% produce a textual report and checks for regressions by checking the MD5 hash
% of the output
%
% Its allowed arguments are the same as those of testMatlab2tikz.
%
% Usage:
%
%     status = TESTHEADLESS(...) % gives programmatical access to the data
%
%     TESTHEADLESS(...); % automatically invokes makeTravisReport afterwards
%
% See also: testMatlab2tikz, testGraphical, makeTravisReport

% The width and height are specified to circumvent different DPIs in developer
% machines. The float format reduces the probability that numerical differences
% in the order of numerical precision disrupt the output.
    extraOptions = {'width' ,'\figureWidth', ...
                    'height','\figureHeight',...
                    'floatFormat', '%4g',    ... % see #604
                    'extraCode',{            ...
                        '\newlength\figureHeight \setlength{\figureHeight}{6cm}', ...
                        '\newlength\figureWidth \setlength{\figureWidth}{10cm}'}
                   };

    [state] = initializeGlobalState();
    finally_restore_state = onCleanup(@() restoreGlobalState(state));

    status = testMatlab2tikz('extraOptions', extraOptions, ...
                             'actionsToExecute', @actionsToExecute, ...
                             varargin{:});

    if nargout == 0
        makeTravisReport(status);
    end
end
% ==============================================================================
function status = actionsToExecute(status, ipp)
    status = execute_plot_stage(status, ipp);

    if status.skip
        return
    end

    status = execute_tikz_stage(status, ipp);
    status = execute_hash_stage(status, ipp);
    status = execute_type_stage(status, ipp);

    if ~status.closeall && ~isempty(status.plotStage.fig_handle)
        try
            close(status.plotStage.fig_handle);
        catch
            close('all');
        end
    else
        close all;
    end
end
% ==============================================================================
