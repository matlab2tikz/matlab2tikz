function [orig] = initializeGlobalState()
% Initialize global state. Set working directory and various properties of
% the graphical root to ensure reliable output of the ACID testsuite.
% See #542 and #552
%
% 1. Working directory
% 2. Bring get(0,'Default') in line with get(0,'Factory')
% 3. Set specific properties, required by matlab2tikz
    fprintf('Initialize global state...\n');
    orig = struct();

    %--- Extract user defined default properties and set factory state
    default = get(0,'Default');
    factory = get(0,'Factory');

    f = fieldnames(default);    % fields of user's default state
    for i = 1:length(f)
        factory_property_name = strrep(f{i},'default','factory');
        factory_property_value = factory.(factory_property_name);
        orig.(f{i}).val = ...
            swapPropertyState(0, f{i}, factory_property_value);
    end

    %--- Define desired global state properties
    % defaultAxesColorOrder: on HG1 'default' and 'factory' differ and
    % HG1 differs from HG2. Consequently use HG2 colors (the new standard).
    new.defaultAxesColorOrder.val = [0.000 0.447 0.741; ...
                                0.850 0.325 0.098; ...
                                0.929 0.694 0.125; ...
                                0.494 0.184 0.556; ...
                                0.466 0.674 0.188; ...
                                0.301 0.745 0.933; ...
                                0.635 0.0780 0.184];
    new.defaultAxesColorOrder.ignore= false;

    % defaultFigurePosition: width and height influence cleanfigure() and
    % the number/location of axis ticks
    new.defaultFigurePosition.val   = [300,200,560,420];
    new.defaultFigurePosition.ignore= false;

    % ScreenPixelsPerInch: TODO: determine, if necessary
    % (probably needed for new line simplification algorithm)
    % not possible in octave
    new.ScreenPixelsPerInch.val     = 96;
    new.ScreenPixelsPerInch.ignore  = strcmpi(getEnvironment,'octave');

    % MATLAB's factory values differ from their default values of a clean
    % MATLAB installation (observed on R2014a, Linux)
    new.defaultAxesColor.val            = [1 1 1];
    new.defaultAxesColor.ignore         = false;
    new.defaultLineColor.val            = [0 0 0];
    new.defaultLineColor.ignore         = false;
    new.defaultTextColor.val            = [0 0 0];
    new.defaultTextColor.ignore         = false;
    new.defaultAxesXColor.val           = [0 0 0];
    new.defaultAxesXColor.ignore        = false;
    new.defaultAxesYColor.val           = [0 0 0];
    new.defaultAxesYColor.ignore        = false;
    new.defaultAxesZColor.val           = [0 0 0];
    new.defaultAxesZColor.ignore        = false;
    new.defaultFigureColor.val          = [0.8 0.8 0.8];
    new.defaultFigureColor.ignore       = false;
    new.defaultPatchEdgeColor.val       = [0 0 0];
    new.defaultPatchEdgeColor.ignore    = false;
    new.defaultPatchFaceColor.val       = [0 0 0];
    new.defaultPatchFaceColor.ignore    = false;
    new.defaultFigurePaperType.val      = 'A4';
    new.defaultFigurePaperType.ignore   = false;
    new.defaultFigurePaperSize.val      = [20.9840 29.6774];
    new.defaultFigurePaperSize.ignore   = false;
    new.defaultFigurePaperUnits.val     = 'centimeters';
    new.defaultFigurePaperUnits.ignore  = false;

    %--- Extract relevant properties and set desired state
    f = fieldnames(new);    % fields of new state
    for i = 1:length(f)
        % ignore property on specified environments
        if ~new.(f{i}).ignore
            val = swapPropertyState(0, f{i}, new.(f{i}).val);

            % store original value only, if not set by user's defaults
            if ~isfield(orig,f{i})
                orig.(f{i}).val = val;
            end 
        end
    end
end
% =========================================================================
function old = swapPropertyState(h, property, new)
    % read current property of graphical object
    % set new value, if not empty
    if nargin < 3, new = []; end

    old = get(h, property);

    if ~isempty(new)
        set(h, property, new);
    end
end
