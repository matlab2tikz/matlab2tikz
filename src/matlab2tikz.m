function matlab2tikz(varargin)
%MATLAB2TIKZ    Save figure in native LaTeX (TikZ/Pgfplots).
%   MATLAB2TIKZ() saves the current figure as LaTeX file.
%   MATLAB2TIKZ comes with several options that can be combined at will.
%
%   MATLAB2TIKZ(FILENAME,...) or MATLAB2TIKZ('filename',FILENAME,...)
%   stores the LaTeX code in FILENAME.
%
%   MATLAB2TIKZ('filehandle',FILEHANDLE,...) stores the LaTeX code in the file
%   referenced by FILEHANDLE. (default: [])
%
%   MATLAB2TIKZ('figurehandle',FIGUREHANDLE,...) explicitly specifies the
%   handle of the figure that is to be stored. (default: gcf)
%
%   MATLAB2TIKZ('colormap',DOUBLE,...) explicitly specifies the colormap to be
%   used. (default: current color map)
%
%   MATLAB2TIKZ('strict',BOOL,...) tells MATLAB2TIKZ to adhere to MATLAB(R)
%   conventions wherever there is room for relaxation. (default: false)
%
%   MATLAB2TIKZ('strictFontSize',BOOL,...) retains the exact font sizes
%   specified in MATLAB for the TikZ code. This goes against normal LaTeX
%   practice. (default: false)
%
%   MATLAB2TIKZ('showInfo',BOOL,...) turns informational output on or off.
%   (default: true)
%
%   MATLAB2TIKZ('showWarnings',BOOL,...) turns warnings on or off.
%   (default: true)
%
%   MATLAB2TIKZ('imagesAsPng',BOOL,...) stores MATLAB(R) images as (lossless)
%   PNG files. This is more efficient than storing the image color data as TikZ
%   matrix. (default: true)
%
%   MATLAB2TIKZ('externalData',BOOL,...) stores all data points in external
%   files as tab separated values (TSV files). (default: false)
%
%   MATLAB2TIKZ('dataPath',CHAR, ...) defines where external data files
%   and/or PNG figures are saved. It can be either an absolute or a relative
%   path with respect to your MATLAB work directory. By default, data files are
%   placed in the same directory as the TikZ output file. To place data files
%   in your MATLAB work directory, you can use '.'. (default: [])
%
%   MATLAB2TIKZ('relativeDataPath',CHAR, ...) tells MATLAB2TIKZ to use the
%   given path to follow the external data files and PNG files. This is the
%   relative path from your main LaTeX file to the data file directory.
%   By default the same directory is used as the output (default: [])
%
%   MATLAB2TIKZ('height',CHAR,...) sets the height of the image. This can be
%   any LaTeX-compatible length, e.g., '3in' or '5cm' or '0.5\textwidth'.  If
%   unspecified, MATLAB2TIKZ tries to make a reasonable guess.
%
%   MATLAB2TIKZ('width',CHAR,...) sets the width of the image.
%   If unspecified, MATLAB2TIKZ tries to make a reasonable guess.
%
%   MATLAB2TIKZ('noSize',BOOL,...) determines whether 'width', 'height', and
%   'scale only axis' are specified in the generated TikZ output. For compatibility with the
%   tikzscale package set this to true. (default: false)
%
%   MATLAB2TIKZ('extraCode',CHAR or CELLCHAR,...) explicitly adds extra code
%   at the beginning of the output file. (default: [])
%
%   MATLAB2TIKZ('extraCodeAtEnd',CHAR or CELLCHAR,...) explicitly adds extra
%   code at the end of the output file. (default: [])
%
%   MATLAB2TIKZ('extraAxisOptions',CHAR or CELLCHAR,...) explicitly adds extra
%   options to the Pgfplots axis environment. (default: [])
%
%   MATLAB2TIKZ('extraColors', {{'name',[R G B]}, ...} , ...) adds
%   user-defined named RGB-color definitions to the TikZ output.
%   R, G and B are expected between 0 and 1. (default: {})
%
%   MATLAB2TIKZ('extraTikzpictureOptions',CHAR or CELLCHAR,...)
%   explicitly adds extra options to the tikzpicture environment. (default: [])
%
%   MATLAB2TIKZ('encoding',CHAR,...) sets the encoding of the output file.
%
%   MATLAB2TIKZ('floatFormat',CHAR,...) sets the format used for float values.
%   You can use this to decrease the file size. (default: '%.15g')
%
%   MATLAB2TIKZ('maxChunkLength',INT,...) sets maximum number of data points
%   per \addplot for line plots (default: 4000)
%
%   MATLAB2TIKZ('parseStrings',BOOL,...) determines whether title, axes labels
%   and the like are parsed into LaTeX by MATLAB2TIKZ's parser.
%   If you want greater flexibility, set this to false and use straight LaTeX
%   for your labels. (default: true)
%
%   MATLAB2TIKZ('parseStringsAsMath',BOOL,...) determines whether to use TeX's
%   math mode for more characters (e.g. operators and figures). (default: false)
%
%   MATLAB2TIKZ('showHiddenStrings',BOOL,...) determines whether to show
%   strings whose were deliberately hidden. This is usually unnecessary, but
%   can come in handy for unusual plot types (e.g., polar plots). (default:
%   false)
%
%   MATLAB2TIKZ('interpretTickLabelsAsTex',BOOL,...) determines whether to
%   interpret tick labels as TeX. MATLAB(R) doesn't do that by default.
%   (default: false)
%
%   MATLAB2TIKZ('tikzFileComment',CHAR,...) adds a custom comment to the header
%   of the output file. (default: '')
%
%   MATLAB2TIKZ('automaticLabels',BOOL,...) determines whether to automatically
%   add labels to plots (where applicable) which make it possible to refer
%   to them using \ref{...} (e.g., in the caption of a figure). (default: false)
%
%   MATLAB2TIKZ('standalone',BOOL,...) determines whether to produce
%   a standalone compilable LaTeX file. Setting this to true may be useful for
%   taking a peek at what the figure will look like. (default: false)
%
%   MATLAB2TIKZ('checkForUpdates',BOOL,...) determines whether to automatically
%   check for updates of matlab2tikz. (default: true)
%
%   Example
%      x = -pi:pi/10:pi;
%      y = tan(sin(x)) - sin(tan(x));
%      plot(x,y,'--rs');
%      matlab2tikz('myfile.tex');
%

%   Copyright (c) 2008--2015, Nico Schlömer <nico.schloemer@gmail.com>
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the distribution
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.

%   Note:
%   This program was based on Paul Wagenaars' Matfig2PGF that can be
%   found on http://www.mathworks.com/matlabcentral/fileexchange/12962 .

%% Check if we are in MATLAB or Octave.
minimalVersion = struct('MATLAB', struct('name','2014a', 'num',[8 3]), ...
                        'Octave', struct('name','3.8', 'num',[3 8]));
checkDeprecatedEnvironment(minimalVersion);

m2t.cmdOpts = [];
m2t.currentHandles = [];

m2t.transform = []; % For hgtransform groups
m2t.pgfplotsVersion = [1,3];
m2t.name = 'matlab2tikz';
m2t.version = '1.0.0';
m2t.author = 'Nico Schlömer';
m2t.authorEmail = 'nico.schloemer@gmail.com';
m2t.years = '2008--2015';
m2t.website = 'http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz-matlab2tikz';
VCID = VersionControlIdentifier();
m2t.versionFull = strtrim(sprintf('v%s %s', m2t.version, VCID));

m2t.tol = 1.0e-15; % numerical tolerance (e.g. used to test equality of doubles)
m2t.imageAsPngNo = 0;
m2t.dataFileNo   = 0;
m2t.quiverId     = 0; % identification flag for quiver plot styles
m2t.automaticLabelIndex = 0;

% definition of color depth
m2t.colorDepth     = 48; %[bit] RGB color depth (typical values: 24, 30, 48)
m2t.colorPrecision = 2^(-m2t.colorDepth/3);
m2t.colorFormat    = sprintf('%%0.%df',ceil(-log10(m2t.colorPrecision)));

% the actual contents of the TikZ file go here
m2t.content = struct('name',     '', ...
                     'comment',  [], ...
                     'options',  {opts_new()}, ...
                     'content',  {cell(0)}, ...
                     'children', {cell(0)});
m2t.preamble = sprintf(['\\usepackage[T1]{fontenc}\n', ...
                        '\\usepackage[utf8]{inputenc}\n', ...
                        '\\usepackage{pgfplots}\n', ...
                        '\\usepackage{grffile}\n', ...
                        '\\pgfplotsset{compat=newest}\n', ...
                        '\\usetikzlibrary{plotmarks}\n', ...
                        '\\usepgfplotslibrary{patchplots}\n', ...
                        '\\usepackage{amsmath}\n']);

%% scan the options
ipp = m2tInputParser;

ipp = ipp.addOptional(ipp, 'filename',   '', @(x) filenameValidation(x,ipp));
ipp = ipp.addOptional(ipp, 'filehandle', [], @filehandleValidation);

ipp = ipp.addParamValue(ipp, 'figurehandle', get(0,'CurrentFigure'), @ishandle);
ipp = ipp.addParamValue(ipp, 'colormap', [], @isnumeric);
ipp = ipp.addParamValue(ipp, 'strict', false, @islogical);
ipp = ipp.addParamValue(ipp, 'strictFontSize', false, @islogical);
ipp = ipp.addParamValue(ipp, 'showInfo', true, @islogical);
ipp = ipp.addParamValue(ipp, 'showWarnings', true, @islogical);
ipp = ipp.addParamValue(ipp, 'checkForUpdates', true, @islogical);

ipp = ipp.addParamValue(ipp, 'encoding' , '', @ischar);
ipp = ipp.addParamValue(ipp, 'standalone', false, @islogical);
ipp = ipp.addParamValue(ipp, 'tikzFileComment', '', @ischar);
ipp = ipp.addParamValue(ipp, 'extraColors', {}, @isColorDefinitions);
ipp = ipp.addParamValue(ipp, 'extraCode', {}, @isCellOrChar);
ipp = ipp.addParamValue(ipp, 'extraCodeAtEnd', {}, @isCellOrChar);
ipp = ipp.addParamValue(ipp, 'extraAxisOptions', {}, @isCellOrChar);
ipp = ipp.addParamValue(ipp, 'extraTikzpictureOptions', {}, @isCellOrChar);
ipp = ipp.addParamValue(ipp, 'floatFormat', '%.15g', @ischar);
ipp = ipp.addParamValue(ipp, 'automaticLabels', false, @islogical);
ipp = ipp.addParamValue(ipp, 'showHiddenStrings', false, @islogical);
ipp = ipp.addParamValue(ipp, 'height', '', @ischar);
ipp = ipp.addParamValue(ipp, 'width' , '', @ischar);
ipp = ipp.addParamValue(ipp, 'imagesAsPng', true, @islogical);
ipp = ipp.addParamValue(ipp, 'externalData', false, @islogical);
ipp = ipp.addParamValue(ipp, 'dataPath', '', @ischar);
ipp = ipp.addParamValue(ipp, 'relativeDataPath', '', @ischar);
ipp = ipp.addParamValue(ipp, 'noSize', false, @islogical);

% Maximum chunk length.
% TeX parses files line by line with a buffer of size buf_size. If the
% plot has too many data points, pdfTeX's buffer size may be exceeded.
% As a work-around, the plot is split into several smaller chunks.
%
% What is a "large" array?
% TeX parser buffer is buf_size=200 000 char on Mac TeXLive, let's say
% 100 000 to be on the safe side.
% 1 point is represented by 25 characters (estimation): 2 coordinates (10
% char), 2 brackets, comma and white space, + 1 extra char.
% That gives a magic arbitrary number of 4000 data points per array.
ipp = ipp.addParamValue(ipp, 'maxChunkLength', 4000, @isnumeric);

% By default strings like axis labels are parsed to match the appearance of
% strings as closely as possible to that generated by MATLAB.
% If the user wants to have particular strings in the matlab2tikz output that
% can't be generated in MATLAB, they can disable string parsing. In that case
% all strings are piped literally to the LaTeX output.
ipp = ipp.addParamValue(ipp, 'parseStrings', true, @islogical);

% In addition to regular string parsing, an additional stage can be enabled
% which uses TeX's math mode for more characters like figures and operators.
ipp = ipp.addParamValue(ipp, 'parseStringsAsMath', false, @islogical);

% As opposed to titles, axis labels and such, MATLAB(R) does not interpret tick
% labels as TeX. matlab2tikz retains this behavior, but if it is desired to
% interpret the tick labels as TeX, set this option to true.
ipp = ipp.addParamValue(ipp, 'interpretTickLabelsAsTex', false, @islogical);

%% deprecated parameters (will auto-generate warnings upon parse)
ipp = ipp.addParamValue(ipp, 'relativePngPath', '', @ischar);
ipp = ipp.deprecateParam(ipp, 'relativePngPath', 'relativeDataPath');

%% Finally parse all the arguments
ipp = ipp.parse(ipp, varargin{:});
m2t.cmdOpts = ipp; % store the input parser back into the m2t data struct

%% inform users of potentially dangerous options
warnAboutParameter(m2t, 'parseStringsAsMath', @(opt)(opt==true), ...
    ['This may produce undesirable string output. For full control over output\n', ...
     'strings please set the parameter "parseStrings" to false.']);
warnAboutParameter(m2t, 'noSize', @(opt)(opt==true), ...
     'This may impede both axes sizing and placement!');
warnAboutParameter(m2t, 'imagesAsPng', @(opt)(opt==false), ...
     ['It is highly recommended to use PNG data to store images.\n', ...
      'Make sure to set "imagesAsPng" to true.']);

% The following color RGB-values which will need to be defined.
% 'extraRgbColorNames' contains their designated names, 'extraRgbColorSpecs'
% their specifications.
[m2t.extraRgbColorNames, m2t.extraRgbColorSpecs] = ...
    dealColorDefinitions(m2t.cmdOpts.Results.extraColors);

%% shortcut
m2t.ff = m2t.cmdOpts.Results.floatFormat;

%% add global elements
if isempty(m2t.cmdOpts.Results.figurehandle)
    error('matlab2tikz:figureNotFound','MATLAB figure not found.');
end
m2t.currentHandles.gcf = m2t.cmdOpts.Results.figurehandle;
if m2t.cmdOpts.Results.colormap
    m2t.currentHandles.colormap = m2t.cmdOpts.Results.colormap;
else
    m2t.currentHandles.colormap = get(m2t.currentHandles.gcf, 'colormap');
end

%% handle output file handle/file name
[m2t, fid, fileWasOpen] = openFileForOutput(m2t);

% By default, reference the PNG (if required) from the TikZ file
% as the file path of the TikZ file itself. This works if the MATLAB script
% is executed in the same folder where the TeX file sits.
if isempty(m2t.cmdOpts.Results.relativeDataPath)
    if ~isempty(m2t.cmdOpts.Results.relativePngPath)
        %NOTE: eventually break backwards compatibility of relative PNG path
        m2t.relativeDataPath = m2t.cmdOpts.Results.relativePngPath;
        userWarning(m2t, ['Using "relativePngPath" for "relativeDataPath".', ...
            ' This will stop working in a future release.']);
    else
        m2t.relativeDataPath = m2t.cmdOpts.Results.relativeDataPath;
    end
else
    m2t.relativeDataPath = m2t.cmdOpts.Results.relativeDataPath;
end
if isempty(m2t.cmdOpts.Results.dataPath)
    m2t.dataPath = fileparts(m2t.tikzFileName);
else
    m2t.dataPath = m2t.cmdOpts.Results.dataPath;
end


userInfo(m2t, ['(To disable info messages, pass [''showInfo'', false] to matlab2tikz.)\n', ...
    '(For all other options, type ''help matlab2tikz''.)\n']);

userInfo(m2t, '\nThis is %s %s.\n', m2t.name, m2t.versionFull)

%% Check for a new matlab2tikz version outside version control
if m2t.cmdOpts.Results.checkForUpdates && isempty(VCID)
  isUpdateInstalled = m2tUpdater(...
    m2t.name, ...
    m2t.website, ...
    m2t.version, ...
    m2t.cmdOpts.Results.showInfo, ...
    getEnvironment...
    );
    % Terminate conversion if update was successful (the user is notified
    % by the updater)
    if isUpdateInstalled, return, end
end

%% print some version info to the screen
versionInfo = ['The latest updates can be retrieved from\n' ,...
               ' %s\n' ,...
               'where you can also make suggestions and rate %s.\n' ,...
               'For usage instructions, bug reports, the latest '   ,...
               'development versions and more, see\n'               ,...
               '   https://github.com/matlab2tikz/matlab2tikz,\n'       ,...
               '   https://github.com/matlab2tikz/matlab2tikz/wiki,\n'  ,...
               '   https://github.com/matlab2tikz/matlab2tikz/issues.\n'];
userInfo(m2t, versionInfo, m2t.website, m2t.name);

%% Save the figure as TikZ to file
saveToFile(m2t, fid, fileWasOpen);
end
% ==============================================================================
function [m2t, fid, fileWasOpen] = openFileForOutput(m2t)
% opens the output file and/or show a dialog to select one
if ~isempty(m2t.cmdOpts.Results.filehandle)
    fid         = m2t.cmdOpts.Results.filehandle;
    fileWasOpen = true;
    if ~isempty(m2t.cmdOpts.Results.filename)
        userWarning(m2t, ...
            'File handle AND file name for output given. File handle used, file name discarded.')
    end
    m2t.tikzFileName = fopen(fid);
else
    fid         = [];
    fileWasOpen = false;
    % set filename
    if ~isempty(m2t.cmdOpts.Results.filename)
        filename = m2t.cmdOpts.Results.filename;
    else
        [filename, pathname] = uiputfile({'*.tex;*.tikz'; '*.*'}, 'Save File');
        filename = fullfile(pathname, filename);
    end
    m2t.tikzFileName = filename;
end

end
% ==============================================================================
function l = filenameValidation(x, p)
% is the filename argument NOT another keyword?
    l = ischar(x) && ~any(strcmp(x,p.Parameters)); %FIXME: See #471
end
% ==============================================================================
function l = filehandleValidation(x)
% is the filehandle the handle to an opened file?
    l = isnumeric(x) && any(x==fopen('all'));
end
% ==============================================================================
function bool = isCellOrChar(x)
    bool = iscell(x) || ischar(x);
end
% ==============================================================================
function bool = isRGBTuple(color)
% Returns true when the color is a valid RGB tuple
    bool = numel(color) == 3 && ...
           all(isreal(color)) && ...
           all( 0<=color & color<=1 ); % this also disallows NaN entries
end
% ==============================================================================
function bool = isColorDefinitions(colors)
% Returns true when the input is a cell array of color definitions, i.e.
%  a cell array with in each cell a cell of the form {'name', [R G B]}
    isValidEntry = @(e)( iscell(e) && ischar(e{1}) && isRGBTuple(e{2}) );

    bool = iscell(colors) && all(cellfun(isValidEntry, colors));
end
% ==============================================================================
function fid = fileOpenForWrite(m2t, filename)
    encoding = switchMatOct({'native', m2t.cmdOpts.Results.encoding}, {});

    fid      = fopen(filename, 'w', encoding{:});
    if fid == -1
        error('matlab2tikz:fileOpenError', ...
            'Unable to open file ''%s'' for writing.', filename);
    end
end
% ==============================================================================
function path = TeXpath(path)
    path = strrep(path, filesep, '/');
% TeX uses '/' as a file separator (as UNIX). Windows, however, uses
% '\' which is not supported by TeX as a file separator
end
% ==============================================================================
function m2t = saveToFile(m2t, fid, fileWasOpen)
% Save the figure as TikZ to a file. All other routines are called from here.

    % It is important to turn hidden handles on, as visible lines (such as the
    % axes in polar plots, for example), are otherwise hidden from their
    % parental handles (and can hence not be discovered by matlab2tikz).
    % With ShowHiddenHandles 'on', there is no escape. :)
    set(0, 'ShowHiddenHandles', 'on');

    % get all axes handles
    [m2t, axesHandles] = findPlotAxes(m2t, m2t.currentHandles.gcf);

    % Turn around the handles vector to make sure that plots that appeared
    % first also appear first in the vector. This has effects on the alignment
    % and the order in which the plots appear in the final TikZ file.
    % In fact, this is not really important but makes things more 'natural'.
    axesHandles = axesHandles(end:-1:1);

    % Alternative Positioning of axes.
    % Select relevant Axes and draw them.
    [m2t, axesBoundingBox] = getRelevantAxes(m2t, axesHandles);

    m2t.axesBoundingBox = axesBoundingBox;
    m2t.axesContainers = {};
    for relevantAxesHandle = m2t.relevantAxesHandles(:)'
        m2t = drawAxes(m2t, relevantAxesHandle);
    end

    % Handle color bars.
    for cbar = m2t.cbarHandles(:)'
        m2t = handleColorbar(m2t, cbar);
    end

    % Draw annotations
    m2t = drawAnnotations(m2t);

    % Add all axes containers to the file contents.
    for axesContainer = m2t.axesContainers
        m2t.content = addChildren(m2t.content, axesContainer);
    end

    set(0, 'ShowHiddenHandles', 'off');
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % actually print the stuff
    minimalPgfplotsVersion = formatPgfplotsVersion(m2t.pgfplotsVersion);

    m2t.content.comment = sprintf('This file was created by %s.\n', m2t.name);

    if m2t.cmdOpts.Results.showInfo
        % disable this info if showInfo=false
        m2t.content.comment = [m2t.content.comment, ...
            sprintf(['\n',...
            'The latest updates can be retrieved from\n', ...
            '  %s\n', ...
            'where you can also make suggestions and rate %s.\n'], ...
            m2t.website, m2t.name ) ...
            ];
    end

    userInfo(m2t, 'You will need pgfplots version %s or newer to compile the TikZ output.',...
        minimalPgfplotsVersion);

    % Add custom comment.
    if ~isempty(m2t.cmdOpts.Results.tikzFileComment)
        m2t.content.comment = [m2t.content.comment, ...
            sprintf('\n%s\n', m2t.cmdOpts.Results.tikzFileComment)
            ];
    end

    m2t.content.name = 'tikzpicture';

    % Add custom TikZ options if any given.
    m2t.content.options = opts_append_userdefined(m2t.content.options, ...
                                   m2t.cmdOpts.Results.extraTikzpictureOptions);

    m2t.content.colors = generateColorDefinitions(m2t.extraRgbColorNames, ...
                            m2t.extraRgbColorSpecs, m2t.colorFormat);

    % Open file if was not open
    if ~fileWasOpen
        fid = fileOpenForWrite(m2t, m2t.tikzFileName);
        finally_fclose_fid = onCleanup(@() fclose(fid));
    end

    % Finally print it to the file
    addComments(fid, m2t.content.comment);
    addStandalone(m2t, fid, 'preamble');
    addCustomCode(fid, '', m2t.cmdOpts.Results.extraCode, '');
    addStandalone(m2t, fid, 'begin');

    printAll(m2t, m2t.content, fid); % actual plotting happens here

    addCustomCode(fid, '\n', m2t.cmdOpts.Results.extraCodeAtEnd, '');

    addStandalone(m2t, fid, 'end');
end
% ==============================================================================
function addStandalone(m2t, fid, part)
% writes a part of a standalone LaTeX file definition
if m2t.cmdOpts.Results.standalone
    switch part
        case 'preamble'
            fprintf(fid, '\\documentclass[tikz]{standalone}\n%s\n',  m2t.preamble);
        case 'begin'
            fprintf(fid, '\\begin{document}\n');
        case 'end'
            fprintf(fid, '\n\\end{document}');
        otherwise
            error('m2t:unknownStandalonePart', ...
                  'Unknown standalone part "%s"', part);
    end
