function varargout = SHPB_defaultpreferences(RESpath)
%SHPB_defaultpreferences generates a preferences.mat file in the resources
%directory


prefs.N = 30;
prefs.iter = 10;
prefs.autosave = 0;
prefs.csvsave = 0;
prefs.txtsave = 0;
prefs.imgformat = 1;
prefs.dpivalue = 2;
prefs.aavalue = 2;
prefs.defaultprofile = 0;
prefs.defaultproject = 0;
prefs.copyraw = 0;

if 2 == exist(fullfile(RESpath,'preferences.mat'))
    % file already exists, this must be a call from the preferences
    % sub gui, restoring default settings
    % just spit out prefs as varargout
    varargout{1} = prefs;
else
    % file doesn't exist, this must be a call from a first time GUI
    % start, generate file with default content
    save(fullfile(RESpath,'preferences.mat'),'prefs')
end
