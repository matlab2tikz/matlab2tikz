function formatWhitespace(filename)
    % FORMATWHITESPACE Formats whitespace in the active document
    %
    %   Rules:
    %       - Smart-indent with all function indent option
    %       - Indentation is 4 spaces
    %       - Remove whitespace in empty lines
    %       - Preserve indentantion after line continuations, i.e. ...
    if nargin < 1, filename = ''; end

    import matlab.desktop.editor.*

    d        = getDoc(filename);
    oldLines = textToLines(d.Text);

    % Smart indent as AllFunctionIndent
    % Using undocumented feature from http://undocumentedmatlab.com/blog/changing-system-preferences-programmatically
    editorProp      = 'EditorMFunctionIndentType';
    oldVal          = com.mathworks.services.Prefs.getStringPref(editorProp);
    com.mathworks.services.Prefs.setStringPref(editorProp, 'AllFunctionIndent');
    restoreSettings = onCleanup(@() com.mathworks.services.Prefs.setStringPref(editorProp, oldVal));
    d.smartIndentContents()

    % Preserve crafted continuations of line
    lines         = textToLines(d.Text);
    iContinuation = ~cellfun('isempty',strfind(lines, '...'));
    iComment      = ~cellfun('isempty',regexp(lines, '^ *%([^%]|$)','once'));
    pAfterDots    = find(iContinuation & ~iComment)+1;
    for ii = 1:numel(pAfterDots)
        % Carry over the change in space due to smart-indenting from the
        % first continuation line to the last
        p            = pAfterDots(ii);
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

    % Remove whitespace lines
    idx        = cellfun('isempty',regexp(lines, '[^ \t\n]','once'));
    lines(idx) = {''};

    d.Text = linesToText(lines);
end

function d = getDoc(filename)

    try
        d = matlab.desktop.editor.getActive();
    catch
        error('formatWhitespace:noEditorApi','Check that the Editor API is available.')
    end

    % Get specific document if filename is specified
    if ~isempty(filename)
        allDocs    = matlab.desktop.editor.getAll();
        [~,fnames] = cellfun(@fileparts, {allDocs.Filename},'un',0);
        [tf, pos]  = ismember(filename,fnames);
        if ~tf
            error('formatWhitespace:filenameNotFound','Filename "%s" not found.', filename)
        end
        d = allDocs(pos);
    end
end