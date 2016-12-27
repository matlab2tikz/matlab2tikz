function regressionTest(commitBase, commitOther)
    % Produce graphical output for two commits

    % Work only with a clean working tree
    [status, cmdout] = system('git status --porcelain');
    if ~isempty(cmdout)
        error('regressionTest:treeNotClean','Working tree is not clean.')
    end
    
    % Save current state
    branchName = getBranchName();
    state = initializeGlobalState();
    finally_restore_state = onCleanup(@() restoreStateAndGit(state, branchName));
    
    % Toggle-off paging in Octave
    if strcmpi(getEnvironment(), 'Octave')
        more off
    end
    
    % Set path
    addpath(fullfile(pwd,'..','src'));
    addpath(fullfile(pwd,'suites'));
    
    suite       = @ACID;
    testIndices = 1:10;
%     testIndices = 1:numel(suite(0));

    makeGraphical(commitBase , suite, testIndices, m2troot('test','output','current'));
    makeGraphical(commitOther, suite, testIndices, m2troot('test','output','other'));
end

function makeGraphical(commit, suite, testIndices, outdir)
    system(['git checkout ', commit]);

    testGraphical('testFunctionIndices', testIndices, 'testsuite', suite,...
        'output', outdir);

    % Make pdf
    fprintf(['Making the .pdf for commit ', commit, '.\n'])
    targetdir = ['"' fullfile(outdir,'converted') '"'];
    try
        [status,cmdout] = system(['make -j -C' targetdir]);
    catch
        [status,cmdout] = system(['mingw32-make -j -C' targetdir]);
    end
end

function branchName = getBranchName()
    % Get branch name
    [status,cmdout] = system('git branch');
    branchName      = regexp(cmdout, '(?<=* )[^\n\r]+','match','once');
    % Deal with detached commit
    if strcmp(branchName(1),'(')
        branchName = regexp(branchName,'\w+(?=\))','match','once');
    end
end

function restoreStateAndGit(state,branchName)
    restoreGlobalState(state);
    system(['git checkout ', branchName]);
end
