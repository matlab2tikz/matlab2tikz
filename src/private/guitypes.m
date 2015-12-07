function types = guitypes()
% GUITYPES returns a cell array of MATLAB/Octave GUI object types
%
% Syntax
%   types = guitypes()
%
% These types are ignored by matlab2tikz and figure2dot.
%
% See also: matlab2tikz, figure2dot

types = {'uitoolbar', 'uimenu', 'uicontextmenu', 'uitoggletool',...
         'uitogglesplittool', 'uipushtool', 'hgjavacomponent'};
end
