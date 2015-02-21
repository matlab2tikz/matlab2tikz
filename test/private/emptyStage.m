function stage = emptyStage()
% constructs an empty (workflow) stage struct
    stage = struct('message', '', 'error'  , false);
end
