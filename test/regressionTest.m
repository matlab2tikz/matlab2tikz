function regressionTest(commitBase, commitOther)
    % Produce graphical output for two commits

    % Work only with a clean working tree
    [status, cmdout] = system('git status --porcelain');
    if ~isempty(cmdout)
        error('regressionTest:treeNotClean','Working tree is not clean.')
    end
    
    % Save current state
    branchName = getBranchName();
    [state,cwd] = initializeGlobalState();
    finally_restore_state = onCleanup(@() restoreStateAndGit(state,cwd, branchName));
    
    % Toggle-off paging in Octave
    if strcmpi(getEnvironment(), 'Octave')
        more off
    end

    suite       = @ACID;
    testIndices = 1:numel(suite(0));

    makeGraphical(commitBase , suite, testIndices, m2troot('test','output','current'));
    makeGraphical(commitOther, suite, testIndices, m2troot('test','output','other'));
end

function makeGraphical(commit, suite, testIndices, outdir)
    system(['git checkout ', commit]);

    testGraphical('testFunctionIndices', testIndices, 'testsuite', suite,...
        'output', outdir);

    % Make pdf
    fprintf(['Making the .pdf for commit ', commit, '.\n'])
    [status,cmdout] = system('make -j -C tex');

    % Rename
    texPath = fullfile(fileparts(which('testGraphical.m')),'tex');
    oldName = fullfile(texPath,'acid.pdf');
    newName = fullfile(texPath,['acid_before_' commit '.pdf']);
    movefile(oldName, newName);
end

function branchName = getBranchName()
    % Get branch name
    [status,cmdout] = system('git branch');
    branchName      = regexp(cmdout, '(?<=^* )[^\n\r]+','match','once');
    % Deal with detached commit
    if strcmp(branchName(1),'(')
        branchName = regexp(branchName,'\w+(?=\))','match','once');
    end
end

function restoreStateAndGit(state,cwd, branchName)
    restoreGlobalState(state,cwd);
    system(['git checkout ', branchName]);
end
