function [ status ] = issues( k )
%ISSUES M2T Test cases related to issues
%
% Issue-related test cases for matlab2tikz
%
% See also: ACID, matlab2tikz_acidtest
    testfunction_handles = {
                             @scatter3Plot3
                           };

    numFunctions = length( testfunction_handles );

    if (k<=0)
        status = testfunction_handles;
        return;  % This is used for querying numFunctions.

    elseif (k<=numFunctions)
        status = testfunction_handles{k}();
        status.function = func2str(testfunction_handles{k});

    else
        error('issues:outOfBounds', ...
              'Out of bounds (number of testfunctions=%d)', numFunctions);
    end

end

% =========================================================================
function [stat] = scatter3Plot3()
    stat.description = 'Scatter3 plot with 2 colors';
    stat.issues = 292;

    hold on;
    x = sin(1:5);
    y = cos(3.4 *(1:5));
    z = x.*y;
    scatter3(x,y,z,150,...
             'MarkerEdgeColor','none','MarkerFaceColor','k');
    scatter3(-x,y,z,150,...
             'MarkerEdgeColor','none','MarkerFaceColor','b');
end

% =========================================================================
