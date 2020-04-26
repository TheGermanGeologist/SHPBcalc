function handles = SHPB_deleteProfile(handles)

meta = handles.meta;
selection = meta.selection;
delCandidate = meta.names{selection};
GUIpath = handles.GUIpath;

message = sprintf(['Do you really want to permanently delete the profile \n',delCandidate,' ?']);
choice = questdlg(message,'Delete Profile?','Yes','No','No');

switch choice
    case 'No'
        return

    case 'Yes'
        % adjust default profile if necessary
        if meta.default ~= 0
            if selection == meta.default
                d = load(fullfile(GUIpath,'resources','preferences.mat'));
                prefs = d.prefs;
                prefs.defaultprofile = 0;
                save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
                meta.default = 0;
                set(handles.defaultprofdisp,'String',['Default Profile: ','none'])
            else
            end
            if selection < meta.default
                d = load(fullfile(GUIpath,'resources','preferences.mat'));
                prefs = d.prefs;
                prefs.defaultprofile = prefs.defaultprofile -1;
                save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
                meta.default = prefs.defaultprofile;
            else
            end
        else
        end
        % adjust current profile if necessary
        if meta.current ~= 0
            if selection == meta.current
                newcurrent = 0;
                save(fullfile(GUIpath,'temp','changedProfile.mat'),'newcurrent')
                meta.current = 0;
                set(handles.currentprofdisp,'String',['Current Profile: ','none'])
            else
            end
            if selection < meta.current
                newcurrent = meta.current -1;
                save(fullfile(GUIpath,'temp','changedProfile.mat'),'newcurrent')
                meta.current = newcurrent;
            else
            end
        else
        end
        % delete the profile
        % load profile index
        p = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
        N = p.N;
        profiles = p.profiles;
        profiles(selection,:) = [];
        N = N - 1;
        save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
        delete(meta.paths{selection})
        % update meta struct
        meta.names = profiles(:,2);
        meta.paths = profiles(:,3);
        meta.selection = 1;
        meta.N = N;
        % fill profile list
        set(handles.profilelistbox,'String',meta.names)
        set(handles.profilelistbox,'Value',meta.selection)
        if N == 0
          meta.selection = 0;
        else
        end
        handles.meta = meta;
        SHPB_updateProfile(handles);
    otherwise
end
