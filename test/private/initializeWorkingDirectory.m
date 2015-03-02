function cwd = initializeWorkingDirectory()
% Initialize working directory. Change into 'test' folder of matlab2tikz.
% Return current working directory so that after tests it can be restored.
    fprintf('Initialize working directory...\n');
    cwd = pwd;
    m2t_path = which('matlab2tikz.m');
    bSuccess = 0;
    
    if ~isempty(m2t_path)
        test_path = fullfile(fileparts(m2t_path), '..', 'test');
        
        if isdir(test_path)
            cd(test_path);
            fprintf('Successfully changed into test folder...\n');
            bSuccess = 1;
        end
    end
    
    if ~bSuccess
        error('matlab2tikz:initializeWorkingDirectory', ...
            'Could not change into test folder.');
    end
end
