function [reliableTests, unreliableTests] = splitUnreliableTests(status)
    % splits tests between reliable and unreliable tests
    knownToFail = cellfun(@(s)s.unreliable, status);

    unreliableTests = status( knownToFail);
    reliableTests = status(~knownToFail);
end
