function handles = SHPB_newProfile(handles,calltype)

meta = handles.meta;
GUIpath = handles.GUIpath;

switch calltype

    case 'enable'
        % Create dummy profile "New"
        meta.N = meta.N + 1;
        meta.names{meta.N} = 'New';
        meta.selection = meta.N;
        set(handles.profilelistbox,'String',meta.names)
        set(handles.profilelistbox,'Value',meta.N)
        % clear fields
        set(handles.profnamefield,'String','');
        set(handles.barnamefield,'String','')
        set(handles.strikerfield,'String','')
        set(handles.incidentfield,'String','')
        set(handles.transmissionfield,'String','')
        set(handles.diameterfield,'String','')
        set(handles.ratefield,'String','')
        set(handles.voltagefield,'String','')
        set(handles.amplificationfield,'String','')
        set(handles.kfactorfield,'String','')
        set(handles.densityfield,'String','')
        set(handles.youngsfield,'String','')
        set(handles.poissondropdown,'Value',1)
        set(handles.descriptionfield,'String','')
        % enable fields
        set(handles.profnamefield,'Enable','on');
        set(handles.barnamefield,'Enable','on')
        set(handles.strikerfield,'Enable','on')
        set(handles.incidentfield,'Enable','on')
        set(handles.transmissionfield,'Enable','on')
        set(handles.diameterfield,'Enable','on')
        set(handles.ratefield,'Enable','on')
        set(handles.voltagefield,'Enable','on')
        set(handles.amplificationfield,'Enable','on')
        set(handles.kfactorfield,'Enable','on')
        set(handles.densityfield,'Enable','on')
        set(handles.youngsfield,'Enable','on')
        set(handles.descriptionfield,'Enable','on')
        set(handles.poissondropdown,'Enable','on')
        % disable everything but accept and cancel button
        set(handles.newbtn,'Enable','off')
        set(handles.deletebtn,'Enable','off')
        set(handles.defaultbtn,'Enable','off')
        set(handles.currentbtn,'Enable','off')
        set(handles.profilelistbox,'Enable','off')
        % enable cancle and accept buttons
        set(handles.cancelbtn,'Enable','on')
        set(handles.acceptbtn,'Enable','on')



        handles.meta = meta;

    case 'accept'
        % get and check values (oof)
        % check name legality
        newprofilename = get(handles.profnamefield,'String');
        [ok,msg] = CheckFileName(newprofilename);
        if ok == 0
            errordlg(msg,'Invalid profile name')
            return
        else
        end
        % check name uniqueness
        if ismember(newprofilename,meta.names)
            errordlg('This profile name is already in use. Please choose a new name',...
                  'Invalid profile name')
            return
        else
        end
        % check numeric fields
        data = [];
        data{end + 1} = str2num(get(handles.strikerfield,'String'));
        data{end + 1} = str2num(get(handles.incidentfield,'String'));
        data{end + 1} = str2num(get(handles.transmissionfield,'String'));
        data{end + 1} = str2num(get(handles.diameterfield,'String'));
        data{end + 1} = str2num(get(handles.ratefield,'String'));
        data{end + 1} = str2num(get(handles.voltagefield,'String'));
        data{end + 1} = str2num(get(handles.amplificationfield,'String'));
        data{end + 1} = str2num(get(handles.kfactorfield,'String'));
        data{end + 1} = str2num(get(handles.densityfield,'String'));
        data{end + 1} = str2num(get(handles.youngsfield,'String'));
        %fieldnames = {'Striker Length','Incident distance','Transmission distance',...
        %              'Diameter','Sampling rate','Voltage','Amplification',...
        %              'k-Factor','Density','Young''s Modulus'};
        if any(cellfun(@isempty,data)) || any(~cellfun(@isnumeric,data)) || any(cellfun(@(x)isequal(x,0),data))
            errordlg('The numeric value fields contain invalid information','Non numeric data')
            return
        elseif any(cellfun(@isnan,data))
          errordlg('The numeric value fields contain invalid information','Non numeric data')
          return
        else
        end
        % everything is fine so far
        % get all the data and store it in new profile file
        profile.Lp = data{1}/100;
        profile.X1 = data{2};
        profile.X2 = data{3};
        profile.Db = data{4}/100;
        profile.Hz = data{5};
        profile.U0 = data{6};
        profile.V = data{7};
        profile.k = data{8};
        profile.roh0b = data{9};
        profile.Eb = data{10};
        profile.pc = get(handles.poissondropdown,'Value');
        profile.bName = get(handles.barnamefield,'String');
        ProfileDescription{1} = get(handles.descriptionfield,'String');
        % store everything in file
        profilepath = fullfile(GUIpath,'resources','profiles',[newprofilename,'.mat']);
        save(profilepath,'profile','ProfileDescription')
        % update profindex
        p = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
        N = meta.N;
        profiles = p.profiles;
        profiles{N,1} = N;
        profiles{N,2} = newprofilename;
        profiles{N,3} = profilepath;
        save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
        % reload the whole meta stuff and make it new
        meta.N = [];
        meta.names = [];
        meta.paths = [];
        meta.selection = [];
        handles.meta = meta;
        u = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
        meta.N = u.N;
        meta.names = u.profiles(:,2);
        meta.paths = u.profiles(:,3);
        meta.selection = meta.N;
        handles.meta = meta;
        set(handles.profilelistbox,'String',meta.names)
        set(handles.profilelistbox,'Value',meta.selection)
        % call updateProfile
        SHPB_updateProfile(handles)
        % re-enable the whole ui stuff
        % deactivate fields
        set(handles.profnamefield,'Enable','inactive');
        set(handles.barnamefield,'Enable','inactive')
        set(handles.strikerfield,'Enable','inactive')
        set(handles.incidentfield,'Enable','inactive')
        set(handles.transmissionfield,'Enable','inactive')
        set(handles.diameterfield,'Enable','inactive')
        set(handles.ratefield,'Enable','inactive')
        set(handles.voltagefield,'Enable','inactive')
        set(handles.amplificationfield,'Enable','inactive')
        set(handles.kfactorfield,'Enable','inactive')
        set(handles.densityfield,'Enable','inactive')
        set(handles.youngsfield,'Enable','inactive')
        set(handles.descriptionfield,'Enable','inactive')
        set(handles.poissondropdown,'Enable','inactive')
        % enable everything but accept and cancel button
        set(handles.newbtn,'Enable','on')
        set(handles.deletebtn,'Enable','on')
        set(handles.defaultbtn,'Enable','on')
        set(handles.currentbtn,'Enable','on')
        set(handles.profilelistbox,'Enable','on')
        % disable cancle and accept buttons
        set(handles.cancelbtn,'Enable','off')
        set(handles.acceptbtn,'Enable','off')
        % DONE!
    case 'cancel'
        % revert changes to meta
        meta.names(meta.N) = [];
        meta.N = meta.N - 1;
        meta.selection = meta.N;
        set(handles.profilelistbox,'String',meta.names)
        set(handles.profilelistbox,'Value',meta.N)
        % deactivate fields
        set(handles.profnamefield,'Enable','inactive');
        set(handles.barnamefield,'Enable','inactive')
        set(handles.strikerfield,'Enable','inactive')
        set(handles.incidentfield,'Enable','inactive')
        set(handles.transmissionfield,'Enable','inactive')
        set(handles.diameterfield,'Enable','inactive')
        set(handles.ratefield,'Enable','inactive')
        set(handles.voltagefield,'Enable','inactive')
        set(handles.amplificationfield,'Enable','inactive')
        set(handles.kfactorfield,'Enable','inactive')
        set(handles.densityfield,'Enable','inactive')
        set(handles.youngsfield,'Enable','inactive')
        set(handles.descriptionfield,'Enable','inactive')
        set(handles.poissondropdown,'Enable','inactive')
        % enable everything but accept and cancel button
        set(handles.newbtn,'Enable','on')
        set(handles.deletebtn,'Enable','on')
        set(handles.defaultbtn,'Enable','on')
        set(handles.currentbtn,'Enable','on')
        set(handles.profilelistbox,'Enable','on')
        % disable cancle and accept buttons
        set(handles.cancelbtn,'Enable','off')
        set(handles.acceptbtn,'Enable','off')

        handles.meta = meta;
        SHPB_updateProfile(handles)


    otherwise
        return
end
