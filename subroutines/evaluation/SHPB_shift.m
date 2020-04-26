function [ dataOut ] = SHPB_shift( data,prof,faxes )
%SHPB_SHIFT shifts all time arrays to match
%   Time correction of all pulses - shifts the pulse histories
%   along the time axis to the respective sample interface

dataOutPre = data;

% load stuff
C0 = data.C0;               % speed of sound in bar
X1 = prof.X1;               % distance incident strain gauges / sample
X1R = data.X1R;             % distance incident strain gauges / sample (neg)
X2 = prof.X2;               % distance transmission strain gauges / sample

tIc = data.tInCorr;         % corrected Incident time array
tRc = data.tReCorr;         % corrected Reflected time array
tTc = data.tTrCorr;         % corrected Transmitted time array

sIc = data.strainInCorr;    % corrected Incident strain array
sRc = data.strainReCorr;    % corrected Reflected strain array
sTc = data.strainTrCorr;    % corrected Transmitted strain array

% shift
tIc = tIc + X1 / C0;
tRc = tRc + X1R / C0;
tTc = tTc - X2 / C0;

% round time to original sampling frequency
% this step is nessecary because C0 has far more decimals than original
% measurement precision. This can cause weird edge cases in the cut-step,
% where one array deviates in size by one element due to absolute
% clipping
freq = prof.Hz*1e6;
% theoretically, applying a blanket rounding shouldn't cause problems since
% the time values behave orderly up to the sampling frequency precision
% and a fixed amount is added behind that. However the amount might differ
% from the three signals because the strain gauge distances can vary. This
% could lead to shifts in opposite directions when rounding, causing a
% mismatch. Therefore, to be safe, the fixed amount is determined
% individually first and then substracted. To remove floatingpoint
% precission artifacts, the values are then rounded.
% Nevermind all this mumbojumbo, this should do it:
tIc = fix(tIc * freq)/freq;
tRc = fix(tRc * freq)/freq;
tTc = fix(tTc * freq)/freq;


% plot
plot(faxes,tIc,sIc,'k',tRc,sRc,'b',tTc,sTc,'r')
xlabel(faxes,'time [s]')
ylabel(faxes,'strain [-]')
legend(faxes,'Incident wave','Reflected wave','Transmitted wave')
title(faxes,'dispersion- and time corrected pulses at respective sample interface')
grid(faxes,'on')

% store
dataOutPre.tInCorr = tIc;
dataOutPre.tReCorr = tRc;
dataOutPre.tTrCorr = tTc;
dataOut = dataOutPre;

end
