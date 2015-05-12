function orig = initializeGlobalState()
% Initialize global state. Set various properties of the graphical root to ensure reliable output of the ACID testsuite.
% See #542 and #552
    fprintf('Initialize global state...\n');

    %--- Define desired global state properties
    % See http://undocumentedmatlab.com/blog/getundoc-get-undocumented-object-properties
    new.defaultAxesColorOrder.val   =               ...
        [0,0,1;0,0.500,0;1,0,0;0,0.750,0.750;   ...
        0.750,0,0.750;0.750,0.750,0;0.250,0.250,0.250;];
    new.defaultAxesColorOrder.ignore= 0;

    new.defaultFigureColor.val      = [1,1,1];
    new.defaultFigureColor.ignore   = 0;

    new.defaultFigurePosition.val   = [300,200,560,420];
    new.defaultFigurePosition.ignore= 0;

    new.screenDepth.val             = 24;
    % not possible in octave; didn't want to duplicate private functions for now
    new.screenDepth.ignore          = strcmpi(getEnvironment,'octave'); 

    new.ScreenPixelsPerInch.val     = 96;
    % not possible in octave; didn't want to duplicate private functions for now
    new.ScreenPixelsPerInch.ignore  = strcmpi(getEnvironment,'octave'); 

    %--- Extract relevant properties and select desired state
    f = fieldnames(new);    % fields of new state
    for i = 1:length(f)
        % ignore property on specified environments
        if ~new.(f{i}).ignore
            orig.(f{i}).val = swap_property_state(0, f{i}, new.(f{i}).val);
        end
    end
end
% =========================================================================
function old = swap_property_state(h, property, new)
    % read current property of graphical object
    % set new value, if not empty
    if nargin < 3, new = []; end

    old = get(h, property);

    if ~isempty(new)
        set(h, property, new);
    end
end
