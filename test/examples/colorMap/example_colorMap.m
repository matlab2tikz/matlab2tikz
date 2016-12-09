function example_colorMap()

f= figure();
h=pcolor(peaks);

hcb=colorbar;
set(hcb,'YTick',[-6 0 6 ],'YTickLabel',{'Good','Normal','Bad'})
matlab2tikz('figurehandle',f,...
    'filename','example_colorMap.tex' ,...
    'showInfo', false,...
    'standalone', true);
close(f)
