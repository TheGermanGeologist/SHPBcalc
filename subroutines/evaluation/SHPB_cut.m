function [ dataOut ] = SHPB_cut( data,prof,faxes )
%SHPB_CUT cuts all arrays to equal length
%   Detailed explanation goes here

dataOutPre = data;

tIc = data.tInCorr;         % corrected & shifted Incident time array
tRc = data.tReCorr;         % corrected & shifted Reflected time array
tTc = data.tTrCorr;         % corrected & shifted Transmitted time array

sIc = data.strainInCorr;    % corrected Incident strain array
sRc = data.strainReCorr;    % corrected Reflected strain array
sTc = data.strainTrCorr;    % corrected Transmitted strain array

% determine limiting borders (should replace visual input)
startv = [tIc(1),tRc(1),tTc(1)];        % all first values
endv = [tIc(end),tRc(end),tTc(end)];    % all last values

lwb = max(startv);  % the biggest value at start must be the lower limit
upb = min(endv);    % the smallest value at end must be the upper limit

% Cut
% Incident
sI = sIc(tIc >= lwb);
tI = tIc(tIc >= lwb);
sI = sI(tI <= upb);
tI = tI(tI <= upb);
% Reflected
sR = sRc(tRc >= lwb);
tR = tRc(tRc >= lwb);
sR = sR(tR <= upb);
tR = tR(tR <= upb);
% Transmitted
sT = sTc(tTc >= lwb);
tT = tTc(tTc >= lwb);
sT = sT(tT <= upb);
tT = tT(tT <= upb);

% HUUUGE probably unnessecary precaution follows, normal code line 110.
% in case the fix in the shift-step didn't work and there is still some
% oddity flying under the radar, applying a brutal fix here
if length(tI) == length(tR) && length(tI) == length(tT) && length(tR) == length(tT)
    % all good
else
    freq = prof.Hz*1e6;
    spacing = 1 / freq;
    arraylengths = [length(tI)  length(tR)  length(tT)];
    % make sure the offset is only 1, else nope.
    longarray = max(arraylengths);
    shortarray = min(arraylengths);
    if (longarray - shortarray) > 1
        warning('Time arrays mismatch by more than one element. Cutting ends, might cause time-mismatch.')
        sI = sI(1:shortarray);
        tI = tI(1:shortarray);
        sR = sR(1:shortarray);
        tR = tR(1:shortarray);
        sT = sT(1:shortarray);
        tT = tT(1:shortarray);
        msg = ['The signals might be mismatched by as much as ',...
            num2str((longarray-shortarray+1)*spacing*1e6),'µs'];
        warning(msg)
    else
        % mismatch is only one element
        % identify the mismatched array
        mismatched = isoutlier(arraylengths);
        [~,mismId] = max(mismatched);
        % since there exists a deviation in values between the three arrays
        % it is difficult to determine wether the first or last element is
        % off. Not impossible, but too much coding for a problem which
        % should be already be fixed in shift.
        % short or long
%         if arraylengths(mismatched) == longarray
%             % outlier is too long
%             newlength = shortarray;
%         elseif arraylengths(mismatched) == shortarray
%             % outlier is too short
%             newlength = longarray;
%         else
%             % what the hell
%             error('Something is seriously wrong with the time arrays.')
%         end
        % just cutting everything to equal length here
        sI = sI(1:shortarray);
        tI = tI(1:shortarray);
        sR = sR(1:shortarray);
        tR = tR(1:shortarray);
        sT = sT(1:shortarray);
        tT = tT(1:shortarray);
        warning('There was a mismatch in time array length. Arrays have been cut to equal length')
        msg = ['The signals might be mismatched by as much as ',...
            num2str(2*spacing*1e6),'µs'];
        warning(msg)
        switch mismId
            case 1
                warning('Deviant time array: Incident')
            case 2
                warning('Deviant time array: Reflected')
            case 3
                warning('Deviant time array: Transmitted')
            otherwise
                % what the hell
                error('Something is seriously wrong with the time arrays.')
        end
    end
    
end

% additional step to cut down on extraction in the next eval step
% unifying time array
t = (tI + tR + tT) / 3;     % calculate mean in case something is off
t = t - min(t);             % shift to zero
% apply decimal precision fix again
freq = prof.Hz*1e6;
t = fix(t * freq)/freq;
sS = sI + sR;               % sum of incident & reflected strain
% plot
plot(faxes,tI,sI,'k',tR,sR,'b',tT,sT,'r',tT,sS,'m--')
xlabel(faxes,'time [s]')
ylabel(faxes,'strain \epsilon [-]')
legend(faxes,'\epsilon_I','\epsilon_R','\epsilon_T','\epsilon_I+\epsilon_R')
title(faxes,'Cut data, element-wise sum of incident and reflected pulses')
grid(faxes,'on')

% store
dataOutPre.strainInCut = sI;
dataOutPre.tInCut = tI;
dataOutPre.strainReCut = sR;
dataOutPre.tReCut = tR;
dataOutPre.strainTrCut = sT;
dataOutPre.tTrCut = tT;         % the t-arrays are not needed for eval, but explore
dataOutPre.tCut = t;

dataOut = dataOutPre;

end
