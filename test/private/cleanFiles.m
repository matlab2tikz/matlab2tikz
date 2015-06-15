function cleanFiles(cleanBefore)
% clean output files in ./tex using make
    if cleanBefore && exist(fullfile('tex','Makefile'),'file')
        fprintf(1, 'Cleaning output files...\n');
        cwd = pwd;
        try
            cd('tex');
            [exitCode, output] = system('make distclean');
            fprintf(1,'%s\n', output);
            assert(exitCode==0, 'Exit code 0 means correct execution');
        catch
            % This might happen when make is not present
            fprintf(2, '\tNot completed succesfully\n\n');
        end
        cd(cwd);
    end
end