end
end
% ==============================================================================
function str = generateColorDefinitions(names, specs, colorFormat)
% output the color definitions to LaTeX
    str = '';
    ff  = colorFormat;
    if ~isempty(names)
        m2t.content.colors = sprintf('%%\n%% defining custom colors\n');
        for k = 1:length(names)
            % make sure to append with '%' to avoid spacing woes
            str = [str, ...
                sprintf(['\\definecolor{%s}{rgb}{', ff, ',', ff, ',', ff,'}%%\n'], ...
                names{k}', specs{k})];
        end
        str = [str sprintf('%%\n')];
    end
end
% ==============================================================================
function [m2t, axesHandles] = findPlotAxes(m2t, fh)
% find axes handles that are not legends/colorbars
% store detected legends and colorbars in 'm2t'
% fh            figure handle
    axesHandles = findobj(fh, 'type', 'axes');

    % Remove all legend handles, as they are treated separately.
    if ~isempty(axesHandles)
        % TODO fix for octave
        tagKeyword = switchMatOct('Tag', 'tag');
        % Find all legend handles. This is MATLAB-only.
        m2t.legendHandles = findobj(fh, tagKeyword, 'legend');
        m2t.legendHandles = m2t.legendHandles(:)';
        idx               = ~ismember(axesHandles, m2t.legendHandles);
        axesHandles       = axesHandles(idx);
    end

    % Remove all colorbar handles, as they are treated separately.
    if ~isempty(axesHandles)
        colorbarKeyword = switchMatOct('Colorbar', 'colorbar');
        % Find all colorbar handles. This is MATLAB-only.
        cbarHandles = findobj(fh, tagKeyword, colorbarKeyword);
        % Octave also finds text handles here; no idea why. Filter.
        m2t.cbarHandles = [];
        for h = cbarHandles(:)'
          if any(strcmpi(get(h, 'Type'),{'axes','colorbar'}))
            m2t.cbarHandles = [m2t.cbarHandles, h];
          end
        end
        m2t.cbarHandles = m2t.cbarHandles(:)';
        idx             = ~ismember(axesHandles, m2t.cbarHandles);
        axesHandles     = axesHandles(idx);
    else
        m2t.cbarHandles = [];
    end

    % Remove scribe layer holding annotations (MATLAB < R2014b)
    m2t.scribeLayer = findobj(axesHandles, 'Tag','scribeOverlay');
    idx             = ~ismember(axesHandles, m2t.scribeLayer);
    axesHandles     = axesHandles(idx);
end
% ==============================================================================
function addComments(fid, comment)
% prints TeX comments to file stream |fid|
    if ~isempty(comment)
        newline = sprintf('\n');
        newlineTeX = sprintf('\n%%');
        fprintf(fid, '%% %s\n', strrep(comment, newline, newlineTeX));
    end
end
% ==============================================================================
function addCustomCode(fid, before, code, after)
    if ~isempty(code)
        fprintf(fid, before);
        if ischar(code)
            code = {code};
        end
        if iscellstr(code)
            for str = code(:)'
                fprintf(fid, '%s\n', str{1});
            end
        else
            error('matlab2tikz:saveToFile', 'Need str or cellstr.');
        end
        fprintf(fid,after);
    end
end
% ==============================================================================
function [m2t, pgfEnvironments] = handleAllChildren(m2t, h)
% Draw all children of a graphics object (if they need to be drawn).
% #COMPLEX: mainly a switch-case
    str = '';
    children = get(h, 'Children');

    % prepare cell array of pgfEnvironments
    pgfEnvironments = cell(0);

    % It's important that we go from back to front here, as this is
    % how MATLAB does it, too. Significant for patch (contour) plots,
    % and the order of plotting the colored patches.
    for child = children(end:-1:1)'
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        [m2t, legendString, interpreter] = findLegendInformation(m2t, child);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        switch char(get(child, 'Type'))
            % 'axes' environments are treated separately.

            case 'line'
                [m2t, str] = drawLine(m2t, child);

            case 'patch'
                [m2t, str] = drawPatch(m2t, child);

            case 'image'
                [m2t, str] = drawImage(m2t, child);
            
            case {'hggroup', 'matlab.graphics.primitive.Group', ...
                  'scatter', 'bar', 'stair', 'stem' ,'errorbar', 'area', ...
                  'quiver','contour'}
                [m2t, str] = drawHggroup(m2t, child);

            case 'hgtransform'
                % From http://www.mathworks.de/de/help/matlab/ref/hgtransformproperties.html:
                % Matrix: 4-by-4 matrix
                %   Transformation matrix applied to hgtransform object and its
                %   children. The hgtransform object applies the transformation
                %   matrix to all its children.
                % More information at http://www.mathworks.de/de/help/matlab/creating_plots/group-objects.html.
                m2t.transform = get(child, 'Matrix');
                [m2t, str] = handleAllChildren(m2t, child);
                m2t.transform = [];

            case 'surface'
                [m2t, str] = drawSurface(m2t, child);

            case 'text'
                [m2t, str] = drawVisibleText(m2t, child);

            case 'rectangle'
                [m2t, str] = drawRectangle(m2t, child);

            case 'histogram'
                [m2t, str] = drawHistogram(m2t, child);

            case {'uitoolbar', 'uimenu', 'uicontextmenu', 'uitoggletool',...
                    'uitogglesplittool', 'uipushtool', 'hgjavacomponent'}
                % don't to anything for these handles and its children
                str = '';

            case ''
                warning('matlab2tikz:NoChildren',...
                        ['No children found for handle %d. ',...
                         'Carrying on as if nothing happened'], double(h));

            otherwise
                error('matlab2tikz:handleAllChildren',                 ...
                    'I don''t know how to handle this object: %s\n', ...
                    get(child, 'Type'));

        end

        str = addLegendInformation(m2t, str, legendString, interpreter);

        % append the environment
        pgfEnvironments{end+1} = str;
    end
end
% ==============================================================================
function [m2t, legendString, interpreter] = findLegendInformation(m2t, child)
% Check if 'child' is referenced in a legend.
% If yes, some plot types may want to add stuff (e.g. 'forget plot').
% Add '\addlegendentry{...}' then after the plot.
legendString = '';
interpreter  = '';
hasLegend = false;

if isempty(child)
    return; % an empty (i.e. non-existent) child cannot have a legend entry
end

% Check if current handle is referenced in a legend.
switch getEnvironment
    case 'MATLAB'
        [legendString, interpreter, hasLegend] = findLegendInfoMATLAB(m2t, child);

    case 'Octave'
        % Octave does not store a reference to the legend entry in the
        % plotted objects. It references the plotted objects in reverse,
        % in the legend's 'deletefcn' property.
        % The variable m2t.gcaAssociatedLegend is set in drawAxes().
        if ~isempty(m2t.gcaAssociatedLegend)
            delfun           = get(m2t.gcaAssociatedLegend,'deletefcn');
            legendEntryPeers = delfun{6}; % See set(hlegend, "deletefcn", {@deletelegend2, ca, [], [], t1, hplots}); in legend.m  
            hasLegend        = ismember(child, legendEntryPeers);
            interpreter      = get(m2t.gcaAssociatedLegend, 'interpreter');
            legendString     = getOrDefault(child,'displayname','');
        end

    otherwise
        errorUnknownEnvironment();
end

% split string to cell, if newline character '\n' (ASCII 10) is present
delimeter = sprintf('\n');
legendString = regexp(legendString,delimeter,'split');

m2t.currentHandleHasLegend = hasLegend && ~isempty(legendString);
end
% ==============================================================================
function [legendString, interpreter, hasLegend] = findLegendInfoMATLAB(m2t, child)
% finds the legend info in MATLAB (only!). Eventually this could be merged back
% into `findLegendInformation`
    legendString = '';
    interpreter  = '';
    hasLegend = false;
    %FIXME: this part (e.g. fall back objects) should be restructured.
    for legendHandle = m2t.legendHandles(:)'
        ud = get(legendHandle, 'UserData');
        if isfield(ud, 'handles')
            plotChildren = ud.handles;
        else
            plotChildren = getOrDefault(legendHandle, 'PlotChildren', []);
        end
        k = find(child == plotChildren);
        if isempty(k)
            % Lines of error bar plots are not referenced
            % directly in legends as an error bars plot contains
            % two "lines": the data and the deviations. Here, the
            % legends refer to the specgraph.errorbarseries
            % handle which is 'Parent' to the line handle.
            k = find(get(child,'Parent') == plotChildren);
        end
        if ~isempty(k)
            % Legend entry found. Add it to the plot.
            hasLegend = true;
            interpreter = get(legendHandle, 'Interpreter');
            if ~isempty(ud) && isfield(ud,'strings')
                legendString = ud.lstrings(k);
            else
                legendString = get(child, 'DisplayName');
            end
        end
    end
end
% ==============================================================================
function str = addLegendInformation(m2t, str, legendString, interpreter)
% Add legend after the plot data.
% The test for ischar(str) && ~isempty(str) is a workaround for hggroups;
% the output might not necessarily be a string, but a cellstr.
    if ischar(str) && ~isempty(str) && m2t.currentHandleHasLegend
        c = prettyPrint(m2t, legendString, interpreter);
        % We also need a legend alignment option to make multiline
        % legend entries work. This is added by default in getLegendOpts().
        str = [str, sprintf('\\addlegendentry{%s};\n\n', join(m2t, c, '\\'))];
    end
end
% ==============================================================================
function data = applyHgTransform(m2t, data)
    if ~isempty(m2t.transform)
        R = m2t.transform(1:3,1:3);
        t = m2t.transform(1:3,4);
        n = size(data, 1);
        data = data * R' + kron(ones(n,1), t');
    end
end
% ==============================================================================
function m2t = drawAxes(m2t, handle)
% Input arguments:
%    handle.................The axes environment handle.

    assertRegularAxes(handle);

    % Initialize empty environment.
    % Use a struct instead of a custom subclass of hgsetget (which would
    % facilitate writing clean code) as structs are more portable (old MATLAB(R)
    % versions, GNU Octave).
    m2t.axesContainers{end+1} = struct('handle', handle, ...
        'name', '', ...
        'comment', [], ...
        'options', {opts_new()}, ...
        'content', {cell(0)}, ...
        'children', {cell(0)});

    % update gca
    m2t.currentHandles.gca = handle;

    % Check if axis is 3d
    % In MATLAB, all plots are treated as 3D plots; it's just the view that
    % makes 2D plots appear like 2D.
    m2t.axesContainers{end}.is3D = isAxis3D(handle);

    % Flag if axis contains barplot
    m2t.axesContainers{end}.barAddedAxisOption = false;

    m2t.gcaAssociatedLegend = getAssociatedLegend(m2t, handle);

    m2t = retrievePositionOfAxes(m2t, handle);

    m2t = addAspectRatioOptionsOfAxes(m2t, handle);

    % Axis direction
    for axis = 'xyz'
        m2t.([axis 'AxisReversed']) = ...
            strcmpi(get(handle,[upper(axis),'Dir']), 'reverse');
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Add color scaling
    CLimMode = get(handle,'CLimMode');
    if strcmpi(CLimMode,'manual') || ~isempty(m2t.cbarHandles)
        clim = caxis(handle);
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'point meta min', sprintf(m2t.ff, clim(1)));
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'point meta max', sprintf(m2t.ff, clim(2)));
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Recurse into the children of this environment.
    [m2t, childrenEnvs] = handleAllChildren(m2t, handle);
    m2t.axesContainers{end} = addChildren(m2t.axesContainers{end}, childrenEnvs);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % The rest of this is handling axes options.
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Get other axis options (ticks, axis color, label,...).
    % This is set here such that the axis orientation indicator in m2t is set
    % before -- if ~isVisible(handle) -- the handle's children are called.
    [m2t, xopts] = getAxisOptions(m2t, handle, 'x');
    [m2t, yopts] = getAxisOptions(m2t, handle, 'y');

    m2t.axesContainers{end}.options = opts_merge(m2t.axesContainers{end}.options, ...
                                            xopts, yopts);

    m2t = add3DOptionsOfAxes(m2t, handle);

    if ~isVisible(handle)
        % Setting hide{x,y} axis also hides the axis labels in Pgfplots whereas
        % in MATLAB, they may still be visible. Well.
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'hide axis', []);
        %    % An invisible axes container *can* have visible children, so don't
        %    % immediately bail out here.
        %    children = get(handle, 'Children');
        %    for child = children(:)'
        %        if isVisible(child)
        %            % If the axes contain something that's visible, add an invisible
        %            % axes pair.
        %            m2t.axesContainers{end}.name = 'axis';
        %            m2t.axesContainers{end}.options = {m2t.axesContainers{end}.options{:}, ...
        %                                               'hide x axis', 'hide y axis'};
        %            m2t.axesContainers{end}.comment = getTag(handle);
        %            break;
        %        end
        %    end
        %    % recurse into the children of this environment
        %    [m2t, childrenEnvs] = handleAllChildren(m2t, handle);
        %    m2t.axesContainers{end} = addChildren(m2t.axesContainers{end}, childrenEnvs);
        %    return
    end
    m2t.axesContainers{end}.name = 'axis';

    m2t = drawBackgroundOfAxes(m2t, handle);
    m2t = drawTitleOfAxes(m2t, handle);
    m2t = drawBoxAndLineLocationsOfAxes(m2t, handle);
    m2t = drawGridOfAxes(m2t, handle);
    m2t = drawLegendOptionsOfAxes(m2t, handle);

    m2t.axesContainers{end}.options = opts_append_userdefined(...
        m2t.axesContainers{end}.options, m2t.cmdOpts.Results.extraAxisOptions);
end
% ==============================================================================
function m2t = drawGridOfAxes(m2t, handle)
% draws the grids of an axes
%TODO: has{XYZ}Grid is always false without a good reason
    hasXGrid = false;
    hasYGrid = false;
    hasZGrid = false;
    if hasXGrid || hasYGrid || hasZGrid
        matlabGridLineStyle = get(handle, 'GridLineStyle');
        % Take over the grid line style in any case when in strict mode.
        % If not, don't add anything in case of default line grid line style
        % and effectively take Pgfplots' default.
        defaultMatlabGridLineStyle = ':';
        if m2t.cmdOpts.Results.strict ...
                || ~strcmpi(matlabGridLineStyle,defaultMatlabGridLineStyle)
            gls = translateLineStyle(matlabGridLineStyle);
            axisGridOpts = {'grid style', sprintf('{%s}', gls)};
            m2t.axesContainers{end}.options = cat(1, ...
                m2t.axesContainers{end}.options,...
                axisGridOpts);
        end
    else
        % When specifying 'axis on top', the axes stay above all graphs (which is
        % default MATLAB behavior), but so do the grids (which is not default
        % behavior).
        %TODO: use proper grid ordering
        if m2t.cmdOpts.Results.strict
            m2t.axesContainers{end}.options = ...
                opts_add(m2t.axesContainers{end}.options, ...
                'axis on top', []);
        end
        % FIXME: axis background, axis grid, main, axis ticks, axis lines, axis tick labels, axis descriptions, axis foreground
    end
end
% ==============================================================================
function m2t = add3DOptionsOfAxes(m2t, handle)
% adds 3D specific options of an axes object
    if isAxis3D(handle)
        [m2t, zopts] = getAxisOptions(m2t, handle, 'z');
        m2t.axesContainers{end}.options = opts_merge(...
            m2t.axesContainers{end}.options, zopts);

         m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'view', sprintf(['{', m2t.ff, '}{', m2t.ff, '}'], get(handle, 'View')));
    end
end
% ==============================================================================
function legendhandle = getAssociatedLegend(m2t, handle)
% Check if the axis is referenced by a legend (only necessary for Octave)
    legendhandle = [];
    switch getEnvironment
        case 'Octave'
            % Make sure that m2t.legendHandles is a row vector.
            for lhandle = m2t.legendHandles(:)'
                ud = get(lhandle, 'UserData');
                if isVisibleContainer(lhandle) && any(handle == ud.handle)
                    legendhandle = lhandle;
                    break;
                end
            end
        case 'MATLAB'
            % no action needed
        otherwise
            errorUnknownEnvironment();
    end
end
% ==============================================================================
function m2t = retrievePositionOfAxes(m2t, handle)
% This retrieves the position of an axes and stores it into the m2t data
% structure

    pos = getAxesPosition(m2t, handle, m2t.cmdOpts.Results.width, ...
                          m2t.cmdOpts.Results.height, m2t.axesBoundingBox);
    % set the width
    if (~m2t.cmdOpts.Results.noSize)
        % optionally prevents setting the width and height of the axis
        m2t = setDimensionOfAxes(m2t, 'width',  pos.w);
        m2t = setDimensionOfAxes(m2t, 'height', pos.h);

        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'at', ...
                ['{(' formatDim(pos.x.value, pos.x.unit) ','...
                      formatDim(pos.y.value, pos.y.unit) ')}']);
        % the following is general MATLAB behavior:
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'scale only axis', []);
    end
end
% ==============================================================================
function m2t = setDimensionOfAxes(m2t, widthOrHeight, dimension)
% sets the dimension "name" of the current axes to the struct "dim"
    m2t.axesContainers{end}.options = opts_add(...
            m2t.axesContainers{end}.options, widthOrHeight, ...
            formatDim(dimension.value, dimension.unit));
end
% ==============================================================================
function m2t = addAspectRatioOptionsOfAxes(m2t, handle)
% Set manual aspect ratio for current axes
% TODO: deal with 'axis image', 'axis square', etc. (#540)
    if strcmpi(get(handle, 'DataAspectRatioMode'), 'manual') ||...
       strcmpi(get(handle, 'PlotBoxAspectRatioMode'), 'manual')
        % we need to set the plot box aspect ratio
        if m2t.axesContainers{end}.is3D
            % Note: set 'plot box ratio' for 3D axes to avoid bug with
            % 'scale mode = uniformly' (see #560)
            aspectRatio = getPlotBoxAspectRatio(handle);
            m2t.axesContainers{end}.options = opts_add(...
            m2t.axesContainers{end}.options, 'plot box ratio', ...
            formatAspectRatio(m2t, aspectRatio));
        end
    end
end
% ==============================================================================
function m2t = drawBackgroundOfAxes(m2t, handle)
% draw the background color of the current axes
    backgroundColor = get(handle, 'Color');
    if ~isNone(backgroundColor) && isVisible(handle)
        [m2t, col] = getColor(m2t, handle, backgroundColor, 'patch');
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'axis background/.style', sprintf('{fill=%s}', col));
    end
end
% ==============================================================================
function m2t = drawTitleOfAxes(m2t, handle)
% processes the title of an axes object
    [m2t, m2t.axesContainers{end}.options] = getTitle(m2t, handle, ...
        m2t.axesContainers{end}.options);
end
% ==============================================================================
function [m2t, opts] = getTitle(m2t, handle, opts)
% gets the title and its markup from an axes/colorbar/...
    [m2t, opts] = getTitleOrLabel_(m2t, handle, opts, 'Title');
end
function [m2t, opts] = getLabel(m2t, handle, opts, tikzKeyword)
% gets the label and its markup from an axes/colorbar/...
    [m2t, opts] = getTitleOrLabel_(m2t, handle, opts, 'Label', tikzKeyword);
end
function [m2t, opts] = getAxisLabel(m2t, handle, axis, opts)
% convert an {x,y,z} axis label to TikZ
    labelName = [upper(axis) 'Label'];
    [m2t, opts] = getTitleOrLabel_(m2t, handle, opts, labelName);
end
function [m2t, opts] = getTitleOrLabel_(m2t, handle, opts, labelKind, tikzKeyword)
% gets a string element from an object
    if ~exist('tikzKeyword', 'var') || isempty(tikzKeyword)
        tikzKeyword = lower(labelKind);
    end
    object = get(handle, labelKind);

    str = get(object, 'String');
    if ~isempty(str)
        interpreter = get(object, 'Interpreter');
        str = prettyPrint(m2t, str, interpreter);
        style = getFontStyle(m2t, object);
        if length(str) > 1 %multiline
            style = opts_add(style, 'align', 'center');
        end
        if ~isempty(style)
            opts = opts_add(opts, [tikzKeyword ' style'], ...
                   sprintf('{%s}', opts_print(m2t, style, ',')));
        end
        str = join(m2t, str, '\\[1ex]');
        opts =  opts_add(opts, tikzKeyword, sprintf('{%s}', str));
    end
end
% ==============================================================================
function m2t = drawBoxAndLineLocationsOfAxes(m2t, h)
% draw the box and axis line location of an axes object
    isBoxOn       = strcmpi(get(h, 'box'), 'on');
    xLoc          = get(h, 'XAxisLocation');
    yLoc          = get(h, 'YAxisLocation');
    isXaxisBottom = strcmpi(xLoc,'bottom');
    isYaxisLeft   = strcmpi(yLoc,'left');

    % Only flip the labels to the other side if not at the default
    % left/bottom positions
    if isBoxOn
        if ~isXaxisBottom
            m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'xticklabel pos','right');
        end
        if ~isYaxisLeft
            m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'yticklabel pos','right');
        end

    % Position axes lines (strips the box)
    else
        m2t.axesContainers{end}.options = ...
            opts_append(m2t.axesContainers{end}.options, ...
            'axis x line*', xLoc);
        m2t.axesContainers{end}.options = ...
            opts_append(m2t.axesContainers{end}.options, ...
            'axis y line*', yLoc);
        if m2t.axesContainers{end}.is3D
            % There's no such attribute as 'ZAxisLocation'.
            % Instead, the default seems to be 'left'.
            m2t.axesContainers{end}.options = ...
                opts_add(m2t.axesContainers{end}.options, ...
                'axis z line*', 'left');
        end
    end
end
% ==============================================================================
function m2t = drawLegendOptionsOfAxes(m2t, handle)
    % See if there are any legends that need to be plotted.
    % Since the legends are at the same level as axes in the hierarchy,
    % we can't work out which relates to which using the tree
    % so we have to do it by looking for a plot inside which the legend sits.
    % This could be done better with a heuristic of finding
    % the nearest legend to a plot, which would cope with legends outside
    % plot boundaries.
    switch getEnvironment
        case 'MATLAB'
            legendHandle = legend(handle);
            if ~isempty(legendHandle)
                [m2t, key, legendOpts] = getLegendOpts(m2t, legendHandle);
                m2t.axesContainers{end}.options = ...
                    opts_add(m2t.axesContainers{end}.options, ...
                    key, ...
                    ['{', legendOpts, '}']);
            end
        case 'Octave'
            % TODO: How to uniquely connect a legend with a pair of axes in Octave?
            axisDims = pos2dims(get(handle,'Position')); %#ok
            % siblings of this handle:
            siblings = get(get(handle,'Parent'), 'Children');
            % "siblings" always(?) is a column vector. Iterating over the column
            % with the for statement below wouldn't return the individual vector
            % elements but the same column vector, resulting in no legends exported.
            % So let's make sure "siblings" is a row vector by reshaping it:
            siblings = reshape(siblings, 1, []);
            for sibling = siblings
                if sibling && strcmpi(get(sibling,'Type'), 'axes') && strcmpi(get(sibling,'Tag'), 'legend')
                    legDims = pos2dims(get(sibling, 'Position')); %#ok

                    % TODO The following logic does not work for 3D plots.
                    %      => Commented out.
                    %      This creates problems though for stacked plots with legends.
                    %                if (   legDims.left   > axisDims.left ...
                    %                     && legDims.bottom > axisDims.bottom ...
                    %                     && legDims.left + legDims.width < axisDims.left + axisDims.width ...
                    %                     && legDims.bottom + legDims.height  < axisDims.bottom + axisDims.height)
                    [m2t, key, legendOpts] = getLegendOpts(m2t, sibling);
                    m2t.axesContainers{end}.options = ...
                        opts_add(m2t.axesContainers{end}.options, ...
                        key, ...
                        ['{', legendOpts, '}']);
                    %                end
                end
            end
        otherwise
            errorUnknownEnvironment();
    end
end
% ==============================================================================
function m2t = handleColorbar(m2t, handle)
    if isempty(handle)
        return;
    end

    % Find the axes environment that this colorbar belongs to.
    parentAxesHandle = double(get(handle,'axes'));
    parentFound = false;
    for k = 1:length(m2t.axesContainers)
        if m2t.axesContainers{k}.handle == parentAxesHandle
            k0 = k;
            parentFound = true;
            break;
        end
    end
    if parentFound
        m2t.axesContainers{k0}.options = ...
            opts_append(m2t.axesContainers{k0}.options, ...
            matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap), []);
        % Append cell string.
        m2t.axesContainers{k0}.options = cat(1,...
            m2t.axesContainers{k0}.options, ...
            getColorbarOptions(m2t, handle));
    else
        warning('matlab2tikz:parentAxesOfColorBarNotFound',...
            'Could not find parent axes for color bar. Skipping.');
    end
end
% ==============================================================================
function tag = getTag(handle)
    % if a tag is given, use it as comment
    tag = get(handle, 'tag');
    if ~isempty(tag)
        tag = sprintf('Axis "%s"', tag);
    else
        tag = sprintf('Axis at [%.2g %.2f %.2g %.2g]', get(handle, 'position'));
    end
end
% ==============================================================================
function [m2t, options] = getAxisOptions(m2t, handle, axis)
    assertValidAxisSpecifier(axis);

    options = opts_new();
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % axis colors
    [color, isDfltColor] = getAndCheckDefault('Axes', handle, ...
                                              [upper(axis),'Color'], [ 0 0 0 ]);
    if ~isDfltColor || m2t.cmdOpts.Results.strict
        [m2t, col] = getColor(m2t, handle, color, 'patch');
        if strcmpi(get(handle, 'box'), 'on')
            % If the axes are arranged as a box, make sure that the individual
            % axes are drawn as four separate paths. This makes the alignment
            % at the box corners somewhat less nice, but allows for different
            % axis styles (e.g., colors).
            options = opts_add(options, 'separate axis lines', []);
        end
        options = ...
            opts_add(options, ...
            ['every outer ', axis, ' axis line/.append style'], ...
            ['{', col, '}']);
        options = ...
            opts_add(options, ...
            ['every ',axis,' tick label/.append style'], ...
            ['{font=\color{',col,'}}']);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % handle the orientation
    isAxisReversed = strcmpi(get(handle,[upper(axis),'Dir']), 'reverse');
    m2t.([axis 'AxisReversed']) = isAxisReversed;
    if isAxisReversed
        options = opts_add(options, [axis, ' dir'], 'reverse');
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    axisScale = getOrDefault(handle, [upper(axis) 'Scale'], 'lin');
    if strcmpi(axisScale, 'log');
        options = opts_add(options, [axis,'mode'], 'log');
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % get axis limits
    options = setAxisLimits(m2t, handle, axis, options);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % get ticks along with the labels
    [options] = getAxisTicks(m2t, handle, axis, options);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % get axis label
    [m2t, options] = getAxisLabel(m2t, handle, axis, options);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % get grids
    if strcmpi(getOrDefault(handle, [upper(axis),'Grid'], 'off'), 'on');
        options = opts_add(options, [axis, 'majorgrids'], []);
    end
    if strcmpi(getOrDefault(handle, [upper(axis),'MinorGrid'], 'off'), 'on');
        options = opts_add(options, [axis, 'minorgrids'], []);
    end
end
% ==============================================================================
function [options] = getAxisTicks(m2t, handle, axis, options)
% Return axis tick marks Pgfplots style. Nice: Tick lengths and such
% details are taken care of by Pgfplots.
    assertValidAxisSpecifier(axis);

    keywordTickMode = [upper(axis), 'TickMode'];
    tickMode = get(handle, keywordTickMode);
    keywordTick = [upper(axis), 'Tick'];
    ticks = get(handle, keywordTick);
    if isempty(ticks)
        % If no ticks are present, we need to enforce this in any case.
        pgfTicks = '\empty';
    else
        if strcmpi(tickMode, 'auto') && ~m2t.cmdOpts.Results.strict
            % If the ticks are set automatically, and strict conversion is
            % not required, then let Pgfplots take care of the ticks.
            % In most cases, this looks a lot better anyway.
            pgfTicks = [];
        else % strcmpi(tickMode,'manual') || m2t.cmdOpts.Results.strict
            pgfTicks = join(m2t, cellstr(num2str(ticks(:))), ', ');
        end
    end

    keywordTickLabelMode = [upper(axis), 'TickLabelMode'];
    tickLabelMode = get(handle, keywordTickLabelMode);
    keywordTickLabel = [upper(axis), 'TickLabel'];
    tickLabels = cellstr(get(handle, keywordTickLabel));
    if strcmpi(tickLabelMode, 'auto') && ~m2t.cmdOpts.Results.strict
        pgfTickLabels = [];
    else % strcmpi(tickLabelMode,'manual') || m2t.cmdOpts.Results.strict
        keywordScale = [upper(axis), 'Scale'];
        isAxisLog = strcmpi(getOrDefault(handle,keywordScale, 'lin'), 'log');
        [pgfTicks, pgfTickLabels] = ...
            matlabTicks2pgfplotsTicks(m2t, ticks, tickLabels, isAxisLog, tickLabelMode);
    end

    keywordMinorTick = [upper(axis), 'MinorTick'];
    hasMinorTicks = strcmpi(getOrDefault(handle, keywordMinorTick, 'off'), 'on');
    tickDirection = getOrDefault(handle, 'TickDir', 'in');

    options = setAxisTicks(m2t, options, axis, pgfTicks, pgfTickLabels, ...
        hasMinorTicks, tickDirection);
end
% ==============================================================================
function options = setAxisTicks(m2t, options, axis, ticks, tickLabels,hasMinorTicks, tickDir)
% set ticks options

    % According to http://www.mathworks.com/help/techdoc/ref/axes_props.html,
    % the number of minor ticks is automatically determined by MATLAB(R) to
    % fit the size of the axis. Until we know how to extract this number, use
    % a reasonable default.
    matlabDefaultNumMinorTicks = 3;
    if ~isempty(ticks)
        options = opts_add(options, ...
            [axis,'tick'], sprintf('{%s}', ticks));
    end
    if ~isempty(tickLabels)
        options = opts_add(options, ...
            [axis,'ticklabels'], sprintf('{%s}', tickLabels));
    end
    if hasMinorTicks
        options = opts_add(options, ...
            [axis,'minorticks'], 'true');
        if m2t.cmdOpts.Results.strict
            options = ...
                opts_add(options, ...
                sprintf('minor %s tick num', axis), ...
                sprintf('{%d}', matlabDefaultNumMinorTicks));
        end
    end
    if strcmpi(tickDir,'out')
        options = opts_add(options, ...
            'tick align','outside');
    elseif strcmpi(tickDir,'both')
        options = opts_add(options, ...
        'tick align','center');
    end
end
% ==============================================================================
function assertValidAxisSpecifier(axis)
% assert that axis is a valid axis specifier
    if ~ismember(axis, {'x','y','z'})
        error('matlab2tikz:illegalAxisSpecifier', ...
              'Illegal axis specifier "%s".', axis);
    end
end
% ==============================================================================
function assertRegularAxes(handle)
% assert that the (axes) object specified by handle is a regular axes and not a
% colorbar or a legend
    tag = lower(get(handle,'Tag'));
    if ismember(tag,{'colorbar','legend'})
        error('matlab2tikz:notARegularAxes', ...
              ['The object "%s" is not a regular axes object. ' ...
               'It cannot be handled with drawAxes!'], handle);
    end
end
% ==============================================================================
function options = setAxisLimits(m2t, handle, axis, options)
% set the upper/lower limit of an axis
    limits = get(handle, [upper(axis),'Lim']);
    if isfinite(limits(1))
        options = opts_add(options, [axis,'min'], sprintf(m2t.ff, limits(1)));
    end
    if isfinite(limits(2))
        options = opts_add(options, [axis,'max'], sprintf(m2t.ff, limits(2)));
    end
end
% ==============================================================================
function bool = isVisibleContainer(axisHandle)
    if ~isVisible(axisHandle)
        % An invisible axes container *can* have visible children, so don't
        % immediately bail out here.
        children = get(axisHandle, 'Children');
        bool = false;
        for child = children(:)'
            if isVisible(child)
                bool = true;
                return;
            end
        end
    else
        bool = true;
    end
end
% ==============================================================================
function [m2t, str] = drawLine(m2t, h, yDeviation)
% Returns the code for drawing a regular line and error bars.
% This is an extremely common operation and takes place in most of the
% not too fancy plots.
    str = '';

    if ~isVisible(h)
        return
    end

    % Check if there is anything to plot (line annotation has no marker)
    lineStyle  = get(h, 'LineStyle');
    lineWidth  = get(h, 'LineWidth');
    marker     = getOrDefault(h, 'Marker','none');
    hasLines   = ~isNone(lineStyle) && lineWidth > 0;
    hasMarkers = ~isNone(marker);
    if ~hasLines && ~hasMarkers
        return
    end

    % Color
    color         = get(h, 'Color');
    [m2t, xcolor] = getColor(m2t, h, color, 'patch');
    % Line and marker options
    lineOptions          = getLineOptions(m2t, lineStyle, lineWidth);
    [m2t, markerOptions] = getMarkerOptions(m2t, h);

    drawOptions = opts_new();
    drawOptions = opts_add(drawOptions, 'color', xcolor);
    drawOptions = opts_merge(drawOptions, lineOptions, markerOptions);

    % Check for "special" lines, e.g.:
    if strcmpi(get(h, 'Tag'), 'zplane_unitcircle')
        % Draw unit circle and axes.
        % TODO Don't hardcode "10".
        opts = opts_print(m2t, drawOptions, ',');
        str = [sprintf('\\draw[%s] (axis cs:0,0) circle[radius=1];\n', opts),...
            sprintf('\\draw[%s] (axis cs:-10,0)--(axis cs:10,0);\n', opts), ...
            sprintf('\\draw[%s] (axis cs:0,-10)--(axis cs:0,10);\n', opts)];
        return
    end

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    [data] = getXYZDataFromLine(m2t, h);

    % check if the *optional* argument 'yDeviation' was given
    hasDeviations = false;
    if nargin > 2
        data = [data, yDeviation(:,1:2)];
        hasDeviations = true;
    end

    % Check if any value is infinite/NaN. In that case, add appropriate option.
    m2t = jumpAtUnboundCoords(m2t, data);

    [m2t, str] = writePlotData(m2t, str, data, drawOptions);
    [m2t, str] = addLabel(m2t, str);
end
% ==============================================================================
function [m2t, str] = writePlotData(m2t, str, data, drawOptions)
% actually writes the plot data to file
    is3D = m2t.axesContainers{end}.is3D;
    if is3D
        % Don't try to be smart in parametric 3d plots: Just plot all the data.
        [m2t, table, tabOpts] = makeTable(m2t, {'','',''}, data);
        str = sprintf('%s\\addplot3 [%s]\n table[%s] {%s};\n ', ...
                      str, opts_print(m2t, drawOptions, ','), ...
                      opts_print(m2t, tabOpts,','), table);
    else
        % split the data into logical chunks
        dataCell = splitLine(m2t, data);

        % plot them
        for k = 1:length(dataCell)
            % If the line has a legend string, make sure to only include a legend
            % entry for the *last* occurrence of the plot series.
            % Hence the condition k<length(xDataCell).
            %if ~isempty(m2t.legendHandles) && (~m2t.currentHandleHasLegend || k < length(dataCell))
            if ~m2t.currentHandleHasLegend || k < length(dataCell)
                % No legend entry found. Don't include plot in legend.
                hiddenDrawOptions = maybeShowInLegend(false, drawOptions);
                opts = opts_print(m2t, hiddenDrawOptions, ',');
            else
                opts = opts_print(m2t, drawOptions, ',');
            end

            [m2t, Part] = plotLine2d(m2t, opts, dataCell{k});
            str = [str, Part];
        end
    end
end
% ==============================================================================
function [data] = getXYZDataFromLine(m2t, h)
% Retrieves the X, Y and Z (if appropriate) data from a Line object
%
% First put them all together in one multiarray.
% This also implicitly makes sure that the lengths match.
    try
        xData = get(h, 'XData');
        yData = get(h, 'YData');
    catch
        % Line annotation
        xData = get(h, 'X');
        yData = get(h, 'Y');
    end
    is3D  = m2t.axesContainers{end}.is3D;
    if ~is3D
        data = [xData(:), yData(:)];
    else
        zData = get(h, 'ZData');
        data = applyHgTransform(m2t, [xData(:), yData(:), zData(:)]);
    end
