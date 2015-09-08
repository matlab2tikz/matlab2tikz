function isBelow = isVersionBelow(versionA, versionB)
% Checks if versionA is smaller than versionB
    vA         = versionArray(versionA);
    vB         = versionArray(versionB);
    n          = min(length(vA), length(vB));
    deltaAB    = vA(1:n) - vB(1:n);
    difference = find(deltaAB, 1, 'first');
    if isempty(difference)
        isBelow = false; % equal versions
    else
        isBelow = (deltaAB(difference) < 0);
    end
end
