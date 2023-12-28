%% Neurofeedback: main ripple quantifications; pre vs plateau, EXCLUDING TRIGGER 
% Figure 1 & SupFig 1

animals = {'remy','gus','bernard','fievel'}; %,'gerald'};,'jaq','roquefort','despereaux','montague'

% this onlu makes sense to do in plateau phase
epochfilter{1} = ['isequal($cond_phase,''plateau'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

%args: appendindex (0/1), trialphase ('rw'/'home'/'rw'/'postrw'/'outer'), ripthresh (default 2),
% includelockouts (1/0/-1 include trials with lockouts after rw success/-2 lockouts only/2 outersuccess only) 
% excltrigger: remove all trigger events 
% removetrigWtrials (1/0)
f = setfilterfunction(f, 'dfa_ripquantpertrial_allphase', {'ca1rippleskons','trials'}, 'excltrigger',1);
f = runfilter(f);

%% style
set(0,'defaultAxesFontSize',14)
set(0,'defaultLineLineWidth',1)

ripcols = [254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
waitcols = [148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;

%% plot median rate and count at rw, post=NF, excluding trigger, trialwise
clearvars -except f animals ripcols waitcols
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,rwdata);
    
    riprates{a} = cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1));
    waitrates{a} = cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2));
    subplot(1,2,1); hold on;
    boxplot(riprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); %ylabel('SWR rate (Hz)');
    p = ranksum(riprates{a},waitrates{a});
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(riprates{a}),length(waitrates{a})))
    title('post-NF, EXCL trigger'); ylim([0 1.5]); %ylabel('Riprate (Hz)')
    
    subplot(1,2,2); hold on;
    ripnums{a} = cellfun(@(x) length(x.size),rwdata(type==1));
    waitnums{a} = cellfun(@(x) length(x.size),rwdata(type==2));
    boxplot(ripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); %ylabel('SWR rate (Hz)');
    p = ranksum(ripnums{a},waitnums{a});
    text(a,10+a,sprintf('p=%d\nn=%d,%d trials',p,length(ripnums{a}),length(waitnums{a})))
    title('post-NF, EXCL trigger'); ylim([0 20]);% ylabel('SWR count')
end

%% plot median SIZE at rw, post-NF, excluding trigger, trialwise & epwise 
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,rwdata{e});
        ripsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.size),rwdata{e}(type==1)));
        waitsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.size),rwdata{e}(type==2)));
    end
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,rwdata);
    ripsizes{a} = cellfun(@(x) mean(x.size),rwdata(type==1));
    waitsizes{a} = cellfun(@(x) mean(x.size),rwdata(type==2));
    subplot(1,2,1); hold on;
    boxplot(ripsizes{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    p = ranksum(ripsizes{a},waitsizes{a});
    text(a,8+a,sprintf('p=%d\nn=%d,%d trials',p,length(ripsizes{a}),length(waitsizes{a})))
   subplot(1,2,2); hold on;
    boxplot(ripsizes_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    [h,p] = ttest(ripsizes_ep{a},waitsizes_ep{a});
    text(a,1.3+a/10,sprintf('tp=%.04f\nn=%deps',p,length(waitsizes_ep{a})))
end
title('post-NF, EXCL trigger'); ylabel('Ripsize (sd)')
%% plot median riplength at rw, post-NF, excluding trigger, trialwise & epwise 
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,rwdata{e});
        ripsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.riplengths),rwdata{e}(type==1)));
        waitsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.riplengths),rwdata{e}(type==2)));
    end
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,rwdata);
    ripsizes{a} = cellfun(@(x) mean(x.riplengths),rwdata(type==1));
    waitsizes{a} = cellfun(@(x) mean(x.riplengths),rwdata(type==2));
    subplot(1,2,1); hold on;
    boxplot(ripsizes{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 .5]); 
    p = ranksum(ripsizes{a},waitsizes{a});
    text(a,a/10,sprintf('p=%d\nn=%d,%d trials',p,length(ripsizes{a}),length(waitsizes{a})))
   subplot(1,2,2); hold on;
    boxplot(ripsizes_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 .5]); 
    [h,p] = ttest(ripsizes_ep{a},waitsizes_ep{a});
    text(a,a/10,sprintf('tp=%.04f\nn=%deps',p,length(waitsizes_ep{a})))
end
title('post-NF, EXCL trigger'); ylabel('Riplength (s)')

%% plot fraction of rip trials with a trigger event excluded
clearvars -except f animals
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[187 1 1374 973]);hold on;
for a = 1:length(animals)
    excldata = arrayfun(@(x) x.hasexcluded, f(a).output{1},'un',0); % stack data from all trials
    excldata = vertcat(excldata{:});
    boxplot(excldata(:,1)./excldata(:,2),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
    boxplot(excldata(:,3)./excldata(:,4),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
    xlim([.5 4.5]); 
end
title('fraction of rw times with above thresh event'); ylim([0 1])

%% plot rate binned by size prevalence plots (epochwise)
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[0 0 800 950])
edges = [2:1:30];
centers = edges(2:end)-.5;
for a = 1:length(animals)
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
    subplot(3,2,a); hold on;
    [valbins,means,sems] = binnedsemcurve(ripprev{a},ripvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',ripcols(a,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',ripcols(a,:),'Linewidth',.5);
    [valbins,means,sems] = binnedsemcurve(waitprev{a},waitvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',waitcols(a,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',waitcols(a,:),'Linewidth',.5);
    set(gca,'YScale','log'); ylim([.001 .2]); xlim([2 14]); title([animals{a} ' prevalence EXCL triggers']); ylabel('Rate (Hz)'); xlabel('Size (sd)');
    subplot(3,2,5); hold on
    [valbins,means,sems] = binnedsemcurve(ratio{a},bothvalbins{a},centers,5);
    plot([centers(valbins);centers(valbins)],[means(valbins)-sems(valbins);means(valbins)+sems(valbins)],'Color',ripcols(a,:),'Linewidth',.5);
    plot(centers(valbins),means(valbins),'Color',ripcols(a,:),'Linewidth',.5);
    set(gca,'YScale','log'); ylim([.2 5]);xlim([2 14]); title('fold change R/W, EXCL triggers'); ylabel('Fold change'); xlabel('Size (sd)');
    plot([2 14],[1 1],'k:')
end
    
%% calculate online rip detection false pos/neg rates (epochwise)
% only use the second half of trials from each epoch, when the
% threshold has been fully raised
clearvars -except f animals 
animcol = [ 254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
f1=figure(); f2=figure(); f3=figure();
for a = 1:length(animals)    
    homedata = arrayfun(@(x) x.home',f(a).output{1},'UniformOutput',0); 
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trialphases
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    outerdata = arrayfun(@(x) x.outer',f(a).output{1},'UniformOutput',0); 
    lockdata = arrayfun(@(x) x.lock',f(a).output{1},'UniformOutput',0); 
    
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
    boxplot(trigmin{a},'Positions',a,'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('size (offline sd)'); title('Trigger  min/ep, 2nd half of eps only'); ylim([0 35])

    figure(f2); hold on 
    boxplot(fp{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('Fraction'); title('False positives'); ylim([0 1])
    figure(f3); hold on;
    boxplot(fn{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    xlim([.5 4.5]); ylabel('Fraction'); title('False negatives'); ylim([0 1])

end

