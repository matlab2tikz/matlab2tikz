function compareTimings(statusBefore, statusAfter)

time_cf.before = cellfun(@(s) s.tikzStage.cleanfigure_time, statusBefore,'ErrorHandler', @(varargin) NaN);
time_cf.after = cellfun(@(s) s.tikzStage.cleanfigure_time, statusAfter,'ErrorHandler', @(varargin) NaN);

time_m2t.before = cellfun(@(s) s.tikzStage.m2t_time, statusBefore,'ErrorHandler', @(varargin) NaN);
time_m2t.after = cellfun(@(s) s.tikzStage.m2t_time, statusAfter,'ErrorHandler', @(varargin) NaN);

colors.matlab2tikz = [161  19  46]/255;
colors.cleanfigure = [  0 113 188]/255;
colors.before      = [236 176  31]/255;
colors.after       = [118 171  47]/255;

hax1 = subplot(3,2,1);
histograms(time_cf, 'cleanfigure');
legend('show')

hax2 = subplot(3,2,3);
histograms(time_m2t, 'matlab2tikz');
legend('show')
linkaxes([hax1 hax2],'x');

subplot(3,2,5)
histogramSpeedup('cleanfigure', time_cf, 'matlab2tikz', time_m2t);
legend('show');

subplot(3,2,2);
plotByTestCase(time_cf, 'cleanfigure');
legend('show')

subplot(3,2,4);
plotByTestCase(time_m2t, 'matlab2tikz');
legend('show')

subplot(3,2,6)
plotSpeedup('cleanfigure', time_cf, 'matlab2tikz', time_m2t);
legend('show');

% ------------------------------------------------------------------------------
function [h] = histograms(timing, name)
    histostyle = {'DisplayStyle', 'bar',...
                  'Normalization','pdf',...
                  'EdgeColor','none',...
                  'BinWidth',0.025};

    hold on;
    h(1) = histogram(timing.before, histostyle{:}, ...
                     'FaceColor', colors.before, ...
                     'DisplayName', 'Before');
    h(2) = histogram(timing.after , histostyle{:}, ...
                     'FaceColor', colors.after,...
                     'DisplayName', 'After');
          
    xlabel(sprintf('%s runtime [s]',name))
    ylabel('Empirical PDF');
end
function [h] = histogramSpeedup(varargin)
    histostyle = {'DisplayStyle', 'bar',...
                  'Normalization','pdf',...
                  'BinMethod', 'fd', ...
                  'EdgeColor','none'};

    [names,timings] = splitNameTiming(varargin);
    nData = numel(timings);
    alldata = [];
    for iData = 1:nData
        name = names{iData};
        timing = timings{iData};
        
        hold on;
        speedup = timing.before ./ timing.after;
        color = colorOptionsOfName(name, 'FaceColor');
        
        h(iData) = histogram(speedup, histostyle{:}, color{:}, 'DisplayName', name);
        alldata = [alldata;speedup(:)];
    end
    xlabel('Speedup')
    ylabel('Empirical PDF');
    set(gca,'XScale','log', 'XLim', [min(alldata) max(alldata)].*[0.9 1.1]);
end
% ------------------------------------------------------------------------------
function [h] = plotByTestCase(timing, name)
    hold on;
    if size(timing.before, 2) > 1
        h{3} = plot(timing.before, '.',...
                    'Color', colors.before, 'HandleVisibility','off');
        h{4} = plot(timing.after, '.',...
                    'Color', colors.after, 'HandleVisibility','off');
    end
    h{1} = plot(median(timing.before, 2), '-',...
                    'Color', colors.before, ...
                    'DisplayName', 'Before');
    h{2} = plot(median(timing.after, 2), '-',...
                'Color', colors.after,...
                'DisplayName', 'After');
    
    
    ylabel(sprintf('%s runtime [s]', name));
    set(gca,'YScale','log')
end

function [h] = plotSpeedup(varargin)
    
    [names, timings] = splitNameTiming(varargin);
    
    nDatasets = numel(names);
    alldata = [];
    for iData = 1:nDatasets
        name = names{iData};
        timing = timings{iData};
        color = colorOptionsOfName(name);

        hold on
        speedup = timing.before ./ timing.after;
        medSpeedup = median(timing.before,2) ./ median(timing.after,2);
        if size(speedup, 2) > 1
            plot(speedup, '.', color{:}, 'HandleVisibility','off');
        end
        h{iData} = plot(medSpeedup, color{:}, 'DisplayName', name);
        
        alldata = [alldata; speedup(:)];
    end
    
    legend('show', 'Location','NorthWest')
    set(gca,'YScale','log','YLim',[min(alldata), max(alldata)].*[0.9 1.1])
    xlabel('Test case');
    ylabel('Speed-up (t_{before}/t_{after})');
end
    function [names,timings] = splitNameTiming(vararginAsCell)
        names  = vararginAsCell(1:2:end-1);
        timings = vararginAsCell(2:2:end);
    end
    function color = colorOptionsOfName(name, keyword)
        if ~exist('keyword','var') || isempty(keyword)
            keyword = 'Color';
        end
        if isfield(colors,name)
            color = {keyword, colors.(name)};
        else
            color = {};
        end
    end        
end


