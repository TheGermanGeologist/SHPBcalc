function [ dataOut ] = SHPB_stst( data,prof,expm,faxes )
%SHPB_STST Calculate STress and STrain
%   Detailed explanation goes here

dataOutPre = data;

% load data
t = data.tCut;              % unified time array
sI = data.strainInCut;      % Incident strain (corrected,shifted,cut)
sR = data.strainReCut;      % Reflected strain (corrected,shifted,cut)
sT = data.strainTrCut;      % Transmitted strain (corrected,shifted,cut)

% load constants
Ab = data.Ab;               % bar surface area [m^2]
As = data.As;               % sample surface area [m^2]
Eb = data.Eb;               % bar Youngs modulus [Pa]
C0 = data.C0;               % speed of sound [m/s]
dt = 1 / (prof.Hz * 1e6);   % data spacing [s]
Ls = expm.Ls;               % length of sample [m]

% Sample stress
sigmaA = Eb * Ab / As * (sI + sR);          % sample stress at incident bar facet
sigmaB = Eb * Ab / As * sT;                 % sample stress at transmission bar facet
sigmaM = Eb * Ab / As * (sI + sR + sT) / 2; % 3-waves evaluated stress (mean value)

% Sample strain
strainInc = [0,(sR(1:end-1)+sR(2:end))/2];          % mean of neighboring strain values
strain = -(2 * C0 / Ls) * cumsum(strainInc * dt);   % integral under strain curve = total strain

% 3-waves evaluation of strain
merge = (sT - sI + sR) / 2;
strain3Inc = [0,(merge(1:end-1) + merge(2:end)) / 2];   % mean of neighboring values
strain3 = -(2 * C0 / Ls) * cumsum(strain3Inc * dt);     % integral / total strain for 3w

% Sample strain rate
srate = -2 * C0 / Ls * sR;              % 1- wave evaluated strain rate
srate3 = -C0 / Ls * (sR + sT - sI);      % 3-waves evaluated strain rate

% store results
dataOutPre.sigmaA = sigmaA;
dataOutPre.sigmaB = sigmaB;
dataOutPre.sigmaM = sigmaM;
dataOutPre.strain = strain;
dataOutPre.strain3 = strain3;
dataOutPre.srate = srate;
dataOutPre.srate3 = srate3;

dataOut = dataOutPre;


% PLOT stuff
plot(faxes,t/1e-3,sigmaA/1e6,'b',t/1e-3,sigmaB/1e6,'k',t/1e-3,sigmaM/1e6,'g','LineWidth',1.5)
xlabel(faxes,'time [ms]')
ylabel(faxes,'stress [MPa]')
legend(faxes,'\sigma_a','\sigma_b','3-waves evaluation','Location','south','Orientation','vertical')
grid(faxes,'on')
title(faxes,'Stress history')

end
