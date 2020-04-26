function SHPB_cumstrain( faxes,data )
%SHPB_CUMSTRAIN  plots the cumulative strain during an experiment

% calculated in SHPB_stst as strain

% get data
t = data.tCut;
strain = data.strain;
strain3 = data.strain3;

plot(faxes,t,strain,'b','LineWidth',1.5)
hold(faxes,'on')
plot(faxes,t,strain3,'k','LineWidth',1.5)
title(faxes,'Cumulative sample strain')
ylabel(faxes,'\epsilon [-]')
xlabel(faxes,'Time [s]')
grid(faxes,'on')
legend(faxes,'reflected wave only','3-wave strain')
