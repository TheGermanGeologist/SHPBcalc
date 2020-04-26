function varargout = SHPB_preferences(varargin)
% SHPB_PREFERENCES MATLAB code for SHPB_preferences.fig
%      SHPB_PREFERENCES, by itself, creates a new SHPB_PREFERENCES or raises the existing
%      singleton*.
%
%      H = SHPB_PREFERENCES returns the handle to a new SHPB_PREFERENCES or the handle to
%      the existing singleton*.
%
%      SHPB_PREFERENCES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHPB_PREFERENCES.M with the given input arguments.
%
%      SHPB_PREFERENCES('Property','Value',...) creates a new SHPB_PREFERENCES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SHPB_preferences_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SHPB_preferences_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SHPB_preferences

% Last Modified by GUIDE v2.5 12-Feb-2019 00:41:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPB_preferences_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPB_preferences_OutputFcn, ...
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


% --- Executes just before SHPB_preferences is made visible.
function SHPB_preferences_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SHPB_preferences (see VARARGIN)

% Choose default command line output for SHPB_preferences
handles.output = hObject;

% Retrieve system information from main GUI
h = findobj('Tag','SHPBgui');
maindata = guidata(h);
systeminfo = maindata.systeminfo;
handles.systeminfo = systeminfo;

% display directory in text field
GUIpath = handles.systeminfo.GUIpath;
msg = ['current directory: ',GUIpath];
set(handles.text9,'String',msg)

% load previous SHPB_preferences
prefpath = fullfile(GUIpath,'resources','preferences.mat');
l = load(prefpath,'prefs');

% populate fields with previous SHPB_preferences
set(handles.Nedit,'String',l.prefs.N);
set(handles.itsedit,'String',l.prefs.iter);
set(handles.autofigurescheck,'Value',l.prefs.autosave);
set(handles.csvsavecheck,'Value',l.prefs.csvsave);
set(handles.txtsavecheck,'Value',l.prefs.txtsave);
set(handles.imgformatslct,'Value',l.prefs.imgformat);
set(handles.dpislct,'Value',l.prefs.dpivalue);
set(handles.aaslct,'Value',l.prefs.aavalue);
set(handles.copyrawcheck,'Value',l.prefs.copyraw);

% extract projects
p = load(fullfile(GUIpath,'resources','projects_index.mat'));
projectslist = 'none';
if p.N > 0
    Projects = p.info;
    % build string
    for ii = 1:p.N
        projectslist = [projectslist,'\n',Projects{ii,2}];
    end
else
end
set(handles.defaultprojctslct,'String',sprintf(projectslist))
% set previous value
set(handles.defaultprojctslct,'Value',l.prefs.defaultproject + 1)

% extract profiles
p = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
profileslist = 'none';
if p.N > 0
    Profiles = p.profiles;
    % build string
    for ii = 1:p.N
        profileslist = [profileslist,'\n',Profiles{ii,2}];
    end
else
end
set(handles.defaultprofslct,'String',sprintf(profileslist))
set(handles.defaultprofslct,'Value',l.prefs.defaultprofile + 1)

% Update handles structure
guidata(hObject, handles);

% move gui to top left corner
movegui(gcf,'center')


% UIWAIT makes SHPB_preferences wait for user response (see UIRESUME)
% uiwait(handles.SHPBpref);


% --- Outputs from this function are returned to the command line.
function varargout = SHPB_preferences_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in autofigurescheck.
function autofigurescheck_Callback(hObject, eventdata, handles)
% hObject    handle to autofigurescheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autofigurescheck


% --- Executes on button press in csvsavecheck.
function csvsavecheck_Callback(hObject, eventdata, handles)
% hObject    handle to csvsavecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of csvsavecheck


% --- Executes on button press in txtsavecheck.
function txtsavecheck_Callback(hObject, eventdata, handles)
% hObject    handle to txtsavecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of txtsavecheck



function Nedit_Callback(hObject, eventdata, handles)
% hObject    handle to Nedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nedit as text
%        str2double(get(hObject,'String')) returns contents of Nedit as a double


% --- Executes during object creation, after setting all properties.
function Nedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function itsedit_Callback(hObject, eventdata, handles)
% hObject    handle to itsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itsedit as text
%        str2double(get(hObject,'String')) returns contents of itsedit as a double


% --- Executes during object creation, after setting all properties.
function itsedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close window
delete(handles.SHPBpref)

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get path
GUIpath = handles.systeminfo.GUIpath;
prefpath = fullfile(GUIpath,'resources','preferences.mat');

