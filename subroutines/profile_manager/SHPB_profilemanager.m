function varargout = SHPB_profilemanager(varargin)
% SHPB_PROFILEMANAGER MATLAB code for SHPB_profilemanager.fig
%      SHPB_PROFILEMANAGER, by itself, creates a new SHPB_PROFILEMANAGER or raises the existing
%      singleton*.
%
%      H = SHPB_PROFILEMANAGER returns the handle to a new SHPB_PROFILEMANAGER or the handle to
%      the existing singleton*.
%
%      SHPB_PROFILEMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHPB_PROFILEMANAGER.M with the given input arguments.
%
%      SHPB_PROFILEMANAGER('Property','Value',...) creates a new SHPB_PROFILEMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SHPB_profilemanager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SHPB_profilemanager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SHPB_profilemanager

% Last Modified by GUIDE v2.5 18-Feb-2019 15:50:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPB_profilemanager_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPB_profilemanager_OutputFcn, ...
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


% --- Executes just before SHPB_profilemanager is made visible.
function SHPB_profilemanager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SHPB_profilemanager (see VARARGIN)

% Choose default command line output for SHPB_profilemanager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% get passed data (mostly GUIpath, but who knows what else might be necessary)
if ~isempty(varargin)
    % exctract
    handles.pass = varargin{1};
    handles.GUIpath = handles.pass.GUIpath;
    currentprofno = handles.pass.currentprofno;
else
    %errordlg('GUIpath not provided by call.','Error')
    %return
    % for testing purposes
    handles.GUIpath = 'C:\Users\theni\Uni\Projekte\SHPB GUI';
    addpath(genpath(handles.GUIpath));
    currentprofno = 1;
end

GUIpath = handles.GUIpath;

% fill poisson ratio dropdown
c = load(fullfile(GUIpath,'resources','pc_data.mat'));
pcList = c.PCinfoString;
set(handles.poissondropdown,'String',pcList)

% load profile index
u = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
meta.N = u.N;
% check if we have profiles yet
if meta.N > 0
    meta.names = u.profiles(:,2);
    meta.paths = u.profiles(:,3);
    meta.current = currentprofno;
    p = load(fullfile(GUIpath,'resources','preferences.mat'));
    meta.default = p.prefs.defaultprofile;
    meta.selection = 1;
    handles.meta = meta;
    % fill profile list
    set(handles.profilelistbox,'String',meta.names)
    set(handles.profilelistbox,'Value',meta.selection)
    % populate fields
    SHPB_updateProfile(handles);

else
    % no profiles yet so everything is empty
    meta.names = [];
    meta.paths = [];
    meta.current = 0;
    meta.default = 0;
    meta.selection = 0;
    handles.meta = meta;
    % fill profile list
    set(handles.profilelistbox,'String','')
    set(handles.profilelistbox,'Value',0)
    % populate fields
    SHPB_updateProfile(handles)

end

% populate current and default disp
if meta.current ~=0
    set(handles.currentprofdisp,'String',['Current Profile: ',meta.names{meta.current}])
else
    set(handles.currentprofdisp,'String',['Current Profile: ','none'])
end
if meta.default ~= 0
    set(handles.defaultprofdisp,'STring',['Default Profile: ',meta.names{meta.default}])
else
    set(handles.defaultprofdisp,'String',['Default Profile: ','none'])
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SHPB_profilemanager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SHPB_profilemanager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in profilelistbox.
function profilelistbox_Callback(hObject, eventdata, handles)
% hObject    handle to profilelistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = get(handles.profilelistbox,'Value');
handles.meta.selection = selection;
% update fields
SHPB_updateProfile(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in deletebtn.
function deletebtn_Callback(hObject, eventdata, handles)
% hObject    handle to deletebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in defaultbtn.
function defaultbtn_Callback(hObject, eventdata, handles)
% hObject    handle to defaultbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.meta.names)
    newdefault = handles.meta.selection;
    GUIpath = handles.GUIpath;
    p = load(fullfile(GUIpath,'resources','preferences.mat'))
    prefs = p.prefs;
    prefs.defaultprofile = newdefault;
    save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
    handles.meta.default = newdefault;
    meta = handles.meta;
    meta.default = newdefault;
    handles.meta = meta;
    set(handles.defaultprofdisp,'String',['Default Profile: ',meta.names{meta.default}])
