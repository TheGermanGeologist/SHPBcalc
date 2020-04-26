function [ varargout ] = SHPB_rate( data,step,faxes )
%SHPB_RATE plots the strain rate history
%   Strain rate history, once with, once without the mean strain rate

t = data.tCut;
rate3 = data.srate3;
rate = data.srate;


switch step
    case 11
        if nargout ~= 0
            msg = ['No output arguments allowed at step ',num2str(step)];
            error(msg)
        else
        end
        % just plot the history, borders have yet to be defined
        % first time plotting this, use the regular timescale for TIMEWINDOWS
        plot(faxes,t,rate,'b',t,rate3,'k','LineWidth',1.5)
        legend(faxes,'1-wave evaluation','3-waves evaluation','Location','South','Orientation','horizontal')
        xlabel(faxes,'time [s]')
        ylabel(faxes,'strain rate [s^{-1}]')
        grid(faxes,'on')
        title(faxes,'Strain rate history')
    case 12
        if nargout > 1
            msg = ['Only one output allowed at step ',num2str(step)];
            error(msg)
        else
        end
        % plot with mean strain rate displayed
        rlwb = data.MrLow;
        rupb = data.MrUp;
        dataOutPre = data;
        t1 = t(rlwb);
        t2 = t(rupb);
%         meanrate = mean(rate3(rlwb:rupb));
%         stdmean = std(rate3(rlwb:rupb));
        plateaurate =  mean(rate3(rlwb:rupb));
        stdplateaurate = std(rate3(rlwb:rupb));
        maxrate = max(rate3);
        line = linspace(plateaurate,plateaurate,length(t));
        plot(faxes,t/1e-3,rate,'b',t/1e-3,rate3,'k',t(rlwb:rupb)/1e-3,line(rlwb:rupb),'r:','LineWidth',1.5)
        message = [num2str(round(line(:,1))),' \pm',num2str(round(stdplateaurate)),' s^-^1'];
        text(faxes,(t1+t2) / 2 * 1e3, line(:,1) - 10,message,'Color','r')
        xlabel(faxes,'time [ms]')
        ylabel(faxes,'strain rate [s^{-1}]')
        grid(faxes,'on')
        legend(faxes,'1-wave evaluation','3-waves evaluation','Mean strain rate','Location','South','Orientation','horizontal')
        title(faxes,'Mean strain rate')
        dataOutPre.plateaurate = plateaurate;
        dataOutPre.stdplateaurate = stdplateaurate;
        dataOutPre.rateline = line;
        dataOutPre.maxrate = maxrate;
        varargout{1} = dataOutPre;
    otherwise
        error('Can''t call this functions at this evaluation step.')
end


end
