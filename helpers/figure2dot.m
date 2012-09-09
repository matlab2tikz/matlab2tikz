% =========================================================================
% *** FUNCTION figure2dot
% ***
% *** This very simple function generates a Graphviz (.dot) file displaying
% *** the children/parents relationships in a MATLAB figure (gcf).
% ***
% =========================================================================
%
%     Copyright (C) 2008 Nico Schl"omer
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% =========================================================================
function figure2dot( filename )

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
% *** END FUNCTION figure2dot
% =========================================================================


% =========================================================================
% *** FUNCTION plot_children
% ***
% *** This function does the actual work: display of the current node, descend
% *** to the children.
% ***
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
% *** END FUNCTION plot_children
% =========================================================================



% =========================================================================
% *** FUNCTION collapse
% ***
% *** This function collapses a cell of strings to a single string (with a
% *** given delimiter inbetween two strings, if desired).
% ***
% *** Example of usage:
% ***              collapse( cellstr, ',' )
% ***
% =========================================================================
function newstr = collapse( cellstr, delimiter )

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
% *** END FUNCTION collapse
% =========================================================================
