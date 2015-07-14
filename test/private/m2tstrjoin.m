function [ newstr ] = m2tstrjoin( cellstr, delimiter )
%M2TSTRJOIN This function joins a cellstr with a separator
%
% This is an alternative implementation for MATLAB's `strjoin`, since that
% one is not available before R2013a.
%
% See also: strjoin
%
% TODO: Unify the inline `join` and pivate `m2tstrjoin` function!

    nElem = numel(cellstr);

    newstr = cell(2,nElem);
    newstr(1,:)         = reshape(cellstr, 1, nElem);
    newstr(2,1:nElem-1) = {delimiter}; % put delimiters in-between the elements
    newstr(2,nElem) = {''};             % put empty string in last cell
    newstr = [newstr{:}];

end
