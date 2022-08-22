clear variables;
close all;
clc;

% Values to test the is... function against
cellODD = {true(1),12,0.3,'a',"b",['a','b'],["a","b"],{'a','b'},{"a","b"}};
Description = ['logical','int','float','char','string','array of chars','array of strings','cell of chars','cell of strings'];

%cellODD with the cells converted to string and chars to make it better
%readable in the summarizing table T_isfunction
cellODD_better_readable = {true(1),12,0.3,'a',"b",['a','b'],'["a","b"]',"{'a','b'}",'{"a","b"}'};

% Apply the function that converts all strings to chars
convertedArguments = convertArguments2Char(cellODD{:});
convertedArgumentsBetterReadable = {true(1),12,0.3,'a','b','ab',"{'a','b'}","{'a','b'}","{'a','b'}"};

%Summary of the results on the converted arguments (CA)
is_char_CA = cellfun(@ischar,convertedArguments);
is_string_CA = cellfun(@isstring,convertedArguments);
is_cell_CA = cellfun(@iscell,convertedArguments);
is_cellstr_CA = cellfun(@iscellstr,convertedArguments);



T_convertedArguments = table(cellODD_better_readable',convertedArgumentsBetterReadable',is_char_CA',is_string_CA',is_cell_CA',is_cellstr_CA');
T_convertedArguments.Properties.VariableNames = {'original values','converted values','is_char','is_string','is_cell','is_cellstr'};


fprintf('Test results of the Function convertArguments2Char \n\n')
fprintf(['I tested the function convertArguments2Char by converting the \n' ...
    'values of cellODD (a cellarray of various data types). Then I check \n' ...
    'if the values are either chars or cells of chars or unchanged. In\n' ...
    'particular the collumn is string should always be false.\n' ...
    'The summary of the result can be seen in the table below:\n\n'])

disp(T_convertedArguments)


% ==============================================================================
function varargin = convertArguments2Char(varargin)
% This function converts the Arguments to char if any strings were
% handed over to be able to handle Matlab strings while staying
% compatible to GNU Octave

if strcmp(getEnvironment(),'MATLAB')

    for k = 1: length(varargin)

        if iscell(varargin{k})
            %converts cells of strings,'UniformOutput'==false to return
            %the results ass cellarray
            varargin{k} = cellfun(@convertStringsToChars,varargin{k},'UniformOutput',false);
        else
            %converts Strings, arrays of strings...
            varargin{k} = convertStringsToChars(varargin{k});
        end

    end
end
end