end
% ==============================================================================
function [m2t, generatedCodeSoFar, labelCode] = addLabel(m2t, generatedCodeSoFar)
% conditionally add a LaTeX label after the current plot
    if ~exist('generatedCodeSoFar','var') || isempty(generatedCodeSoFar)
        generatedCodeSoFar = '';
    end
    if m2t.cmdOpts.Results.automaticLabels
        [pathstr, name] = fileparts(m2t.cmdOpts.Results.filename); %#ok
        labelName = sprintf('addplot:%s%d', name, m2t.automaticLabelIndex);
        labelCode = sprintf('\\label{%s}\n', labelName);
        m2t.automaticLabelIndex = m2t.automaticLabelIndex + 1;

        userWarning(m2t, 'Automatically added label ''%s'' for line plot.', labelName);
        generatedCodeSoFar = [generatedCodeSoFar, labelCode];
    end
end
% ==============================================================================
function [m2t,str] = plotLine2d(m2t, opts, data)
    errorbarMode = (size(data,2) == 4); % is (optional) yDeviation given?

    str = '';
    if errorbarMode
        m2t = needsPgfplotsVersion(m2t, [1,9]);
        str = sprintf('plot [error bars/.cd, y dir = both, y explicit]\n');
    end

    % Convert to string array then cell to call sprintf once (and no loops).
    [m2t, table, tabOpts] = makeTable(m2t, repmat({''}, size(data,2)), data);
    if errorbarMode
        tabOpts = opts_add(tabOpts, 'y error plus index', '2');
        tabOpts = opts_add(tabOpts, 'y error minus index', '3');
    end
    str = sprintf('\\addplot [%s]\n %s table[%s]{%s};\n',...
        opts, str, opts_print(m2t, tabOpts, ', '), table);
end
% ==============================================================================
function dataCell = splitLine(m2t, data)
% Split the xData, yData into several chunks of data for each of which
% an \addplot will be generated.
    dataCell{1} = data;

    % Split each of the current chunks further with respect to outliers.
    dataCell = splitByArraySize(m2t, dataCell);
end
% ==============================================================================
function dataCellNew = splitByArraySize(m2t, dataCell)
% TeX parses files line by line with a buffer of size buf_size. If the
% plot has too many data points, pdfTeX's buffer size may be exceeded.
% As a work-around, the plot is split into several smaller plots, and this
% function does the job.
    dataCellNew = cell(0);

    %TODO: pre-allocate the cell array such that it doesn't grow during the loop
    %TODO: scale `maxChunkLength` with the number of columns in the data array

    for data = dataCell
        chunkStart = 1;
        len = size(data{1}, 1);
        while chunkStart <= len
            chunkEnd = min(chunkStart + m2t.cmdOpts.Results.maxChunkLength - 1, len);

            % Copy over the data to the new containers.
            dataCellNew{end+1} = data{1}(chunkStart:chunkEnd,:);

            % Add an extra (overlap) point to the data stream;
            % otherwise the line between two data chunks would be broken.
            % Technically, this is only needed when the plot has a line
            % connecting the points, but the additional cost when there is no
            % line doesn't justify the added complexity.
            if chunkEnd~=len
                dataCellNew{end} = [dataCellNew{end};...
                                    data{1}(chunkEnd+1,:)];
            end

            chunkStart = chunkEnd + 1;
        end
    end
end
% ==============================================================================
function lineOpts = getLineOptions(m2t, lineStyle, lineWidth)
% Gathers the line options.
    lineOpts = opts_new();

    if ~isNone(lineStyle) && (lineWidth > m2t.tol)
        lineOpts = opts_add(lineOpts, translateLineStyle(lineStyle));
    end

    % Take over the line width in any case when in strict mode. If not, don't add
    % anything in case of default line width and effectively take Pgfplots'
    % default.
    % Also apply the line width if no actual line is there; the markers make use
    % of this, too.
    matlabDefaultLineWidth = 0.5;
    if m2t.cmdOpts.Results.strict ...
            || ~abs(lineWidth-matlabDefaultLineWidth) <= m2t.tol
        lineOpts = opts_add(lineOpts, 'line width', sprintf('%.1fpt', lineWidth));
    end
end
% ==============================================================================
function [m2t, drawOptions] = getMarkerOptions(m2t, h)
% Handles the marker properties of a line (or any other) plot.
    drawOptions = opts_new();

    marker = getOrDefault(h, 'Marker', 'none');

    if ~isNone(marker)
        markerSize = get(h, 'MarkerSize');
        lineStyle  = get(h, 'LineStyle');
        lineWidth  = get(h, 'LineWidth');

        [tikzMarkerSize, isDefault] = ...
            translateMarkerSize(m2t, marker, markerSize);

        % take over the marker size in any case when in strict mode;
        % if not, don't add anything in case of default marker size
        % and effectively take Pgfplots' default.
        if m2t.cmdOpts.Results.strict || ~isDefault
            drawOptions = opts_add(drawOptions, 'mark size', ...
                                   sprintf('%.1fpt', tikzMarkerSize));
        end

        markOptions = opts_new();
        % make sure that the markers get painted in solid (and not dashed)
        % if the 'lineStyle' is not solid (otherwise there is no problem)
        if ~strcmpi(lineStyle, 'solid')
            markOptions = opts_add(markOptions, 'solid');
        end

        % print no lines
        if isNone(lineStyle) || lineWidth==0
            drawOptions = opts_add(drawOptions, 'only marks');
        end

        % get the marker color right
        markerFaceColor = get(h, 'markerfaceColor');
        markerEdgeColor = get(h, 'markeredgeColor');

        [tikzMarker, markOptions] = translateMarker(m2t, marker, ...
                                        markOptions, ~isNone(markerFaceColor));

        [m2t, markOptions] = setColor(m2t, h, markOptions, 'fill', markerFaceColor);

        if ~strcmpi(markerEdgeColor,'auto')
            [m2t, markOptions] = setColor(m2t, h, markOptions, 'draw', markerEdgeColor);
        end

        % add it all to drawOptions
        drawOptions = opts_add(drawOptions, 'mark', tikzMarker);

        if ~isempty(markOptions)
            mo = opts_print(m2t, markOptions, ',');
            drawOptions = opts_add(drawOptions, 'mark options', ['{' mo '}']);
        end
    end
end
% ==============================================================================
function [tikzMarkerSize, isDefault] = ...
    translateMarkerSize(m2t, matlabMarker, matlabMarkerSize)
% The markersizes of Matlab and TikZ are related, but not equal. This
% is because
%
%  1.) MATLAB uses the MarkerSize property to describe something like
%      the diameter of the mark, while TikZ refers to the 'radius',
%  2.) MATLAB and TikZ take different measures (e.g. the
%      edge of a square vs. its diagonal).
    if(~ischar(matlabMarker))
        error('matlab2tikz:translateMarkerSize',                      ...
            'Variable matlabMarker is not a string.');
    end

    if(~isnumeric(matlabMarkerSize))
        error('matlab2tikz:translateMarkerSize',                      ...
            'Variable matlabMarkerSize is not a numeral.');
    end

    % 6pt is the default MATLAB marker size for all markers
    defaultMatlabMarkerSize = 6;
    isDefault = abs(matlabMarkerSize(1)-defaultMatlabMarkerSize)<m2t.tol;
    % matlabMarkerSize can be vector data, use first index to check the default
    % marker size. When the script also handles different markers together with
    % changing size and color, the test should be extended to a vector norm, e.g.
    % sqrt(e^T*e) < tol, where e=matlabMarkerSize-defaultMatlabMarkerSize

    switch (matlabMarker)
        case 'none'
            tikzMarkerSize = [];
        case {'+','o','x','*','p','pentagram','h','hexagram'}
            % In MATLAB, the marker size refers to the edge length of a
            % square (for example) (~diameter), whereas in TikZ the
            % distance of an edge to the center is the measure (~radius).
            % Hence divide by 2.
            tikzMarkerSize = matlabMarkerSize(:) / 2;
        case '.'
            % as documented on the Matlab help pages:
            %
            % Note that MATLAB draws the point marker (specified by the '.'
            % symbol) at one-third the specified size.
            % The point (.) marker type does not change size when the
            % specified value is less than 5.
            %
            tikzMarkerSize = matlabMarkerSize(:) / 2 / 3;
        case {'s','square'}
            % Matlab measures the diameter, TikZ half the edge length
            tikzMarkerSize = matlabMarkerSize(:) / 2 / sqrt(2);
        case {'d','diamond'}
            % MATLAB measures the width, TikZ the height of the diamond;
            % the acute angle (at the top and the bottom of the diamond)
            % is a manually measured 75 degrees (in TikZ, and MATLAB
            % probably very similar); use this as a base for calculations
            tikzMarkerSize = matlabMarkerSize(:) / 2 / atan(75/2 *pi/180);
        case {'^','v','<','>'}
            % for triangles, matlab takes the height
            % and tikz the circumcircle radius;
            % the triangles are always equiangular
            tikzMarkerSize = matlabMarkerSize(:) / 2 * (2/3);
        otherwise
            error('matlab2tikz:translateMarkerSize',                   ...
                'Unknown matlabMarker ''%s''.', matlabMarker);
    end
end
% ==============================================================================
function [tikzMarker, markOptions] = ...
    translateMarker(m2t, matlabMarker, markOptions, faceColorToggle)
% Translates MATLAB markers to their Tikz equivalents
% #COMPLEX: inherently large switch-case
    if ~ischar(matlabMarker)
        error('matlab2tikz:translateMarker:MarkerNotAString',...
            'matlabMarker is not a string.');
    end

    switch (matlabMarker)
        case 'none'
            tikzMarker = '';
        case '+'
            tikzMarker = '+';
        case 'o'
            if faceColorToggle
                tikzMarker = '*';
            else
                tikzMarker = 'o';
            end
        case '.'
            tikzMarker = '*';
        case 'x'
            tikzMarker = 'x';
        otherwise  % the following markers are only available with PGF's
            % plotmarks library
            userInfo(m2t, '\nMake sure to load \\usetikzlibrary{plotmarks} in the preamble.\n');
            hasFilledVariant = true;
            switch (matlabMarker)

                case '*'
                    tikzMarker = 'asterisk';
                    hasFilledVariant = false;

                case {'s','square'}
                    tikzMarker = 'square';

                case {'d','diamond'}
                    tikzMarker = 'diamond';

                case '^'
                    tikzMarker = 'triangle';

                case 'v'
                    tikzMarker = 'triangle';
                    markOptions = opts_add(markOptions, 'rotate', '180');

                case '<'
                    tikzMarker = 'triangle';
                    markOptions = opts_add(markOptions, 'rotate', '90');

                case '>'
                    tikzMarker = 'triangle';
                    markOptions = opts_add(markOptions, 'rotate', '270');

                case {'p','pentagram'}
                    tikzMarker = 'star';

                case {'h','hexagram'}
                    userWarning(m2t, 'MATLAB''s marker ''hexagram'' not available in TikZ. Replacing by ''star''.');
                    tikzMarker = 'star';

                otherwise
                    error('matlab2tikz:translateMarker:unknownMatlabMarker',...
                        'Unknown matlabMarker ''%s''.',matlabMarker);
            end
            if faceColorToggle && hasFilledVariant
                tikzMarker = [tikzMarker '*'];
            end
    end
end
% ==============================================================================
function [m2t, str] = drawPatch(m2t, handle)
% Draws a 'patch' graphics object (as found in contourf plots, for example).
%
    str = '';

    if ~isVisible(handle)
        return
    end

    % This is for a quirky workaround for stacked bar plots.
    m2t.axesContainers{end}.nonbarPlotsPresent = true;

    % Each row of the faces matrix represents a distinct patch
    % NOTE: pgfplot uses zero-based indexing into vertices and interpolates
    % counter-clockwise
    Faces    = get(handle,'Faces')-1;
    Vertices = get(handle,'Vertices');

    % 3D vs 2D
    is3D = m2t.axesContainers{end}.is3D;
    if is3D
        columnNames = {'x', 'y', 'z'};
        plotCmd     = 'addplot3';
        Vertices    = applyHgTransform(m2t, Vertices);
    else
        columnNames = {'x', 'y'};
        plotCmd     = 'addplot';
        Vertices    = Vertices(:,1:2);
    end

    % Process fill, edge colors and shader
    [m2t,patchOptions, s] = shaderOpts(m2t,handle,'patch');

    % Return empty axes if no face or edge colors
    if isNone(s.plotType)
        return
    end

    % -----------------------------------------------------------------------
    % gather the draw options
    % Make sure that legends are shown in area mode.
    drawOptions = opts_add(opts_new,'area legend','');
    verticesTableOptions = opts_new();

    % Marker options
    [m2t, markerOptions] = getMarkerOptions(m2t, handle);
    drawOptions          = opts_merge(drawOptions, markerOptions);

    % Line options
    lineStyle   = get(handle, 'LineStyle');
    lineWidth   = get(handle, 'LineWidth');
    lineOptions = getLineOptions(m2t, lineStyle, lineWidth);
    drawOptions = opts_merge(drawOptions, lineOptions);

    % No patch: if one patch and single face/edge color
    isFaceColorFlat = isempty(strfind(opts_get(patchOptions, 'shader'),'interp'));
    if size(Faces,1) == 1 && s.hasOneEdgeColor && isFaceColorFlat
        ptType = '';
        cycle  = conditionallyCyclePath(Vertices);

        [m2t, drawOptions] = setColor(m2t, handle, drawOptions, 'draw', ...
                                         s.edgeColor);
        [m2t, drawOptions] = setColor(m2t, handle, drawOptions, 'fill', ...
                                         s.faceColor);
                                     
        [drawOptions] = opts_copy(patchOptions, 'draw opacity', drawOptions);
        [drawOptions] = opts_copy(patchOptions, 'fill opacity', drawOptions);

    else % Multiple patches

        % Patch table type
        ptType      = 'patch table';
        cycle       = '';
        drawOptions = opts_add(drawOptions,'table/row sep','crcr');
        % TODO: is the above "crcr" compatible with pgfplots 1.12 ?
        % TODO: is a "patch table" externalizable?

        % Enforce 'patch' or cannot use 'patch table='
        if strcmpi(s.plotType,'mesh')
            drawOptions = opts_add(drawOptions,'patch','');
        end
        drawOptions = opts_add(drawOptions,s.plotType,''); % Eventually add mesh, but after patch!

        drawOptions = getPatchShape(m2t, handle, drawOptions, patchOptions);

        [m2t, drawOptions, Vertices, Faces, verticesTableOptions, ptType, ...
         columnNames] = setColorsOfPatches(m2t, handle, drawOptions, ...
           Vertices, Faces, verticesTableOptions, ptType, columnNames, ...
           isFaceColorFlat, s);
    end

    drawOptions = maybeShowInLegend(m2t.currentHandleHasLegend, drawOptions);
    m2t = jumpAtUnboundCoords(m2t, Faces(:));

    % Add Faces table
    if ~isempty(ptType)
        [m2t, facesTable] = makeTable(m2t, repmat({''},1,size(Faces,2)), Faces);
        drawOptions = opts_add(drawOptions, ptType, sprintf('{%s}', facesTable));
    end
    drawOpts = opts_print(m2t, drawOptions,',');

    % Plot the actual data.
    [m2t, verticesTable, tabOpts] = makeTable(m2t, columnNames, Vertices);
    tabOpts = opts_merge(tabOpts, verticesTableOptions);

    str = sprintf('%s\n\\%s[%s]\ntable[%s] {%s}%s;\n',...
        str, plotCmd, drawOpts, opts_print(m2t, tabOpts, ', '), verticesTable, cycle);
end
% ==============================================================================
function [m2t, drawOptions, Vertices, Faces, verticesTableOptions, ptType, ...
         columnNames] = setColorsOfPatches(m2t, handle, drawOptions, ...
           Vertices, Faces, verticesTableOptions, ptType, columnNames, isFaceColorFlat, s)
% this behemoth does the color setting for patches

    % TODO: this function can probably be split further, just look at all those
    % parameters being passed.

    fvCData   = get(handle,'FaceVertexCData');
    rowsCData = size(fvCData,1);

    % We have CData for either all faces or vertices
    if rowsCData > 1

        % Add the color map
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap), []);

        % Determine if mapping is direct or scaled
        CDataMapping = get(handle,'CDataMapping');
        if strcmpi(CDataMapping, 'direct')
            drawOptions = opts_add(drawOptions, 'colormap access','direct');
        end

        % Switch to face CData if not using interpolated shader
        isVerticesCData = rowsCData == size(Vertices,1);
        if isFaceColorFlat && isVerticesCData
            % Take first vertex color (see FaceColor in Patch Properties)
            fvCData         = fvCData(Faces(:,1)+ 1,:);
            rowsCData       = size(fvCData,1);
            isVerticesCData = false;
        end

        % Point meta as true color CData, i.e. RGB in [0,1]
        if size(fvCData,2) == 3
            % Create additional custom colormap
            m2t.axesContainers{end}.options(end+1,:) = ...
                {matlab2pgfplotsColormap(m2t, fvCData, 'patchmap'), []};
            drawOptions = opts_append(drawOptions, 'colormap name','patchmap');

            % Index into custom colormap
            fvCData = (0:rowsCData-1)';
        end

        % Add pointmeta data to vertices or faces
        if isVerticesCData
            columnNames{end+1}   = 'c';
            verticesTableOptions = opts_add(verticesTableOptions, 'point meta','\thisrow{c}');
            Vertices             = [Vertices, fvCData];
        else
            ptType = 'patch table with point meta';
            Faces  = [Faces fvCData];
        end

    else
        % Scalar FaceVertexCData, i.e. one color mapping for all patches,
        % used e.g. by Octave in drawing barseries

        [m2t,xFaceColor] = getColor(m2t, handle, s.faceColor, 'patch');
        drawOptions      = opts_add(drawOptions, 'fill', xFaceColor);
    end
end
% ==============================================================================
function [drawOptions] = maybeShowInLegend(showInLegend, drawOptions)
% sets the appropriate options to show/hide the plot in the legend
    if ~showInLegend
        % No legend entry found. Don't include plot in legend.
        drawOptions = opts_add(drawOptions, 'forget plot', '');
    end
end
% ==============================================================================
function [m2t, options] = setColor(m2t, handle, options, property, color, noneValue)
% assigns the MATLAB color of the object identified by "handle" to the LaTeX
% property stored in the options array. An optional "noneValue" can be provided
% that is set when the color == 'none' (if it is omitted, the property will not
% be set).
% TODO: probably this should be integrated with getAndCheckDefault etc.
    if ~isNone(color)
        [m2t, xcolor] = getColor(m2t, handle, color, 'patch');
        if ~isempty(xcolor)
            % this may happen when color == 'flat' and CData is Nx3, e.g. in
            % scatter plot or in patches
            options = opts_add(options, property, xcolor);
        end
    else
        if exist('noneValue','var')
            options = opts_add(options, property, noneValue);
        end
    end
end
% ==============================================================================
function drawOptions = getPatchShape(m2t, h, drawOptions, patchOptions)
% Retrieves the shape options (i.e. number of vertices) of patch objects
% Depending on the number of vertices, patches can be triangular, rectangular
% or polygonal
% See pgfplots 1.12 manual section 5.8.1 "Additional Patch Types" and the
% patchplots library
    vertexCount = size(get(h, 'Faces'), 2);

    switch vertexCount
        case 3 % triangle (default)
            % do nothing special

        case 4 % rectangle
            drawOptions = opts_add(drawOptions,'patch type', 'rectangle');

        otherwise % generic polygon
            userInfo(m2t, '\nMake sure to load \\usepgfplotslibrary{patchplots} in the preamble.\n');

            % Default interpolated shader,not supported by polygon, to faceted
            if ~isFaceColorFlat
                % NOTE: check if pgfplots supports this (or specify version)
                userInfo(m2t, '\nPgfplots does not support interpolation for polygons.\n Use patches with at most 4 vertices.\n');
                patchOptions = opts_remove(patchOptions, 'shader');
                patchOptions = opts_add(patchOptions, 'shader', 'faceted');
            end

            % Add draw options
            drawOptions = opts_add(drawOptions, 'patch type', 'polygon');
            drawOptions = opts_add(drawOptions, 'vertex count', ...
                                                sprintf('%d', vertexCount));
    end

    drawOptions = opts_merge(drawOptions, patchOptions);
end
% ==============================================================================
function [cycle] = conditionallyCyclePath(data)
% returns "--cycle" when the path should be cyclic in pgfplots
% Mostly, this is the case UNLESS the data record starts or ends with a NaN
% record (i.e. a break in the path)
    if any(~isfinite(data([1 end],:)))
        cycle = '';
    else
        cycle = '--cycle';
    end
end
% ==============================================================================
function m2t = jumpAtUnboundCoords(m2t, data)
% signals the axis to allow discontinuities in the plot at unbounded
% coordinates (i.e. Inf and NaN).
% See also pgfplots 1.12 manual section 4.5.13 "Interrupted Plots".
    if any(~isfinite(data(:)))
        m2t = needsPgfplotsVersion(m2t, [1 4]);
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'unbounded coords', 'jump');
    end
end
% ==============================================================================
function [m2t, str] = drawImage(m2t, handle)
    str = '';

    if ~isVisible(handle)
        return
    end

    % read x-, y-, and color-data
    xData = get(handle, 'XData');
    yData = get(handle, 'YData');
    cData = get(handle, 'CData');

    if (m2t.cmdOpts.Results.imagesAsPng)
        [m2t, str] = imageAsPNG(m2t, handle, xData, yData, cData);
    else
        [m2t, str] = imageAsTikZ(m2t, handle, xData, yData, cData);
    end

    % Make sure that the axes are still visible above the image.
    m2t.axesContainers{end}.options = ...
        opts_add(m2t.axesContainers{end}.options, ...
        'axis on top', []);
end
% ==============================================================================
function [m2t, str] = imageAsPNG(m2t, handle, xData, yData, cData)
    m2t.imageAsPngNo = m2t.imageAsPngNo + 1;
    % ------------------------------------------------------------------------
    % draw a png image
    [pngFileName, pngReferencePath] = externalFilename(m2t, m2t.imageAsPngNo, '.png');

    % Get color indices for indexed images and truecolor values otherwise
    if ndims(cData) == 2 %#ok don't use ismatrix (cfr. #143)
        [m2t, colorData] = cdata2colorindex(m2t, cData, handle);
    else
        colorData = cData;
    end

    m = size(cData, 1);
    n = size(cData, 2);

    alphaData = normalizedAlphaValues(m2t, get(handle,'AlphaData'), handle);
    if numel(alphaData) == 1
        alphaData = alphaData(ones(size(colorData(:,:,1))));
    end
    [colorData, alphaData] = flipImageIfAxesReversed(m2t, colorData, alphaData);

    % Write an indexed or a truecolor image
    hasAlpha = true;
    if isfloat(alphaData) && all(alphaData(:) == 1)
        alphaOpts = {};
        hasAlpha = false;
    else
        alphaOpts = {'Alpha', alphaData};
    end
    if (ndims(colorData) == 2) %#ok don't use ismatrix (cfr. #143)
        if size(m2t.currentHandles.colormap, 1) <= 256 && ~hasAlpha
            % imwrite supports maximum 256 values in a colormap (i.e. 8 bit)
            % and no alpha channel for indexed PNG images.
            imwrite(colorData, m2t.currentHandles.colormap, ...
                pngFileName, 'png');
        else % use true-color instead
            imwrite(ind2rgb(colorData, m2t.currentHandles.colormap), ...
                pngFileName, 'png', alphaOpts{:});
        end
    else
        imwrite(colorData, pngFileName, 'png', alphaOpts{:});
    end
    % -----------------------------------------------------------------------
    % dimensions of a pixel in axes units
    if n == 1
        xLim = get(m2t.currentHandles.gca, 'XLim');
        xw = xLim(2) - xLim(1);
    else
        xw = (xData(end)-xData(1)) / (n-1);
    end
    if m == 1
        yLim = get(m2t.currentHandles.gca, 'YLim');
        yw = yLim(2) - yLim(1);
    else
        yw = (yData(end)-yData(1)) / (m-1);
    end

    opts = opts_new();
    opts = opts_add(opts, 'xmin', sprintf(m2t.ff, xData(1  ) - xw/2));
    opts = opts_add(opts, 'xmax', sprintf(m2t.ff, xData(end) + xw/2));
    opts = opts_add(opts, 'ymin', sprintf(m2t.ff, yData(1  ) - yw/2));
    opts = opts_add(opts, 'ymax', sprintf(m2t.ff, yData(end) + yw/2));

    str = sprintf('\\addplot [forget plot] graphics [%s] {%s};\n', ...
        opts_print(m2t, opts, ','), pngReferencePath);

    userInfo(m2t, ...
        ['\nA PNG file is stored at ''%s'' for which\n', ...
        'the TikZ file contains a reference to ''%s''.\n', ...
        'You may need to adapt this, depending on the relative\n', ...
        'locations of the master TeX file and the included TikZ file.\n'], ...
        pngFileName, pngReferencePath);
end
% ==============================================================================
function [m2t, str] = imageAsTikZ(m2t, handle, xData, yData, cData)
% writes an image as raw TikZ commands (STRONGLY DISCOURAGED)

    % set up cData
    if ndims(cData) == 3
        cData = cData(end:-1:1,:,:);
    else
        cData = cData(end:-1:1,:);
    end


    % Generate uniformly distributed X, Y, although xData and yData may be
    % non-uniform.
    % This is MATLAB(R) behavior.
    switch length(xData)
        case 2 % only the limits given; common for generic image plots
            hX = 1;
        case size(cData,1) % specific x-data is given
            hX = (xData(end)-xData(1)) / (length(xData)-1);
        otherwise
            error('drawImage:arrayLengthMismatch', ...
                'Array lengths not matching (%d = size(cdata,1) ~= length(xData) = %d).', size(cData,1), length(xData));
    end
    X = xData(1):hX:xData(end);

    switch length(yData)
        case 2 % only the limits given; common for generic image plots
            hY = 1;
        case size(cData,2) % specific y-data is given
            hY = (yData(end)-yData(1)) / (length(yData)-1);
        otherwise
            error('drawImage:arrayLengthMismatch', ...
                'Array lengths not matching (%d = size(cData,2) ~= length(yData) = %d).', size(cData,2), length(yData));
    end
    Y = yData(1):hY:yData(end);
    [m2t, xcolor] = getColor(m2t, handle, cData, 'image');

    % The following section takes pretty long to execute, although in
    % principle it is discouraged to use TikZ for those; LaTeX will take
    % forever to compile.
    % Still, a bug has been filed on MathWorks to allow for one-line
    % sprintf'ing with (string+num) cells (Request ID: 1-9WHK4W);
    % <http://www.mathworks.de/support/service_requests/Service_Request_Detail.do?ID=183481&filter=&sort=&statusorder=0&dateorder=0>.
    % An alternative approach could be to use 'surf' or 'patch' of pgfplots
    % with inline tables.
    str = '';
    m = length(X);
    n = length(Y);
    for i = 1:m
        for j = 1:n
            str = [str, ...
                sprintf(['\t\\fill [%s] ', ...
                    '(axis cs:', m2t.ff,',', m2t.ff,') rectangle ', ...
                    '(axis cs:', m2t.ff,',',m2t.ff,');\n'], ...
                    xcolor{n-j+1,i}, ...
                    X(i)-hX/2, Y(j)-hY/2, ...
                    X(i)+hX/2, Y(j)+hY/2 ...
                    )];
        end
    end
end
% ==============================================================================
function [colorData, alphaData] = flipImageIfAxesReversed(m2t, colorData, alphaData)
% flip the image if reversed
    if m2t.xAxisReversed
        colorData = colorData(:, end:-1:1, :);
        alphaData = alphaData(:, end:-1:1);
    end
    if ~m2t.yAxisReversed % y-axis direction is revesed normally for images, flip otherwise
        colorData = colorData(end:-1:1, :, :);
        alphaData = alphaData(end:-1:1, :);
    end
end
% ==============================================================================
function alpha = normalizedAlphaValues(m2t, alpha, handle)
    alphaDataMapping = getOrDefault(handle, 'AlphaDataMapping', 'none');
    switch lower(alphaDataMapping)
        case 'none'  % no rescaling needed
        case 'scaled'
            ALim = get(m2t.currentHandles.gca, 'ALim');
            AMax = ALim(2);
            AMin = ALim(1);
            if ~isfinite(AMax)
                AMax = max(alpha(:)); %NOTE: is this right?
            end
            alpha = (alpha - AMin)./(AMax - AMin);
        case 'direct'
            alpha = ind2rgb(alpha, get(m2t.currentHandles.gcf, 'Alphamap'));
        otherwise
            error('matlab2tikz:UnknownAlphaMapping', ...
                  'Unknown alpha mapping "%s"', alphaMapping);
    end

    if isfloat(alpha) %important, alpha data can have integer type which should not be scaled
        alpha = min(1,max(alpha,0)); % clip at range [0, 1]
    end
end
% ==============================================================================
function [m2t, str] = drawContour(m2t, h)
    if isHG2()
        [m2t, str] = drawContourHG2(m2t, h);
    else
        % Save legend state for the contour group
        hasLegend = m2t.currentHandleHasLegend;

        % Plot children patches
        children  = get(h,'children');
        N         = numel(children);
        str       = cell(N,1);
        for ii = 1:N
            % Plot in reverse order
            child          = children(N-ii+1);
            isContourLabel = strcmpi(get(child,'type'),'text');
            if isContourLabel
                [m2t, str{ii}] = drawText(m2t,child);
            else
                [m2t, str{ii}] = drawPatch(m2t,child);
            end

            % Only first child can be in the legend
            m2t.currentHandleHasLegend = false; 
        end
        str = strcat(str,sprintf('\n'));
        str = [str{:}];

        % Restore group's legend state
        m2t.currentHandleHasLegend = hasLegend;
    end
