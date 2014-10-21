% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'all');

% Create plot
plot(0:pi/20:2*pi,sin(0:pi/20:2*pi))

% Create arrow
annotation(figure1,'arrow',[0.192857142857143 0.55],...
    [0.729952380952381 0.433333333333333]);

% Create ellipse
annotation(figure1,'ellipse',...
    [0.538499999999999 0.240476190476191 0.157928571428572 0.2452380952381]);

% Create textbox
annotation(figure1,'textbox',...
    [0.3 0.348251748251748 0.0328486806677437 0.0517482517482517],...
    'String',{'y-x'},...
    'FontSize',16,...
    'FitBoxToText','off',...
    'LineStyle','none');

