function regressionTest(commitBase, commitOther, testIndices)
    % Produce graphical output of the ACID for two commits

    % Work only with a clean working tree
    [status, cmdout] = system('git status --porcelain');
    if ~isempty(cmdout)
        error('regressionTest:treeNotClean','Working tree is not clean.')
    end

    % Save current state
    branchName    = getBranchName();
    state         = initializeGlobalState();
    restore_state = onCleanup(@() restoreStateAndGit(state, branchName));

    % Toggle-off paging in Octave
    if strcmpi(getEnvironment(), 'Octave')
        more off
    end

    % Set path
    addpath(fullfile(pwd,'..','src'));
    addpath(fullfile(pwd,'suites'));

    suite = @ACID;
    if nargin < 3
        testIndices = 1:numel(suite(0));
    end

    currentDir    = m2troot('test','output','current');
    currentStatus = makeGraphical(commitBase , suite, testIndices, currentDir);
    otherDir      = m2troot('test','output','other');
    otherStatus   = makeGraphical(commitOther, suite, testIndices, otherDir);

    delete(restore_state)

    makeLatexReportRegression(currentStatus, currentDir, otherStatus);
end

function status = makeGraphical(commit, suite, testIndices, outdir)
    system(['git checkout ', commit]);

    status = testGraphical('testFunctionIndices', testIndices, 'testsuite', suite,...
        'output', outdir);

    makeLatexReport(status, outdir);

    % Make pdfs
    fprintf(['Making the .pdf for commit ', commit, '.\n'])
    if ispc
        [systatus,cmdout] = system(['mingw32-make -j -C' outdir]);
    else
        [systatus,cmdout] = system(['make -j -C' outdir]);
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
