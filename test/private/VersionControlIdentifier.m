function [formatted,treeish] = VersionControlIdentifier()
% This function gives the (git) commit ID of matlab2tikz
%
% This assumes the standard directory structure as used by Nico's master branch:
%     SOMEPATH/src/matlab2tikz.m with a .git directory in SOMEPATH.
%
% The HEAD of that repository is determined from file system information only
% by following dynamic references (e.g. ref:refs/heds/master) in branch files
% until an absolute commit hash (e.g. 1a3c9d1...) is found.
% NOTE: Packed branch references are NOT supported by this approach
    MAXITER     = 10; % stop following dynamic references after a while
    formatted   = '';
    REFPREFIX   = 'ref:';
    isReference = @(treeish)(any(strfind(treeish, REFPREFIX)));
    treeish     = [REFPREFIX 'HEAD'];
    try
        % get the matlab2tikz directory
        privateDir = fileparts(mfilename('fullpath'));
        gitDir = fullfile(privateDir,'..','..','.git');

        nIter = 1;
        while isReference(treeish)
            refName    = treeish(numel(REFPREFIX)+1:end);
            branchFile = fullfile(gitDir, refName);

            if exist(branchFile, 'file') && nIter < MAXITER
                % The FID is reused in every iteration, so `onCleanup` cannot
                % be used to `fclose(fid)`. But since there is very little that
                % can go wrong in a single `fscanf`, it's probably best to leave
                % this part as it is for the time being.
                fid     = fopen(branchFile,'r');
                treeish = fscanf(fid,'%s');
                fclose(fid);
                nIter   = nIter + 1;
            else % no branch file or iteration limit reached
                treeish = '';
                return;
            end
        end
    catch %#ok
        treeish = '';
    end
    if ~isempty(treeish)
        formatted = ['  Commit & ' treeish ' \\\\ \n'];
    end
    %TODO: do the formatting somewhere else!
end
