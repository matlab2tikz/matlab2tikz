function cleanfigure()
%   CLEANFIGURE() removes the unnecessary objects from your MATLAB plot
%   to give you a better experience with matlab2tikz.

%   CLEANFIGURE comes with several options that can be combined at will.
%
%   CLEANFIGURE('handle',HANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   Example
%      x = -pi:pi/1000:pi;
%      y = tan(sin(x)) - sin(tan(x));
%      plot(x,y,'--rs');
%      coarsenLine2d(0.1);
%

%   Copyright (c) 2013, Nico Schlömer <nico.schloemer@gmail.com>
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the distribution
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.

  % Recurse down the tree of plot objects and clean up the leaves.
  recursiveCleanup(gcf);
  return;
end
% =========================================================================
function recursiveCleanup(h)

  % Skip invisible objects.
  if ~strcmp(get(h,'Visible'), 'on')
      return;
  end

  % Don't try to be smart about quiver groups.
  if isa(handle(h), 'specgraph.quivergroup')
      return;
  end

  children = get(h, 'Children');
  if ~isempty(children)
      for child = children(:)'
          recursiveCleanup(child);
      end
  else
      % We're in a leaf, so apply all the fancy simplications.
      type = get(h, 'Type');
      if strcmp(type, 'line')
          % Move some points closer to the box to avoid TeX:DimensionTooLarge
          % errors. This may involve inserting extra points.
          movePointsCloser(h);
          % Don't be too precise.
          coarsenLine(h, 1.0e-10);
      elseif strcmp(type, 'text')
          % Check if text is inside bounds by checking if the Extent rectangle
          % and the axes box overlap.
          xlim = get(gca, 'XLim');
          ylim = get(gca, 'YLim');
          extent = get(h, 'Extent');
          extent(3:4) = extent(1:2) + extent(3:4);
          overlap = xlim(1) < extent(3) && xlim(2) > extent(1) ...
                 && ylim(1) < extent(4) && ylim(2) > extent(2);
          if ~overlap
              % Artificially disable visibility. m2t will check and skip.
              set(h, 'Visible', 'off');
          end
      end
  end

  return;
end
% =========================================================================
function coarsenLine(handle, minimumPointsDistance)
  % Reduce the number of data points in the line handle.
  % Given a minimum distance at which two nodes are considered different,
  % this can help with plots that contain a large amount of data points not
  % all of which need to be plotted.
  %
  if ( abs(minimumPointsDistance) < 1.0e-15 )
      % bail out early
      return
  end

  % Extract the data from the current line handle.
  data = [get(handle, 'XData')', get(handle, 'YData')'];

  if isempty(data)
      return;
  end

  % Generates a mask which is true for the first point, and all
  % subsequent points which have a greater norm2-distance from
  % the previous point than 'threshold'.
  n = size(data, 1);

  % Get info about log scaling.
  isXlog = strcmp(get(gca, 'XScale'), 'log');
  isYlog = strcmp(get(gca, 'YScale'), 'log');

  mask = false(n, 1);

  XRef = data(1,:);
  mask(1) = true;
  for kk = 2:n
      % Compute the visible distance of those points,
      % incorporating possible log-scaling of the axes.
      visDiff = XRef - data(kk,:);
      if isXlog
          % visDiff(1) = log10(XRef(1)) - log10(data(kk,1));
          visDiff(1) = log10(visDiff(1));
      end
      if isYlog
          visDiff(2) = log10(visDiff(2));
      end
      % Check if it's larger than the threshold and
      % update the reference point in that case.
      if norm(visDiff) > minimumPointsDistance
          XRef = data(kk,:);
          mask(kk) = true;
      end
  end
  mask(end) = true;

  % Set the new (masked) data.
  set(handle, 'XData', data(mask, 1));
  set(handle, 'YData', data(mask, 2));

end
% =========================================================================
function movePointsCloser(handle)
  % Move all points outside a box much larger than the visible one
  % to the boundary of that box and make sure that lines in the visible
  % box are preserved. This typically involved replacing one point by
  % two new ones.

  % Extract the data from the current line handle.
  data = [get(handle, 'XData')', get(handle, 'YData')'];

%get(handle, 'ZData')
%data

  xlim = get(gca, 'XLim');
  ylim = get(gca, 'YLim');

  xWidth = xlim(2) - xlim(1);
  yWidth = ylim(2) - ylim(1);
  extendFactor = 20;
  largeXLim = xlim + extendFactor * [-xWidth, xWidth];
  largeYLim = ylim + extendFactor * [-yWidth, yWidth];

  % Get which points are in an extended box (the limits of which
  % don't exceed TeX's memory).
  dataIsInLargeBox = isInBox(data(:,1:2), ...
                             largeXLim, largeYLim);

  % Loop through all points which are to be included in the plot yet do not
  % fit into the extended box, and gather the points by which they are to be
  % replaced.
  replaceIndices = find(~dataIsInLargeBox)';
  m = length(replaceIndices);
  r = cell(m, 1);
  for k = 1:m
      i = replaceIndices(k);
      r{k} = [];
      if i > 1 && all(isfinite(data(i-1,:)))
          newPoint = moveToBox(data(i,:), data(i-1,:), largeXLim, largeYLim);
          % Don't bother if the point is inf:
          % There's no intersection with the large box, so even the
          % connection between the two after they have been moved
          % won't be probably be visible.
          if all(isfinite(newPoint))
              r{k} = [r{k}; newPoint];
          end
      end
      if i < size(data,1) && all(isfinite(data(i+1,:)))
          newPoint = moveToBox(data(i,:), data(i+1,:), largeXLim, largeYLim);
          % Don't bother if the point is inf:
          % There's no intersection with the large box, so even the
          % connection between the two after they have been moved
          % won't be probably be visible.
          if all(isfinite(newPoint))
              r{k} = [r{k}; newPoint];
          end
      end
  end

  % Insert all r{k}{:} at replaceIndices[k].
  dataNew = [];
  lastReplIndex = 0;
  for k = 1:m
     dataNew = [dataNew; ...
                data(lastReplIndex+1:replaceIndices(k)-1,:);...
                r{k}];
     lastReplIndex = replaceIndices(k);
  end
  dataNew = [dataNew; ...
             data(lastReplIndex+1:end,:)];

  % Set the new (masked) data.
  set(handle, 'XData', dataNew(:,1));
  set(handle, 'YData', dataNew(:,2));

  return;
end
% =========================================================================
function xNew = moveToBox(x, xRef, xlim, ylim)
  % Takes a box defined by xlim, ylim, one point x and a reference point
  % xRef.
  % Returns the point xNew that sits on the line segment between x and xRef
  % *and* on the box. If several such points exist, take the closest one
  % to x.

  % Find out with which border the line x---xRef intersects, and determine
  % the smallest parameter alpha such that x + alpha*(xRef-x)
  % sits on the boundary.
  minAlpha = inf;
  % left boundary:
  lambda = crossLines(x, xRef, [xlim(1);ylim(1)], [xlim(1);ylim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % bottom boundary:
  lambda = crossLines(x, xRef, [xlim(1);ylim(1)], [xlim(2);ylim(1)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % right boundary:
  lambda = crossLines(x, xRef, [xlim(2);ylim(1)], [xlim(2);ylim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % top boundary:
  lambda = crossLines(x, xRef, [xlim(1);ylim(2)], [xlim(2);ylim(2)]);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % create the new point
  xNew = x + minAlpha*(xRef-x);
end
% =========================================================================
function out = isInBox(data, xLim, yLim)

  out = data(:,1) > xLim(1) & data(:,1) < xLim(2) ...
      & data(:,2) > yLim(1) & data(:,2) < yLim(2);

end
% =========================================================================
function lambda = crossLines(X1, X2, X3, X4)
  % Given four points X_k=(x_k,y_k), k\in{1,2,3,4}, and the two lines defined
  % by those,
  %
  %  L1(lambda) = X1 + lambda (X2 - X1)
  %  L2(lambda) = X3 + lambda (X4 - X3)
  %
  % returns the lambda for which they intersect (and Inf if they are parallel).
  % Technically, one needs to solve the 2x2 equation system
  %
  %   x1 + lambda1 (x2-x1)  =  x3 + lambda2 (x4-x3)
  %   y1 + lambda1 (y2-y1)  =  y3 + lambda2 (y4-y3)
  %
  % for lambda and mu.

  rhs = X3(:) - X1(:);
  % Divide by det even if it's 0: Infs are returned.
  % A = [X2-X1, -(X4-X3)];
  detA = -(X2(1)-X1(1))*(X4(2)-X3(2)) + (X2(2)-X1(2))*(X4(1)-X3(1));
  invA = [-(X4(2)-X3(2)), X4(1)-X3(1);...
          -(X2(2)-X1(2)), X2(1)-X1(1)] / detA;
  lambda = invA * rhs;

end
% =========================================================================
