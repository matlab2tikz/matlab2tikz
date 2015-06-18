classdef SemVer < Version
	properties
		buildSpecs = {};
		prereleaseSpecs = {};
	end
    properties(Dependent)
        major
        minor
        patch
    end
	methods
        function obj = SemVer(def)
            %TODO: document
            if isnumeric(def) && numel(def) == 3
                obj.number = def;
            elseif ischar(def)
                %TODO parse string
            elseif isa(def,'Version')
                obj.number = def.number;
                if isa(def,'SemVer')
                    obj.buildSpecs      = def.buildSpecs;
                    obj.prereleaseSpecs = def.prereleaseSpecs;
                end
            else
                error(); %TODO: specify
            end
        end
		function str = char(obj)
            prerelease = SemVer.specsToChar('-', obj.prereleaseSpecs);
            build      = SemVer.specsToChar('+', obj.buildSpecs);
            str = sprintf('%d.%d.%d%s%s', ...
                          obj.major, obj.minor, obj.patch, ...
                          prerelease, build);
		end
        %TODO: implement comparison
	end
    methods
        function val = get.major(obj)
            val = obj.number(1);
        end
        function val = get.minor(obj)
            val = obj.number(2);
        end
        function val = get.patch(obj)
            val = obj.number(3);
        end
    end

    methods(Static,Hidden)
        function str = specsToChar(prefix, specs)
            if isempty(specs)
                str = '';
            else
                specs = cellfun(@toChar, specs, 'UniformOutput', false);
                str = [prefix strjoin(specs,'.')];
            end
            function str = toChar(str)
                if isnumeric(str)
                    str = sprintf('%d',str);
                end
                str = char(str);
            end
        end
    end
end
