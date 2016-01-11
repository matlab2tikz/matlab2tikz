function example_bar_plot()
test_data =[18     0; 20     0;   21     2;    30    14;    35    34;    40    57;    45    65;    50    46;    55     9;    60     2;    65     1;    70     0];

% Create figure
figure1 = figure('Color',[1 1 1]);

subplot(1,2,1)


hb=barh(test_data(:,1),test_data(:,2),'DisplayName','Test Data');

ylabel('parameter [units]');
xlabel('#');
legend('show','Location','northwest');
subplot(1,2,2)


hb=bar(test_data(:,1),test_data(:,2),'DisplayName','Test Data');

xlabel('parameter [units]');
ylabel('#');
legend('show','Location','northwest');


xdata=test_data(:,1);
barWidth=test_getBarWidthInAbsolutUnits(hb);

x_l=xdata-barWidth/2;
x_u=xdata+barWidth/2;
max_y=max(test_data(:,2))*1.2;
x=[];
y=[];
for i=1:length(x_l)
    x = [x , x_l(i),x_l(i),nan,x_u(i),x_u(i),nan];
    y = [y,       0,max_y ,nan,0     ,max_y ,nan];
    
    
end
hold on
plot(x,y,'r');

matlab2tikz('figurehandle',figure1,'filename','example_v_bar_plot.tex' ,'standalone', true);


    function BarWidth=test_getBarWidthInAbsolutUnits(h)
        % astimates the width of a bar plot
        XData_bar=get(h,'XData');
        length_bar = length(XData_bar);
        BarWidth= get(h, 'BarWidth');
        if length_bar > 1
            BarWidth = min(diff(XData_bar))*BarWidth;
        end
        
