function regressionTest(commitBase,commitOther)
    % Produce graphical output for two commits

    % Work only with a clean working tree
    [status, cmdout] = system('git status --porcelain');
    if ~isempty(cmdout)
        error('regressionTest:treeNotClean','Working tree is not clean.')
    end

    branchName = getBranchName();

    system(['git checkout ', commitBase]);
    statusBase = runMatlab2TikzTests();

    % Initialize state and prepare cleanup
    [state,cwd] = initializeGlobalState();

    finally_restore_state = onCleanup(@() restoreStateAndGit(state,cwd, branchName));

    % Toggle-off paging in Octave
    if strcmpi(getEnvironment(), 'Octave')
        more off
    end

    suite       = @ACID;
    testIndices = 1:numel(suite(0));

    makeGraphical(commitBase , suite, testIndices);
    makeGraphical(commitOther, suite, testIndices);
end

function makeGraphical(commit, suite, testIndices)
    system(['git checkout ', commit]);

    testGraphical('testFunctionIndices', testIndices,...
        'testsuite',           suite);

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