end
% ==============================================================================
function [m2t, str] = drawContourHG2(m2t, h)
  str = '';
  
  % Retrieve ContourMatrix
  contours = get(h,'ContourMatrix')';
  [istart, nrows] = findStartOfContourData(contours);

  % Scale negative contours one level down (for proper coloring)
  Levels    = contours(istart,1);
  LevelList = get(h,'LevelList');
  ineg      = Levels < 0;
  if any(ineg) && min(LevelList) < min(Levels)
      [idx,pos] = ismember(Levels, LevelList);
      idx       = idx & ineg;
      contours(istart(idx)) = LevelList(pos(idx)-1);
  end

  % Draw a contour group (MATLAB R2014b and newer only)
  isFilled = strcmpi(get(h,'Fill'),'on');
  if isFilled
      [m2t, str] = drawFilledContours(m2t, str, h, contours, istart, nrows);

  else
      % Add colormap
      cmap = m2t.currentHandles.colormap;
      m2t.axesContainers{end}.options = ...
          opts_add(m2t.axesContainers{end}.options, ...
          matlab2pgfplotsColormap(m2t, cmap));

      % Contour table in Matlab format
      plotoptions = opts_new();
      plotoptions = opts_add(plotoptions,'contour prepared');
      plotoptions = opts_add(plotoptions,'contour prepared format','matlab');

      % Labels
      if strcmpi(get(h,'ShowText'),'off')
          plotoptions = opts_add(plotoptions,'contour/labels','false');
      end

      % Make contour table
      [m2t, table, tabOpts] = makeTable(m2t, {'',''}, contours);

      str = sprintf('\\addplot[%s] table[%s] {%%\n%s};\n', ...
          opts_print(m2t, plotoptions, ', '),...
          opts_print(m2t, tabOpts, ','), table);

  end
end
% ==============================================================================
function [istart, nrows] = findStartOfContourData(contours)
% Index beginning of contour data (see contourc.m for details)
    nrows  = size(contours,1);
    istart = false(nrows,1);
    pos    = 1;
    while pos < nrows
        istart(pos) = true;
        pos         = pos + contours(pos, 2) + 1;
    end
    istart = find(istart);
end
% ==============================================================================
function [m2t, str] = drawFilledContours(m2t, str, h, contours, istart, nrows)
    % Loop each contour and plot a filled region
    %
    % NOTE:
    % - we cannot plot from inner to outer contour since the last
    % filled area will cover the inner regions. Therefore, we need to
    % invert the plotting order in those cases.
    % - we need to distinguish between contour groups. A group is
    % defined by inclusion, i.e. its members are contained within one
    % outer contour. The outer contours of two groups cannot include
    % each other.

    % Split contours in cell array
    cellcont = mat2cell(contours, diff([istart; nrows+1]));
    ncont    = numel(cellcont);

    % Determine contour groups and the plotting order.
    % The ContourMatrix lists the contours in ascending order by level.
    % Hence, if the lowest (first) contour contains any others, then the
    % group will be a peak. Otherwise, the group will be a valley, and
    % the contours will have to be plotted in reverse order, i.e. from
    % highest (largest) to lowest (narrowest).
    order = NaN(ncont,1);
    ifree = true(ncont,1);
    from  = 1;
    while any(ifree)
        % Select peer with lowest level among the free contours, i.e.
        % those which do not belong to any group yet
        pospeer = find(ifree,1,'first');
        peer    = cellcont{pospeer};
        igroup  = false(ncont,1);

        % Loop through all contours
        for ii = 1:numel(cellcont)
            if ~ifree(ii), continue, end

            curr = cellcont{ii};
            % Current contour contained in the peer
            if inpolygon(curr(2,1),curr(2,2), peer(2:end,1),peer(2:end,2))
                igroup(ii) = true;
                isinverse  = false;
                % Peer contained in the current
            elseif inpolygon(peer(2,1),peer(2,2),curr(2:end,1),curr(2:end,2))
                igroup(ii) = true;
                isinverse  = true;
            end
        end
        % Order members of group according to the inclusion principle
        nmembers = nnz(igroup ~= 0);
        if isinverse
            order(igroup) = nmembers+from-1:-1:from;
        else
            order(igroup) = from:nmembers+from-1;
        end

        % Continue numbering
        from  = from + nmembers;
        ifree = ifree & ~igroup;
    end

    % Reorder the contours
    cellcont(order,1) = cellcont;

    % Add zero level fill
    xdata = get(h,'XData');
    ydata = get(h,'YData');
    zerolevel = [0,          4;
                 min(xdata), min(ydata);
                 min(xdata), max(ydata);
                 max(xdata), max(ydata);
                 max(xdata), min(ydata)];
    cellcont = [zerolevel; cellcont];

    % Plot
    columnNames = {'x','y'};
    for ii = 1:ncont + 1
        drawOpts = opts_new();

        % Get color
        zval          = cellcont{ii}(1,1);
        [m2t, xcolor] = getColor(m2t,h,zval,'image');
        drawOpts      = opts_add(drawOpts,'fill',xcolor);

        % Toggle legend entry
        hasLegend = ii == 1 && m2t.currentHandleHasLegend;
        drawOpts  = maybeShowInLegend(hasLegend, drawOpts);

        % Print table
        [m2t, table, tabOpts] = makeTable(m2t, columnNames, cellcont{ii}(2:end,:));

        % Fillplot
        str = sprintf('%s\\addplot[%s] table[%s] {%%\n%s};\n', ...
            str, opts_print(m2t,drawOpts,','), opts_print(m2t,tabOpts,','), table);
    end
end
% ==============================================================================
function [m2t, str] = drawHggroup(m2t, h)
% Octave doesn't have the handle() function, so there's no way to determine
% the nature of the plot anymore at this point.  Set to 'unknown' to force
% fallback handling. This produces something for bar plots, for example.
% #COMPLEX: big switch-case
    try
        cl = class(handle(h));
    catch %#ok
        cl = 'unknown';
    end

    switch(cl)
        case {'specgraph.barseries', 'matlab.graphics.chart.primitive.Bar'}
            % hist plots and friends
            [m2t, str] = drawBarseries(m2t, h);

        case {'specgraph.stemseries', 'matlab.graphics.chart.primitive.Stem'}
            % stem plots
            [m2t, str] = drawStemSeries(m2t, h);

        case {'specgraph.stairseries', 'matlab.graphics.chart.primitive.Stair'}
            % stair plots
            [m2t, str] = drawStairSeries(m2t, h);

        case {'specgraph.areaseries', 'matlab.graphics.chart.primitive.Area'}
            % scatter plots
            [m2t,str] = drawAreaSeries(m2t, h);

        case {'specgraph.quivergroup', 'matlab.graphics.chart.primitive.Quiver'}
            % quiver arrows
            [m2t, str] = drawQuiverGroup(m2t, h);

        case {'specgraph.errorbarseries', 'matlab.graphics.chart.primitive.ErrorBar'}
            % error bars
            [m2t,str] = drawErrorBars(m2t, h);

        case {'specgraph.scattergroup','matlab.graphics.chart.primitive.Scatter'}
            % scatter plots
            [m2t,str] = drawScatterPlot(m2t, h);
        
        case {'specgraph.contourgroup', 'matlab.graphics.chart.primitive.Contour'}
            [m2t,str] = drawContour(m2t, h);
            
        case {'hggroup', 'matlab.graphics.primitive.Group'}
            % handle all those the usual way
            [m2t, str] = handleAllChildren(m2t, h);

        case 'unknown'
            % Weird spurious class from Octave.
            [m2t, str] = handleAllChildren(m2t, h);

        otherwise
            userWarning(m2t, 'Don''t know class ''%s''. Default handling.', cl);
            try
                m2tBackup = m2t;
                [m2t, str] = handleAllChildren(m2t, h);
            catch ME
                userWarning(m2t, 'Default handling for ''%s'' failed. Continuing as if it did not occur. \n Original Message:\n %s', cl, getReport(ME));
                [m2t, str] = deal(m2tBackup, ''); % roll-back
            end
    end
end
% ==============================================================================
function m2t = drawAnnotations(m2t)
% Draws annotation in Matlab (Octave not supported).

% In HG1 annotations are children of an invisible axis called scribeOverlay.
% In HG2 annotations are children of annotationPane object which does not
% have any axis properties. Hence, we cannot simply handle it with a
% drawAxes() call.

    % Octave
    if strcmpi(getEnvironment,'Octave')
        return
    end

    % Get annotation handles
    if isHG2
        annotPanes   = findobj(m2t.currentHandles.gcf,'Tag','scribeOverlay');
        annotHandles = findobj(get(annotPanes,'Children'),'Visible','on');
    else
        annotHandles = findobj(m2t.scribeLayer,'-depth',1,'Visible','on');
    end

    % There are no anotations
    if isempty(annotHandles)
        return
    end

    % Create fake simplified axes overlay (no children)
    warning('off', 'matlab2tikz:NoChildren')
    scribeLayer = axes('Units','Normalized','Position',[0,0,1,1],'Visible','off');
    m2t         = drawAxes(m2t, scribeLayer);
    warning('on', 'matlab2tikz:NoChildren')

    % Plot in reverse to preserve z-ordering and assign the converted
    % annotations to the converted fake overlay
    for ii = numel(annotHandles):-1:1
        m2t = drawAnnotationsHelper(m2t,annotHandles(ii));
    end

    % Delete fake overlay graphics object
    delete(scribeLayer)
end
% ==============================================================================
function m2t = drawAnnotationsHelper(m2t,h)
    % Get class name
    try
        cl = class(handle(h));
    catch %#ok
        cl = 'unknown';
    end

    switch cl

        % Line
        case {'scribe.line', 'matlab.graphics.shape.Line'}
            [m2t, str] = drawLine(m2t, h);

        % Ellipse
        case {'scribe.scribeellipse','matlab.graphics.shape.Ellipse'}
            [m2t, str] = drawEllipse(m2t, h);

        % Arrows
        case {'scribe.arrow', 'scribe.doublearrow'}%,...
              %'matlab.graphics.shape.Arrow', 'matlab.graphics.shape.DoubleEndArrow'}
            % Annotation: single and double Arrow, line
            % TODO:
            % - write a drawArrow(). Handle all info info directly
            %   without using handleAllChildren() since HG2 does not have
            %   children (so no shortcut).
            % - It would be good if drawArrow() was callable on a
            %   matlab.graphics.shape.TextArrow object to draw the arrow
            %   part.
            [m2t, str] = handleAllChildren(m2t, h);

        % Text box
        case {'scribe.textbox','matlab.graphics.shape.TextBox'}
            [m2t, str] = drawText(m2t, h);

        % Tetx arrow
        case {'scribe.textarrow'}%,'matlab.graphics.shape.TextArrow'}
            % TODO: rewrite drawTextarrow. Handle all info info directly
            %       without using handleAllChildren() since HG2 does not
            %       have children (so no shortcut) as used for
            %       scribe.textarrow.
            [m2t, str] = drawTextarrow(m2t, h);

        % Rectangle
        case {'scribe.scriberect', 'matlab.graphics.shape.Rectangle'}
            [m2t, str] = drawRectangle(m2t, h);

        otherwise
            userWarning(m2t, 'Don''t know annotation ''%s''.', cl);
            return
    end

    % Add annotation to scribe overlay
    m2t.axesContainers{end} = addChildren(m2t.axesContainers{end}, str);
end
% ==============================================================================
function [m2t,str] = drawSurface(m2t, h)

    [m2t, opts, s] = shaderOpts(m2t, h,'surf');
    tabOpts = opts_new();

    % Allow for empty surf
    if isNone(s.plotType)
        str = '';
        return
    end

    [dx, dy, dz, numrows] = getXYZDataFromSurface(h);
    m2t = jumpAtUnboundCoords(m2t, [dx(:); dy(:); dz(:)]);

    [m2t, opts] = addZBufferOptions(m2t, h, opts);

    % Check if 3D
    is3D = m2t.axesContainers{end}.is3D;
    if is3D
        columnNames = {'x','y','z','c'};
        plotCmd     = 'addplot3';
        data        = applyHgTransform(m2t, [dx(:), dy(:), dz(:)]);
    else
        columnNames = {'x','y','c'};
        plotCmd     = 'addplot';
        data        = [dx(:), dy(:)];
    end

    % There are several possibilities of how colors are specified for surface
    % plots:
    %    * explicitly by RGB-values,
    %    * implicitly through a color map with a point-meta coordinate,
    %    * implicitly through a color map with a given coordinate (e.g., z).
    %

    % Check if we need extra CData.
    CData = get(h, 'CData');
    if length(size(CData)) == 3 && size(CData, 3) == 3

        % Create additional custom colormap
        nrows = size(data,1);
        CData = reshape(CData, nrows,3);
        m2t.axesContainers{end}.options(end+1,:) = ...
            {matlab2pgfplotsColormap(m2t, CData, 'patchmap'), []};

        % Index into custom colormap
        color = (0:nrows-1)';

        tabOpts = opts_add(tabOpts, 'colormap name','surfmap');
    else
        opts = opts_add(opts,matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap),'');
        % If NaNs are present in the color specifications, don't use them for
        % Pgfplots; they may be interpreted as strings there.
        % Note:
        % Pgfplots actually does a better job than MATLAB in determining what
        % colors to use for the patches. The circular test case on
        % http://www.mathworks.de/de/help/matlab/ref/pcolor.html, for example
        % yields a symmetric setup in Pgfplots (and doesn't in MATLAB).
        needsPointmeta = any(xor(isnan(dz(:)), isnan(CData(:)))) ...
            || any(abs(CData(:) - dz(:)) > 1.0e-10);
        if needsPointmeta
            color = CData(:);
        else
            color = dz(:);      % Fallback on the z-values, especially if 2D view
        end
    end
    tabOpts = opts_add(tabOpts, 'point meta','\thisrow{c}');

    data = [data, color];

    % Add mesh/rows=<num rows> for specifying the row data instead of empty
    % lines in the data list below. This makes it possible to reduce the
    % data writing to one single sprintf() call.
    opts = opts_add(opts,'mesh/rows',sprintf('%d', numrows));

    % Print the addplot options
    str = sprintf('\n\\%s[%%\n%s,\n%s]', plotCmd, s.plotType, opts_print(m2t, opts, ','));

    % Print the data
    [m2t, table, tabOptsExtra] = makeTable(m2t, columnNames, data);
    tabOpts = opts_merge(tabOptsExtra, tabOpts);

    % Here is where everything is put together
    str = sprintf('%s\ntable[%s] {%%\n%s};\n', ...
                  str, opts_print(m2t, tabOpts, ', '), table);

    % TODO:
    % - remove grids in spectrogram by either removing grid command
    %   or adding: 'grid=none' from/in axis options
    % - handling of huge data amounts in LaTeX.

    [m2t, str] = addLabel(m2t, str);
end
% ==============================================================================
function [m2t, opts] = addZBufferOptions(m2t, h, opts)
    % Enforce 'z buffer=sort' if shader is flat and is a 3D plot. It is to
    % avoid overlapping e.g. sphere plots and to properly mimic Matlab's
    % coloring of faces.
    % NOTE:
    % - 'z buffer=sort' is computationally more expensive for LaTeX, we
    %   could try to avoid it in some default situations, e.g. when dx and
    %   dy are rank-1-matrices.
    % - hist3D plots should not be z-sorted or the highest bars will cover
    %   the shortest one even if positioned in the back
    isShaderFlat = isempty(strfind(opts_get(opts, 'shader'), 'interp'));
    isHist3D     = strcmpi(get(h,'tag'), 'hist3');
    is3D         = m2t.axesContainers{end}.is3D;
    if is3D && isShaderFlat && ~isHist3D
        opts = opts_add(opts, 'z buffer', 'sort');
        % Pgfplots 1.12 contains a bug fix that fixes legend entries when
        % 'z buffer=sort' has been set. So, it's  easier to always require that
        % version anyway. See #504 for more information.
        m2t = needsPgfplotsVersion(m2t, [1,12]);
    end
end
% ==============================================================================
function [dx, dy, dz, numrows] = getXYZDataFromSurface(h)
% retrieves X, Y and Z data from a Surface plot. The data gets returned in a
% wastefull format where the dimensions of these data vectors is equal, akin
% to the format used by meshgrid.
    dx = get(h, 'XData');
    dy = get(h, 'YData');
    dz = get(h, 'ZData');
    [numcols, numrows] = size(dz);

    % If dx or dy are given as vectors, convert them to the (wasteful) matrix
    % representation first. This makes sure we can treat the data with one
    % single sprintf() command below.
    if isvector(dx)
        dx = ones(numcols,1) * dx(:)';
    end
    if isvector(dy)
        dy = dy(:) * ones(1,numrows);
    end
end
% ==============================================================================
function [m2t, str] = drawVisibleText(m2t, handle)
% Wrapper for drawText() that only draws visible text

    % There may be some text objects floating around a MATLAB figure which are
    % handled by other subfunctions (labels etc.) or don't need to be handled at
    % all.
    % The HandleVisibility says something about whether the text handle is
    % visible as a data structure or not. Typically, a handle is hidden if the
    % graphics aren't supposed to be altered, e.g., axis labels.  Most of those
    % entities are captured by matlab2tikz one way or another, but sometimes they
    % are not. This is the case, for example, with polar plots and the axis
    % descriptions therein.  Also, Matlab treats text objects with a NaN in the
    % position as invisible.
    if any(isnan(get(handle, 'Position')) | isnan(get(handle, 'Rotation'))) ...
            || strcmpi(get(handle, 'Visible'), 'off') ...
            || (strcmpi(get(handle, 'HandleVisibility'), 'off') && ...
                ~m2t.cmdOpts.Results.showHiddenStrings)

        str = '';
        return;
    end

    [m2t, str] = drawText(m2t, handle);

end
% ==============================================================================
function [m2t, str] = drawText(m2t, handle)
% Adding text node anywhere in the axes environment.
% Not that, in Pgfplots, long texts get cut off at the axes. This is
% Different from the default MATLAB behavior. To fix this, one could use
% /pgfplots/after end axis/.code.

    str = '';

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % get required properties
    String = get(handle, 'String');
    Interpreter = get(handle, 'Interpreter');
    String = prettyPrint(m2t, String, Interpreter);
    % Concatenate multiple lines
    String = join(m2t, String, '\\');
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % translate them to pgf style
    style = opts_new();

    bgColor = get(handle,'BackgroundColor');
    [m2t, style] = setColor(m2t, handle, style, 'fill', bgColor);

    style = getXYAlignmentOfText(handle, style);

    style = getRotationOfText(m2t, handle, style);

    style = opts_merge(style, getFontStyle(m2t, handle));

    color  = get(handle, 'Color');
    [m2t, tcolor] = getColor(m2t, handle, color, 'patch');
    style = opts_add(style, 'text', tcolor);

    EdgeColor = get(handle, 'EdgeColor');
    [m2t, style] = setColor(m2t, handle, style, 'draw', EdgeColor);

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % plot the thing
    [m2t, posString] = getPositionOfText(m2t, handle);

    str = sprintf('\\node[%s]\nat %s {%s};\n', ...
        opts_print(m2t, style, ', '), posString, String);
end
% ==============================================================================
function [style] = getXYAlignmentOfText(handle, style)
% sets the horizontal and vertical alignment options of a text object
    VerticalAlignment = get(handle, 'VerticalAlignment');
    HorizontalAlignment = get(handle, 'HorizontalAlignment');

    horizontal = '';
    vertical   = '';
    switch VerticalAlignment
        case {'top', 'cap'}
            vertical = 'below';
        case {'baseline', 'bottom'}
            vertical = 'above';
    end
    switch HorizontalAlignment
        case 'left'
            horizontal = 'right';
        case 'right'
            horizontal = 'left';
    end
    alignment = strtrim(sprintf('%s %s', vertical, horizontal));
    if ~isempty(alignment)
         style = opts_add(style, alignment);
    end

    % Set 'align' option that is needed for multiline text
    style = opts_add(style, 'align', HorizontalAlignment);
end
% ==============================================================================
function [style] = getRotationOfText(m2t, handle, style)
% Add rotation, if existing
    defaultRotation = 0.0;
    rot = getOrDefault(handle, 'Rotation', defaultRotation);
    if rot ~= defaultRotation
        style = opts_add(style, 'rotate', sprintf(m2t.ff, rot));
    end
end
% ==============================================================================
function [m2t,posString] = getPositionOfText(m2t, h)
% makes the tikz position string of a text object
    pos   = get(h, 'Position');
    units = get(h, 'Units');
    is3D  = m2t.axesContainers{end}.is3D;

    % Deduce if text or textbox
    type = get(h,'type');
    if isempty(type) || strcmpi(type,'hggroup')
        type = get(h,'ShapeType'); % Undocumented property valid from 2008a
    end

    switch type
        case 'text'
            if is3D
                pos  = applyHgTransform(m2t, pos);
                npos = 3;
            else
                pos  = pos(1:2);
                npos = 2;
            end
        case {'textbox','textboxshape'}
            % TODO:
            %   - size of the box (e.g. using node attributes minimum width / height)
            %   - Alignment of the resized box
            pos  = pos(1:2);
            npos = 2;

        otherwise
            error('matlab2tikz:drawText', 'Unrecognized text type: %s.', type);
    end

    % Format according to units
    switch units
        case 'normalized'
            type    = 'rel axis cs:';
            fmtUnit = '';
        case 'data'
            type    = 'axis cs:';
            fmtUnit = '';
        % Let Matlab do the conversion of any unit into cm
        otherwise
            type    = '';
            fmtUnit = 'cm';
            if ~strcmpi(units, 'centimeters')
                % Save old pos, set units to cm, query pos, reset
                % NOTE: cannot use copyobj since it is buggy in R2014a, see
                %       http://www.mathworks.com/support/bugreports/368385
                oldPos = get(h, 'Position');
                set(h,'Units','centimeters')
                pos    = get(h, 'Position');
                pos    = pos(1:npos);
                set(h,'Units',units,'Position',oldPos)
            end
    end
    posString = cell(1,npos);
    for ii = 1:npos
        posString{ii} = formatDim(pos(ii), fmtUnit);
    end

    posString = sprintf('(%s%s)',type,join(m2t,posString,','));
    m2t = disableClippingInCurrentAxes(m2t, pos);

end
% ==============================================================================
function m2t = disableClippingInCurrentAxes(m2t, pos)
% Disables clipping in the current axes if the `pos` vector lies outside
% the limits of the axes.
    xlim  = getOrDefault(m2t.currentHandles.gca, 'XLim',[-Inf +Inf]);
    ylim  = getOrDefault(m2t.currentHandles.gca, 'YLim',[-Inf +Inf]);
    zlim  = getOrDefault(m2t.currentHandles.gca, 'ZLim',[-Inf +Inf]);
    is3D  = m2t.axesContainers{end}.is3D;

    xOutOfRange =          pos(1) < xlim(1) || pos(1) > xlim(2);
    yOutOfRange =          pos(2) < ylim(1) || pos(2) > ylim(2);
    zOutOfRange = is3D && (pos(3) < zlim(1) || pos(3) > zlim(2));
    if xOutOfRange || yOutOfRange || zOutOfRange
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'clip', 'false');
    end
end
% ==============================================================================
function [m2t, str] = drawRectangle(m2t, h)
    str = '';

    % there may be some text objects floating around a Matlab figure which
    % are handled by other subfunctions (labels etc.) or don't need to be
    % handled at all
    if ~isVisible(h) || strcmpi(get(h, 'HandleVisibility'), 'off')
        return;
    end

    % TODO handle Curvature = [0.8 0.4]

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Get draw options.
    lineStyle = get(h, 'LineStyle');
    lineWidth = get(h, 'LineWidth');

    drawOptions = getLineOptions(m2t, lineStyle, lineWidth);

    [m2t, drawOptions] = getRectangleFaceOptions(m2t, h, drawOptions);
    [m2t, drawOptions] = getRectangleEdgeOptions(m2t, h, drawOptions);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    pos = pos2dims(get(h, 'Position'));
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % plot the thing
    str = sprintf(['\\draw[%s] (axis cs:',m2t.ff,',',m2t.ff, ')', ...
                   ' rectangle (axis cs:',m2t.ff,',',m2t.ff,');\n'], ...
                  opts_print(m2t, drawOptions, ', '), ...
                  pos.left, pos.bottom, pos.right, pos.top);
end
% ==============================================================================
function [m2t, drawOptions] = getRectangleFaceOptions(m2t, h, drawOptions)
% draws the face (i.e. fill) of a Rectangle
    faceColor    = get(h, 'FaceColor');
    isAnnotation = strcmpi(get(h,'type'),'rectangleshape') || ...
                   strcmpi(getOrDefault(h,'ShapeType',''),'rectangle');
    isFlatColor  = strcmpi(faceColor, 'flat');
    if ~(isNone(faceColor) || (isAnnotation && isFlatColor))
        [m2t, xFaceColor] = getColor(m2t, h, faceColor, 'patch');
        drawOptions = opts_add(drawOptions, 'fill', xFaceColor);
    end
end
% ==============================================================================
function [m2t, drawOptions] = getRectangleEdgeOptions(m2t, h, drawOptions)
% draws the edges of a rectangle
    edgeColor = get(h, 'EdgeColor');
    lineStyle = get(h, 'LineStyle');
    if isNone(lineStyle) || isNone(edgeColor)
        drawOptions = opts_add(drawOptions, 'draw', 'none');
    else
        [m2t, drawOptions] = setColor(m2t, h, drawOptions, 'draw', edgeColor);
    end
end
% ==============================================================================
function [m2t,opts,s] = shaderOpts(m2t, handle, selectedType)
% SHADEROPTS Returns the shader, fill and draw options for patches, surfs and meshes
%
%   SHADEROPTS(M2T, HANDLE, SELECTEDTYPE) Where SELECTEDTYPE should either
%   be 'surf' or 'patch'
%
%
%   [...,OPTS, S] = SHADEROPTS(...)
%       OPTS is a M by 2 cell array with Key/Value pairs
%       S is a struct with fields, e.g. 'faceColor', to be re-used by the
%       caller

    % Initialize
    opts              = opts_new;
    s.hasOneEdgeColor = false;
    s.hasOneFaceColor = false;

    % Get relevant Face and Edge color properties
    s.faceColor = get(handle, 'FaceColor');
    s.edgeColor = get(handle, 'EdgeColor');

    if isNone(s.faceColor) && isNone(s.edgeColor)
        s.plotType        = 'none';
        s.hasOneEdgeColor = true;
    elseif isNone(s.faceColor)
        s.plotType        = 'mesh';
        s.hasOneFaceColor = true;
        [m2t, opts, s]    = shaderOptsMesh(m2t, handle, opts, s);
    else
        s.plotType     = selectedType;
        [m2t, opts, s] = shaderOptsSurfPatch(m2t, handle, opts, s);
    end
end
% ==============================================================================
function [m2t, opts, s] = shaderOptsMesh(m2t, handle, opts, s)

    % Edge 'interp'
    if strcmpi(s.edgeColor, 'interp')
        opts = opts_add(opts,'shader','flat');

    % Edge RGB
    else
        s.hasOneEdgeColor = true;
        [m2t, xEdgeColor] = getColor(m2t, handle, s.edgeColor, 'patch');
        opts              = opts_add(opts,'color',xEdgeColor);
    end
end
% ==============================================================================
function [m2t, opts, s] = shaderOptsSurfPatch(m2t, handle, opts, s)
% gets the shader options for surface patches

    % Set opacity if FaceAlpha < 1 in MATLAB
    s.faceAlpha = get(handle, 'FaceAlpha');
    if isnumeric(s.faceAlpha) && s.faceAlpha ~= 1.0
        opts = opts_add(opts,'fill opacity',sprintf(m2t.ff,s.faceAlpha));
    end

    % Set opacity if EdgeAlpha < 1 in MATLAB
    s.edgeAlpha = get(handle, 'EdgeAlpha');
    if isnumeric(s.edgeAlpha) && s.edgeAlpha ~= 1.0
        opts = opts_add(opts,'draw opacity',sprintf(m2t.ff,s.edgeAlpha));
    end

    if isNone(s.edgeColor) % Edge 'none'
        [m2t, opts, s] = shaderOptsSurfPatchEdgeNone(m2t, handle, opts, s);
        
    elseif strcmpi(s.edgeColor, 'interp') % Edge 'interp'
        [m2t, opts, s] = shaderOptsSurfPatchEdgeInterp(m2t, handle, opts, s);

    elseif strcmpi(s.edgeColor, 'flat') % Edge 'flat'
        [m2t, opts, s] = shaderOptsSurfPatchEdgeFlat(m2t, handle, opts, s);

    else % Edge RGB
        [m2t, opts, s] = shaderOptsSurfPatchEdgeRGB(m2t, handle, opts, s);
    end
end
% ==============================================================================
function [m2t, opts, s] = shaderOptsSurfPatchEdgeNone(m2t, handle, opts, s)
% gets the shader options for surface patches without edges
    s.hasOneEdgeColor = true; % consider void as true
    if strcmpi(s.faceColor, 'flat')
        opts = opts_add(opts,'shader','flat');
    elseif strcmpi(s.faceColor, 'interp');
        opts = opts_add(opts,'shader','interp');
    else
        s.hasOneFaceColor = true;
        [m2t,xFaceColor]  = getColor(m2t, handle, s.faceColor, 'patch');
        opts              = opts_add(opts,'fill',xFaceColor);
    end
end
function [m2t, opts, s] = shaderOptsSurfPatchEdgeInterp(m2t, handle, opts, s)
% gets the shader options for surface patches with interpolated edge colors  
    if strcmpi(s.faceColor, 'interp')
        opts = opts_add(opts,'shader','interp');
    elseif strcmpi(s.faceColor, 'flat')
        opts = opts_add(opts,'shader','faceted');
    else
        s.hasOneFaceColor = true;
        [m2t,xFaceColor]  = getColor(m2t, handle, s.faceColor, 'patch');
        opts              = opts_add(opts,'fill',xFaceColor);
    end
end
function [m2t, opts, s] = shaderOptsSurfPatchEdgeFlat(m2t, handle, opts, s)
% gets the shader options for surface patches with flat edge colors, i.e. the
% vertex color
    if strcmpi(s.faceColor, 'flat')
        opts = opts_add(opts,'shader','flat corner');
    elseif strcmpi(s.faceColor, 'interp')
        opts = opts_add(opts,'shader','faceted interp');
    else
        s.hasOneFaceColor = true;
        opts              = opts_add(opts,'shader','flat corner');
        [m2t,xFaceColor]  = getColor(m2t, handle, s.faceColor, 'patch');
        opts              = opts_add(opts,'fill',xFaceColor);
    end
