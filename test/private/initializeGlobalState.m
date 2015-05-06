function orig = initializeGlobalState()
% Initialize global state. Set various properties of the graphical root to ensure reliable output of the ACID testsuite.
% See #542 and #552
    fprintf('Initialize global state...\n');
    
    % Obtain complete global state
    state_complete = get(0);

    % Define desired global state properties
    % See http://undocumentedmatlab.com/blog/getundoc-get-undocumented-object-properties
    new.ScreenPixelsPerInch = 96;
    new.defaultAxesColorOrder =       ...
        [0,0,1;0,0.500,0;1,0,0;0,0.750,0.750;   ...
        0.750,0,0.750;0.750,0.750,0;0.250,0.250,0.250;];
    
    % Extract relevant properties and select desired state
    switch getEnvironment
        case 'MATLAB'
            % --- ScreenPixelsPerInch: Known to influence `width` and `at`
            orig.ScreenPixelsPerInch = ...
                swap_property_state(0, ...
                    'ScreenPixelsPerInch', new.ScreenPixelsPerInch);

            % --- defaultAxesColorOrder
            orig.defaultAxesColorOrder = ...
                swap_property_state(0, ...
                    'defaultAxesColorOrder', new.defaultAxesColorOrder);

        case 'Octave'
            % --- ScreenPixelsPerInch: Known to influence `width` and `at`
            % setting this property in Octave seems unsupported
            orig.ScreenPixelsPerInch = ...
                swap_property_state(0, ...
                    'ScreenPixelsPerInch');

            % --- defaultAxesColorOrder
            orig.defaultAxesColorOrder = ...
                swap_property_state(0, ...
                    'defaultAxesColorOrder', new.defaultAxesColorOrder);

        otherwise
            error('matlab2tikz:UnknownEnvironment', ...
                 'Unknown environment. Need MATLAB(R) or GNU Octave.')
    end
end

function old = swap_property_state(h, property, new)
    % read current property of graphical object
    % set new value, if not empty
    if nargin < 3, new = []; end

    old = get(h, property);

    if ~isempty(new)
        set(h, property, new);
    end
end
