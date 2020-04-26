function varargout = SHPB_checkfiles(GUIpath)
%SHPB_checkfiles checks the integrity of the app filesystem and if necessary
%restores it.

corrupted = 0;
% CHECK IF THE IDIOT USER HAS DELETED THE WHOLE FUCKING FOLDER
if 0 == exist(GUIpath,'dir')
    % na herzlichen Glückwunsch..
    corrupted = 1;
    mkdir(GUIpath)
    mkdir(fullfile(GUIpath,'resources'))
    mkdir(fullfile(GUIpath,'resources','profiles'))
    SHPB_defaultpreferences(fullfile(GUIpath,'resources'));
    SHPB_pcdefault(fullfile(GUIpath,'resources'));
    SHPB_lithofile(GUIpath)
    Ncalls = 0;
    save(fullfile(GUIpath,'resources','guicounter.mat'),'Ncalls')
    N = 0; info = [];
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
    N = 0; profiles = [];
    save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
    mkdir(GUIpath,'temp')
    mkdir(GUIpath,'individual experiments')
    ProjectDescription = 'Individual Experiments.';
    N = 0;
    expms = [];
    save(fullfile(GUIpath,'individual experiments','individuals.mat'),'N','ProjectDescription','expms')
    mkdir(GUIpath,'projects')
else
    %   CHECK RESOURCES FOLDER
    if 0 == exist(fullfile(GUIpath,'resources'),'dir')
        corrupted = 1;
        mkdir(fullfile(GUIpath,'resources'))
        mkdir(fullfile(GUIpath,'resources','profiles'))
        SHPB_defaultpreferences(fullfile(GUIpath,'resources'));
        SHPB_pcdefault(fullfile(GUIpath,'resources'));
        SHPB_lithofile(GUIpath)
        Ncalls = 0;
        save(fullfile(GUIpath,'resources','guicounter.mat'),'Ncalls')
        N = 0; info = [];
        save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
        N = 0; profiles = [];
        save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
    else
        if 0 == exist(fullfile(GUIpath,'resources','profiles'),'dir')
            corrupted = 1;
            mkdir(fullfile(GUIpath,'resources','profiles'))
            N = 0; profiles = [];
            save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
        else
            if 0 == exist(fullfile(GUIpath,'resources','profiles','profindex.mat'),'file')
                corrupted = 1;
                N = 0; profiles = [];
                save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
            else
            end
        end
        if 0 == exist(fullfile(GUIpath,'resources','guicounter.mat'),'file')
            corrupted = 1;
            Ncalls = 0;
            save(fullfile(GUIpath,'resources','guicounter.mat'),'Ncalls')
        else
        end
        if 0 == exist(fullfile(GUIpath,'resources','projects_index.mat'),'file')
            corrupted = 1;
            N = 0; info = [];
            save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
        else
        end
        if 0 == exist(fullfile(GUIpath,'resources','preferences.mat'),'file')
            corrupted = 1;
            SHPB_defaultpreferences(fullfile(GUIpath,'resources'));
        else
        end
        if 0 == exist(fullfile(GUIpath,'resources','pc_data.mat'),'file')
            corrupted = 1;
            SHPB_pcdefault(fullfile(GUIpath,'resources'));
        else
        end
        if 0 == exist(fullfile(GUIpath,'resources','lithologies.mat'))
            corrupted = 1;
            SHPB_lithofile(GUIpath)
        else
        end
    end

    % CHECK TEMP FOLDER
    if 0 == exist(fullfile(GUIpath,'temp'),'dir')
        corrupted = 1;
        mkdir(GUIpath,'temp')
    else
    end

    % CHECK INDIVIDUAL FOLDER
    if 0 == exist(fullfile(GUIpath,'individual experiments'),'dir')
        corrupted = 1;
        mkdir(GUIpath,'individual experiments')
        ProjectDescription = 'Individual Experiments.';
        N = 0;
        expms = [];
        save(fullfile(GUIpath,'individual experiments','individuals.mat'),'N','ProjectDescription','expms')
    else
        if 0 == exist(fullfile(GUIpath,'individual experiments','individuals.mat'),'file')
            corrupted = 1;
            ProjectDescription = 'Individual Experiments.';
            N = 0;
            expms = [];
            save(fullfile(GUIpath,'individual experiments','individuals.mat'),'N','ProjectDescription','expms')
        else
        end
    end

    % CHECK PROJECTS FOLDER
    if 0 == exist(fullfile(GUIpath,'projects'),'dir')
        corrupted = 1;
        mkdir(GUIpath,'projects')
    end
end
varargout{1} = corrupted;
end
