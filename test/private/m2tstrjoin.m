function [ newstr ] = m2tstrjoin( cellstr, delimiter )
%M2TSTRJOIN This function joins a cellstr with a separator
%
% This is an alternative implementation for MATLAB's `strjoin`, since that
% one is not available before R2013a.
%
% See also: strjoin

    %TODO: Unify the private `m2tstrjoin` functions
    %FIXME: differs from src/private/m2tstrjoin in functionality !!!

    nElem = numel(cellstr);
    if nElem == 0
        newstr = '';
        return % m2tstrjoin({}, ...) -> ''
    end

    newstr = cell(2,nElem);
    newstr(1,:)         = reshape(cellstr, 1, nElem);
    newstr(2,1:nElem-1) = {delimiter}; % put delimiters in-between the elements
    newstr(2, end)      = {''}; % for Octave 4 compatibility
    newstr = [newstr{:}];

end
