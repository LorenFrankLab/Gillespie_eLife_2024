%% Neurofeedback: comparisons between conditioned and control animals

animals = {'jaq','roquefort','despereaux','montague','remy','gus','bernard','fievel'}; 

epochfilter{1} = ['isequal($cond_phase,''plateau'') & isequal($environment,''goal'') '];  %cond rats
epochfilter{2} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 '];  % for control rats
%epochfilter{4} = ['$ripthresh==0 & (isequal($environment,''goal_nodelay'')) & $forageassist==0 '];  % for control rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

%args: appendindex (0/1), ripthresh (default 2),
% includelockouts (1/0/-1 include trials with lockouts after rw success/-2 lockouts only/2 outersuccess only) 
% excltrigger: exclude trigger event
% excluderwstart: amount (in seconds) to exclude from beginning of rw phase (trials shorter than exclude amount will be dropped)
% excludepostrwstart: amount (in seconds) to exclude from beginning of POSTrw phase (trials shorter than exclude amount will be dropped)
f = setfilterfunction(f, 'dfa_ripquantpertrial_allphase_NF', {'ca1rippleskons','trials','pos'}, 'excltrigger',1);
f = runfilter(f);

%save('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats_excltrig.mat','f','-v7.3')
load('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats_excltrig.mat','f')

animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols


%% PART 1 plot median rate at rw, TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type>=1))./cellfun(@(x) x.duration,rwdata(type>=1));
        waitrates{a} = riprates{a};
        labels_rip{a} = [zeros(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1));
        waitrates{a} = cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2));
        labels_rip{a} = [ones(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = [ones(length(waitrates{a}),1),a+zeros(length(waitrates{a}),1)];
    end  
end
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[1 20],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate pre-reward, EXCLtrig, plateau');  ylim([0 2]);

%% PART 2 plot  SIZE & DURATION at rw, ripwise comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripsizes{a} = cell2mat(cellfun(@(x) x.size,rwdata(type>=1),'un',0));
        waitsizes{a} = ripsizes{a};
        ripdurs{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type>=1),'un',0));
        waitdurs{a} = ripdurs{a};        
        labels_rip{a} = [zeros(length(ripsizes{a}),1),a+zeros(length(ripsizes{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=1;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripsizes{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==1),'un',0));
        waitsizes{a} = cell2mat(cellfun(@(x) x.size,rwdata(type==2),'un',0));
        ripdurs{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==1),'un',0));
        waitdurs{a} = cell2mat(cellfun(@(x) x.riplengths,rwdata(type==2),'un',0));
        labels_rip{a} = [ones(length(ripsizes{a}),1),a+zeros(length(ripsizes{a}),1)];
        labels_wait{a} = [ones(length(waitsizes{a}),1),a+zeros(length(waitsizes{a}),1)];
    end  
end
figure; subplot(1,2,1); hold on; allrat_lmeplot(ripsizes,waitsizes,labels_rip,labels_wait,'spacer',[0 2],'grouped',1)
ylabel('SWR size (Hz)');title('Ripsizes, pre-reward EXCLtrig,n=rips');  ylim([0 20]);
subplot(1,2,2); hold on; allrat_lmeplot(ripdurs,waitdurs,labels_rip,labels_wait,'spacer',[0 40],'grouped',1)
ylabel('SWR duration (s)');title('Riplengths, pre-reward, EXCLtrig,n=rips'); ylim([0 .5]);

%% PART 3 plot latency to detection (manipulation cohort only)
ratoffset = [75, 100, 50, 50]/1000;
when = 1;
f1=figure(); hold on

