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
