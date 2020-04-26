function varargout = SHPB_manager(varargin)
% SHPB_MANAGER MATLAB code for SHPB_manager.fig
%      SHPB_MANAGER, by itself, creates a new SHPB_MANAGER or raises the existing
%      singleton*.
%
%      H = SHPB_MANAGER returns the handle to a new SHPB_MANAGER or the handle to
%      the existing singleton*.
%
%      SHPB_MANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHPB_MANAGER.M with the given input arguments.
%
%      SHPB_MANAGER('Property','Value',...) creates a new SHPB_MANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SHPB_manager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SHPB_manager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SHPB_manager

% Last Modified by GUIDE v2.5 12-Feb-2019 20:59:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPB_manager_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPB_manager_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SHPB_manager is made visible.
function SHPB_manager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SHPB_manager (see VARARGIN)

% Choose default command line output for SHPB_manager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% get passed data (mostly GUIpath, but who knows what else might be necessary)
if ~isempty(varargin)
    % exctract
    handles.pass = varargin{1};
    handles.GUIpath = handles.pass.GUIpath;
else
  %errordlg('GUIpath not provided by call.','Error')
  %return
  % for testing purposes
  handles.GUIpath = 'C:\Users\theni\Uni\Projekte\SHPB GUI';
  addpath(genpath(handles.GUIpath));
end

% set everything to initial stuff
% first, load projects_index
GUIpath = handles.GUIpath;
p = load(fullfile(GUIpath,'resources','projects_index.mat'));
pInfo = p.info;
pN = p.N;
handles.projects.pInfo = pInfo;
handles.projects.pN = pN;
handles.projects.selection = 1;

handles = SHPB_updateProject(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SHPB_manager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in projectlist.
function projectlist_Callback(hObject, eventdata, handles)
% hObject    handle to projectlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.projects.selection = get(handles.projectlist,'Value');
handles = SHPB_updateProject(handles);
% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns projectlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projectlist


% --- Executes during object creation, after setting all properties.
function projectlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in expmlist.
function expmlist_Callback(hObject, eventdata, handles)
% hObject    handle to expmlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.expms.selection = get(handles.expmlist,'Value');
handles = SHPB_updateExpms(handles);
SHPB_updatePreview(handles);
% Update handles structure
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns expmlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from expmlist


% --- Executes during object creation, after setting all properties.
function expmlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expmlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in previewslct.
function previewslct_Callback(hObject, eventdata, handles)
% hObject    handle to previewslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHPB_updatePreview(handles);

% Hints: contents = cellstr(get(hObject,'String')) returns previewslct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from previewslct


% --- Executes during object creation, after setting all properties.
function previewslct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to previewslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previewtoggle.
function previewtoggle_Callback(hObject, eventdata, handles)
% hObject    handle to previewtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHPB_updatePreview(handles);
% Hint: get(hObject,'Value') returns toggle state of previewtoggle


% --- Executes on button press in edeletebtn.
function edeletebtn_Callback(hObject, eventdata, handles)
% hObject    handle to edeletebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get selected project
delCandidate = handles.expms.selection;
delName = handles.expms.eInfo{delCandidate,3};
message = sprintf(['Do you really want to permanently delete the experiment \n',delName,' ?']);
choice = questdlg(message,'Delete Experiment?','Yes','No','No');
containingProject = handles.projects.selection;

switch choice
    case 'Yes'
        GUIpath = handles.GUIpath;
        ok = SHPB_deleteExpm(GUIpath,containingProject,delCandidate);
        if ok == 1
            msgbox(['Experiment "',delName,'" successfully deleted.'],'Project deleted.');
        elseif ok == 0
            errordlg('Failed to delete the experiment.','Error')
        else

        end
        % update experiments, and in order to do so just call update projects
        % because the project meta info has changed as well
        GUIpath = handles.GUIpath;
        p = load(fullfile(GUIpath,'resources','projects_index.mat'));
        pInfo = p.info;
        pN = p.N;
        handles.projects.pInfo = pInfo;
        handles.projects.pN = pN;
        handles = SHPB_updateProject(handles);
        % store new data
        guidata(hObject, handles);
    case 'No'
        % just exit
    otherwise
end



% --- Executes on button press in eanalyzebtn.
function eanalyzebtn_Callback(hObject, eventdata, handles)
% hObject    handle to eanalyzebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('This feature will be added in a future release.')

% --- Executes on button press in panalyzebtn.
function panalyzebtn_Callback(hObject, eventdata, handles)
% hObject    handle to panalyzebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('This feature will be added in a future release.')

% --- Executes on button press in pdeletebtn.
function pdeletebtn_Callback(hObject, eventdata, handles)
% hObject    handle to pdeletebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get selected project
delCandidate = get(handles.projectlist,'Value');
delName = handles.projects.pInfo{delCandidate,2};
message = sprintf(['Do you really want to permanently delete the project \n',delName,' ?']);
choice = questdlg(message,'Delete Project?','Yes','No','No');

switch choice
    case 'Yes'
        GUIpath = handles.GUIpath;
        ok = SHPB_deleteProject(GUIpath,delCandidate);
        if ok == 1
            msgbox(['Project "',delName,'" successfully deleted.'],'Project deleted.');
        elseif ok == 0
            errordlg('Failed to delete the project.','Error')
        else

        end
        % update projects
        p = load(fullfile(GUIpath,'resources','projects_index.mat'));
        pInfo = p.info;
        pN = p.N;
        handles.projects.pInfo = pInfo;
        handles.projects.pN = pN;

        handles = SHPB_updateProject(handles);
        % store new data
        guidata(hObject, handles);
    case 'No'
        % just exit
    otherwise
end


% --- Executes on button press in paddbtn.
function paddbtn_Callback(hObject, eventdata, handles)
% hObject    handle to paddbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIpath = handles.GUIpath;
addedPath = uigetdir(GUIpath,'Select a project folder to add.');
returnstate = SHPB_addProject(GUIpath,addedPath);
switch returnstate
    case 1
        msgbox('Project successfully added.','Success.')
        % update projects
        p = load(fullfile(GUIpath,'resources','projects_index.mat'));
        pInfo = p.info;
        pN = p.N;
        handles.projects.pInfo = pInfo;
        handles.projects.pN = pN;

        handles = SHPB_updateProject(handles);
        % store new data
        guidata(hObject, handles);
    case 2
        errordlg('The selected folder appears to not be a SHPBcalc project folder.'...
        ,'Error.')
    case 3
        errordlg('A project with the same name already exists.','Error')
otherwise
end



% --- Executes on button press in psharebtn.
function psharebtn_Callback(hObject, eventdata, handles)
% hObject    handle to psharebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
m = msgbox('Copy the project folder you whish to share in the filesystem.');
uiwait(m)
GUIpath = handles.GUIpath;
projectpath = fullfile(GUIpath,'projects');
if ispc
    winopen(projectpath)
elseif ismac
    system(['open ',projectpath])
elseif ~ismac && isunix
    system(['xdg-open ',projectpath])
else
end
