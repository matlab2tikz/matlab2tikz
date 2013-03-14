function figure2dot( filename )
%FIGURE2DOT    Save figure in Graphviz (.dot) file.
%   FIGURE2DOT() saves the current figure as dot-file.
%

%   Copyright (c) 2008--2013, Nico Schlömer <nico.schloemer@gmail.com>
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
  global node_number

  % also show hidden handles
  set( 0, 'ShowHiddenHandles', 'on' );

  filehandle = fopen( filename, 'w' );

  % start printing
  fprintf( filehandle, 'digraph simple_hierarchy {\n\n' );

  fprintf( filehandle, 'node[shape=box];\n\n' );

  % define the root node
  node_number = 0;
  p = get( gcf, 'Parent' );
  % define root element
  type = get( p, 'Type' );
  fprintf( filehandle, 'N%d [label="%s"]\n\n', node_number, type );

  % start recursion
  plot_children( filehandle, p, node_number );

  % finish off
  fprintf( filehandle, '}' );
  fclose( filehandle );
  set( 0, 'ShowHiddenHandles', 'off' );

end
% =========================================================================
function plot_children( fh, h, id )

  global node_number

  % get the children
  children = get( h, 'Children' );

  % -----------------------------------------------------------------------
  % loop through the children
  for k= 1:length(children)

      % define child number
      node_number = node_number + 1;

      type = get( children(k), 'Type' );

      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % skip certain entries
      if  strcmp( type, 'uimenu'        ) || ...
          strcmp( type, 'uitoolbar'     ) || ...
          strcmp( type, 'uicontextmenu' )
          continue;
      end
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


      label = cell(0);
      label = [ label, sprintf( 'Type: %s' , type   ) ];

      hClass = class( handle(children(k)) );
      label  = [ label, sprintf( 'Class: %s', hClass ) ];

      tag = get( children(k), 'Tag'  );
      if ~isempty(tag)
          label = [ label, sprintf( 'Tag: %s', tag ) ];
      end

      visibility = get( children(k), 'Visible' );
      color = []; % set default value
      if ~strcmp( visibility , 'on' )
          label = [ label, sprintf( 'Visible: %s', visibility ) ];
          color = 'gray';
      end

      handlevisibility = get( children(k), 'HandleVisibility' );
      if ~ strcmp( handlevisibility , 'on' )
          label = [ label, sprintf( 'HandleVisibility: %s', handlevisibility ) ];
      end

      % gather options
      options = cell(0);
      if ~isempty(label)
          options = [ options, [ 'label=',collapse(label,'\n') ] ];
      end
      if ~isempty(color)
          options = [ options, [ 'color=',color ] ];
      end


      % print node
      fprintf( fh, 'N%d [label="%s"]\n', node_number, collapse(label,'\n') );

      % connect to the child
      fprintf( fh, 'N%d -> N%d;\n\n', id, node_number );

      % recurse
      plot_children( fh, children(k), node_number );
  end
  % -----------------------------------------------------------------------

end
% =========================================================================
function newstr = collapse( cellstr, delimiter )
  % This function collapses a cell of strings to a single string (with a
  % given delimiter inbetween two strings, if desired).
  %
  % Example of usage:
  %              collapse( cellstr, ',' )

  if length(cellstr)<1
     newstr = [];
     return
  end

  if isnumeric( cellstr{1} )
      newstr = my_num2str( cellstr{1} );
  else
      newstr = cellstr{1};
  end

  for k = 2:length( cellstr )
      if isnumeric( cellstr{k} )
          str = my_num2str( cellstr{k} );
      else
          str = cellstr{k};
      end
      newstr = [ newstr, delimiter, str ];
  end

end
% =========================================================================
