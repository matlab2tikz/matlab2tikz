function figure2dot(filename, varargin)
%FIGURE2DOT    Save figure in Graphviz (.dot) file.
%  FIGURE2DOT(filename) saves the current figure as dot-file.
%
%  FIGURE2DOT(filename, 'object', HGOBJECT) constructs the graph representation
%  of the specified object (default: gcf)
%
%  You can visualize the constructed DOT file using:
%    - [GraphViz](http://www.graphviz.org) on your computer
%    - [WebGraphViz](http://www.webgraphviz.com) online
%    - [Gravizo](http://www.gravizo.com) for your markdown files
%    - and a lot of other software such as OmniGraffle
%

%   Copyright (c) 2008--2014, Nico Schlömer <nico.schloemer@gmail.com>
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
%
% =========================================================================

    ipp = m2tInputParser();
    ipp = ipp.addRequired(ipp, 'filename', @ischar);
    ipp = ipp.addParamValue(ipp, 'object', gcf, @ishghandle);
    ipp = ipp.parse(ipp, filename, varargin{:});
    args = ipp.Results;

    filehandle = fopen(args.filename, 'w');
    finally_fclose_filehandle = onCleanup(@() fclose(filehandle));

    % start printing
    fprintf(filehandle, 'digraph simple_hierarchy {\n\n');
    fprintf(filehandle, 'node[shape=box];\n\n');

    % define the root node
    node_number = 0;
    p = get(args.object, 'Parent');
    % define root element
    type = get(p, 'Type');
    fprintf(filehandle, 'N%d [label="%s"]\n\n', node_number, type);

    % start recursion
    plot_children(filehandle, p, node_number);

    % finish off
    fprintf(filehandle, '}');

    % ----------------------------------------------------------------------------
    function plot_children(fh, h, parent_node)

        children = allchild(h);

        for h = children(:)'
            if shouldSkip(h), continue, end;
            node_number = node_number + 1;

            label = {};
            label = addHGProperty(label, h, 'Type', '');
            try
                hClass = class(handle(h));
                label = addProperty(label, 'Class', hClass);
            catch
                % don't do anything
            end
            label = addProperty(label, 'Handle', sprintf('%g', double(h)));
            label = addHGProperty(label, h, 'Title', '');
            label = addHGProperty(label, h, 'String', '');
            label = addHGProperty(label, h, 'Tag', '');
            label = addHGProperty(label, h, 'DisplayName', '');
            label = addHGProperty(label, h, 'Visible', 'on');
            label = addHGProperty(label, h, 'HandleVisibility', 'on');

            % print node
            fprintf(fh, 'N%d [label="%s"]\n', ...
                    node_number, m2tstrjoin(label, '\n'));

            % connect to the child
            fprintf(fh, 'N%d -> N%d;\n\n', parent_node, node_number);

            % recurse
            plot_children(fh, h, node_number);
        end
    end
end
% ==============================================================================
function bool = shouldSkip(h)
    %  returns TRUE for objects that can be skipped
    objType = get(h, 'Type');
    bool = ismember(lower(objType), {'uimenu', 'uitoolbar', 'uicontextmenu'});
    %FIXME: maybe integrate this in matlab2tikz?
end
% ==============================================================================
function label = addHGProperty(label, h, propName, default)
    % get a HG property and assign it to a GraphViz node label
    if ~exist('default','var') || isempty(default)
        shouldOmit = @isempty;
    elseif isa(default, 'function_handle')
        shouldOmit = default;
    else
        shouldOmit = @(v) isequal(v,default);
    end

    if isprop(h, propName)
        propValue = get(h, propName);
        if numel(propValue) == 1 && ishghandle(propValue) && isprop(propValue, 'String')
            % dereference Titles, labels, ...
            propValue = get(propValue, 'String');
        elseif iscell(propValue)
            propValue = ['{' m2tstrjoin(propValue,',') '}'];
        end

        if ~shouldOmit(propValue)
            label = addProperty(label, propName, propValue);
        end
    end
end
function label = addProperty(label, propName, propValue)
    % add a property to a GraphViz node label
    if isnumeric(propValue)
        propValue = num2str(propValue);
    elseif iscell(propValue)
        propValue = m2tstrjoin(propValue,sprintf('\n'));
    end
    label = [label, sprintf('%s: %s', propName, propValue)];
end
% ==============================================================================
