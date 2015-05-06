function state_orig = initializeGlobalState()
% Initialize global state. Set various properties of the graphical root to ensure reliable output of the ACID testsuite.
% See #542 and #552
    fprintf('Initialize global state...\n');
    
    % Obtain complete global state
    state_complete = get(0);

    % Define desired global state properties
    % See http://undocumentedmatlab.com/blog/getundoc-get-undocumented-object-properties
    state_desired.ScreenPixelsPerInch = 96;
    
    % Extract relevant properties and select desired state
    % --- ScreenPixelsPerInch: Known to influence `width` and `at`
    switch getEnvironment
        case 'MATLAB'
            state_orig.ScreenPixelsPerInch = ...
                state_complete.ScreenPixelsPerInch;
            set(0,'ScreenPixelsPerInch',state_desired.ScreenPixelsPerInch);

        case 'Octave'
            state_orig.ScreenPixelsPerInch = ...
                state_complete.screenpixelsperinch;
            % setting in Octave seems unsupported
            %set(0,'screenpixelsperinch',state_desired.ScreenPixelsPerInch);

        otherwise
            error('matlab2tikz:UnknownEnvironment', ...
                 'Unknown environment. Need MATLAB(R) or GNU Octave.')
    end
end
