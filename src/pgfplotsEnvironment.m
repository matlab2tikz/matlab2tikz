% Make 'pgfplotsEnvironment' a subclass of MATLAB's very own 'handle' class
% to retain some of the expected default (C++) class behavior.
% See, e.g., <http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_oop/brfylwk-1.html>.
classdef pgfplotsEnvironment < hgsetget
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public properties
    properties
        name;
        comment = '';
    end
    % --------------------------------------------------------------------------
    % private properties
    properties ( SetAccess = private )
        options  = cell(0);
        content  = cell(0);
        children = cell(0);
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        % ======================================================================
        function prepend(this,str)
            if ~ischar(str)
                error( 'Argument must be of class ''string''.' );
            end

            if ~isempty(str)
                this.content = [ str, this.content ];
            end
            return;
        end
        % ======================================================================
        function append(this,str)
            if isempty(str)
                return;
            end
            if ~ischar(str)
                error( 'Argument must be of class ''string''.' );
            end

            this.content = [ this.content, str ];
            return;
        end
        % ======================================================================
        function appendOptions( this, opts )
            if isempty(opts)
                return;
            end

            if ischar(opts)
                this.options = [ this.options, opts ];
            elseif iscellstr(opts)
                for k = 1:length(opts)
                    this.options = [ this.options, opts{k} ];
                end
            else
                error( 'Argument must be of class ''string'' or cell of strings.' );
            end

            return
        end
        % ======================================================================
        function addChildren( this, pgfplotsItems )

            if isempty(pgfplotsItems)
                return;
            end

            if iscell(pgfplotsItems)
                for k = 1:length(pgfplotsItems)
                    this.addChildren( pgfplotsItems{k} );
                end
            elseif ischar(pgfplotsItems) || all(class(pgfplotsItems)=='pgfplotsEnvironment')
                if isempty(this.children)
                    this.children = {pgfplotsItems};
                else
                    % TODO Get something simpler here.
                    tmp = cell( length(this.children), 1 );
                    for k = 1:length(this.children)
                        tmp{k} = this.children{k};
                    end
                    tmp{length(this.children)+1} = pgfplotsItems;
                    this.children = tmp;
                end
            else
                error( 'Argument must be of class ''pgfplotsEnvironment'' or a string or a cell of those.' );
            end

            return;
        end
        % ======================================================================
        function print(this,fid)

            if ~isempty(this.comment)
                fprintf( fid, '%% %s\n', regexprep( this.comment, '\n', '\n% ' ) );
            end

            if isempty(this.options)
                fprintf( fid, '\\begin{%s}\n', this.name );
            else
                fprintf( fid, '\\begin{%s}[%%\n%s]\n', this.name, collapse(this.options, sprintf(',\n')) );
            end

            for k = 1:length(this.content)
                fprintf( fid, '%s', this.content{k} );
            end

            for k = 1:length( this.children )
                if ischar( this.children{k} )
                    fprintf( fid, escapeCharacters(this.children{k}) );
                elseif all(class(this.children{k})=='pgfplotsEnvironment')
                    fprintf( fid, '\n' );
                    this.children{k}.print( fid );
                end
            end

            fprintf( fid, '\\end{%s}\n', this.name );
        end
    end % public methods
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % classdef

% helper functions
% ==============================================================================
function newstr = collapse( cellstr, delimiter )

  if ~iscellstr( cellstr )
      error( 'Expected ''cellstr''.' );
  end

  if isempty(cellstr)
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
% ==============================================================================
% *** FUNCTION escapeCharacters
% ***
% *** Replaces the single characters %, ', \ by their escaped versions
% *** \'', %%, \\, respectively.
% ***
% ==============================================================================
function newstr = escapeCharacters( str )

  if ~ischar( str )
      error ( 'Argument  is not a string.' );
  end   

  newstr = str;
  newstr = strrep( newstr, '''', '\''''' );
  newstr = strrep( newstr, '%' , '%%'    );
  newstr = strrep( newstr, '\' , '\\'    );

end
% ==============================================================================
% *** END FUNCTION escapeCharacters
% ==============================================================================