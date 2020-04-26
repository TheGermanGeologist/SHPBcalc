function [ dataOut ] = SHPB_extendedeval( data,step,haxes1,haxes2 )

switch step
    case 17
        % Fracture work / energy absorbed
        sI = data.strainInCut;
        sT = data.strainTrCut;
        sR = data.strainReCut;
        t = data.tCut;
        Ab = data.Ab;
        C0 = data.C0;
        Eb = data.Eb;
        factor = (Ab * C0) / Eb;
        
        WI = factor * cumtrapz(t,(sI*Eb).^2);
        WR = factor * cumtrapz(t,(sR*Eb).^2);
        WT = factor * cumtrapz(t,(sT*Eb).^2);
        
        absorbed = WI - WR - WT;
        fractureWork = absorbed(end);
        dataOut = data;
        dataOut.fractureWork = fractureWork;
        dataOut.WI = WI;
        dataOut.WR = WR;
        dataOut.WT = WT;
        
        plot(haxes1,t,WI,'--k','LineWidth',1.3)
        hold(haxes1,'on')
        grid(haxes1,'on')
        plot(haxes1,t,WR,'--','LineWidth',1.3,'Color',[0.8 0.3 0])
        plot(haxes1,t,WT,'--r','LineWidth',1.3)
        plot(haxes1,t,WI-WT-WR,'-b','LineWidth',1.3)
        legend(haxes1,'W_{I}','W_{R}','W_{T}','W_{I}-W_{R}-W_{T}')
        title(haxes1,'Energy vs. time')
        xlabel(haxes1,'Time [s]')
        ylabel(haxes1,'Energy [J]')
        
        plot(haxes2,WI-WR,WT,':r','LineWidth',1.2)
        hold(haxes2,'on')
        maxval = max(max([WI-WR,WT]));
        plot(haxes2,[0 maxval],[0 maxval],'-k','LineWidth',1.4)
        grid(haxes2,'on')
        title(haxes2,'Energy transmission')
        xlabel(haxes2,'W_{I}-W_{R}')
        ylabel(haxes2,'W_{T}')
        
        
        
    case 18
        % axial strain acceleration
        linrate = data.linrate;
        linstrain = data.linstrain;
        linstress = data.linstress;
        lintime = data.lintime;
        dt = mean(lintime(2:end)-lintime(1:end-1));
        axStAcc = (linrate(2:end)-linrate(1:end-1)) ./ dt;
        transientMod = (linstress(2:end)-linstress(1:end-1)) ./ (linstrain(2:end)-linstrain(1:end-1));
        
        plot(haxes1,lintime(1:end-1),axStAcc,'-k','LineWidth',1.2)
        grid(haxes1,'on')
        title(haxes1,'Axial strain acceleration')
        ylabel(haxes1,'Axial strain acceleration [s^{-2}]')
        xlabel(haxes1,'Time [s]')
        
        plot(haxes2,axStAcc,transientMod,'-k','LineWidth',1.2)
        grid(haxes2,'on')
        title(haxes2,'Sample inertia')
        ylabel(haxes2,'\delta_{\sigma}/\delta_{\epsilon}')
        xlabel(haxes2,'Axial strain acceleration [s^{-2}]')
        
        
        dataOut = data;
        dataOut.axStAcc = axStAcc;
        dataOut.transientMod = transientMod;
    case 19
        % complete sample history
        srate3 = data.srate3;
        strain3 = data.strain3;
        sigmaA = data.sigmaA;
        sigmaB = data.sigmaB;
        sigmaM = data.sigmaM;
        time = data.tCut;
        maxstress = max(max([sigmaA sigmaB sigmaM]));
        maxrate = max(srate3);
        maxstrain = max(strain3);
        
        rlwb = data.MrLow;
        rupb = data.MrUp;
        t1 = time(rlwb);   % plateautime1
        t2 = time(rupb);   % plateatime2
        lintime = data.lintime;
        t3 = lintime(1);
        t4 = lintime(end);
        t5 = time(find(sigmaM == max(sigmaM)));
        
        plot(haxes1,time,sigmaA./maxstress,'-g')
        hold(haxes1,'on')
        plot(haxes1,time,sigmaB./maxstress,'-b')
        a = plot(haxes1,time,sigmaM./maxstress,'-k','LineWidth',1.2);
        b = plot(haxes1,time,srate3./maxrate,'-r','LineWidth',1.2);
        plot(haxes1,[t1 t1],[-0.5 1],'k:')
        plot(haxes1,[t2 t2],[-0.5 1],'k:')
        plot(haxes1,[t3 t3],[-0.5 1],'k:')
        plot(haxes1,[t4 t4],[-0.5 1],'k:')
        plot(haxes1,[t5 t5],[-0.5 1],'k:')
        text(haxes1,t1,1.1,'t_{p0}')
        text(haxes1,t2,1.1,'t_{p1}')
        text(haxes1,t3,1.1,'t_{e0}')
        text(haxes1,t4,1.1,'t_{e1}')
        text(haxes1,t5,1.1,'t_{ucd}')
        plot(haxes1,[t1 t2],[data.plateaurate/maxrate data.plateaurate/maxrate],...
            'Color',[0.8,0.5,0])
        plot(haxes1,[t3 t4],[data.elasticrate/maxrate data.elasticrate/maxrate],...
            'Color',[0.8,0,0.6])
        text(haxes1,(t1+t2)/2,data.plateaurate/maxrate+0.1,[num2str(round(data.plateaurate)),' \pm ',num2str(round(data.stdplateaurate))],...
            'Color',[0.8,0.5,0])
        text(haxes1,(t3+t4)/2,data.elasticrate/maxrate+0.1,[num2str(round(data.elasticrate)),' \pm ',num2str(round(data.stdelasticrate))],...
            'Color',[0.8,0,0.6])
        legend(haxes1,[a b],'Stress','Strain rate')
        xlabel(haxes1,'Time [s]')
        ylabel(haxes1,'Normalized stress & strain rate')
        
        a = plot(haxes2,time,sigmaA./maxstress,'-g');
        hold(haxes2,'on')
        plot(haxes2,time,sigmaB./maxstress,'-b')
        plot(haxes2,time,sigmaM./maxstress,'-k','LineWidth',1.2)
        b = plot(haxes2,time,strain3./maxstrain,'-r','LineWidth',1.2);
        plot(haxes2,[t1 t1],[0 1],'k:')
        plot(haxes2,[t2 t2],[0 1],'k:')
        plot(haxes2,[t3 t3],[0 1],'k:')
        plot(haxes2,[t4 t4],[0 1],'k:')
        plot(haxes2,[t5 t5],[0 1],'k:')
        text(haxes2,t1,1.1,'t_{p0}')
        text(haxes2,t2,1.1,'t_{p1}')
        text(haxes2,t3,1.1,'t_{e0}')
        text(haxes2,t4,1.1,'t_{e1}')
        text(haxes2,t5,1.1,'t_{ucd}')
        legend(haxes2,[a b],'Stress','Strain')
        xlabel(haxes2,'Time [s]')
        ylabel(haxes2,'Normalized stress & strain')
        
        dataOut = data;
        
    otherwise
        error('Can''t call fx at this step')
end

end