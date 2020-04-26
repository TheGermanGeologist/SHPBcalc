function [status] = SHPB_raw( data,faxes )

try
    % extract struct
    raw1a = data.raw1a;
    raw1b = data.raw1b;
    raw2a = data.raw2a;
    raw2b = data.raw2b;
    rawt = data.rawt;
    % plot the stuff
    plot(faxes,rawt,raw1a,rawt,raw1b,rawt,raw2a,rawt,raw2b)
    xlabel(faxes,'t [s]')
    ylabel(faxes,'Voltage [V]')
    title(faxes,'Complete raw data')
    legend(faxes,'Incident A','Incident B','Transmission A','Transmission B')
    grid(faxes,'on')
    status = 1;
catch
    status = 0;
end
end
