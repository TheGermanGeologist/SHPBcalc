function [ dataOut ] = SHPB_modulus( data,expm,step,faxes )
%SHPB_MODULUS plots stress vs strain, called 3 timespan
%   call 1: just plot everything
%   call 2: plot again, calculate tangent modulus from timewindow
%   call 3: plot again, calculate ucd

% load general stuff
strain3 = data.strain3;     % this will be the x-axis
sigmaA = data.sigmaA;
sigmaB = data.sigmaB;
sigmaM = data.sigmaM;
srate3 = data.srate3;
t1 = data.MrLow;
t2 = data.MrUp;
time = data.tCut;

dataOutPre = data;


switch step
    case 14
        % just plot everything
        % first, plot with regular scale for TIMEWINDOWS
        a=plot(faxes,strain3,sigmaA/1e6,'k--');
        hold(faxes,'on')
        b=plot(faxes,strain3,sigmaB/1e6,'b--');
        c=plot(faxes,strain3,sigmaM/1e6,'g','Linewidth',1);
        xlabel(faxes,'\epsilon [-]')
        ylabel(faxes,'\sigma [MPa]')
        title(faxes,'Stress vs. Strain')
        grid(faxes,'on')
        plot(faxes,[strain3(t1),strain3(t1)],[0 sigmaM(t1)/1e6],'k:')
        plot(faxes,[strain3(t2),strain3(t2)],[0 sigmaM(t2)/1e6],'k:')
        text(faxes,strain3(t1),sigmaM(t1)/1e6,'t1')
        text(faxes,strain3(t2),sigmaM(t2)/1e6,'t2')
        legend(faxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
        dataOut = data;
    case 15
        % plot again, calculate, plot and store tangent-modulus
        % calculate tangent-modulus
        tmlwb = data.TmLow;     % lower border of linear section
        tmupb = data.TmUp;     % upper border of linear section
        % cut out linear section
        linstrain = strain3(strain3 >= tmlwb & strain3 <= tmupb & srate3 > 0);
        linstress = sigmaM(strain3 >= tmlwb & strain3 <= tmupb & srate3 > 0);
        linrate = srate3(strain3 >= tmlwb & strain3 <= tmupb & srate3 > 0);
        lintime = time(strain3 >= tmlwb & strain3 <= tmupb & srate3 > 0);
        elasticrate = mean(linrate);
        stdelasticrate = std(linrate);
        % evaluate it
        coeff = polyfit(linstrain,linstress,1);
        tanmod = coeff(1);      % tangent-modulus
        tmline = polyval(coeff,linstrain);
        % error
        % no idea what exactly the math behind this is, lookup sometime!
        sy = sqrt(1 / (length(linstrain) - 2) * sum((linstress - coeff(1) * linstrain - coeff(2)).^2));
        Zaehler = (1 / length(linstrain) * sy^2);
        Nenner = mean((linstrain).^2) - (mean(linstrain))^2;
        deltatm = sqrt(Zaehler / Nenner);
        % plot all
        a=plot(faxes,strain3/1e-3,sigmaA/1e6,'k--');
        hold(faxes,'on')
        b=plot(faxes,strain3/1e-3,sigmaB/1e6,'b--');
        c=plot(faxes,strain3/1e-3,sigmaM/1e6,'g','Linewidth',1);
        plot(faxes,linstrain/1e-3,tmline/1e6,'k','LineWidth',1.5);
        xlabel(faxes,'\epsilon [mm/m]')
        ylabel(faxes,'\sigma [MPa]')
        title(faxes,'Stress vs. Strain')
        % set xlim and ylim
        xlim(faxes,[0 max(xlim(faxes))])
        ylim(faxes,[0 max(ylim(faxes))])
        grid(faxes,'on')
        string1 = 'tangent modulus [GPa]';
        string2 = [num2str(round(tanmod/1e9,2)),'\xb1 ',num2str(round(deltatm/1e9,2))];
        msg = sprintf([string1,'\n',string2]);
        % x1 = (linstrain(length(linstrain)) / 2 + linstrain(length(linstrain)) / 20) / 1e-3;
        % y1 = (linstress(length(linstress)) / 2 - linstress(length(linstress)) / 20) / 1e6;
        x1 = (linstrain(round(length(linstrain) / 2)) + linstrain(length(linstrain)) / 20) / 1e-3;
        y1 = (linstress(round(length(linstress) / 2)) - linstress(length(linstress)) / 20) / 1e6;
        text(faxes,x1,y1,msg)
        plot(faxes,[strain3(t1)/1e-3,strain3(t1)/1e-3],[0 sigmaM(t1)/1e6],'k:')
        plot(faxes,[strain3(t2)/1e-3,strain3(t2)/1e-3],[0 sigmaM(t2)/1e6],'k:')
        text(faxes,strain3(t1)/1e-3,sigmaM(t1)/1e6,'t1')
        text(faxes,strain3(t2)/1e-3,sigmaM(t2)/1e6,'t2')
        legend(faxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
        % store data
        dataOutPre.tanmod = tanmod;
        dataOutPre.deltatm = deltatm;
        dataOutPre.linstrain = linstrain;
        dataOutPre.linstress = linstress;
        dataOutPre.linrate = linrate;
        dataOutPre.lintime = lintime;
        dataOutPre.elasticrate = elasticrate;
        dataOutPre.stdelasticrate = stdelasticrate;
        dataOutPre.tmline = tmline;
        dataOut = dataOutPre;
    case 16
        % check if sample failed
        if expm.fail == 1
            textsign = '\sigma_{ucd} = ';
        else
            textsign = '\sigma_{max} = ';
        end
        % calculate ucd, then plot again
        % get tangent-modulus vars
        tanmod = data.tanmod;
        deltatm = data.deltatm;
        linstrain = data.linstrain;
        linstress = data.linstress;
        tmline = data.tmline;
        % determine ucd
        [ucd,ucdI] = max(sigmaM);    % [MPa]
        ucd = ucd / 1e6;
        % build string
        string3 = [textsign,num2str(round(ucd)),' MPa'];
        % position string
        x2 = strain3(find(sigmaM == max(sigmaM))) / 1e-3;
        ucdstrain = x2 * 1e-3;
        finalstrain = strain3(end);
        ucdrate = srate3(find(sigmaM == max(sigmaM)));
        y2 = ucd + 0.03 * ucd;
        % plot old stuff again
        a=plot(faxes,strain3/1e-3,sigmaA/1e6,'k--');
        hold(faxes,'on')
        b=plot(faxes,strain3/1e-3,sigmaB/1e6,'b--');
        c=plot(faxes,strain3/1e-3,sigmaM/1e6,'g','Linewidth',1);
        plot(faxes,linstrain/1e-3,tmline/1e6,'k','LineWidth',1.5);
        xlabel(faxes,'\epsilon [mm/m]')
        ylabel(faxes,'\sigma [MPa]')
        title(faxes,'Stress vs. Strain')
        string1 = 'tangent modulus [GPa]';
        string2 = [num2str(round(tanmod/1e9,2)),'\xb1 ',num2str(round(deltatm/1e9,2))];
        msg = sprintf([string1,'\n',string2]);
%         x1 = (linstrain(length(linstrain)) / 2 + linstrain(length(linstrain)) / 20) / 1e-3;
%         y1 = (linstress(length(linstress)) / 2 - linstress(length(linstress)) / 20) / 1e6;
        x1 = (linstrain(round(length(linstrain) / 2)) + linstrain(length(linstrain)) / 20) / 1e-3;
        y1 = (linstress(round(length(linstress) / 2)) - linstress(length(linstress)) / 20) / 1e6;
        text(faxes,x1,y1,msg)
        % plot ucd
        plot(faxes,strain3(ucdI)/1e-3,ucd,'kd','MarkerFaceColor','k')
        text(faxes,x2,y2,string3)
        % set xlim and ylim
        xlim(faxes,[0 max(xlim(faxes))])
        ylim(faxes,[0 max(ylim(faxes))])
        grid(faxes,'on')
        plot(faxes,[strain3(t1)/1e-3,strain3(t1)/1e-3],[0 sigmaM(t1)/1e6],'k:')
        plot(faxes,[strain3(t2)/1e-3,strain3(t2)/1e-3],[0 sigmaM(t2)/1e6],'k:')
        text(faxes,strain3(t1)/1e-3,sigmaM(t1)/1e6,'t1')
        text(faxes,strain3(t2)/1e-3,sigmaM(t2)/1e6,'t2')
        legend(faxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
        % store ucd
        dataOutPre.ucd = ucd;
        dataOutPre.ucdstrain = ucdstrain;
        dataOutPre.ucdrate = ucdrate;
        dataOutPre.finalstrain = finalstrain;
        dataOut = dataOutPre;
    otherwise
        error('Can''t call fx at this step')
end
