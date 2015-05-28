function [orig,cwd] = initializeGlobalState()
% Initialize global state. Set working directory and various properties of
% the graphical root to ensure reliable output of the ACID testsuite.
% See #542 and #552
%
% 1. Working directory
% 2. Bring get(0,'Default') in line with get(0,'Factory')
% 3. Set specific properties, required by matlab2tikz
    fprintf('Initialize global state...\n');
    orig = struct();

    %--- Initialize working directory
    cwd = initializeWorkingDirectory();

    %--- Extract user defined default properties and set factory state
    default = get(0,'Default');
    factory = get(0,'Factory');

    f = fieldnames(default);    % fields of user's default state
    for i = 1:length(f)
        factory_property_name = strrep(f{i},'default','factory');
        factory_property_value = factory.(factory_property_name);
        orig.(f{i}).val = ...
            swap_property_state(0, f{i}, factory_property_value);
    end
    clear default factory_property_name factory_property_value

    %--- Define desired global state properties
    % defaultFigurePosition: width and height influence cleanfigure() and
    % the number/location of axis ticks
    new.defaultFigurePosition.val   = [300,200,560,420];
    new.defaultFigurePosition.ignore= 0;

    % screenDepth: TODO: determine, if necessary
    % not possible in octave
    new.screenDepth.val             = 24;
    new.screenDepth.ignore          = strcmpi(getEnvironment,'octave'); 

    % ScreenPixelsPerInch: TODO: determine, if necessary
    % not possible in octave
    new.ScreenPixelsPerInch.val     = 96;
    new.ScreenPixelsPerInch.ignore  = strcmpi(getEnvironment,'octave'); 

    %--- Extract relevant properties and set desired state
    f = fieldnames(new);    % fields of new state
    for i = 1:length(f)
        % ignore property on specified environments
        if ~new.(f{i}).ignore
            val = swap_property_state(0, f{i}, new.(f{i}).val);

            % store original value only, if not set by user's defaults
            if ~isfield(orig,f{i})
                orig.(f{i}).val = val;
            end 
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
