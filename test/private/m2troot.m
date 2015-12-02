function rootpath = m2troot(varargin)
    % M2TROOT produces paths inside the matlab2tikz repository
    %
    % Usage:
    %   There are two ways to call this function, the base syntax is:
    %
    %       * rootpath = m2troot()
    %
    %   where |rootpath|  points towards the root of the repository.
    %   
    %   The other syntax:
    %
    %       * path = m2troot(...)
    %   
    %    is equivalent to |fullfile(m2troot, ...)| and as such allows to 
    %    easily produce a path to any file within the repository.
    
    m2t = which('matlab2tikz');
    if isempty(m2t)
        error('M2TRoot:NotFound', 'Matlab2tikz was not found on the PATH!')
    end
    
    [srcpath] = fileparts(m2t);  % this should be $(m2troot)/src
    [rootpath, srcdir] = fileparts(srcpath); % this should be $(m2troot)
    assert(strcmpi(srcdir,'src'));
    
    if nargin >= 1
        rootpath = fullfile(rootpath, varargin{:});
    end
end
