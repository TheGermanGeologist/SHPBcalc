function handles = SHPB_ginputtimewindow(handles)

data = handles.data;
switch handles.evalstep
    case 2
        % activate mouse input
        [x,y] = ginput(2);
        % selected borders
        lbord = x(1);   % lower border value
        ubord = x(2);   % upper border value
        t = handles.data.rawt;      % the time array we are searching
        DMSI = handles.data.DMSI;
        DMST = handles.data.DMST;
        rate = handles.profile.Hz;  % this is the sampling rate in MHz
        xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
        % get absolute values
        InLow = xpos(1);    % lower border array position
        InUp = xpos(2);    % upper border array position
        % store results
        data.InLow = InLow;
        data.InUp = InUp;
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
        % display message with values
        string = ['Absolute: lower border: ',num2str(lbord),', upper border: ',...
                  num2str(ubord),';\nRelative: lower border: ',num2str(InLow),...
                  ', upper border: ',num2str(InUp)];
        message = sprintf(string);
        set(handles.time_info,'String',message)
        handles.data = data;
    case 3
        % activate mouse input
        [x,y] = ginput(2);
        % selected borders
        lbord = x(1);   % lower border value
        ubord = x(2);   % upper border value
        t = handles.data.rawt;      % the time array we are searching
        DMSI = handles.data.DMSI;
        DMST = handles.data.DMST;
        rate = handles.profile.Hz;  % this is the sampling rate in MHz
        xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
        % get absolute values
        ReLow = xpos(1);    % lower border array position
        ReUp = xpos(2);    % upper border array position
        % store results
        InLow = data.InLow;
        InUp = data.InUp;
        data.ReLow = ReLow;
        data.ReUp = ReUp;
        handles.data = data;
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
        % display message with values
        string = ['Absolute: lower border: ',num2str(lbord),', upper border: ',...
                  num2str(ubord),';\nRelative: lower border: ',num2str(ReLow),...
                  ', upper border: ',num2str(ReUp)];
        message = sprintf(string);
        set(handles.time_info,'String',message)
        handles.data = data;
    case 4
        % activate mouse input
        [x,y] = ginput(2);
        % selected borders
        lbord = x(1);   % lower border value
        ubord = x(2);   % upper border value
        t = handles.data.rawt;      % the time array we are searching
        DMSI = handles.data.DMSI;
        DMST = handles.data.DMST;
        rate = handles.profile.Hz;  % this is the sampling rate in MHz
        xpos = SHPB_timewindow(x,t,rate);   % pass to timewindow fx to search value
        % get absolute values
        TrLow = xpos(1);    % lower border array position
        TrUp = xpos(2);    % upper border array position
        % store results
        InLow = data.InLow;
        InUp = data.InUp;
        ReLow = data.ReLow;
        ReUp = data.ReUp;
        data.TrLow = TrLow;
        data.TrUp = TrUp;
        handles.data = data;

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
        % display message with values
        string = ['Absolute: lower border: ',num2str(lbord),', upper border: ',...
                  num2str(ubord),';\nRelative: lower border: ',num2str(TrLow),...
                  ', upper border: ',num2str(TrUp)];
        message = sprintf(string);
        set(handles.time_info,'String',message)
        handles.data = data;
    otherwise
end
