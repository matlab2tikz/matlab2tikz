function cleanfigure(varargin)
%   CLEANFIGURE() removes the unnecessary objects from your MATLAB plot
%   to give you a better experience with matlab2tikz.
%   CLEANFIGURE comes with several options that can be combined at will.
%
%   CLEANFIGURE('handle',HANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   CLEANFIGURE('targetResolution',[W,H,RES],...)  
%   Reduce the number of data points in the line handle by applying
%   unperceivable changes at the target resolution.
%   W and H are the target width and height of the figure, e.g. 15x9 cm, and 
%   RES is the target resolution of a unit square, e.g. 600 pixels per cm^2.
%   Use targetResolution = Inf, or targetResolution(3) = Inf to disable 
%   line simplification. (default: [15 9 600])
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
% =========================================================================
function out = segmentVisible(data, dataIsInBox, xLim, yLim)
    % Given a bounding box {x,y}Lim, loop through all pairs of subsequent nodes
    % in p and determine whether the line between the pair crosses the box.

    n = size(data, 1);
    out = false(n-1, 1);
    for k = 1:n-1
        out(k) =  (dataIsInBox(k) && all(isfinite(data(k+1,:)))) ... % one of the neighbors is inside the box
               || (dataIsInBox(k+1) && all(isfinite(data(k,:)))) ... % and the other is finite
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(1)], [xLim(1);yLim(2)]) ... % left border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(1)], [xLim(2);yLim(1)]) ... % bottom border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(2);yLim(1)], [xLim(2);yLim(2)]) ... % right border
               || segmentsIntersect(data(k,:), data(k+1,:), ...
                                    [xLim(1);yLim(2)], [xLim(2);yLim(2)]); % top border
    end

end
% =========================================================================
function out = segmentsIntersect(X1, X2, X3, X4)
  % Checks whether the segments X1--X2 and X3--X4 intersect.
  lambda = crossLines(X1, X2, X3, X4);
  out = all(lambda > 0.0) && all(lambda < 1.0);
  return
end
% =========================================================================
function simplifyLine(meta, handle, targetResolution)
    % Reduce the number of data points in the line 'handle', first by 
    % reducing the resolution up to a zoom multiplier and then by 
    % simplifying the path of the line by ensuring the change is negligible
    % at the target resolution.
    %
    % 'targetResolution' is in format [W,H,RES], where W and H are the
    % target width and height of the figure, and RES is the target 
    % resolution in points of a unit square. (default: [15 9 600])
    %
    % Use targetResolution = Inf, or targetResolution(3) = Inf to disable line
    % simplification.

    % The figure is pixelated at N times the target resolution before the 
    % real line simplification. 
    ZOOM_MULTIPLIER = 4;
    
    % Do not simpify
    if any(isinf(targetResolution) | targetResolution == 0)
        return
    end
    
    % Target Pixels Per Inch 
    if isscalar(targetResolution)
        PPI       = targetResolution;
        oldunits  = get(gcf,'Units');
        set(gcf,'Units','Inches');
        figSizeIn = get(gcf,'Position'); % query figure size in inches
        W         = figSizeIn(3);
        H         = figSizeIn(4);
        set(gcf,'Units', oldunits) % restore original unit
    % Target W x H in pixels 
    else
        W   = targetResolution(1);
        H   = targetResolution(2);
        PPI = 1;
    end
    
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
    a = axis(meta.gca);
    if ~isXlog
        xrange = (a(2)-a(1));
    else
        xrange = (log10(a(2))-log10(a(1)));
    end
    if ~isYlog
        yrange = (a(4)-a(3));
    else
        yrange = (log10(a(4))-log10(a(3)));
    end
    tol = xrange*yrange/(W*H*PPI^2);
    
    % Conversion factors of data units into pixels
    xToPix = W*PPI/xrange;
    yToPix = H*PPI/yrange;
    
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
        
        % Pixelate data at the zoom multiplier 
        mask = pixelate(vx, vy, xToPix, yToPix, ZOOM_MULTIPLIER);
        vx   = vx(mask);
        vy   = vy(mask);
        x    = x(mask);
        y    = y(mask); 
        
        % Line simplification
        if numel(vx) > 2
            area = featureArea(vx,vy);
            x    = x(area>tol);
            y    = y(area>tol);
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
    
    function mask = pixelate(x, y, xToPix, yToPix, multiplier)
        % Resolution is lost only beyond the multiplier magnification

        % Convert data to pixel units, magnify and mark only the first
        % point that occupies a given position
        mask = [true,diff(round(x * xToPix * multiplier))~=0];
        mask = [true,diff(round(y * yToPix * multiplier))~=0] | mask;

        % Keep end point or it might truncate a whole pixel
        mask(end) = true;
    end
