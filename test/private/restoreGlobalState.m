function restoreGlobalState(orig)
% Restore original properties of global state.
% See #542 and #552
    fprintf('Restore global state...\n');
    
    % Restore relevant properties
    switch getEnvironment
        case 'MATLAB'
            % --- ScreenPixelsPerInch: Known to influence `width` and `at`
            set(0,'ScreenPixelsPerInch',orig.ScreenPixelsPerInch);

            % --- defaultAxesColorOrder
            set(0,'defaultAxesColorOrder',orig.defaultAxesColorOrder);

        case 'Octave'
            % --- ScreenPixelsPerInch: Known to influence `width` and `at`
            % setting this property in Octave seems unsupported
            %set(0,'screenpixelsperinch',orig.ScreenPixelsPerInch);

            % --- defaultAxesColorOrder
            set(0,'defaultAxesColorOrder',orig.defaultAxesColorOrder);

        otherwise
            error('matlab2tikz:UnknownEnvironment', ...
                 'Unknown environment. Need MATLAB(R) or GNU Octave.')
    end
end
