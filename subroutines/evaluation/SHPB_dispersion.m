function [ fourierInfo, dataOut ] = SHPB_dispersion( data,pref,prof,step,GUIpath,qaxes1,qaxes2,qaxes3,qaxes4 )
%SHPB_DISPERSION Performs the dispersion correction on input data
%   Detailed explanation goes here

dataOutPre = data;

% determine step and load appropriate stuff
switch step
    case 5
        % Incident
        lwb = data.InLow;  % upper border, first entry corresponds to incident
        upb = data.InUp;  % lower border, as above
        s = data.s1;        % incident bar strain signal
        X = prof.X1;        % distance incident strain gauges / sample
    case 6
        % Reflected
        lwb = data.ReLow;
        upb = data.ReUp;
        s = data.s1;        % incident bar strain signal
        X = data.X1R;       % distance incident strain gauges / sample (neg)
    case 7
        % Transmitted
        lwb = data.TrLow;
        upb = data.TrUp;
        s = data.s2;        % transmission bar strain signal
        X = prof.X2;        % distance transmission strain gauges / sample
    otherwise
        errordlg('Can''t call this functions at this evaluation step.')
        return
end

% load general stuff
dt = 1 / (prof.Hz * 1e6);   % spacing
t = data.t;                 % time array
N = pref.N;                 % number of fourier iterations
it = pref.iter;             % number of P.-C. iterations
C0 = data.C0;               % speed of sound in bar
Tp = data.Tp;               % pulse duration
Db = prof.Db;               % bar diameter


% precalc
sX = s(lwb:upb);            % selected portion of strain array
tX = t(lwb:upb) - t(lwb);   % selected portion of time array
span = upb - lwb;           % total distance in data
T = tX(span) - tX(1);       % total timespan
omega = 2 * pi / T;         % circular frequency of analyzed section

% put this step in the beginning to catch high N early and reduces it right
% away
% Computation of wavelengths lamda(n) and respective wave speed C(n)
% this is where the algorithm can break, too high fourier number N for
% short pulses causes NaN values at high N
check = 0;
fourierWarn = 0;
while check ~= 1
    lambdai = zeros(1,N);
    for n = 1:N
        lambdai(n) = 2 * Tp * C0 / n / 2; % Initial guess of wave lengths
        if any(isnan(lambdai))
            check = 0;
            N = N - 1;
            fourierWarn = 1;
            if N < 10
               error('Fourier number has to be reduced below the minimum of 10 for the dispersion correction to work.')
            else
            end
        else
            check = 1;
        end
    end
end

if fourierWarn == 1
   warning(['The fourier number N had to be reduced to ',num2str(N),...
       ' for the dispersion correction to work. ',...
       'The reduction is applied to all subsequent corrections in this experiment.'])
else
end

% PLOT qaxes1
plot(qaxes1,tX + t(lwb),sX,'.b',t,s,'k')
hold(qaxes1,'on')
grid(qaxes1,'on')
xlabel(qaxes1,'time [s]')
ylabel(qaxes1,'strain [-]')
if step == 7
    legend (qaxes1,'Selected pulse section','measured signal on bar','Location','northwest')
else
    legend (qaxes1,'Selected pulse section','measured signal on bar')
end
title(qaxes1,'To be analyzed section of bar signal')

% Fourier coefficients
slice = zeros(1,span - 1);
A0 = 0;
for i = 1:(span - 1)
    % incremental area of curve
    slice(i) = (sX(i) + sX(i+1)) / 2 * (tX(i+1) - tX(i));
end
A0 = sum(slice) * 2 / T;

a = zeros(1,span - 1);
an = zeros(1,N);
for n = 1:N
    for j = 1:(span-1)
        a(j) = slice(j) * cos(n * omega * (tX(j) + tX(j+1)) / 2);
    end
    an(n) = 2 / T * sum(a);
end

b = zeros(1,span - 1);
bn = zeros(1,N);
for n = 1:N
    for j = 1:(span-1)
        b(j) = slice(j) * sin(n * omega * (tX(j) + tX(j+1)) / 2);
    end
    bn(n) = 2 / T * sum(b);
end

Dn = sqrt(an.^2 + bn.^2);   % strain caused by n-th wave portion;

