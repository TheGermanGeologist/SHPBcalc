function [ dataOut ] = SHPB_bending( data,faxes,signals )
%SHPB_BENDING calculate average values of strain gauges separated at 180�
%   Detailed explanation goes here

dataOutPre = data;
% load stuff
raw1a = data.raw1a;
raw1b = data.raw1b;
raw2a = data.raw2a;
raw2b = data.raw2b;
rawt = data.rawt;

if signals(1) == 2
    raw1a = raw1b;
end
if signals(2) == 1
    raw1b = raw1a;
end
if signals(3) == 4
    raw2a = raw2b;
end
if signals(4) == 3
    raw2b = raw2a;
end

% check if time array starts with negative values and zero it
if rawt(1) < 0
    rawt = rawt - rawt(1);
else
end

% average out
DMSI = (raw1a + raw1b) / 2; % average of DMS1A and DMS1B = incident bar signal
DMST = (raw2a + raw2b) / 2; % average of DMS2A and DMS2B = transmission bar signal

% plot
plot(faxes,rawt,DMSI,rawt,DMST)
grid(faxes,'on')
legend(faxes,'Incident bar signal (bending corrected)','Transmission bar signal (bending corrected)')
xlabel(faxes,'t [s]')
ylabel(faxes,'Voltage [V]')
title(faxes,'Bending corrected signal')

% store
dataOutPre.DMSI = DMSI;
dataOutPre.DMST = DMST;
dataOutPre.rawt = rawt;
dataOut = dataOutPre;

end
