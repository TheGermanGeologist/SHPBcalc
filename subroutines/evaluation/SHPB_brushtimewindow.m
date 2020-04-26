function handles = SHPB_brushtimewindow(handles)

data = handles.data;
%l = findobj(handles.fullaaxes,'type','line');
axlines = flipud(handles.fullaxes.Children);
% lines are in order: IncidentSignal, TransmittedSignal, IncidentMarker,
% ReflectedMarker, TransmittedMarker
names ={'IncidentSignal', 'TransmittedSignal','IncidentMarker',...
        'ReflectedMarker','TransmittedMarker'};

bO = brush;
bO.ActionPostCallback = {@PostBrushCallback,names};
bO.Color = [0 0.2 1];

if handles.evalstep == 2
  % incident
  lineno = 1;
elseif handles.evalstep == 3
  % reflected
  lineno = 1;
elseif handles.evalstep == 4
  % transmitted
  lineno = 2;
else
    errordlg('Can''t call this function at this evaluation step','Error')
    return
end

evalin('base',['clearvars(''IncidentSignal'',''TransmittedSignal'')'])
set(bO,'Enable','on');
%disp('Starting to wait')
waitfor(axlines(lineno),'BrushData')
while evalin('base',['~exist(''',names{lineno},''',''var'')'])
    pause(0.1)
    %disp(['searching for ',names{lineno}])
end
set(bO,'Enable','off')
% gather brushdata results
if handles.evalstep == 2
    % incident
    IncidentSignal = evalin('base','IncidentSignal');
    InLow = min(find(IncidentSignal));
    InUp = max(find(IncidentSignal));
    data.InLow = InLow;
    data.InUp = InUp;
    handles.data = data;
elseif handles.evalstep == 3
    % reflected
    IncidentSignal = evalin('base','IncidentSignal');
    ReLow = min(find(IncidentSignal));
    ReUp = max(find(IncidentSignal));
    data.ReLow = ReLow;
    data.ReUp = ReUp;
    handles.data = data;
elseif handles.evalstep == 4
    % transmitted
    TransmittedSignal = evalin('base','TransmittedSignal');
    TrLow = min(find(TransmittedSignal));
    TrUp = max(find(TransmittedSignal));
    data.TrLow = TrLow;
    data.TrUp = TrUp;
    handles.data = data;
else
end

t = handles.data.rawt;
DMSI = handles.data.DMSI;
DMST = handles.data.DMST;

% update the plot
if handles.evalstep == 2
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
elseif handles.evalstep == 3
    InLow = data.InLow;
    InUp = data.InUp;
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
elseif handles.evalstep == 4
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
    plot(handles.fullaxes,t(TrLow:TrUp),DMST(TrLow:TrUp),'y.')
    xlabel(handles.fullaxes,'time [s]')
    ylabel(handles.fullaxes,'Voltage [V]')
    title(handles.fullaxes,'Pulse selection')
    grid(handles.fullaxes,'on')
    legend(handles.fullaxes,'Incident signal','Transmitted signal','Incident pulse','Reflected pulse','Transmitted pulse')
else
end

end
