function returnstate = SHPB_deleteProject(GUIpath,delNumber)

try

% disable warnings from deleting from searchpath
warning('off','MATLAB:RMDIR:RemovedFromPath')

p = load(fullfile(GUIpath,'resources','projects_index.mat'));
indexedProjects = p.info;
Nprojects = p.N;
d = load(fullfile(GUIpath,'resources','preferences.mat'));
prefs = d.prefs;
defaultproject = prefs.defaultproject;


if delNumber == defaultproject
    rmdir(fullfile(indexedProjects{delNumber,3}),'s')
    prefs.defaultproject == 0;
    save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
    N = Nprojects - 1;
    info = indexedProjects;
    info(delNumber,:) = [];
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
elseif delNumber < defaultproject
    rmdir(fullfile(indexedProjects{delNumber,3}),'s')
    prefs.defaultproject == defaultproject - 1;
    save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
    N = Nprojects - 1;
    info = indexedProjects;
    info(delNumber,:) = [];
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
elseif delNumber > defaultproject
    rmdir(fullfile(indexedProjects{delNumber,3}),'s')
    N = Nprojects - 1;
    info = indexedProjects;
    info(delNumber,:) = [];
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
end
    % re-enable warnings
    warning('on','MATLAB:RMDIR:RemovedFromPath')
    returnstate = 1;
catch
    returnstate = 0;
end
