function handles = SHPB_updateProject(handles)
%SHPB_updateProject: when called, the function modifies the SHPB_manager
%GUI to update everything after a new project has been selected
%unfortunately we need the whole handles structure here

pInfo = handles.projects.pInfo;
slctdProject = handles.projects.selection;
pN = handles.projects.pN;
if slctdProject > pN
  handles.projects.selection = 1;
  slctdProject = 1;
else
end

% fill projects list
if ~isempty(pInfo)
    ProjectNames = pInfo(:,2);
    set(handles.projectlist,'String',ProjectNames)
    % set list selection to selected project
    set(handles.projectlist,'Value',slctdProject)
    % load project meta information
    e = load(fullfile(pInfo{slctdProject,3},[pInfo{slctdProject,2},'.mat']));
    eInfo = e.expms;
    eN = e.N;
    pDscrpt = e.ProjectDescription;
    % update project information
    set(handles.pnamevalue,'String',pInfo{slctdProject,2})
    set(handles.expmnovalue,'String',num2str(eN))
    if ~isempty(eInfo)
        evalcount = sum([eInfo{:,4}]);
        set(handles.evalnovalue,'String',num2str(evalcount))
    else
        set(handles.evalnovalue,'String','0')
    end
    set(handles.ppathvalue,'String',pInfo{slctdProject,3})
    if ~isempty(pDscrpt)
        text = []; for i = 1:size(pDscrpt,1); text = [text,pDscrpt(i,:),'\n']; end;
        text = sprintf(text(1:end-2));
        set(handles.pdscrptvalue,'String',text)
    else
        set(handles.pdscrptvalue,'String','')
    end
    % append new experiments to handles
    handles.expms.pDscrpt = pDscrpt;
    handles.expms.eInfo = eInfo;
    handles.expms.eN = eN;
    % project changed, so set selected expm to 1
    handles.expms.selection = 1;
    % fill experiments lists
    handles = SHPB_updateExpms(handles);
    % update preview
    SHPB_updatePreview(handles)
else
    % update project list
    set(handles.projectlist,'String','')
    set(handles.projectlist,'Value',0)
    % update project information
    set(handles.pnamevalue,'String','-')
    set(handles.expmnovalue,'String','-')
    set(handles.evalnovalue,'String','-')
    set(handles.ppathvalue,'String','-')
    set(handles.pdscrptvalue,'String','-')
    % append new experiments to handles
    handles.expms.pDscrpt = [];
    handles.expms.eInfo = [];
    handles.expms.eN = [];
    % no project , so set selected expm to 0
    handles.expms.selection = 0;
    % fill experiments lists
    handles = SHPB_updateExpms(handles);
    % update preview
    SHPB_updatePreview(handles)
end
