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