function PostBrushCallback(~,eventdata,names)

% Extract plotted graphics objects
% Invert order because "Children" property is in reversed plotting order
hLines = flipud(eventdata.Axes.Children);

% Loop through each graphics object
for k = 1:numel(hLines)
    % Check that the property is valid for that type of object
    % Also check if any points in that object are selected
    if isprop(hLines(k),'BrushData') && any(hLines(k).BrushData)
        % Output the selected data to the base workspace with assigned name
        data = logical(hLines(k).BrushData.');
        %data = [hLines(k).XData(ptsSelected).' ...
        %    hLines(k).YData(ptsSelected).'];
        assignin('base',names{k},data)
    end
end

end
