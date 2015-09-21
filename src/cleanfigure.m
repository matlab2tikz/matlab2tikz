function cleanfigure(varargin)
%   CLEANFIGURE() removes the unnecessary objects from your MATLAB plot
%   to give you a better experience with matlab2tikz.
%   CLEANFIGURE comes with several options that can be combined at will.
%
%   CLEANFIGURE('handle',HANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   CLEANFIGURE('targetResolution',PPI,...)
%   CLEANFIGURE('targetResolution',[W,H],...)
%   Reduce the number of data points in line objects by applying
%   unperceivable changes at the target resolution.
%   The target resolution can be specificed as the number of Pixels Per
%   Inch (PPI), e.g. 300, or as the Width and Heigth of the figure in
%   pixels, e.g. [9000, 5400].
%   Use targetResolution = Inf or 0 to disable line simplification.
%   (default: 600)
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
  m2t.cmdOpts = m2t.cmdOpts.addParamValue(m2t.cmdOpts, 'handle', gcf, @ishandle);
  m2t.cmdOpts = m2t.cmdOpts.addParamValue(m2t.cmdOpts, 'targetResolution', 600, @isValidTargetResolution);

  m2t.cmdOpts = m2t.cmdOpts.addParamValue(m2t.cmdOpts, 'minimumPointsDistance', 1.0e-10, @isnumeric);
  m2t.cmdOpts = m2t.cmdOpts.deprecateParam(m2t.cmdOpts, 'minimumPointsDistance', 'targetResolution');

  % Finally parse all the elements.
  m2t.cmdOpts = m2t.cmdOpts.parse(m2t.cmdOpts, varargin{:});

  % Recurse down the tree of plot objects and clean up the leaves.
  for h = m2t.cmdOpts.Results.handle(:)'
    recursiveCleanup(meta, h, m2t.cmdOpts.Results.targetResolution, 0);
  end

  % Reset to initial state.
  set(0, 'ShowHiddenHandles', shh);

  return;
end
% =========================================================================
function indent = recursiveCleanup(meta, h, targetResolution, indent)

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
          indent = recursiveCleanup(meta, child, targetResolution, indent);
          indent = indent - 4;
      end
  else
      % We're in a leaf, so apply all the fancy simplications.

      % Skip invisible objects.
      %if ~strcmp(get(h, 'Visible'), 'on')
      %    display(sprintf([repmat(' ',1,indent), '  invisible']))
      %    return;
      %end

      %display(sprintf([repmat(' ',1,indent), '  handle this']))

      if strcmp(type, 'line')
          simplifyLine(meta, h, targetResolution);
          pruneOutsideBox(meta, h);
          % Move some points closer to the box to avoid TeX:DimensionTooLarge
          % errors. This may involve inserting extra points.
          movePointsCloser(meta, h);
          setDataPrecision(meta, h);
      elseif strcmpi(type, 'stair')
          pruneOutsideBox(meta, h);
          setDataPrecision(meta, h);
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
function processData(meta, h, func, keyword, varargin)
  if strcmp(getEnvironment(), 'Octave')
    keyword  = lower(keyword);
    varargin = lower(varargin);
  end
    
  if isprop(h, keyword)
    arguments = cellfun(@(args) get(meta.gca, args), varargin, 'UniformOutput', false);
    data = func(get(h, keyword), arguments{:});
    set(h, keyword, data);
  end
end
% =========================================================================
function data = limitPrecision(data, scale)
  % Get the maximal value of the data
  if strcmp(scale,'linear')
    range = max(abs(data));
  else
    range = max(abs(log10(data)));
  end

  % Get the maximal precision for the data range
  eps_range = eps(range);
  
  % Scale the data wrt the range
  data  = data / eps_range;
  
  % Round to precision and scale back
  data  = round(data) * eps_range;
end
% =========================================================================
function setDataPrecision(meta, handle)
  processData(meta, handle, @limitPrecision, 'XData', 'XScale');
  processData(meta, handle, @limitPrecision, 'YData', 'YScale');
  
  if isprop(meta, handle, 'ZData')
    processData(handle, @limitPrecision, 'ZData', 'ZScale');
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

      % Get the indices of points that should be removed
      id_remove = find(~shouldPlot);

      % If there are consecutive data points to be removed, only replace 
      % the first one by a NaN. Consecutive data points have 
      % diff(id_remove)==1, so replace diff(id_remove)>1 by NaN and remove
      % the rest
      idx        = [true; diff(id_remove) >1];
      id_replace = id_remove(idx);
      id_remove  = id_remove(~idx);
      
      % Replace the data points
      data(id_replace,:) = NaN(length(id_replace), size(data,2));
      
      % Remove the other non visible data points
      data(id_remove,:) = [];
  end
  
  % Make sure that there are no NaNs at the beginning of the data since
  % this would be interpreted as column names by Pgfplots.
  % Also drop all NaNs at the end of the data
  notnan   = any(~isnan(data),2);
  id_first = find(notnan,1,'first');
  id_last  = find(notnan,1,'last');
  data     = data(id_first:id_last,:);

  % Override with the new data.
  set(handle, 'XData', data(:, 1));
  set(handle, 'YData', data(:, 2));
  if ~isempty(zData)
    set(handle, 'ZData', data(:, 3));
  end

  return;
end
% ==========================================================================
function [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim)
    % Determine the corners of the axes as defined by xLim and yLim
    bottomLeft  = [xLim(1); yLim(1)];
    topLeft     = [xLim(1); yLim(2)];
    bottomRight = [xLim(2); yLim(1)];
    topRight    = [xLim(2); yLim(2)];
end
% =========================================================================
function out = segmentVisible(data, dataIsInBox, xLim, yLim)
    % Given a bounding box {x,y}Lim, determine whether the line between all 
    % pairs of subsequent data points crosses the box.
    n = size(data, 1);
    out = false(n-1, 1);
    
    % Only check if there is more than 1 point    
    if n>1
        % Define the vectors of data points for the segments X1--X2
        idx= 1:n-1;
        X1 = data(idx,   :);
        X2 = data(idx+1, :);
        
        % One of the neighbors is inside the box and the other is finite
        thisVisible = (dataIsInBox(idx)     & all(isfinite(X2), 2));
        nextVisible = (dataIsInBox(idx+1)   & all(isfinite(X1), 2));

        % Get the corner coordinates
        [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim);

        % Check if data points intersect with the borders of the plot
        left   = segmentsIntersect(X1, X2, bottomLeft , topLeft);
        right  = segmentsIntersect(X1, X2, bottomRight, topRight);
        bottom = segmentsIntersect(X1, X2, bottomLeft , bottomRight);
        top    = segmentsIntersect(X1, X2, topLeft    , topRight);

        % Check the result
        out = thisVisible | nextVisible | left | right | top | bottom;
    end
end
% =========================================================================
function out = segmentsIntersect(X1, X2, X3, X4)
  % Checks whether the segments X1--X2 and X3--X4 intersect. 
  lambda = crossLines(X1, X2, X3, X4);
  
  % Check whether lambda is in bound
  out = 0.0 < lambda(:, 1) & lambda(:, 1) < 1.0 &...
        0.0 < lambda(:, 2) & lambda(:, 2) < 1.0;
end
% =========================================================================
function simplifyLine(meta, handle, targetResolution)
    % Reduce the number of data points in the line 'handle'.
    %
    % Aplies a path-simplification algorithm if there are no markers or
    % pixelization otherwise. Changes are visually negligible at the target
    % resolution.
    %
    % The target resolution is either specificed as the number of PPI or as
    % the [Width, Heigth] of the figure in pixels.
    % A scalar value of INF or 0 disables path simplification.
    % (default = 600)

    % Do not simpify
    if any(isinf(targetResolution) | targetResolution == 0)
        return
    end

    % Retrieve target figure size in pixels
    [W, H] = getWidthHeightInPixels(targetResolution);

    % Extract the data from the current line handle.
    xData = get(handle, 'XData');
    yData = get(handle, 'YData');
    zData = get(handle, 'ZData');

    if ~isempty(zData)
        % TODO: 3d simplificattion of frontal 2d projection
        return;
    end
    if isempty(xData) || isempty(yData)
        return;
    end
    if numel(xData) <= 2
        return;
    end

    % Get info about log scaling
    isXlog = strcmp(get(meta.gca, 'XScale'), 'log');
    vxData = xData;
    if isXlog
        vxData = log10(xData);
    end

    isYlog = strcmp(get(meta.gca, 'YScale'), 'log');
    vyData = yData;
    if isYlog
        vyData = log10(yData);
    end

    % Automatically guess a tol based on the area of the figure and
    % the area and resolution of the output
    xLim = xlim(meta.gca);
    if isXlog
        xLim = log10(xLim);
    end
    xrange = xLim(2)-xLim(1);
    yLim   = ylim(meta.gca);
    if isYlog
        yLim = log10(yLim);
    end
    yrange = yLim(2)-yLim(1);

    % Conversion factors of data units into pixels
    xToPix = W/xrange;
    yToPix = H/yrange;

    % If the path has markers, perform pixelation instead of simplification
    hasMarkers = ~strcmpi(get(handle,'Marker'),'none');
    if hasMarkers
        % Pixelate data at the zoom multiplier
        mask   = pixelate(vxData, vyData, xToPix, yToPix);
        xData  = xData(mask);
        yData  = yData(mask);
        set(handle, 'XData', xData);
        set(handle, 'YData', yData);
        return
    end

    xPixelWidth = 1/xToPix;
    yPixelWidth = 1/yToPix;
    tol = min(xPixelWidth,yPixelWidth);

    % Split up lines which are seperated by NaNs
    inan   = isnan(vxData) | isnan(vyData);
    df     = diff([false, ~inan, false]);
    pstart = find(df == 1);
    pend   = find(df == -1)-1;
    nlines = numel(pstart);

    [linesx, linesy] = deal(cell(1,nlines*2));
    for ii = 1:nlines
        % Visual data used for simplifications
        vx = vxData(pstart(ii):pend(ii));
        vy = vyData(pstart(ii):pend(ii));

        % Actual data that inherits the simplifications
        x = xData(pstart(ii):pend(ii));
        y = yData(pstart(ii):pend(ii));

        % Line simplification
        if numel(vx) > 2
            mask = opheimSimplify(vx,vy,tol);
            x    = x(mask);
            y    = y(mask);
        end

        % Place eventually simplified lines segments on odd positions
        linesx{ii*2-1} = x;
        linesy{ii*2-1} = y;

        % Add nans back (if any) in between the line segments
        linesx{ii*2} = nan;
        linesy{ii*2} = nan;
    end
    xData = [linesx{1:end-1}];
    yData = [linesy{1:end-1}];

    % Update with the new (masked) data
    set(handle, 'XData', xData);
    set(handle, 'YData', yData);
end
% =========================================================================
function mask = pixelate(x, y, xToPix, yToPix)
    % Rough reduction of data points at a multiple of the target resolution

    % The resolution is lost only beyond the multiplier magnification
    mult = 2;

    % Convert data to pixel units, magnify and mark only the first
    % point that occupies a given position
    mask = [true, diff(round(x * xToPix * mult))~=0];
    mask = [true, diff(round(y * yToPix * mult))~=0] | mask;

    % Keep end points or it might truncate whole pixels
    inan         = isnan(x) | isnan(y);
    df           = diff([false, inan, false]);
    istart       = df == 1;
    pend         = find(df == -1)-1;
    mask(istart) = true;
    mask(pend)   = true;
end
% =========================================================================
function mask = opheimSimplify(x,y,tol)
    % Opheim path simplification algorithm
    %
    % Given a path of vertices V and a tolerance TOL, the algorithm:
    %   1. selects the first vertex as the KEY;
    %   2. finds the first vertex farther than TOL from the KEY and links
    %      the two vertices with a LINE;
    %   3. finds the last vertex from KEY which stays within TOL from the
    %      LINE and sets it to be the LAST vertex. Removes all points in
    %      between the KEY and the LAST vertex;
    %   4. sets the KEY to the LAST vertex and restarts from step 2.
    %
    % The Opheim algorithm can produce unexpected results if the path
    % returns back on itself while remaining within TOL from the LINE.
    % This behaviour can be seen in the following example:
    %
    %   x   = [1,2,2,2,3];
    %   y   = [1,1,2,1,1];
    %   tol < 1
    %
    % The algorithm undesirably removes the second last point. See
    % https://github.com/matlab2tikz/matlab2tikz/pull/585#issuecomment-89397577
    % for additional details.
    %
    % To rectify this issues, step 3 is modified to find the LAST vertex as
    % follows:
    %   3*. finds the last vertex from KEY which stays within TOL from the
    %       LINE, or the vertex that connected to its previous point forms
    %       a segment which spans an angle with LINE larger than 90
    %       degrees.

    mask = false(size(x));
    mask(1) = true;
    mask(end) = true;

    N = numel(x);
    i = 1;
    while i <= N-2
        % Find first vertex farther than TOL from the KEY
        j = i+1;
        v = [x(j)-x(i); y(j)-y(i)];
        while j < N && norm(v) <= tol
            j = j+1;
            v = [x(j)-x(i); y(j)-y(i)];
        end
        v = v/norm(v);

        % Unit normal to the line between point i and point j
        normal = [v(2);-v(1)];

        % Find the last point which stays within TOL from the line
        % connecting i to j, or the last point within a direction change
        % of pi/2.
        % Starts from the j+1 points, since all previous points are within
        % TOL by construction.
        while j < N
            % Calculate the perpendicular distance from the i->j line
            v1 = [x(j+1)-x(i); y(j+1)-y(i)];
            d = abs(normal.'*v1);
            if d > tol
                break
            end

            % Calculate the angle between the line from the i->j and the
            % line from j -> j+1. If
            v2 = [x(j+1)-x(j); y(j+1)-y(j)];
            anglecosine = v.'*v2;
            if anglecosine <= 0;
                break
            end
            j = j + 1;
        end
        i = j;
        mask(i) = true;
    end
end
% =========================================================================
function [W, H] = getWidthHeightInPixels(targetResolution)
    % Retrieves target figure width and height in pixels
    % TODO: If targetResolution is a scalar, W and H are determined
    % differently on different environments (octave, local vs. Travis).
    % It is unclear why, as this even happens, if `Units` and `Position`
    % are matching. Could it be that the `set(gcf,'Units','Inches')` is not
    % taken into consideration for `Position`, directly after setting it?

    % targetResolution is PPI
    if isscalar(targetResolution)
        % Query figure size in inches and convert W and H to target pixels
        oldunits  = get(gcf,'Units');
        set(gcf,'Units','Inches');
        figSizeIn = get(gcf,'Position');
        W         = figSizeIn(3) * targetResolution;
        H         = figSizeIn(4) * targetResolution;
        set(gcf,'Units', oldunits) % restore original unit

    % It is already in the format we want
    else
        W = targetResolution(1);
        H = targetResolution(2);
    end
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
  
  data = [xData(:), yData(:)];

  xlim = get(meta.gca, 'XLim');
  ylim = get(meta.gca, 'YLim');

  % Calculate the extension of the extended box  
  xWidth = xlim(2) - xlim(1);
  yWidth = ylim(2) - ylim(1);
  
  % Don't choose the larger box too large to make sure that the values inside
  % it can still be treated by TeX.
  extendFactor = 0.1;
  largeXLim = xlim + extendFactor * [-xWidth, xWidth];
  largeYLim = ylim + extendFactor * [-yWidth, yWidth];

  % Get which points are in an extended box (the limits of which
  % don't exceed TeX's memory).
  dataIsInLargeBox = isInBox(data(:, 1:2), largeXLim, largeYLim);

  % Count the NaNs as being inside the box.
  dataIsInLargeBox = dataIsInLargeBox | any(isnan(data), 2);

  % Find all points which are to be included in the plot yet do not fit
  % into the extended box
  replaceIndices = find(~dataIsInLargeBox);  
  
  % Only try to replace points if there are some to replace
  if (~isempty(replaceIndices))
      % Check whether the points are finite.
      DataIsFinite = all(isfinite(data(replaceIndices,:)), 2);

      % Get the indices of those points, that are the first point in a
      % segment
      id_first  = replaceIndices(replaceIndices < size(data, 1) & DataIsFinite);

      % Get the indices of those points, that are the second point in a
      % segment
      id_second = replaceIndices(replaceIndices > 1  & DataIsFinite);

      % Define the vectors of data points for the segments X1--X2
      X1_first  = data(id_first,    :);
      X2_first  = data(id_first+1,  :);
      X1_second = data(id_second,   :);
      X2_second = data(id_second-1, :);

      % Move the points closer to the large box along the segment
      newData_first = moveToBox(X1_first,  X2_first,  largeXLim, largeYLim);
      newData_second= moveToBox(X1_second, X2_second, largeXLim, largeYLim);

      % If newData_* is infinite, the segment was not visible. However, as we
      % move the point closer, it would become visible. So insert a NaN.
      isInfinite_first  = any(~isfinite(newData_first),  2);
      isInfinite_second = any(~isfinite(newData_second), 2);

      newData_first(isInfinite_first,  :) = NaN(sum(isInfinite_first),  2);
      newData_second(isInfinite_second,:) = NaN(sum(isInfinite_second), 2);

      % If a point is part of two segments, that cross the border, we need to
      % insert a NaN to prevent an additional line segment
      [trash, trash, id_conflict] = intersect(id_first (~isInfinite_first), ...
                                      id_second(~isInfinite_second));

      % Cut the data into length(replaceIndices)+1 segments.
      % Calculate the length of the segments
      length_segments = [replaceIndices(1);
                         diff(replaceIndices);
                         size(data, 1)-replaceIndices(end)];

      % Cut the data into segments
      dataCell = mat2cell(data, length_segments, 2);

      % Remove the last point of every segment except the last one as they
      % will be replaced
      dataCell(1:end-1) = cellfun(@(x) x(1:end-1,:), dataCell(1:end-1), 'UniformOutput', false);

      % Create an empty cell array for inserting NaNs and fill it at the
      % conflict sites
      dataInsert_NaN   = cell(length(length_segments),1);
      dataInsert_NaN(id_conflict) = mat2cell(NaN(length(id_conflict), 2),...
                                             ones(size(id_conflict)), 2);

      % Create a cell array for the moved points
      dataInsert_first  = mat2cell(newData_first,  ones(size(id_first)),  2);
      dataInsert_second = mat2cell(newData_second, ones(size(id_second)), 2);

      % Add an empty cell at the end of the last segment
      dataInsert_first  = [dataInsert_first;  cell(1)];
      dataInsert_second = [dataInsert_second; cell(1)];

      % If the first or the last point would have been replaced add an empty
      % cell at the beginning/end
      if(replaceIndices(end) == size(data, 1))
        dataInsert_first  = [dataInsert_first; cell(1)];
      end
      if(replaceIndices(1) == 1)
        dataInsert_second = [cell(1); dataInsert_second];
      end

      % Put the cells together, right points first, then the possible NaN
      % and then the left points
      dataCell = [dataCell';
                  dataInsert_second';
                  dataInsert_NaN';
                  dataInsert_first'];

      % Merge the cells back together
      data     = cat(1, dataCell{:});
  end

  % Remove consecutive NaNs
  id_NaN = find(isnan(data(:, 1)));
  id_NaN = id_NaN(diff(id_NaN) == 1);
  data(id_NaN, :) = [];

  % Set the new (masked) data.
  set(handle, 'XData', data(:, 1));
  set(handle, 'YData', data(:, 2));
  if ~isempty(zData)
    % As per precondition, all zData entries are equal.
    zDataNew = zData(1) * ones(size(data, 1), 1);
    set(handle, 'zData', zDataNew);
  end

  return;
end
% =========================================================================
function xNew = moveToBox(x, xRef, xLim, yLim)
  % Takes a box defined by xlim, ylim, a vector of points x and a vector of 
  % reference points xRef.
  % Returns the vector of points xNew that sits on the line segment between 
  % x and xRef *and* on the box. If several such points exist, take the 
  % closest one to x.
  n = size(x, 1);

  % Find out with which border the line x---xRef intersects, and determine
  % the smallest parameter alpha such that x + alpha*(xRef-x)
  % sits on the boundary. Otherwise set Alpha to inf.
  minAlpha = inf(n, 1);
  
  % Get the corner points
  [bottomLeft, topLeft, bottomRight, topRight] = corners(xLim, yLim);

  % left boundary:
  minAlpha = updateAlpha(x, xRef, bottomLeft, topLeft, minAlpha);

  % bottom boundary:
  minAlpha = updateAlpha(x, xRef, bottomLeft, bottomRight, minAlpha);

  % right boundary:
  minAlpha = updateAlpha(x, xRef, bottomRight, topRight, minAlpha);
  
  % top boundary:
  minAlpha = updateAlpha(x, xRef, topLeft, topRight, minAlpha);

  % Create the new point
  xNew = x + bsxfun(@times ,minAlpha, (xRef-x));
end
% =========================================================================
function minAlpha = updateAlpha(X1, X2, X3, X4, minAlpha)
  % Checks whether the segments X1--X2 and X3--X4 intersect. 
  lambda = crossLines(X1, X2, X3, X4);
  
  % Check if lambda is in bounds and lambda1 large enough
  id_Alpha           = 0.0 < lambda(:,2) & lambda(:,2) < 1.0 ...
                     & abs(minAlpha) > abs(lambda(:,1));

  % Update alpha when applicable
  minAlpha(id_Alpha) = lambda(id_Alpha,1);
end
% =========================================================================
function out = isInBox(data, xLim, yLim)

  out = data(:,1) > xLim(1) & data(:,1) < xLim(2) ...
      & data(:,2) > yLim(1) & data(:,2) < yLim(2);
end
% =========================================================================
function lambda = crossLines(X1, X2, X3, X4)
  % Checks whether the segments X1--X2 and X3--X4 intersect.
  % See https://en.wikipedia.org/wiki/Line-line_intersection for reference.
  % Given four points X_k=(x_k,y_k), k\in{1,2,3,4}, and the two lines 
  % defined by those,
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
  % for lambda1 and lambda2.

  % Now X1 is a vector of all data points X1 and X2 is a vector of all
  % consecutive data points X2
  % n is the number of segments (not points in the plot!)
  n      = size(X2, 1);
  lambda = zeros(n, 2);
  
  % Calculate the determinant of A = [X2-X1, -(X4-X3)];
  % detA = -(X2(1)-X1(1))*(X4(2)-X3(2)) + (X2(2)-X1(2))*(X4(1)-X3(1))
  % NOTE: Vectorized this is equivalent to the matrix multiplication
  % [nx2] * [2x2] * [2x1] = [nx1]
  detA = -(X2(:, 1)-X1(:, 1)) .* (X4(2)-X3(2)) + (X2(:, 2)-X1(:, 2)) .* (X4(1)-X3(1));  
  
  % Get the indices for nonzero elements
  id_detA = detA~=0;
  
  if any(id_detA)
      % rhs = X3(:) - X1(:)
      % NOTE: Originaly this was a [2x1] vector. However as we vectorize the 
      % calculation it is beneficial to treat it as an [nx2] matrix rather than a [2xn]
      rhs = bsxfun(@minus, X3', X1);
      
      % Calculate the inverse of A and lambda
      % invA=[-(X4(2)-X3(2)), X4(1)-X3(1);...
      %       -(X2(2)-X1(2)), X2(1)-X1(1)] / detA 
      % lambda = invA * rhs
  
      % Rotational matrix with sign flip. It transforms a given vector [a,b] by 
      % Rotate * [a,b] = [-b,a] as required for calculation of invA  
      Rotate = [0, -1; 1, 0];   


      % Rather than calculating invA first and then multiply with rhs to obtain 
      % lambda, directly calculate the respective terms
      % The upper half of the 2x2 matrix is always the same and is given by:
      % [-(X4(2)-X3(2)), X4(1)-X3(1)] / detA * rhs
      % This is a matrix multiplication of the form [1x2] * [2x1] = [1x1]
      % As we have transposed rhs we can write this as:
      % rhs * Rotate * (X4-X3) => [nx2] * [2x2] * [2x1] = [nx1]
      lambda(id_detA, 1) = (rhs(id_detA, :) * Rotate * (X4-X3))./detA(id_detA);

      % The lower half is dependent on (X2-X1) which is a matrix of size [nx2]
      % [-(X2(2)-X1(2)), X2(1)-X1(1)] / detA * rhs 
      % As both (X2-X1) and rhs are matrices of size [nx2] there is no simple 
      % matrix multiplication leading to a [nx1] vector. Therefore, use the
      % elementwise multiplication and sum over it
      % sum( [nx2] * [2x2] .* [nx2], 2) = sum([nx2],2) = [nx1] 
      lambda(id_detA, 2) = sum(-(X2(id_detA, :)-X1(id_detA, :)) * Rotate .* rhs(id_detA, :), 2)./detA(id_detA);
  end
end
% =========================================================================
function bool = isValidTargetResolution(val)
    bool = isnumeric(val) && ~any(isnan(val)) && (isscalar(val) || numel(val) == 2);
end
% =========================================================================
