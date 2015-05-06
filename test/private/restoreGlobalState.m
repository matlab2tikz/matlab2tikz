function restoreGlobalState(state_orig)
% Restore original properties of global state.
% See #542 and #552
    fprintf('Restore global state...\n');
    
    % Restore relevant properties
    % --- ScreenPixelsPerInch: Known to influence `width` and `at`
    switch getEnvironment
        case 'MATLAB'
            set(0,'ScreenPixelsPerInch',state_orig.ScreenPixelsPerInch);

        case 'Octave'
            % setting in Octave seems unsupported
            %set(0,'screenpixelsperinch',state_orig.ScreenPixelsPerInch);

        otherwise
            error('matlab2tikz:UnknownEnvironment', ...
                 'Unknown environment. Need MATLAB(R) or GNU Octave.')
    end
end
