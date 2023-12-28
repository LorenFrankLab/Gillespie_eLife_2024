%% Neurofeedback: mua rate inside and outside of rips at various trial phases

animals = {'jaq','roquefort','despereaux','montague','remy','gus','bernard','fievel',}; 

epochfilter{1} = ['isequal($cond_phase,''plateau'') & isequal($environment,''goal'') '];  %cond rats
epochfilter{2} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 '];  % for control rats
%epochfilter{3} = ['$ripthresh==0 & (isequal($environment,''goal_nodelay'')) & $forageassist==0 '];  % for control rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

%args: appendindex (0/1), ripthresh (default 2),
% includelockouts (1/0/-1 include trials with lockouts after rw success/-2 lockouts only/2 outersuccess only) 
% excltrigger: exclude trigger event
% excludeRWstart: amount (in sec) to exclude from start of RW time
f = setfilterfunction(f, 'dfa_muarate_NF', {'marks','tetinfo','ca1rippleskons','trials'}, 'excltrigger',1,'excludeRWstart',0);
f = runfilter(f);

%save('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats_muarateExcltrig.mat','f','-v7.3')
%load('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats_muarateExcltrig.mat','f')
%% style
set(0,'defaultAxesFontSize',14)
set(0,'defaultLineLineWidth',1)

animcol = [27 92 41; 25 123 100; 33 159 169; 123 225 191; 83 69 172; 115 101 199; 150 139 222; 190 182 240]./255;  %ctrlcols

%% compare mua rate during rips at NF vs delay port pre-reward (ripwise)
% original unit is spikes/2ms timebin so x500 to get to hz 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type>=1),'un',0));
        waitmua{a} = ripmua{a};    
        ripsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type>=1),'un',0));
        waitsize{a} = ripsize{a};    
        riplength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type>=1),'un',0));
        waitlength{a} = riplength{a};    
        labels_rip{a} = [zeros(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type==1),'un',0));
        waitmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type==2),'un',0));
        ripsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==1),'un',0));
        waitsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==2),'un',0));
        riplength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==1),'un',0));
        waitlength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==2),'un',0));    
        labels_rip{a} = [ones(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = [ones(length(waitmua{a}),1),a+zeros(length(waitmua{a}),1)];
    end  
end
figure; subplot(2,2,1); hold on; allrat_lmeplot(ripmua,waitmua,labels_rip,labels_wait,'spacer',[0 .01])
ylabel('mua rate (Hz/tet)');title('Muarate per rip EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 800]);
subplot(2,2,2); hold on; allrat_lmeplot(ripsize,waitsize,labels_rip,labels_wait,'spacer',[0 1])
ylabel('SWR size (offline sd)');title('Size per rip EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 20]);
subplot(2,2,3); hold on; allrat_lmeplot(riplength,waitlength,labels_rip,labels_wait,'spacer',[0 20])
ylabel('SWR length (s)');title('Length per rip EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 .5]);

%% compare mua rate during rips at NF vs delay port pre-reward (trialwise)
% original unit is spikes/2ms timebin so x500 to get to hz 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) mean(x.ripmua),rwdata(type>=1),'un',0));
        waitmua{a} = ripmua{a};    
        ripsize{a} = cell2mat(cellfun(@(x) mean(x.size),rwdata(type>=1),'un',0));
        waitsize{a} = ripsize{a};    
        riplength{a} = cell2mat(cellfun(@(x) mean(x.riplengths),rwdata(type>=1),'un',0));
        waitlength{a} = riplength{a};    
        labels_rip{a} = [zeros(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) mean(x.ripmua),rwdata(type==1),'un',0));
        waitmua{a} = cell2mat(cellfun(@(x) mean(x.ripmua),rwdata(type==2),'un',0));
        ripsize{a} = cell2mat(cellfun(@(x) mean(x.size),rwdata(type==1),'un',0));
        waitsize{a} = cell2mat(cellfun(@(x) mean(x.size),rwdata(type==2),'un',0));
        riplength{a} = cell2mat(cellfun(@(x) mean(x.riplengths),rwdata(type==1),'un',0));
        waitlength{a} = cell2mat(cellfun(@(x) mean(x.riplengths),rwdata(type==2),'un',0));    
        labels_rip{a} = [ones(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = [ones(length(waitmua{a}),1),a+zeros(length(waitmua{a}),1)];
    end  
end
figure; subplot(2,2,1); hold on; allrat_lmeplot(ripmua,waitmua,labels_rip,labels_wait,'spacer',[0 .01])
ylabel('mua rate (Hz/tet)');title('Muarate per trial EXCLtrig,'); xlim([.5 9.5]); ylim([0 800]);
subplot(2,2,2); hold on; allrat_lmeplot(ripsize,waitsize,labels_rip,labels_wait,'spacer',[0 1])
ylabel('SWR size (offline sd)');title('Size per trial EXCLtrig'); xlim([.5 9.5]); ylim([0 20]);
subplot(2,2,3); hold on; allrat_lmeplot(riplength,waitlength,labels_rip,labels_wait,'spacer',[0 20])
ylabel('SWR length (s)');title('Length per trial EXCLtrig'); xlim([.5 9.5]); ylim([0 .5]);

%% compare mua rate during rips at NF vs delay port POST-reward (ripwise)
% original unit is spikes/2ms timebin so x500 to get to hz 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type>=1),'un',0));
        waitmua{a} = ripmua{a};    
        ripsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type>=1),'un',0));
        waitsize{a} = ripsize{a};    
        riplength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type>=1),'un',0));
        waitlength{a} = riplength{a};    
        labels_rip{a} = [zeros(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type==1),'un',0));
        waitmua{a} = cell2mat(cellfun(@(x) x.ripmua,rwdata(type==2),'un',0));
        ripsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==1),'un',0));
        waitsize{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==2),'un',0));
        riplength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==1),'un',0));
        waitlength{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==2),'un',0));    
        labels_rip{a} = [ones(length(ripmua{a}),1),a+zeros(length(ripmua{a}),1)];
        labels_wait{a} = [ones(length(waitmua{a}),1),a+zeros(length(waitmua{a}),1)];
    end  
