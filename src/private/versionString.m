function str = versionString(arr)
% Converts a version array to string
  if ischar(arr)
      str = arr;
  elseif isnumeric(arr)
      str = sprintf('%d.', arr);
      str = str(1:end-1); % remove final period
  end
end
