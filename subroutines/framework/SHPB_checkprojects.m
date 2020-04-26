function varargout = SHPB_checkprojects(GUIpath)
%SHPB_checkprojects checks the projects folder if projects have been
%deleted or added by the user outside of a SHPBcalc session and
%makes the necessary adjustments to projects_index.mat

% CHECK FOR MISSING PROJECTS
l = load(fullfile(GUIpath,'resources','projects_index.mat'));
Nexpected = l.N;
N = Nexpected;

% get default profile so we can update this accordingly
d = load(fullfile(GUIpath,'resources','preferences.mat'));
defaultproject = d.prefs.defaultproject;

deletedList = {};
deletedTrue = 0;
newProjectInfo = {};

% first check if we even have projects in the index
if N ~= 0
    ProjectInfo = l.info;
    %deleteProjects = [];
    for ii = 1:Nexpected
        if 0 == exist(fullfile(ProjectInfo{ii,3}),'dir')
            % this project is missing
            % dont include it in newProjectInfo
            % check if it is the default project
            if ii == defaultproject
                prefs = d.prefs;
                prefs.defaultproject = 0;
                save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
            end
        else
            % move to new project info
            newProjectInfo(end+1,:) = ProjectInfo(ii,:);
            newProjectInfo{end,1} = size(newProjectInfo,1);
            % check if it is the default project
            if ii == defaultproject
                prefs = d.prefs;
                prefs.defaultproject = size(newProjectInfo,1);
                save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
            end
        end
    end
    % Update projects_index.mat
    ProjectInfo = newProjectInfo;
    info = ProjectInfo;
    N = size(newProjectInfo,1);
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info','-append')
    
%     % delete from projects_index.mat
%     if numel(deleteProjects) > 0
%         % there were missing projects
%         deletedTrue = 1;
%         % get default profile so we can update this accordingly
%         d = load(fullfile(GUIpath,'resources','preferences.mat'));
%         defaultproject = d.prefs.defaultproject;
%         defaultoffset = 0;
%         ProjectInfoOriginal = ProjectInfo;
%         % iterate through all missing projects
%         for ii = 1:numel(deleteProjects)
%             deletedList{ii} = ProjectInfoOriginal{ii,2};
%             missing = deleteProjects(ii);
%             if missing == defaultproject
%                 % the default profile has been removed, set default to none
%                 defaultoffset = -defaultproject;
%             elseif missing < defaultproject
%                 % a profile above the default has been removed,
%                 % so the default has to move up as well
%                 % this looks like it could potentially break the program, but since all
%                 % of this happens in the order of projects as in the index, defauloffset
%                 % should not be able to become bigger than defaultprofile.
%                 defaultoffset = defaultoffset - 1;
%             else
%                 % the defaultprofile is above the removed profile so it is unaffected
%             end
%             N = N - 1;
%             %ProjectInfo{missing,1} = [];
%             %ProjectInfo{missing,2} = [];
%             %ProjectInfo{missing,3} = [];
%             ProjectInfo(missing,:) = [];
%         end
%         % update default preferences
%         if defaultoffset ~= 0
%             prefs = d.prefs;
%             prefs.defaultproject = defaultproject + defaultoffset;
%             save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
%         else
%         end
%         % now the first field N for all remaining projects should be updated
%         % it doesn't really matter, but better do it to avoid confusion
%         for jj = 1:N
%             ProjectInfo{jj,1} = jj;
%         end
%         % Update projects_index.mat
%         info = ProjectInfo;
%         save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info','-append')
%     else
%         % all expected projects were present
%     end

else
    % no projects in the index so there cant be missing projects, duh.
end

% CHECK FOR NEWLY ADDED PROJECTS
% get information about projects folder contents
projectcontens = dir(fullfile(GUIpath,'projects'));
projectfolders = {projectcontens([projectcontens(:).isdir]).name};
projectfolders = projectfolders(3:end);
Nactual = numel(projectfolders);

% reload updated projects_index.mat
l = load(fullfile(GUIpath,'resources','projects_index.mat'));
Nexpected = l.N;
N = Nexpected;
ProjectInfo = l.info;

newProjects = [];

% first check if we even have projects in the index
if N ~= 0
    KnownProjects = ProjectInfo(:,2);
    % search for unkown folders in projects
    projectmatch = zeros(1,Nexpected);
    newProjects = [];
    % get name of folder in projects
    for ii = 1:Nactual
        % compare it to all names of known projects
        for jj = 1:Nexpected
            if strcmp(projectfolders{ii},KnownProjects{jj})
                % matching known project found for this folder
                projectmatch(jj) = 1;
                % no need to search the rest so exit now
                break
                % this could probably somehow be sped up by excluding already
                % matched projects from the search pool...
            else
                % no match so far
                projectmatch(jj) = 0;
            end
        end
        % check if there was a match
        if any(projectmatch == 1)
            % this project (ii) is part of the known projects
        else
            % this is an unknown project
            % check if project.mat file is presend
            if 0 == exist(fullfile(GUIpath,'projects',projectfolders{ii},[projectfolders{ii},'.mat']),'file')
                % this isn't actually a project folder, the index file is not present
            else
                % this confirms that this is indeed a project folder
                % memorize new project for later
                newProjects(end+1) = ii;
            end
        end
    end
else
  % no projects in index so every folder found must be new
    if Nactual > 0
        % at least one folder present
        newProjects = [];
        % identify actual project folders
        for ii = 1:Nactual
            if 0 == exist(fullfile(GUIpath,'projects',projectfolders{ii},[projectfolders{ii},'.mat']),'file')
                % this isn't actually a project folder, the index file is not present
            else
                % this confirms that this is indeed a project folder
                % memorize new project for later
                newProjects(end+1) = ii;
            end
        end
        % the rest is taken care of by the usual adding routine
    else
        % there's no folder in projects, so all good
    end
end

addedTrue = 0;
addedList = {};
% add to projects_index.mat
if numel(newProjects) > 0
    addedTrue = 1;
    for ii = 1:numel(newProjects)
        new = newProjects(ii);
        N = N + 1;
        ProjectInfo{N,1} = N;
        ProjectInfo{N,2} = projectfolders{new};
        ProjectInfo{N,3} = fullfile(GUIpath,'projects',projectfolders{new});
        addedList{ii} = projectfolders{new};
    end
    % Update projects_index.mat
    info = ProjectInfo;
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info','-append')
else
end


output.addedTrue = addedTrue;
output.addedList = addedList;
output.deletedTrue = deletedTrue;
output.deletedList = deletedList;
varargout{1} = output;
end
