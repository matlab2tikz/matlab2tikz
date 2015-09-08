function SM = StreamMaker()
% StreamMaker (Factory for fie/input/output Streams)
%
% A StreamMaker can make Stream PseudoObjects based on either
%  an "fid" or "filename" (and extra arguments for `fopen`).
% The StreamMaker also contains a method `isStream` to validate whether
% the value passed is a valid stream specifier.
%
% Usage
%
%  SM = StreamMaker;
%
%    Stream = SM.make(fid)
%    Stream = SM.make(filename, ...)
%
% This returns a PseudoObject Stream with the following properties:
%   - name: (file) name of the stream
%   - fid: handle (fid) of the stream
%
% and methods:
%   - print: prints to the stream, i.e. fprintf
%   - close: closes the stream, i.e. fclose
%
% It may also contain a field to automatically close the Stream when it goes
% out of scope.
%
    SM = PseudoObject('StreamMaker', ...
                      'isStream',  @isStream, ...
                      'make', @constructStream);
end

function PseudoObj = PseudoObject(T, varargin)
% construct a Pseudo-Object with type T (no other fields yet)
    PseudoObj = struct('Type', T, varargin{:});
end

function bool = isStream(value)
    bool = ischar(value) || ismember(value, [1,2,fopen('all')]);
    %TODO: allow others kinds of streams
    %     Stream -> clipboard (write on close)
    %     Stream -> string variable
    % e.g. a quick-and-dirty way would be to write the file to `tempname`
    % putting a flag to read that file back upon completion.
end

function Stream = constructStream(streamSpecifier, varargin)
    % this is the actual constructor of a stream
    if ~isStream(streamSpecifier)
        error('StreamMaker:NotAStream', 'Invalid stream specifier "%s"', ...
              streamSpecifier);
    end

    Stream = PseudoObject('Stream');
    closeAfterUse = false;
    if ischar(streamSpecifier)
        Stream.name = streamSpecifier;
        Stream.fid = fopen(Stream.name, varargin{:});
        closeAfterUse = true;
    elseif isnumeric(streamSpecifier)
        Stream.fid  = streamSpecifier;
        Stream.name = fopen(Stream.fid);
    end

    if Stream.fid == -1
        error('Stream:InvalidStream', ...
              'Unable to create stream "%s"!', streamSpecifier);
    end

    Stream.print = @(varargin) fprintf(Stream.fid, varargin{:});
    Stream.close = @() fclose(Stream.fid);
    if closeAfterUse
        Stream.closeAfterUse = onCleanup(Stream.close);
    end
end
