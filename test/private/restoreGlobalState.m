function restoreGlobalState(orig,cwd)
% Restore original properties of global state.
% See #542 and #552
    fprintf('Restore global state...\n');
    
    % Restore relevant properties
    state_fields = fieldnames(orig);
    for i = 1:length(state_fields)
        set(0, state_fields{i}, orig.(state_fields{i}).val);
    end

    % Return to previous working directory
    fprintf('Restore working directory...\n');
    cd(cwd);
end
