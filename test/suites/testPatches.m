function status = testPatches(k)
% TESTPATCHES Test suite for patches
%
% See also: ACID, matlab2tikz_acidtest

testfunction_handles = {
    @patch01;
    @patch02;
    @patch03;
    @patch04;
    @patch05;
    @patch06;
    @patch07;
    @patch08;
    };

numFunctions = length( testfunction_handles );

if nargin < 1 || isempty(k) || k <= 0
    status = testfunction_handles;
    return;  % This is used for querying numFunctions.

elseif (k<=numFunctions)
    status = testfunction_handles{k}();
    status.function = func2str(testfunction_handles{k});

else
    error('patchTests:outOfBounds', ...
        'Out of bounds (number of testfunctions=%d)', numFunctions);
end

end

% =========================================================================
function p = patch00()
% DO NOT INCLUDE IN ACID LIST
% Base patch plot for following tests
xdata = [2 2 0 2 5; 2 8 2 4 5; 8 8 2 4 8];
ydata = [4 4 4 2 0; 8 4 6 2 2; 4 0 4 0 0];
zdata = ones(3,5)*2;
p     = patch(xdata,ydata,zdata);
end
% =========================================================================
function stat = patch01()
stat.description = 'Set face color red';

p = patch00();
set(p,'FaceColor','r')
end
% =========================================================================
function stat = patch02()
stat.description = 'Flat face colors scaled in clim [0,40]';

p = patch00();
set(gca,'CLim',[0 40])
cdata = [15 30 25 2 60];
set(p,'FaceColor','flat','CData',cdata,'CDataMapping','scaled')
end
% =========================================================================
function stat = patch03()
stat.description = 'Flat face colors direct in clim [0,40]';

p = patch00();
set(gca,'CLim',[0 40])
cdata = [15 30 25 2 60];
set(p,'FaceColor','flat','CData',cdata,'CDataMapping','direct')
end
% =========================================================================
function stat = patch04()
stat.description = 'Flat face colors with 3D (truecolor) CData';

p = patch00();
cdata(:,:,1) = [0 0 1 0 0.8];
cdata(:,:,2) = [0 0 0 0 0.8];
cdata(:,:,3) = [1 1 1 0 0.8];
set(p,'FaceColor','flat','CData',cdata)
end
% =========================================================================
function stat = patch05()
stat.description = 'Flat face color, scaled edge colors in clim [0,40]';

p = patch00();
set(gca,'CLim',[0 40])
cdata = [15 30 25 2 60; 12 23 40 13 26; 24 8 1 65 42];
set(p,'FaceColor','flat','CData',cdata,'EdgeColor','flat','LineWidth',5,'CDataMapping','scaled')
end
% =========================================================================
function stat = patch06()
stat.description = 'Flat face color, direct edge colors in clim [0,40]';

p = patch00();
set(gca,'CLim',[0 40])
cdata = [15 30 25 2 60; 12 23 40 13 26; 24 8 1 65 42];
set(p,'FaceColor','flat','CData',cdata,'EdgeColor','flat','LineWidth',5,'CDataMapping','direct')
end
% =========================================================================
function stat = patch07()
stat.description = 'Flat face color with 3D CData and interp edge colors';

p = patch00();
cdata(:,:,1) = [0 0 1 0 0.8;
                0 0 1 0.2 0.6;
                0 1 0 0.4 1];
cdata(:,:,2) = [0 0 0 0 0.8;
                1 1 1 0.2 0.6;
                1 0 0 0.4 0];
cdata(:,:,3) = [1 1 1 0 0.8;
                0 1 0 0.2 0.6;
                1 0 1 0.4 0];
set(p,'FaceColor','flat','CData',cdata,'EdgeColor','interp','LineWidth',5)
end
% =========================================================================
function stat = patch08()
stat.description = 'Interp face colors, flat edges, scaled CData in clims [0,40]';

p = patch00();
set(gca,'CLim',[0 40])
cdata = [15 30 25 2 60; 12 23 40 13 26; 24 8 1 65 42];
set(p,'FaceColor','interp','CData',cdata,'EdgeColor','flat','LineWidth',5,'CDataMapping','scaled')
end
% =========================================================================
