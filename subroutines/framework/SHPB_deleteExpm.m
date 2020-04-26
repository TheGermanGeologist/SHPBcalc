function returnstate = SHPB_deleteExpm(GUIpath,projectID,expmID)

% disable warnings from deleting from searchpath
warning('off','MATLAB:RMDIR:RemovedFromPath')

% get project file
p = load(fullfile(GUIpath,'resources','projects_index.mat'));
projects = p.info;

projectpath = projects{projectID,3};
e = load(fullfile(projectpath,[projects{projectID,2},'.mat']));
expmdirname = e.expms{expmID,9};

% delete the experiment folder
rmdir(fullfile(projectpath,expmdirname),'s')

% update project file
N = e.N - 1;
expms = e.expms;
expms(expmID,:) = [];

save(fullfile(projectpath,[projects{projectID,2},'.mat']),'N','expms','-append')

returnstate = 1;

% re-enable warnings
warning('on','MATLAB:RMDIR:RemovedFromPath')
returnstate = 1;
