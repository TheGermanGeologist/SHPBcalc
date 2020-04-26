function varargout = SHPB_checkprofiles(GUIpath)
%SHPB_checkprofiles checks if the user has deleted profiles outside of a SHPBcalc
%session and updates the profindex.mat file and defaultprofile accordingly

% CHECK FOR MISSING PROFILES
l = load(fullfile(GUIpath,'resources','profiles','profindex.mat'));
Nexpected = l.N;
N = Nexpected;

deletedList = {};
deletedTrue = 0;

% first check if we even have profiles in the index
if N ~= 0
    ProfilesInfo = l.profiles;
    deleteProfiles = [];
    for ii = 1:Nexpected
        if 0 == exist(fullfile(ProfilesInfo{ii,3}),'file')
            % this project is missing
            % mark for deletion
            deleteProfiles(end+1) = ii;
        else
        end
    end
    % delete from profindex.mat
    if numel(deleteProfiles) > 0
        % there were missing profiles
        deletedTrue = 1;
        % get default profile so we can update this accordingly
        d = load(fullfile(GUIpath,'resources','preferences.mat'));
        defaultprofile = d.prefs.defaultprofile;
        defaultoffset = 0;
        % iterate through all missing profiles
        for ii = 1:numel(deleteProfiles)
            deletedList{ii} = ProfilesInfo{ii,2};
            missing = deleteProfiles(ii);
            if missing == defaultprofile
                % the default profile has been removed, set default to none
                defaultoffset = -defaultprofile;
            elseif missing < defaultprofile
                % a profile above the default has been removed,
                % so the default has to move up as well
                % this looks like it could potentially break the program, but since all
                % of this happens in the order of projects as in the index, defauloffset
                % should not be able to become bigger than defaultprofile.
                defaultoffset = defaultoffset - 1;
            else
                % the defaultprofile is above the removed profile so it is unaffected
            end
            N = N - 1;
            ProfilesInfo{missing,1} = [];
            ProfilesInfo{missing,2} = [];
            ProfilesInfo{missing,3} = [];
        end
        % update default preferences
        if defaultoffset ~= 0
            prefs = d.prefs;
            prefs.defaultprofile = defaultprofile + defaultoffset;
            save(fullfile(GUIpath,'resources','preferences.mat'),'prefs')
        else
        end
        % now the first field N for all remaining profiles should be updated
        % it doesn't really matter, but better do it to avoid confusion
        for jj = 1:N
            ProfilesInfo{jj,1} = jj;
        end
        % Update projects_index.mat
        profiles = ProfilesInfo;
        save(fullfile(GUIpath,'resources','profiles','profindex.mat'),'N','profiles','-append')
    else
        % all expected profiles were present
    end

else
    % no profiles in the index so there cant be missing profiles, duh.
end
output.deletedTrue = deletedTrue;
output.deletedList = deletedList;
varargout{1} = output;
end
