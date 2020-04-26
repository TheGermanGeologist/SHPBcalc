function [Valid, Msg] = CheckFileName(S)
% Credit to Jan, the legend on the matlabcentral forum
Msg = '';
BadChar = ',.<>:"/\|?*§$&%~µ@!{}[]^°';
BadName = {'CON', 'PRN', 'AUX', 'NUL', 'CLOCK$', ...
    'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', ...
    'COM7', 'COM8', 'COM9', ...
    'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', ...
    'LPT7', 'LPT8', 'LPT9'};
bad = ismember(BadChar, S);
if any(bad)
    Msg = ['Name contains bad characters: ', BadChar(bad)];
elseif any(S < 32)
    Msg = ['Name contains non printable characters, ASCII:', sprintf(' %d', S(S < 32))];
elseif ~isempty(S) && (S(end) == ' ' || S(end) == '.')
    Msg = 'A trailing space or dot is forbidden';
elseif any(S == '/')
    Msg = '/ is forbidden in a file name';
elseif any(S == 0)
    Msg = '\0 is forbidden in a file name';
else
    % "AUX.txt" fails also, so extract the file name only:
    [~, name] = fileparts(S);
    if any(strcmpi(name, BadName))
        Msg = ['Name not allowed: ', name];
    end
end

Valid = isempty(Msg);
end
