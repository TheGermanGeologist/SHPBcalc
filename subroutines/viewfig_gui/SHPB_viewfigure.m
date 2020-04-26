function varargout = SHPB_viewfigure(varargin)
% SHPB_VIEWFIGURE MATLAB code for SHPB_viewfigure.fig
%      SHPB_VIEWFIGURE, by itself, creates a new SHPB_VIEWFIGURE or raises the existing
%      singleton*.
%
%      H = SHPB_VIEWFIGURE returns the handle to a new SHPB_VIEWFIGURE or the handle to
%      the existing singleton*.
%
%      SHPB_VIEWFIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHPB_VIEWFIGURE.M with the given input arguments.
%
%      SHPB_VIEWFIGURE('Property','Value',...) creates a new SHPB_VIEWFIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SHPB_viewfigure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SHPB_viewfigure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SHPB_viewfigure

% Last Modified by GUIDE v2.5 11-Feb-2019 18:11:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPB_viewfigure_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPB_viewfigure_OutputFcn, ...
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


% --- Executes just before SHPB_viewfigure is made visible.
function SHPB_viewfigure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SHPB_viewfigure (see VARARGIN)

% Choose default command line output for SHPB_viewfigure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

abtn=findall(handles.FigureToolBar,'ToolTipString','Save Figure');
set(abtn,'Visible','Off')
bbtn = findall(handles.FigureToolBar,'ToolTipString','New Figure');
set(bbtn,'Visible','Off')
cbtn = findall(handles.FigureToolBar,'ToolTipString','Open File');
set(cbtn,'Visible','Off')
dbtn = findall(handles.FigureToolBar,'ToolTipString','Print Figure');
set(dbtn,'Visible','Off')
ebtn = findall(handles.FigureToolBar,'ToolTipString','Link Plot');
set(ebtn,'Visible','Off')
fbtn = findall(handles.FigureToolBar,'ToolTipString','Insert Colorbar');
set(fbtn,'Visible','Off')
gbtn = findall(handles.FigureToolBar,'ToolTipString','Open Property Inspector');
set(gbtn,'Visible','Off')
hbtn = findall(handles.FigureToolBar,'ToolTipString','Zoom Out');
set(hbtn,'Visible','On')

% check if this is a functional call to this GUI
if ~isempty(varargin)
    % data to plot has been passed
    handles.pass = varargin{1};
    pass = handles.pass;
    imgpath = pass.path;
    set(handles.pathtxt,'String',['Saving images to path: ',imgpath])
    cla(handles.viewfigaxes)
    cla(handles.viewfigaxes,'reset')
    SHPB_plotstep(handles.viewfigaxes, pass.data, pass.expm, pass.step );

    % Update handles structure
    guidata(hObject, handles);
else
    % dummy placeholder plot
    plot(handles.viewfigaxes,[1 2 3 4 5 6 7],[16 8 4 2 1 0.5 0.25])
    hold(handles.viewfigaxes,'on')
    title(handles.viewfigaxes,'Test-Plot')
    xlabel(handles.viewfigaxes,'x-values')
    ylabel(handles.viewfigaxes,'y-values')
    grid(handles.viewfigaxes,'on')
    text(handles.viewfigaxes,4,4,'Test-Annotation')
    legend(handles.viewfigaxes,'Test-Data')
    guidata(hObject, handles);
end

% move gui to top left corner
movegui(gcf,'center')

% UIWAIT makes SHPB_viewfigure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SHPB_viewfigure_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in expfigbtn.
function expfigbtn_Callback(hObject, eventdata, handles)
% hObject    handle to expfigbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% default path for testing purposes
% imgpath = 'C:\Users\theni\Desktop\testbild';

% get data from pass
pass = handles.pass;

% gather information
formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
formatselect(1) = get(handles.pngcheck,'Value');
formatselect(2) = get(handles.jpgcheck,'Value');
formatselect(3) = get(handles.bmpcheck,'Value');
formatselect(4) = get(handles.epscheck,'Value');
formatselect(5) = get(handles.pdfcheck,'Value');
options.fileformats = formatselect;
options.dpi = get(handles.dpislct,'Value');
options.aa = get(handles.aaslct,'Value');

% set background color to white for saving the image
%set(SHPB_viewfigure,'Color','w')
% for some reason the color of plotted data changes by changing the
% background color, so it has to be plotted again..
%cla(handles.viewfigaxes)
%cla(handles.viewfigaxes,'reset')
%plotstep(handles.viewfigaxes, pass.data, pass.expm, pass.step )

% export figure
mode = 2;
SHPB_savefigure(handles.viewfigaxes,pass.step,options,mode,pass.path)

% export_fig(handles.viewfigaxes,imgpath,'-png','-jpg','-r300','-a3')

% reverse background color to original grey
%set(SHPB_viewfigure,'Color',[0.5 0.5 0.5])
% and again, new plot
%cla(handles.viewfigaxes)
%cla(handles.viewfigaxes,'reset')
%plotstep(handles.viewfigaxes, pass.data, pass.expm, pass.step )


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


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


% --- Executes on button press in linewdcheck.
function linewdcheck_Callback(hObject, eventdata, handles)
% hObject    handle to linewdcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of linewdcheck



function linewdval_Callback(hObject, eventdata, handles)
% hObject    handle to linewdval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linewdval as text
%        str2double(get(hObject,'String')) returns contents of linewdval as a double


% --- Executes during object creation, after setting all properties.
function linewdval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linewdval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in jpgcheck.
function jpgcheck_Callback(hObject, eventdata, handles)
% hObject    handle to jpgcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of jpgcheck


% --- Executes on button press in pdfcheck.
function pdfcheck_Callback(hObject, eventdata, handles)
% hObject    handle to pdfcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pdfcheck


% --- Executes on button press in epscheck.
function epscheck_Callback(hObject, eventdata, handles)
% hObject    handle to epscheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of epscheck


% --- Executes on button press in bmpcheck.
function bmpcheck_Callback(hObject, eventdata, handles)
% hObject    handle to bmpcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bmpcheck


% --- Executes on button press in pngcheck.
function pngcheck_Callback(hObject, eventdata, handles)
% hObject    handle to pngcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pngcheck
