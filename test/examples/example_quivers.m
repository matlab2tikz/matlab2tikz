%% Quiver calculations
% These are calculations for the quiver dimensions as implemented in MATLAB
% (HG1) as in the |quiver.m| function.
%
% For HG2 and Octave, the situation might be different.
%
% A single quiver is defined as:
%
%                   C
%                    \
%                     \
%  A ----------------- B 
%                     /
%                    /
%                   D
%
% To know the dimensions of the arrow head, MATLAB defines the quantities
%  alpha = beta = 0.33 that determine the coordinates of C and D as given below.

clc; 
clear variables;
close all;

%% Parameters
try
    syms x y z u v w alpha beta epsilon real
catch
    warning('Symbolic toolbox not found. Interpret the values with care!');
    x = randn(); y = randn(); z = randn();
    u = randn(); v = randn(); w = randn();
end
alpha = 0.33;
beta = alpha;
epsilon = 0;
is2D = true;

%% Coordinates as defined in MATLAB
% Note that in 3D, the arrow head is oriented in a weird way. Let' just ignore
% that and only focus on 2D and use the same in 3D. Due to the lack
% of [u,v,w]-symmetry in those equations, the angle is bound to depend on the
% length of |delta|, i.e. something we don't know beforehand.
A = [x y z].';
delta = [u v w].';
B = A + delta;
C = B - alpha*[u+beta*(v+epsilon);
               v-beta*(u+epsilon)
               w];
D = B - alpha*[u-beta*(v+epsilon);
               v+beta*(u+epsilon)
               w];

if is2D
    A = A(1:2);
    B = B(1:2);
    C = C(1:2);
    D = D(1:2);
    delta = delta(1:2);
end

%% Calculating the angle of the arrowhead
% Calculate the cos(angle) using the inner product
unitVector = @(v) v/norm(v);
cosAngleBetween = @(a,b,c) unitVector(a-b).' * unitVector(c-b);

cosTwiceTheta = cosAngleBetween(C,B,D);
if isa(cosTwiceTheta, 'sym')
    cosTwiceTheta = simplify(cosTwiceTheta);
end

theta = acos(cosTwiceTheta) / 2

radToDeg = @(rads) (rads * 180 / pi);

thetaVal = radToDeg(theta)
try
    thetaVal = double(thetaVal)
end

% For the MATLAB parameters alpha=beta=0.33, we get theta = 18.263 degrees.