end
function [m2t, opts, s] = shaderOptsSurfPatchEdgeRGB(m2t, handle, opts, s)
% gets the shader options for surface patches with fixed (RGB) edge color
    s.hasOneEdgeColor = true;
    [m2t, xEdgeColor] = getColor(m2t, handle, s.edgeColor, 'patch');
    if isnumeric(s.faceColor)
        s.hasOneFaceColor = true;
        [m2t, xFaceColor] = getColor(m2t, handle, s.faceColor, 'patch');
        opts              = opts_add(opts,'fill',xFaceColor);
        opts              = opts_add(opts,'faceted color',xEdgeColor);
    elseif strcmpi(s.faceColor,'interp')
        opts = opts_add(opts,'shader','faceted interp');
        opts = opts_add(opts,'faceted color',xEdgeColor);
    else
        opts = opts_add(opts,'shader','flat corner');
        opts = opts_add(opts,'draw',xEdgeColor);
    end
end
% ==============================================================================
function [m2t, str] = drawScatterPlot(m2t, h)
    str = '';

    xData = get(h, 'XData');
    yData = get(h, 'YData');
    zData = get(h, 'ZData');
    cData = get(h, 'CData');
    sData = get(h, 'SizeData');

    matlabMarker = get(h, 'Marker');
    markerFaceColor = get(h, 'MarkerFaceColor');
    markerEdgeColor = get(h, 'MarkerEdgeColor');
    hasFaceColor = ~isNone(markerFaceColor);
    hasEdgeColor = ~isNone(markerEdgeColor);
    markOptions = opts_new();
    [tikzMarker, markOptions] = translateMarker(m2t, matlabMarker, ...
        markOptions, hasFaceColor);

    constMarkerkSize = length(sData) == 1; % constant marker size

    % Rescale marker size (not definitive, follow discussion in #316)
    sData = translateMarkerSize(m2t, matlabMarker, sqrt(sData)/2);

    drawOptions = opts_new();
    if length(cData) == 3
        [m2t, drawOptions] = getScatterOptsOneColor(m2t, h, drawOptions, ...
                                                markOptions, tikzMarker, ...
                                                cData, sData, constMarkerkSize);
    elseif size(cData,2) == 3
        drawOptions = getScatterOptsRGB(m2t, drawOptions);
    else
        [m2t, drawOptions] = getScatterOptsColormap(m2t, h, drawOptions, ...
                           markOptions, tikzMarker, hasEdgeColor, hasFaceColor);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Plot the thing.
    [env, data, sColumn] = organizeScatterData(m2t, xData, yData, zData, sData);

    if ~constMarkerkSize %
        drawOptions = opts_add(drawOptions, 'visualization depends on', ...
            ['{\thisrowno{', num2str(sColumn), '} \as \perpointmarksize}']);
        drawOptions = opts_add(drawOptions, ...
            'scatter/@pre marker code/.append style', ...
            '{/tikz/mark size=\perpointmarksize}');
    end
    drawOpts = opts_print(m2t, drawOptions, ',');

    [data, metaPart] = addCDataToScatterData(data, cData);

    % The actual printing.
    nColumns = size(data, 2);
    [m2t, table, tabOpts] = makeTable(m2t, repmat({''},1,nColumns), data);
    tabOpts = opts_merge(tabOpts, metaPart);

    str = sprintf('%s\\%s[%s] plot table[%s]{%s};\n', str, env, ...
        drawOpts, opts_print(m2t, tabOpts, ','), table);
end
% ==============================================================================
function [m2t, drawOptions] = getScatterOptsOneColor(m2t, h, drawOptions, ...
                        markOptions, tikzMarker, cData, sData, constMarkerkSize)
% gets options specific to scatter plots with a single color
    % No special treatment for the colors or markers are needed.
    % All markers have the same color.
    [m2t, xcolor, hasFaceColor] = getColorOfMarkers(m2t, h, 'MarkerFaceColor', cData);
    [m2t, ecolor, hasEdgeColor] = getColorOfMarkers(m2t, h, 'MarkerEdgeColor', cData);
    
    if constMarkerkSize
        drawOptions = opts_add(drawOptions, 'only marks');
        drawOptions = opts_add(drawOptions, 'mark', tikzMarker);
        drawOptions = opts_add(drawOptions, 'mark options', ...
            ['{' opts_print(m2t, markOptions, ',') '}']);
        drawOptions = opts_add(drawOptions, 'mark size', ...
            sprintf('%.4fpt', sData)); % FIXME: investigate whether to use `m2t.ff`
        if hasFaceColor && hasEdgeColor
            drawOptions = opts_add(drawOptions, 'draw', ecolor);
            drawOptions = opts_add(drawOptions, 'fill', xcolor);
        else
            drawOptions = opts_add(drawOptions, 'color', xcolor);
        end
    else % if changing marker size but same color on all marks
        markerOptions = opts_new();
        markerOptions = opts_add(markerOptions, 'mark', tikzMarker);
        markerOptions = opts_add(markerOptions, 'mark options', ...
            ['{' opts_print(m2t, markOptions, ',') '}']);
        if hasEdgeColor
            markerOptions = opts_add(markerOptions, 'draw', ecolor);
        else
            markerOptions = opts_add(markerOptions, 'draw', xcolor);
        end
        if hasFaceColor
            markerOptions = opts_add(markerOptions, 'fill', xcolor);
        end
        % for changing marker size, the 'scatter' option has to be added
        
        drawOptions = opts_add(drawOptions, 'scatter');
        drawOptions = opts_add(drawOptions, 'only marks');
        drawOptions = opts_add(drawOptions, 'color', xcolor);
        drawOptions = opts_add(drawOptions, 'mark', tikzMarker);
        drawOptions = opts_add(drawOptions, 'mark options', ...
            ['{' opts_print(m2t, markOptions, ',') '}']);
        
        if ~hasFaceColor
            drawOptions = opts_add(drawOptions, ...
                'scatter/use mapped color', xcolor);
        else
            drawOptions = opts_add(drawOptions, ...
                'scatter/use mapped color', ...
                ['{' opts_print(m2t, markerOptions,',') '}']);
        end
    end
end
function drawOptions = getScatterOptsRGB(m2t, drawOptions)
% scatter plots with each marker a different RGB color (not yet supported!)
    drawOptions = opts_add(drawOptions, 'only marks');
    userWarning(m2t, 'Pgfplots cannot handle RGB scatter plots yet.');
    % TODO Get this in order as soon as Pgfplots can do "scatter rgb".
    % See e.g. http://tex.stackexchange.com/questions/197270 and #433
end
function [m2t, drawOptions] = getScatterOptsColormap(m2t, h, drawOptions, ...
                            markOptions, tikzMarker, hasEdgeColor, hasFaceColor)
% scatter plot where the colors are set using a color map
    markerOptions = opts_new();
    markerOptions = opts_add(markerOptions, 'mark', tikzMarker);
    markerOptions = opts_add(markerOptions, 'mark options', ...
        ['{' opts_print(m2t, markOptions, ',') '}']);
    
    if hasEdgeColor && hasFaceColor
        [m2t, ecolor] = getColor(m2t, h, markerEdgeColor,'patch');
        markerOptions = opts_add(markerOptions, 'draw', ecolor);
    else
        markerOptions = opts_add(markerOptions, 'draw', 'mapped color');
    end
    if hasFaceColor
        markerOptions = opts_add(markerOptions, 'fill', 'mapped color');
    end
    drawOptions = opts_add(drawOptions, 'scatter');
    drawOptions = opts_add(drawOptions, 'only marks');
    drawOptions = opts_add(drawOptions, 'scatter src', 'explicit');
    drawOptions = opts_add(drawOptions, 'scatter/use mapped color', ...
        ['{' opts_print(m2t, markerOptions, ',') '}']);
    % Add color map.
    m2t.axesContainers{end}.options = opts_append(...
        m2t.axesContainers{end}.options, ...
        matlab2pgfplotsColormap(m2t, m2t.currentHandles.colormap), []);
end
% ==============================================================================
function [env, data, sColumn] = organizeScatterData(m2t, xData, yData, zData, sData)
% reorganizes the {X,Y,Z,S} data into a single matrix
    sColumn = [];
    if ~m2t.axesContainers{end}.is3D
        env = 'addplot';
        if length(sData) == 1
            data = [xData(:), yData(:)];
        else
            sColumn = 2;
            data = [xData(:), yData(:), sData(:)];
        end
    else
        env = 'addplot3';
        if length(sData) == 1
            data = applyHgTransform(m2t, [xData(:),yData(:),zData(:)]);
        else
            sColumn = 3;
            data = applyHgTransform(m2t, [xData(:),yData(:),zData(:),sData(:)]);
        end
    end
end
% ==============================================================================
function [data, metaOptions] = addCDataToScatterData(data, cData)
% adds the cData vector to the data table of a scatter plot
    metaOptions = opts_new();
    if length(cData) == 3
        % If size(cData,1)==1, then all the colors are the same and have
        % already been accounted for above.

    elseif size(cData,2) == 3
        %TODO Hm, can't deal with this?
        %[m2t, col] = rgb2colorliteral(m2t, cData(k,:));
        %str = strcat(str, sprintf(' [%s]\n', col));
    else
        metaOptions = opts_add(metaOptions, ...
                               'meta index', sprintf('%d', size(data,2)));
        data = [data, cData(:)];
    end
end
% ==============================================================================
function [m2t, xcolor, hasColor] = getColorOfMarkers(m2t, h, name, cData)
    color = get(h, name);
    hasColor = ~isNone(color);
    if hasColor && ~strcmpi(color,'flat');
        [m2t, xcolor] = getColor(m2t, h, color, 'patch');
    else
        [m2t, xcolor] = getColor(m2t, h, cData, 'patch');
    end
end
% ==============================================================================
function [m2t, str] = drawHistogram(m2t, h)

    if ~isVisible(h)
        str = '';
        return;
    end

    % Init options
    opts = opts_new();

    % Face
    faceColor = get(h,'FaceColor');
    [m2t, opts] = setColor(m2t, h, opts, 'fill', faceColor, 'none');

    % FaceAlpha
    faceAlpha = get(h, 'FaceAlpha');
    if ~isNone(faceColor) && isnumeric(faceAlpha) && faceAlpha ~= 1.0
        opts = opts_add(opts,'fill opacity', sprintf(m2t.ff,faceAlpha));
    end

    % Edge
    edgeColor = get(h, 'EdgeColor');
    [m2t, opts] = setColor(m2t, h, opts, 'draw', edgeColor, 'none');

    % Data
    binEdges = get(h, 'BinEdges');
    binValue = get(h, 'Values');
    data     = [binEdges(:), [binValue(:); binValue(end)]];

    % Bar type (depends on orientation)
    isVertical = strcmpi(get(h,'Orientation'),'vertical');
    if isVertical
        opts = opts_add(opts, 'ybar interval');
    else
        opts = opts_add(opts, 'xbar interval');
        data = fliplr(data);
    end

    % Make table
    [m2t, table, tableOptions] = makeTable(m2t, {'x','y'},data);

    % Add 'area legend' (x/ybar interval legend do not seem to work)
    opts = opts_add(opts, 'area legend');

    % Print out
    drawOpts = opts_print(m2t, opts, ',');
    tabOpts = opts_print(m2t, tableOptions, ',');
    str      = sprintf('\\addplot[%s] plot table[%s] {%s};\n', ...
                       drawOpts, tabOpts, table);
end
% ==============================================================================
function [m2t, str] = drawBarseries(m2t, h)
% Takes care of plots like the ones produced by MATLAB's hist.
% The main pillar is Pgfplots's '{x,y}bar' plot.
%
% TODO Get rid of code duplication with 'drawAxes'.

    str = '';

    if ~isVisible(h)
        return; % don't bother drawing invisible things
    end

    % Add 'log origin = infty' if BaseValue differs from zero (log origin=0 is
    % the default behaviour since Pgfplots v1.5).
    baseValue = get(h, 'BaseValue');
    if baseValue ~= 0.0
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, ...
            'log origin', 'infty');
        %TODO: wait for pgfplots to implement other base values (see #438)
    end

    xData = get(h, 'XData');
    yData = get(h, 'YData');

    % init drawOptions
    drawOptions = opts_new();

    [barType, isHoriz] = getOrientationOfBarSeries(h);
    [m2t, drawOptions] = setBarLayoutOfBarSeries(m2t, h, barType, drawOptions);

    % define edge color
    edgeColor = get(h, 'EdgeColor');
    lineStyle = get(h, 'LineStyle');
    if isNone(lineStyle)
        drawOptions = opts_add(drawOptions, 'draw', 'none');
    else
        [m2t, drawOptions] = setColor(m2t, h, drawOptions, 'draw', ...
            edgeColor, 'none');
    end

    [m2t, drawOptions] = getFaceColorOfBar(m2t, h, drawOptions);

    % Add 'area legend' to the options as otherwise the legend indicators
    % will just highlight the edges.
    drawOptions = opts_add(drawOptions, 'area legend');

    % plot the thing
    if isHoriz
        [yDataPlot, xDataPlot] = deal(xData, yData); % swap values
    else
        [xDataPlot, yDataPlot] = deal(xData, yData);
    end

    [m2t, table, tabOpts] = makeTable(m2t, '', xDataPlot, '', yDataPlot);
    str = sprintf('\\addplot[%s] plot table[%s] {%s};\n', ...
                 opts_print(m2t, drawOptions, ','), ...
                 opts_print(m2t, tabOpts, ','), table);
end
% ==============================================================================
function [barType, isHorizontal] = getOrientationOfBarSeries(h)
% determines the orientation (horizontal/vertical) of a BarSeries object
    isHorizontal = strcmpi(get(h, 'Horizontal'), 'on');
    if isHorizontal
        barType = 'xbar';
    else
        barType = 'ybar';
    end
end
% ==============================================================================
function [m2t, drawOptions] = setBarLayoutOfBarSeries(m2t, h, barType, drawOptions)
% sets the options specific to a bar layour (grouped vs stacked)
    barlayout = get(h, 'BarLayout');
    switch barlayout
        case 'grouped'  % grouped bar plots

            % Get number of bars series and bar series id
            [numBarSeries, barSeriesId] = getNumBarAndId(h);

            % Maximum group width relative to the minimum distance between two
            % x-values. See <MATLAB>/toolbox/matlab/specgraph/makebars.m
            maxGroupWidth = 0.8;
            if numBarSeries == 1
                groupWidth = 1.0;
            else
                groupWidth = min(maxGroupWidth, numBarSeries/(numBarSeries+1.5));
            end

            % Calculate the width of each bar and the center point shift as in
            % makebars.m
            % Get the shifts of the bar centers.
            % In case of numBars==1, this returns 0,
            % In case of numBars==2, this returns [-1/4, 1/4],
            % In case of numBars==3, this returns [-1/3, 0, 1/3],
            % and so forth.
            assumedBarWidth = groupWidth/numBarSeries; % assumption
            barShift        = (barSeriesId - 0.5) * assumedBarWidth - groupWidth/2;

            % From http://www.mathworks.com/help/techdoc/ref/bar.html:
            % bar(...,width) sets the relative bar width and controls the
            % separation of bars within a group. The default width is 0.8, so if
            % you do not specify X, the bars within a group have a slight
            % separation. If width is 1, the bars within a group touch one
            % another. The value of width must be a scalar.
            barWidth = get(h, 'BarWidth') * assumedBarWidth;

            % Bar type
            drawOptions = opts_add(drawOptions, barType);

            % Bar width
            drawOptions = opts_add(drawOptions, 'bar width', ...
                                 formatDim(barWidth, ''));
            % Bar shift
            if barShift ~= 0
                drawOptions = opts_add(drawOptions, 'bar shift', ...
                                 formatDim(barShift, ''));
            end

        case 'stacked' % stacked plots
            % Pass option to parent axis & disallow anything but stacked plots
            % Make sure this happens exactly *once*.

            if ~m2t.axesContainers{end}.barAddedAxisOption;
                barWidth = get(h, 'BarWidth');
                m2t.axesContainers{end}.options = ...
                    opts_add(m2t.axesContainers{end}.options, ...
                    'bar width', formatDim(barWidth,''));
                m2t.axesContainers{end}.barAddedAxisOption = true;
            end

            % Somewhere between pgfplots 1.5 and 1.8 and starting
            % again from 1.11, the option {x|y}bar stacked can be applied to
            % \addplot instead of the figure and thus allows to combine stacked
            % bar plots and other kinds of plots in the same axis.
            % Thus, it is advisable to use pgfplots 1.11. In older versions, the
            % plot will only contain a single bar series, but should compile fine.
            m2t = needsPgfplotsVersion(m2t, [1,11]);
            drawOptions = opts_add(drawOptions, [barType ' stacked']);
        otherwise
            error('matlab2tikz:drawBarseries', ...
                'Don''t know how to handle BarLayout ''%s''.', barlayout);
    end
end
% ==============================================================================
function [numBarSeries, barSeriesId] = getNumBarAndId(h)
% Get number of bars series and bar series id
    prop         = switchMatOct('BarPeers', 'bargroup');
    bargroup     = get(h, prop);
    numBarSeries = numel(bargroup);

    if isHG2
        % In HG2, BarPeers are sorted in reverse order wrt HG1
        bargroup = bargroup(end:-1:1);

    elseif strcmpi(getEnvironment, 'MATLAB')
        % In HG1, h is a double but bargroup a graphic object. Cast h to a
        % graphic object
        h = handle(h);

    else
        % In Octave, the bargroup is a replicated cell array. Pick first
        bargroup = bargroup{1};
    end

    % Get bar series Id
    [dummy, barSeriesId] = ismember(h, bargroup);
end
% ==============================================================================
function [m2t, drawOptions] = getFaceColorOfBar(m2t, h, drawOptions)
% retrieve the FaceColor of a barseries object
    if ~isempty(get(h,'Children'))
        % quite oddly, before MATLAB R2014b this value is stored in a child
        % patch and not in the object itself
        obj = get(h, 'Children');
    else % R2014b and newer
        obj = h;
    end
    faceColor = get(obj, 'FaceColor');
    [m2t, drawOptions] = setColor(m2t, h, drawOptions, 'fill', faceColor);
end
% ==============================================================================
function [m2t, str] = drawStemSeries(m2t, h)
    [m2t, str] = drawStemOrStairSeries_(m2t, h, 'ycomb');
end
function [m2t, str] = drawStairSeries(m2t, h)
    [m2t, str] = drawStemOrStairSeries_(m2t, h, 'const plot');
end
function [m2t, str] = drawStemOrStairSeries_(m2t, h, plotType)
    str = '';

    lineStyle = get(h, 'LineStyle');
    lineWidth = get(h, 'LineWidth');
    marker    = get(h, 'Marker');

    if (isNone(lineStyle) || lineWidth==0) && isNone(marker)
        return % nothing to plot!
    end

    % deal with draw options
    color = get(h, 'Color');
    [m2t, plotColor] = getColor(m2t, h, color, 'patch');

    lineOptions = getLineOptions(m2t, lineStyle, lineWidth);
    [m2t, markerOptions] = getMarkerOptions(m2t, h);

    drawOptions = opts_new();
    drawOptions = opts_add(drawOptions, plotType);
    drawOptions = opts_add(drawOptions, 'color', plotColor);
    drawOptions = opts_merge(drawOptions, lineOptions, markerOptions);

    % Toggle legend entry
    drawOptions = maybeShowInLegend(m2t.currentHandleHasLegend, drawOptions);

    % insert draw options
    drawOpts = opts_print(m2t, drawOptions, ',');

    % plot the thing
    xData = get(h, 'XData');
    yData = get(h, 'YData');
    [m2t, table, tabOpts] = makeTable(m2t, '', xData, '', yData);

    str = sprintf('%s\\addplot[%s] plot table[%s] {%s};\n', ...
        str, drawOpts, opts_print(m2t, tabOpts, ','), table);
end
% ==============================================================================
function [m2t, str] = drawAreaSeries(m2t, h)
% Takes care of MATLAB's stem plots.
%
% TODO Get rid of code duplication with 'drawAxes'.

    str = '';

    if ~isfield(m2t, 'addedAreaOption') || isempty(m2t.addedAreaOption) || ~m2t.addedAreaOption
        % Add 'area style' to axes options.
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'area style');
        m2t.axesContainers{end}.options = ...
            opts_add(m2t.axesContainers{end}.options, 'stack plots', 'y');
        m2t.addedAreaOption = true;
    end

    % Handle draw options.
    % define edge color
    drawOptions = opts_new();
    edgeColor = get(h, 'EdgeColor');
    [m2t, xEdgeColor] = getColor(m2t, h, edgeColor, 'patch');
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % define face color;
    if ~isempty(get(h,'Children'))
        % quite oddly, before MATLAB R2014b this value is stored in a child
        % patch and not in the object itself
        obj = get(h, 'Children');
    else % R2014b and newer
        obj = h;
    end
    faceColor = get(obj, 'FaceColor');
    [m2t, xFaceColor] = getColor(m2t, h, faceColor, 'patch');
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % gather the draw options
    lineStyle = get(h, 'LineStyle');
    drawOptions = opts_add(drawOptions, 'fill', xFaceColor);
    if isNone(lineStyle)
        drawOptions = opts_add(drawOptions, 'draw', 'none');
    else
        drawOptions = opts_add(drawOptions, 'draw', xEdgeColor);
    end

    % Toggle legend entry
    drawOptions = maybeShowInLegend(m2t.currentHandleHasLegend, drawOptions);

    drawOpts = opts_print(m2t, drawOptions, ',');

    % plot the thing
    xData = get(h, 'XData');
    yData = get(h, 'YData');
    [m2t, table, tabOpts] = makeTable(m2t, '', xData, '', yData);
    str = sprintf('%s\\addplot[%s] plot table[%s]{%s}\n\\closedcycle;\n',...
        str, drawOpts, opts_print(m2t, tabOpts, ','), table);
end
% ==============================================================================
function [m2t, str] = drawQuiverGroup(m2t, h)
% Takes care of MATLAB's quiver plots.

    % used for arrow styles, in case there are more than one quiver fields
    m2t.quiverId = m2t.quiverId + 1;

    str = '';

    [x,y,z,u,v,w] = getAndRescaleQuivers(m2t,h);
    is3D = m2t.axesContainers{end}.is3D;

    % prepare output
    if is3D
        name = 'addplot3';
        format = [m2t.ff,',',m2t.ff,',',m2t.ff];
    else % 2D plotting
        name   = 'addplot';
        format = [m2t.ff,',',m2t.ff];
    end

    data = NaN(6,numel(x));
    data(1,:) = x;
    data(2,:) = y;
    data(3,:) = z;
    data(4,:) = x + u;
    data(5,:) = y + v;
    data(6,:) = z + w;

    if ~is3D
        data([3 6],:) = []; % remove Z-direction
    end

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % gather the arrow options
    showArrowHead = get(h, 'ShowArrowHead');
    lineStyle     = get(h, 'LineStyle');
    lineWidth     = get(h, 'LineWidth');

    if (isNone(lineStyle) || lineWidth==0)  && ~showArrowHead
        return
    end

    arrowOpts = opts_new();
    if showArrowHead
        arrowOpts = opts_add(arrowOpts, '->');
    else
        arrowOpts = opts_add(arrowOpts, '-');
    end

    color = get(h, 'Color');
    lineOpts = getLineOptions(m2t, lineStyle, lineWidth);
    [m2t, arrowcolor] = getColor(m2t, h, color, 'patch');
    arrowOpts = opts_add(arrowOpts, 'color', arrowcolor);
    arrowOpts = opts_merge(arrowOpts, lineOpts);

    % define arrow style
    arrowOptions = opts_print(m2t, arrowOpts, ',');

    % Append the arrow style to the TikZ options themselves.
    % TODO: Look into replacing this by something more 'local',
    % (see \pgfplotset{}).
    m2t.content.options = opts_add(m2t.content.options,...
        sprintf('arrow%d/.style', m2t.quiverId), ...
        ['{', arrowOptions, '}']);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % return the vector field code
    str = [str, ...
        sprintf(['\\',name,' [arrow',num2str(m2t.quiverId), '] ', ...
        'coordinates{(',format,') (',format,')};\n'],...
        data)];
    %FIXME: external
end
% ==============================================================================
function [x,y,z,u,v,w] = getAndRescaleQuivers(m2t, h)
% get and rescale the arrows from a quivergroup object
    x = get(h, 'XData');
    y = get(h, 'YData');
    z = getOrDefault(h, 'ZData', []);

    u = get(h, 'UData');
    v = get(h, 'VData');
    w = getOrDefault(h, 'WData', []);

    is3D = m2t.axesContainers{end}.is3D;
    if ~is3D
        z = 0;
        w = 0;
    end

    % MATLAB uses a scaling algorithm to determine the size of the arrows.
    % Before R2014b, the processed coordinates were available. This is no longer
    % the case, so we have to re-implement it. In MATLAB it is implemented in
    % the |quiver3|  (and |quiver|) function.
    if any(size(x)==1)
        nX = sqrt(numel(x)); nY = nX;
    else
        [nY, nX] = size(x);
    end
    range  = @(xyzData)(max(xyzData(:)) - min(xyzData(:)));
    euclid = @(x,y,z)(sqrt(x.^2 + y.^2 + z.^2));
    dx = range(x)/nX;
    dy = range(y)/nY;
    dz = range(z)/max(nX,nY);
    dd = euclid(dx, dy, dz);
    if dd > 0
        vectorLength = euclid(u/dd,v/dd,w/dd);
        maxLength = max(vectorLength(:));
    else
        maxLength = 1;
    end
    if getOrDefault(h, 'AutoScale', true)
        scaleFactor = getOrDefault(h,'AutoScaleFactor', 0.9) / maxLength;
    else
        scaleFactor = 1;
    end
    x = x(:).'; u = u(:).'*scaleFactor;
    y = y(:).'; v = v(:).'*scaleFactor;
    z = z(:).'; w = w(:).'*scaleFactor;
end
% ==============================================================================
function [m2t, str] = drawErrorBars(m2t, h)
% Takes care of MATLAB's error bar plots.
    if isa(h,'matlab.graphics.chart.primitive.ErrorBar') % MATLAB R2014b+
        hData = h;
        upDev = get(h, 'UData');
        loDev = get(h, 'LData');

        yDeviations = [upDev(:), loDev(:)];

    else % Legacy Handling (Octave and MATLAB R2014a and older):
        % 'errorseries' plots have two line-plot children, one of which contains
        % the information about the center points; 'XData' and 'YData' components
        % are both of length n.
        % The other contains the information about the deviations (errors), more
        % more precisely: the lines to be drawn. Those are
        %        ___
        %         |
        %         |
        %         X  <-- (x0,y0)
        %         |
        %        _|_
        %
        %    X: x0,     x0,     x0-eps, x0+eps, x0-eps, x0+eps;
        %    Y: y0-dev, y0+dev, y0-dev, y0-dev, y0+dev, y0+dev.
        %
        % Hence, 'XData' and 'YData' are of length 6*n and contain redundant info.
        % Some versions of MATLAB(R) insert more columns with NaNs (to be able to
        % pass the entire X, Y arrays into plot()) such that the data is laid out as
        %
        %    X: x0,     x0,     NaN, x0-eps, x0+eps, NaN, x0-eps, x0+eps;
        %    Y: y0-dev, y0+dev, NaN, y0-dev, y0-dev, NaN, y0+dev, y0+dev,
        %
        % or with another columns of NaNs added at the end.
        c = get(h, 'Children');

        % Find out which contains the data and which the deviations.
        %TODO: this can be simplified using sort
        n1 = length(get(c(1),'XData'));
        n2 = length(get(c(2),'XData'));
        if n2 == 6*n1
            % 1 contains centerpoint info
            dataIdx  = 1;
            errorIdx = 2;
            numDevData = 6;
        elseif n1 == 6*n2
            % 2 contains centerpoint info
            dataIdx  = 2;
            errorIdx = 1;
            numDevData = 6;
        elseif n2 == 9*n1-1 || n2 == 9*n1
            % 1 contains centerpoint info
            dataIdx  = 1;
            errorIdx = 2;
            numDevData = 9;
        elseif n1 == 9*n2-1 || n1 == 9*n2
            % 2 contains centerpoint info
            dataIdx  = 2;
            errorIdx = 1;
            numDevData = 9;
        else
            error('drawErrorBars:errorMatch', ...
                'Sizes of and error data not matching (6*%d ~= %d and 6*%d ~= %d, 9*%d-1 ~= %d, 9*%d-1 ~= %d).', ...
                n1, n2, n2, n1, n1, n2, n2, n1);
        end
        hData  = c(dataIdx);
        hError = c(errorIdx);

        % prepare error array (that is, gather the y-deviations)
        yValues = get(hData , 'YData');
        yErrors = get(hError, 'YData');

        n = length(yValues);

        yDeviations = zeros(n, 2);

        %TODO: this can be vectorized
        for k = 1:n
            % upper deviation
            kk = numDevData*(k-1) + 1;
            upDev = abs(yValues(k) - yErrors(kk));

            % lower deviation
            kk = numDevData*(k-1) + 2;
            loDev = abs(yValues(k) - yErrors(kk));

            yDeviations(k,:) = [upDev loDev];
        end
    end
    % Now run drawLine() with deviation information.
    [m2t, str] = drawLine(m2t, hData, yDeviations);
end
% ==============================================================================
function [m2t, str] = drawEllipse(m2t, handle)
% Takes care of MATLAB's ellipse annotations.
%