else
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in currentbtn.
function currentbtn_Callback(hObject, eventdata, handles)
% hObject    handle to currentbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.meta.names)
    % save to file in temp folder which will be checked once the profile manager is closed
    meta = handles.meta;
    newcurrent = handles.meta.selection;
    meta.current = newcurrent;
    GUIpath = handles.GUIpath;
    save(fullfile(GUIpath,'temp','changedProfile.mat'),'newcurrent')
    set(handles.currentprofdisp,'String',['Current Profile: ',meta.names{newcurrent}])
    handles.meta = meta;
else
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in newbtn.
function newbtn_Callback(hObject, eventdata, handles)
% hObject    handle to newbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = SHPB_newProfile(handles,'enable');
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in acceptbtn.
function acceptbtn_Callback(hObject, eventdata, handles)
% hObject    handle to acceptbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = SHPB_newProfile(handles,'accept');
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in cancelbtn.
function cancelbtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = SHPB_newProfile(handles,'cancel');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function profilelistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to profilelistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in poissondropdown.
function poissondropdown_Callback(hObject, eventdata, handles)
% hObject    handle to poissondropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns poissondropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from poissondropdown


% --- Executes during object creation, after setting all properties.
function poissondropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to poissondropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function youngsfield_Callback(hObject, eventdata, handles)
% hObject    handle to youngsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of youngsfield as text
%        str2double(get(hObject,'String')) returns contents of youngsfield as a double


% --- Executes during object creation, after setting all properties.
function youngsfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to youngsfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function densityfield_Callback(hObject, eventdata, handles)
% hObject    handle to densityfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of densityfield as text
%        str2double(get(hObject,'String')) returns contents of densityfield as a double


% --- Executes during object creation, after setting all properties.
function densityfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to densityfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kfactorfield_Callback(hObject, eventdata, handles)
% hObject    handle to kfactorfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kfactorfield as text
%        str2double(get(hObject,'String')) returns contents of kfactorfield as a double


% --- Executes during object creation, after setting all properties.
function kfactorfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kfactorfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amplificationfield_Callback(hObject, eventdata, handles)
% hObject    handle to amplificationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amplificationfield as text
%        str2double(get(hObject,'String')) returns contents of amplificationfield as a double


% --- Executes during object creation, after setting all properties.
function amplificationfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplificationfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltagefield_Callback(hObject, eventdata, handles)
% hObject    handle to voltagefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltagefield as text
%        str2double(get(hObject,'String')) returns contents of voltagefield as a double


% --- Executes during object creation, after setting all properties.
function voltagefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltagefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ratefield_Callback(hObject, eventdata, handles)
% hObject    handle to ratefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ratefield as text
%        str2double(get(hObject,'String')) returns contents of ratefield as a double


% --- Executes during object creation, after setting all properties.
function ratefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ratefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diameterfield_Callback(hObject, eventdata, handles)
% hObject    handle to diameterfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diameterfield as text
%        str2double(get(hObject,'String')) returns contents of diameterfield as a double


% --- Executes during object creation, after setting all properties.
function diameterfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameterfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transmissionfield_Callback(hObject, eventdata, handles)
% hObject    handle to transmissionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transmissionfield as text
%        str2double(get(hObject,'String')) returns contents of transmissionfield as a double


% --- Executes during object creation, after setting all properties.
function transmissionfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transmissionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function incidentfield_Callback(hObject, eventdata, handles)
% hObject    handle to incidentfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of incidentfield as text
%        str2double(get(hObject,'String')) returns contents of incidentfield as a double


% --- Executes during object creation, after setting all properties.
function incidentfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incidentfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strikerfield_Callback(hObject, eventdata, handles)
% hObject    handle to strikerfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strikerfield as text
%        str2double(get(hObject,'String')) returns contents of strikerfield as a double


% --- Executes during object creation, after setting all properties.
function strikerfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strikerfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function barnamefield_Callback(hObject, eventdata, handles)
% hObject    handle to barnamefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of barnamefield as text
%        str2double(get(hObject,'String')) returns contents of barnamefield as a double


% --- Executes during object creation, after setting all properties.
function barnamefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to barnamefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function profnamefield_Callback(hObject, eventdata, handles)
% hObject    handle to profnamefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of profnamefield as text
%        str2double(get(hObject,'String')) returns contents of profnamefield as a double


% --- Executes during object creation, after setting all properties.
function profnamefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to profnamefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function descriptionfield_Callback(hObject, eventdata, handles)
% hObject    handle to descriptionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of descriptionfield as text
%        str2double(get(hObject,'String')) returns contents of descriptionfield as a double


% --- Executes during object creation, after setting all properties.
function descriptionfield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to descriptionfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