end
% =========================================================================
function a = featureArea(x,y)
    % The function uses Visvalingam's line simplification algorithm to skip
    % points on the path defined by X and Y, and returns the vector of
    % areas A affected by each of these changes.
    %
    % Every time a point is removed from the path, the algorithm calculates
    % the area of the triangle formed by the skipped point and its
    % neighbors. The bigger the area, the stronger is the perceived change
    % in the path.
    % The algorithm builds the list of areas sequentially and the final
    % simplification filters out only those points whose area is below a
    % certain threshold, i.e. the perceived change is negligible.
    %
    % For a graphical example see: http://bost.ocks.org/mike/simplify/
    %
    % Runtime is O(n log(n))
    %
    % Used by 'simplifyLine'.

    % The algorithm simplifies the path in ascending order of the changed
    % area. Every time a point is skipped, the two adjacent areas have to
    % be recalculated and a new minimum has to be found. The implementation
    % takes advantage of a min heap and a linked list of vertices (see
    % http://en.wikipedia.org/wiki/Binary_heap)

    n = numel(x);

    % Index of next and previous elements in the linked list which defines
    % the path
    linkedList = [(0:n-1)',[(2:n)';0]];

    % 'heap' stores the points in an (implicit) heap, referenced by their index.
    % First and last points are assumed fixed and not added to the heap.
    heap = (2:n-1)';
    len = numel(heap);

    % 'pos' stores the current position of each point in the heap array.
    % Needed to lookup position of points when their neighbours are updated.
    %
    % pos(i) = 0 denotes that the elements are not in the heap.
    pos = [0;(1:len)';0];

    % Area of the triangle with verticies at index i, j and k in the line.
    % See http://en.wikipedia.org/wiki/Triangle#Using_coordinates (Shoelace
    % formula)
    area = @(i,j,k) abs((y(j) - y(k)).*x(i) + (y(k)-y(i)).*x(j) + ...
        (y(i)-y(j)).*x(k))/2;

    % Endpoints are assigned infinte area so they can't be removed
    a = [Inf;area((1:n-2)', (2:n-1)', (3:n)')';Inf];

    % Keep track of the maximum area removed so far to ensure
    % a given element will only be excluded after earlier elements
    maxArea = 0;

    % Heapify the 'heap' array based on the area, using Floyd's alg
    root = bitshift(len,-1); %starting with the first parent node
    while root >= 1
        down(root);
        root = root-1;
    end

    % Now iteratively remove the point associated with the minimum area from
    % the path, and update it's neighbours
    while len > 1
        % Ensure the current element is excluded only after the elements
        % which were removed earlier
        if a(heap(1)) > maxArea
            maxArea = a(heap(1));
        else
            a(heap(1)) = maxArea;
        end

        % Remove smallest element from heap
        e = pop(1);

        % Remove same element from linked list
        left = linkedList(e,1);
        right = linkedList(e,2);
        linkedList(left,2) = linkedList(e,2);
        linkedList(right,1) = linkedList(e,1);

        % Update area of neighbouring points (unless ends points)
        if linkedList(left,1) > 0
            a(left) = area(linkedList(left,1),left,linkedList(left,2));
            pop(pos(left));
            push();
        end

        if linkedList(right,2) > 0
            a(right) = area(linkedList(right,1),right,linkedList(right,2));
            pop(pos(right));
            push();
        end
    end

    % Update the last element on the heap
    if numel(heap) >0 &&  a(heap(1)) < maxArea
        a(heap(1)) = maxArea;
    end

    % Heap utility functions
    function down(root)
        % Move element at "root" down the heap, assuming the heap property
        % is satisfied for the rest of the tree
        while 2*root  <= len %while the root has a child
            lchild = 2*root;
            rchild = lchild+1;
            % Find the minimum of the root and its children
            minimum = root;
            if a(heap(lchild)) < a(heap(minimum))
                minimum = lchild;
            end
            if rchild <= len && (a(heap(rchild)) < a(heap(minimum)))
                minimum = rchild;
            end

            if minimum == root
                % if the root is the minimum, then we're done
                break
            else
                % otherwise, swap the root and its minimum child and continue
                pos(heap([root,minimum])) = [minimum,root];
                heap([root,minimum]) = heap([minimum,root]);
                root = minimum;
            end
        end
    end

    function up(child)
        % Move element up the heap until it finds the correct position
        while child > 1
            parent = bitshift(n,-1);
            if a(heap(child)) < a(heap(parent))
                % If this element is less than its parent, swap them
                pos(heap([parent,child])) = [child,parent];
                heap([parent,child]) = heap([child,parent]);
                child = parent;
            else
                % Otherwise the heap property is restored
                break
            end
        end
    end

    function e = pop(i)
        % Remove element at position i off the heap and return its value

        e = heap(i);

        % Swap the first and the last
        pos(heap([i,len])) = [len,i];
        heap([i,len]) = heap([len,i]);

        % Remove the last element from the heap
        len = len-1;

        % Move the new ith element down the heap until it finds the correct spot
        down(i);
    end

    function push()
        % Add the element at len+1 in the 'heap' array back into the heap
        len = len+1;
        up(len);
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
function bool = isValidTargetResolution(val)
    bool = isnumeric(val) && ~any(isnan(val)) && (isscalar(val) || numel(val) == 2);
end
% =========================================================================
