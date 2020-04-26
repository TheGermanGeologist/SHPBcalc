function [ status ] = SHPB_pcdefault( RESpath )
% PCDEFAULT generates default values of pochhammer chree curves
% input: path of previous curves
% output: status = 1 -> success, status = 0 -> something went wrong

try
    %% 1 ny = 0.1, original
    n1 = [1
        0.99994
        0.99975
        0.99941
        0.9989
        0.99816
        0.9971
        0.99556
        0.99323
        0.98951
        0.98296
        0.97014
        0.94487
        0.90658
        0.86493
        0.82653
        0.79306
        0.76445
        0.74013
        0.71949
        0.70196
        0.65419
        0.62836
        0.61393
        0.60565
        0.6008
        0.600802714
        0.600805429
        0.600808143
        0.600810857
        0.600813571
        0.600816286
        0.600819
        0.600821714
        0.600824429
        0.600827143
        0.600829857
        0.600832571
        0.600835286
        0.600838
        0.600840714
        0.600843429
        0.600846143
        0.600848857
        0.600851571
        0.600854286
        0.600857
        0.600859714
        0.600862429
        0.600865143
        0.600867857
        0.600870571
        0.600873286
        0.600876
        0.600878714
        0.600881429
        0.600884143
        0.600886857];

    %% 2 ny = 0.15, original
    n2 = [1
        0.99986
        0.99943
        0.99868
        0.9989
        0.99591
        0.99362
        0.99038
        0.98569
        0.97866
        0.96771
        0.95037
        0.92436
        0.89086
        0.85471
        0.82009
        0.78893
        0.76167
        0.73812
        0.71791
        0.70058
        0.65266
        0.62623
        0.61118
        0.60236
        0.59707
        0.597065592
        0.597061184
        0.597056776
        0.597052367
        0.597047959
        0.597043551
        0.597039143
        0.597034735
        0.597030327
        0.597025918
        0.59702151
        0.597017102
        0.597012694
        0.597008286
        0.597003878
        0.596999469
        0.596995061
        0.596990653
        0.596986245
        0.596981837
        0.596977429
        0.59697302
        0.596968612
        0.596964204
        0.596959796
        0.596955388
        0.59695098
        0.596946571
        0.596942163
        0.596937755
        0.596933347
        0.596928939];

    %% 3 ny = 0.2, original
    n3 = [1
        0.99975
        0.99899
        0.99766
        0.99568
        0.99287
        0.98899
        0.98366
        0.97627
        0.96592
        0.95133
        0.93119
        0.90502
        0.87432
        0.84201
        0.81074
        0.78202
        0.75644
        0.73402
        0.71454
        0.69786
        0.6503
        0.62361
        0.60815
        0.59892
        0.59326
        0.593249347
        0.593238694
        0.593228041
        0.593217388
        0.593206735
        0.593196082
        0.593185429
        0.593174776
        0.593164122
        0.593153469
        0.593142816
        0.593132163
        0.59312151
        0.593110857
        0.593100204
        0.593089551
        0.593078898
        0.593068245
        0.593057592
        0.593046939
        0.593036286
        0.593025633
        0.59301498
        0.593004327
        0.592993673
        0.59298302
        0.592972367
        0.592961714
        0.592951061
        0.592940408
        0.592929755
        0.592919102];

    %% 4 ny = 0.25, original
    n4 = [1
        0.99961
        0.99843
        0.99638
        0.99333
        0.98909
        0.98337
        0.97572
        0.96559
        0.9522
        0.93479
        0.91288
        0.88681
        0.858
        0.82841
        0.79982
        0.77332
        0.74943
        0.72826
        0.70967
        0.69344
        0.64712
        0.62048
        0.60479
        0.59526
        0.58932
        0.589304
        0.589288
        0.589272
        0.589256
        0.58924
        0.589224
        0.589208
        0.589192
        0.589176
        0.58916
        0.589144
        0.589128
        0.589112
        0.589096
        0.58908
        0.589064
        0.589048
        0.589032
        0.589016
        0.589
        0.588984
        0.588968
        0.588952
        0.588936
        0.58892
        0.588904
        0.588888
        0.588872
        0.588856
        0.58884
        0.588824
        0.588808];

    %% 5 ny = 0.3, original
    n5 = [1
        0.99944
        0.99774
        0.99482
        0.99054
        0.98466
        0.97691
        0.96688
        0.9541
        0.9381
        0.91854
        0.89549
        0.86964
        0.84222
        0.81466
        0.78818
        0.76357
        0.74125
        0.7213
        0.70365
        0.68814
        0.64321
        0.61687
        0.60111
        0.59139
        0.58524
        0.585219429
        0.585198857
        0.585178286
        0.585157714
        0.585137143
        0.585116571
        0.585096
        0.585075429
        0.585054857
        0.585034286
        0.585013714
        0.584993143
        0.584972571
        0.584952
        0.584931429
        0.584910857
        0.584890286
        0.584869714
        0.584849143
        0.584828571
        0.584808
        0.584787429
        0.584766857
        0.584746286
        0.584725714
        0.584705143
        0.584684571
        0.584664
        0.584643429
        0.584622857
        0.584602286
        0.584581714];

    %% 6 ny = 0.35, original, Al 6061-T6
    n6 = [1
        0.99924
        0.99694
        0.99302
        0.98732
        0.97967
        0.96979
        0.95739
        0.94218
        0.92397
        0.90277
        0.87899
        0.85341
        0.82709
        0.8011
        0.77632
        0.7533
        0.73236
        0.71355
        0.69682
        0.68203
        0.63869
        0.61284
        0.59713
        0.58731
        0.58101
        0.580985551
        0.580961102
        0.580936653
        0.580912204
        0.580887755
        0.580863306
        0.580838857
        0.580814408
        0.580789959
        0.58076551
        0.580741061
        0.580716612
        0.580692163
        0.580667714
        0.580643265
        0.580618816
        0.580594367
        0.580569918
        0.580545469
        0.58052102
        0.580496571
        0.580472122
        0.580447673
        0.580423224
        0.580398776
        0.580374327
        0.580349878
        0.580325429
        0.58030098
        0.580276531
        0.580252082
        0.580227633];

    %% 7 ny = 0.4, original
    n7 = [1
        0.99901
        0.99602
        0.99097
        0.98373
        0.97418
        0.96214
        0.94747
        0.93007
        0.91001
        0.88758
        0.86333
        0.83806
        0.81265
        0.78792
        0.76452
        0.74284
        0.7231
        0.70532
        0.68946
        0.67537
        0.63368
        0.60844
        0.59289
        0.58304
        0.57664
        0.576612306
        0.576584612
        0.576556918
        0.576529224
        0.576501531
        0.576473837
        0.576446143
        0.576418449
        0.576390755
        0.576363061
        0.576335367
        0.576307673
        0.57627998
        0.576252286
        0.576224592
        0.576196898
        0.576169204
        0.57614151
        0.576113816
        0.576086122
        0.576058429
        0.576030735
        0.576003041
        0.575975347
        0.575947653
        0.575919959
        0.575892265
        0.575864571
        0.575836878
        0.575809184
        0.57578149
        0.575753796];

    %% 8 ny = 0.34, interpolated
    n8 = [1
        0.99928
        0.9971
        0.99338
        0.987964
        0.980668
        0.971214
        0.959288
        0.944564
        0.926796
        0.905924
        0.88229
        0.856656
        0.830116
        0.803812
        0.778692
        0.755354
        0.734138
        0.7151
        0.698186
        0.683252
        0.639594
        0.613646
        0.597926
        0.588126
        0.581856
        0.581832327
        0.581808653
        0.58178498
        0.581761306
        0.581737633
        0.581713959
        0.581690286
        0.581666612
        0.581642939
        0.581619265
        0.581595592
        0.581571918
        0.581548245
        0.581524571
        0.581500898
        0.581477224
        0.581453551
        0.581429878
        0.581406204
        0.581382531
        0.581358857
        0.581335184
        0.58131151
        0.581287837
        0.581264163
        0.58124049
        0.581216816
        0.581193143
        0.581169469
        0.581145796
        0.581122122
        0.581098449];

    %% 9 ny = 0.334, interpolated, Aluminium
    n9 = [1
        0.999304
        0.997196
        0.993596
        0.9883504
        0.9812668
        0.9720684
        0.9604268
        0.9459944
        0.9284916
        0.9078164
        0.88427
        0.8586036
        0.8319316
        0.8054392
        0.7801152
        0.7565864
        0.7352048
        0.71603
        0.6990056
        0.6839852
        0.6401364
        0.6141296
        0.5984036
        0.5886156
        0.5823636
        0.582340392
        0.582317184
        0.582293976
        0.582270767
        0.582247559
        0.582224351
        0.582201143
        0.582177935
        0.582154727
        0.582131518
        0.58210831
        0.582085102
        0.582061894
        0.582038686
        0.582015478
        0.581992269
        0.581969061
        0.581945853
        0.581922645
        0.581899437
        0.581876229
        0.58185302
        0.581829812
        0.581806604
        0.581783396
        0.581760188
        0.58173698
        0.581713771
        0.581690563
        0.581667355
        0.581644147
        0.581620939];

    %% 10 ny = 0.32, interpolated, Al 2024-T4
    n10 = [1
        0.99932
        0.99726
        0.99374
        0.988608
        0.981666
        0.972638
        0.961186
        0.946948
        0.929622
        0.909078
        0.88559
        0.859902
        0.833142
        0.806524
        0.781064
        0.757408
        0.735916
        0.71665
        0.699552
        0.684474
        0.640498
        0.614452
        0.598722
        0.588942
        0.582702
        0.582679102
        0.582656204
        0.582633306
        0.582610408
        0.58258751
        0.582564612
        0.582541714
        0.582518816
        0.582495918
        0.58247302
        0.582450122
        0.582427224
        0.582404327
        0.582381429
        0.582358531
        0.582335633
        0.582312735
        0.582289837
        0.582266939
        0.582244041
        0.582221143
        0.582198245
        0.582175347
        0.582152449
        0.582129551
        0.582106653
        0.582083755
        0.582060857
        0.582037959
        0.582015061
        0.581992163
        0.581969265];

    %% 11 ny = 0.33, interpolated, Al 7075-T6
    n11 = [1
        0.99932
        0.99726
        0.99374
        0.988608
        0.981666
        0.972638
        0.961186
        0.946948
        0.929622
        0.909078
        0.88559
        0.859902
        0.833142
        0.806524
        0.781064
        0.757408
        0.735916
        0.71665
        0.699552
        0.684474
        0.640498
        0.614452
        0.598722
        0.588942
        0.582702
        0.582679102
        0.582656204
        0.582633306
        0.582610408
        0.58258751
        0.582564612
        0.582541714
        0.582518816
        0.582495918
        0.58247302
        0.582450122
        0.582427224
        0.582404327
        0.582381429
        0.582358531
        0.582335633
        0.582312735
        0.582289837
        0.582266939
        0.582244041
        0.582221143
        0.582198245
        0.582175347
        0.582152449
        0.582129551
        0.582106653
        0.582083755
        0.582060857
        0.582037959
        0.582015061
        0.581992163
        0.581969265];

    %% 12 ny = 0.342, interpolated, Titan Grade 5
    n12 = [1
        0.999272
        0.997068
        0.993308
        0.9878352
        0.9804684
        0.9709292
        0.9589084
        0.9440872
        0.9262308
        0.9052932
        0.88163
        0.8560068
        0.8295108
        0.8032696
        0.7782176
        0.7549432
        0.7337824
        0.71479
        0.6979128
        0.6830076
        0.6394132
        0.6134848
        0.5977668
        0.5879628
        0.5816868
        0.581662971
        0.581639143
        0.581615314
        0.581591486
        0.581567657
        0.581543829
        0.58152
        0.581496171
        0.581472343
        0.581448514
        0.581424686
        0.581400857
        0.581377029
        0.5813532
        0.581329371
        0.581305543
        0.581281714
        0.581257886
        0.581234057
        0.581210229
        0.5811864
        0.581162571
        0.581138743
        0.581114914
        0.581091086
        0.581067257
        0.581043429
        0.5810196
        0.580995771
        0.580971943
        0.580948114
        0.580924286];

    %% Dlambdaint

    Dlambdaint = [0
        0.05
        0.1
        0.15
        0.2
        0.25
        0.3
        0.35
        0.4
        0.45
        0.5
        0.55
        0.6
        0.65
        0.7
        0.75
        0.8
        0.85
        0.9
        0.95
        1
        1.2
        1.4
        1.6
        1.8
        2
        2.2
        2.4
        2.6
        2.8
        3
        3.2
        3.4
        3.6
        3.8
        4
        4.2
        4.4
        4.6
        4.8
        5
        5.2
        5.4
        5.6
        5.8
        6
        6.2
        6.4
        6.6
        6.8
        7
        7.2
        7.4
        7.6
        7.8
        8
        8.2
        8.4];

    %% CombinedMatrix
    PCdata = [n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12];
    % cell with meta info
    % N, ny, origin, name
    PCinfo = {1,'nu = 0.1','original','';...
        2,'nu = 0.15','original','';...
        3,'nu = 0.2','original','';...
        4,'nu = 0.25','original','';...
        5,'nu = 0.3','original','';...
        6,'nu = 0.35','original','Al 6061-T6';...
        7,'nu = 0.4','original','';...
        8,'nu = 0.34','interpolated','';...
        9,'nu = 0.334','interpolated','Aluminium';...
        10,'nu = 0.32','interpolated','Al 2024-T4';...
        11,'nu = 0.33','interpolated','Al 7075-T6';...
        12,'nu = 0.342','interpolated','Titan Grade 5'};
    PCinfoString = {'01 - nu = 0.1 - original';...
        '02 - nu = 0.15 - original';...
        '03 - nu = 0.2 - original';...
        '04 - nu = 0.25 - original';...
        '05 - nu = 0.3 - original';...
        '06 - nu = 0.35 - original - Al 6061-T6';...
        '07 - nu = 0.4 - original';...
        '08 - nu = 0.34 - interpolated';...
        '09 - nu = 0.334 - interpolated - Aluminium';...
        '10 - nu = 0.32 - interpolated - Al 2024-T4';...
        '11 - nu = 0.33 - interpolated - Al 7075-T6';...
        '12 - nu = 0.342 - interpolated - Titan Grade 5'};
    nu = [0.1,0.15,0.2,0.25,0.3,0.35,0.40,0.34,0.334,0.32,0.33,0.342];
    nu0 = [0.1,0.15,0.2,0.25,0.3,0.35,0.40];
    N = 12;

    %% save stuff
    save(fullfile(RESpath,'pc_data.mat'),'nu','PCinfo','PCinfoString','PCdata','N','nu0','Dlambdaint')
    status = 1;
catch
    status = 0;
end

end