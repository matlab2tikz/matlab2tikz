function [ report ] = codeReport( varargin )
%CODEREPORT Builds a report of the code health
%
% This function generates a Markdown report on the code health. At the moment
% this is limited to the McCabe (cyclomatic) complexity of a function and its
% subfunctions.
%
% This makes use of |checkcode| in MATLAB.
%
% Usage:
%
%   CODEREPORT('function', functionName) to determine which function is
%   analyzed. (default: matlab2tikz)
%
%   CODEREPORT('complexityThreshold', integer ) to set above which complexity, a
%   function is added to the report (default: 10)
% 
% See also: checkcode, mlint, 

    ipp = matlab2tikzInputParser();
    ipp = ipp.addParamValue(ipp, 'function', 'matlab2tikz', @ischar);
    ipp = ipp.addParamValue(ipp, 'complexityThreshold', 10, @isnumeric);
    ipp = ipp.parse(ipp, varargin{:});

    data = checkcode(ipp.Results.function,'-cyc','-struct');

    %% generate report data
    [complexity, mlintMessages] = splitCycloComplexity(data);

    %% analyze cyclomatic complexity
    complexity = arrayfun(@parseCycloComplexity, complexity);
    complexity = filter(complexity, @(x) x.complexity > ipp.Results.complexityThreshold);
    complexity = sortBy(complexity, 'line', 'ascend');
    complexity = sortBy(complexity, 'complexity', 'descend');

    %% analyze other messages
    %TODO: handle all mlint messages and/or other metrics of the code

    %% format report
    dataStr = complexity;
    dataStr = arrayfun(@(d) mapField(d, 'function',  @markdownInlineCode), dataStr);
    dataStr = arrayfun(@(d) mapField(d, 'line',         @integerToString), dataStr);
    dataStr = arrayfun(@(d) mapField(d, 'complexity',   @integerToString), dataStr);
    report = makeTable(dataStr, {'line','function', 'complexity'}, ...
                                {'Line','Function', 'Complexity'});

    %% 
    if nargout == 0
        disp(report)
    end
                        
end
%% CATEGORIZATION ==============================================================
function [complexity, others] = splitCycloComplexity(list)
% splits codereport into McCabe complexity and others
    filter = @(l) ~isempty(strfind(l.message, 'McCabe complexity'));
    idxComplexity = arrayfun(filter, list);
    complexity = list( idxComplexity);
    others     = list(~idxComplexity);
end

%% PARSING =====================================================================
function [out] = parseCycloComplexity(in)
% converts McCabe complexity report strings into a better format
    out = regexp(in.message, ...
                 'The McCabe complexity of ''(?<function>[A-Za-z0-9_]+)'' is (?<complexity>[0-9]+).', ...
                 'names');
    out.complexity = str2double(out.complexity);             
    out.line = in.line;
end

%% DATA PROCESSING =============================================================
function selected = filter(list, filterFunc)
% filters an array according to a binary function
    idx = logical(arrayfun(filterFunc, list));
    selected = list(idx);
end
function [data] = mapField(data, field, mapping)
    data.(field) = mapping(data.(field));
end
function sorted = sortBy(list, fieldName, mode)
% sorts a struct array by a single field
% extra arguments are as for |sort|
    values = arrayfun(@(m)m.(fieldName), list);
    [dummy, idxSorted] = sort(values(:), 1, mode); %#ok
    sorted = list(idxSorted);
end

%% FORMATTING ==================================================================
function str = integerToString(value)
% convert integer to string
    str = sprintf('%d',value);
end
function str = markdownInlineCode(str)
% format as inline code for markdown
    str = sprintf('`%s`', str);
end
function str = makeTable(data, fields, header)  
% make a markdown table from struct array
    nData = numel(data);
    str = '';
    if nData == 0
        return; % empty input
    end
    
    % determine column sizes
    nFields = numel(fields);
    table = cell(nFields, nData);
    columnWidth = zeros(1,nFields);
    for iField = 1:nFields
        field = fields{iField};
        table(iField, :) = {data(:).(field)};
        columnWidth(iField) = max(cellfun(@numel, table(iField, :)));
    end
    columnWidth = max(columnWidth, cellfun(@numel, header));
    columnWidth = columnWidth + 2; % empty space left and right
    columnWidth([1,end]) = columnWidth([1,end]) - 1; % except at the edges
    
    % format table inside cell array
    table = [header; table'];
    for iField = 1:nFields
        FORMAT = ['%' int2str(columnWidth(iField)) 's'];
        
        for jData = 1:size(table, 1)
            table{jData, iField} = strjust(sprintf(FORMAT, ...
                                           table{jData, iField}), 'center');
        end
    end
    
    % insert separator
    table = [table(1,:)
             arrayfun(@(n) repmat('-',1,n), columnWidth, 'UniformOutput',false)
             table(2:end,:)]';
    
    % convert cell array to string
    FORMAT = ['%s' repmat('|%s', 1,nFields-1) '\n'];
    str = sprintf(FORMAT, table{:});
    
end
