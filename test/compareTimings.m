function compareTimings(statusBefore, statusAfter)
% COMPARETIMINGS compare timing of matlab2tikz test suite runs
%
% This function plots some analysis plots of the timings of different test
% cases. When the test suite is run repeatedly, the median statistics are
% reported as well as the individual runs.
%
% Usage:
%  COMPARETIMINGS(statusBefore, statusAfter)
%
% Parameters:
%  - statusBefore and statusAfter are expected to be
%    N x R cell arrays, each cell contains a status of a test case
%    where there are N test cases, repeated R times each.
%
% You can build such cells, e.g. with the following snippet.
%
%     suite = @ACID
%     N = numel(suite(0)); % number of test cases
%     R = 10; % number of repetitions of each test case
%
%     statusBefore = cell(N, R);
%     for r = 1:R
%         statusBefore(:, r) = testHeadless;
%     end
%
%     % now check out the after commit
%
%     statusAfter = cell(N, R);
%     for r = 1:R
%         statusAfter(:, r) = testHeadless;
%     end
%
%     compareTimings(statusBefore, statusAfter)
%
% See also: testHeadless

%% Extract timing information
time_cf  = extract(statusBefore, statusAfter, @(s) s.tikzStage.cleanfigure_time);
time_m2t = extract(statusBefore, statusAfter, @(s) s.tikzStage.m2t_time);
%% Construct plots
hax(1) = subplot(3,2,1);
histograms(time_cf, 'cleanfigure');
legend('show')

hax(2) = subplot(3,2,3);
histograms(time_m2t, 'matlab2tikz');
legend('show')
linkaxes(hax([1 2]),'x');

hax(3) = subplot(3,2,5);
histogramSpeedup('cleanfigure', time_cf, 'matlab2tikz', time_m2t);
legend('show');

hax(4) = subplot(3,2,2);
plotByTestCase(time_cf, 'cleanfigure');
legend('show')

hax(5) = subplot(3,2,4);
plotByTestCase(time_m2t, 'matlab2tikz');
legend('show')

hax(6) = subplot(3,2,6);
plotSpeedup('cleanfigure', time_cf, 'matlab2tikz', time_m2t);
legend('show');

linkaxes(hax([4 5 6]), 'x');

% ------------------------------------------------------------------------------
end
%% Data processing
function timing = extract(statusBefore, statusAfter, func)
    otherwiseNaN = {'ErrorHandler', @(varargin) NaN};

    timing.before = cellfun(func, statusBefore, otherwiseNaN{:});
    timing.after  = cellfun(func, statusAfter, otherwiseNaN{:});
end
function [names,timings] = splitNameTiming(vararginAsCell)
    names  = vararginAsCell(1:2:end-1);
    timings = vararginAsCell(2:2:end);
end

%% Plot subfunctions
function [h] = histograms(timing, name)
    % plot histogram of time measurements
    colors = colorscheme;
    histostyle = {'DisplayStyle', 'bar',...
                  'Normalization','pdf',...
                  'EdgeColor','none',...
                  'BinWidth',0.025};

    hold on;
    h{1} = myHistogram(timing.before, histostyle{:}, ...
                     'FaceColor', colors.before, ...
                     'DisplayName', 'Before');
    h{2} = myHistogram(timing.after , histostyle{:}, ...
                     'FaceColor', colors.after,...
                     'DisplayName', 'After');

    xlabel(sprintf('%s runtime [s]',name))
    ylabel('Empirical PDF');
end
function [h] = histogramSpeedup(varargin)
    % plot histogram of observed speedup
    histostyle = {'DisplayStyle', 'bar',...
                  'Normalization','pdf',...
                  'EdgeColor','none'};

    [names,timings] = splitNameTiming(varargin);
    nData = numel(timings);
    h = cell(nData, 1);
    minTime = NaN; maxTime = NaN;
    for iData = 1:nData
        name = names{iData};
        timing = timings{iData};

        hold on;
        speedup = computeSpeedup(timing);
        color = colorOptionsOfName(name, 'FaceColor');

        h{iData} = myHistogram(speedup, histostyle{:}, color{:},...
                               'DisplayName', name);

        [minTime, maxTime] = minAndMax(speedup, minTime, maxTime);
    end
    xlabel('Speedup')
    ylabel('Empirical PDF');
    set(gca,'XScale','log', 'XLim', [minTime, maxTime].*[0.9 1.1]);
