function bool = isAxis3D(axisHandle)
% Check if elevation is not orthogonal to xy plane
    axisView = get(axisHandle,'view');
    bool     = ~ismember(axisView(2),[90,-90]);
end
