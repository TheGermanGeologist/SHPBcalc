function [ xpos ] = SHPB_timewindow( x,t,rate )
%SHPB_TIMEWINDOW find the array numbers of input floatpoint values
%   INPUT ARGUMENTS: x = vector with the values
%                    t = vector that should be searched for x
%                    rate = sampling rate of t in MHz

% preparations
rate = rate * 1e6;          % change to Hz
spacing = 1 / rate;    % this yields the spacing of data points
tolsteps = spacing / 10;    % increase tolerance in these steps
N = max(size(x));           % number of input positions
xpos = zeros(1,N);          % initialize output var

% now we must find the position of these values in their array. direct
% comparision is not possible because we deal with floating point numbers.
% set initial tolerance to smallest difference in measurement, depending on
% the sampling rate
% at a sampling rate of 10 MHz two points are 1e-7 apart, so start at a
% tolerance of 1e-8 and increase in 1e-8 steps until we get a result. If
% increasing the tolerance to far leads to two results decrease again with
% 0.3e-8

% looking at this two years later, this is all very silly. Why not simply
% round the value given by ginput to the same precision as the sampling
% frequency? Oh well, now that it is here, it stays. Have to apply fix for
% cut step though, because there the loop times out

% even later, I discover that there is an undocumented function called
% Data Brushing which makes data selection much more convenient. Might switch to
% this as long as it isn't removed in a future MATLAB release. For now let's work
% with this.

for i = 1:N
    tolerance = tolsteps;   % initial guess for tolerance;
    check = 0;
    search = abs(t - x(i));
    timeoutlimit = 300;
    iterations = 0;
    while check == 0 && iterations < timeoutlimit
        pos = find(search < tolerance);
        possize = max(size(pos));
        if isempty(pos)
            % value not found, tolerance too small
            tolerance = tolerance + tolsteps;
            check = 0;
        elseif possize > 1
            % multiple values found, tolerance to big
            tolerance = tolerance - tolsteps*0.3;
            check = 0;
        else
            % value correctly identified, we are done
            check = 1;
        end
        iterations = iterations + 1;
    end
    disp(['Iterations: ',num2str(iterations)])
    if check == 0
        % new, much simpler way of solving this
        [~,pos] = min(abs(t - x(i)));
        disp('Alternative timewindow method used')
    else
    end
    xpos(i) = pos;
end



end