for a = 5:length(animals) 
    %of the rips that co-occur with an offline-detected rip, how long till trigger?
    tmp = cell2mat(arrayfun(@(x) x.removedrips(:,4)',f(a).output{1},'UniformOutput',0));
    latency{a} = ratoffset(a-4) + tmp(tmp>0) % zero = didn't have a matching rip
     boxplot(latency{a},'Positions',a-4,'Symbol','','Width',.2,'Color',animcol(a,:))
     text(a-4,0+a/20,sprintf('n=%dtrigs',length(latency{a})));
    xlim([.5 4.5]); ylabel('latency (s) '); title('Time btwn offline ripstart and sound/rew'); ylim([0 .5])
end

%% PART 4 plot rate binned by size prevalence plots (epochwise) - NF rats only
clearvars -except f animals animcol 
figure; set(gcf,'Position',[0 0 800 950])
edges = [2:1:30];
centers = edges(2:end)-.5;
for a = 5:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); 
    ratio{a} = zeros(length(rwdata),length(centers));
    for e = 1:length(rwdata)  %generate 1 curve per ep
        type = cellfun(@(x) x.type,rwdata{e});
        ripsizes = cell2mat(cellfun(@(x) x.size',rwdata{e}(type==1),'un',0));
        waitsizes = cell2mat(cellfun(@(x) x.size',rwdata{e}(type==2),'un',0));
        ripduration = sum(cellfun(@(x) x.duration,rwdata{e}(type==1)));
        waitduration = sum(cellfun(@(x) x.duration,rwdata{e}(type==2)));
        ripprev{a}(e,:) = histcounts(ripsizes,edges)./ripduration;
        waitprev{a}(e,:) = histcounts(waitsizes,edges)./waitduration;
        ripvalbins{a}(e,:) = ripprev{a}(e,:)>0;
        waitvalbins{a}(e,:) = waitprev{a}(e,:)>0;
        bothvalbins{a}(e,:) = ripvalbins{a}(e,:) & waitvalbins{a}(e,:);
        ratio{a}(e,find(bothvalbins{a}(e,:))) = ripprev{a}(e,find(bothvalbins{a}(e,:)))./waitprev{a}(e,find(bothvalbins{a}(e,:)));
    end
    subplot(3,2,a-4); hold on;
    [valbins,means,sems] = binnedsemcurve(ripprev{a},ripvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',animcol(a,:),'Linewidth',.5);
    [valbins,means,sems] = binnedsemcurve(waitprev{a},waitvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',animcol(a+4,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',animcol(a+4,:),'Linewidth',.5);
    set(gca,'YScale','log'); ylim([.001 .2]); xlim([2 14]); title([animals{a} ' prevalence EXCL triggers']); ylabel('Rate (Hz)'); xlabel('Size (sd)');
    subplot(3,2,5); hold on
    [valbins,means,sems] = binnedsemcurve(ratio{a},bothvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',animcol(a,:),'Linewidth',.5);
    set(gca,'YScale','log'); ylim([.2 5]);xlim([2 14]); title('fold change R/W, EXCL triggers'); ylabel('Fold change'); xlabel('Size (sd)');
    plot([2 14],[1 1],'k:')
end



%% rw+postrw riprate curves by timebin, centered at trig/rwend
clearvars -except f animals animcol
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255; 
timebin = .5;
timeedges = [-20:timebin:20]; %22:2:60
centers = timeedges(2:end);
toHz = 1/timebin;
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[72 391 1815 443]); hold on;
for a = 1:length(animals)
    if a<=4
        when=2;
    else
        when=1;
    end
    rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
   for e = 1:length(postrwdata)
        rwtrialnum = cellfun(@(x) x.trialnum,rwdata{e});
        postrwtrialnum = cellfun(@(x) x.trialnum,postrwdata{e});
        [~,rw_ind,postrw_ind] = intersect(rwtrialnum,postrwtrialnum);  % line up trials with matching trialnum
        
        combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata{e}(rw_ind),postrwdata{e}(postrw_ind),'un',0);
    epripmat{a}{e} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
    epbinclude{a}{e} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata{e}(rw_ind),postrwdata{e}(postrw_ind),'UniformOutput',0));
        eptype{a}{e} = cellfun(@(x) x.type,rwdata{e}(rw_ind));
   end
    ripmat{a} = vertcat(epripmat{a}{:}); binclude{a} = vertcat(epbinclude{a}{:}); type{a} = vertcat(eptype{a}{:}); 
     if a<=4
        for b = 1:length(centers)
            rip(a,b) = toHz*(mean(ripmat{a}(type{a}>=1 & binclude{a}(:,b),b)));
            rip_sem(a,b) = toHz*(std(ripmat{a}(type{a}>=1 & binclude{a}(:,b),b))/sqrt(sum(type{a}>=1 & binclude{a}(:,b))));
        end
        valbins_rip(a,:) = sum(binclude{a}(type{a}>=1,:))>100;
        subplot(2,4,a); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
        plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
        plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1); ylim([0 1.5]); xlim([-20 20])
    else
        for b = 1:length(centers)
            rip(a,b) = toHz*(mean(ripmat{a}(type{a}==1 & binclude{a}(:,b),b)));
            rip_sem(a,b) = toHz*(std(ripmat{a}(type{a}==1 & binclude{a}(:,b),b))/sqrt(sum(type{a}==1 & binclude{a}(:,b))));
            wait(a,b) = toHz*(mean(ripmat{a}(type{a}==2 & binclude{a}(:,b),b)));
            wait_sem(a,b) = toHz*(std(ripmat{a}(type{a}==2 & binclude{a}(:,b),b))/sqrt(sum(type{a}==2 & binclude{a}(:,b))));
        end
        valbins_rip(a,:) = sum(binclude{a}(type{a}==1,:))>100;
        valbins_wait(a,:) = sum(binclude{a}(type{a}==2,:))>100;
        
        subplot(2,4,a); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)'); hold on;
        plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
        plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1)
        plot([centers(valbins_wait(a,:)); centers(valbins_wait(a,:))], [wait(a,valbins_wait(a,:))-wait_sem(a,valbins_wait(a,:)); wait(a,valbins_wait(a,:))+wait_sem(a,valbins_wait(a,:))],'Color',animcol(a+4,:),'Linewidth',.5);
        plot(centers(valbins_wait(a,:)),wait(a,valbins_wait(a,:)),'Color',animcol(a+4,:),'Linewidth',1)
        ylim([0 1.5]); xlim([-20 20])
    end
