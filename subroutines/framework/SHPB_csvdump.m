function SHPB_csvdump(expmpath,data)



% pulses
output = [data.tCut',data.strainInCut',data.strainReCut',data.strainTrCut'];
headers = {'Time [s]','Incident strain','Reflected strain','Transmitted strain'};
csvwrite_with_headers(fullfile(expmpath,'pulses.csv'),output,headers)

% stress vs time
output = [data.tCut',data.sigmaA',data.sigmaB',data.sigmaM'];
headers = {'Time [s]','Sigma A [Pa]','Sigma B [Pa]','Sigma M [Pa]'};
csvwrite_with_headers(fullfile(expmpath,'stress.csv'),output,headers)

% strain vs time
output = [data.tCut',data.strain',data.strain3'];
headers = {'Time [s]','Reflected strain','3-wave strain'};
csvwrite_with_headers(fullfile(expmpath,'strain.csv'),output,headers)

% strainrate vs time
output = [data.tCut',data.srate',data.srate3'];
headers = {'Time [s]','Reflected strainrate [s^-1]','3-wave strainrate [s^-1]'};
csvwrite_with_headers(fullfile(expmpath,'strainrate.csv'),output,headers)

% stress vs strain
output = [data.strain3',data.sigmaA',data.sigmaB',data.sigmaM'];
headers = {'3-wave strain','Sigma A [Pa]','Sigma B [Pa]','Sigma M [Pa]'};
csvwrite_with_headers(fullfile(expmpath,'stressVSstrain.csv'),output,headers)
