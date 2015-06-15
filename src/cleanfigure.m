function cleanfigure(varargin)
%   CLEANFIGURE() removes the unnecessary objects from your MATLAB plot
%   to give you a better experience with matlab2tikz.
%   CLEANFIGURE comes with several options that can be combined at will.
%
%   CLEANFIGURE('handle',HANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   CLEANFIGURE('minimumPointsDistance',DOUBLE,...) explicitly specified the
%   minimum distance between two points. (default: 1.0e-10)
%
%   Example
%      x = -pi:pi/1000:pi;
%      y = tan(sin(x)) - sin(tan(x));
%      plot(x,y,'--rs');
%      cleanfigure();
%

%   Copyright (c) 2013--2014, Nico Schlömer <nico.schloemer@gmail.com>
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

  % Treat hidden handles, too.
  shh = get(0, 'ShowHiddenHandles');
  set(0, 'ShowHiddenHandles', 'on');

  % Keep track of the current axes.
  meta.gca = [];

  % Set up command line options.
  m2t.cmdOpts = m2tInputParser;
  m2t.cmdOpts = m2t.cmdOpts.addParamValue(m2t.cmdOpts, 'minimumPointsDistance', 1.0e-10, @isnumeric);
  m2t.cmdOpts = m2t.cmdOpts.addParamValue(m2t.cmdOpts, 'handle', gcf, @ishandle);

  % Finally parse all the elements.
  m2t.cmdOpts = m2t.cmdOpts.parse(m2t.cmdOpts, varargin{:});

  % Recurse down the tree of plot objects and clean up the leaves.
  for h = m2t.cmdOpts.Results.handle(:)'
    recursiveCleanup(meta, h, m2t.cmdOpts.Results.minimumPointsDistance, 0);
  end

  % Reset to initial state.
  set(0, 'ShowHiddenHandles', shh);

  return;
end
% =========================================================================
function indent = recursiveCleanup(meta, h, minimumPointsDistance, indent)

  type = get(h, 'Type');

  %display(sprintf([repmat(' ',1,indent), type, '->']))

  % Don't try to be smart about quiver groups.
  % NOTE:
  % A better way to write `strcmp(get(h,...))` would be to use
  %     isa(handle(h), 'specgraph.quivergroup').
  % The handle() function isn't supported by Octave, though, so let's stick
  % with strcmp().
  if strcmp(get(h, 'Type'), 'specgraph.quivergroup')
  %if strcmp(class(handle(h)), 'specgraph.quivergroup')
      return;
  end

  % Update the current axes.
  if strcmp(get(h, 'Type'), 'axes')
      meta.gca = h;
  end

  children = get(h, 'Children');
  if ~isempty(children)
      for child = children(:)'
          indent = indent + 4;
          indent = recursiveCleanup(meta, child, minimumPointsDistance, indent);
          indent = indent - 4;
      end
  else
      % We're in a leaf, so apply all the fancy simplications.

      %% Skip invisible objects.
      %if ~strcmp(get(h, 'Visible'), 'on')
      %    display(sprintf([repmat(' ',1,indent), '  invisible']))
      %    return;
      %end

      %display(sprintf([repmat(' ',1,indent), '  handle this']))

      if strcmp(type, 'line')
          pruneOutsideBox(meta, h);
          % Move some points closer to the box to avoid TeX:DimensionTooLarge
          % errors. This may involve inserting extra points.
          movePointsCloser(meta, h);
          % Don't be too precise.
          coarsenLine(meta, h, minimumPointsDistance);
      elseif strcmpi(type, 'stair')
          pruneOutsideBox(meta, h);
      elseif strcmp(type, 'text')
          % Ensure units of type 'data' (default) and restore the setting later
          units_original = get(h, 'Units');
          set(h, 'Units', 'data');

          % Check if text is inside bounds by checking if the position is inside
          % the x, y and z limits. This works for both 2D and 3D plots.
          x_lim = get(meta.gca, 'XLim');
          y_lim = get(meta.gca, 'YLim');
          z_lim = get(meta.gca, 'ZLim');
          axLim = [x_lim; y_lim; z_lim];

          pos = get(h, 'Position');
          % If the axis is 2D, ignore the z component for the checks
          if ~isAxis3D(meta.gca)
              pos(3) = 0; 
          end
          bPosInsideLim = ( pos' >= axLim(:,1) ) & ( pos' <= axLim(:,2) );

          % In 2D plots the 'extent' of the textbox is available and also
          % considered to keep the textbox, if it is partially inside the axis
          % limits.
          extent = get(h, 'Extent');

          % Restore original units (after reading all dimensions)
          set(h, 'Units', units_original);

          % This check makes sure the extent is only considered if it contains
          % valid values. The 3D case returns a vector of NaNs.
          if all(~isnan(extent))
            % Extend the actual axis limits by the extent of the textbox so that
            % the textbox is not discarded, if it overlaps the axis.
            x_lim(1) = x_lim(1) - extent(3);    % x-limit is extended by width
            y_lim(1) = y_lim(1) - extent(4);    % y-limit is extended by height
            axLim = [x_lim; y_lim; z_lim];

            bPosInsideLimExt = ( pos' >= axLim(:,1) ) & ( pos' <= axLim(:,2) );
            bPosInsideLim = bPosInsideLim | bPosInsideLimExt;
          end

          if ~all(bPosInsideLim)
              % Artificially disable visibility. m2t will check and skip.
              set(h, 'Visible', 'off');
          end
      end
  end

  return;
end
% =========================================================================
function pruneOutsideBox(meta, handle)
  % Some sections of the line may sit outside of the visible box.
  % Cut those off.

  xData = get(handle, 'XData');
  yData = get(handle, 'YData');

  % Obtain zData, if available
  if isprop(handle, 'ZData')
    zData = get(handle, 'ZData');
  else
    zData = [];
  end

  if isempty(zData)
    data = [xData(:), yData(:)];
  else
    data = [xData(:), yData(:), zData(:)];
  end

  if isempty(data)
      return;
  end

  %hasLines = ~strcmp(lineStyle,'none') && lineWidth>0.0;
  %hasMarkers = ~strcmp(marker,'none');
  hasLines = true;
  hasMarkers = true;
  xLim = get(meta.gca, 'XLim');
  yLim = get(meta.gca, 'YLim');

  tol = 1.0e-10;
  relaxedXLim = xLim + [-tol, tol];
  relaxedYLim = yLim + [-tol, tol];

  numPoints = size(data, 1);

  % Get which points are inside a (slightly larger) box.
  dataIsInBox = isInBox(data(:,1:2), ...
                        relaxedXLim, relaxedYLim);

  % By default, don't plot any points.
  shouldPlot = false(numPoints, 1);
  if hasMarkers
      shouldPlot = shouldPlot | dataIsInBox;
  end
  if hasLines
      % Check if the connecting line is in the box.
      segvis = segmentVisible(data(:,1:2), ...
                              dataIsInBox, xLim, yLim);
      % Plot points which are next to an edge which is in the box.
      shouldPlot = shouldPlot | [false; segvis] | [segvis; false];
  end

  if ~all(shouldPlot)
      % There are two options here:
      %      data = data(shouldPlot, :);
      % i.e., simply removing the data that isn't supposed to be plotted.
      % For line plots, this has the disadvantage that the line between two
      % 'loose' ends may now appear in the figure.
      % To avoid this, add a row of NaNs wherever a block of actual data is
      % removed.
      chunkIndices = [];
      k = 1;
      while k <= numPoints
          % fast forward to shouldPlot==True
          while k<=numPoints && ~shouldPlot(k)
              k = k+1;
          end
          kStart = k;
          % fast forward to shouldPlot==False
          while k<=numPoints && shouldPlot(k)
              k = k+1;
          end
          kEnd = k-1;

          if kStart <= kEnd
              chunkIndices = [chunkIndices; ...
                              [kStart, kEnd]];
          end
      end

      % Create masked data with NaN padding.
      % Make sure that there are no NaNs at the beginning of the data since
      % this would be interpreted as column names by Pgfplots.
      if size(chunkIndices, 1) > 0
          ci = chunkIndices(1,:);
          newData = data(ci(1):ci(2), :);
          n = size(data, 2);
          for ci = chunkIndices(2:end,:)'
               newData = [newData; ...
                          NaN(1, n); ...
                          data(ci(1):ci(2), :)];
          end
          data = newData;
      end
  end

  % Override with the new data.
  set(handle, 'XData', data(:, 1));
  set(handle, 'YData', data(:, 2));
  if ~isempty(zData)
    set(handle, 'ZData', data(:, 3));
  end

  return;
end
% ==========================================================================
function [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim);
    % Determine the corners of the axes as defined by xLim and yLim
    bottomLeft  = [xLim(1); yLim(1)];
    topLeft     = [xLim(1); yLim(2)];
    bottomRight = [xLim(2); yLim(1)];
    topRight    = [xLim(2); yLim(2)];
end
% =========================================================================
function out = segmentVisible(data, dataIsInBox, xLim, yLim)
    % Given a bounding box {x,y}Lim, loop through all pairs of subsequent nodes
    % in p and determine whether the line between the pair crosses the box.
    n = size(data, 1);
    out = false(n-1, 1);

    [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim);

    for k = 1:n-1
        this = data(k  , :);
        next = data(k+1, :);

        % One of the neighbors is inside the box and the other is finite
        nextVisible = (dataIsInBox(k+1) && all(isfinite(this)));
        thisVisible = (dataIsInBox(k)   && all(isfinite(next)));

        % Check whether the line connecting this point and the next one
        % intersects with any of the borders of the drawn axis
        left   = segmentsIntersect(this, next, bottomLeft , topLeft);
        right  = segmentsIntersect(this, next, bottomRight, topRight);
        bottom = segmentsIntersect(this, next, bottomLeft , bottomRight);
        top    = segmentsIntersect(this, next, topLeft    , topRight);

        % The segment is visible when any of the following hold:
        %  - this point is visible in the axis and the next is finite
        %  - this point is finite and the next is visible in the axis
        %  - the segment connecting this and the next point crosses a border
        out(k) = thisVisible || nextVisible || left || right || top || bottom;
    end
end
% =========================================================================
function out = segmentsIntersect(X1, X2, X3, X4)
  % Checks whether the segments X1--X2 and X3--X4 intersect.
  lambda = crossLines(X1, X2, X3, X4);
  out = all(lambda > 0.0) && all(lambda < 1.0);
end
% =========================================================================
function coarsenLine(meta, handle, minimumPointsDistance)
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
  xData = get(handle, 'XData');
  yData = get(handle, 'YData');
  zData = get(handle, 'ZData');
  if ~isempty(zData)
    % Don't do funny stuff when zData is present.
    return;
  end

  data = [xData(:), yData(:)];

  if isempty(data)
      return;
  end

  % Generate a mask which is true for the first point, and all
  % subsequent points which have a greater norm2-distance from
  % the previous point than 'threshold'.
  n = size(data, 1);

  % Get info about log scaling.
  isXlog = strcmp(get(meta.gca, 'XScale'), 'log');
  isYlog = strcmp(get(meta.gca, 'YScale'), 'log');

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

  % Make sure to keep NaNs.
  mask = mask | any(isnan(data)')';

  % Set the new (masked) data.
  set(handle, 'XData', data(mask, 1));
  set(handle, 'YData', data(mask, 2));

  return;
end
% =========================================================================
function movePointsCloser(meta, handle)
  % Move all points outside a box much larger than the visible one
  % to the boundary of that box and make sure that lines in the visible
  % box are preserved. This typically involves replacing one point by
  % two new ones and a NaN.

  % Extract the data from the current line handle.
  xData = get(handle, 'XData');
  yData = get(handle, 'YData');
  zData = get(handle, 'ZData');

  if ~isempty(zData) && any(zData(1)~=zData)
    % Don't do funny stuff with varying zData.
    return;
  end

  numberOfPoints = length(xData);
  data = [xData(:), yData(:)];

  xlim = get(meta.gca, 'XLim');
  ylim = get(meta.gca, 'YLim');

  xWidth = xlim(2) - xlim(1);
  yWidth = ylim(2) - ylim(1);
  % Don't choose the larger box too large to make sure that the values inside
  % it can still be treated by TeX.
  extendFactor = 0.1;
  largeXLim = xlim + extendFactor * [-xWidth, xWidth];
  largeYLim = ylim + extendFactor * [-yWidth, yWidth];

  % Get which points are in an extended box (the limits of which
  % don't exceed TeX's memory).
  dataIsInLargeBox = isInBox(data(:,1:2), ...
                             largeXLim, largeYLim);

  % Count the NaNs as being inside the box.
  dataIsInLargeBox = dataIsInLargeBox | any(isnan(data)')';

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
  lastEntryIsReplacement = false;
  for k = 1:m
     % Make sure that two subsequent moved points are separated by a NaN entry.
     % This is to make sure that there is no visible line between two moved
     % points that wasn't there before.
     d = data(lastReplIndex+1:replaceIndices(k)-1,:);
     if size(r{k}, 1) == 2
         % Two replacement entries -- pad them with a NaN.
         rep = [r{k}(1, :); ...
                NaN(1, size(r{k}, 2)); ...
                r{k}(2, :)];
     else
         rep = r{k};
     end

     % Don't draw line, if connecting line would be completely outside axis.
     % We can check this using a line clipping algorithm.
     % Illustration of the problem:
     % http://www.cc.gatech.edu/grads/h/Hao-wei.Hsieh/Haowei.Hsieh/sec1_example.html
     % This boils down to a line intersects line test, where all four lines of
     % the axis rectangle need to be considered.
     %
     % First consider two easy cases:
     % 1. This can't be the case, if last point was not replaced, because it is
     %    inside the axis limits ('lastEntryIsReplacement == 0').
     % 2. This can't be the case, if the current point will not be replace,
     %    because it is inside the axis limits.
     %    ( (isempty(d) && ~isempty(rep) == 0 ).
     if lastEntryIsReplacement && (isempty(d) && ~isempty(rep))
         % Now check if the connecting line goes through the axis rectangle.
         % OR: Only do this, if the original segment was not visible either
         bLineOutsideAxis = ~segmentVisible(...
             data([lastReplIndex,replaceIndices(k)],:), ...
             [false;false], xlim, ylim);

         % If line is completly outside the axis, don't draw the line. This is
         % achieved by adding a NaN and necessary, because the two points are
         % moved close to the axis limits and thus would afterwards show a
         % connecting line in the axis.
         if bLineOutsideAxis
             rep = [NaN(1, size(r{k}, 2)); rep];
         end
     end

     % Add the data, depending if it is a valid point or a replacement
     if ~isempty(d)     % Add current point from valid point 'd'
         dataNew = [dataNew; d];
         lastEntryIsReplacement = false;
     end
     if ~isempty(rep)   % Add current point from replacement point 'rep'
         dataNew = [dataNew; rep];
         lastEntryIsReplacement = true;
     end

     % Store last replacement index
     lastReplIndex = replaceIndices(k);
  end
  dataNew = [dataNew; ...
             data(lastReplIndex+1:end,:)];

  % Set the new (masked) data.
  set(handle, 'XData', dataNew(:,1));
  set(handle, 'YData', dataNew(:,2));
  if ~isempty(zData)
    % As per precondition, all zData entries are equal.
    zDataNew = zData(1) * ones(size(dataNew,1), 1);
    set(handle, 'zData', zDataNew);
  end

  return;
end
% =========================================================================
function xNew = moveToBox(x, xRef, xLim, yLim)
  % Takes a box defined by xlim, ylim, one point x and a reference point
  % xRef.
  % Returns the point xNew that sits on the line segment between x and xRef
  % *and* on the box. If several such points exist, take the closest one
  % to x.

  % Find out with which border the line x---xRef intersects, and determine
  % the smallest parameter alpha such that x + alpha*(xRef-x)
  % sits on the boundary.
  minAlpha = inf;
  [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim);
  %TODO: clean up duplicate code below, possibly store lambda in matrix

  % left boundary:
  lambda = crossLines(x, xRef, bottomLeft, topLeft);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % bottom boundary:
  lambda = crossLines(x, xRef, bottomLeft, bottomRight);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % right boundary:
  lambda = crossLines(x, xRef, bottomRight, topRight);
  if 0.0 < lambda(2) && lambda(2) < 1.0 && abs(minAlpha) > abs(lambda(1))
      minAlpha = lambda(1);
  end

  % top boundary:
  lambda = crossLines(x, xRef, topLeft, topRight);
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

  %TODO: why don't we use `\` instead of Cramer's rule?

  rhs = X3(:) - X1(:);
  % Don't divide by det(erminant), if it is zero. Directly return 'inf'.
  % Otherwise this yields "warning: division by zero" in octave. See #664.
  % A = [X2-X1, -(X4-X3)];
  detA = -(X2(1)-X1(1))*(X4(2)-X3(2)) + (X2(2)-X1(2))*(X4(1)-X3(1));

  if detA == 0
    invA = inf;
  else
    invA = [-(X4(2)-X3(2)), X4(1)-X3(1);...
            -(X2(2)-X1(2)), X2(1)-X1(1)] / detA;
  end
  lambda = invA * rhs;

end
% =========================================================================
