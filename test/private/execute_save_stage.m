function [status] = execute_save_stage(status, ipp, env)
% save stage: saves the figure to EPS/PDF depending on env
    if ismember('save', ipp.Results.stages)
        testNumber = status.index;

        reference_eps = sprintf('data/reference/test%d-reference.eps', testNumber);
        reference_pdf = sprintf('data/reference/test%d-reference.pdf', testNumber);
        reference_fig = sprintf('data/reference/test%d-reference', testNumber);

        % Save reference output as PDF
        try
            switch env
                case 'MATLAB'
                    % MATLAB does not generate properly cropped PDF files.
                    % So, we generate EPS files that are converted later on.
                    print(gcf, '-depsc2', reference_eps);

                    % On R2014b Win, line endings in .eps are Unix style
                    % https://github.com/matlab2tikz/matlab2tikz/issues/370
                    ensureLineEndings(reference_eps);

                case 'Octave'
                    % In Octave, figures are properly cropped when using  print().
                    print(reference_pdf, '-dpdf', '-S415,311', '-r150');
                    pause(1.0)
                otherwise
                    error('Unknown environment. Need MATLAB(R) or GNU Octave.')
            end
        catch %#ok
            e = lasterror('reset'); %#ok
            [status.saveStage] = errorHandler(e, env);
        end
        status.saveStage.epsFile = reference_eps;
        status.saveStage.pdfFile = reference_pdf;
        status.saveStage.texReference = reference_fig;
    end
end
function ensureLineEndings(filename)
% Read in one line and test the ending
fid = fopen(filename,'r+');
testline = fgets(fid);
if ispc && ~strcmpi(testline(end-1:end), sprintf('\r\n'))
    % Rewind, read the whole
    fseek(fid,0,'bof');
    str = fread(fid,'*char')';

    % Replace, overwrite and close
    str = strrep(str, testline(end), sprintf('\r\n'));
    fseek(fid,0,'bof');
    fprintf(fid,'%s',str);
    fclose(fid);
end
end