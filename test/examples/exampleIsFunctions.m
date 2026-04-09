clear variables;
close all;
clc;


% Values to test the is... function against
cellODD = {true(1),12,0.3,'a',"b",['a','b'],["a","b"],{'a','b'},{"a","b"}};
Description = ['logical','int','float','char','string','array of chars','array of strings','cell of chars','cell of strings'];

%cellODD with the cells converted to string and chars to make it better
%readable in the summarizing table T_isfunction
cellODD_better_readable = {true(1),12,0.3,'a',"b",['a','b'],'["a","b"]',"{'a','b'}",'{"a","b"}'};

%Test if the isCharOrString return the correct result
result_isCharOrString = cellfun(@isCharOrString,cellODD);

%Test if the isCellOrCharOrString returns the correct result
result_isCellOrCharOrString = cellfun(@isCellOrCharOrString,cellODD);

%Test if the isCellstrOrCharOrString returns the correct result
result_isCellstrOrCharOrString = cellfun(@isCellstrOrCharOrString,cellODD);


%Summary of the results
is_char = cellfun(@ischar,cellODD);
is_string = cellfun(@isstring,cellODD);
is_cell = cellfun(@iscell,cellODD);
is_cellstr = cellfun(@iscellstr,cellODD);

T_isfunctions = table(cellODD_better_readable',is_char',is_string',is_cell', ...
    is_cellstr',result_isCharOrString',result_isCellOrCharOrString', result_isCellstrOrCharOrString');
T_isfunctions.Properties.VariableNames = {'Original_values','is_char','is_string', ...
    'is_cell','is_cellstr','is_cell_or_char','is_cell_or_char_or_string','is_cellstr_or_char_or_string'};


fprintf('Test results of the Function isCharOrString, isCellOrCharOrString, isCellstrOrCharOrString \n\n')
fprintf(['I tested the function on most of the common datatypes including: logical,\n' ...
    'int, float, char, strings, array of chars, array of strings, cell of chars \n' ...
    'and cell of chars. Then the function is compared to the results of the \n' ...
    'built in functions ischar, isstring and iscell and iscellstr. The summary of can be \n' ...
    'seen in the printed table below \n\n'])

disp(T_isfunctions)


% ==============================================================================
function bool = isCharOrString(x)
%checks if input is a char. If we are working in a
%Matlab environment also if it is a string.

bool = ischar(x);

if strcmp(getEnvironment(),'MATLAB')
    bool = bool || isstring(x);
end

end
% ==============================================================================
function bool = isCellOrCharOrString(x)
%checks if input is either a cell or a char. And if we are working in a
%Matlab environment also if it is a string.
bool = iscell(x) || ischar(x);

if strcmp(getEnvironment(),'MATLAB')
    bool = bool || isstring(x);
end

end
% ==============================================================================
function bool = isCellstrOrCharOrString(x)
%checks if input is either a cellstr or a char. And if we are working in a
%Matlab environment also if it is a string.
bool = iscellstr(x) || ischar(x);

if strcmp(getEnvironment(),'MATLAB')
    bool = bool || isstring(x);
end

end