%     c = get(h, 'Children');

    drawOptions = opts_new();

    p = get(handle,'position');
    radius = p([3 4]) / 2;
    center = p([1 2]) + radius;

    lineStyle = get(handle, 'LineStyle');
    lineWidth = get(handle, 'LineWidth');

    color = get(handle, 'Color');
    [m2t, xcolor] = getColor(m2t, handle, color, 'patch');
    lineOptions = getLineOptions(m2t, lineStyle, lineWidth);

    filling = get(handle, 'FaceColor');

    % Has a filling?
    if isNone(filling)
        drawOptions = opts_add(drawOptions, xcolor);
        drawCommand = '\draw';
    else
        [m2t, xcolorF] = getColor(m2t, handle, filling, 'patch');
        drawOptions = opts_add(drawOptions, 'draw', xcolor);
        drawOptions = opts_add(drawOptions, 'fill', xcolorF);

        drawCommand = '\filldraw';
    end
    drawOptions = opts_merge(drawOptions, lineOptions);

    opt = opts_print(m2t, drawOptions, ',');

    str = sprintf('%s [%s] (axis cs:%g,%g) ellipse [x radius=%g, y radius=%g];\n', ...
        drawCommand, opt, center, radius);
end
% ==============================================================================
function [m2t, str] = drawTextarrow(m2t, handle)
% Takes care of MATLAB's textarrow annotations.

    % handleAllChildren to draw the arrow
    [m2t, str] = handleAllChildren(m2t, handle);

    % handleAllChildren ignores the text, unless hidden strings are shown
    if ~m2t.cmdOpts.Results.showHiddenStrings
        child = findobj(handle, 'type', 'text');
        [m2t, str{end+1}] = drawText(m2t, child);
    end
end
% ==============================================================================
function out = linearFunction(X, Y)
% Return the linear function that goes through (X[1], Y[1]), (X[2], Y[2]).
    out = @(x) (Y(2,:)*(x-X(1)) + Y(1,:)*(X(2)-x)) / (X(2)-X(1));
end
% ==============================================================================
function matlabColormap = pgfplots2matlabColormap(points, rgb, numColors)
% Translates a Pgfplots colormap to a MATLAB color map.
    matlabColormap = zeros(numColors, 3);
    % Point indices between which to interpolate.
    I = [1, 2];
    f = linearFunction(points(I), rgb(I,:));
    for k = 1:numColors
        x = (k-1)/(numColors-1) * points(end);
        if x > points(I(2))
            I = I + 1;
            f = linearFunction(points(I), rgb(I,:));
        end
        matlabColormap(k,:) = f(x);
    end
end
% ==============================================================================
function pgfplotsColormap = matlab2pgfplotsColormap(m2t, matlabColormap, name)
% Translates a MATLAB color map into a Pgfplots colormap.

if nargin < 3 || isempty(name), name = 'mymap'; end

% First check if we could use a default Pgfplots color map.
% Unfortunately, MATLAB and Pgfplots color maps will never exactly coincide
% except to the most simple cases such as blackwhite. This is because of a
% slight incompatibility of Pgfplots and MATLAB colormaps:
% In MATLAB, indexing goes from 1 through 64, whereas in Pgfplots you can
% specify any range, the default ones having something like
% (0: red, 1: yellow, 2: blue).
% To specify this exact color map in MATLAB, one would have to put 'red' at
% 1, blue at 64, and yellow in the middle of the two, 32.5 that is.
% Not really sure how MATLAB rounds here: 32, 33? Anyways, it will be
% slightly off and hence not match the Pgfplots color map.
% As a workaround, build the MATLAB-formatted colormaps of Pgfplots default
% color maps, and check if matlabColormap is close to it. If yes, take it.

% For now, comment out the color maps which haven't landed yet in Pgfplots.
    pgfmaps = { %struct('name', 'colormap/autumn', ...
        %       'points', [0,1], ...
        %       'values', [[1,0,0];[1,1,0]]), ...
        %struct('name', 'colormap/bled', ...
        %       'points', 0:6, ...
        %       'values', [[0,0,0];[43,43,0];[0,85,0];[0,128,128];[0,0,170];[213,0,213];[255,0,0]]/255), ...
        %struct('name', 'colormap/bright', ...
        %       'points', 0:7, ...
        %       'values', [[0,0,0];[78,3,100];[2,74,255];[255,21,181];[255,113,26];[147,213,114];[230,255,0];[255,255,255]]/255), ...
        %struct('name', 'colormap/bone', ...
        %       'points', [0,3,6,8], ...
        %       'values', [[0,0,0];[84,84,116];[167,199,199];[255,255,255]]/255), ...
        %struct('name', 'colormap/cold', ...
        %       'points', 0:3, ...
        %       'values', [[0,0,0];[0,0,1];[0,1,1];[1,1,1]]), ...
        %struct('name', 'colormap/copper', ...
        %       'points', [0,4,5], ...
        %       'values', [[0,0,0];[255,159,101];[255,199,127]]/255), ...
        %struct('name', 'colormap/copper2', ...
        %       'points', 0:4, ...
        %       'values', [[0,0,0];[68,62,63];[170,112,95];[207,194,138];[255,255,255]]/255), ...
        %struct('name', 'colormap/hsv', ...
        %       'points', 0:6, ...
        %       'values', [[1,0,0];[1,1,0];[0,1,0];[0,1,1];[0,0,1];[1,0,1];[1,0,0]]), ...
        struct('name', 'colormap/hot', ...
        'points', 0:3, ...
        'values', [[0,0,1];[1,1,0];[1,0.5,0];[1,0,0]]), ... % TODO check this
        struct('name', 'colormap/hot2', ...
        'points', [0,3,6,8], ...
        'values', [[0,0,0];[1,0,0];[1,1,0];[1,1,1]]), ...
        struct('name', 'colormap/jet', ...
        'points', [0,1,3,5,7,8], ...
        'values', [[0,0,128];[0,0,255];[0,255,255];[255,255,0];[255,0,0];[128,0,0]]/255), ...
        struct('name', 'colormap/blackwhite', ...
        'points', [0,1], ...
        'values', [[0,0,0];[1,1,1]]), ...
        struct('name', 'colormap/bluered', ...
        'points', 0:5, ...
        'values', [[0,0,180];[0,255,255];[100,255,0];[255,255,0];[255,0,0];[128,0,0]]/255), ...
        struct('name', 'colormap/cool', ...
        'points', [0,1,2], ...
        'values', [[255,255,255];[0,128,255];[255,0,255]]/255), ...
        struct('name', 'colormap/greenyellow', ...
        'points', [0,1], ...
        'values', [[0,128,0];[255,255,0]]/255), ...
        struct('name', 'colormap/redyellow', ...
        'points', [0,1], ...
        'values', [[255,0,0];[255,255,0]]/255), ...
        struct('name', 'colormap/violet', ...
        'points', [0,1,2], ...
        'values', [[25,25,122];[255,255,255];[238,140,238]]/255) ...
        };

    % The tolerance is a subjective matter of course.
    % Some figures:
    %    * The norm-distance between MATLAB's gray and bone is 6.8e-2.
    %    * The norm-distance between MATLAB's jet and Pgfplots's jet is 2.8e-2.
    %    * The norm-distance between MATLAB's hot and Pgfplots's hot2 is 2.1e-2.
    tol = 5.0e-2;

    for map = pgfmaps
        numColors = size(matlabColormap, 1);
        mmap = pgfplots2matlabColormap(map{1}.points, map{1}.values, numColors);
        alpha = norm(matlabColormap - mmap) / sqrt(numColors);
        if alpha < tol
            userInfo(m2t, 'Found %s to be a pretty good match for your color map (||diff||=%g).', ...
                map{1}.name, alpha);
            pgfplotsColormap = map{1}.name;
            return
        end
    end

    % Build a custom color map.
    % Loop over the data, stop at each spot where the linear
    % interpolation is interrupted, and set a color mark there.
    m = size(matlabColormap, 1);
    steps = [1, 2];
    % A colormap with a single color is valid in MATLAB but an error in
    % pgfplots. Repeating the color produces the desired effect in this
    % case.
    if m==1
        colors=[matlabColormap(1,:);matlabColormap(1,:)];
    else
        colors = [matlabColormap(1,:); matlabColormap(2,:)];
        f = linearFunction(steps, colors);
        k = 3;
        while k <= m
            if norm(matlabColormap(k,:) - f(k)) > 1.0e-10
                % Add the previous step to the color list
                steps(end) = k-1;
                colors(end,:) = matlabColormap(k-1,:);
                steps = [steps, k];
                colors = [colors; matlabColormap(k,:)];
                f = linearFunction(steps(end-1:end), colors(end-1:end,:));
            end
            k = k+1;
        end
        steps(end) = m;
        colors(end,:) = matlabColormap(m,:);
    end

    % Get it in Pgfplots-readable form.
    unit = 'pt';
    colSpecs = {};
    for k = 1:length(steps)
        x = steps(k)-1;
        colSpecs{k} = sprintf('rgb(%d%s)=(%g,%g,%g)', x, unit, colors(k,:));
    end
    pgfplotsColormap = sprintf('colormap={%s}{[1%s] %s}',name, unit, join(m2t, colSpecs, '; '));
end
% ==============================================================================
function fontStyle = getFontStyle(m2t, handle)
    fontStyle = '';
    if strcmpi(get(handle, 'FontWeight'),'Bold')
        fontStyle = sprintf('%s\\bfseries',fontStyle);
    end
    if strcmpi(get(handle, 'FontAngle'), 'Italic')
        fontStyle = sprintf('%s\\itshape',fontStyle);
    end
    if m2t.cmdOpts.Results.strictFontSize
        fontSize  = get(handle,'FontSize');
        fontUnits = matlab2texUnits(get(handle,'FontUnits'), 'pt');
        fontStyle = sprintf('\\fontsize{%d%s}{1em}%s\\selectfont',fontSize,fontUnits,fontStyle);
    else
        % don't try to be smart and "translate" MATLAB font sizes to proper LaTeX
        % ones: it cannot be done. LaTeX uses semantic sizes (e.g. \small)
        % whose actual dimensions depend on the document style, context, ...
    end

    if ~isempty(fontStyle)
        fontStyle = opts_add(opts_new, 'font', fontStyle);
    else
        fontStyle = opts_new();
    end
end
% ==============================================================================
function axisOptions = getColorbarOptions(m2t, handle)

    % begin collecting axes options
    axisOptions = opts_new();
    cbarStyleOptions = opts_new();

    [cbarTemplate, cbarStyleOptions] = getColorbarPosOptions(handle, ...
                                                cbarStyleOptions);

    % axis label and direction
    if isHG2
        % VERSION: Starting from R2014b there is only one field `label`.
        % The colorbar's position determines, if it should be a x- or y-label.

        if strcmpi(cbarTemplate, 'horizontal')
            labelOption = 'xlabel';
        else
            labelOption = 'ylabel';
        end
        [m2t, cbarStyleOptions] = getLabel(m2t, handle, cbarStyleOptions, labelOption);

        % direction
        dirString = get(handle, 'Direction');
        if ~strcmpi(dirString, 'normal') % only if not 'normal'
            if strcmpi(cbarTemplate, 'horizontal')
                dirOption = 'x dir';
            else
                dirOption = 'y dir';
            end
            cbarStyleOptions = opts_add(cbarStyleOptions, dirOption, dirString);
        end

        % TODO HG2: colorbar ticks and colorbar tick labels

    else
        % VERSION: Up to MATLAB R2014a and OCTAVE
        [m2t, xo] = getAxisOptions(m2t, handle, 'x');
        [m2t, yo] = getAxisOptions(m2t, handle, 'y');
        xyo = opts_merge(xo, yo);
        xyo = opts_remove(xyo, 'xmin','xmax','xtick','ymin','ymax','ytick');

        cbarStyleOptions = opts_merge(cbarStyleOptions, xyo);
    end

    % title
    [m2t, cbarStyleOptions] = getTitle(m2t, handle, cbarStyleOptions);

    if m2t.cmdOpts.Results.strict
        % Sampled colors.
        numColors = size(m2t.currentHandles.colormap, 1);
        axisOptions = opts_add(axisOptions, 'colorbar sampled');
        cbarStyleOptions = opts_add(cbarStyleOptions, 'samples', ...
            sprintf('%d', numColors+1));

        if ~isempty(cbarTemplate)
            userWarning(m2t, ...
-               'Pgfplots cannot deal with more than one colorbar option yet.');
            %FIXME: can we get sampled horizontal color bars to work?
            %FIXME: sampled colorbars should be inferred, not by using strict!
        end
    end

    % Merge them together in axisOptions.
    axisOptions = opts_add(axisOptions, strtrim(['colorbar ', cbarTemplate]));

    if ~isempty(cbarStyleOptions)
        axisOptions = opts_add(axisOptions, ...
            'colorbar style', ...
            ['{' opts_print(m2t, cbarStyleOptions, ',') '}']);
    end

    % do _not_ handle colorbar's children
end
% ==============================================================================
function [cbarTemplate, cbarStyleOptions] = getColorbarPosOptions(handle, cbarStyleOptions)
% set position, ticks etc. of a colorbar
    loc = get(handle, 'Location');
    cbarTemplate = '';

    switch lower(loc) % case insensitive (MATLAB: CamelCase, Octave: lower case)
        case 'north'
            cbarTemplate = 'horizontal';
            cbarStyleOptions = opts_add(cbarStyleOptions, 'at',...
                '{(0.5,0.97)}');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'anchor',...
                'north');
            cbarStyleOptions = opts_add(cbarStyleOptions,...
                'xticklabel pos', 'lower');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'width',...
                '0.97*\pgfkeysvalueof{/pgfplots/parent axis width}');
        case 'south'
            cbarTemplate = 'horizontal';
            cbarStyleOptions = opts_add(cbarStyleOptions, 'at',...
                '{(0.5,0.03)}');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'anchor', ...
                'south');
            cbarStyleOptions = opts_add(cbarStyleOptions, ...
                'xticklabel pos','upper');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'width',...
                '0.97*\pgfkeysvalueof{/pgfplots/parent axis width}');
        case 'east'
            cbarTemplate = 'right';
            cbarStyleOptions = opts_add(cbarStyleOptions, 'at',...
                '{(0.97,0.5)}');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'anchor', ...
                'east');
            cbarStyleOptions = opts_add(cbarStyleOptions, ...
                'xticklabel pos','left');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'width',...
                '0.97*\pgfkeysvalueof{/pgfplots/parent axis width}');
        case 'west'
            cbarTemplate = 'left';
            cbarStyleOptions = opts_add(cbarStyleOptions, 'at',...
                '{(0.03,0.5)}');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'anchor',...
                'west');
            cbarStyleOptions = opts_add(cbarStyleOptions,...
                'xticklabel pos', 'right');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'width',...
                '0.97*\pgfkeysvalueof{/pgfplots/parent axis width}');
        case 'eastoutside'
            %cbarTemplate = 'right';
        case 'westoutside'
            cbarTemplate = 'left';
        case 'northoutside'
            % TODO move to top
            cbarTemplate = 'horizontal';
            cbarStyleOptions = opts_add(cbarStyleOptions, 'at',...
                '{(0.5,1.03)}');
            cbarStyleOptions = opts_add(cbarStyleOptions, 'anchor',...
                'south');
            cbarStyleOptions = opts_add(cbarStyleOptions,...
                'xticklabel pos', 'upper');
        case 'southoutside'

            cbarTemplate = 'horizontal';
        otherwise
            error('matlab2tikz:getColorOptions:unknownLocation',...
                'getColorbarOptions: Unknown ''Location'' %s.', loc)
    end
end
% ==============================================================================
function [m2t, xcolor] = getColor(m2t, handle, color, mode)
% Handles MATLAB colors and makes them available to TikZ.
% This includes translation of the color value as well as explicit
% definition of the color if it is not available in TikZ by default.
%
% The variable 'mode' essentially determines what format 'color' can
% have. Possible values are (as strings) 'patch' and 'image'.

% check if the color is straight given in rgb
% -- notice that we need the extra NaN test with respect to the QUIRK
%    below
    if isRGBTuple(color)
        % everything alright: rgb color here
        [m2t, xcolor] = rgb2colorliteral(m2t, color);
    else
        switch lower(mode)
            case 'patch'
                [m2t, xcolor] = patchcolor2xcolor(m2t, color, handle);
            case 'image'

                m = size(color,1);
                n = size(color,2);
                xcolor = cell(m, n);

                if ndims(color) == 3
                    for i = 1:m
                        for j = 1:n
                            [m2t, xc] = rgb2colorliteral(m2t, color(i,j, :));
                            xcolor{i, j} = xc;
                        end
                    end
                elseif ndims(color) <= 2
                    [m2t, colorindex] = cdata2colorindex(m2t, color, handle);
                    for i = 1:m
                        for j = 1:n
                            [m2t, xc] = rgb2colorliteral(m2t, m2t.currentHandles.colormap(colorindex(i,j), :));
                            xcolor{i, j} = xc;
                        end
                    end
                else
                    error('matlab2tikz:getColor:image:colorDims',...
                        'Image color data cannot have more than 3 dimensions');
                end
            otherwise
                error(['matlab2tikz:getColor', ...
                    'Argument ''mode'' has illegal value ''%s''.'], ...
                    mode);
        end
    end
end
% ==============================================================================
function [m2t, xcolor] = patchcolor2xcolor(m2t, color, patchhandle)
% Transforms a color of the edge or the face of a patch to an xcolor literal.
    if isnumeric(color)
        [m2t, xcolor] = rgb2colorliteral(m2t, color);
    elseif ischar(color)
        switch color
            case 'flat'
                cdata  = getCDataWithFallbacks(patchhandle);
                color1 = cdata(1,1);
                % RGB cdata
                if ndims(cdata) == 3 && all(size(cdata) == [1,1,3])
                    [m2t,xcolor] = rgb2colorliteral(m2t, cdata);
                % All same color
                elseif all(isnan(cdata) | abs(cdata-color1)<1.0e-10)
                    [m2t, colorindex] = cdata2colorindex(m2t, color1, patchhandle);
                    [m2t, xcolor] = rgb2colorliteral(m2t, m2t.currentHandles.colormap(colorindex, :));
                else
                    % Don't return anything meaningful and count on the caller
                    % to make something of it.
                    xcolor = [];
                end

            case 'auto'
                try
                    color = get(patchhandle, 'Color');
                catch
                    % From R2014b use an undocumented property if Color is
                    % not present
                    color = get(patchhandle, 'AutoColor');
                end
                [m2t, xcolor] = rgb2colorliteral(m2t, color);

            case 'none'
                error('matlab2tikz:anycolor2rgb:ColorModelNoneNotAllowed',...
                    ['Color model ''none'' not allowed here. ',...
                    'Make sure this case gets intercepted before.']);

            otherwise
                    error('matlab2tikz:anycolor2rgb:UnknownColorModel',...
                    'Don''t know how to handle the color model ''%s''.',color);
        end
    else
        error('patchcolor2xcolor:illegalInput', ...
            'Input argument ''color'' not a string or numeric.');
    end
end
% ==============================================================================
function cdata = getCDataWithFallbacks(patchhandle)
% Looks for CData at different places
    cdata = getOrDefault(patchhandle, 'CData', []);

    if isempty(cdata) || ~isnumeric(cdata)
        child = get(patchhandle, 'Children');
        cdata = get(child, 'CData');
    end
    if isempty(cdata) || ~isnumeric(cdata)
        % R2014b+: CData is implicit by the ordering of the siblings
        siblings = get(get(patchhandle, 'Parent'), 'Children');
        cdata = find(siblings(end:-1:1)==patchhandle);
    end
end
% ==============================================================================
function [m2t, colorindex] = cdata2colorindex(m2t, cdata, imagehandle)
% Transforms a color in CData format to an index in the color map.
% Only does something if CDataMapping is 'scaled', really.

    if ~isnumeric(cdata) && ~islogical(cdata)
        error('matlab2tikz:cdata2colorindex:unknownCDataType',...
            'Don''t know how to handle CData ''%s''.',cdata);
    end

    axeshandle = m2t.currentHandles.gca;

    % -----------------------------------------------------------------------
    % For the following, see, for example, the MATLAB help page for 'image',
    % section 'Image CDataMapping'.
    try
        mapping = get(imagehandle, 'CDataMapping');
    catch
        mapping = 'scaled';
    end
    switch mapping
        case 'scaled'
            % need to scale within clim
            % see MATLAB's manual page for caxis for details
            clim = get(axeshandle, 'clim');
            m = size(m2t.currentHandles.colormap, 1);
            colorindex = zeros(size(cdata));
            idx1 = cdata <= clim(1);
            idx2 = cdata >= clim(2);
            idx3 = ~idx1 & ~idx2;
            colorindex(idx1) = 1;
            colorindex(idx2) = m;
            colorindex(idx3) = fix((cdata(idx3)-clim(1)) / (clim(2)-clim(1)) *m) ...
                + 1;
        case 'direct'
            % direct index
            colorindex = cdata;

        otherwise
            error('matlab2tikz:anycolor2rgb:unknownCDataMapping',...
                'Unknown CDataMapping ''%s''.',cdatamapping);
    end
end
% ==============================================================================
function [m2t, key, lOpts] = getLegendOpts(m2t, handle)
% Need to check that there's nothing inside visible before we
% abandon this legend -- an invisible property of the parent just
% means the legend has no box.
    children = get(handle, 'Children');
    if ~isVisible(handle) && ~any(isVisible(children))
        return
    end

    lStyle = opts_new();

    lStyle = legendPosition(m2t, handle, lStyle);
    lStyle = legendOrientation(m2t, handle, lStyle);
    lStyle = legendEntryAlignment(m2t, handle, lStyle);

    % If the plot has 'legend boxoff', we have the 'not visible'
    % property, so turn off line and background fill.
    if ~isVisible(handle) || strcmpi(get(handle,'box'),'off')
        lStyle = opts_add(lStyle, 'fill', 'none');
        lStyle = opts_add(lStyle, 'draw', 'none');
    else
        % handle colors
        [edgeColor, isDfltEdge] = getAndCheckDefault('Legend', handle, ...
                                                     'EdgeColor', [1 1 1]);
        if isNone(edgeColor)
            lStyle = opts_add(lStyle, 'draw', 'none');

        elseif ~isDfltEdge
            [m2t, col] = getColor(m2t, handle, edgeColor, 'patch');
            lStyle = opts_add(lStyle, 'draw', col);
        end

        [fillColor, isDfltFill] = getAndCheckDefault('Legend', handle, ...
                                                     'Color', [1 1 1]);
        if isNone(fillColor)
            lStyle = opts_add(lStyle, 'fill', 'none');

        elseif ~isDfltFill
            [m2t, col] = getColor(m2t, handle, fillColor, 'patch');
            lStyle = opts_add(lStyle, 'fill', col);
        end
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    key = 'legend style';
    lOpts = opts_print(m2t, lStyle, ',');