end

%% calculate online rip detection false pos/neg rates (epochwise) (manipulation cohort only)
% only use the second half of trials from each epoch, when the
% threshold has been fully raised
clearvars -except f animals animcol
%animcol = [ 254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
when = 1;
f1=figure(); f2=figure(); f3=figure();

for a = 5:length(animals) 
    homedata = arrayfun(@(x) x.home',f(a).output{when},'UniformOutput',0); 
    rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trialphases
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    outerdata = arrayfun(@(x) x.outer',f(a).output{when},'UniformOutput',0); 
    lockdata = arrayfun(@(x) x.lock',f(a).output{when},'UniformOutput',0); 
    
    %how many trigs didn't co-occur with an offline-detected rip?
    trigs = arrayfun(@(x) x.removedrips,f(a).output{1},'UniformOutput',0);
    trigs = cellfun(@(x) (x(x(:,2)>=ceil(max(x(:,2))/2),:)),trigs,'un',0);
    fp{a} = cellfun(@(x) (sum(x(:,3)<=0)/size(x,1)),trigs);
    
    % how many rips of mean (min?) trig size or larger did not trigger? 
    for e = 1:length(homedata)
        mid = ceil(max(cellfun(@(x) (x.trialnum),homedata{e}))/2);
        homesizes = cell2mat(cellfun(@(x) (x.size),homedata{e}(cellfun(@(x) (x.trialnum),homedata{e})>=mid),'un',0));
        rwsizes = cell2mat(cellfun(@(x) (x.size),rwdata{e}(cellfun(@(x) (x.trialnum),rwdata{e})>=mid),'un',0));
        postrwsizes = cell2mat(cellfun(@(x) (x.size),postrwdata{e}(cellfun(@(x) (x.trialnum),postrwdata{e})>=mid),'un',0));
        outersizes = cell2mat(cellfun(@(x) (x.size),outerdata{e}(cellfun(@(x) (x.trialnum),outerdata{e})>=mid),'un',0));
        locksizes = cell2mat(cellfun(@(x) (x.size),lockdata{e}(cellfun(@(x) (x.trialnum),lockdata{e})>=mid),'un',0));
        allsizes = [homesizes;rwsizes;postrwsizes;outersizes;locksizes];
        trigmin{a}(e) = min(trigs{e}(trigs{e}(:,3)>0,3));
        %trigmin = prctile(trigs{e}(trigs{e}(:,3)>0,3),5);
        fn{a}(e) = sum(allsizes>trigmin{a}(e))/(sum(allsizes>trigmin{a}(e))+size(trigs{e},1));
    end
    %alltrigs = vertcat(trigs{:});
    figure(f1); hold on
    %boxplot(alltrigs(alltrigs(:,3)>0,3),'Positions',a,'Width',.2,'Color',animcol(a,:))
    boxplot(trigmin{a},'Positions',a-4,'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('size (offline sd)'); title('Trigger  min/ep, 2nd half of eps only'); ylim([0 35])

    figure(f2); hold on 
    boxplot(fp{a},'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('Fraction'); title('False positives'); ylim([0 1])
    figure(f3); hold on;
    boxplot(fn{a},'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('Fraction'); title('False negatives'); ylim([0 1])

end

