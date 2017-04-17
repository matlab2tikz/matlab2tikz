classdef Version
% The `Version` class implements storage, comparison and conversion of version
% numbers of software.
    properties
        number; % numerical representation of the version
    end
	methods
        function obj = Version(def)
            if ~exist('def','var')
                def = [];
            end
            if isa(def, 'Version')
                def = def.number;
            elseif ischar(def)
                def = versionArray(def);
            elseif isnumeric(def)
            else
                error('Version:BadArgument');
            end
            obj.number = def(:).';
        end
        function str = char(obj)
            str = sprintf('%d.',obj.number);
        end
        function [str, status] = gencode_rvalue(obj)
            str = sprintf('%s(''%s'')', class(obj), char(obj));
            status = true;
        end
        function display(obj)
            disp(gencode_rvalue(obj));
        end
        %% Comparison operators
        function bool = lt(obj, other)
            bool = isVersionBelow(obj, other);
        end
        function bool = gt(obj, other)
            bool = isVersionBelow(other, obj);
        end
        function bool = eq(obj, other)
        end
        function bool = ne(obj, other)
        end
        function bool = le(obj, other)
        end
        function bool = ge(obj, other)
        end
	end

    methods(Hidden,Access=protected)
        function bool = isVersionBelow(vA,vB)
            %TODO
        end
    end

    methods(Static)
        function obj = fromChar(str)
            %TODO
        end

    end
end

function bool = versionCompare( vA, operator, vB )
%VERSIONCOMPARE Performs a version comparison operation
    switch operator
        case '<'
            bool = isVersionBelow(vA, vB);
        case '>'
            bool = isVersionBelow(vB, vA);
        case {'<=', '=<'}
            bool = ~isVersionBelow(vB, vA);
        case {'>=', '=>'}
            bool = ~isVersionBelow(vA, vB);
        case {'=', '=='}
            bool = ~isVersionBelow(vA, vB) && ~isVersionBelow(vB, vA);
        case {'~=', '!='}
            bool = isVersionBelow(vA, vB) || isVersionBelow(vB, vA);
        otherwise
            error('versionCompare:UnknownOperator',...
                  '"%s" is not a known comparison operator', operator);
    end
end
