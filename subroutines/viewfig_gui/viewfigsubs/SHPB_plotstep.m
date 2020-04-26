%{
plot figure depending on chosen step to new guidata
this functions recreate all necessary steps in order to plot the data of the
current step in a new window
%}


function returnstate = SHPB_plotstep(targetaxes, data, expm, step )

% clean slate
cla(targetaxes)
cla(targetaxes,'reset')

% set initial returnstate
returnstate = 0;

% giant switch case


switch step
  case 0
    % RAW DATA
    raw1a = data.raw1a;
    raw1b = data.raw1b;
    raw2a = data.raw2a;
    raw2b = data.raw2b;
    rawt = data.rawt;
    plot(targetaxes,rawt,raw1a,rawt,raw1b,rawt,raw2a,rawt,raw2b)
    xlabel(targetaxes,'t [s]')
    ylabel(targetaxes,'Voltage [V]')
    title(targetaxes,'Complete raw data')
    legend(targetaxes,'Incident A','Incident B','Transmission A','Transmission B')
    grid(targetaxes,'on')
    returnstate = 1;
  case 1
    % BENDING CORRECTION
    rawt = data.rawt;
    DMSI = data.DMSI;
    DMST = data.DMST;
    plot(targetaxes,rawt,DMSI,rawt,DMST)
    grid(targetaxes,'on')
    legend(targetaxes,'Incident bar signal (bending corrected)','Transmission bar signal (bending corrected)')
    xlabel(targetaxes,'t [s]')
    ylabel(targetaxes,'Voltage [V]')
    returnstate = 1;
  case 2
    % INCIDENT SELCETED
    t = data.rawt;
    DMSI = data.DMSI;
    DMST = data.DMST;
    InLow = data.InLow;
    InUp = data.InUp;
    plot(targetaxes,t,DMSI,t,DMST)
    hold(targetaxes,'on')
    plot(targetaxes,t(InLow:InUp),DMSI(InLow:InUp),'r.')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'Voltage [V]')
    title(targetaxes,'Pulse selection')
    grid(targetaxes,'on')
    legend(targetaxes,'Incident signal','Transmitted signal','Incident pulse')
    returnstate = 1;
  case 3
    % REFLECTED SELECTED
    t = data.rawt;
    DMSI = data.DMSI;
    DMST = data.DMST;
    InLow = data.InLow;
    InUp = data.InUp;
    ReLow = data.ReLow;
    ReUp = data.ReUp;
    plot(targetaxes,t,DMSI,t,DMST)
    hold(targetaxes,'on')
    plot(targetaxes,t(InLow:InUp),DMSI(InLow:InUp),'r.')
    plot(targetaxes,t(ReLow:ReUp),DMSI(ReLow:ReUp),'g.')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'Voltage [V]')
    title(targetaxes,'Pulse selection')
    grid(targetaxes,'on')
    legend(targetaxes,'Incident signal','Transmitted signal','Incident pulse','Reflected pulse')
    returnstate = 1;
  case 4
    % TRANSMITTED SELECTED
    t = data.rawt;
    DMSI = data.DMSI;
    DMST = data.DMST;
    InLow = data.InLow;
    InUp = data.InUp;
    ReLow = data.ReLow;
    ReUp = data.ReUp;
    TrLow = data.TrLow;
    TrUp = data.TrUp;
    plot(targetaxes,t,DMSI,t,DMST)
    hold(targetaxes,'on')
    plot(targetaxes,t(InLow:InUp),DMSI(InLow:InUp),'r.')
    plot(targetaxes,t(ReLow:ReUp),DMSI(ReLow:ReUp),'g.')
    plot(targetaxes,t(TrLow:TrUp),DMST(TrLow:TrUp),'y.')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'Voltage [V]')
    title(targetaxes,'Pulse selection')
    grid(targetaxes,'on')
    legend(targetaxes,'Incident signal','Transmitted signal','Incident pulse','Reflected pulse','Transmitted pulse')
    returnstate = 1;
  case 5
    % dispersion correction - invalid call
    returnstate = 0;
    errordlg('Can''t call at this this step', 'Error')
    return
  case 6
    % dispersion correction - invalid call
    returnstate = 0;
    errordlg('Can''t call at this this step', 'Error')
    return
  case 7
    % dispersion correction - invalid call
    returnstate = 0;
    errordlg('Can''t call at this this step', 'Error')
    return
  case 8
    % DATA SHIFTED TO SUPERPOSITION
    sIc = data.strainInCorr;    % corrected Incident strain array
    sRc = data.strainReCorr;    % corrected Reflected strain array
    sTc = data.strainTrCorr;    % corrected Transmitted strain array
    tIc = data.tInCorr;         % shifted Incident time array
    tRc = data.tReCorr;         % shifted Reflected time array
    tTc = data.tTrCorr;         % shifted Transmitted time array
    plot(targetaxes,tIc,sIc,'k',tRc,sRc,'b',tTc,sTc,'r')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'strain [-]')
    legend(targetaxes,'Incident wave','Reflected wave','Transmitted wave')
    title(targetaxes,'dispersion- and time corrected pulses at respective sample interface')
    grid(targetaxes,'on')
    returnstate = 1;
  case 9
    % DATA CUT TO EQUAL LENGTH
    sI = data.strainInCut;
    tI = data.tInCut;
    sR = data.strainReCut;
    tR = data.tReCut;
    sT = data.strainTrCut;
    tT = data.tTrCut;
    sS = sI + sR;
    plot(targetaxes,tI,sI,'k',tR,sR,'b',tT,sT,'r',tT,sS,'m--')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'strain \epsilon [-]')
    legend(targetaxes,'\epsilon_I','\epsilon_R','\epsilon_T','\epsilon_I+\epsilon_R')
    title(targetaxes,'Cut data, element-wise sum of incident and reflected pulses')
    grid(targetaxes,'on')
    returnstate = 1;
  case 10
    % STRESS VS TIME
    t = data.tCut;
    sigmaA = data.sigmaA;
    sigmaB = data.sigmaB;
    sigmaM = data.sigmaM;
    plot(targetaxes,t/1e-3,sigmaA/1e6,'b',t/1e-3,sigmaB/1e6,'k',t/1e-3,sigmaM/1e6,'g','LineWidth',1.5)
    xlabel(targetaxes,'time [ms]')
    ylabel(targetaxes,'stress [MPa]')
    legend(targetaxes,'\sigma_a','\sigma_b','3-waves evaluation','Location','south','Orientation','vertical')
    grid(targetaxes,'on')
    returnstate = 1;
  case 11
    % STRAIN RATE VS TIME
    t = data.tCut;
    rate3 = data.srate3;
    rate = data.srate;
    plot(targetaxes,t,rate,'b',t,rate3,'k')
    legend(targetaxes,'1-wave evaluation','3-waves evaluation','Location','South','Orientation','horizontal')
    xlabel(targetaxes,'time [s]')
    ylabel(targetaxes,'strain rate [s^{-1}]')
    grid(targetaxes,'on')
    returnstate = 1;
  case 12
    % MEAN STRAIN RATE
    t = data.tCut;
    rate3 = data.srate3;
    rate = data.srate;
    rlwb = data.MrLow;
    rupb = data.MrUp;
    t1 = t(rlwb);
    t2 = t(rupb);
    meanrate = data.plateaurate;
    stdmean = data.stdplateaurate;
    line = data.rateline;
    plot(targetaxes,t/1e-3,rate,'b',t/1e-3,rate3,'k',t(rlwb:rupb)/1e-3,line(rlwb:rupb),'r:','LineWidth',1.5)
    message = [num2str(round(line(:,1))),' \pm',num2str(round(stdmean)),' s^-^1'];
    text(targetaxes,(t1+t2) / 2 * 1e3, line(:,1) + 20,message,'Color','r')
    xlabel(targetaxes,'time [ms]')
    ylabel(targetaxes,'strain rate [s^{-1}]')
    grid(targetaxes,'on')
    returnstate = 1;
  case 13
    % CUMULATIVE STRAIN
    t = data.tCut;
    strain = data.strain;
    strain3 = data.strain3;
    plot(targetaxes,t,strain)
    hold(targetaxes,'on')
    plot(targetaxes,t,strain3)
    title(targetaxes,'Cumulative sample strain')
    xlabel(targetaxes,'\epsilon [-]')
    ylabel(targetaxes,'Time [s]')
    grid(targetaxes,'on')
    legend(targetaxes,'reflected wave only','3-wave strain')
    returnstate = 1;
  case 14
    % STRESS VS STRAIN
    strain3 = data.strain3;
    sigmaA = data.sigmaA;
    sigmaB = data.sigmaB;
    sigmaM = data.sigmaM;
    t1 = data.MrLow;
    t2 = data.MrUp;
    a=plot(targetaxes,strain3,sigmaA/1e6,'k--');
    b=plot(targetaxes,strain3,sigmaB/1e6,'b--');
    hold(targetaxes,'on')
    c=plot(targetaxes,strain3,sigmaM/1e6,'g','Linewidth',1);
    xlabel(targetaxes,'\epsilon [-]')
    ylabel(targetaxes,'\sigma [MPa]')
    title(targetaxes,'Stress vs. Strain')
    grid(targetaxes,'on')
    plot(targetaxes,[strain3(t1),strain3(t1)],[0 sigmaM(t1)/1e6],'k:')
    plot(targetaxes,[strain3(t2),strain3(t2)],[0 sigmaM(t2)/1e6],'k:')
    text(targetaxes,strain3(t1),sigmaM(t1)/1e6,'t1')
    text(targetaxes,strain3(t2),sigmaM(t2)/1e6,'t2')
    legend(targetaxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
    returnstate = 1;
  case 15
    % TANGENT MODULUS
    strain3 = data.strain3;
    sigmaA = data.sigmaA;
    sigmaB = data.sigmaB;
    sigmaM = data.sigmaM;
    t1 = data.MrLow;
    t2 = data.MrUp;
    linstrain = data.linstrain;
    tmline = data.tmline;
    tanmod = data.tanmod;
    deltatm = data.deltatm;
    linstress = data.linstress;
    a=plot(targetaxes,strain3/1e-3,sigmaA/1e6,'k--');
    hold(targetaxes,'on')
    b=plot(targetaxes,strain3/1e-3,sigmaB/1e6,'b--');
    c=plot(targetaxes,strain3/1e-3,sigmaM/1e6,'g','Linewidth',1);
    plot(targetaxes,linstrain/1e-3,tmline/1e6,'k','LineWidth',1.5);
    xlabel(targetaxes,'\epsilon [mm/m]')
    ylabel(targetaxes,'\sigma [MPa]')
    title(targetaxes,'Stress vs. Strain')
    % set xlim and ylim
    xlim(targetaxes,[0 max(xlim(targetaxes))])
    ylim(targetaxes,[0 max(ylim(targetaxes))])
    grid(targetaxes,'on')
    string1 = 'tangent modulus [GPa]';
    string2 = [num2str(round(tanmod/1e9,2)),'\xb1 ',num2str(round(deltatm/1e9,2))];
    msg = sprintf([string1,'\n',string2]);
    % x1 = (linstrain(length(linstrain)) / 2 + linstrain(length(linstrain)) / 20) / 1e-3;
    % y1 = (linstress(length(linstress)) / 2 - linstress(length(linstress)) / 20) / 1e6;
    x1 = (linstrain(round(length(linstrain) / 2)) + linstrain(length(linstrain)) / 20) / 1e-3;
    y1 = (linstress(round(length(linstress) / 2)) - linstress(length(linstress)) / 20) / 1e6;
    text(targetaxes,x1,y1,msg)
    plot(targetaxes,[strain3(t1)/1e-3,strain3(t1)/1e-3],[0 sigmaM(t1)/1e6],'k:')
    plot(targetaxes,[strain3(t2)/1e-3,strain3(t2)/1e-3],[0 sigmaM(t2)/1e6],'k:')
    text(targetaxes,strain3(t1)/1e-3,sigmaM(t1)/1e6,'t1')
    text(targetaxes,strain3(t2)/1e-3,sigmaM(t2)/1e6,'t2')
    legend(targetaxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
    returnstate = 1;
  case 16
    % UCD / MAX STRESS
    if expm.fail == 1
        textsign = '\sigma_{ucd} = ';
    else
        textsign = '\sigma_{max} = ';
    end
    strain3 = data.strain3;
    sigmaA = data.sigmaA;
    sigmaB = data.sigmaB;
    sigmaM = data.sigmaM;
    t1 = data.MrLow;
    t2 = data.MrUp;
    tanmod = data.tanmod;
    deltatm = data.deltatm;
    linstrain = data.linstrain;
    linstress = data.linstress;
    tmline = data.tmline;
    [ucd,ucdI] = max(sigmaM);
    ucd = ucd / 1e6;
    string3 = [textsign,num2str(round(ucd)),' MPa'];
    % position string
    x2 = strain3(find(sigmaM == max(sigmaM))) / 1e-3;
    y2 = ucd + 0.03 * ucd;
    % plot old stuff again
    a=plot(targetaxes,strain3/1e-3,sigmaA/1e6,'k--');
    hold(targetaxes,'on')
    b=plot(targetaxes,strain3/1e-3,sigmaB/1e6,'b--');
    c=plot(targetaxes,strain3/1e-3,sigmaM/1e6,'g','Linewidth',1);
    plot(targetaxes,linstrain/1e-3,tmline/1e6,'k','LineWidth',1.5);
    xlabel(targetaxes,'\epsilon [mm/m]')
    ylabel(targetaxes,'\sigma [MPa]')
    title(targetaxes,'Stress vs. Strain')
    string1 = 'tangent modulus [GPa]';
    string2 = [num2str(round(tanmod/1e9,2)),'\xb1 ',num2str(round(deltatm/1e9,2))];
    msg = sprintf([string1,'\n',string2]);
    x1 = (linstrain(round(length(linstrain) / 2)) + linstrain(length(linstrain)) / 20) / 1e-3;
    y1 = (linstress(round(length(linstress) / 2)) - linstress(length(linstress)) / 20) / 1e6;
    text(targetaxes,x1,y1,msg)
    % plot ucd
    plot(targetaxes,strain3(ucdI)/1e-3,ucd,'kd','MarkerFaceColor','k')
    text(targetaxes,x2,y2,string3)
    % set xlim and ylim
    xlim(targetaxes,[0 max(xlim(targetaxes))])
    ylim(targetaxes,[0 max(ylim(targetaxes))])
    grid(targetaxes,'on')
    plot(targetaxes,[strain3(t1)/1e-3,strain3(t1)/1e-3],[0 sigmaM(t1)/1e6],'k:')
    plot(targetaxes,[strain3(t2)/1e-3,strain3(t2)/1e-3],[0 sigmaM(t2)/1e6],'k:')
    text(targetaxes,strain3(t1)/1e-3,sigmaM(t1)/1e6,'t1')
    text(targetaxes,strain3(t2)/1e-3,sigmaM(t2)/1e6,'t2')
    legend(targetaxes,[a b c],'\sigma_a','\sigma_b','3-waves evaluation','Location','northwest','Orientation','vertical')
    returnstate = 1;
    
    
    case 171
        t = data.tCut;
        WI = data.WI;
        WR = data.WR;
        WT = data.WT;
        
        plot(targetaxes,t,WI,'--k','LineWidth',1.3)
        hold(targetaxes,'on')
        grid(targetaxes,'on')
        plot(targetaxes,t,WR,'--','LineWidth',1.3,'Color',[0.8 0.3 0])
        plot(targetaxes,t,WT,'--r','LineWidth',1.3)
        plot(targetaxes,t,WI-WT-WR,'-b','LineWidth',1.3)
        legend(targetaxes,'W_{I}','W_{R}','W_{T}','W_{I}-W_{R}-W_{T}')
        title(targetaxes,'Energy vs. time')
        xlabel(targetaxes,'Time [s]')
        ylabel(targetaxes,'Energy [J]')
        
    case 172
        t = data.tCut;
        WI = data.WI;
        WR = data.WR;
        WT = data.WT;
        
        plot(targetaxes,WI-WR,WT,':r','LineWidth',1.2)
        hold(targetaxes,'on')
        maxval = max(max([WI-WR,WT]));
        plot(targetaxes,[0 maxval],[0 maxval],'-k','LineWidth',1.4)
        grid(targetaxes,'on')
        title(targetaxes,'Energy transmission')
        xlabel(targetaxes,'W_{I}-W_{R}')
        ylabel(targetaxes,'W_{T}')
        
    case 181
        lintime = data.lintime;
        axStAcc = data.axStAcc;
        
        plot(targetaxes,lintime(1:end-1),axStAcc,'-k','LineWidth',1.2)
        grid(targetaxes,'on')
        title(targetaxes,'Axial strain acceleration')
        ylabel(targetaxes,'Axial strain acceleration [s^{-2}]')
        xlabel(targetaxes,'Time [s]')
        
    case 182
        axStAcc = data.axStAcc;
        transientMod = data.transientMod;
        
        plot(targetaxes,axStAcc,transientMod,'-k','LineWidth',1.2)
        grid(targetaxes,'on')
        title(targetaxes,'Sample inertia')
        ylabel(targetaxes,'\delta_{\sigma}/\delta_{\epsilon}')
        xlabel(targetaxes,'Axial strain acceleration [s^{-2}]')
        
    case 191
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
        
        plot(targetaxes,time,sigmaA./maxstress,'-g')
        hold(targetaxes,'on')
        plot(targetaxes,time,sigmaB./maxstress,'-b')
        a = plot(targetaxes,time,sigmaM./maxstress,'-k','LineWidth',1.2);
        b = plot(targetaxes,time,srate3./maxrate,'-r','LineWidth',1.2);
        plot(targetaxes,[t1 t1],[-0.5 1],'k:')
        plot(targetaxes,[t2 t2],[-0.5 1],'k:')
        plot(targetaxes,[t3 t3],[-0.5 1],'k:')
        plot(targetaxes,[t4 t4],[-0.5 1],'k:')
        plot(targetaxes,[t5 t5],[-0.5 1],'k:')
        text(targetaxes,t1,1.1,'t_{p0}')
        text(targetaxes,t2,1.1,'t_{p1}')
        text(targetaxes,t3,1.1,'t_{e0}')
        text(targetaxes,t4,1.1,'t_{e1}')
        text(targetaxes,t5,1.1,'t_{ucd}')
        plot(targetaxes,[t1 t2],[data.plateaurate/maxrate data.plateaurate/maxrate],...
            'Color',[0.8,0.5,0])
        plot(targetaxes,[t3 t4],[data.elasticrate/maxrate data.elasticrate/maxrate],...
            'Color',[0.8,0,0.6])
        text(targetaxes,(t1+t2)/2,data.plateaurate/maxrate+0.1,[num2str(round(data.plateaurate)),' \pm ',num2str(round(data.stdplateaurate))],...
            'Color',[0.8,0.5,0])
        text(targetaxes,(t3+t4)/2,data.elasticrate/maxrate+0.1,[num2str(round(data.elasticrate)),' \pm ',num2str(round(data.stdelasticrate))],...
            'Color',[0.8,0,0.6])
        legend(targetaxes,[a b],'Stress','Strain rate')
        xlabel(targetaxes,'Time [s]')
        ylabel(targetaxes,'Normalized stress & strain rate')
        
        
    case 192
        
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
        
        a = plot(targetaxes,time,sigmaA./maxstress,'-g');
        hold(targetaxes,'on')
        plot(targetaxes,time,sigmaB./maxstress,'-b')
        plot(targetaxes,time,sigmaM./maxstress,'-k','LineWidth',1.2)
        b = plot(targetaxes,time,strain3./maxstrain,'-r','LineWidth',1.2);
        plot(targetaxes,[t1 t1],[0 1],'k:')
        plot(targetaxes,[t2 t2],[0 1],'k:')
        plot(targetaxes,[t3 t3],[0 1],'k:')
        plot(targetaxes,[t4 t4],[0 1],'k:')
        plot(targetaxes,[t5 t5],[0 1],'k:')
        text(targetaxes,t1,1.1,'t_{p0}')
        text(targetaxes,t2,1.1,'t_{p1}')
        text(targetaxes,t3,1.1,'t_{e0}')
        text(targetaxes,t4,1.1,'t_{e1}')
        text(targetaxes,t5,1.1,'t_{ucd}')
        legend(targetaxes,[a b],'Stress','Strain')
        xlabel(targetaxes,'Time [s]')
        ylabel(targetaxes,'Normalized stress & strain')
        
        
case 42
    % POCHHAMMER CHREE CURVES
    Dlambdaint = data.Dlambdaint;
    PCdata = data.PCdata;
    N = data.N;
    nu = data.nu;
    legendstr = {};
    for i = 1:N
        plot(targetaxes,Dlambdaint(Dlambdaint<=2),PCdata(Dlambdaint<=2,i))
        hold(targetaxes,'on')
        legendstr{i} = ['nu = ',num2str(nu(i))];
    end
    grid(targetaxes,'on')
    title(targetaxes,'Pochhammer-Chree Curves')
    xlabel(targetaxes,'D/\lambda_{n}')
    ylabel(targetaxes,'C_{n}/C_{0}')
    legend(targetaxes,legendstr,'NumColumns',2)

otherwise
    returnstate = 0;
    errordlg('Invalid call.','Error')
    return
end