end
figure; subplot(2,2,1); hold on; allrat_lmeplot(ripmua,waitmua,labels_rip,labels_wait,'spacer',[0 .01])
ylabel('mua rate (Hz/tet)');title('Muarate per rip post-RW EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 800]);
subplot(2,2,2); hold on; allrat_lmeplot(ripsize,waitsize,labels_rip,labels_wait,'spacer',[0 .5])
ylabel('SWR size (offline sd)');title('Size per rip postRW EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 20]);
subplot(2,2,3); hold on; allrat_lmeplot(riplength,waitlength,labels_rip,labels_wait,'spacer',[0 20])
ylabel('SWR length (s)');title('Length per rip post-RW EXCLtrig,n=rips'); xlim([.5 9.5]); ylim([0 .5]);

%% compare mua rate *outside* of rips pre vs post reward 
% original unit is spikes/2ms timebin so x500 to get to hz 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripimmomua{a} = cell2mat(cellfun(@(x) x.immomua_norips,rwdata(type>=1),'un',0));
        waitimmomua{a} = ripimmomua{a};        
        labels_rip{a} = [zeros(length(ripimmomua{a}),1),a+zeros(length(ripimmomua{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripimmomua{a} = cell2mat(cellfun(@(x) x.immomua_norips,rwdata(type==1),'un',0));
        waitimmomua{a} = cell2mat(cellfun(@(x) x.immomua_norips,rwdata(type==2),'un',0));
        labels_rip{a} = [ones(length(ripimmomua{a}),1),a+zeros(length(ripimmomua{a}),1)];
        labels_wait{a} = [ones(length(waitimmomua{a}),1),a+zeros(length(waitimmomua{a}),1)];
    end  
end
figure;  hold on; allrat_lmeplot(ripimmomua,waitimmomua,labels_rip,labels_wait,'spacer',[0 .1])
ylabel('muarate (Hz)');title('Mua outside of rips, pre-reward EXCLtrig'); xlim([.5 9.5]); ylim([0 80]);

