%{
SHPB_GUI
Copyright by Matthias Doerfler, 2016

%}


function varargout = SHPBcalc(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPBcalc_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPBcalc_OutputFcn, ...
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


% --- Executes just before SHPBcalc is made visible.
function SHPBcalc_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for SHPBcalc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%------------------------------------------------------------------------

% ######   ######## ######## ##     ## ########
% ##    ## ##          ##    ##     ## ##     ##
% ##       ##          ##    ##     ## ##     ##
%  ######  ######      ##    ##     ## ########
%       ## ##          ##    ##     ## ##
% ##    ## ##          ##    ##     ## ##
%  ######  ########    ##     #######  ##


% >>> SETUP <<<

% display waitbar
fwait = waitbar(0,'Gathering Information..');

% disable warnings
warning('off','MATLAB:RMDIR:RemovedFromPath')

% get seperator of filesystem
pathseperator = filesep;
% check if GUI is running as a standalone version
if isdeployed
    standalone = 1; % is deployed
    % determine OS
    if ispc
        systemid = 1;   % Windows PC
        command = 'echo %USERPROFILE%\Documents';
        [status,docpath] = system(command);
    elseif ismac
        systemid = 2;   % Mac OSX
        command = 'echo ~/Documents';   % check if this is correct
        [status,docpath] = system(command);
    elseif isunix && ~ismac
        systemid = 3;   % Linux
        command = 'echo ~/Documents';   % check if this is correct
        [status,docpath] = system(command);
    else
        status = 1;
        systemid = 0;   % Unknown system
    end
    if status ~= 0 || systemid == 0
        h = warndlg('The program was unable to identify your Documents folder. Please select a folder where you want the program to store data.','Error');
        uiwait(h)
        docpath = uigetdir('','Select a folder');
    else
    end
    docpath = cell2mat(cellstr(docpath));   % ridiculous way to make this into normal string
    GUIpath = fullfile(docpath,'SHPB calc');
else
    standalone = 0; % is running in MATLAB session
    systemid = 0;
    % check if cd is the gui folder
    correctpath = 1;
    try
        SplitPath = regexp(cd,pathseperator,'split');
        cdname = cell2mat(cellstr(SplitPath(end)));
        if strcmp(cdname,'SHPB GUI')
            %all good
        else
            correctpath = 0;
            box = msgbox('Can''t find program folder. Please select the folder in which this program is running.',...
                'Unkown working directory');
            uiwait(box)
            custompath = uigetdir(cd,'Select the folder containing the program file.');
            if isempty(custompath)
                custompath = cd;
                errordlg('No path provided. Continuing with current directory','Null');
            elseif ~(2 == exist('SHPBcalc.m'))
                custompath = cd;
                errordlg('Provided path does not contain the program file.','Error')
            end
        end
            catch
        errordlg('Unknown OS','Can''t check GUI path.')
    end
    if correctpath == 1
        GUIpath = cd;
    else
        GUIpath = custompath;
    end
end

%systeminfo = {standalone, systemid, GUIpath};
% retrieve cell information with cell2mat(cell(x))
% this was bs, use struct, much easier.
systeminfo.standalone = standalone;
systeminfo.systemid = systemid;
systeminfo.GUIpath = GUIpath;
systeminfo.pathsep = filesep;
handles.systeminfo = systeminfo;    % save in handles for later use
% setappdata(handles.SHPBgui,'systeminformation',systeminfo)
handles.MessageHistory = [];
handles.MessageNo = 0;
guidata(hObject,handles)  % update handles

% add GUI path to matlab search path for matlab version
if standalone == 0
    try
        addpath(genpath(GUIpath));
    catch
        errordlg('Couldn''t find program files. Please add the files to the MATLAB search path.',...
            'Missing program files')
    end
else
end

% check if this is the first time the GUI is running
if standalone == 1 && ~exist(GUIpath,'dir')
    m = msgbox('This program will create a folder in your documents folder. Please do not tamper with this.',...
        'Welcome!');
    uiwait(m)
    % build directories and necessary files in Documents folder
    mkdir(docpath,'SHPB calc')
    mkdir(GUIpath,'resources')
    mkdir(GUIpath,'temp')
    mkdir(GUIpath,'projects')
    mkdir(GUIpath,'individual experiments')
    mkdir(fullfile(GUIpath,'resources','profiles'))
    SHPB_defaultpreferences(fullfile(GUIpath,'resources'));
    SHPB_pcdefault(fullfile(GUIpath,'resources'));
    Ncalls = 0;
    save(fullfile(GUIpath,'resources','guicounter.mat'),'Ncalls')
    clearvars Ncalls
    N = 0; info = [];
    save(fullfile(GUIpath,'resources','projects_index.mat'),'N','info')
    clearvars N info
    N = 0; profiles = [];
    save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles')
    clearvars N profiles
    % guiroot = ctfroot;  % get root folder of deployed GUI
    % respath = [guiroot,'\resources'];  % locate resources in root
    % movefile(respath,GUIpath,'f')   % move resources to documents folder
%     m = msgbox('All done. Welcome to SHPB calc!','Welcome!');
%     uiwait(m)
else
end

waitbar(0.33,fwait,'Checking program filesystem...');

% check integrity of GUIpath structure
corrupted = SHPB_checkfiles(GUIpath);
if corrupted == 1
    handles.MessageHistory = sprintf([handles.MessageHistory,'Filesystem integrity was corrupted and successfully restored.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
elseif corrupted == 0
    handles.MessageHistory = sprintf([handles.MessageHistory,'Filesystem integrity was maintained.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end

waitbar(0.67,fwait,'Searching for projects..');

% check projects folder for new or missing projects
output = SHPB_checkprojects(GUIpath);
if output.deletedTrue == 0 && output.addedTrue == 0
    handles.MessageHistory = sprintf([handles.MessageHistory,'No changes to projects folder.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end
if output.deletedTrue == 1
    Ndel = numel(output.deletedList);
    prjstring = [];
    for ii = 1:Ndel
        prjstring = [prjstring,output.deletedList{ii},'\n'];
    end
    handles.MessageHistory = sprintf([handles.MessageHistory,'The following projects were missing:','\n',...
    prjstring,'They were removed from the project index.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end
if output.addedTrue == 1
    Nadd = numel(output.addedList);
    prjstring = [];
    for ii = 1:Nadd
        prjstring = [prjstring,output.addedList{ii},'\n'];
    end
    handles.MessageHistory = sprintf([handles.MessageHistory,'The following projects were added:','\n',...
    prjstring,'\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end

% check profiles
output = SHPB_checkprofiles(GUIpath);
if output.deletedTrue == 0
    handles.MessageHistory = sprintf([handles.MessageHistory,'No changes to profiles.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end
if output.deletedTrue == 1
    Ndel = numel(output.deletedList);
    prjstring = [];
    for ii = 1:Ndel
        prjstring = [prjstring,output.deletedList{ii},'\n'];
    end
    handles.MessageHistory = sprintf([handles.MessageHistory,'The following profiles were missing:','\n',...
    prjstring,'They were removed from the profiles index.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
    guidata(hObject,handles)
else
end

% add GUI path to matlab search path for matlab version
if standalone == 0
    try
        addpath(genpath(GUIpath));
    catch
        errordlg('Couldn''t find program files. Please add the files to the MATLAB search path.',...
            'Missing program files')
    end
else
end



waitbar(1,fwait,'Ready!');
pause(0.5)
close(fwait)

if standalone == 0
    countpath = fullfile(GUIpath,'resources','guicounter.mat');
    count = load(countpath);
    if count.Ncalls > 0
        m = msgbox('Welcome back to SHPB calc!','Welcome!');
        uiwait(m)
    else
        m = msgbox('Welcome to SHPB calc!','Welcome!');
        uiwait(m)
    end
else
end

if standalone == 1
    countpath = fullfile(GUIpath,'resources','guicounter.mat');
    count = load(countpath);
    if count.Ncalls > 0
      m = msgbox('Welcome back to SHPB calc!','Welcome!');
      uiwait(m)
    else
    end
end

% get file 'guicounter'
Ncalls = count.Ncalls;
% add 1 to number of calls
Ncalls = Ncalls + 1;
save(countpath,'Ncalls')

% clear old dump files
% just delete the whole temp folder and make a new one
rmdir(fullfile(GUIpath,'temp'),'s')
mkdir(fullfile(GUIpath,'temp'))

% build GUI background:
% disabled because it looks shit atm
ha = axes('units','normalized','position',[0 0 1 1]);
uistack(ha,'bottom');
% impath = [GUIpath,'\resources\shpbguiback.png'];
% I=imread(impath);
% hi = image(I);
set(ha,'handlevisibility','off','visible','off')
% move gui to top left corner
movegui('center')

% re-enable warnings
warning('on','MATLAB:RMDIR:RemovedFromPath')


%{
Initzialize GUI state: key:
standby:    default state when gui is started
            data import not possible, preferences change possible,
            PC_Curve possible,
resumed:    experiment loaded, keep things locked
ready:      project, experiment and profile are set
            data import possible, preferences change possible, profile
            change possible, changes to project will discard experiment and
            profile, return to standby
start:      data is imported and displayed, start button is made available,
            preferences and profile data is loaded in handles and become
            locked for the current session
evaluating: most framework functionality becomes disabled, the evaluation-
            steps keep track of what's going on
            cancelling evaluation returns to the ready state
done:       evaluation is done, waiting for user to press 'finish' to
            return to standby state
%}
handles.guistate = 'standby';
handles.evalstep = 0;


% initialize active state
active.profile = 'none';
active.project = 'none';
active.expm = 'none';
handles.active = active;

% load preferences
prefinfo.path = fullfile(GUIpath,'resources','preferences.mat');
prefinfo.tempStatus = 0;
handles.prefinfo = prefinfo;
% what the fuck is all of this, just add all preferences to handles..
l = load(prefinfo.path);
handles.prefs = l.prefs;

guidata(hObject,handles)  % update handles

% load default project
selectedPrjct = handles.prefs.defaultproject;
if selectedPrjct ~= 0
    p = load(fullfile(GUIpath,'resources','projects_index.mat'));
    currproj = p.info{selectedPrjct,2};
    % handles.currentproject = currproj;
    active = handles.active;
    active.project = currproj;
    handles.active = active;
    projectinfo.name = currproj;
    projectinfo.path = p.info{selectedPrjct,3};
    handles.projectinfo = projectinfo;
    guidata(hObject,handles)
    set(handles.project_display,'String',['Current Project : ',currproj])
    % output message
    handles.MessageHistory = sprintf([handles.MessageHistory,'Project "',currproj,'" is loaded.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListboxTop',handles.MessageNo);
    set(handles.msg_wind,'Value',handles.MessageNo);
    set(handles.msg_wind,'Value',[]);
    guidata(hObject,handles)
else
    % 0 means 'none' is selcected as default profile
end

% load default profile
selectedProf = handles.prefs.defaultprofile;
if selectedProf ~= 0
    po = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
    if ~isempty(po.profiles)
        currprof = po.profiles{selectedProf,2};
        active = handles.active;
        active.profile = currprof;
        handles.active = active;
        profileinfo.path = po.profiles{selectedProf,3};
        profileinfo.name = currprof;
        profileinfo.no = selectedProf;
        handles.profileinfo = profileinfo;
        guidata(hObject,handles)
        p = load(handles.profileinfo.path);
        profile = p.profile;
        pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
        l = load(pcdatapath);
        set(handles.profile_display,'String',['Profile used: ',currprof])
        set(handles.bar_name_disp,'String',profile.bName)
        set(handles.ymod_disp,'String',num2str(profile.Eb))
        set(handles.density_disp,'String',num2str(profile.roh0b))
        set(handles.poisson_disp,'String',num2str(l.nu(profile.pc)))
        set(handles.bdia_disp,'String',num2str(profile.Db*100))
        set(handles.stlen_disp,'String',num2str(profile.Lp*100))
        set(handles.incdis_disp,'String',num2str(profile.X1))
        set(handles.trandis_disp,'String',num2str(profile.X2))
        set(handles.voltage_disp,'String',num2str(profile.U0))
        set(handles.amp_disp,'String',num2str(profile.V))
        set(handles.kfactor_disp,'String',num2str(profile.k))
        set(handles.rate_disp,'String',num2str(profile.Hz))
    else
        handles.profileinfo.no = 0;
        guidata(hObject,handles)
    end
else
    handles.profileinfo.no = 0;
    guidata(hObject,handles)
    % 0 means 'none' was selcected as default profile
end


% END SETUP
%------------------------------------------------------------------------


% --- Outputs from this function are returned to the command line.
function varargout = SHPBcalc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%   ######## ########     ###    ##     ## ########
%   ##       ##     ##   ## ##   ###   ### ##
%   ##       ##     ##  ##   ##  #### #### ##
%   ######   ########  ##     ## ## ### ## ######
%   ##       ##   ##   ######### ##     ## ##
%   ##       ##    ##  ##     ## ##     ## ##
%   ##       ##     ## ##     ## ##     ## ########

% FRAMEWORK --------------------------------------------------------------
% --------- FRAMEWORK ----------------------------------------------------
% ------------------- FRAMEWORK ------------------------------------------


% >>> EXPLORE <<<
function explore_menu_Callback(hObject, eventdata, handles)
% hObject    handle to explore_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO: build new GUI for exploration of results, call it here
% (priority: low)

% ------------------------------------------------------------------------


% >>> DATA DUMP <<<
function data_dump_Callback(hObject, eventdata, handles)
% hObject    handle to data_dump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.guistate,'evaluating')
    step = handles.evalstep + 1;
    GUIpath = handles.systeminfo.GUIpath;
    temppath = fullfile(GUIpath,'temp',['dump',num2str(step),'.mat']);
    data = handles.data;
    save(temppath,'data')
    % output message
    handles.MessageHistory = sprintf([handles.MessageHistory,'Data dumped to temporary folder','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListboxTop',handles.MessageNo);
    set(handles.msg_wind,'Value',handles.MessageNo);
    set(handles.msg_wind,'Value',[]);
    guidata(hObject,handles)
else
    errordlg('Can''t dump data without active experiment')
    return
end

% ------------------------------------------------------------------------


%      ####  ######   ##    ##  #######  ########  ########
%       ##  ##    ##  ###   ## ##     ## ##     ## ##
%       ##  ##        ####  ## ##     ## ##     ## ##
%       ##  ##   #### ## ## ## ##     ## ########  ######
%       ##  ##    ##  ##  #### ##     ## ##   ##   ##
%       ##  ##    ##  ##   ### ##     ## ##    ##  ##
%      ####  ######   ##    ##  #######  ##     ## ########


% > Ignore < File parent menu
function file_menu_Callback(hObject, eventdata, handles)
% empty

% ------------------------------------------------------------------------

% > Ignore < Tools parent menu
function tools_menu_Callback(hObject, eventdata, handles)
% empty

% ------------------------------------------------------------------------

% >>>Ignore<<<  Executes on selection change in msg_wind.
function msg_wind_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function msg_wind_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<< Executes on button press in safailed_check.
function safailed_check_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<<
function sadia_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function sadia_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function salen_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function salen_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function incdis_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function incdis_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function trandis_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function trandis_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function stlen_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function stlen_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function bdia_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function bdia_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function density_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function density_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function ymod_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function ymod_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function bar_name_disp_Callback(hObject, eventdata, handles)
% emtpy

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function bar_name_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function voltage_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<<
function voltage_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function amp_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function amp_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function kfactor_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function kfactor_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function rate_disp_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<< Executes during object creation, after setting all properties.
function rate_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------

% >>>Ignore<<<
function help_menu_Callback(hObject, eventdata, handles)
% empty

% --------------------------------------------------------------------

% >>>Ignore<<<
function poisson_disp_Callback(hObject, eventdata, handles)
% empty

% >>>Ignore<<< Executes during object creation, after setting all properties.
function poisson_disp_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------


%   ######## ########     ###    ##     ## ########
%   ##       ##     ##   ## ##   ###   ### ##
%   ##       ##     ##  ##   ##  #### #### ##
%   ######   ########  ##     ## ## ### ## ######
%   ##       ##   ##   ######### ##     ## ##
%   ##       ##    ##  ##     ## ##     ## ##
%   ##       ##     ## ##     ## ##     ## ########

% >>> CHANGE INFO PANEL <<<
% --- Executes when selected object is changed in info_type_group.
function info_type_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in info_type_group
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showlog = get(handles.log_info_btn,'value');
showparam = get(handles.param_info_btn,'value');

if showlog == 1 && showparam == 0
    set(handles.value_info,'handlevisibility','off','visible','off')
    set(handles.infopan,'handlevisibility','on','visible','on')
elseif showlog == 0 && showparam == 1
    set(handles.infopan,'handlevisibility','off','visible','off')
    set(handles.value_info,'handlevisibility','on','visible','on')
else
    errordlg('Invalid radio button state','Error')
    return
end

% --------------------------------------------------------------------


% >>> OPEN CUSTOM FIGURE GUI <<<
% --- Executes on button press in customfigbtn.
function customfigbtn_Callback(hObject, eventdata, handles)
% hObject    handle to customfigbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.guistate,'evaluating')  || strcmp(handles.guistate,'done')
    pass.data = handles.data;
    pass.expm = handles.expm;
    pass.step = handles.evalstep - 1;
    pass.path = handles.expminfo.folder;
    SHPB_viewfigure(pass)
else
    errordlg('Can''t customize nonexistent figure.','Error')
    return
end

% --------------------------------------------------------------------


% >>> QUICK SAVE IMAGE <<<
% --- Executes on button press in qsavefigbtn.
function qsavefigbtn_Callback(hObject, eventdata, handles)
% hObject    handle to qsavefigbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.guistate,'evaluating') || strcmp(handles.guistate,'done')
    set(handles.fullaxespan,'BackgroundColor','w')
    options.dpi = handles.prefs.dpivalue;
    options.aa = handles.prefs.aavalue;
    formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
    formatselect(handles.prefs.imgformat) = 1;
    options.fileformats = formatselect;
    imgpath = handles.expminfo.folder;
    SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,1,imgpath)
    set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
else
  errordlg('Can''t save nonexistent figure.','Error')
  return
end

% --------------------------------------------------------------------


% >>> OPEN ABOUT INFOSCREEN <<<
function about_menu_Callback(hObject, eventdata, handles)
% hObject    handle to about_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% call about sub gui
SHPB_about

% --------------------------------------------------------------------

% >>> OPEN BROWSER DOCUMENTATION <<<
function document_menu_Callback(hObject, eventdata, handles)
% hObject    handle to document_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'https://thegermangeologist.rocks/software/shpbcalc/shpbcalcdocumentation/';
web(url,'-browser')

% --------------------------------------------------------------------


% >>> DISPLAY POCHHAMMER CHREE IN VIEWFIGURE <<<
function viewpc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to viewpc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIpath = handles.systeminfo.GUIpath;
pass.data = load(fullfile(GUIpath,'resources','pc_data.mat'));
pass.expm = [];
pass.step = 42;
pass.path = GUIpath;
SHPB_viewfigure(pass)

% --------------------------------------------------------------------

% >>> OPEN PROJECT IN FILESYSTEM <<<
function filesystemView_Callback(hObject, eventdata, handles)
% hObject    handle to filesystemView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(handles.active.project,'none')
    if ispc
        winopen(handles.projectinfo.path)
    elseif ismac
        system(['open ',handles.projectinfo.path])
    elseif ~ismac && isunix
        system(['xdg-open ',handles.projectinfo.path])
    else
    end
else
    errordlg('No active project','Error')
    return
end

% --------------------------------------------------------------------



% >> NEW PROFILE <<
function new_profile_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_profile_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##    ## ######## ##      ##    ########  ########
        %    ###   ## ##       ##  ##  ##    ##     ## ##     ##
        %    ####  ## ##       ##  ##  ##    ##     ## ##     ##
        %    ## ## ## ######   ##  ##  ##    ########  ########
        %    ##  #### ##       ##  ##  ##    ##        ##   ##
        %    ##   ### ##       ##  ##  ##    ##        ##    ##
        %    ##    ## ########  ###  ###     ##        ##     ##

% get path to profiles folder
GUIpath = handles.systeminfo.GUIpath;
profpath = fullfile(GUIpath,'resources','profiles');
% load profiles index
profindexpath = fullfile(profpath,'profindex.mat');
ProfS = load(profindexpath);
N = ProfS.N;
ExistProfs = ProfS.profiles;
% get name of new profile, make sure that it is unique
validname = 0;

% TODO: change this to if exist(profilefile) (priority: low)

while validname == 0
    newprofilename = inputdlg('Enter a unique name for the new profile:','Name');
    if isempty(newprofilename)
        return
    else
    end
    newprofilename = cell2mat(newprofilename);
    % check if this is not the first profile being created
    if N ~= 0
        % check if name is unique
        for i = 1:N
            nameN = cell2mat(ExistProfs(N,2));
            if strcmp(nameN,newprofilename)
                errordlg('A profile with this name already exists, please chose a different name.',...
                    'Name not unique')
                validname = 2;
            else
            end
        end
        if validname == 2
            % name was at least once identical, still not valid
            validname = 0;
        else
            % value of validname did not change, so it is valid
            validname = 1;
        end
    else
        validname = 1; % this is the first profile, so it's name must be valid
    end
end

% Get profile description
ProfileDescription = inputdlg('Description (This will be used to identify the profile):',...
        'Profile description',[3 100]);
% Gather data for new profile
% trust user to do this correctly, wrong input might break the program
% though

% TODO: possibly add name of striker, maybe description is good enough
% though (priority: low)

prompt = {'Voltage at strain gauges (Peak to Peak) [V]:','k-factor of strain gauges:',...
          'Amplification of the voltage:','Name of bar:','Bar diameter [m]:','Young''s Modulus of the bar [GPa]:',...
          'Density of the bar [kg/m^3]:','Samplerate [MHz]:','Striker length [m]:',...
          'Distance of incident strain gauges to end of incident bar [m]:',...
          'Distance of transmission strain gauges to start of transmission bar [m]:'};
title = ['Data for profile ',newprofilename];
ProfileData = inputdlg(prompt,title);
if isempty(ProfileData)
    return
else
end

% TODO: Ask for a Pochhammer Chree Curve to use with this profile!
% (priority: probably done)
% store in profile.pc as the number of the curve in the pcdata file

pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
l = load(pcdatapath);
PCList = l.PCinfoString;
[SlctPC,ok] = listdlg('Name','Pochhammer-Chree Selection','PromptString','Select a Pochhammer-Chree curve',...
    'SelectionMode','single','ListSize',[330 230],'ListString',PCList);
if ok == 0
    return
else
end
% ProfileData is a cell
% {U0,k,V,bName,Db,Eb,roh0b,Hz,Lp,X1,X2}
% retrieve with str2num(cell2mat(ProfileData(i)))

% store in a struct instead for easier accesability
profile.U0 = str2double(cell2mat(ProfileData(1)));
profile.k = str2double(cell2mat(ProfileData(2)));
profile.V = str2double(cell2mat(ProfileData(3)));
profile.bName = cell2mat(ProfileData(4));
profile.Db = str2double(cell2mat(ProfileData(5)));
profile.Eb = str2double(cell2mat(ProfileData(6)));
profile.roh0b = str2double(cell2mat(ProfileData(7)));
profile.Hz = str2double(cell2mat(ProfileData(8)));
profile.Lp = str2double(cell2mat(ProfileData(9)));
profile.X1 = str2double(cell2mat(ProfileData(10)));
profile.X2 = str2double(cell2mat(ProfileData(11)));
profile.pc = SlctPC;


% save Profile:
savepath = fullfile(GUIpath,'resources','profiles',[newprofilename,'.mat']);
save(savepath,'ProfileDescription','ProfileData','profile')

% TODO: ( probably done )
% set new profile as current profile if Project is active
% if blabla
%     handles.currentprofile = newprofilename;
%     guidata(hObject,handles)
%     set(handles.profile_display,'String',['Profile used: ',newprofilename])
% else
% end

% if a project is active set new profile as current profile
if strcmp(handles.active.project,'none') && strcmp(handles.guistate,'evaluating')
    % no project, do nothing
    % or evaluating
else
    handles.active.profile = newprofilename;
    profileinfo.path = savepath;
    profileinfo.name = newprofilename;
    handles.profileinfo = profileinfo;
    guidata(hObject,handles)
    set(handles.profile_display,'String',['Profile used: ',newprofilename])
    set(handles.bar_name_disp,'String',profile.bName)
    set(handles.ymod_disp,'String',num2str(profile.Eb))
    set(handles.density_disp,'String',num2str(profile.roh0b))
    set(handles.poisson_disp,'String',num2str(l.nu(SlctPC)))
    set(handles.bdia_disp,'String',num2str(profile.Db*100))
    set(handles.stlen_disp,'String',num2str(profile.Lp*100))
    set(handles.incdis_disp,'String',num2str(profile.X1))
    set(handles.trandis_disp,'String',num2str(profile.X2))
    set(handles.voltage_disp,'String',num2str(profile.U0))
    set(handles.amp_disp,'String',num2str(profile.V))
    set(handles.kfactor_disp,'String',num2str(profile.k))
    set(handles.rate_disp,'String',num2str(profile.Hz))
end

% update profindex
N = N + 1;
profiles = ExistProfs;
profiles{N,1} = N;
profiles{N,2} = newprofilename;
profiles{N,3} = savepath;
save(profindexpath,'N','profiles')

% TODO: check if conditions are met to switch from standby to ready
% (priority: probably done)

active = handles.active;
if strcmp(active.project,'none') || strcmp(active.profile,'none') ||...
        strcmp(active.expm,'none')
    % at least one condition is not met
else
    % all are different from none -> switch to ready
    handles.guistate = 'ready';
    set(handles.status_disp,'String','Status: ready')
    guidata(hObject,handles)
    set(handles.import_menu,'Enable','On')
end

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'New Profile "',newprofilename,'" was created.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListBoxTop',handles.MessageNo);
guidata(hObject,handles)

% ------------------------------------------------------------------------


% >>> LOAD PROFILE <<<
function load_profile_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_profile_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##        #######     ###    ########     ########  ########
        %    ##       ##     ##   ## ##   ##     ##    ##     ## ##     ##
        %    ##       ##     ##  ##   ##  ##     ##    ##     ## ##     ##
        %    ##       ##     ## ##     ## ##     ##    ########  ########
        %    ##       ##     ## ######### ##     ##    ##        ##   ##
        %    ##       ##     ## ##     ## ##     ##    ##        ##    ##
        %    ########  #######  ##     ## ########     ##        ##     ##

% TODO: check if project is active, otherwise dont allow profile selection
% (priority: probably done)
% no idea what the reasoning behind this was, the order shouldn't matter here
% cant see anything obious

%if strcmp(handles.active.project,'none')
%    errordlg('No active project','You can''t activate a profile without an active project.')
%    return
%else
%end

if strcmp(handles.guistate,'evaluating')
  errordlg('Can''t change profile while evaluating.','Error')
  return
else
end

% get list of profiles
GUIpath = handles.systeminfo.GUIpath;
profpath = fullfile(GUIpath,'resources','profiles');
profindexpath = fullfile(profpath,'profindex.mat');
ProfS = load(profindexpath);
N = ProfS.N;
% check if there are profiles available for selection
if N ~= 0
    % Selection dialogue
    ExistProfs = ProfS.profiles;
    ProfilesList = ExistProfs(:,2);
    [SelectedProf,ok] = listdlg('Name','Profile selection','PromptString','Chose a profile',...
        'SelectionMode','single','ListString',ProfilesList);
    % TODO: prepare for cancel
else
    % no profiles yet
    msgbox('No existing profiles','You must create a profile before you can choose one.')
    return
end
% set profile upon selection
if ok == 1
    currprof = cell2mat(ExistProfs(SelectedProf,2));
    active = handles.active;
    active.profile = currprof;
    handles.active = active;
    profileinfo.path = cell2mat(ExistProfs(SelectedProf,3));
    profileinfo.name = currprof;
    profileinfo.no = SelectedProf;
    handles.profileinfo = profileinfo;
    guidata(hObject,handles)
    p = load(handles.profileinfo.path);
    profile = p.profile;
    pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
    l = load(pcdatapath);
    set(handles.profile_display,'String',['Profile used: ',currprof])
    set(handles.bar_name_disp,'String',profile.bName)
    set(handles.ymod_disp,'String',num2str(profile.Eb))
    set(handles.density_disp,'String',num2str(profile.roh0b))
    set(handles.poisson_disp,'String',num2str(l.nu(profile.pc)))
    set(handles.bdia_disp,'String',num2str(profile.Db*100))
    set(handles.stlen_disp,'String',num2str(profile.Lp*100))
    set(handles.incdis_disp,'String',num2str(profile.X1))
    set(handles.trandis_disp,'String',num2str(profile.X2))
    set(handles.voltage_disp,'String',num2str(profile.U0))
    set(handles.amp_disp,'String',num2str(profile.V))
    set(handles.kfactor_disp,'String',num2str(profile.k))
    set(handles.rate_disp,'String',num2str(profile.Hz))
else
    % else do nothing
    return
end

% TODO: check if conditions are met to switch from standby to ready
% (priority: probably done)
active = handles.active;
if strcmp(active.project,'none') || strcmp(active.profile,'none') ||...
        strcmp(active.expm,'none')
    % at least one condition is not met
else
    % all are different from none -> switch to ready
    handles.guistate = 'ready';
    set(handles.status_disp,'String','Status: ready')
    set(handles.status_disp,'ForegroundColor',[0 1 0])
    guidata(hObject,handles)
    set(handles.import_menu,'Enable','On')
end

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'Profile "',currprof,'" is loaded.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)
% ------------------------------------------------------------------------


% > Ignore < New Pochhammer Chree parent menu
function new_p_c_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_p_c_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------------------------------------------------------------------


% >>> SET PREFERENCES <<<
function preferences_menu_Callback(hObject, eventdata, handles)
% hObject    handle to preferences_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ########  ########  ######## ########
        %    ##     ## ##     ## ##       ##
        %    ##     ## ##     ## ##       ##
        %    ########  ########  ######   ######
        %    ##        ##   ##   ##       ##
        %    ##        ##    ##  ##       ##
        %    ##        ##     ## ######## ##

% TODO: either add warning that changing preferences while evaluation is in
% progress will cause problems or disable it entirely
% (priority:  probably done)
% TODO: this is barely a failsafe, later make sure that preferences can't
% be called when changing guistate (priority: low)
% TODO: in preferences: add cancel button functionality

guistate = handles.guistate;
if strcmp(guistate,'start') || strcmp(guistate,'evaluating') || strcmp(guistate,'done')
    errordlg('Can''t change preferences','You can''t change the preferences while evaluating data.')
    return
else
end

% open preferences sub-GUI
SHPB_preferences
% do stuff
GUIpath = handles.systeminfo.GUIpath;
prefinfo.path = fullfile(GUIpath,'resources','preferences.mat');
prefinfo.tempStatus = 0;
handles.prefinfo = prefinfo;

% actually, load the stuff now
l = load(prefinfo.path);
handles.prefs = l.prefs;

guidata(hObject,handles)

% ------------------------------------------------------------------------


% >>> NEW PROJECT <<<
function new_project_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_project_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##    ## ######## ##      ##    ########        ##
        %    ###   ## ##       ##  ##  ##    ##     ##       ##
        %    ####  ## ##       ##  ##  ##    ##     ##       ##
        %    ## ## ## ######   ##  ##  ##    ########        ##
        %    ##  #### ##       ##  ##  ##    ##        ##    ##
        %    ##   ### ##       ##  ##  ##    ##        ##    ##
        %    ##    ## ########  ###  ###     ##         ######

% TODO: make this into a functional form, for use in other callbacks!

% New Project: barely creates a new directory for the project and sets it
% as the current project
GUIpath = handles.systeminfo.GUIpath;
projectindexpath = fullfile(GUIpath,'resources','projects_index.mat');
l = load(projectindexpath);
ProjectInfo = l.info;
% ProjectNames is cell, names in (:,2)
N = l.N;


% TODO: in this state ProjectPaths is a struct with the actual variable as
% a field, same applies to ProjectNames above
% (priority: probably done)
% ProjectPaths is cell, paths in (:,2), wrong
% ProjectPaths = ProjectPaths.Paths;  % this should fix it, clean up when confirmed

% what in gods name is this monstrosity..
% it works, but
% TODO: fix this
if N ~= 0
    validname = 0;
    while validname == 0
        ProjectName = inputdlg('Enter a name for your project:','Project name');
        if isempty(ProjectName)
            return
        else
        end
        ProjectName = cell2mat(ProjectName);
        for i = 1:N
            NprojectName = ProjectInfo{i,2};
            if strcmp(ProjectName,NprojectName) || strcmp(ProjectName,'individuals')
                errordlg('A project with this name already exists, please chose a different name.',...
                    'Name not unique')
                validname = 2;
            else
            end
        end
        if validname == 2
            % name was at least once identical, still not valid
            validname = 0;
        else
            % check for illegal characters
            [ok,msg] = CheckFileName(ProjectName);
            if ok == 0
                m = errordlg(msg,'Invalid name');
                uiwait(m)
                validname = 0;
            else
                if isempty(ProjectName)
                    validname = 0;
                else
                    % value of validname did not change, so it is valid
                    validname = 1;
                end
            end
        end
    end
else
    ProjectName = inputdlg('Enter a name for your project:','Project name');
    if isempty(ProjectName)
        return
    else
    end
    ProjectName = cell2mat(ProjectName);
end
ProjectDescription = inputdlg('Description of this project:',...
        'Project description',[3 100]);
ProjectDescription = cell2mat(ProjectDescription);

% TODO: ask if a specific profile should be tied to this project.
% if yes: ask if it should be an existing profile -> list, or a new profile
% (priority: low)

% disabling user choice for project folder location makes life easier
%ProjectPath = uigetdir(GUIpath,'Choose a folder for your project:');
%if isempty(ProjectPath)
%    return
%elseif ProjectPath == 0
%    return
%else
%end
Ncarry = N + 1;

% folder issue should be fixed, make sure to try in controlled environement
% though

% create directory and file
mkdir(fullfile(GUIpath,'projects',ProjectName))
projectsubpath = fullfile(GUIpath,'projects',ProjectName); % path to directory
projectnamepath = fullfile(projectsubpath,[ProjectName,'.mat']); % path to file
N = 0; expms = {}; % expms is cell with columns: N,datenum,name,eval,meanrate,ucd,tanmod,failed
save(projectnamepath,'ProjectDescription','N','expms')

N = Ncarry;

% update project index
%ProjectNames(N,:) = {N,ProjectName};
%Names = ProjectNames;
%ProjectPaths(N,:) = {N,projectsubpath};
%Paths = ProjectPaths;

ProjectInfo{N,1} = N;
ProjectInfo{N,2} = ProjectName;
ProjectInfo{N,3} = projectsubpath;
info = ProjectInfo;
save(projectindexpath,'N','info','-append')

% Set as current project
% handles.currentproject = ProjectName;
active = handles.active;
active.project = ProjectName;
handles.active = active;
projectinfo.name = ProjectName;
projectinfo.path = projectsubpath;
handles.projectinfo = projectinfo;
guidata(hObject,handles)
set(handles.project_display,'String',['Current Project: ',ProjectName])

% TODO: replace this with active.project (priority: probably done)
% TODO: add to handles: projectinfo.meta_n with meta data of the project
% (priority: probably done)

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'New project "',ProjectName,'" was created.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% ------------------------------------------------------------------------


% >>> LOAD PROJECT <<<
function load_project_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_project_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##        #######     ###    ########     ########        ##
        %    ##       ##     ##   ## ##   ##     ##    ##     ##       ##
        %    ##       ##     ##  ##   ##  ##     ##    ##     ##       ##
        %    ##       ##     ## ##     ## ##     ##    ########        ##
        %    ##       ##     ## ######### ##     ##    ##        ##    ##
        %    ##       ##     ## ##     ## ##     ##    ##        ##    ##
        %    ########  #######  ##     ## ########     ##         ######

% get list of projects
GUIpath = handles.systeminfo.GUIpath;
projectindexpath = fullfile(GUIpath,'resources','projects_index.mat');
l = load(projectindexpath);
ProjectInfo = l.info;
N = l.N;
% check if there are projects available for selection
if N ~= 0
    % Selection dialogue
    ProjectList = ProjectInfo(:,2);
    [SlctProject,ok] = listdlg('Name','Project selection','PromptString','Chose a project',...
        'SelectionMode','single','ListString',ProjectList);
else
    % no projects yet
    msgbox('No existing projects','You must create a project before you can choose one.')
    return
end

% TODO: after selection show project description and ask for confirmation
%       priority: low
% TODO: change stuff below to handles.active.project (priority: probably done)
% TODO: update handles.projectinfo (priority: probably done)

% set project upon selection
if ok == 1
    currproj = ProjectInfo{SlctProject,2};
    % handles.currentproject = currproj;
    active = handles.active;
    active.project = currproj;
    handles.active = active;
    projectinfo.name = currproj;
    projectinfo.path = ProjectInfo{SlctProject,3};
    handles.projectinfo = projectinfo;
    guidata(hObject,handles)
    set(handles.project_display,'String',['Current Project : ',currproj])
    % output message
    handles.MessageHistory = sprintf([handles.MessageHistory,'Project "',currproj,'" is loaded.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListboxTop',handles.MessageNo);
    set(handles.msg_wind,'Value',handles.MessageNo);
    set(handles.msg_wind,'Value',[]);
    guidata(hObject,handles)
else
    % else do nothing
    return
end

% ------------------------------------------------------------------------


% >>> NEW EXPERIMENT <<<
function new_experiment_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_experiment_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##    ## ######## ##      ##    ######## ##     ##
        %    ###   ## ##       ##  ##  ##    ##        ##   ##
        %    ####  ## ##       ##  ##  ##    ##         ## ##
        %    ## ## ## ######   ##  ##  ##    ######      ###
        %    ##  #### ##       ##  ##  ##    ##         ## ##
        %    ##   ### ##       ##  ##  ##    ##        ##   ##
        %    ##    ## ########  ###  ###     ######## ##     ##

% if project active: make experiment in project
% if no project yet: ask if individual experiment should be perforemd, or
% if a existing project should be chosen

% TODO: each project folder needs an exmp_index.mat file to store
% information about the experiments contained in the project (number of
% experiments, cell with names, datenum) (priority: probably done)

% get project name, if active
active = handles.active;
activeproject = active.project;

GUIpath = handles.systeminfo.GUIpath;

% check if project is active and prepare for experiment creation
if strcmp(activeproject,'none')
    % no active project, do stuff accordingly
    % TODO: add option to choose or create a project when trying to create
    % a new experiment with no active project (priority: medium)
    errordlg('The option to choose a project will be added in a future release.','No active project')
    return
else
    % project is active, retrieve project meta data
    projectinfo = handles.projectinfo;
    projectpath = projectinfo.path;
    projectname = projectinfo.name;
end

% gather experiment info
% get name, make sure it is unique
%validname = 0;
%while validname ~= 1
%    expmname = inputdlg('Enter a name for your experiment:','Experiment name');
%    if isempty(expmname)
%        return
%    else
%    end
%    expmname = cell2mat(expmname);
%    expmpath = fullfile(projectpath,expmname);
%    a = exist(expmpath,'dir');
%    if a == 7
%        % already exists
%        errordlg('Name not unique','An experiment with this name already exists in this project.')
%        validname = 2;
%    else
%        % name is new
%        validname = 1;
%    end
%end

% load project index
pr = load(fullfile(GUIpath,'projects',activeproject,[activeproject,'.mat']));
existingexpms = pr.expms;
if ~isempty(existingexpms)
    existingnames = string(existingexpms(:,3));
else
    existingnames = '';
end

validname = 0;
while validname ~= 1
    expmname = inputdlg('Enter a name for your experiment:','Experiment name');
    if isempty(expmname)
        return
    else
    end
    expmname = cell2mat(expmname);
    if any(strcmp(expmname,existingnames))
        % already exists
        m = errordlg('An experiment with this name already exists in this project.','Name not unique');
        uiwait(m)
        validname = 2;
    else
        % check for illegal characters
        [ok,msg] = CheckFileName(expmname);
        if ok == 0
            m = errordlg(msg,'Invalid name');
            uiwait(m)
            validname = 2;
        else
            if isempty(expmname)
                validname = 2;
            else
                % name is new
                validname = 1;
            end
        end
    end
end
expmpath = fullfile(projectpath,expmname);

% get data
prompt = {'Length of sample [mm]:','Diameter of sample [mm]:','Pressure [bar]:',...
          'Striker velocity v0 [m/s]:','Date the experiment was performed: [dd.mm.yyyy]'};
title = 'Experiment information:';
expmdata = inputdlg(prompt,title,[1 60]);
% return if canceled
if isempty(expmdata)
  return
else
end
% return if fields are empty
if any(cellfun(@isempty,expmdata(1:2)))
    return
else
end
% store data in struct
expm.Ls = str2double(cell2mat(expmdata(1)))/1000;
expm.Ds = str2double(cell2mat(expmdata(2)))/1000;
expm.cp = str2double(cell2mat(expmdata(3)));
expm.v0 = str2double(cell2mat(expmdata(4)));
expm.date = cell2mat(expmdata(5));
expm.eval = 0;

% ask if the sample failed
samplefail = questdlg('Did the sample fail (fracture)?','Sample failure','yes','no','no');
if strcmp(samplefail,'yes')
    expm.fail = 1;
elseif strcmp(samplefail,'no')
    expm.fail = 0;
else
    errordlg('Something went wrong','Error')
    return
end
% get lithology
lit = load(fullfile(GUIpath,'resources','lithologies.mat'));
lithologies = lit.lithologies;
[lithslct,ok] = listdlg('PromptString','Select a lithology:','SelectionMode','single','ListString',lithologies);
if ok == 0
    lithology = 'undefined';
else
    lithology = lithologies{lithslct};
end
expm.lith = lithology;


% get description
expmDescription = inputdlg('Remarks and observations:',...
        'Experiment description',[5 75]);
expm.dscrpt = cell2mat(expmDescription);

% load project index
projectfilepath = fullfile(projectpath,[projectname,'.mat']); % path to file
index = load(projectfilepath);
N = index.N;
expms = index.expms;

% build experiment directory
N = N + 1;
if N < 10
    fullexpmname = ['00',num2str(N),expmname];
elseif N >= 10 && N < 100
    fullexpmname = ['0',num2str(N),expmname];
elseif N >= 100
    fullexpmname = [num2str(N),expmname];
end
mkdir(projectpath,fullexpmname)
expmpath = fullfile(projectpath,fullexpmname);

% save experiment data
expmfilepath = fullfile(expmpath,'experiment.mat');
save(expmfilepath,'expm')

% update information in project file
% expms is cell with columns: N,datenum,name,eval,meanrate,ucd,tanmod,failed
expms{N,1} = N;
expms{N,2} = now;
expms{N,3} = expmname;
expms{N,4} = 0;
expms{N,5} = [];
expms{N,6} = [];
expms{N,7} = [];
expms{N,8} = expm.fail;
expms{N,9} = fullexpmname;
save(projectfilepath,'N','expms','-append')

% TODO: set as current experiment
active = handles.active;
active.expm = expmname;
handles.active = active;
expminfo.path = expmfilepath;
expminfo.folder = expmpath;
expminfo.name = expmname;
handles.expminfo = expminfo;
guidata(hObject,handles)
set(handles.experiment_display,'String',['Current Exp.: ',expmname])
set(handles.safailed_check,'Value',expm.fail)
set(handles.sadia_disp,'String',num2str(expm.Ds*1000))
set(handles.salen_disp,'String',num2str(expm.Ls*1000))

% enable data import
set(handles.import_menu,'handlevisibility','on')

% TODO: check if conditions are met to switch from standby to ready
active = handles.active;
if strcmp(active.project,'none') || strcmp(active.profile,'none') ||...
        strcmp(active.expm,'none')
    % at least one condition is not met
else
    % all are different from none -> switch to ready
    handles.guistate = 'ready';
    set(handles.status_disp,'String','Status: ready')
    set(handles.status_disp,'ForegroundColor',[0 1 0])
    guidata(hObject,handles)
    set(handles.import_menu,'Enable','On')
end

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'New experiment "',expmname,'" was created.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% ------------------------------------------------------------------------


%    #### ##    ## ########  #### ##     ## #### ########
%     ##  ###   ## ##     ##  ##  ##     ##  ##  ##     ##
%     ##  ####  ## ##     ##  ##  ##     ##  ##  ##     ##
%     ##  ## ## ## ##     ##  ##  ##     ##  ##  ##     ##
%     ##  ##  #### ##     ##  ##   ##   ##   ##  ##     ##
%     ##  ##   ### ##     ##  ##    ## ##    ##  ##     ##
%    #### ##    ## ########  ####    ###    #### ########


function individmenu_Callback(hObject, eventdata, handles)
% hObject    handle to individmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set 'individual' as current project

GUIpath = handles.systeminfo.GUIpath;
active = handles.active;
active.project = 'individuals';
handles.active = active;
projectinfo.name = 'individuals';
projectinfo.path = fullfile(GUIpath,'individual experiments');
handles.projectinfo = projectinfo;
guidata(hObject,handles)
set(handles.project_display,'String',['Current Project : ','individuals'])
% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'Project "','individuals','" is loaded.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% get name, make sure it is unique
% load project index
pr = load(fullfile(GUIpath,'individual experiments','individuals.mat'));
existingexpms = pr.expms;
if ~isempty(existingexpms)
    existingnames = string(existingexpms(:,3));
else
    existingnames = '';
end
validname = 0;
while validname ~= 1
    expmname = inputdlg('Enter a name for your experiment:','Experiment name');
    if isempty(expmname)
        return
    else
    end
    expmname = cell2mat(expmname);

    if any(strcmp(expmname,existingnames))
        % already exists
        m = errordlg('An experiment with this name already exists in this project.','Name not unique');
        uiwait(m)
        validname = 2;
    else
        % check for illegal characters
        [ok,msg] = CheckFileName(expmname);
        if ok == 0
            m = errordlg(msg,'Invalid name')
            uiwait(m)
            validname = 2;
        else
            if isempty(expmname)
                validname = 2;
            else
                % name is new
                validname = 1;
            end
        end
    end
end
expmpath = fullfile(GUIpath,'individual experiments',expmname);

% load project index
index = load(fullfile(GUIpath,'individual experiments','individuals.mat'));
N = index.N;
expms = index.expms;

% build experiment directory
N = N + 1;
if N < 10
    fullexpmname = ['00',num2str(N),expmname];
elseif N >= 10 && N < 100
    fullexpmname = ['0',num2str(N),expmname];
elseif N >= 100
    fullexpmname = [num2str(N),expmname];
end
mkdir(fullfile(GUIpath,'individual experiments'),fullexpmname)
expmpath = fullfile(GUIpath,'individual experiments',fullexpmname);

% save experiment data
expmfilepath = fullfile(expmpath,'experiment.mat');
expm = [];
save(expmfilepath,'expm')

% update information in project file
% expms is cell with columns: N,datenum,name,eval,meanrate,ucd,tanmod,failed
expms{N,1} = N;
expms{N,2} = now;
expms{N,3} = expmname;
expms{N,4} = 0;
expms{N,5} = [];
expms{N,6} = [];
expms{N,7} = [];
expms{N,8} = [];
save(fullfile(GUIpath,'individual experiments','individuals.mat'),'N','expms','-append')

% set as current experiment
active = handles.active;
active.expm = expmname;
handles.active = active;
expminfo.path = expmfilepath;
expminfo.folder = expmpath;
expminfo.name = expmname;
handles.expminfo = expminfo;
guidata(hObject,handles)
set(handles.experiment_display,'String',['Current Exp.: ',expmname])

% enable data import
set(handles.import_menu,'handlevisibility','on')

% enable experiment value fields
set(handles.salen_disp,'Enable','on')
set(handles.sadia_disp,'Enable','on')
set(handles.safailed_check,'Enable','on')

% TODO: check if conditions are met to switch from standby to ready
active = handles.active;
if strcmp(active.project,'none') || strcmp(active.profile,'none') ||...
        strcmp(active.expm,'none')
    % at least one condition is not met
else
    % all are different from none -> switch to ready
    handles.guistate = 'ready';
    set(handles.status_disp,'String','Status: ready')
    set(handles.status_disp,'ForegroundColor',[0 1 0])
    guidata(hObject,handles)
    set(handles.import_menu,'Enable','On')
end

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'New experiment "',expmname,'" was created.','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% ------------------------------------------------------------------------


% >>> LOAD EXPERIMENT <<<
function load_experiment_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_experiment_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% probably useless
msgbox('This function has yet to be implemented.','Funtion unavailable.')

% ------------------------------------------------------------------------


% >>> LOAD POCHHAMMER CHREE FROM FILE <<<
function new_p_c_load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_p_c_load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('This function has yet to be implemented.','Funtion unavailable.')

% ------------------------------------------------------------------------


% >>> INTERPOLATE POCHHAMMER CHREE FROM EXISTING VALUES <<<
function new_p_c_int_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_p_c_int_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ########   ######     #### ##    ## ########
        %    ##     ## ##    ##     ##  ###   ##    ##
        %    ##     ## ##           ##  ####  ##    ##
        %    ########  ##           ##  ## ## ##    ##
        %    ##        ##           ##  ##  ####    ##
        %    ##        ##    ##     ##  ##   ###    ##
        %    ##         ######     #### ##    ##    ##

% build up input
GUIpath = handles.systeminfo.GUIpath;
pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
newnu = inputdlg('Enter a poisson ratio for your new curve:','Poisson ratio');
if isempty(newnu)
    return
else
end
newname = inputdlg('Enter a name for your new curve:','Name');
if isempty (newname)
    return
else
end
newnu = str2double(cell2mat(newnu));
newname = cell2mat(newname);

% check if newnu is valid
if newnu <= 0 || newnu >= 1
    errordlg('Invalid poisson ratio','Your poisson ratio must be between 0 and 1.')
    return
else
end

% TODO: name should be unique, too. not mandatory, but would be confusing
% to have multiple pc curves of the same name. (priority: low)

% execute pc interpolate subroutine
try
    status  = SHPB_pcinterpol( newnu,pcdatapath,newname );
catch
    status = 3;
end

% follow up
switch status
    case 1
        % success
        msgbox('Success!','A new Pochhammer Chree curve was interpolated.')
    case 2
        % curve for this nu-value already in existence
        errordlg('Poission ratio not new',...
                 'A Pochhammer Chree curve for this poisson ratio already exists.')
    case 3
        % something went wrong, dammit
        errordlg('For fucks sake...','Something went wrong. Sorry.')
    otherwise
        % should never get there
end


% ------------------------------------------------------------------------


% > Ignore < Parent menu for import options
function import_menu_Callback(hObject, eventdata, handles)
% hObject    handle to import_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------------------------------------------------------------------


% >>> UIIMPORT FOR ANY DATA <<<
function uiimport_menu_Callback(hObject, eventdata, handles)
% hObject    handle to uiimport_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ##     ##    #### ##     ## ########   #######  ########  ########
        %    ##     ##     ##  ###   ### ##     ## ##     ## ##     ##    ##
        %    ##     ##     ##  #### #### ##     ## ##     ## ##     ##    ##
        %    ##     ##     ##  ## ### ## ########  ##     ## ########     ##
        %    ##     ##     ##  ##     ## ##        ##     ## ##   ##      ##
        %    ##     ##     ##  ##     ## ##        ##     ## ##    ##     ##
        %     #######     #### ##     ## ##         #######  ##     ##    ##

if strcmp(handles.active.expm,'none')
    errordlg('Can''t import data without active experiment','Invalid call')
    return
else
end

m = warndlg('Attention: You HAVE to name the data as follows, otherwise the program won''t work!',...
       'Warning');
uiwait(m)
m = msgbox('time = t, incident A = DMS1A0A1, incident B = DMS1B0A2, transmission A = DMS2A0A3, transmission B = DMS2B0A4');
uiwait(m)

uiimport('-file');               % Open Matlab import dialogue

breaktime = 0;          % initialize failsafe
% this loop puts everything on hold until the data with the variable t is
% imported or a time of roughly 5 minutes has passed
% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'Reading data...','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

while ~ exist('t','var') && breaktime < 270
    breaktime = breaktime + 1;
    pause(1)
end
if breaktime >= 270
    errordlg('Time has expired','Error')
    return
elseif ~isempty(t)
    msgbox('Data succesfully imported','Success')
else
end

% collect data
raw1a = DMS1A0A1;
raw1b = DMS1B0A2;
raw2a = DMS2A0A3;
raw2b = DMS2B0A4;
data.rawt = t;
data.raw1a = raw1a;
data.raw1b = raw1b;
data.raw2a = raw2a;
data.raw2b = raw2b;

% save to handles
handles.data = data;
guidata(hObject,handles)

% plot preview in fullaxes
plot(handles.fullaxes,t,raw1a,t,raw2a)
hold(handles.fullaxes)
grid(handles.fullaxes,'on')
xlabel(handles.fullaxes,'time [s]')
ylabel(handles.fullaxes,'Voltage [V]')
legend(handles.fullaxes,'Incident bar signal','Transmission bar signal')
title(handles.fullaxes,'Imported data - preview')

% change guistate to start
handles.guistate = 'start';
guidata(hObject,handles)
set(handles.status_disp,'String','Status: start')
set(handles.status_disp,'ForegroundColor',[0 0 1])

% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'Data successfully imported','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% ------------------------------------------------------------------------


% >>> STANDARD IMPORT FROM TRANAX <<<
function stdimport_menu_Callback(hObject, eventdata, handles)
% hObject    handle to stdimport_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %     ######     #### ##     ## ########   #######  ########  ########
        %    ##    ##     ##  ###   ### ##     ## ##     ## ##     ##    ##
        %    ##           ##  #### #### ##     ## ##     ## ##     ##    ##
        %     ######      ##  ## ### ## ########  ##     ## ########     ##
        %          ##     ##  ##     ## ##        ##     ## ##   ##      ##
        %    ##    ##     ##  ##     ## ##        ##     ## ##    ##     ##
        %     ######     #### ##     ## ##         #######  ##     ##    ##

if strcmp(handles.active.expm,'none')
    errordlg('Can''t import data without active experiment','Invalid call')
    return
else
end

[name,path] = uigetfile('*.asd','Choose a file to import');

if isequal(name,0) || isequal(path,0)
    return; % was cancelled
else
    fullpath = [path,name]; % build path
    try
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Reading data...','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % call custom import function
        [t,raw1a,raw1b,raw2a,raw2b] = SHPB_stdimport(fullpath);
    catch
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Something went wrong, sorry.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        errordlg('Damn...','Something went wrong. Sorry.')
        return
    end
    % collect data
    data.rawt = t;
    data.raw1a = raw1a;
    data.raw1b = raw1b;
    data.raw2a = raw2a;
    data.raw2b = raw2b;
    % save to handles
    handles.data = data;
    guidata(hObject,handles)
    % plot preview in fullaxes
    plot(handles.fullaxes,t,raw1a,t,raw2a)
    hold(handles.fullaxes)
    grid(handles.fullaxes,'on')
    xlabel(handles.fullaxes,'time [s]')
    ylabel(handles.fullaxes,'Voltage [V]')
    legend(handles.fullaxes,'Incident bar signal','Transmission bar signal')
    title(handles.fullaxes,'Imported data - preview')
    % copy file to expm folder if desired
    if handles.prefs.copyraw == 1
        copyfile(fullpath,handles.expminfo.folder)
    else
    end
    % change guistate to start
    handles.guistate = 'start';
    guidata(hObject,handles)
    set(handles.status_disp,'String','Status: start')
    set(handles.status_disp,'ForegroundColor',[0 0 1])
    % output message
    handles.MessageHistory = sprintf([handles.MessageHistory,'Data succesfully imported.','\n']);
    handles.MessageNo = handles.MessageNo + 1;
    set(handles.msg_wind,'String',handles.MessageHistory);
    set(handles.msg_wind,'ListboxTop',handles.MessageNo);
    set(handles.msg_wind,'Value',handles.MessageNo);
    set(handles.msg_wind,'Value',[]);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------

% >Ignore< parent menu for developer tools
function devtool_Callback(hObject, eventdata, handles)
% hObject    handle to devtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------


% >>>DEV PURGE<<<
function devpurge_Callback(hObject, eventdata, handles)
% hObject    handle to devpurge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        %    ########  ##     ## ########   ######   ########
        %    ##     ## ##     ## ##     ## ##    ##  ##
        %    ##     ## ##     ## ##     ## ##        ##
        %    ########  ##     ## ########  ##   #### ######
        %    ##        ##     ## ##   ##   ##    ##  ##
        %    ##        ##     ## ##    ##  ##    ##  ##
        %    ##         #######  ##     ##  ######   ########

% make sure if this is really intentional
purgechoice = questdlg('Warning: Purging will reset everything to it''s initial state.',...
        'Purge ?','Purge','Cancel','Cancel');
% follow up
% TODO: prepare for case in which the user has already deleted something
% himself, the path referring to this file or directory would then be
% outdated and trying to delete it throws an error (priority: HIGH)
switch purgechoice
    case 'Purge'
            % disable warnings
            warning('off','MATLAB:RMDIR:RemovedFromPath')
            % get GUI path
            systeminfo = handles.systeminfo;
            GUIpath = handles.systeminfo.GUIpath;
            % reset preferences to default
            prefs = SHPB_defaultpreferences(fullfile(GUIpath,'resources'));
            prefpath = fullfile(GUIpath,'resources','preferences.mat');
            save(prefpath,'prefs')
            handles.prefinfo.tempStatus = 0;
            handles.prefs = prefs;
            % generate original Pochhammer Chree file
            pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
            delete(pcdatapath)
            try
                status = SHPB_pcdefault(fullfile(GUIpath,'resources'));
            catch
                status = 0;
            end
            if status == 0
                errordlg('For fucks sake...','Something went wrong. Sorry.')
                return
            else
            end
            % reset guicounter
            countpath = fullfile(GUIpath,'resources','guicounter.mat');
            Ncalls = 0;
            save(countpath,'Ncalls')
            % delete all projects (this should also delete all experiments)
            rmdir(fullfile(GUIpath,'projects'),'s')
            mkdir(fullfile(GUIpath,'projects'))
            try
                % delete individual experiments
                individpath = fullfile(GUIpath,'individual experiments');
                rmdir(individpath,'s')
                mkdir(GUIpath,'individual experiments')
                individindexpath = fullfile(GUIpath,'individuals.mat');
                % reset individuals index
                N = 0;
                info = [];
                save(individindexpath,'N','info')
                % delete all profiles
                profpath = fullfile(GUIpath,'resources','profiles');
                profindexpath = fullfile(profpath,'profindex.mat');
                rmdir(profpath,'s')
                mkdir(fullfile(GUIpath,'resources'),'profiles')
                % reset profiles index
                N = 0;
                profiles = {};
                save(profindexpath,'N','profiles')
            catch
                errordlg('Oops.','Error while purging. Individuals or profiles.')
            end
            % reset guistate
            active = handles.active;    % useless command?
            active.profile = 'none';
            active.project = 'none';
            active.expm = 'none';
            handles.active = active;
            handles.guistate = 'standby';
            handles.evalstep = 0;
            % clear loaded preferences and profile
            handles.profile = [];
            % update handles
            guidata(hObject,handles)
            % TODO: clear handles.data
            % TODO: activate, deactivate and bring to front the appropriate
            % things
            % re-add folders to matlab search paths
            addpath(genpath(GUIpath));
            % set all strings in GUI to initial state
            set(handles.status_disp,'String','Status: standby')
            set(handles.status_disp,'ForegroundColor',[1 0.412 0.161])
            set(handles.step_disp,'String','Step: 0')
            set(handles.project_display,'String','Current project: none')
            set(handles.profile_display,'String','Profile used: none')
            set(handles.experiment_display,'String','Current Exp.: none')
            set(handles.ctrl_prompt,'String','')
            set(handles.import_menu,'handlevisibility','off')
            set(handles.bar_name_disp,'String','')
            set(handles.ymod_disp,'String','')
            set(handles.density_disp,'String','')
            set(handles.poisson_disp,'String','')
            set(handles.bdia_disp,'String','')
            set(handles.stlen_disp,'String','')
            set(handles.incdis_disp,'String','')
            set(handles.trandis_disp,'String','')
            set(handles.voltage_disp,'String','')
            set(handles.amp_disp,'String','')
            set(handles.kfactor_disp,'String','')
            set(handles.rate_disp,'String','')
            set(handles.safailed_check,'Value',0)
            set(handles.sadia_disp,'String','')
            set(handles.salen_disp,'String','')
            set(handles.customfigbtn,'Enable','off')
            % output message
            handles.MessageHistory = sprintf([handles.MessageHistory,'Null state restored.','\n']);
            handles.MessageNo = handles.MessageNo + 1;
            set(handles.msg_wind,'String',handles.MessageHistory);
            set(handles.msg_wind,'ListboxTop',handles.MessageNo);
            set(handles.msg_wind,'Value',handles.MessageNo);
            set(handles.msg_wind,'Value',[]);
            guidata(hObject,handles)
            % re-enable warnings
            warning('on','MATLAB:RMDIR:RemovedFromPath')
            % TODO: everything (priority: high)


    case 'Cancel'

    otherwise
end

% ------------------------------------------------------------------------


% END FRAMEWORK ----------------------------------------------------------
% --------- END FRAMEWORK ------------------------------------------------
% ------------------- END FRAMEWORK --------------------------------------

% ######## ##     ##    ###    ##
% ##       ##     ##   ## ##   ##
% ##       ##     ##  ##   ##  ##
% ######   ##     ## ##     ## ##
% ##        ##   ##  ######### ##
% ##         ## ##   ##     ## ##
% ########    ###    ##     ## ########


% EVALUATION -------------------------------------------------------------
% --------- EVALUATION ---------------------------------------------------
% ------------------- EVALUATION -----------------------------------------

% >>> START / CONTINUE <<<
function start_cont_btn_Callback(hObject, eventdata, handles)
% hObject    handle to start_cont_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Under this button callback all necessary evaluation steps are called one after
% another.
step = handles.evalstep;
guistate = handles.guistate;
if strcmp(guistate,'start') || strcmp(guistate,'evaluating') || strcmp(guistate,'done')
    % call is valid
else
    errordlg('Invalid call','Can''t call function in this guistate')
    return
end
data = handles.data;

switch step
    case 0
        % check if this is an individual experiment
        if strcmp(handles.active.project,'individuals')
            % get data
            expm.Ls = str2num(get(handles.salen_disp,'String')) ./ 1000;
            expm.Ds = str2num(get(handles.sadia_disp,'String')) ./ 1000;
            expm.fail = get(handles.safailed_check,'Value');
            expm.eval = 0;
            expm.date = now;
            expm.dscrpt = 'individual experiment';
            expm.cp = NaN;
            expm.v0 = NaN;
            expm.lith = 'undefined';
            % check data
            if  isempty(expm.Ls) || isempty(expm.Ds)
                errordlg('Experiment data not provided','Error')
                return
            elseif expm.Ls <= 0 || expm.Ds <= 0
                errordlg('Experiment data not provided','Error')
                return
            end
            % save in experiments folder
            save(handles.expminfo.path,'expm','-append')
            % add to handles
            handles.expm = expm;
            % lock experiment info fields
            set(handles.salen_disp,'Enable','off')
            set(handles.sadia_disp,'Enable','off')
            set(handles.safailed_check,'Enable','off')
        else
        end

        % data has just been imported, btn says start
        % plot all data, then turn btn to "bending correction"

        %    ########     ###    ##      ##
        %    ##     ##   ## ##   ##  ##  ##
        %    ##     ##  ##   ##  ##  ##  ##
        %    ########  ##     ## ##  ##  ##
        %    ##   ##   ######### ##  ##  ##
        %    ##    ##  ##     ## ##  ##  ##
        %    ##     ## ##     ##  ###  ###

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % plot raw data
        status = SHPB_raw( data,handles.fullaxes );
        set(handles.start_cont_btn,'String','Bending correction')
        handles.evalstep = 1;   % proceed
        handles.guistate = 'evaluating';
        set(handles.step_disp,'String','Step: 1')
        set(handles.status_disp,'String','Status: evaluating')
        set(handles.status_disp,'ForegroundColor',[0.6 0.18 0.7])
        % enable custom figure button
        set(handles.customfigbtn,'Enable','on')
        set(handles.qsavefigbtn,'Enable','on')

        % load profile, expm and prefs
        p = load(handles.profileinfo.path);
        handles.profile = p.profile;
        p = load(handles.prefinfo.path);
        p = load(handles.expminfo.path);
        handles.expm = p.expm;
        guidata(hObject,handles)
        
        set(handles.bendINa,'Enable','on')
        set(handles.bendINb,'Enable','on')
        set(handles.bendTa,'Enable','on')
        set(handles.bendTb,'Enable','on')
        
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Displaying raw data','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 1
        % bending correction

        %    ########  ######## ##    ## ########
        %    ##     ## ##       ###   ## ##     ##
        %    ##     ## ##       ####  ## ##     ##
        %    ########  ######   ## ## ## ##     ##
        %    ##     ## ##       ##  #### ##     ##
        %    ##     ## ##       ##   ### ##     ##
        %    ########  ######## ##    ## ########

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % bending
        useSignals = [1 1 1 1];
        if get(handles.bendINa,'Value') == 0
            useSignals(1) = 0;
        end
        if get(handles.bendINb,'Value') == 0
            useSignals(2) = 0;
        end
        if get(handles.bendTa,'Value') == 0
            useSignals(3) = 0;
        end
        if get(handles.bendTb,'Value') == 0
            useSignals(4) = 0;
        end
        if useSignals(1) == 0 && useSignals(2) == 0 || useSignals(3) == 0 && useSignals(4) == 0
            errordlg('Select at least one Transmission and one Incident Signal','Error')
            return
        end
        set(handles.bendINa,'Enable','off')
        set(handles.bendINb,'Enable','off')
        set(handles.bendTa,'Enable','off')
        set(handles.bendTb,'Enable','off')
        signalsArg = [1 2 3 4];
        if useSignals(1) == 0
            signalsArg(1) = 2;
        end
        if useSignals(2) == 0
            signalsArg(2) = 1;
        end
        if useSignals(3) == 0
            signalsArg(3) = 4;
        end
        if useSignals(4) == 0
            signalsArg(4) = 3;
        end
        dataOut = SHPB_bending( data,handles.fullaxes,signalsArg );
        set(handles.start_cont_btn,'String','Select timewindow')
        set(handles.step_disp,'String','Step: 2')
        handles.data = dataOut; % update data struct
        handles.evalstep = 2;   % proceed
        guidata(hObject,handles)
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Bending component removed.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 2
        % timewindow: Incident signal

        %    ######## #### ##     ## ########    #### ##    ##
        %       ##     ##  ###   ### ##           ##  ###   ##
        %       ##     ##  #### #### ##           ##  ####  ##
        %       ##     ##  ## ### ## ######       ##  ## ## ##
        %       ##     ##  ##     ## ##           ##  ##  ####
        %       ##     ##  ##     ## ##           ##  ##   ###
        %       ##    #### ##     ## ########    #### ##    ##

        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % tell user what to do:
        set(handles.ctrl_prompt,'String','Select the incident pulse!')

        try
            handles = SHPB_brushtimewindow(handles);
        catch
            handles = SHPB_ginputtimewindow(handles);
        end

        handles.evalstep = 3;   % proceed
        set(handles.step_disp,'String','Step: 3')
        guidata(hObject,handles)
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Incident pulse selected','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 3
        % timewindow: Reflected signal

        %    ######## #### ##     ## ########    ########  ########
        %       ##     ##  ###   ### ##          ##     ## ##
        %       ##     ##  #### #### ##          ##     ## ##
        %       ##     ##  ## ### ## ######      ########  ######
        %       ##     ##  ##     ## ##          ##   ##   ##
        %       ##     ##  ##     ## ##          ##    ##  ##
        %       ##    #### ##     ## ########    ##     ## ########

        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % tell user what to do:
        set(handles.ctrl_prompt,'String','Select the reflected pulse!')

        try
            handles = SHPB_brushtimewindow(handles);
        catch
            handles = SHPB_ginputtimewindow(handles);
        end

        handles.evalstep = 4;   % proceed
        set(handles.step_disp,'String','Step: 4')
        guidata(hObject,handles)
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Reflected pulse selected','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 4
        % timewindow: Transmitted signal

        %    ######## #### ##     ## ########    ######## ########
        %       ##     ##  ###   ### ##             ##    ##     ##
        %       ##     ##  #### #### ##             ##    ##     ##
        %       ##     ##  ## ### ## ######         ##    ########
        %       ##     ##  ##     ## ##             ##    ##   ##
        %       ##     ##  ##     ## ##             ##    ##    ##
        %       ##    #### ##     ## ########       ##    ##     ##

        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % tell user what to do:
        set(handles.ctrl_prompt,'String','Select the transmitted pulse!')

        try
            handles = SHPB_brushtimewindow(handles);
        catch
            handles = SHPB_ginputtimewindow(handles);
        end

        handles.evalstep = 5;   % proceed
        set(handles.step_disp,'String','Step: 5')
        guidata(hObject,handles)
        % update instructions
        set(handles.ctrl_prompt,'String','')
        % prepare for next step
        set(handles.start_cont_btn,'String','Dispersion correction')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Transmitted pulse selected','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end
    case 5
        % dispersion correction Incident

        %    ########  ####  ######  ########     #### ##    ##
        %    ##     ##  ##  ##    ## ##     ##     ##  ###   ##
        %    ##     ##  ##  ##       ##     ##     ##  ####  ##
        %    ##     ##  ##   ######  ########      ##  ## ## ##
        %    ##     ##  ##        ## ##            ##  ##  ####
        %    ##     ##  ##  ##    ## ##            ##  ##   ###
        %    ########  ####  ######  ##           #### ##    ##
        set(handles.customfigbtn,'Enable','off')
        set(handles.fullaxespan,'visible','off')
        % perform precalculations (only once needed, duh)
        expm = handles.expm;
        profile = handles.profile;
        data = SHPB_precalc( data,expm,profile );
        % dispersion correction
        GUIpath = handles.systeminfo.GUIpath;
        prefs = handles.prefs;
        [fInfo,data] = SHPB_dispersion( data,prefs,profile,step,GUIpath,handles.quarteraxes1,handles.quarteraxes2,handles.quarteraxes3,handles.quarteraxes4 );
        % check fourier status
        if fInfo.status == 1
            handles.prefinfo.tempStatus = 1;
            handles.prefs.N = fInfo.N;
            % output message
            handles.MessageHistory = sprintf([handles.MessageHistory,'Fourier No. reduced to ',num2str(fInfo.N),' for all subsequent dispersion corrections.','\n']);
            handles.MessageNo = handles.MessageNo + 1;
            set(handles.msg_wind,'String',handles.MessageHistory);
            set(handles.msg_wind,'ListboxTop',handles.MessageNo);
            set(handles.msg_wind,'Value',handles.MessageNo);
            set(handles.msg_wind,'Value',[]);
            guidata(hObject,handles)
        else
            % all good
        end
        % store results
        handles.data = data;
        handles.evalstep = 6;
        set(handles.step_disp,'String','Step: 6')
        guidata(hObject,handles)
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Incident signal corrected for dispersion','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 6
        % dispersion correction Reflected

        %    ########  ####  ######  ########     ########  ########
        %    ##     ##  ##  ##    ## ##     ##    ##     ## ##
        %    ##     ##  ##  ##       ##     ##    ##     ## ##
        %    ##     ##  ##   ######  ########     ########  ######
        %    ##     ##  ##        ## ##           ##   ##   ##
        %    ##     ##  ##  ##    ## ##           ##    ##  ##
        %    ########  ####  ######  ##           ##     ## ########

        % clear axes
        cla(handles.quarteraxes1)
        cla(handles.quarteraxes1,'reset')
        cla(handles.quarteraxes2)
        cla(handles.quarteraxes2,'reset')
        cla(handles.quarteraxes3)
        cla(handles.quarteraxes3,'reset')
        cla(handles.quarteraxes4)
        cla(handles.quarteraxes4,'reset')
        % dispersion correction
        GUIpath = handles.systeminfo.GUIpath;
        prefs = handles.prefs;
        profile = handles.profile;
        [fInfo,data] = SHPB_dispersion( data,prefs,profile,step,GUIpath,handles.quarteraxes1,handles.quarteraxes2,handles.quarteraxes3,handles.quarteraxes4 );
        % check fourier status
        if fInfo.status == 1
            handles.prefinfo.tempStatus = 1;
            handles.prefs.N = fInfo.N;
            % output message
            handles.MessageHistory = sprintf([handles.MessageHistory,'Fourier No. reduced to ',num2str(fInfo.N),' for all subsequent dispersion corrections.','\n']);
            handles.MessageNo = handles.MessageNo + 1;
            set(handles.msg_wind,'String',handles.MessageHistory);
            set(handles.msg_wind,'ListboxTop',handles.MessageNo);
            set(handles.msg_wind,'Value',handles.MessageNo);
            set(handles.msg_wind,'Value',[]);
            guidata(hObject,handles)
        else
            % all good
        end
        % store results
        handles.data = data;
        handles.evalstep = 7;
        set(handles.step_disp,'String','Step: 7')
        guidata(hObject,handles)
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Reflected signal corrected for dispersion','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 7
        % dispersion correction Transmitted

        %    ########  ####  ######  ########     ######## ########
        %    ##     ##  ##  ##    ## ##     ##       ##    ##     ##
        %    ##     ##  ##  ##       ##     ##       ##    ##     ##
        %    ##     ##  ##   ######  ########        ##    ########
        %    ##     ##  ##        ## ##              ##    ##   ##
        %    ##     ##  ##  ##    ## ##              ##    ##    ##
        %    ########  ####  ######  ##              ##    ##     ##

        % clear axes
        cla(handles.quarteraxes1)
        cla(handles.quarteraxes1,'reset')
        cla(handles.quarteraxes2)
        cla(handles.quarteraxes2,'reset')
        cla(handles.quarteraxes3)
        cla(handles.quarteraxes3,'reset')
        cla(handles.quarteraxes4)
        cla(handles.quarteraxes4,'reset')
        % dispersion correction
        GUIpath = handles.systeminfo.GUIpath;
        prefs = handles.prefs;
        profile = handles.profile;
        [fInfo,data] = SHPB_dispersion( data,prefs,profile,step,GUIpath,handles.quarteraxes1,handles.quarteraxes2,handles.quarteraxes3,handles.quarteraxes4 );
        % check fourier status
        if fInfo.status == 1
            handles.prefinfo.tempStatus = 1;
            handles.prefs.N = fInfo.N;
            % output message
            handles.MessageHistory = sprintf([handles.MessageHistory,'Fourier No. reduced to ',num2str(fInfo.N),' for all subsequent dispersion corrections.','\n']);
            handles.MessageNo = handles.MessageNo + 1;
            set(handles.msg_wind,'String',handles.MessageHistory);
            set(handles.msg_wind,'ListboxTop',handles.MessageNo);
            set(handles.msg_wind,'Value',handles.MessageNo);
            set(handles.msg_wind,'Value',[]);
            guidata(hObject,handles)
        else
            % all good
        end
        % store results
        handles.data = data;
        handles.evalstep = 8;
        set(handles.step_disp,'String','Step: 8')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Time correction')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Transmitted signal corrected for dispersion','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        set(handles.customfigbtn,'Enable','on')
        guidata(hObject,handles)
        %  debug data dump
        %  assignin('base','unshifted',data)
    case 8
        % shift signals

        %     ######  ##     ## #### ######## ########
        %    ##    ## ##     ##  ##  ##          ##
        %    ##       ##     ##  ##  ##          ##
        %     ######  #########  ##  ######      ##
        %          ## ##     ##  ##  ##          ##
        %    ##    ## ##     ##  ##  ##          ##
        %     ######  ##     ## #### ##          ##

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        set(handles.fullaxespan,'visible','on')
        % shift
        profile = handles.profile;
        data = SHPB_shift( data,profile,handles.fullaxes );
        % store results
        handles.data = data;
        handles.evalstep = 9;
        set(handles.step_disp,'String','Step: 9')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Cut')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Signals shifted to correct time.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        % debug data dump
        % assignin('base','shifted',data)
    case 9
        % cut to equal length

        %    ######  ##     ## ########
        %   ##    ## ##     ##    ##
        %   ##       ##     ##    ##
        %   ##       ##     ##    ##
        %   ##       ##     ##    ##
        %   ##    ## ##     ##    ##
        %    ######   #######     ##

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % cut
        profile = handles.profile;
        data = SHPB_cut( data,profile,handles.fullaxes );
        % store results
        handles.data = data;
        handles.evalstep = 10;
        set(handles.step_disp,'String','Step: 10')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Stress & Strain')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Signals cut to equal length','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end
    case 10
        % calculate Stress & Strain

        %     ######  ########  ######  ########
        %    ##    ##    ##    ##    ##    ##
        %    ##          ##    ##          ##
        %     ######     ##     ######     ##
        %          ##    ##          ##    ##
        %    ##    ##    ##    ##    ##    ##
        %     ######     ##     ######     ##

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % calculation
        profile = handles.profile;
        expm = handles.expm;
        data = SHPB_stst( data,profile,expm,handles.fullaxes );
        % store results
        handles.data = data;
        handles.evalstep = 11;
        set(handles.step_disp,'String','Step: 11')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Strain rate')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Stress calculated.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end
    case 11
        % strain rate, first call to rate

        %    ########     ###    ######## ########
        %    ##     ##   ## ##      ##    ##
        %    ##     ##  ##   ##     ##    ##
        %    ########  ##     ##    ##    ######
        %    ##   ##   #########    ##    ##
        %    ##    ##  ##     ##    ##    ##
        %    ##     ## ##     ##    ##    ########

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % calculation
        SHPB_rate( data,step,handles.fullaxes );
        % store results
        handles.data = data;
        handles.evalstep = 12;
        set(handles.step_disp,'String','Step: 12')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Timewindow')
        set(handles.ctrl_prompt,'String','Select the timewindow to calculate the mean strain rate!')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Strain rate calculated.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 12
        % mean strain rate, 2nd call to rate

        %    ##     ## ########    ###    ##    ##    ########
        %    ###   ### ##         ## ##   ###   ##    ##     ##
        %    #### #### ##        ##   ##  ####  ##    ##     ##
        %    ## ### ## ######   ##     ## ## ## ##    ########
        %    ##     ## ##       ######### ##  ####    ##   ##
        %    ##     ## ##       ##     ## ##   ###    ##    ##
        %    ##     ## ######## ##     ## ##    ##    ##     ##

        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % update instructions
        set(handles.ctrl_prompt,'String','Chose a region for the mean strain rate!')
        % activate mouse input
        [x,y] = ginput(2);
        % selected borders
        lbord = x(1);   % lower border value
        ubord = x(2);   % upper border value
        t = handles.data.tCut;      % the time array we are searching
        rate = handles.profile.Hz;  % this is the sampling rate in MHz
        xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
        % get absolute values
        MrLow = xpos(1);    % lower border array position
        MrUp = xpos(2);    % upper border array position
        % store results
        data.MrLow = MrLow;
        data.MrUp = MrUp;
        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % determine mean strain rate and plot
        data = SHPB_rate( data,step,handles.fullaxes );
        % more results
        handles.data = data;
        handles.evalstep = 13;   % proceed
        set(handles.step_disp,'String','Step: 13')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Cumulative Strain')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Mean strain rate determined.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        % update instruction
        set(handles.ctrl_prompt,'String','')

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end

    case 13
%         ######  ##     ## ##     ## ##     ## ##
%        ##    ## ##     ## ###   ### ##     ## ##
%        ##       ##     ## #### #### ##     ## ##
%        ##       ##     ## ## ### ## ##     ## ##
%        ##       ##     ## ##     ## ##     ## ##
%        ##    ## ##     ## ##     ## ##     ## ##
%         ######   #######  ##     ##  #######  ########
        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % plot
        SHPB_cumstrain(handles.fullaxes,data)
        handles.evalstep = 14;    % proceed
        set(handles.step_disp,'String','Step: 14')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Stress vs Strain')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Displaying cumulative sample strain','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end
    case 14
        % plot stress vs. strain

        %     ######  ########    ##     ##  ######      ######  ########
        %    ##    ##    ##       ##     ## ##    ##    ##    ##    ##
        %    ##          ##       ##     ## ##          ##          ##
        %     ######     ##       ##     ##  ######      ######     ##
        %          ##    ##        ##   ##        ##          ##    ##
        %    ##    ##    ##         ## ##   ##    ##    ##    ##    ##
        %     ######     ##          ###     ######      ######     ##

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % plot
        data = SHPB_modulus( data,handles.expm,step,handles.fullaxes );
        handles.evalstep = 15;   % proceed
        set(handles.step_disp,'String','Step: 15')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Tangent modulus')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Displaying stress vs. strain curve','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    case 15
        % select timewindow for tangent-modulus

        %    ########    ###    ##    ## ##     ##  #######  ########
        %       ##      ## ##   ###   ## ###   ### ##     ## ##     ##
        %       ##     ##   ##  ####  ## #### #### ##     ## ##     ##
        %       ##    ##     ## ## ## ## ## ### ## ##     ## ##     ##
        %       ##    ######### ##  #### ##     ## ##     ## ##     ##
        %       ##    ##     ## ##   ### ##     ## ##     ## ##     ##
        %       ##    ##     ## ##    ## ##     ##  #######  ########

        % set fullaxes as current axes
        axes(handles.fullaxes)
        hold(handles.fullaxes)
        % update instructions
        set(handles.ctrl_prompt,'String','Select the linear elastic region for the tangent modulus!')
        % activate mouse input
        [x,y] = ginput(2);
        TmLow = x(1);    % lower border array position
        TmUp = x(2);    % upper border array position
        % store results
        data.TmLow = TmLow;
        data.TmUp = TmUp;
        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        % calculate tangent-modulus, plot again
        data = SHPB_modulus( data,handles.expm,step,handles.fullaxes );
        % more results
        handles.data = data;
        handles.evalstep = 16;   % proceed
        set(handles.step_disp,'String','Step: 16')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','UCD')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Tangent modulus calculated.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        % update instructions
        set(handles.ctrl_prompt,'String','')
    case 16
        % determine UCD

        %    ##     ##  ######  ########
        %    ##     ## ##    ## ##     ##
        %    ##     ## ##       ##     ##
        %    ##     ## ##       ##     ##
        %    ##     ## ##       ##     ##
        %    ##     ## ##    ## ##     ##
        %     #######   ######  ########

        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')

        % ucd
        data = SHPB_modulus( data,handles.expm,step,handles.fullaxes );
        % store results
        handles.data = data;
        handles.evalstep = 17;   % proceed
        set(handles.step_disp,'String','Step: 17')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Fracture Work')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Maximum stress found.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)

        % autosave if activated
        if handles.prefs.autosave == 1
            set(handles.fullaxespan,'BackgroundColor','w')
            options.dpi = handles.prefs.dpivalue;
            options.aa = handles.prefs.aavalue;
            formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
            formatselect(handles.prefs.imgformat) = 1;
            options.fileformats = formatselect;
            imgpath = handles.expminfo.folder;
            SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
            set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
        else
        end
        
    case 17
        % Extended Evaluation:
        % Fracture work
        set(handles.customfigbtn,'Enable','off')
        set(handles.fullaxespan,'visible','off')
        set(handles.quarteraxespan,'visible','off')
        set(handles.custmfigleft,'Enable','on')
        set(handles.custmfigright,'Enable','on')
        set(handles.halfaxespan,'visible','on')
        
        data = SHPB_extendedeval( data,step,handles.halfaxes1,handles.halfaxes2 );
        
        % store results
        handles.data = data;
        handles.evalstep = 18;   % proceed
        set(handles.step_disp,'String','Step: 18')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Strain acceleration')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Fracture work calculated.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        
        
        
    case 18
        % Extended Evaluation:
        % Axial strain acceleration
        cla(handles.halfaxes1)
        cla(handles.halfaxes1,'reset')
        cla(handles.halfaxes2)
        cla(handles.halfaxes2,'reset')
        
        data = SHPB_extendedeval( data,step,handles.halfaxes1,handles.halfaxes2 );
        
        % store results
        handles.data = data;
        handles.evalstep = 19;   % proceed
        set(handles.step_disp,'String','Step: 19')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Overview')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Axial strain acceleration calculated.','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        
    case 19
        % Extended Evaluation:
        % Complete Sample history
        cla(handles.halfaxes1)
        cla(handles.halfaxes1,'reset')
        cla(handles.halfaxes2)
        cla(handles.halfaxes2,'reset')
        
        data = SHPB_extendedeval( data,step,handles.halfaxes1,handles.halfaxes2 );
        
        % store results
        handles.data = data;
        handles.evalstep = 20;   % proceed
        set(handles.step_disp,'String','Step: 20')
        guidata(hObject,handles)
        set(handles.start_cont_btn,'String','Finish!')
        handles.guistate = 'done';
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Overview generated','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        

    case 20
        % Finish it off

        %    ######## #### ##    ## ####  ######  ##     ##
        %    ##        ##  ###   ##  ##  ##    ## ##     ##
        %    ##        ##  ####  ##  ##  ##       ##     ##
        %    ######    ##  ## ## ##  ##   ######  #########
        %    ##        ##  ##  ####  ##        ## ##     ##
        %    ##        ##  ##   ###  ##  ##    ## ##     ##
        %    ##       #### ##    ## ####  ######  ##     ##

        
        set(handles.customfigbtn,'Enable','on')
        set(handles.fullaxespan,'visible','on')
        set(handles.quarteraxespan,'visible','on')
        set(handles.custmfigleft,'Enable','off')
        set(handles.custmfigright,'Enable','off')
        set(handles.halfaxespan,'visible','off')
        % reset guistate
        handles.guistate = 'standby';
        handles.evalstep = 0;
        GUIpath = handles.systeminfo.GUIpath;
        data = handles.data;
        % save txt file
        if handles.prefs.txtsave == 1
            metadata.data = data;
            metadata.expm = handles.expm;
            metadata.profilename = handles.active.profile;
            metadata.projectname = handles.active.project;
            metadata.expmname = handles.expminfo.name;
            expmpath = handles.expminfo.folder;
            SHPB_txtcompiler(expmpath,metadata)
        else
        end
        if handles.prefs.csvsave == 1
            expmpath = handles.expminfo.folder;
            data = handles.data;
            SHPB_csvdump(expmpath,data)
        else
        end
        % clear axes
        cla(handles.fullaxes)
        cla(handles.fullaxes,'reset')
        cla(handles.quarteraxes1)
        cla(handles.quarteraxes1,'reset')
        cla(handles.quarteraxes2)
        cla(handles.quarteraxes2,'reset')
        cla(handles.quarteraxes3)
        cla(handles.quarteraxes3,'reset')
        cla(handles.quarteraxes4)
        cla(handles.quarteraxes4,'reset')
        % save data
        expm = handles.expm;
        expm.eval = 1;
        expmpath = handles.expminfo.folder;
        datapath = fullfile(expmpath,'data.mat');
        metapath = fullfile(expmpath,'experiment.mat');
        % embed profile
        profile = handles.profile;
        profile.profilename = handles.active.profile;
        save(datapath,'data','profile')
        save(metapath,'expm')
        % update project file
        l = load(fullfile(handles.projectinfo.path,[handles.projectinfo.name,'.mat']));
        expms = l.expms;
        expms{end,4} = 1;
        expms{end,5} = data.plateaurate;
        expms{end,6} = data.ucd;
        expms{end,7} = data.tanmod;
        save(fullfile(handles.projectinfo.path,[handles.projectinfo.name,'.mat']),'expms','-append')
        SHPB_updateMetaTable(fullfile(handles.projectinfo.path,[handles.projectinfo.name,'.mat']),...
            metapath,data,profile,handles.expminfo.name )
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Data saved to experiment folder','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
        % clear data from GUI
        handles.expm = [];
        handles.data = [];
        handles.profile = [];
        set(handles.start_cont_btn,'String','Start')
        % reset experiment
        active = handles.active;    % useless command?
        active.expm = 'none';
        handles.active = active;
        % update handles
        guidata(hObject,handles)
        % restore original preferences
        if handles.prefinfo.tempStatus == 1
            handles.prefinfo.tempStatus = 0;
            handles.prefs = [];
            p = load(fullfile(GUIpath,'resources','preferences.mat'));
            handles.prefs = p.prefs;
        else
            handles.prefs = [];
            p = load(fullfile(GUIpath,'resources','preferences.mat'));
            handles.prefs = p.prefs;
        end
        % set all strings in GUI to initial state
        set(handles.status_disp,'String','Status: standby')
        set(handles.status_disp,'ForegroundColor',[1 0.412 0.161])
        set(handles.step_disp,'String','Step: 0')
        set(handles.experiment_display,'String','Current Exp.: none')
        set(handles.time_info,'String','')
        set(handles.import_menu,'handlevisibility','off')
        set(handles.safailed_check,'Value',0)
        set(handles.sadia_disp,'String','')
        set(handles.salen_disp,'String','')
        set(handles.customfigbtn,'Enable','off')
        set(handles.qsavefigbtn,'Enable','off')
        % output message
        handles.MessageHistory = sprintf([handles.MessageHistory,'Evaluation completed','\n']);
        handles.MessageNo = handles.MessageNo + 1;
        set(handles.msg_wind,'String',handles.MessageHistory);
        set(handles.msg_wind,'ListboxTop',handles.MessageNo);
        set(handles.msg_wind,'Value',handles.MessageNo);
        set(handles.msg_wind,'Value',[]);
        guidata(hObject,handles)
    otherwise
end

% --------------------------------------------------------------------


%     ######     ###    ##    ##  ######  ##       ########
%    ##    ##   ## ##   ###   ## ##    ## ##       ##
%    ##        ##   ##  ####  ## ##       ##       ##
%    ##       ##     ## ## ## ## ##       ##       ######
%    ##       ######### ##  #### ##       ##       ##
%    ##    ## ##     ## ##   ### ##    ## ##       ##
%     ######  ##     ## ##    ##  ######  ######## ########


% >>> CANCEL EVALUATION <<<
function cancel_eval_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.guistate = 'standby';
handles.evalstep = 0;
GUIpath = handles.systeminfo.GUIpath;
% restore original preferences
if handles.prefinfo.tempStatus == 1
    handles.prefinfo.tempStatus = 0;
    handles.prefs = [];
    p = load(fullfile(GUIpath,'resources','preferences.mat'));
    handles.prefs = p.prefs;
else
    handles.prefs = [];
    p = load(fullfile(GUIpath,'resources','preferences.mat'));
    handles.prefs = p.prefs;
end
% clear axes
cla(handles.fullaxes)
cla(handles.fullaxes,'reset')
set(handles.fullaxespan,'visible','on')
cla(handles.quarteraxes1)
cla(handles.quarteraxes1,'reset')
cla(handles.quarteraxes2)
cla(handles.quarteraxes2,'reset')
cla(handles.quarteraxes3)
cla(handles.quarteraxes3,'reset')
cla(handles.quarteraxes4)
cla(handles.quarteraxes4,'reset')
% clear data from GUI
handles.expm = [];
handles.data = [];
handles.profile = [];
set(handles.start_cont_btn,'String','Start')
set(handles.ctrl_prompt,'String','')
% reset experiment
active = handles.active;    % useless command?
active.expm = 'none';
handles.active = active;
% disable import
set(handles.import_menu,'handlevisibility','off')
% update handles
guidata(hObject,handles)
% set all strings in GUI to initial state
set(handles.status_disp,'String','Status: standby')
set(handles.status_disp,'ForegroundColor',[1 0.412 0.161])
set(handles.step_disp,'String','Step: 0')
set(handles.experiment_display,'String','Current Exp.: none')
set(handles.time_info,'String','')
set(handles.msg_disp,'String','')
set(handles.safailed_check,'Value',0)
set(handles.sadia_disp,'String','')
set(handles.salen_disp,'String','')
set(handles.customfigbtn,'Enable','off')
set(handles.qsavefigbtn,'Enable','off')
% output message
handles.MessageHistory = sprintf([handles.MessageHistory,'Evaluation canceled','\n']);
handles.MessageNo = handles.MessageNo + 1;
set(handles.msg_wind,'String',handles.MessageHistory);
set(handles.msg_wind,'ListboxTop',handles.MessageNo);
set(handles.msg_wind,'Value',handles.MessageNo);
set(handles.msg_wind,'Value',[]);
guidata(hObject,handles)

% --------------------------------------------------------------------


% >>> TIMEWINDOWS <<<
function timewindow_btn_Callback(hObject, eventdata, handles)
% hObject    handle to timewindow_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('You shouldn''t be able to press this button.','Stop!')

% THIS IS OBSOLETE
% THIS IS OBSOLETE
% THIS IS OBSOLETE

% % set fullaxes as current axes
% axes(handles.fullaxes)
% hold(handles.fullaxes)
%
% % activate mouse input
% [x,y] = ginput(2);
% % selected borders
% lbord = x(1);   % lower border value
% ubord = x(2);   % upper border value
%
% t = handles.data.rawt;      % the time array we are searching
% rate = handles.profile.Hz;  % this is the sampling rate in MHz
%
% xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
%
% lbpos = xpos(1);    % lower border array position
% ubpos = xpos(2);    % upper border array position
%
% message = ['lb value: ',num2str(lbord),', lb pos: ',num2str(lbpos),...
%             ', ub value: ',num2str(ubord),', ub pos: ', num2str(ubpos)];
% set(handles.msg_disp,'String',message)
%
% raw1a = handles.data.raw1a;
% plot(handles.fullaxes,t(lbpos:ubpos),raw1a(lbpos:ubpos),'r.')

% --------------------------------------------------------------------


% >>> REFINE TIMEWINDOW <<<
function refine_btn_Callback(hObject, eventdata, handles)
% hObject    handle to refine_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.evalstep
    case 3
      % set fullaxes as current axes
      axes(handles.fullaxes)
      hold(handles.fullaxes)
      % tell user what to do:
      set(handles.ctrl_prompt,'String','Select the incident pulse!')

      handles.evalstep = 2;   % revert
      set(handles.step_disp,'String','Step: 2')
      guidata(hObject,handles)
      data = handles.data;
      rawt = data.rawt;
      DMSI = data.DMSI;
      DMST = data.DMST;
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      % plot
      plot(handles.fullaxes,rawt,DMSI,rawt,DMST)
      grid(handles.fullaxes,'on')
      legend(handles.fullaxes,'Incident bar signal (bending corrected)','Transmission bar signal (bending corrected)')
      xlabel(handles.fullaxes,'t [s]')
      ylabel(handles.fullaxes,'Voltage [V]')
      title(handles.fullaxes,'Bending corrected signal')
      try
          handles = SHPB_brushtimewindow(handles);
      catch
          handles = SHPB_ginputtimewindow(handles);
      end
      handles.evalstep = 3;   % proceed
      set(handles.step_disp,'String','Step: 3')
      guidata(hObject,handles)

    case 4
      % set fullaxes as current axes
      axes(handles.fullaxes)
      hold(handles.fullaxes)

      handles.evalstep = 3;   % revert
      set(handles.step_disp,'String','Step: 3')
      guidata(hObject,handles)
      % update instructions
      % tell user what to do:
      set(handles.ctrl_prompt,'String','Select the reflected pulse!')

      data = handles.data;
      t = data.rawt;
      DMSI = data.DMSI;
      DMST = data.DMST;
      InLow = data.InLow;
      InUp = data.InUp;
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      % plot results
      plot(handles.fullaxes,t,DMSI,t,DMST)
      hold(handles.fullaxes,'on')
      plot(handles.fullaxes,t(InLow:InUp),DMSI(InLow:InUp),'r.')
      xlabel(handles.fullaxes,'time [s]')
      ylabel(handles.fullaxes,'Voltage [V]')
      title(handles.fullaxes,'Pulse selection')
      grid(handles.fullaxes,'on')
      legend(handles.fullaxes,'Incident signal','Transmitted signal','Incident pulse')

      try
          handles = SHPB_brushtimewindow(handles);
      catch
          handles = SHPB_ginputtimewindow(handles);
      end

      handles.evalstep = 4;   % proceed
      set(handles.step_disp,'String','Step: 4')
      guidata(hObject,handles)
      % update instructions
      set(handles.ctrl_prompt,'String','Select the reflected Pulse!')
      guidata(hObject,handles)

    case 5
      set(handles.customfigbtn,'Enable','on')
      set(handles.fullaxespan,'visible','on')

      % set fullaxes as current axes
      axes(handles.fullaxes)
      hold(handles.fullaxes)

      handles.evalstep = 4;   % proceed
      set(handles.step_disp,'String','Step: 4')
      guidata(hObject,handles)
      % update instructions
      % tell user what to do:
      set(handles.ctrl_prompt,'String','Select the transmitted pulse!')

      data = handles.data;
      t = data.rawt;
      DMSI = data.DMSI;
      DMST = data.DMST;
      InLow = data.InLow;
      InUp = data.InUp;
      ReLow = data.ReLow;
      ReUp = data.ReUp;
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      % plot results
      plot(handles.fullaxes,t,DMSI,t,DMST)
      hold(handles.fullaxes,'on')
      plot(handles.fullaxes,t(InLow:InUp),DMSI(InLow:InUp),'r.')
      plot(handles.fullaxes,t(ReLow:ReUp),DMSI(ReLow:ReUp),'g.')
      xlabel(handles.fullaxes,'time [s]')
      ylabel(handles.fullaxes,'Voltage [V]')
      title(handles.fullaxes,'Pulse selection')
      grid(handles.fullaxes,'on')
      legend(handles.fullaxes,'Incident signal','Transmitted signal','Incident pulse','Reflected pulse')

      try
          handles = SHPB_brushtimewindow(handles);
      catch
          handles = SHPB_ginputtimewindow(handles);
      end

      handles.evalstep = 5;   % proceed
      set(handles.step_disp,'String','Step: 5')
      guidata(hObject,handles)
      % update instructions
      set(handles.ctrl_prompt,'String','')
      % prepare for next step
      set(handles.start_cont_btn,'String','Dispersion correction')
      guidata(hObject,handles)

      % autosave if activated
      if handles.prefs.autosave == 1
          set(handles.fullaxespan,'BackgroundColor','w')
          options.dpi = handles.prefs.dpivalue;
          options.aa = handles.prefs.aavalue;
          formatselect = [0 0 0 0 0]; % png jpg bmp eps pdf
          formatselect(handles.prefs.imgformat) = 1;
          options.fileformats = formatselect;
          imgpath = handles.expminfo.folder;
          SHPB_savefigure(handles.fullaxes,handles.evalstep-1,options,3,imgpath)
          set(handles.fullaxespan,'BackgroundColor',[0.5 0.5 0.5])
      else
      end

    case 13
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      data = handles.data;
      handles.evalstep = 11;
      set(handles.step_disp,'String','Step: 11')
      step = handles.evalstep;
      % calculation
      SHPB_rate( data,step,handles.fullaxes )
      guidata(hObject,handles)
      set(handles.start_cont_btn,'String','Timewindow')
      set(handles.ctrl_prompt,'String','Select the timewindow to calculate the mean strain rate!')
      % set fullaxes as current axes
      axes(handles.fullaxes)
      hold(handles.fullaxes)
      % update instructions
      set(handles.ctrl_prompt,'String','Chose a region for the mean strain rate!')
      % activate mouse input
      [x,y] = ginput(2);
      % selected borders
      lbord = x(1);   % lower border value
      ubord = x(2);   % upper border value
      t = handles.data.tCut;      % the time array we are searching
      rate = handles.profile.Hz;  % this is the sampling rate in MHz
      xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
      % get absolute values
      MrLow = xpos(1);    % lower border array position
      MrUp = xpos(2);    % upper border array position
      % store results
      data.MrLow = MrLow;
      data.MrUp = MrUp;
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      handles.evalstep = 12;
      set(handles.step_disp,'String','Step: 12')
      step = handles.evalstep;
      % determine mean strain rate and plot
      data = SHPB_rate( data,step,handles.fullaxes );
      % more results
      handles.data = data;
      handles.evalstep = 13;   % proceed
      set(handles.step_disp,'String','Step: 13')
      guidata(hObject,handles)
      set(handles.start_cont_btn,'String','Cumulative Strain')
      guidata(hObject,handles)
      % update instruction
      set(handles.ctrl_prompt,'String','')
    case 16
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      data = handles.data;
      handles.evalstep = 15;   % proceed
      step = handles.evalstep;
      set(handles.step_disp,'String','Step: 15')
      guidata(hObject,handles)
      % load general stuff
      strain3 = data.strain3;     % this will be the x-axis
      sigmaA = data.sigmaA;
      sigmaB = data.sigmaB;
      sigmaM = data.sigmaM;
      srate3 = data.srate3;
      t1 = data.MrLow;
      t2 = data.MrUp;
      % just plot everything
      % first, plot with regular scale for TIMEWINDOWS
      a=plot(handles.fullaxes,strain3,sigmaA/1e6,'k--');
      hold(handles.fullaxes,'on')
      b=plot(handles.fullaxes,strain3,sigmaB/1e6,'b--');
      c=plot(handles.fullaxes,strain3,sigmaM/1e6,'g','Linewidth',1);
      xlabel(handles.fullaxes,'\epsilon [-]')
      ylabel(handles.fullaxes,'\sigma [MPa]')
      title(handles.fullaxes,'Stress vs. Strain')
      grid(handles.fullaxes,'on')
      plot(handles.fullaxes,[strain3(t1),strain3(t1)],[0 sigmaM(t1)/1e6],'k:')
      plot(handles.fullaxes,[strain3(t2),strain3(t2)],[0 sigmaM(t2)/1e6],'k:')
      text(handles.fullaxes,strain3(t1),sigmaM(t1)/1e6,'t1')
      text(handles.fullaxes,strain3(t2),sigmaM(t2)/1e6,'t2')
      legend(handles.fullaxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
      % set fullaxes as current axes
      axes(handles.fullaxes)
      hold(handles.fullaxes)
      % update instructions
      set(handles.ctrl_prompt,'String','Select the linear elastic region for the tangent modulus!')
      % activate mouse input
      [x,y] = ginput(2);
      TmLow = x(1);    % lower border array position
      TmUp = x(2);    % upper border array position
      % store results
      data.TmLow = TmLow;
      data.TmUp = TmUp;
      % clear axes
      cla(handles.fullaxes)
      cla(handles.fullaxes,'reset')
      % calculate tangent-modulus, plot again
      data = SHPB_modulus( data,handles.expm,step,handles.fullaxes );
      % more results
      handles.data = data;
      handles.evalstep = 16;   % proceed
      set(handles.step_disp,'String','Step: 16')
      guidata(hObject,handles)
      set(handles.start_cont_btn,'String','UCD')
      guidata(hObject,handles)
      % update instructions
      set(handles.ctrl_prompt,'String','')
    otherwise
      return
end

% --------------------------------------------------------------------


% >>> CHANGE DISPERSION SETTINGS <<<
function dispersion_btn_Callback(hObject, eventdata, handles)
% hObject    handle to dispersion_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------


% --------------------------------------------------------------------
function menu_prjctmanager_Callback(hObject, eventdata, handles)
% hObject    handle to menu_prjctmanager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.guistate,'standby')
    pass.GUIpath = handles.systeminfo.GUIpath;
    waitfor(SHPB_manager(pass))
    % check if the current project has been deleted
    if ~strcmp(handles.active.project,'none')
        if ~isdir(handles.projectinfo.path)
            handles.active.project = 'none';
            set(handles.project_display,'String',['Current Project : ','none'])
        else
        end
    else
    end
else
  errordlg('Can''t open project manager while an experiment is active.','Error')
  return
end


% --------------------------------------------------------------------
function profmanager_menu_Callback(hObject, eventdata, handles)
% hObject    handle to profmanager_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIpath = handles.systeminfo.GUIpath;
if strcmp(handles.guistate,'standby')
    pass.GUIpath = GUIpath;
    pass.currentprofno = handles.profileinfo.no;
    waitfor(SHPB_profilemanager(pass))
    % check if the current profile has changed
    tppath = fullfile(GUIpath,'temp','changedProfile.mat');
    if isfile(tppath)
        c = load(tppath);
        selectedProf = c.newcurrent;
        po = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
        if ~isempty(po.profiles)
            currprof = po.profiles{selectedProf,2};
            active = handles.active;
            active.profile = currprof;
            handles.active = active;
            profileinfo.path = po.profiles{selectedProf,3};
            profileinfo.name = currprof;
            profileinfo.no = selectedProf;
            handles.profileinfo = profileinfo;
            guidata(hObject,handles)
            p = load(handles.profileinfo.path);
            profile = p.profile;
            pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
            l = load(pcdatapath);
            set(handles.profile_display,'String',['Profile used: ',currprof])
            set(handles.bar_name_disp,'String',profile.bName)
            set(handles.ymod_disp,'String',num2str(profile.Eb))
            set(handles.density_disp,'String',num2str(profile.roh0b))
            set(handles.poisson_disp,'String',num2str(l.nu(profile.pc)))
            set(handles.bdia_disp,'String',num2str(profile.Db*100))
            set(handles.stlen_disp,'String',num2str(profile.Lp*100))
            set(handles.incdis_disp,'String',num2str(profile.X1))
            set(handles.trandis_disp,'String',num2str(profile.X2))
            set(handles.voltage_disp,'String',num2str(profile.U0))
            set(handles.amp_disp,'String',num2str(profile.V))
            set(handles.kfactor_disp,'String',num2str(profile.k))
            set(handles.rate_disp,'String',num2str(profile.Hz))
        else
        end
        delete(tppath);
    else
    end
else
  errordlg('Can''t open profile manager while an experiment is active.','Error')
  return
end


% --- Executes on button press in bendINa.
function bendINa_Callback(hObject, eventdata, handles)
% hObject    handle to bendINa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bendINa


% --- Executes on button press in bendINb.
function bendINb_Callback(hObject, eventdata, handles)
% hObject    handle to bendINb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bendINb


% --- Executes on button press in bendTa.
function bendTa_Callback(hObject, eventdata, handles)
% hObject    handle to bendTa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bendTa


% --- Executes on button press in bendTb.
function bendTb_Callback(hObject, eventdata, handles)
% hObject    handle to bendTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bendTb


% --- Executes on button press in custmfigleft.
function custmfigleft_Callback(hObject, eventdata, handles)
% hObject    handle to custmfigleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.guistate,'evaluating')  || strcmp(handles.guistate,'done')
    pass.data = handles.data;
    pass.expm = handles.expm;
    switch handles.evalstep
        case 18
            pass.step = 171;
        case 19
            pass.step = 181;
        case 20
            pass.step = 191;
        otherwise
            error('Can''t customize figure.')
    end
    pass.path = handles.expminfo.folder;
    SHPB_viewfigure(pass)
else
    errordlg('Can''t customize nonexistent figure.','Error')
    return
end


% --- Executes on button press in custmfigright.
function custmfigright_Callback(hObject, eventdata, handles)
% hObject    handle to custmfigright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.guistate,'evaluating')  || strcmp(handles.guistate,'done')
    pass.data = handles.data;
    pass.expm = handles.expm;
    switch handles.evalstep
        case 18
            pass.step = 172;
        case 19
            pass.step = 182;
        case 20
            pass.step = 192;
        otherwise
            error('Can''t customize figure.')
    end
    pass.path = handles.expminfo.folder;
    SHPB_viewfigure(pass)
else
    errordlg('Can''t customize nonexistent figure.','Error')
    return
end
