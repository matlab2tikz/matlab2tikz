function [status] = fillStruct(status, defaultStatus)
% fills non-existant fields of |data| with those of |defaultData|
    fields = fieldnames(defaultStatus);
    for iField = 1:numel(fields)
      field = fields{iField};
      if ~isfield(status,field)
          status.(field) = defaultStatus.(field);
      end
    end
end