% Gather information
N = str2double(get(handles.Nedit,'String'));
iter = str2double(get(handles.itsedit,'String'));
autosave = get(handles.autofigurescheck,'Value');
csvsave = get(handles.csvsavecheck,'Value');
txtsave = get(handles.txtsavecheck,'Value');
imgformat = get(handles.imgformatslct,'Value');
dpivalue = get(handles.dpislct,'Value');
aavalue = get(handles.aaslct,'Value');
copyrawSlct = get(handles.copyrawcheck,'Value');

% TODO (probably done): add restrictions for N and iter
% TODO (probably done): check if N and iter are numeric
if isnumeric(N) && ~isnan(N) && (floor(N) == N)
    % all good
    % check size
    if N <= 50 && N >= 10
      % all good
    else
      % something is wrong
      errordlg('The fourier number N must be an integer between 10 and 50','Invalid fourier number')
      return
    end
else
    % something is wrong
    errordlg('The fourier number N must be an integer between 10 and 50','Invalid fourier number')
    return
end
if isnumeric(iter) && ~isnan(iter) && (floor(iter) == iter)
    % all good
    % check size
    if iter <= 20 && iter >= 5
      % all good
    else
      % something is wrong
      errordlg('The number of fitting iterations must be an integer between 5 and 20','Invalid number of iterations')
      return
    end
else
    % something is wrong
    errordlg('The number of fitting iterations must be an integer between 5 and 20','Invalid number of iterations')
    return
end

% get defaults selection
defProfSlct = get(handles.defaultprofslct,'Value') - 1;
defPrjctSlct = get(handles.defaultprojctslct,'Value') - 1;


% store in struct
prefs.N = N;
prefs.iter = iter;
prefs.autosave = autosave;
prefs.csvsave = csvsave;
prefs.txtsave = txtsave;
prefs.imgformat = imgformat;
prefs.dpivalue = dpivalue;
prefs.aavalue = aavalue;
prefs.defaultprofile = defProfSlct;
prefs.defaultproject = defPrjctSlct;
prefs.copyraw = copyrawSlct;

% Save information
save(prefpath,'prefs')

% Close window
delete(handles.SHPBpref)


% --- Executes on button press in default.
function default_Callback(hObject, eventdata, handles)
% hObject    handle to default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUIpath = handles.systeminfo.GUIpath;
RESpath = fullfile(GUIpath,'resources');

% load default settings
prefs = SHPB_defaultpreferences(RESpath);

% populate fields with default settings
set(handles.Nedit,'String',prefs.N);
set(handles.itsedit,'String',prefs.iter);
set(handles.autofigurescheck,'Value',prefs.autosave);
set(handles.csvsavecheck,'Value',prefs.csvsave);
set(handles.txtsavecheck,'Value',prefs.txtsave);
set(handles.imgformatslct,'Value',prefs.imgformat);
set(handles.dpislct,'Value',prefs.dpivalue);
set(handles.aaslct,'Value',prefs.aavalue);
set(handles.copyrawcheck,'Value',prefs.copyraw);

% save default as current
prefpath = fullfile(GUIpath,'resources','preferences.mat');
save(prefpath,'prefs')


% --- Executes on selection change in defaultprofslct.
function defaultprofslct_Callback(hObject, eventdata, handles)
% hObject    handle to defaultprofslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns defaultprofslct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from defaultprofslct


% --- Executes during object creation, after setting all properties.
function defaultprofslct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to defaultprofslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in defaultprojctslct.
function defaultprojctslct_Callback(hObject, eventdata, handles)
% hObject    handle to defaultprojctslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns defaultprojctslct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from defaultprojctslct


% --- Executes during object creation, after setting all properties.
function defaultprojctslct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to defaultprojctslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imgformatslct.
function imgformatslct_Callback(hObject, eventdata, handles)
% hObject    handle to imgformatslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imgformatslct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imgformatslct


% --- Executes during object creation, after setting all properties.
function imgformatslct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgformatslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dpislct.
function dpislct_Callback(hObject, eventdata, handles)
% hObject    handle to dpislct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dpislct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dpislct


% --- Executes during object creation, after setting all properties.
function dpislct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dpislct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in aaslct.
function aaslct_Callback(hObject, eventdata, handles)
% hObject    handle to aaslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns aaslct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aaslct


% --- Executes during object creation, after setting all properties.
function aaslct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aaslct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in copyrawcheck.
function copyrawcheck_Callback(hObject, eventdata, handles)
% hObject    handle to copyrawcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of copyrawcheck
