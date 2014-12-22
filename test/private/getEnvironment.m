function [env,versionString] = getEnvironment()
  % Check if we are in MATLAB or Octave.
  % Calling ver with an argument: iterating over all entries is very slow
  supportedEnvironments = {'MATLAB', 'Octave'};
  for iCase = 1:numel(supportedEnvironments)
      env   = supportedEnvironments{iCase};
      vData = ver(env);
      if ~isempty(vData)
          versionString = vData.Version;
          return; % found the right environment
      end
  end
  % no suitable environment found
  if ~ismember(env, supportedEnvironments)
      error('testMatlab2tikz:UnknownEnvironment',...
            'Unknown environment. Only MATLAB and Octave are supported.')
  end
end