end
% ==============================================================================
function [lStyle] = legendOrientation(m2t, handle, lStyle)
% handle legend orientation
    ori = get(handle, 'Orientation');
    switch lower(ori)
        case 'horizontal'
            numLegendEntries = sprintf('%d',length(get(handle, 'String')));
            lStyle = opts_add(lStyle, 'legend columns', numLegendEntries);

        case 'vertical'
            % Use default.
        otherwise
            userWarning(m2t, [' Unknown legend orientation ''',ori,'''' ...
                '. Choosing default (vertical).']);
    end
end
% ==============================================================================
function [lStyle] = legendPosition(m2t, handle, lStyle)
% handle legend location
% #COMPLEX: just a big switch-case
    loc  = get(handle, 'Location');
    dist = 0.03;  % distance to to axes in normalized coordinates
    % MATLAB(R)'s keywords are camel cased (e.g., 'NorthOutside'), in Octave
    % small cased ('northoutside'). Hence, use lower() for uniformity.
    switch lower(loc)
        case 'northeast'
            return % don't do anything in this (default) case
        case 'northwest'
            position = [dist, 1-dist];
            anchor   = 'north west';
        case 'southwest'
            position = [dist, dist];
            anchor   = 'south west';
        case 'southeast'
            position = [1-dist, dist];
            anchor   = 'south east';
        case 'north'
            position = [0.5, 1-dist];
            anchor   = 'north';
        case 'east'
            position = [1-dist, 0.5];
            anchor   = 'east';
        case 'south'
            position = [0.5, dist];
            anchor   = 'south';
        case 'west'
            position = [dist, 0.5];
            anchor   = 'west';
        case 'northoutside'
            position = [0.5, 1+dist];
            anchor = 'south';
        case 'southoutside'
            position = [0.5, -dist];
            anchor = 'north';
        case 'eastoutside'
            position = [1+dist, 0.5];
            anchor = 'west';
        case 'westoutside'
            position = [-dist, 0.5];
            anchor = 'east';
        case 'northeastoutside'
            position = [1+dist, 1];
            anchor = 'north west';
        case 'northwestoutside'
            position = [-dist, 1];
            anchor = 'north east';
        case 'southeastoutside'
            position = [1+dist, 0];
            anchor = 'south west';
        case 'southwestoutside'
            position = [-dist, 0];
            anchor = 'south east';
        case 'none'
            legendPos = get(handle, 'Position');
            unit = get(handle, 'Units');
            if isequal(unit, 'normalized')
                position = legendPos(1:2);
            else
                % Calculate where the legend is located w.r.t. the axes.
                axesPos = get(m2t.currentHandles.gca, 'Position');
                axesUnit = get(m2t.currentHandles.gca, 'Units');
                % Convert to legend unit
                axesPos = convertUnits(axesPos, axesUnit, unit);
                % By default, the axes position is given w.r.t. to the figure,
                % and so is the legend.
                position = (legendPos(1:2)-axesPos(1:2)) ./ axesPos(3:4);
            end
            anchor = 'south west';
        case {'best','bestoutside'}
            % TODO: Implement these.
            % The position could be determined by means of 'Position' and/or
            % 'OuterPosition' of the legend handle; in fact, this could be made
            % a general principle for all legend placements.
            userWarning(m2t, [sprintf(' Option ''%s'' not yet implemented.',loc),         ...
                ' Choosing default.']);
            return % use defaults

        otherwise
            userWarning(m2t, [' Unknown legend location ''',loc,''''           ...
                '. Choosing default.']);
            return % use defaults
    end

    % set legend position
    %TODO: shouldn't this include units?
    lStyle = opts_add(lStyle, 'at',  sprintf('{(%s,%s)}', ...
                        formatDim(position(1)), formatDim(position(2))));
    lStyle = opts_add(lStyle, 'anchor', anchor);

end
% ==============================================================================
function [lStyle] = legendEntryAlignment(m2t, handle, lStyle)
% determines the text and picture alignment inside a legend
    textalign = '';
    pictalign = '';
    switch getEnvironment
        case 'Octave'
            % Octave allows to change the alignment of legend text and
            % pictograms using legend('left') and legend('right')
            textpos = get(handle, 'textposition');
            switch lower(textpos)
                case 'left'
                    % pictogram right of flush right text
                    textalign = 'right';
                    pictalign = 'right';
                case 'right'
                    % pictogram left of flush left text (default)
                    textalign = 'left';
                    pictalign = 'left';
                otherwise
                    userWarning(m2t, ...
                        ['Unknown legend text position ''',...
                        textpos, '''. Choosing default.']);
            end
        case 'MATLAB'
            % does not specify text/pictogram alignment in legends
        otherwise
            errorUnknownEnvironment();
    end

    % set alignment of legend text and pictograms, if available
    if ~isempty(textalign) && ~isempty(pictalign)
        lStyle = opts_add(lStyle, 'legend cell align', textalign);
        lStyle = opts_add(lStyle, 'align', textalign);
        lStyle = opts_add(lStyle, 'legend plot pos', pictalign);
    else
        % Make sure the entries are flush left (default MATLAB behavior).
        % This is also import for multiline legend entries: Without alignment
        % specification, the TeX document won't compile.
        % 'legend plot pos' is not set explicitly, since 'left' is default.
        lStyle = opts_add(lStyle, 'legend cell align', 'left');
        lStyle = opts_add(lStyle, 'align', 'left');
    end
end
% ==============================================================================
function [pTicks, pTickLabels] = ...
    matlabTicks2pgfplotsTicks(m2t, ticks, tickLabels, isLogAxis, tickLabelMode)
% Converts MATLAB style ticks and tick labels to pgfplots style (if needed)
    if isempty(ticks)
        pTicks      = '\empty';
        pTickLabels = [];
        return
    end

    % set ticks + labels
    pTicks = join(m2t, num2cell(ticks), ',');

    % if there's no specific labels, return empty
    if isempty(tickLabels) || (length(tickLabels)==1 && isempty(tickLabels{1}))
        pTickLabels = '\empty';
        return
    end

    % sometimes tickLabels are cells, sometimes plain arrays
    % -- unify this to cells
    if ischar(tickLabels)
        tickLabels = strtrim(mat2cell(tickLabels,                  ...
            ones(size(tickLabels,1), 1), ...
            size(tickLabels, 2)          ...
            ) ...
            );
    end

    ticks = removeSuperfluousTicks(ticks, tickLabels);

    isNeeded = isTickLabelsNecessary(m2t, ticks, tickLabels, isLogAxis);

    pTickLabels = formatPgfTickLabels(m2t, isNeeded, tickLabels, ...
        isLogAxis, tickLabelMode);
end
% ==============================================================================
function bool = isTickLabelsNecessary(m2t, ticks, tickLabels, isLogAxis)
    % Check if tickLabels are really necessary (and not already covered by
    % the tick values themselves).
    bool = false;

    k = find(ticks ~= 0.0, 1); % get an index with non-zero tick value
    if isLogAxis || isempty(k) % only a 0-tick
        scalingFactor = 1;
    else
        % When plotting axis, MATLAB might scale the axes by a factor of ten,
        % say 10^n, and plot a 'x 10^k' next to the respective axis. This is
        % common practice when the tick marks are really large or small
        % numbers.
        % Unfortunately, MATLAB doesn't contain the information about the
        % scaling anywhere in the plot, and at the same time the {x,y}TickLabels
        % are given as t*10^k, thus no longer corresponding to the actual
        % value t.
        % Try to find the scaling factor here. This is then used to check
        % whether or not explicit {x,y}TickLabels are really necessary.
        s = str2double(tickLabels{k});
        scalingFactor = ticks(k)/s;
        % check if the factor is indeed a power of 10
        S = log10(scalingFactor);
        if abs(round(S)-S) > m2t.tol
            scalingFactor = 1.0;
        end
    end

    for k = 1:min(length(ticks),length(tickLabels))
        % Don't use str2num here as then, literal strings as 'pi' get
        % legally transformed into 3.14... and the need for an explicit
        % label will not be recognized. str2double returns a NaN for 'pi'.
        if isLogAxis
            s = 10^(str2double(tickLabels{k}));
        else
            s = str2double(tickLabels{k});
        end
        if isnan(s)  ||  abs(ticks(k)-s*scalingFactor) > m2t.tol
            bool = true;
            return;
        end
    end
end
% ==============================================================================
function pTickLabels = formatPgfTickLabels(m2t, plotLabelsNecessary, ...
        tickLabels, isLogAxis, tickLabelMode)
% formats the tick labels for pgfplots
    if plotLabelsNecessary
        % if the axis is logscaled, MATLAB does not store the labels,
        % but the exponents to 10
        if isLogAxis
            for k = 1:length(tickLabels)
                if isnumeric(tickLabels{k})
                    str = num2str(tickLabels{k});
                else
                    str = tickLabels{k};
                end
                if strcmpi(tickLabelMode,'auto')
                    tickLabels{k} = sprintf('$10^{%s}$', str);
                end
            end
        end
        tickLabels = cellfun(@(l)(sprintf('{%s}',l)), tickLabels, ...
            'UniformOutput', false);
        pTickLabels = join(m2t, tickLabels, ',');
    else
        pTickLabels = [];
    end
end
% ==============================================================================
function ticks = removeSuperfluousTicks(ticks, tickLabels)
% What MATLAB does when the number of ticks and tick labels is not the same,
% is somewhat unclear. Cut of the first entries to fix bug
%     https://github.com/matlab2tikz/matlab2tikz/issues/161,
    m = length(ticks);
    n = length(tickLabels);
    if n < m
        ticks = ticks(m-n+1:end);
    end
end
% ==============================================================================
function tikzLineStyle = translateLineStyle(matlabLineStyle)
    if(~ischar(matlabLineStyle))
        error('matlab2tikz:translateLineStyle:NotAString',...
            'Variable matlabLineStyle is not a string.');
    end

    switch (matlabLineStyle)
        case 'none'
            tikzLineStyle = '';
        case '-'
            tikzLineStyle = 'solid';
        case '--'
            tikzLineStyle = 'dashed';
        case ':'
            tikzLineStyle = 'dotted';
        case '-.'
            tikzLineStyle = 'dashdotted';
        otherwise
            error('matlab2tikz:translateLineStyle:UnknownLineStyle',...
                'Unknown matlabLineStyle ''%s''.', matlabLineStyle);
    end
end
% ==============================================================================
function [m2t, table, opts] = makeTable(m2t, varargin)
%   [m2t,table,opts] = makeTable(m2t, 'name1', data1, 'name2', data2, ...)
%   [m2t,table,opts] = makeTable(m2t, {'name1','name2',...}, {data1, data2, ...})
%   [m2t,table,opts] = makeTable(m2t, {'name1','name2',...}, [data1(:), data2(:), ...])
%
%  Returns m2t structure, formatted table and table options.
%  When all the names are empty, no header is printed
    [variables, data] = parseInputsForTable_(varargin{:});
    opts = opts_new();

    COLSEP = sprintf('\t');
    if m2t.cmdOpts.Results.externalData
        ROWSEP = sprintf('\n');
    else
        ROWSEP = sprintf('\\\\\n');
        opts = opts_add(opts, 'row sep','crcr');
    end

    nColumns = numel(data);
    nRows    = cellfun(@numel, data);
    if ~all(nRows==nRows(1))
        error('matlab2tikz:makeTableDifferentNumberOfRows',...
            'Different data lengths [%s].', num2str(nRows));
    end
    nRows = nRows(1);

    FORMAT = repmat({m2t.ff}, 1, nColumns);
    FORMAT(cellfun(@isCellOrChar, data)) = {'%s'};
    FORMAT = join(m2t, FORMAT, COLSEP);
    if all(cellfun(@isempty, variables))
        header = {};
    else
        header = {join(m2t, variables, COLSEP)};
    end

    table = cell(nRows,1);
    for iRow = 1:nRows
        thisData = cell(1,nColumns);
        for jCol = 1:nColumns
            thisData{1,jCol} = data{jCol}(iRow);
        end
        table{iRow} = sprintf(FORMAT, thisData{:});
    end
    table = lower(table); % convert NaN and Inf to lower case for TikZ
    table = [join(m2t, [header;table], ROWSEP) ROWSEP];

    if m2t.cmdOpts.Results.externalData
        % output data to external file
        m2t.dataFileNo = m2t.dataFileNo + 1;
        [filename, latexFilename] = externalFilename(m2t, m2t.dataFileNo, '.tsv');

        % write the data table to an external file
        fid = fileOpenForWrite(m2t, filename);
        finally_fclose_fid = onCleanup(@() fclose(fid));

        fprintf(fid, '%s', table);

        % put the filename in the TikZ output
        table = latexFilename;
    else
        % output data with "%newline" prepended for formatting consistency
        % do NOT prepend another newline in the output: LaTeX will crash.
        table = sprintf('%%\n%s', table);
    end
end
% ==============================================================================
function [variables, data] = parseInputsForTable_(varargin)
% parse input arguments for |makeTable|
    if numel(varargin) == 2 % cell syntax
        variables = varargin{1};
        data      = varargin{2};
        if ischar(variables)
            % one variable, one data vector -> (cell, cell)
            variables = {variables};
            data      = {data};
        elseif iscellstr(variables) && ~iscell(data)
            % multiple variables, one data matrix -> (cell, cell) by column
            data = num2cell(data, 1);
        end
    else % key-value syntax
        variables = varargin(1:2:end-1);
        data      = varargin(2:2:end);
    end
end
% ==============================================================================
function [path, texpath] = externalFilename(m2t, counter, extension)
% generates a file name for an external data file and its relative TeX path

    [dummy, name] = fileparts(m2t.tikzFileName); %#ok
    baseFilename  = [name '-' num2str(counter) extension];
    path    = fullfile(m2t.dataPath, baseFilename);
    texpath = TeXpath(fullfile(m2t.relativeDataPath, baseFilename));
end
% ==============================================================================
function [names,definitions] = dealColorDefinitions(mergedColorDefs)
    if isempty(mergedColorDefs)
        mergedColorDefs = {};
    end
    [names,definitions] = cellfun(@(x)(deal(x{:})),  mergedColorDefs, ...
        'UniformOutput', false);
end
% ==============================================================================
function [m2t, colorLiteral] = rgb2colorliteral(m2t, rgb)
% Translates an rgb value to an xcolor literal
%
% Possible outputs:
%  - xcolor literal color, e.g. 'blue'
%  - mixture of 2 previously defined colors, e.g. 'red!70!green'
%  - a newly defined color, e.g. 'mycolor10'

% Take a look at xcolor.sty for the color definitions.
% In xcolor.sty some colors are defined in CMYK space and approximated
% crudely for RGB color space. So it is better to redefine those colors
% instead of using xcolor's:
%    'cyan' , 'magenta', 'yellow', 'olive'
%    [0,1,1], [1,0,1]  , [1,1,0] , [0.5,0.5,0]

    xcolColorNames = {'white', 'black', 'red', 'green', 'blue', ...
                      'brown', 'lime', 'orange', 'pink', ...
                      'purple', 'teal', 'violet', ...
                      'darkgray', 'gray', 'lightgray'};
    xcolColorSpecs = {[1,1,1], [0,0,0], [1,0,0], [0,1,0], [0,0,1], ...
                      [0.75,0.5,0.25], [0.75,1,0], [1,0.5,0], [1,0.75,0.75], ...
                      [0.75,0,0.25], [0,0.5,0.5], [0.5,0,0.5], ...
                      [0.25,0.25,0.25], [0.5,0.5,0.5], [0.75,0.75,0.75]};

    colorNames = [xcolColorNames, m2t.extraRgbColorNames];
    colorSpecs = [xcolColorSpecs, m2t.extraRgbColorSpecs];

    %% check if rgb is a predefined color
    for kColor = 1:length(colorSpecs)
        Ck = colorSpecs{kColor}(:);
        if max(abs(Ck - rgb(:))) < m2t.colorPrecision
            colorLiteral = colorNames{kColor};
            return % exact color was predefined
        end
    end

    %% check if the color is a linear combination of two already defined colors
    for iColor = 1:length(colorSpecs)
        for jColor = iColor+1:length(colorSpecs)
            Ci = colorSpecs{iColor}(:);
            Cj = colorSpecs{jColor}(:);

            % solve color mixing equation `Ck = p * Ci + (1-p) * Cj` for p
            p  = (Ci-Cj) \ (rgb(:)-Cj);
            p  = round(100*p)/100;  % round to a percentage
            Ck = p * Ci + (1-p)*Cj; % approximated mixed color

            if p <= 1 && p >= 0 && max(abs(Ck(:) - rgb(:))) < m2t.colorPrecision
                colorLiteral = sprintf('%s!%d!%s', colorNames{iColor}, round(p*100), ...
                    colorNames{jColor});
                return % linear combination found
            end
        end
    end

    %% Define colors that are not a linear combination of two known colors
    colorLiteral = sprintf('mycolor%d', length(m2t.extraRgbColorNames)+1);
    m2t.extraRgbColorNames{end+1} = colorLiteral;
    m2t.extraRgbColorSpecs{end+1} = rgb;
end
% ==============================================================================
function newstr = join(m2t, cellstr, delimiter)
% This function joins a cell of strings to a single string (with a
% given delimiter in between two strings, if desired).
%
% Example of usage:
%              join(m2t, cellstr, ',')
    if isempty(cellstr)
        newstr = '';
        return
    end

    % convert all values to strings first
    nElem = numel(cellstr);
    for k = 1:nElem
        if isnumeric(cellstr{k})
            cellstr{k} = sprintf(m2t.ff, cellstr{k});
        elseif iscell(cellstr{k})
            cellstr{k} = join(m2t, cellstr{k}, delimiter);
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
    newstr = [newstr{:}];
end
% ==============================================================================
function [width, height, unit] = getNaturalFigureDimension(m2t)
    % Returns the size of figure (in inch)
    % To stay compatible with getNaturalAxesDimensions, the unit 'in' is
    % also returned.

    % Get current figure size
    figuresize = get(m2t.currentHandles.gcf, 'Position');
    figuresize = figuresize([3 4]);
    figureunit = get(m2t.currentHandles.gcf, 'Units');

    % Convert Figure Size
    unit = 'in';
    figuresize = convertUnits(figuresize, figureunit, unit);

    % Split size into width and height
    width  = figuresize(1);
    height = figuresize(2);

end
% ==============================================================================
function dimension = getFigureDimensions(m2t, widthString, heightString)
% Returns the physical dimension of the figure.

    [width, height, unit] = getNaturalFigureDimension(m2t);

    % get the natural width-height ration of the plot
    axesWidthHeightRatio = width / height;
    % check matlab2tikz arguments
    if ~isempty(widthString)
        width = extractValueUnit(widthString);
    end
    if ~isempty(heightString)
        height = extractValueUnit(heightString);
    end

    % prepare the output
    if ~isempty(widthString) && ~isempty(heightString)
        dimension.x.unit  = width.unit;
        dimension.x.value = width.value;
        dimension.y.unit  = height.unit;
        dimension.y.value = height.value;
    elseif ~isempty(widthString)
        dimension.x.unit  = width.unit;
        dimension.x.value = width.value;
        dimension.y.unit  = width.unit;
        dimension.y.value = width.value / axesWidthHeightRatio;
    elseif ~isempty(heightString)
        dimension.y.unit  = height.unit;
        dimension.y.value = height.value;
        dimension.x.unit  = height.unit;
        dimension.x.value = height.value * axesWidthHeightRatio;
    else % neither width nor height given
        dimension.x.unit  = unit;
        dimension.x.value = width;
        dimension.y.unit  = unit;
        dimension.y.value = height;
    end
end
% ==============================================================================
function position = getAxesPosition(m2t, handle, widthString, heightString, axesBoundingBox)
% Returns the physical position of the axes. This includes - in difference
% to the Dimension - also an offset to shift the axes inside the figure
% An optional bounding box can be used to omit empty borders.

    % Deal with optional parameter
    if nargin < 4
        axesBoundingBox = [0 0 1 1];
    end

    % First get the whole figures size
    figDim = getFigureDimensions(m2t, widthString, heightString);

    % Get the relative position of the axis
    relPos = getRelativeAxesPosition(m2t, handle, axesBoundingBox);

    position.x.value = relPos(1) * figDim.x.value;
    position.x.unit  = figDim.x.unit;
    position.y.value = relPos(2) * figDim.y.value;
    position.y.unit  = figDim.y.unit;
    position.w.value = relPos(3) * figDim.x.value;
    position.w.unit  = figDim.x.unit;
    position.h.value = relPos(4) * figDim.y.value;
    position.h.unit  = figDim.y.unit;
end
% ==============================================================================
function [position] = getRelativeAxesPosition(m2t, axesHandles, axesBoundingBox)
% Returns the relative position of axes within the figure.
% Position is an (n,4) matrix with [minX, minY, width, height] for each
% handle. All these values are relative to the figure size, which means
% that [0, 0, 1, 1] covers the whole figure.
% It is possible to add a second parameter with the relative coordinates of
% a bounding box around all axes of the figure (see getRelevantAxes()). In
% this case, relative positions are rescaled so that the bounding box is
% [0, 0, 1, 1]

    % Get Figure Dimension
    [figWidth, figHeight, figUnits] = getNaturalFigureDimension(m2t);

    % Initialize position
    position = zeros(numel(axesHandles), 4);
    % Iterate over all handles
    for i = 1:numel(axesHandles)
        axesHandle = axesHandles(i);
        axesPos = get(axesHandle, 'Position');
        axesUnits = get(axesHandle, 'Units');
        if isequal(lower(axesUnits), 'normalized')
            % Position is already relative
            position(i,:) = axesPos;
        else
            % Convert figure size into axes units
            figureSize = convertUnits([figWidth, figHeight], figUnits, axesUnits);
            % Figure size into axes units to get the relative size
            position(i,:) = axesPos ./ [figureSize, figureSize];

        end
        
        if strcmpi(get(axesHandle, 'DataAspectRatioMode'), 'manual') ...
                || strcmpi(get(axesHandle, 'PlotBoxAspectRatioMode'), 'manual')
                
            if strcmpi(get(axesHandle,'Projection'),'Perspective')
                userWarning(m2t,'Perspective projections are not currently supported')
            end
            
            % project vertices of 3d plot box (this results in 2d coordinates in
            % an absolute coordinate system that is scaled proportionally by
            % Matlab to fit the axes position box)
            switch getEnvironment()
                case 'MATLAB'
                    projection = view(axesHandle);

                case 'Octave'
                    % Unfortunately, Octave does not have the full `view` 
                    % interface implemented, but the projection matrices are
                    % available: http://octave.1599824.n4.nabble.com/Implementing-view-td3032041.html
                    
                    projection = get(axesHandle, 'x_viewtransform');

                otherwise
                    errorUnknownEnvironment();
            end
            
                
            vertices = projection * [0, 1, 0, 0, 1, 1, 0, 1;
                                     0, 0, 1, 0, 1, 0, 1, 1;
                                     0, 0, 0, 1, 0, 1, 1, 1; 
                                     1, 1, 1, 1, 1, 1, 1, 1];
                         
            % each of the columns of vertices represents a vertex of the 3D axes
            % but we only need their XY coordinates
            verticesXY = vertices([1 2], :);
                                
            % the size of the projected plot box is limited by the long diagonals
            % The matrix A determines the connectivity, e.g. the first diagonal runs from vertices(:,3) -> vertices(:,4)
            A = [ 0,  0,  0, -1, +1,  0,  0,  0;
                  0,  0, -1,  0,  0, +1,  0,  0;
                  0, -1,  0,  0,  0,  0, +1,  0;
                 -1,  0,  0,  0,  0,  0,  0, +1];
            diagonals = verticesXY * A';
            % each of the columns of this matrix contains a the X and Y distance of a diagonal
            dimensions = max(abs(diagonals), [], 2);
            
            % find limiting dimension and adjust position
            aspectRatio = dimensions(2) * figWidth / (dimensions(1) * figHeight);
            axesAspectRatio = position(i,4) / position(i,3);
            if aspectRatio > axesAspectRatio
                newWidth = position(i,4) / aspectRatio;
                % Center Axis
                offset = (position(i,3) - newWidth) / 2;
                position(i,1) = position(i,1) + offset;
                % Store new width
                position(i,3) = newWidth;
            else
                newHeight = position(i,3) * aspectRatio;
                offset = (position(i,4) - newHeight) / 2;
                position(i,2) = position(i,2) + offset;
                % Store new height
                position(i,4) = newHeight;
            end
        end
    end

    %% Rescale if axesBoundingBox is given
    if exist('axesBoundingBox','var')
        % shift position so that [0, 0] is the lower left corner of the
        % bounding box
        position(:,1) = position(:,1) - axesBoundingBox(1);
        position(:,2) = position(:,2) - axesBoundingBox(2);
        % Recale
        position(:,[1 3]) = position(:,[1 3]) / max(axesBoundingBox([3 4]));
        position(:,[2 4]) = position(:,[2 4]) / max(axesBoundingBox([3 4]));
    end
end
% ==============================================================================
function aspectRatio = getPlotBoxAspectRatio(axesHandle)
    limits = axis(axesHandle);
    if any(isinf(limits))
        aspectRatio = get(axesHandle,'PlotBoxAspectRatio');
    else
        % DataAspectRatio has priority
        dataAspectRatio = get(axesHandle,'DataAspectRatio');
        nlimits         = length(limits)/2;
        limits          = reshape(limits, 2, nlimits);
        aspectRatio     = abs(limits(2,:) - limits(1,:))./dataAspectRatio(1:nlimits);
        aspectRatio     = aspectRatio/min(aspectRatio);
    end
end
% ==============================================================================
function texUnits = matlab2texUnits(matlabUnits, fallbackValue)
    switch matlabUnits
        case 'pixels'
            texUnits = 'px'; % only in pdfTex/LuaTeX
        case 'centimeters'
            texUnits = 'cm';
        case 'characters'
            texUnits = 'em';
        case 'points'
            texUnits = 'pt';
        case 'inches'
            texUnits = 'in';
        otherwise
            texUnits = fallbackValue;
    end
end
% ==============================================================================
function dstValue = convertUnits(srcValue, srcUnit, dstUnit)
% Converts values between different units.
%   srcValue stores a length (or vector of lengths) in srcUnit.
% The resulting dstValue is the converted length into dstUnit.
%
% Currently supported units are: in, cm, px, pt

    % Use tex units, if possible (to make things simple)
    srcUnit = matlab2texUnits(lower(srcUnit),lower(srcUnit));
    dstUnit = matlab2texUnits(lower(dstUnit),lower(dstUnit));

    if isequal(srcUnit, dstUnit)
        dstValue = srcValue;
        return % conversion to the same unit => factor = 1
    end

    units  = {srcUnit, dstUnit};
    factor = ones(1,2);
    for ii = 1:numel(factor) % Same code for srcUnit and dstUnit
        % Use inches as intermediate unit
        % Compute the factor to convert an inch into another unit
        switch units{ii}
            case 'cm'
               factor(ii) = 2.54;
            case 'px'
               factor(ii) = get(0, 'ScreenPixelsPerInch');
            case 'in'
                factor(ii) = 1;
            case 'pt'
                factor(ii) = 72;
            otherwise
                warning('MATLAB2TIKZ:UnknownPhysicalUnit',...
                'Can not convert unit ''%s''. Using conversion factor 1.', units{ii});
        end
    end

    dstValue = srcValue * factor(2) / factor(1);
end
% ==============================================================================
function out = extractValueUnit(str)
% Decompose m2t.cmdOpts.Results.width into value and unit.

    % Regular expression to match '4.12cm', '\figurewidth', ...
    fp_regex = '[-+]?\d*\.?\d*(?:e[-+]?\d+)?';
    pattern = strcat('(', fp_regex, ')?', '(\\?[a-zA-Z]+)');

    [dummy,dummy,dummy,dummy,t,dummy] = regexp(str, pattern, 'match'); %#ok

    if length(t)~=1
        error('getAxesDimensions:illegalLength', ...
            'The width string ''%s'' could not be decomposed into value-unit pair.', str);
    end

    if length(t{1}) == 1
        out.value = 1.0; % such as in '1.0\figurewidth'
        out.unit  = strtrim(t{1}{1});
    elseif length(t{1}) == 2 && isempty(t{1}{1})
        % MATLAB(R) does this:
        % length(t{1})==2 always, but the first field may be empty.
        out.value = 1.0;
        out.unit  = strtrim(t{1}{2});
    elseif length(t{1}) == 2
        out.value = str2double(t{1}{1});
        out.unit  = strtrim(t{1}{2});
    else
        error('getAxesDimensions:illegalLength', ...
            'The width string ''%s'' could not be decomposed into value-unit pair.', str);
    end
end
% ==============================================================================
function str = escapeCharacters(str)
% Replaces "%" and "\" with respectively "%%" and "\\"
    str = strrep(str, '%' , '%%');
    str = strrep(str, '\' , '\\');
end
% ==============================================================================
function bool = isNone(value)
% Checks whether a value is 'none'
    bool = strcmpi(value, 'none');
end
% ==============================================================================
function val = getOrDefault(handle, key, default)
% gets the value or returns the default value if no such property exists
    if all(isprop(handle, key))
        val = get(handle, key);
    else
        val = default;
    end
end
% ==============================================================================
function val = getFactoryOrDefault(type, key, fallback)
% get factory default value for a certain type of HG object
% this CANNOT be done using |getOrDefault| as |isprop| doesn't work for
% factory/default settings. Hence, we use a more expensive try-catch instead.
    try
        groot = 0;
        val = get(groot, ['Factory' type key]);
    catch
        val = fallback;
    end
end
% ==============================================================================
function [val, isDefault] = getAndCheckDefault(type, handle, key, default)
% gets the value from a handle of certain type and check the default values
    default   = getFactoryOrDefault(type, key, default);
    val       = getOrDefault(handle, key, default);
    isDefault = isequal(val, default);
end
% ==============================================================================
function opts = addIfNotDefault(m2t, type, handle, key, default, pgfKey, opts)
% sets an option in the options array named `pgfKey` if the MATLAB option is
% not a default value
% FIXME: this function is currently unused -- remove it in the future?
    [value, isDefault] = getAndCheckDefault(type, handle, key, default);
    if ~isDefault || m2t.cmdOpts.Results.strict
        opts = opts_add(opts, pgfKey, value);
    end
end
% ==============================================================================
function bool = isVisible(handles)
% Determines whether an object is actually visible or not.
    bool = strcmpi(get(handles,'Visible'), 'on');
    % There's another handle property, 'HandleVisibility', which may or may not
    % determine the visibility of the object. Empirically, it seems to be 'off'
    % whenever we're dealing with an object that's not user-created, such as
    % automatic axis ticks, baselines in bar plots, axis lines for polar plots
    % and so forth. For now, don't check 'HandleVisibility'.
end
% ==============================================================================
function [m2t, axesBoundingBox] = getRelevantAxes(m2t, axesHandles)
% Returns relevant axes. These are defines as visible axes that are no
% colorbars. Function 'findPlotAxes()' ensures that 'axesHandles' does not
% contain colorbars. In addition, a bounding box around all relevant Axes is
% computed. This can be used to avoid undesired borders.
% This function is the remaining code of alignSubPlots() in the alternative
% positioning system.

    % List only visible axes
    N   = numel(axesHandles);
    idx = false(N,1);
    for ii = 1:N
       idx(ii) = isVisibleContainer(axesHandles(ii));
    end
    % Store the relevant axes in m2t to simplify querying e.g. positions
    % of subplots
    m2t.relevantAxesHandles = double(axesHandles(idx));

    % Compute the bounding box if width or height of the figure are set by
    % parameter
    if ~isempty(m2t.cmdOpts.Results.width) || ~isempty(m2t.cmdOpts.Results.height)
        % TODO: check if relevant Axes or all Axes are better.
        axesBoundingBox = getRelativeAxesPosition(m2t, m2t.relevantAxesHandles);
        % Compute second corner from width and height for each axes
        axesBoundingBox(:,[3 4]) = axesBoundingBox(:,[1 2]) + axesBoundingBox(:,[3 4]);
        % Combine axes corners to get the bounding box
        axesBoundingBox = [min(axesBoundingBox(:,[1 2]),[],1), max(axesBoundingBox(:,[3 4]), [], 1)];
        % Compute width and height of the bounding box
        axesBoundingBox(:,[3 4]) = axesBoundingBox(:,[3 4]) - axesBoundingBox(:,[1 2]);
    else
        % Otherwise take the whole figure as bounding box => lengths are
        % not changed in tikz
        axesBoundingBox = [0, 0, 1, 1];
    end
end
% ==============================================================================
function userInfo(m2t, message, varargin)
% Display usage information.
    if m2t.cmdOpts.Results.showInfo
        mess = sprintf(message, varargin{:});

        mess = strrep(mess, sprintf('\n'), sprintf('\n *** '));
        fprintf(' *** %s\n', mess);
    end
end
% ==============================================================================
function userWarning(m2t, message, varargin)
% Drop-in replacement for warning().
    if m2t.cmdOpts.Results.showWarnings
        warning('matlab2tikz:userWarning', message, varargin{:});
    end
end
% ==============================================================================
function warnAboutParameter(m2t, parameter, isActive, message)
% warn the user about the use of a dangerous parameter
    line = ['\n' repmat('=',1,80) '\n'];
    if isActive(m2t.cmdOpts.Results.(parameter))
        userWarning(m2t, [line, 'You are using the "%s" parameter.\n', ...
                          message line], parameter);
    end
end
% ==============================================================================
function parent = addChildren(parent, children)
    if isempty(children)
        return;
    elseif iscell(children)
        for k = 1:length(children)
            parent = addChildren(parent, children{k});
        end
    else
        if isempty(parent.children)
            parent.children = {children};
        else
            parent.children = {parent.children{:} children};
        end
    end
end
% ==============================================================================
function printAll(m2t, env, fid)
    if isfield(env, 'colors') && ~isempty(env.colors)
        fprintf(fid, '%s', env.colors);
    end

    if isempty(env.options)
        fprintf(fid, '\\begin{%s}\n', env.name);
    else
        fprintf(fid, '\\begin{%s}[%%\n%s\n]\n', env.name, ...
                opts_print(m2t, env.options, sprintf(',\n')));
    end

    for item = env.content
        fprintf(fid, '%s', char(item));
    end

    for k = 1:length(env.children)
        if ischar(env.children{k})
            fprintf(fid, escapeCharacters(env.children{k}));
        else
            fprintf(fid, '\n');
            printAll(m2t, env.children{k}, fid);
        end
    end

    % End the tikzpicture environment with an empty comment and no newline
    % so no additional space is generated after the tikzpicture in TeX.
    if strcmp(env.name, 'tikzpicture') % LaTeX is case sensitive
        fprintf(fid, '\\end{%s}%%', env.name);
    else
        fprintf(fid, '\\end{%s}\n', env.name);
    end
end
% ==============================================================================
function c = prettyPrint(m2t, strings, interpreter)
% Some resources on how MATLAB handles rich (TeX) markup:
% http://www.mathworks.com/help/techdoc/ref/text_props.html#String
% http://www.mathworks.com/help/techdoc/creating_plots/f0-4741.html#f0-28104
% http://www.mathworks.com/help/techdoc/ref/text_props.html#Interpreter
% http://www.mathworks.com/help/techdoc/ref/text.html#f68-481120

    strings = cellstrOneLinePerCell(strings);

    % Now loop over the strings and return them pretty-printed in c.
    c = {};
    for k = 1:length(strings)
        % linear indexing for independence of cell array dimensions
        s = strings{k};

        % If the user set the matlab2tikz parameter 'parseStrings' to false, no
        % parsing of strings takes place, thus making the user 100% responsible.
        if ~m2t.cmdOpts.Results.parseStrings
            c = strings;
            return
        end

        % Make sure we have a valid interpreter set up
        if ~any(strcmpi(interpreter, {'latex', 'tex', 'none'}))
            userWarning(m2t, 'Don''t know interpreter ''%s''. Default handling.', interpreter);
            interpreter = 'tex';
        end

        % The interpreter property of the text element defines how the string
        % is parsed
        switch lower(interpreter)
            case 'latex' % Basic subset of the LaTeX markup language

                % Replace $$...$$ with $...$ for groups, but otherwise leave
                % untouched.
                % Displaymath \[...\] seems to be unsupported by TikZ/PGF.
                % If this changes, use '\\[$2\\]' as replacement below.
                % Do not escape dollar in replacement string (e.g., "\$$2\$"),
                % since this is not properly handled by octave 3.8.2.
                string = regexprep(s, '(\$\$)(.*?)(\$\$)', '$$2$');

            case 'tex' % Subset of plain TeX markup language

                % Deal with UTF8 characters.
                string = s;

                % degree symbol following "^" or "_" needs to be escaped
                string = regexprep(string, '([\^\_])°', '$1{{}^\\circ}');
                string = strrep(string, '°', '^\circ');
                string = strrep(string, '∞', '\infty');

                % Parse string piece-wise in a separate function.
                string = parseTexString(m2t, string);

            case 'none' % Literal characters
                % Make special characters TeX compatible

                string = strrep(s, '\', '\textbackslash{}');
                % Note: '{' and '}' can't be converted to '\{' and '\}',
                %       respectively, via strrep(...) as this would lead to
                %       backslashes converted to '\textbackslash\{\}' because
                %       the backslash was converted to '\textbackslash{}' in
                %       the previous step. Using regular expressions with
                %       negative look-behind makes sure any braces in 'string'
                %       were not introduced by escaped backslashes.
                %       Also keep in mind that escaping braces before backslashes
                %       would not remedy the issue -- in that case 'string' would
                %       contain backslashes introduced by brace escaping that are
                %       not supposed to be printable characters.
                repl = switchMatOct('\\{', '\{');
                string = regexprep(string, '(?<!\\textbackslash){', repl);
                repl = switchMatOct('\\}', '\}');
                string = regexprep(string, '(?<!\\textbackslash{)}', repl);
                string = strrep(string, '$', '\$');
                string = strrep(string, '%', '\%');
                string = strrep(string, '_', '\_');
                string = strrep(string, '^', '\textasciicircum{}');
                string = strrep(string, '#', '\#');
                string = strrep(string, '&', '\&');
                string = strrep(string, '~', '\textasciitilde{}'); % or '\~{}'
                % Clean up: remove superfluous '{}' if it's followed by a backslash
                string = strrep(string, '{}\', '\');
                % Clean up: remove superfluous '{}' at the end of 'string'
                string = regexprep(string, '\{\}$', '');

                % Make sure to return a string and not a cellstr.
                if iscellstr(string)
                    string = string{1};
                end
            otherwise
                error('matlab2tikz:prettyPrint', 'Unknown interpreter');
        end
        c{end+1} = string;
    end
end
% ==============================================================================
function strings = cellstrOneLinePerCell(strings)
% convert to cellstr that contains only one-line strings
    if ischar(strings)
        strings = cellstr(strings);
    elseif iscellstr(strings)
        cs = {};
        for s = strings
            tmp = cellstr(s);
            cs = {cs{:}, tmp{:}};
        end
        strings = cs;
    else
        error('matlab2tikz:cellstrOneLinePerCell', ...
            'Data type not understood.');
    end
end
% ==============================================================================
function parsed = parseTexString(m2t, string)
    if iscellstr(string)
        % Convert cell string to regular string, otherwise MATLAB complains
        string = string{:};
    end

    % Get the position of all braces
    bracesPos = regexp(string, '\{|\}');

    % Exclude braces that are part of any of these MATLAB-supported TeX commands:
    % \color{...}  \color[...]{...}  \fontname{...}  \fontsize{...}
    [sCmd, eCmd] = regexp(string, '\\(color(\[[^\]]*\])?|fontname|fontsize)\{[^}]*\}');
    for i = 1:length(sCmd)
        bracesPos(bracesPos >= sCmd(i) & bracesPos <= eCmd(i)) = [];
    end

    % Exclude braces that are preceded by an odd number of backslashes which
    % means the brace is escaped and thus to be printed, not a grouping brace
    expr = '(?<!\\)(\\\\)*\\(\{|\})';
    escaped = regexp(string, expr, 'end');
    % It's necessary to go over 'string' with the same RegEx again to catch
    % overlapping matches, e.g. string == '\{\}'. In such a case the simple
    % regexp(...) above only finds the first brace. What we have to do is look
    % only at the part of 'string' that starts with the first brace but doesn't
    % encompass its escaping backslash. Iterating over all previously found
    % matches makes sure all overlapping matches are found, too. That way even
    % cases like string == '\{\} \{\}' are handled correctly.
    % The call to unique(...) is not necessary to get the behavior described, but
    % by removing duplicates in 'escaped' it's cleaner than without.
    for i = escaped
        escaped = unique([escaped, regexp(string(i:end), expr, 'end') + i-1]);
    end
    % Now do the actual removal of escaped braces
    for i = 1:length(escaped)
        bracesPos(bracesPos == escaped(i)) = [];
    end

    parsed = '';
    % Have a virtual brace one character left of where the actual string
    % begins (remember, MATLAB strings start counting at 1, not 0). This is
    % to make sure substrings left of the first brace get parsed, too.
    prevBracePos = 0;
    % Iterate over all the brace positions in order to split up 'string'
    % at those positions and then parse the substrings. A virtual brace is
    % added right of where the actual string ends to make sure substrings
    % right of the right-most brace get parsed as well.
    for currBracePos = [bracesPos, length(string)+1]
        if (prevBracePos + 1) < currBracePos
            % Parse the substring between (but not including) prevBracePos
            % and currBracePos, i.e. between the previous brace and the
            % current one (but only if there actually is a non-empty
            % substring). Then append it to the output string.
            substring = string(prevBracePos+1 : currBracePos-1);
            parsed = [parsed, parseTexSubstring(m2t, substring)];
        end
        if currBracePos <= length(string)
            % Append the brace itself to the output string, but only if the
            % current brace position is within the limits of the string, i.e.
            % don't append anything for the last, virtual brace that is only
            % there to enable parsing of substrings beyond the right-most
            % actual brace.
            brace = string(currBracePos);
            parsed = [parsed, brace];
        end
        % The current brace position will be next iteration's previous one
        prevBracePos = currBracePos;
    end

    % Enclose everything in $...$ to use math mode
    parsed = ['$' parsed '$'];
    % ...except when everything is text
    parsed = regexprep(parsed, '^\$\\text\{([^}]*)\}\$$', '$1');
    % start-> $ \text {(non-}) } $<-end
    % ...or when the parsed string is empty
    parsed = regexprep(parsed, '^\$\$$', '');

    % Ensure math mode for pipe symbol (issue #587)
    parsed = strrep(parsed, '|', '$|$');
end
% ==============================================================================
function string = parseTexSubstring(m2t, string)
    origstr = string; % keep this for warning messages

    % Font families (italic, bold, etc.) get a trailing '{}' because they may be
    % followed by a letter which would produce an error in (La)TeX.
    for i = {'it', 'bf', 'rm', 'sl'}
        string = strrep(string, ['\' i{:}], ['\' i{:} '{}']);
    end

    % The same holds true for special characters like \alpha
    % The list of MATLAB-supported TeX characters was taken from
    % http://www.mathworks.com/help/techdoc/ref/text_props.html#String
    named = {'alpha', 'angle', 'ast', 'beta', 'gamma', 'delta',     ...
        'epsilon', 'zeta', 'eta', 'theta', 'vartheta', 'iota', ...
        'kappa', 'lambda', 'mu', 'nu', 'xi', 'pi', 'rho',      ...
        'sigma', 'varsigma', 'tau', 'equiv', 'Im', 'otimes',   ...
        'cap', 'int', 'rfloor', 'lfloor', 'perp', 'wedge',     ...
        'rceil', 'vee', 'langle', 'upsilon', 'phi', 'chi',     ...
        'psi', 'omega', 'Gamma', 'Delta', 'Theta', 'Lambda',   ...
        'Xi', 'Pi', 'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega', ...
        'forall', 'exists', 'ni', 'cong', 'approx', 'Re',      ...
        'oplus', 'cup', 'subseteq', 'lceil', 'cdot', 'neg',    ...
        'times', 'surd', 'varpi', 'rangle', 'sim', 'leq',      ...
        'infty', 'clubsuit', 'diamondsuit', 'heartsuit',       ...
        'spadesuit', 'leftrightarrow', 'leftarrow',            ...
        'Leftarrow', 'uparrow', 'rightarrow', 'Rightarrow',    ...
        'downarrow', 'circ', 'pm', 'geq', 'propto', 'partial', ...
        'bullet', 'div', 'neq', 'aleph', 'wp', 'oslash',       ...
        'supseteq', 'nabla', 'ldots', 'prime', '0', 'mid',     ...
        'copyright'                                            };
    for i = named
        string = strrep(string, ['\' i{:}], ['\' i{:} '{}']);
        % FIXME: Only append '{}' if there's an odd number of backslashes
        %        in front of the items from 'named'. If it's an even
        %        number instead, that means there's an escaped (printable)
        %        backslash and some text like "alpha" after that.
    end
    % Some special characters' names are subsets of others, e.g. '\o' is
    % a subset of '\omega'. This would produce undesired double-escapes.
    % For example if '\o' was converted to '\o{}' after '\omega' has been
    % converted to '\omega{}' this would result in '\o{}mega{}' instead of
    % '\omega{}'. Had '\o' been converted to '\o{}' _before_ '\omega' is
    % converted then the result would be '\o{}mega' and thus also wrong.
    % To circumvent the problem all those special character names that are
    % subsets of others are now converted using a regular expression that
    % uses negative lookahead. The special handling of the backslash is
    % required for MATLAB/Octave compatibility.
    string = regexprep(string, '(\\)o(?!mega|times|plus|slash)', '$1o{}');
    string = regexprep(string, '(\\)in(?!t|fty)', '$1in{}');
    string = regexprep(string, '(\\)subset(?!eq)', '$1subset{}');
    string = regexprep(string, '(\\)supset(?!eq)', '$1supset{}');

    % Convert '\0{}' (TeX text mode) to '\emptyset{}' (TeX math mode)
    string = strrep(string, '\0{}', '\emptyset{}');

    % Add skip to \fontsize
    % This is required for a successful LaTeX run on the output as in contrast
    % to MATLAB/Octave it requires the skip parameter (even if it's zero)
    string = regexprep(string, '(\\fontsize\{[^}]*\})', '$1{0}');

    % Put '\o{}' inside \text{...} as it is a text mode symbol that does not
    % exist in math mode (and LaTeX gives a warning if you use it in math mode)
    string = strrep(string, '\o{}', '\text{\o{}}');

    % Put everything that isn't a TeX command inside \text{...}
    expr = '(\\[a-zA-Z]+(\[[^\]]*\])?(\{[^}]*\}){1,2})';
    % |( \cmd  )( [...]?  )( {...}{1,2} )|
    % (              subset $1               )
    repl = '}$1\\text{';
    string = regexprep(string, expr, repl);
    % ...\alpha{}... -> ...}\alpha{}\text{...
    string = ['\text{' string '}'];
    % ...}\alpha{}\text{... -> \text{...}\alpha{}\text{...}

    % '_' has to be in math mode so long as it's not escaped as '\_' in which
    % case it remains as-is. Extra care has to be taken to make sure any
    % backslashes in front of the underscore are not themselves escaped and
    % thus printable backslashes. This is the case if there's an even number
    % of backslashes in a row.
    repl = '$1}_\\text{';
    string = regexprep(string, '(?<!\\)((\\\\)*)_', repl);

    % '^' has to be in math mode so long as it's not escaped as '\^' in which
    % case it is expressed as '\textasciicircum{}' for compatibility with
    % regular TeX. Same thing here regarding even/odd number of backslashes
    % as in the case of underscores above.
    repl = '$1\\textasciicircum{}';
    string = regexprep(string, '(?<!\\)((\\\\)*)\\\^', repl);
    repl = '$1}^\\text{';
    string = regexprep(string, '(?<!\\)((\\\\)*)\^', repl);

    % '<' and '>' has to be either in math mode or needs to be typeset as
    % '\textless' and '\textgreater' in textmode
    % This is handled better, if 'parseStringsAsMath' is activated
    if m2t.cmdOpts.Results.parseStringsAsMath == 0
        string = regexprep(string, '<', '\\textless{}');
        string = regexprep(string, '>', '\\textgreater{}');
    end

    % Move font styles like \bf into the \text{} command.
    expr = '(\\bf|\\it|\\rm|\\fontname)({\w*})+(\\text{)';
    while regexp(string, expr)
        string = regexprep(string, expr, '$3$1$2');
    end

    % Replace Fontnames
    [dummy, dummy, dummy, dummy, fonts, dummy, subStrings] = regexp(string, '\\fontname{(\w*)}'); %#ok
    fonts = fonts2tex(fonts);
    subStrings = [subStrings; fonts, {''}];
    string = cell2mat(subStrings(:)');

    % Merge adjacent \text fields:
    string = mergeAdjacentTexCmds(string, '\text');

    % '\\' has to be escaped to '\textbackslash{}'
    % This cannot be done with strrep(...) as it would replace e.g. 4 backslashes
    % with three times the replacement string because it finds overlapping matches
    % (see http://www.mathworks.de/help/techdoc/ref/strrep.html)
    % Note: Octave's backslash handling is broken. Even though its output does
    % not resemble MATLAB's, the same m2t code is used for either software. That
    % way MATLAB-compatible code produces the same matlab2tikz output no matter
    % which software it's executed in. So long as this MATLAB incompatibility
    % remains in Octave you're probably better off not using backslashes in TeX
    % text anyway.
    string = regexprep(string, '(\\)\\', '$1textbackslash{}');

    % '_', '^', '{', and '}' are already escaped properly, even in MATLAB's TeX
    % dialect (and if they're not, that's intentional)

    % Escape "$", "%", and "#" to make them compatible to true TeX while in
    % MATLAB/Octave they are not escaped
    string = strrep(string, '$', '\$');
    string = strrep(string, '%', '\%');
    string = strrep(string, '#', '\#');

    % Escape "§" as "\S" since it can give UTF-8 problems otherwise.
    % The TeX string 'a_§' in particular lead to problems in Octave 3.6.0.
    % m2t transcoded that string into '$\text{a}_\text{*}\text{#}$' with
    % * = 0xC2 and # = 0xA7 which corresponds with the two-byte UTF-8
    % encoding. Even though this looks like an Octave bug that shows
    % during the '..._\text{abc}' to '..._\text{a}\text{bc}' conversion,
    % it's best to include the workaround here.
    string = strrep(string, '§', '\S{}');

    string = escapeAmpersands(m2t, string, origstr);
    string = escapeTildes(m2t, string, origstr);

    % Convert '..._\text{abc}' and '...^\text{abc}' to '..._\text{a}\text{bc}'
    % and '...^\text{a}\text{bc}', respectively.
    % Things get a little more complicated if instead of 'a' it's e.g. '$'. The
    % latter has been converted to '\$' by now and simply extracting the first
    % character from '\text{\$bc}' would result in '\text{$}\text{$bc}' which
    % is syntactically wrong. Instead the whole command '\$' has to be moved in
    % front of the \text{...} block, e.g. '..._\text{\$bc}' -> '..._\$\text{bc}'.
    % Note that the problem does not occur for the majority of special characters
    % like '\alpha' because they use math mode and therefore are never inside a
    % \text{...} block to begin with. This means that the number of special
    % characters affected by this issue is actually quite small:
    %   $ # % & _ { } \o § ~ \ ^
    expr = ['(_|\^)(\\text)\{([^}\\]|\\\$|\\#|\\%|\\&|\\_|\\\{|\\\}|', ...
        ... %   (_/^)(\text) {(non-}\| \$ | \#| \%| \&| \_| \{ | \} |
        ... %   ($1)( $2 )  (                 $3                      ->
        '\\o\{\}|\\S\{\}|\\textasciitilde\{\}|\\textbackslash\{\}|', ...
        ... %    \o{}  | \S{}  | \textasciitilde{}  | \textbackslash{}  |
        ... %  <-                         $3                                 ->
        '\\textasciicircum\{\})'];
    %    \textasciicircum{} )
    %  <-      $3           )
    string = regexprep(string, expr, '$1$2{$3}$2{');

    string = parseStringsAsMath(m2t, string);

    % Clean up: remove empty \text{}
    string = strrep(string, '\text{}', '');
    % \text{}\alpha{}\text{...} -> \alpha{}\text{...}

    % Clean up: convert '{}\' to '\' unless it's prefixed by a backslash which
    % means the opening brace is escaped and thus a printable character instead
    % of a grouping brace.
    string = regexprep(string, '(?<!\\)\{\}(\\)', '$1');
    % \alpha{}\text{...} -> \alpha\text{...}

    % Clean up: convert '{}}' to '}' unless it's prefixed by a backslash
    string = regexprep(string, '(?<!\\)\{\}\}', '}');

    % Clean up: remove '{}' at the end of 'string' unless it's prefixed by a
    % backslash
    string = regexprep(string, '(?<!\\)\{\}$', '');
end
% ==============================================================================
function string = escapeTildes(m2t, string, origstr)
% Escape plain "~" in MATLAB and replace escaped "\~" in Octave with a proper
% escape sequence. An un-escaped "~" produces weird output in Octave, thus
% give a warning in that case
    switch getEnvironment
        case 'MATLAB'
            string = strrep(string, '~', '\textasciitilde{}'); % or '\~{}'
        case 'Octave'
            string = strrep(string, '\~', '\textasciitilde{}'); % ditto
            if regexp(string, '(?<!\\)~')
                userWarning(m2t,                                     ...
                    ['TeX string ''%s'' contains un-escaped ''~''. ' ...
                    'For proper display in Octave you probably '     ...
                    'want to escape it even though that''s '         ...
                    'incompatible with MATLAB. '                     ...
                    'In the matlab2tikz output it will have its '    ...
                    'usual TeX function as a non-breaking space.'],  ...
                    origstr)
            end
        otherwise
            errorUnknownEnvironment();
    end
end
% ==============================================================================
function string = escapeAmpersands(m2t, string, origstr)
% Escape plain "&" in MATLAB and replace it and the following character with
% a space in Octave unless the "&" is already escaped
    switch getEnvironment
        case 'MATLAB'
            string = strrep(string, '&', '\&');
        case 'Octave'
            % Ampersands should already be escaped in Octave.
            % Octave (tested with 3.6.0) handles un-escaped ampersands a little
            % funny in that it removes the following character, if there is one:
            % 'abc&def'      -> 'abc ef'
            % 'abc&\deltaef' -> 'abc ef'
            % 'abc&$ef'      -> 'abc ef'
            % 'abcdef&'      -> 'abcdef'
            % Don't remove closing brace after '&' as this would result in
            % unbalanced braces
            string = regexprep(string, '(?<!\\)&(?!})', ' ');
            string = regexprep(string, '(?<!\\)&}', '}');
            if regexp(string, '(?<!\\)&\\')
                % If there's a backslash after the ampersand, that means not only
                % the backslash should be removed but the whole escape sequence,
                % e.g. '\delta' or '\$'. Actually the '\delta' case is the
                % trickier one since by now 'string' would have been turned from
                % 'abc&\deltaef' into '\text{abc&}\delta{}\text{ef}', i.e. after
                % the ampersand first comes a closing brace and then '\delta';
                % the latter as well as the ampersand itself should be removed
                % while the brace must remain in place to avoid unbalanced braces.
                userWarning(m2t,                                                ...
                    ['TeX string ''%s'' contains a special character '  ...
                    'after an un-escaped ''&''. The output generated ' ...
                    'by matlab2tikz will not precisely match that '    ...
                    'which you see in Octave itself in that the '      ...
                    'special character and the preceding ''&'' is '    ...
                    'not replaced with a space.'], origstr)
            end
        otherwise
            errorUnknownEnvironment();
    end
end
% ==============================================================================
function [string] = parseStringsAsMath(m2t, string)
% Some further processing makes the output behave more like TeX math mode,
% but only if the matlab2tikz parameter parseStringsAsMath=true.
    if m2t.cmdOpts.Results.parseStringsAsMath

        % Some characters should be in math mode: =-+/,.()<>0-9
        expr = '(\\text)\{([^}=\-+/,.()<>0-9]*)([=\-+/,.()<>0-9]+)([^}]*)\}';
        %    \text  {(any non-"x"/'}'char)( any "x" char  )(non-}) }
        %  ( $1 )  (       $2        )(      $3       )( $4)
        while regexp(string, expr)
            % Iterating is necessary to catch all occurrences. See above.
            string = regexprep(string, expr, '$1{$2}$3$1{$4}');
        end

        % \text{ } should be a math-mode space
        string = regexprep(string, '\\text\{(\s+)}', '$1');

        % '<<' probably means 'much smaller than', i.e. '\ll'
        repl = switchMatOct('$1\\ll{}$2', '$1\ll{}$2');
        string = regexprep(string, '([^<])<<([^<])', repl);

        % '>>' probably means 'much greater than', i.e. '\gg'
        repl = switchMatOct('$1\\gg{}$2', '$1\gg{}$2');
        string = regexprep(string, '([^>])>>([^>])', repl);

        % Single letters are most likely variables and thus should be in math mode
        string = regexprep(string, '\\text\{([a-zA-Z])\}', '$1');

    end
end
% ==============================================================================
function tex = fonts2tex(fonts)
% Returns a tex command for each fontname in the cell array fonts.
    if ~iscell(fonts)
        error('matlab2tikz:fonts2tex', ...
                 'Expecting a cell array as input.');
    end
    tex = cell(size(fonts));

    for ii = 1:numel(fonts)
        font = fonts{ii}{1};

        % List of known fonts.
        switch lower(font)
            case 'courier'
                tex{ii} = '\ttfamily{}';
            case 'times'
                tex{ii} = '\rmfamily{}';
            case {'arial', 'helvetica'}
                tex{ii} = '\sffamily{}';
            otherwise
                warning('matlab2tikz:fonts2tex', ...
                    'Unknown font ''%s''. Using tex default font.',font);
                % Unknown font -> Switch to standard font.
                tex{ii} = '\rm{}';
        end
    end
end
% ==============================================================================
function string = mergeAdjacentTexCmds(string, cmd)
% Merges adjacent tex commands like \text into one command
    % If necessary, add a backslash
    if cmd(1) ~= '\'
        cmd = ['\' cmd];
    end
    % Link each bracket to the corresponding bracket
    link = zeros(size(string));
    pos = [regexp([' ' string], '([^\\]{)'), ...
        regexp([' ' string], '([^\\]})')];
    pos = sort(pos);
    ii = 1;
    while ii <= numel(pos)
        if string(pos(ii)) == '}'
            link(pos(ii-1)) = pos(ii);
            link(pos(ii)) = pos(ii - 1);
            pos([ii-1, ii]) = [];
            ii = ii - 1;
        else
            ii = ii + 1;
        end
    end
    % Find dispensable commands
    pos = regexp(string, ['}\' cmd '{']);
    delete = zeros(0,1);
    len = numel(cmd);
    for p = pos
        l = link(p);
        if l > len && isequal(string(l-len:l-1), cmd)
            delete(end+1,1) = p;
        end
    end
    %   3. Remove these commands (starting from the back
    delete = repmat(delete, 1, len+2) + repmat(0:len+1,numel(delete), 1);
    string(delete(:)) = [];
end
function dims = pos2dims(pos)
% Position quadruplet [left, bottom, width, height] to dimension structure
    dims = struct('left' , pos(1), 'bottom', pos(2));
    if numel(pos) == 4
        dims.width  = pos(3);
        dims.height = pos(4);
        dims.right  = dims.left   + dims.width;
        dims.top    = dims.bottom + dims.height;
    end
end
% OPTION ARRAYS ================================================================
function opts = opts_new()
% create a new options array
    opts = cell(0,2);
end
function opts = opts_add(opts, key, value)
% add a key-value pair to an options array (with duplication check)
    if ~exist('value','var')
        value = '';
    end
    value = char(value);

    % Check if the key already exists.
    if opts_has(opts, key)
        oldValue = opts_get(opts, key);
        if isequal(value, oldValue)
            return; % no action needed: value already present
        else
            error('matlab2tikz:opts_add', ...
                 ['Trying to add (%s, %s) to options, but it already ' ...
                  'contains the conflicting key-value pair (%s, %s).'], ...
                  key, value, key, oldValue);
        end
    end
    opts = opts_append(opts, key, value);
end
function bool = opts_has(opts, key)
% returns true if the options array contains the key
    bool = ~isempty(opts) && ismember(key, opts(:,1));
end
function value = opts_get(opts, key)
% returns the value(s) stored for a key in an options array
    idx = find(ismember(opts(:,1), key));
    switch numel(idx)
        case 1
            value = opts{idx,2}; % just the value
        otherwise
            value = opts(idx,2); % as cell array
    end
end
function opts = opts_append(opts, key, value)
% append a key-value pair to an options array (duplicate keys allowed)
    if ~exist('value','var')
        value = '';
    end
    value = char(value);
    if ~(opts_has(opts, key) && isequal(opts_get(opts, key), value))
        opts = cat(1, opts, {key, value});
    end
end
function opts = opts_append_userdefined(opts, userDefined)
% appends user-defined options to an options array
% the userDefined options can come either as a single string or a cellstr that
% is already TikZ-formatted. The internal 2D cell format is NOT supported.
    if ~isempty(userDefined)
        if ischar(userDefined)
            userDefined = {userDefined};
        end
        for k = 1:length(userDefined)
            opts = opts_append(opts, userDefined{k});
        end
    end
end
function opts = opts_copy(opts_from, name_from, opts, name_to)
% copies an option (if it exists) from one option array to another one
    if ~exist('name_to', 'var') || isempty(name_to)
        name_to = name_from;
    end
    if opts_has(opts_from, name_from)
        value = opts_get(opts_from, name_from);
        opts = opts_append(opts, name_to, value);
    end
end
function opts = opts_remove(opts, varargin)
% remove some key-value pairs from an options array
    keysToDelete = varargin;
    idxToDelete = ismember(opts(:,1), keysToDelete);
    opts(idxToDelete, :) = [];
end
function opts = opts_merge(opts, varargin)
% merge multiple options arrays
    for jArg = 1:numel(varargin)
        opts2 = varargin{jArg};
        for k = 1:size(opts2, 1)
            opts = opts_append(opts, opts2{k,1}, opts2{k,2});
        end
    end
end
function str  = opts_print(m2t, opts, sep)
% pretty print an options array
    nOpts = size(opts,1);
    c = cell(1,nOpts);
    for k = 1:nOpts
        if isempty(opts{k,2})
            c{k} = sprintf('%s', opts{k,1});
        else
            c{k} = sprintf('%s=%s', opts{k,1}, opts{k,2});
        end
    end
    str = join(m2t, c, sep);
end
% ==============================================================================
function [env, versionString] = getEnvironment()
% Checks if we are in MATLAB or Octave.
    persistent cache

    alternatives = {'MATLAB', 'Octave'};
    if isempty(cache)
        for iCase = 1:numel(alternatives)
            env   = alternatives{iCase};
            vData = ver(env);
            if ~isempty(vData) % found the right environment
                versionString = vData.Version;
                % store in cache
                cache.env = env;
                cache.versionString = versionString;
                return;
            end
        end
        % fall-back values
        env = '';
        versionString = '';
    else
        env = cache.env;
        versionString = cache.versionString;
    end
end
% ==============================================================================
function bool = isHG2()
% Checks if graphics system is HG2 (true) or HG1 (false).
% HG1 : MATLAB up to R2014a and currently all OCTAVE versions
% HG2 : MATLAB starting from R2014b (version 8.4)
    [env, envVersion] = getEnvironment();
    bool = strcmpi(env,'MATLAB') && ...
           ~isVersionBelow(envVersion, [8,4]);
end
% ==============================================================================
function bool = isVersionBelow(versionA, versionB)
% Checks if versionA is smaller than versionB
    vA         = versionArray(versionA);
    vB         = versionArray(versionB);
    n          = min(length(vA), length(vB));
    deltaAB    = vA(1:n) - vB(1:n);
    difference = find(deltaAB, 1, 'first');
    % Empty difference then same version
    bool       = ~isempty(difference) && deltaAB(difference) < 0;
end
% ==============================================================================
function str = formatAspectRatio(m2t, values)
% format the aspect ratio. Behind the scenes, formatDim is used
    strs = arrayfun(@formatDim, values, 'UniformOutput', false);
    str = join(m2t, strs, ' ');
end
% ==============================================================================
function str = formatDim(value, unit)
% format the value for use as a TeX dimension
    if ~exist('unit','var') || isempty(unit)
        unit = '';
    end
    tolerance = 1e-7;
    value  = round(value/tolerance)*tolerance;
    if value == 1 && ~isempty(unit) && unit(1) == '\'
        str = unit; % just use the unit
    else
        % LaTeX has support for single precision (about 6.5 decimal places),
        % but such accuracy is overkill for positioning. We clip to three
        % decimals to overcome numerical rounding issues that tend to be very
        % platform and version dependent. See also #604.
        str = sprintf('%.3f', value);
        str = regexprep(str, '(\d*\.\d*?)0+$', '$1'); % remove trailing zeros
        str = regexprep(str, '\.$', ''); % remove trailing period
        str = [str unit];
    end
end
% ==============================================================================
function arr = versionArray(str)
% Converts a version string to an array.
    if ischar(str)
        % Translate version string from '2.62.8.1' to [2; 62; 8; 1].
        switch getEnvironment
            case 'MATLAB'
                split = regexp(str, '\.', 'split'); % compatibility MATLAB < R2013a
            case  'Octave'
                split = strsplit(str, '.');
            otherwise
                errorUnknownEnvironment();
        end
        arr = str2num(char(split)); %#ok
    else
        arr = str;
    end
    arr = arr(:)';
end
% ==============================================================================
function [retval] = switchMatOct(matlabValue, octaveValue)
% Returns a different value for MATLAB and Octave
    switch getEnvironment
        case 'MATLAB'
            retval = matlabValue;
        case 'Octave'
            retval = octaveValue;
        otherwise
            errorUnknownEnvironment();
    end
end
% ==============================================================================
function checkDeprecatedEnvironment(minimalVersions)
    [env, envVersion] = getEnvironment();
    if isfield(minimalVersions, env)
        minVersion = minimalVersions.(env);
        envWithVersion = sprintf('%s %s', env, minVersion.name);

        if isVersionBelow(envVersion, minVersion.num)
            ID = 'matlab2tikz:deprecatedEnvironment';

            warningMessage = ['\n', repmat('=',1,80), '\n\n', ...
                '  matlab2tikz is tested and developed on   %s   and newer.\n', ...
                '  This script may still be able to handle your plots, but if you\n', ...
                '  hit a bug, please consider upgrading your environment first.\n', ...
                '  Type "warning off %s" to suppress this warning.\n', ...
                '\n', repmat('=',1,80), ];
            warning(ID, warningMessage, envWithVersion, ID);

        end
    else
        errorUnknownEnvironment();
    end
end
% ==============================================================================
function errorUnknownEnvironment()
    error('matlab2tikz:unknownEnvironment',...
          'Unknown environment "%s". Need MATLAB(R) or Octave.', getEnvironment);
end
% ==============================================================================
function m2t = needsPgfplotsVersion(m2t, minVersion)
    if isVersionBelow(m2t.pgfplotsVersion, minVersion)
        m2t.pgfplotsVersion = minVersion;
    end
end
% ==============================================================================
function str = formatPgfplotsVersion(version)
    version = versionArray(version);
    if all(isfinite(version))
        str = sprintf('%d.',version);
        str = str(1:end-1); % remove the last period
    else
        str = 'newest';
    end
end
% ==============================================================================
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
        m2tDir = fileparts(mfilename('fullpath'));
        gitDir = fullfile(m2tDir,'..','.git');

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
        formatted = sprintf('(commit %s)',treeish);
    end
end
% ==============================================================================
