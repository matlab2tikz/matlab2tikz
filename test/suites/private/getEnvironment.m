function [env,versionString] = getEnvironment()
% Checks if we are in MATLAB or Octave.
    alternatives = {'MATLAB','Octave'};
    for iCase = 1:numel(alternatives)
        env   = alternatives{iCase};
        vData = ver(env);
        if ~isempty(vData)
            versionString = vData.Version;
            return; % found the right environment
        end
    end
    % otherwise:
    env = '';
    versionString = '';
end