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
%      pointReduction2d(0.1);
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

  % Don't try to be smart about quiver groups.
  if strcmp(class(handle(h)), 'specgraph.quivergroup')
      return;
  end

  children = get(h, 'Children');
  if ~isempty(children)
      for child = children(:)'
          recursiveCleanup(child);
      end
  else
      type = get(h, 'Type');
      if strcmp(type, 'line')
          pointReduction(h);
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
function pointReduction(handle)
  % Reduce the number of data points in the line handle.
  % Given a minimum distance at which two nodes are considered different,
  % this can help with plots that contain a large amount of data points not
  % all of which need to be plotted.
  %
  minimumPointsDistance = 1.0e-10;

  if ( abs(minimumPointsDistance) < 1.0e-15 )
      % bail out early
      return
  end

  % Extract the data from the current line handle.
  data = [get(handle, 'XData')', get(handle, 'YData')'];

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