end
function [h] = plotByTestCase(timing, name)
    % plot all time measurements per test case
    colors = colorscheme;
    hold on;
    if size(timing.before, 2) > 1
        h{3} = plot(timing.before, '.',...
                    'Color', colors.before, 'HandleVisibility', 'off');
        h{4} = plot(timing.after, '.',...
                    'Color', colors.after, 'HandleVisibility', 'off');
    end
    h{1} = plot(median(timing.before, 2), '-',...
                'LineWidth', 2, ...
                'Color', colors.before, ...
                'DisplayName', 'Before');
    h{2} = plot(median(timing.after, 2), '-',...
                'LineWidth', 2, ...
                'Color', colors.after,...
                'DisplayName', 'After');

    ylabel(sprintf('%s runtime [s]', name));
    set(gca,'YScale','log')
end
function [h] = plotSpeedup(varargin)
    % plot speed up per test case
    [names, timings] = splitNameTiming(varargin);

    nDatasets = numel(names);
    minTime = NaN;
    maxTime = NaN;
    h = cell(nDatasets, 1);
    for iData = 1:nDatasets
        name = names{iData};
        timing = timings{iData};
        color = colorOptionsOfName(name);

        hold on
        [speedup, medSpeedup] = computeSpeedup(timing);
        if size(speedup, 2) > 1
            plot(speedup, '.', color{:}, 'HandleVisibility','off');
        end
        h{iData} = plot(medSpeedup, color{:}, 'DisplayName', name, ...
                        'LineWidth', 2);

        [minTime, maxTime] = minAndMax(speedup, minTime, maxTime);
    end

    nTests = size(speedup, 1);
    plot([-nTests nTests*2], ones(2,1), 'k','HandleVisibility','off');

    legend('show', 'Location','NorthWest')
    set(gca,'YScale','log','YLim', [minTime, maxTime].*[0.9 1.1], ...
        'XLim', [0 nTests+1])
    xlabel('Test case');
    ylabel('Speed-up (t_{before}/t_{after})');
end

%% Histogram wrapper
function [h] = myHistogram(data, varargin)
% this is a very crude wrapper that mimics Histogram in R2014a and older
    if ~isempty(which('histogram'))
        h = histogram(data, varargin{:});
    else % no "histogram" available
        options = struct(varargin{:});

        minData = min(data(:));
        maxData = max(data(:));
        if isfield(options, 'BinWidth')
            numBins = ceil((maxData-minData)/options.BinWidth);
        elseif isfield(options, 'NumBins')
            numBins = options.NumBins;
        else
            numBins = 10;
        end
        [counts, bins] = hist(data(:), numBins);
        if isfield(options,'Normalization') && strcmp(options.Normalization,'pdf')
            binWidth = mean(diff(bins));
            counts = counts./sum(counts)/binWidth;
        end
        h = bar(bins, counts, 1);

        % transfer properties as well
        names = fieldnames(options);
        for iName = 1:numel(names)
            option = names{iName};
            if isprop(h, option)
                set(h, option, options.(option));
            end
        end
        set(allchild(h),'FaceAlpha', 0.75); % only supported with OpenGL renderer
        % but this should look a bit similar with matlab2tikz then...
    end
end

%% Calculations
function [speedup, medSpeedup] = computeSpeedup(timing)
    % computes the timing speedup (and median speedup)
    dRep = 2; % dimension containing the repeated tests
    speedup = timing.before ./ timing.after;
    medSpeedup = median(timing.before, dRep) ./ median(timing.after, dRep);
end
function [minTime, maxTime] = minAndMax(speedup, minTime, maxTime)
    % calculates the minimum/maximum time in an array and peviously
    % computed min/max times
    minTime = min([minTime; speedup(:)]);
    maxTime = min([maxTime; speedup(:)]);
end
%% Color scheme
function colors = colorscheme()
% defines the color scheme
    colors.matlab2tikz = [161  19  46]/255;
    colors.cleanfigure = [  0 113 188]/255;
    colors.before      = [236 176  31]/255;
    colors.after       = [118 171  47]/255;
end
function color = colorOptionsOfName(name, keyword)
% returns a cell array with a keyword (default: 'Color') and a named color
% if it exists in the colorscheme
    if ~exist('keyword','var') || isempty(keyword)
        keyword = 'Color';
    end
    colors = colorscheme;
    if isfield(colors,name)
        color = {keyword, colors.(name)};
    else
        color = {};
    end
end
