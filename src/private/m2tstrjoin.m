function newstr = m2tstrjoin(cellstr, delimiter, floatFormat)
% This function joins a cell of strings to a single string (with a
% given delimiter in between two strings, if desired).
    if ~exist('delimiter','var') || isempty(delimiter)
        delimiter = '';
    end
    if ~exist('floatFormat','var') || isempty(floatFormat)
        floatFormat = '%g';
    end
    if isempty(cellstr)
        newstr = '';
        return
    end

    % convert all values to strings first
    nElem = numel(cellstr);
    for k = 1:nElem
        if isnumeric(cellstr{k})
            cellstr{k} = sprintf(floatFormat, cellstr{k});
        elseif iscell(cellstr{k})
            cellstr{k} = m2tstrjoin(cellstr{k}, delimiter, floatFormat);
            % this will fail for heavily nested cells
        elseif ~ischar(cellstr{k})
            error('matlab2tikz:join:NotCellstrOrNumeric',...
                'Expected cellstr or numeric.');
        end
    end

    % inspired by strjoin of recent versions of MATLAB
    newstr = cell(2,nElem);
    newstr(1,:)         = reshape(cellstr, 1, nElem);
    newstr(2,1:nElem-1) = {delimiter}; % put delimiters in-between the elements
    newstr(2,end)       = {''}; % for Octave 4 compatibility
    newstr = [newstr{:}];
end
