function [env, versionString] = getEnvironment()
% Determine environment (Octave, MATLAB) and version string
% TODO: Unify private `getEnvironment` functions
    persistent cache

    if isempty(cache)
        isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
        if isOctave
            env = 'Octave';
            versionString = OCTAVE_VERSION;
        else
            env = 'MATLAB';
            vData = ver(env);
            versionString = vData.Version;
        end

        % store in cache
        cache.env = env;
        cache.versionString = versionString;

    else
        env = cache.env;
        versionString = cache.versionString;
    end
end
