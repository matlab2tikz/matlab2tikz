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
%   CODEREPORT('stream', stream) to set to which stream/file to output the report
%   (default: 1, i.e. stdout). The stream is used only when no output argument
%   for `codeReport` is specified!.
%
% See also: checkcode, mlint

    SM = StreamMaker();
    %% input options
    ipp = m2tInputParser();
    ipp = ipp.addParamValue(ipp, 'function', 'matlab2tikz', @ischar);
    ipp = ipp.addParamValue(ipp, 'complexityThreshold', 10, @isnumeric);
    ipp = ipp.addParamValue(ipp, 'stream', 1, SM.isStream);
    ipp = ipp.parse(ipp, varargin{:});

    stream = SM.make(ipp.Results.stream, 'w');

    %% generate report data
    data = checkcode(ipp.Results.function,'-cyc','-struct');
    [complexityAll, mlintMessages] = splitCycloComplexity(data);

    %% analyze cyclomatic complexity
    categorizeComplexity = @(x) categoryOfComplexity(x, ...
                                 ipp.Results.complexityThreshold, ...
                                 ipp.Results.function);

    complexityAll = arrayfun(@parseCycloComplexity, complexityAll);
    complexityAll = arrayfun(categorizeComplexity, complexityAll);

    complexity = filter(complexityAll, @(x) strcmpi(x.category, 'Bad'));
    complexity = sortBy(complexity, 'line', 'ascend');
    complexity = sortBy(complexity, 'complexity', 'descend');

    [complexityStats] = complexityStatistics(complexityAll);

    %% analyze other messages
    %TODO: handle all mlint messages and/or other metrics of the code

    %% format report
    dataStr = complexity;
    dataStr = arrayfun(@(d) mapField(d, 'function',  @markdownInlineCode), dataStr);
    if ~isempty(dataStr)
        dataStr = addFooterRow(dataStr, 'complexity', @sum, {'line',0, 'function',bold('Total')});
    end
    dataStr = arrayfun(@(d) mapField(d, 'line',         @integerToString), dataStr);
    dataStr = arrayfun(@(d) mapField(d, 'complexity',   @integerToString), dataStr);

    report = makeTable(dataStr, {'function', 'complexity'}, ...
                                {'Function', 'Complexity'});

    %% command line usage
    if nargout == 0
        if ismember(stream.name, {'stdout','stderr'})
            stream.print('%s\n', codelinks(report, ipp.Results.function));
        else
            stream.print('%s\n', report);
        end

        figure('name',sprintf('Complexity statistics of %s', ipp.Results.function));
        h = statisticsPlot(complexityStats, 'Complexity', 'Number of functions');
        for hh = h
            plot(hh, [1 1]*ipp.Results.complexityThreshold, ylim(hh), ...
                 'k--','DisplayName','Threshold');
        end
        legend(h(1),'show','Location','NorthEast');

        clear report
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
function [data] = categoryOfComplexity(data, threshold, mainFunc)
% categorizes the complexity as "Good", "Bad" or "Accepted"
  TOKEN = '#COMPLEX'; % token to signal allowed complexity

  try %#ok
    helpStr = help(sprintf('%s>%s', mainFunc, data.function));
    if ~isempty(strfind(helpStr, TOKEN))
        data.category = 'Accepted';
        return;
    end
  end
  if data.complexity > threshold
      data.category = 'Bad';
  else
      data.category = 'Good';
  end
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

function [stat] = complexityStatistics(list)
% calculate some basic statistics of the complexities

    stat.values     = arrayfun(@(c)(c.complexity), list);
    stat.binCenter  = sort(unique(stat.values));

    categoryPerElem = {list.category};
    stat.categories = unique(categoryPerElem);
    nCategories = numel(stat.categories);

    groupedHist = zeros(numel(stat.binCenter), nCategories);
    for iCat = 1:nCategories
        category = stat.categories{iCat};
        idxCat = ismember(categoryPerElem, category);
        groupedHist(:,iCat) = hist(stat.values(idxCat), stat.binCenter);
    end

    stat.histogram  = groupedHist;
    stat.median     = median(stat.values);
end
function [data] = addFooterRow(data, column, func, otherFields)
% adds a footer row to data table based on calculations of a single column
footer = data(end);
for iField = 1:2:numel(otherFields)
    field = otherFields{iField};
    value = otherFields{iField+1};
    footer.(field) = value;
end
footer.(column) = func([data(:).(column)]);
data(end+1) = footer;
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
    %TODO: use gfmTable from makeTravisReport instead to do the formatting

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

function str = codelinks(str, functionName)
% replaces inline functions with clickable links in MATLAB
str = regexprep(str, '`([A-Za-z0-9_]+)`', ...
                ['`<a href="matlab:edit ' functionName '>$1">$1</a>`']);
%NOTE: editing function>subfunction will focus on that particular subfunction
% in the editor (this also works for the main function)
end
function str = bold(str)
str = ['**' str '**'];
end

%% PLOTTING ====================================================================
function h = statisticsPlot(stat, xLabel, yLabel)
% plot a histogram and box plot
    nCategories = numel(stat.categories);
    colors = colorscheme;

    h(1) = subplot(5,1,1:4);
    hold all;
    hb = bar(stat.binCenter, stat.histogram, 'stacked');

    for iCat = 1:nCategories
        category = stat.categories{iCat};

        set(hb(iCat), 'DisplayName', category, 'FaceColor', colors.(category), ...
                   'LineStyle','none');
    end

    %xlabel(xLabel);
    ylabel(yLabel);

    h(2) = subplot(5,1,5);
    hold all;

    boxplot(stat.values,'orientation','horizontal',...
                        'boxstyle',   'outline', ...
                        'symbol',     'o', ...
                        'colors',  colors.All);
    xlabel(xLabel);

    xlims = [min(stat.binCenter)-1 max(stat.binCenter)+1];
    c     = 1;
    ylims = (ylim(h(2)) - c)/3 + c;

    set(h,'XTickMode','manual','XTick',stat.binCenter,'XLim',xlims);
    set(h(1),'XTickLabel','');
    set(h(2),'YTickLabel','','YLim',ylims);
    linkaxes(h, 'x');
end
function colors = colorscheme()
% recognizable color scheme for the categories
 colors.All      = [  0 113 188]/255;
 colors.Good     = [118 171  47]/255;
 colors.Bad      = [161  19  46]/255;
 colors.Accepted = [236 176  31]/255;
end
