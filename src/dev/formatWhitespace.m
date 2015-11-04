function formatWhitespace()
import matlab.desktop.editor.*
try
    d        = getActive();
    oldLines = textToLines(d.Text);
catch
    error('formatWhitespace:noEditorApi','Check that the Editor API is available.')
end

% Parse file into a tree
tree = mtree(d.Text);

% Check for mlint error
if ~isempty(tree.mtfind('Kind','ERR'))
    [~,name,ext] = fileparts(obj.Filename);
    error('formatWhitespace:mlintError','''%s'' contains syntax errors. Cannot proceed.',[name,ext])
end

% Smart indent except for crafted continuations of line
d.smartIndentContents()
lines      = textToLines(d.Text);
iDots      = ~cellfun('isempty',regexp(lines, '\.\.\.','once'));
iComment   = ~cellfun('isempty',regexp(lines, '^ *%([^%]|$)','once'));
pDotsAfter = find(iDots & ~iComment)+1;
for ii = 1:numel(pDotsAfter)
    p            = pDotsAfter(ii);
    nWhiteBefore = find(~isspace(oldLines{p-1}),1,'first');
    nWhiteAfter  = find(~isspace(lines{p-1}),1,'first');
    df           = nWhiteAfter - nWhiteBefore;
    if df > 0
        lines{p} = [blanks(df) oldLines{p}];
    elseif df < 0
        df       = min(abs(df)+1, find(~isspace(oldLines{p}),1,'first'));
        lines{p} = oldLines{p}(df:end);
    else
        lines{p} = oldLines{p};
    end
end

% Parse file into a tree
tree = mtree(d.Text);

% Check for mlint error
if ~isempty(tree.mtfind('Kind','ERR'))
    [~,name,ext] = fileparts(obj.Filename);
    error('justify:mlintError','''%s'' contains syntax errors. Cannot proceed.',[name,ext])
end

% Find position of function/end pairs
tmp   = tree.mtfind('Kind','FUNCTION');
stpos = tmp.lineno;
enpos = tmp.lastone;

% Pad content with 4 spaces
for f = 1:numel(stpos)
    pos        = stpos(f)+1:enpos(f)-1;
    lines(pos) = strcat({'    '}, lines(pos));
end

% Remove whitespace lines
idx        = cellfun('isempty',regexp(lines, '[^ \t\n]','once'));
lines(idx) = {''};

d.Text = linesToText(lines);
end
