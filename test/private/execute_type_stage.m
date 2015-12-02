function [status] = execute_type_stage(status, ipp)
    try
        filename = status.tikzStage.texFile;
        stream = 1; % stdout
        if errorHasOccurred(status) && exist(filename, 'file')
            shortname = strrep(filename, m2troot, '$(M2TROOT)');
            fprintf(stream, '\n%%%%%%%% BEGIN FILE "%s" %%%%%%%%\n', shortname);
            type(filename);
            fprintf(stream, '\n%%%%%%%% END   FILE "%s" %%%%%%%%\n', shortname);
        end
    catch
        e = lasterror('reset');
        [status.typeStage] = errorHandler(e);
    end
end
