function SHPB_savefigure(sourceaxes, step, options, mode, imgpath)
%SHPB_savefigure Is a wrapper for the thirdparty figure saving tool export_fig
% sourceaxes: the axes to be saved (handle)
% step: the evaluation step (integer)
% options: figure export options, saved in a struct
% mode: 1: quicksave 2: custom 3: autosave (integer [1,2,3])
% path: the path to the experiment folder, where the figure will be saved (string)

% build image path and name
plotname = {'00_rawdata','01_bendingcorr','02_incidentsign',...
              '03_reflectedsign','04_transmittedsign',...
              '','','','08_timeshift','09_cutsignals',...
              '10_stressVStime','11_strainrate','12_meanrate',...
              '13_cumulstrain','14_stressVSstrain','15_tanmod',...
              '16_ucd','17-1_fractureWork','17-2_energyTransmission',...
              '18-1_strainAcc','18-2_inertia','19-1_stressRateOverview',...
              '19-2_stressStrainOverview'};
modename = {'QS','CT','AS'};

if step == 5 || step == 6 || step == 7
    errordlg('Can''t save figure during this evaluation step.','Invalid Call.')
    return
else
end

switch step
    
    case 171
        step = 17;
    case 172
        step = 18;
    case 181
        step = 19;
    case 182
        step = 20;
    case 191
        step = 21;
    case 192
        step = 22;
    otherwise     
end

step = step + 1;

%imgpath
fullimgpath = fullfile(imgpath,[plotname{step},modename{mode}]);

% get dpi and AA Options
dpivalues = [72 150 300];
dpi = dpivalues(options.dpi);
dpistr = ['-r',num2str(dpi)];

aavalues = [0 1 2 3 4];
aa = aavalues(options.aa);
aastr = ['-a',num2str(aa)];

% get desired file formats
formatstr = {'-png','-jpg','-bmp','-eps','-pdf'};
fileformats = options.fileformats;
saveformats = formatstr(logical(fileformats));
N = sum(fileformats);

for i = 1:N
    export_fig(sourceaxes,fullimgpath,saveformats{i},dpistr,aastr)
end
