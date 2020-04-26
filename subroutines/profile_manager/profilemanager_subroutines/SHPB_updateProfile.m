function SHPB_updateProfile(handles)

meta = handles.meta;
selection = meta.selection;

if meta.selection ~= 0
    % load profile
    profpath = meta.paths{selection};
    l = load(profpath);
    description = l.ProfileDescription{1};
    profiledata = l.profile;
    % populate fields
    set(handles.profnamefield,'String',meta.names{selection});
    set(handles.barnamefield,'String',profiledata.bName)
    set(handles.strikerfield,'String',num2str(profiledata.Lp*100))
    set(handles.incidentfield,'String',num2str(profiledata.X1))
    set(handles.transmissionfield,'String',num2str(profiledata.X2))
    set(handles.diameterfield,'String',num2str(profiledata.Db*100))
    set(handles.ratefield,'String',num2str(profiledata.Hz))
    set(handles.voltagefield,'String',num2str(profiledata.U0))
    set(handles.amplificationfield,'String',num2str(profiledata.V))
    set(handles.kfactorfield,'String',num2str(profiledata.k))
    set(handles.densityfield,'String',num2str(profiledata.roh0b))
    set(handles.youngsfield,'String',num2str(profiledata.Eb))
    set(handles.poissondropdown,'Value',profiledata.pc)
    if ~isempty(description)
        text = []; for i = 1:size(description,1); text = [text,description(i,:),'\n']; end;
        text = text(1:end-2);
        set(handles.descriptionfield,'String',sprintf(text))
    else
        set(handles.descriptionfield,'String','')
    end
else
    set(handles.profnamefield,'String','-');
    set(handles.barnamefield,'String','-')
    set(handles.strikerfield,'String','-')
    set(handles.incidentfield,'String','-')
    set(handles.transmissionfield,'String','-')
    set(handles.diameterfield,'String','-')
    set(handles.ratefield,'String','-')
    set(handles.voltagefield,'String','-')
    set(handles.amplificationfield,'String','-')
    set(handles.kfactorfield,'String','-')
    set(handles.densityfield,'String','-')
    set(handles.youngsfield,'String','-')
    set(handles.poissondropdown,'Value',1)
    set(handles.descriptionfield,'String','-')
end
