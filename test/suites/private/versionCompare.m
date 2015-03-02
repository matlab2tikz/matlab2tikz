function bool = versionCompare( vA, operator, vB )
%VERSIONCOMPARE Performs a version comparison operation
    ENV = getEnvironment();
    switch operator
        case '<'
            bool = isVersionBelow(ENV, vA, vB);
        case '>'
            bool = isVersionBelow(ENV, vB, vA);
        case {'<=', '=<'}
            bool = ~isVersionBelow(ENV, vB, vA);
        case {'>=', '=>'}
            bool = ~isVersionBelow(ENV, vA, vB);
        case {'=', '=='}
            bool = ~isVersionBelow(ENV, vA, vB) && ~isVersionBelow(ENV, vB, vA);
        case {'~=', '!='}
            bool = isVersionBelow(ENV, vA, vB) || isVersionBelow(ENV, vB, vA);
        otherwise
            error('versionCompare:UnknownOperator',...
                  '"%s" is not a known comparison operator', operator);
    end
end
