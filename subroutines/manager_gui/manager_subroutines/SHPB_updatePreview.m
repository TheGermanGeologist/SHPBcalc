function SHPB_updatePreview(handles)

if get(handles.previewtoggle,'Value') == 1 && ~isempty(handles.expms.eInfo)
  % clear axes
  cla(handles.previewaxes)
  cla(handles.previewaxes,'reset')
  % check if evaluated
  if handles.expms.expmstruct.eval == 1
  % load experiment data
  expmdata = handles.expms.expmdata;
  plottype = get(handles.previewslct,'Value');
    switch plottype
        case 1
            % Cut and shifted pulses
            sI = expmdata.strainInCut;
            tI = expmdata.tInCut;
            sR = expmdata.strainReCut;
            tR = expmdata.tReCut;
            sT = expmdata.strainTrCut;
            tT = expmdata.tTrCut;
            sS = sI + sR;
            plot(handles.previewaxes,tI,sI,'k',tR,sR,'b',tT,sT,'r',tT,sS,'m--','LineWidth',1.5)
        case 2
            % Stress vs time
            t = expmdata.tCut;
            sigmaA = expmdata.sigmaA;
            sigmaB = expmdata.sigmaB;
            sigmaM = expmdata.sigmaM;
            plot(handles.previewaxes,t/1e-3,sigmaA/1e6,'b',t/1e-3,sigmaB/1e6,'k',t/1e-3,sigmaM/1e6,'g','LineWidth',1.5)
        case 3
            % Strain rate vs time
            t = expmdata.tCut;
            rate3 = expmdata.srate3;
            rate = expmdata.srate;
            rlwb = expmdata.MrLow;
            rupb = expmdata.MrUp;
            t1 = t(rlwb);
            t2 = t(rupb);
            meanrate = expmdata.plateaurate;
            stdmean = expmdata.stdplateaurate;
            line = expmdata.rateline;
            plot(handles.previewaxes,t/1e-3,rate,'b',t/1e-3,rate3,'k',t(rlwb:rupb)/1e-3,line(rlwb:rupb),'r:','LineWidth',1.5)
            message = num2str(round(line(:,1)));
            text(handles.previewaxes,(t1+t2) / 2 * 1e3, line(:,1) -10,message,'Color','r')
        case 4
            % Cumulative strain
            t = expmdata.tCut;
            strain = expmdata.strain;
            strain3 = expmdata.strain3;
            plot(handles.previewaxes,t,strain,'b','LineWidth',1.5)
            hold(handles.previewaxes,'on')
            plot(handles.previewaxes,t,strain3,'k','LineWidth',1.5)
        case 5
            % Stress vs Strain with derivatives
            strain3 = expmdata.strain3;
            sigmaA = expmdata.sigmaA;
            sigmaB = expmdata.sigmaB;
            sigmaM = expmdata.sigmaM;
            tanmod = expmdata.tanmod;
            deltatm = expmdata.deltatm;
            linstrain = expmdata.linstrain;
            linstress = expmdata.linstress;
            tmline = expmdata.tmline;
            [ucd,ucdI] = max(sigmaM);
            ucd = ucd / 1e6;
            string3 = num2str(round(ucd));
            % position string
            x2 = strain3(find(sigmaM == max(sigmaM))) / 1e-3;
            y2 = ucd + 0.03 * ucd;
            % plot old stuff again
            plot(handles.previewaxes,strain3/1e-3,sigmaA/1e6,'k--',strain3/1e-3,sigmaB/1e6,'b--')
            hold(handles.previewaxes,'on')
            plot(handles.previewaxes,strain3/1e-3,sigmaM/1e6,'g','Linewidth',1)
            plot(handles.previewaxes,linstrain/1e-3,tmline/1e6,'k','LineWidth',1.5)
            string2 = num2str(round(tanmod/1e9,2));
            msg = sprintf(string2);
            x1 = (linstrain(round(length(linstrain) / 2)) + linstrain(length(linstrain)) / 20) / 1e-3;
            y1 = (linstress(round(length(linstress) / 2)) - linstress(length(linstress)) / 20) / 1e6;
            text(handles.previewaxes,x1,y1,msg)
            % plot ucd
            plot(handles.previewaxes,strain3(ucdI)/1e-3,ucd,'kd','MarkerFaceColor','k')
            text(handles.previewaxes,x2,y2,string3)
    end
  else
    % clear axes
    cla(handles.previewaxes)
    cla(handles.previewaxes,'reset')
  end
else
    % clear axes
    cla(handles.previewaxes)
    cla(handles.previewaxes,'reset')
end
