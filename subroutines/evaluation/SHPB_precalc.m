function [ dataOut ] = SHPB_precalc( dataIn,expm,profile )
%SHPB_PRECALC Performs some precalculations for the evaluation
%   Detailed explanation goes here

% get variables
dataOutPre = dataIn;
% from profile
U0 = profile.U0;        % Peak-to-Peak voltage at strain gauges [V]
k = profile.k;          % k-factor of strain gauges [-]
V = profile.V;          % Amplification [-]
Lp = profile.Lp;        % Length of striker [m]
Db = profile.Db;        % Diameter of bar [m]
Eb = profile.Eb;        % Young's modulus of bar [GPa]
roh0b = profile.roh0b;  % Density of bar [kg/m^3]
X1 = profile.X1;        % Distance incident strain / sample [m]
%X2 = profile.X2;        % Distance transmission strain / sample [m]
% from data
rawt = dataIn.rawt;        % time [s]
DMSI = dataIn.DMSI;     % Incident signal [V]
DMST = dataIn.DMST;     % Transmission signal [V]
% from experiment
Ds = expm.Ds;           % Diameter of the sample [m]
%Ls = expm.Ls;           % Length of the sample [m]


% Calculate strains s... from measured voltages for every pair of strain
% gauges
s1 = DMSI * 4 / (U0 * k * V); %incident bar strain signal [-]
s2 = DMST * 4 / (U0 * k * V); %transmission bar strain signal [-]
t = rawt - min(rawt);         %initial time axis shift to begin at 0

% negative distance of DMS1A and DMS1B from sample (for reflected wave)
X1R = -X1;

% bar properties
Eb = Eb * 10^9;       % convert GPa to Pa
Ab = pi * (Db / 2)^2; % cross sectional area of the bars [m^2]
C0 = sqrt(Eb / roh0b); % speed of sound [m/s]
Tp = 2 * Lp / C0; % Pulse duration [s]

% sample properties
As = pi * (Ds / 2)^2; %cross sectional area of the sample [m^2]

% save new values to dataOut
dataOutPre.s1 = s1;
dataOutPre.s2 = s2;
dataOutPre.t = t;
dataOutPre.X1R = X1R;
dataOutPre.Ab = Ab;
dataOutPre.C0 = C0;
dataOutPre.Tp = Tp;
dataOutPre.As = As;
dataOutPre.Eb = Eb;

dataOut = dataOutPre;

end
