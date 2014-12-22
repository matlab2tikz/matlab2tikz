function stages = getStagesFromStatus(status)
% retrieves the different (names of) stages of a status struct 
    fields = fieldnames(status);
    stages = fields(cellfun(@(f) ~isempty(strfind(f,'Stage')), fields));
end
