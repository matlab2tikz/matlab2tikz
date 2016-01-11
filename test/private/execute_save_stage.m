function [status] = execute_save_stage(status, ipp)
% save stage: saves the figure to EPS/PDF depending on env
    testNumber = status.index;

    basepath = fullfile(ipp.Results.output,'data','reference');
    reference_eps = fullfile(basepath, sprintf('test%d-reference.eps', testNumber));
    reference_pdf = fullfile(basepath, sprintf('test%d-reference.pdf', testNumber));
    % the reference below is for inclusion in LaTeX! Use UNIX conventions!
    reference_fig = sprintf('data/reference/test%d-reference', testNumber);

    % Save reference output as PDF
    try
        switch getEnvironment
            case 'MATLAB'
                % MATLAB does not generate properly cropped PDF files.
                % So, we generate EPS files that are converted later on.
                print(gcf, '-depsc2', reference_eps);

                fixLineEndingsInWindows(reference_eps);

            case 'Octave'
                % In Octave, figures are properly cropped when using  print().
                print(reference_pdf, '-dpdf', '-S415,311', '-r150');
                pause(1.0)
            otherwise
                error('matlab2tikz:UnknownEnvironment', ...
                     'Unknown environment. Need MATLAB(R) or GNU Octave.')
        end
    catch %#ok
        e = lasterror('reset'); %#ok
        [status.saveStage] = errorHandler(e);
    end
    status.saveStage.epsFile = reference_eps;
    status.saveStage.pdfFile = reference_pdf;
    status.saveStage.texReference = reference_fig;
end
% ==============================================================================
function fixLineEndingsInWindows(filename)
% On R2014b Win, line endings in .eps are Unix style (LF) instead of Windows
% style (CR+LF). This causes problems in the MikTeX `epstopdf` for some files
% as dicussed in:
%  * https://github.com/matlab2tikz/matlab2tikz/issues/370
%  * http://tex.stackexchange.com/questions/208179
    if ispc
        fid = fopen(filename,'r+');
        finally_fclose_fid = onCleanup(@() fclose(fid));
        testline = fgets(fid);
        CRLF = sprintf('\r\n');
        endOfLine = testline(end-1:end);
        if ~strcmpi(endOfLine, CRLF)
            endOfLine = testline(end); % probably an LF

            % Rewind, read the whole
            fseek(fid,0,'bof');
            str = fread(fid,'*char')';

            % Replace, overwrite and close
            str = strrep(str, endOfLine, CRLF);
            fseek(fid,0,'bof');
            fprintf(fid,'%s',str);
        end
    end
end
