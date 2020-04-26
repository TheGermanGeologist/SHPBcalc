function returnstate = SHPB_addProject(GUIpath,addedPath)


% first check if this is a project folder
if isdir(addedPath)
    % split path end get last element
    endout = regexp(addedPath,filesep,'split');
    addedname = endout{end};
    addedfilename = [addedPath,filesep,addedname,'.mat'];
    if isfile(addedfilename)
        % ok, that means this is indeed a project
        % then check if a project with the same name as the to be added one
        % already exists
        testpath = fullfile(GUIpath,'projects',addedname);
        if ~isdir(testpath)
            % project name is new, now we can go ahead and copy the new project
            % to the projects folder
            % move project folder to GUIpath projects directory
            copyfile(addedPath,fullfile(GUIpath,'projects',addedname));
            % add new project to projects_index
            p = load(fullfile(GUIpath,'resources','projects_index.mat'));
            info = p.info;
            N = p.N + 1;
            info{N,1} = N;
            info{N,2} = addedname;
            info{N,3} = testpath;
            save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
            returnstate = 1;
        else
            returnstate = 3;
        end
    else
        returnstate = 2;
    end
else
    returnstate = 2;
end
