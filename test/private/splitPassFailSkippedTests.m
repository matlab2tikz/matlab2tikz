function [passedTests, failedTests, skippedTests] = splitPassFailSkippedTests(status)
    % splits tests between passed, failed and skippedtests    
    skipped = cellfun(@(s) s.skip, status);
    status_notSkipped = status(~skipped);
    failed = hasTestFailed(status_notSkipped);
    
    passedTests  = status_notSkipped(~failed);
    failedTests  = status_notSkipped(failed);
    skippedTests = status(skipped);
end
