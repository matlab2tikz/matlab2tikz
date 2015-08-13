function example_bar_plot()
test_data =[15     0; 20     0;   25     2;    30    14;    35    34;    40    57;    45    65;    50    46;    55     9;    60     2;    65     1;    70     0];

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
matlab2tikz('figurehandle',figure1,'filename','example_v_bar_plot.tex' ,'standalone', true);