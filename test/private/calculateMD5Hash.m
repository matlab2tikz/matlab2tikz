function hash = calculateMD5Hash(filename)
% CALCULATEMD5HASH calculate a MD5 hash of a file
%
% This functionality is built-in into Octave but uses Java in MATLAB.

    switch getEnvironment
        case 'Octave'
            hash = md5sum(filename);

        case 'MATLAB'
            % There are some MD5 implementations in MATLAB, but those
            % tend to be slow and licensing is unclear.
            % Rolling our own implementation is unwanted, especially since this
            % is a  cryptographic hash, even though its security has been
            % broken. Instead we make use of the Java libraries.
            % Unless the "-nojvm" flag is specified, this should work well.

            % Java only has reliable support for absolute paths.
            absoluteFilename = fullfile(pwd, filename);

            % Based on code by Stéphane Pinchaux and Bastian Ebeling that can be
            % found at <http://stackoverflow.com/questions/12140458/>.

            fis = java.io.FileInputStream(java.io.File(absoluteFilename));
            MD5 = java.security.MessageDigest.getInstance('MD5');
            dis = java.security.DigestInputStream(fis, MD5);

            while(dis.read() ~= -1), end; % read the whole file

            hash = reshape(dec2hex(typecast(MD5.digest(),'uint8')).', 1, 32);
    end

    hash = lower(hash);
end
