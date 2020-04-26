function SHPB_updateMetaTable( projectfilepath,expmfilepath,data,profile,expmname )

warning('off','MATLAB:table:RowsAddedExistingVars')
e = load(expmfilepath);
l = load(projectfilepath);
if isfield(l,'metaResults')
    metaTable = l.metaResults;
    metaResults = fillSHPBtable( metaTable,data,e.expm,profile,expmname );
    save(projectfilepath,'metaResults','-append')
else
    metaTable = initSHPBtable();
    metaResults = fillSHPBtable( metaTable,data,e.expm,profile,expmname );
    save(projectfilepath,'metaResults','-append')
end

    function filledTable = fillSHPBtable( originalTable,inputData,inputExpm,inputProfile,inputName )
        pos = numel(originalTable.expmName) + 1;
        originalTable.expmName{pos} = inputName;
        originalTable.sampleMaterial{pos} = inputExpm.lith;
        originalTable.barMaterial{pos} = inputProfile.bName;
        originalTable.strikerLength(pos) = inputProfile.Lp * 100;
        originalTable.strikerSpeed(pos) = inputExpm.v0;
        originalTable.vesselPressure(pos) = inputExpm.cp;
        originalTable.sampleLength(pos) = inputExpm.Ls * 1000;
        originalTable.sampleDiameter(pos) = inputExpm.Ds * 1000;
        originalTable.plateauRate(pos) = inputData.plateaurate;
        originalTable.plateauDev(pos) = inputData.stdplateaurate;
        originalTable.elasticRate(pos) = inputData.elasticrate;
        originalTable.elasticrateDev(pos) = inputData.stdelasticrate;
        originalTable.eMod(pos) = inputData.tanmod;
        originalTable.eModDev(pos) = inputData.deltatm;
        originalTable.UCD(pos) = inputData.ucd;
        originalTable.UCDrate(pos) = inputData.ucdrate;
        originalTable.maxrate(pos) = inputData.maxrate;
        originalTable.failed(pos) = inputExpm.fail;
        originalTable.fractureWork(pos) = inputData.fractureWork;
        originalTable.ucdStrain(pos) = inputData.ucdstrain;
        originalTable.finalStrain(pos) = inputData.finalstrain;
        originalTable.strain3{pos} = inputData.strain3;
        originalTable.sigmaM{pos} = inputData.sigmaM;
        originalTable.srate3{pos} = inputData.srate3;
        originalTable.time{pos} = inputData.tCut;
        filledTable = originalTable;
    end


    function newTable = initSHPBtable()
        expmName = {};
        sampleMaterial = {};
        barMaterial = {};
        strikerLength = [];
        strikerSpeed = [];
        vesselPressure = [];
        sampleLength = [];
        sampleDiameter = [];
        plateauRate = [];
        plateauDev = [];
        elasticRate = [];
        elasticrateDev = [];
        eMod = [];
        eModDev = [];
        UCD = [];
        UCDrate = [];
        maxrate = [];
        failed = [];
        fractureWork = [];
        ucdStrain = [];
        finalStrain = [];
        strain3 = {};
        sigmaM = {};
        srate3 = {};
        time = {};
        
        newTable = table(expmName,sampleMaterial,barMaterial,strikerLength,...
            strikerSpeed,vesselPressure,sampleLength,sampleDiameter,plateauRate,...
            plateauDev,elasticRate,elasticrateDev,eMod,eModDev,UCD,UCDrate,maxrate,...
            failed,fractureWork,ucdStrain,finalStrain,strain3,...
            sigmaM,srate3,time);
    end
end