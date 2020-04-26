function SHPB_txtcompiler(expmpath,metadata)
%SHPB_txtcompiler generates a txt file summarizing the most important
%parameters and results of an evaluated experiment
%expmpath: expm directory in which the txt will be saved
%metadata: struct containing fields:
%metadata.expm
%metadata.data
%metadata.profilename
%metadata.projectname
%metadata.expmname

expm = metadata.expm;
data = metadata.data;
profilename = metadata.profilename;
projectname = metadata.projectname;
expmname = metadata.expmname;

if expm.fail == 1
    fail = 'yes';
    strength = 'UCD: ';
else
    fail = 'no';
    strength = 'Maximum stress: ';
end

ln1 = ['Report for experiment "',expmname,'"'];
lnsep = ['____________________________________________'];
ln3 = ['Part of project: "',projectname,'"'];
ln4 = ['Profile used: "',profilename,'"'];
% lineseperator
ln6 = 'Sample:';
ln7 = ['Lithology: ',convertStringsToChars(expm.lith)];
ln8 = ['Length: ',num2str(expm.Ls*1000),' mm'];
ln9 = ['Diameter: ',num2str(expm.Ds*1000),' mm'];
ln10 = ['Failed: ',fail];
% lineseperator
ln12 = 'Experiment:';
ln13 = ['Vessel pressure: ',num2str(expm.cp),' bar'];
ln14 = ['Striker speed: ',num2str(expm.v0),' m/s'];
ln15 = ['Performed on: ',expm.date];
% lineseperator
ln17 = 'Results:';
ln18 = ['Mean strain rate: ',num2str(data.plateaurate),' s^-1 +- ',num2str(data.stdplateaurate),' s^-1'];
ln19 = [strength,num2str(data.ucd),' MPa'];
ln20 = ['Tangent modulus: ',num2str(data.tanmod/1e9),' GPa +- ',num2str(data.deltatm/1e9),' GPa'];
% lineseperator
ln22 = ['Experiment evaluated on: ',date];
ln23 = 'Using SHPBcalc';
ln24 = 'thegermangeologist.rocks/software/shpbcalc';

txtoutput = [ln1,'\n',lnsep,'\n',ln3,'\n',ln4,'\n',lnsep,'\n',...
ln6,'\n',ln7,'\n',ln8,'\n',ln9,'\n',ln10,'\n',lnsep,'\n',...
ln12,'\n',ln13,'\n',ln14,'\n',ln15,'\n',lnsep,'\n',ln17,'\n',...
ln18,'\n',ln19,'\n',ln20,'\n',lnsep,'\n',ln22,'\n',ln23,'\n',ln24];

fID = fopen(fullfile(expmpath,['report_for_',expmname,'.txt']),'wt');
fprintf(fID,txtoutput);
fclose(fID);