% PLOT qaxes2
bar(qaxes2,Dn)
xlabel(qaxes2,'Fourier number n')
ylabel(qaxes2,'strain [-]')
title(qaxes2,'Fourier number vs. intensity of wave')

vn = zeros(1,N);
for n = 1:N
    % Phase angles
    if an(n) < 0
        vn(n) = atan(bn(n) / an(n)) + pi;
    else
        vn(n) = atan(bn(n) / an(n));
    end
end

% Fit to Pochhammer Chree curve
% Load appropriate P.-C. curve:
pcdatapath = fullfile(GUIpath,'resources','pc_data.mat');
pcdata = load(pcdatapath);
pcN = pcdata.N; % number of curves in file
curveno = prof.pc;
if curveno > pcN
    error('The profile is referencing to a nonexistent Pochhammer Chree curve.')
else
end
CnC0int = pcdata.PCdata(:,curveno);
Dlambdaint = pcdata.Dlambdaint;

% PLOT qaxes3
PC = plot(qaxes3,Dlambdaint,CnC0int,'g','Linewidth',2);
hold(qaxes3,'on')

% Actual fitting begins here
Ci = zeros(1,N);
x = zeros(1,N);
lambdaj = zeros(1,N);
for i = 1:it
    for n = 1:N
        Ci(n) = n * omega / (2 * pi) * lambdai(n);
        x(n) = Db / lambdai(n); %x-coordinates for interpolation on Pochhammer-Chree curve
    end
    CnC0intnew = interp1(Dlambdaint,CnC0int,x); % Interpolation on P.-C. curve
    Cj = CnC0intnew * C0;
    for n = 1:N
        lambdaj(n) = Cj(n) * 2 * pi / (n * omega);
    end
    CnC0 = Cj / C0; % y-axis values
    Dla = Db ./ lambdaj; % x-axis values
    hold on
    % PLOT qaxes3
    n = plot(qaxes3,Dla,CnC0,'-'); % Incremental result of approximation procedure
    lambdai = lambdaj; % Use result for next iteration
end

% PLOT qaxes3
hold(qaxes3,'on')
f = plot(qaxes3,Dla,CnC0,'r.');
xlabel(qaxes3,'D/\lambda_n')
ylabel(qaxes3,'C_n/C_0')
legend(qaxes3,[PC n f],'Pochhammer-Chree curve','n-th iteration fit curve','final result')

%Phase angle change vdn and new phase angle vnew
Cn = Cj;
vdn = zeros(1,N);
vnew = zeros(1,N);
for n = 1:N
    vdn(n) = (n * omega * X / C0) * (C0 / Cn(n) - 1);
    vnew(n) = vn(n) + vdn(n);
end

%Build up of dispersion corrected wave
tc = 0:dt:T;
scv = zeros(1,N);
sc = zeros(1,(length(tc)));
for i = 1:length(tc)
    for n = 1:N
        scv(n) = Dn(n) * cos(n * omega * tc(i) - vnew(n));
    end
    sc(i)= A0 / 2 + sum(scv);
end

sXc = sc; %dispersion corrected values for strain
tXc = tc + t(lwb); %dispersion corrected values for time +minimalvalue of original wave+time shift by distance

% PLOT qaxes4
plot(qaxes4,t,s,'g',tXc,sXc,'b')
hold(qaxes4,'on')
xlabel(qaxes4,'time [s]')
ylabel(qaxes4,'strain [-]')
if step == 7
    legend(qaxes4,'Measured signal','Dispersion corrected pulse','Location','northwest')
else
    legend(qaxes4,'Measured signal','Dispersion corrected pulse')
end
title(qaxes4,'Dispersion corrected wave')
grid(qaxes4,'on')

% save appropriate stuff
switch step
    case 5
        % Incident
        dataOutPre.strainInCorr = sXc;
        dataOutPre.tInCorr = tXc;
    case 6
        % Reflected
        dataOutPre.strainReCorr = sXc;
        dataOutPre.tReCorr = tXc;
    case 7
        % Transmitted
        dataOutPre.strainTrCorr = sXc;
        dataOutPre.tTrCorr = tXc;
    otherwise
end
dataOut = dataOutPre;
fourierInfoPre.N = N;
fourierInfoPre.status = fourierWarn;
fourierInfo = fourierInfoPre;

end
