function handles = SHPB_updateExpms(handles)

  selectedExpm = handles.expms.selection;
  slctdProject = handles.projects.selection;
  eInfo = handles.expms.eInfo;
  pInfo = handles.projects.pInfo;
    if ~isempty(eInfo)
        ExperimentNames = eInfo(:,3);
        set(handles.expmlist,'String',ExperimentNames)
        set(handles.expmlist,'Value',selectedExpm)
        % load meta info of first experiment
        m = load(fullfile(pInfo{slctdProject,3},eInfo{selectedExpm,9},'experiment.mat'));
        expmstruct = m.expm;
        handles.expms.expmstruct = expmstruct;
        % set experiment meta information
        set(handles.pressurevalue,'String',[num2str(expmstruct.cp),' [bar]'])
        set(handles.strikervalue,'String',[num2str(expmstruct.v0),' [m/s]'])
        set(handles.datevalue,'String',expmstruct.date)
        set(handles.lengthvalue,'String',[num2str(expmstruct.Ls*1000),' [mm]'])
        set(handles.diametervalue,'String',[num2str(expmstruct.Ds*1000),' [mm]'])
        set(handles.lithvalue,'String',convertStringsToChars(expmstruct.lith))
        if ~isempty(expmstruct.dscrpt)
            text = []; for i = 1:size(expmstruct.dscrpt,1); text = [text,expmstruct.dscrpt(i,:),'\n']; end;
            text = text(1:end-2);
            set(handles.observevalue,'String',sprintf(text))
        else
            set(handles.observevalue,'String','')
        end
        if expmstruct.fail == 1
            set(handles.failvalue,'String','yes')
        else
            set(handles.failvalue,'String',' no')
        end
        if expmstruct.eval == 1
            % load results of evaluation
            set(handles.evalvalue,'String','yes')
            d = load(fullfile(pInfo{slctdProject,3},eInfo{selectedExpm,9},'data.mat'));
            expmdata = d.data;
            handles.expms.expmdata = expmdata;
            % display results
            set(handles.tanmodvalue,'String',[num2str(round(expmdata.tanmod/1e9,2)),' [GPa]'])
            set(handles.ucdvalue,'String',[num2str(round(expmdata.ucd)),' [MPa]'])
            set(handles.ratevalue,'String',[num2str(round(expmdata.plateaurate)),' [s^-1]'])
            set(handles.profilevalue,'String',d.profile.profilename)
            set(handles.maxratevalue,'String',[num2str(round(expmdata.maxrate)),' [s^-1]'])
            set(handles.elasticratevalue,'String',[num2str(round(expmdata.elasticrate)),' [s^-1]'])
            set(handles.stdmeanvalue,'String',num2str(round(expmdata.stdplateaurate)))
            set(handles.stdelasticvalue,'String',num2str(round(expmdata.stdelasticrate)))
            % if preview is enabled, plot the preview to previewaxes
            % SHPB_updatePreview(handles)
            % actually, do this outside this function
        else
            set(handles.evalvalue,'String','no')
            set(handles.tanmodvalue,'String','-')
            set(handles.ucdvalue,'String','-')
            set(handles.ratevalue,'String','-')
            set(handles.profilevalue,'String','-')
            set(handles.maxratevalue,'String','-')
            set(handles.elasticratevalue,'String','-')
            set(handles.stdmeanvalue,'String','-')
            set(handles.stdelasticvalue,'String','-')
            % SHPB_updatePreview(handles)
        end
    else
      set(handles.expmlist,'String','')
      set(handles.expmlist,'Value',0)
      set(handles.pressurevalue,'String','-')
      set(handles.strikervalue,'String','-')
      set(handles.datevalue,'String','-')
      set(handles.lengthvalue,'String','-')
      set(handles.diametervalue,'String','-')
      set(handles.lithvalue,'String','-')
      set(handles.observevalue,'String','-')
      set(handles.failvalue,'String','-')
      set(handles.evalvalue,'String','-')
      set(handles.tanmodvalue,'String','-')
      set(handles.ucdvalue,'String','-')
      set(handles.ratevalue,'String','-')
      set(handles.profilevalue,'String','-')
      set(handles.maxratevalue,'String','-')
      set(handles.elasticratevalue,'String','-')
      set(handles.stdmeanvalue,'String','-')
      set(handles.stdelasticvalue,'String','-')
    end
