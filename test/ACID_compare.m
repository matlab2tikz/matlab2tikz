function [result] = ACID_compare(N)
close all;

    for i=1:length(N)
    h1 = figure('units','normalized','outerposition',[0 0 1 1]);
    ACID(N(i));
    cleanfigure_orig; 
    lineObjs_orig = findobj(h1, 'type', 'line');
    xdata_orig = get(lineObjs_orig, 'XData');
    ydata_orig = get(lineObjs_orig, 'YData');

    h2 = figure('units','normalized','outerposition',[0 0 1 1]);
    ACID(N(i)); 
    cleanfigure;     
    lineObjs = findobj(h2, 'type', 'line');
    xdata = get(lineObjs, 'XData');
    ydata = get(lineObjs, 'YData');
    close all;
    
    if(iscell(xdata))
        for i=1:size(xdata,1)
            neq_x(:,i) = xdata{i}~=xdata_orig{i} & (~isnan(xdata{i}) & ~isnan(xdata_orig{i}));
            neq_y(:,i) = ydata{i}~=ydata_orig{i} & (~isnan(ydata{i}) & ~isnan(ydata_orig{i}));
        end
    else
        neq_x = xdata~=xdata_orig & (~isnan(xdata) & ~isnan(xdata_orig));
        neq_y = ydata~=ydata_orig & (~isnan(ydata) & ~isnan(ydata_orig));
    end
    
    if(any(neq_x) || any(neq_y))
        result = false;
        disp(['Test ACID(',num2str(N(i)),') failed']);
    else
        result = true;    
        disp(['Test ACID(',num2str(N(i)),') passed']);
    end    
end