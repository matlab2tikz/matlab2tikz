function cwd = initializeWorkingDirectory()
% Initialize working directory. Change into 'test' folder of matlab2tikz.
% Return current working directory so that after tests it can be restored.
    fprintf('Initialize working directory...\n');
    cwd = pwd;
    test_path = m2troot('test');
    cdSucceeded = false;
        
    if isdir(test_path)
        cd(test_path);
        fprintf('Successfully changed into test folder...\n');
        cdSucceeded = true;
    end
    
    if ~cdSucceeded
        error('matlab2tikz:initializeWorkingDirectory', ...
            'Could not change into test folder.');
    end
end
