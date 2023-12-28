 %% Neurofeedback: main analyses. Plateau phase only

animals = {'remy','gus','bernard','fievel'}; 

%epochfilter{1} = ['isequal($cond_phase,''pre'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];
%epochfilter{2} = ['isequal($cond_phase,''early'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];
%epochfilter{3} = ['isequal($cond_phase,''late'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];
epochfilter{1} = ['isequal($cond_phase,''plateau'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};

iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);
%args: appendindex (0/1), ripthresh (default 2),
% includelockouts (1/0/-1 include trials with lockouts after rw success/-2 lockouts only/2 outersuccess only) 
% excltrigger to exclude trigger event (0/1)
% removetrigWtrials (1/0)
f = setfilterfunction(f, 'dfa_ripquantpertrial_allphase', {'ca1rippleskons','trials'}, 'excltrigger',0);
f = runfilter(f);

% style
ripcols = [254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
waitcols = [148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;
set(0,'defaultLineLineWidth',1)

%% plot median rate & count at rw, TRIALWISE comparisons
clearvars -except f animals ripcols waitcols
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,rwdata);
    riprates{a} = cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1));
    waitrates{a} = cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2));
    subplot(1,2,1); hold on;
    boxplot(riprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    title('Riprate pre-reward, incltrig, plateau'); xlim([.5 4.5]); ylim([0 1.5]);
    p = ranksum(riprates{a},waitrates{a});
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(riprates{a}),length(waitrates{a})))
    
    subplot(1,2,2); hold on; title('Rip count pre-reward, incltrig, plateau')
    ripnums{a} = cellfun(@(x) length(x.size),rwdata(type==1));
    waitnums{a} = cellfun(@(x) length(x.size),rwdata(type==2));
    boxplot(ripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 25]);
    p = ranksum(ripnums{a},waitnums{a});
    text(a,20+a/5,sprintf('p=%d\nn=%d,%d trials',p,length(ripnums{a}),length(waitnums{a})))
end
ylabel('SWR count'); subplot(1,2,1);  ylabel('SWR rate (Hz)');


%% rates&counts of rips at rw,postrw,% combined, post-NF, EPOCHWISE COMPARISONS
clearvars -except f animals ripcols waitcols

rwr = figure(); hold on; postr = figure(); hold on; combr = figure(); hold on;
rwc = figure(); hold on; postc = figure(); hold on; combc = figure(); hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,rwdata{e});
        ripnums{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e}(type==1)));
        waitnums{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e}(type==2)));
        riprates{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e}(type==1))./cellfun(@(x) x.duration,rwdata{e}(type==1)));
        waitrates{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e}(type==2))./cellfun(@(x) x.duration,rwdata{e}(type==2)));
        postripnums{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e}(type==1)));
        postwaitnums{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e}(type==2)));
        postriprates{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e}(type==1))./cellfun(@(x) x.duration,postrwdata{e}(type==1)));
        postwaitrates{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e}(type==2))./cellfun(@(x) x.duration,postrwdata{e}(type==2)));
        combripnums{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e}(type==1),postrwdata{e}(type==1)));
        combwaitnums{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e}(type==2),postrwdata{e}(type==2)));
        combriprates{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e}(type==1),postrwdata{e}(type==1))./cellfun(@(x,y) x.duration+y.duration,rwdata{e}(type==1),postrwdata{e}(type==1)));
        combwaitrates{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e}(type==2),postrwdata{e}(type==2))./cellfun(@(x,y) x.duration+y.duration,rwdata{e}(type==2),postrwdata{e}(type==2)));
        numtrials{a}(e,:) = [sum(type==1),sum(type==2)];
    end
    figure(rwr);
    plot(repmat([a,a+.25],length(rwdata),1)',[riprates{a}',waitrates{a}']','Color',[.8 .8 .8])
    boxplot(riprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(riprates{a},waitrates{a}); text(a,1+a/10,sprintf('ttestp=%d\nn=%d epochs',p_t,length(rwdata)))
    title('rw rates'); xlim([.5 4.5]); ylim([0 1.5]);
    
    figure(postr);
    plot(repmat([a,a+.25],length(postrwdata),1)',[postriprates{a}',postwaitrates{a}']','Color',[.8 .8 .8])
    boxplot(postriprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(postwaitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(postriprates{a},postwaitrates{a}); text(a,1+a/10,sprintf('ttestp=%d\nn=%d epochs',p_t,length(postrwdata)))
    title('postrw rates'); xlim([.5 4.5]); ylim([0 2]);
    
    figure(combr); hold on;
    plot(repmat([a,a+.25],length(postrwdata),1)',[combriprates{a}',combwaitrates{a}']','Color',[.8 .8 .8])
    boxplot(combriprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(combwaitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(combriprates{a},combwaitrates{a}); text(a,1+a/10,sprintf('ttestp=%d\nn=%d epochs',p_t,length(postrwdata)))
    title('combined rates'); xlim([.5 4.5]); ylim([0 2]);
    figure(rwc); hold on;
    plot(repmat([a,a+.25],length(rwdata),1)',[ripnums{a}',waitnums{a}']','Color',[.8 .8 .8])
    boxplot(ripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(ripnums{a},waitnums{a}); text(a,10+a,sprintf('ttestp=%d\nn=%d epochs',p_t,length(rwdata)))
    xlim([.5 4.5]); ylim([0 15]); title('rw nums');
    
    figure(postc); hold on;
    plot(repmat([a,a+.25],length(postrwdata),1)',[postripnums{a}',postwaitnums{a}']','Color',[.8 .8 .8])
    boxplot(postripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(postwaitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(postripnums{a},postwaitnums{a}); text(a,10+a,sprintf('ttestp=%d\nn=%d epochs',p_t,length(postrwdata)))
    title('postrw nums'); xlim([.5 4.5]); ylim([0 15]);
    
    figure(combc); hold on;
    plot(repmat([a,a+.25],length(postrwdata),1)',[combripnums{a}',combwaitnums{a}']','Color',[.8 .8 .8])
    boxplot(combripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(combwaitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    [h,p_t] = ttest(combripnums{a},combwaitnums{a}); text(a,10+a,sprintf('ttestp=%d\nn=%d epochs',p_t,length(postrwdata)))
    title('combined nums'); xlim([.5 4.5]); ylim([0 15]);
end

%% plot rip rate at rw in .5s windows from start, post-NF
clearvars -except f animals ripcols waitcols
timeedges = [0:.5:40]; %22:2:60
centers = timeedges(2:end);
toHz = 1./diff(timeedges);
figure; set(gcf,'Position',[0 0 800 950]); hold on;
for a = 1:length(animals)
        rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:});
        type = cellfun(@(x) x.type,rwdata);
        ripmat1{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type==1),'UniformOutput',0));  %rip
        binclude1{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type==1),'UniformOutput',0));
        ripmat2{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type==2),'UniformOutput',0));  % wait
        binclude2{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type==2),'UniformOutput',0));
    for b = 1:length(centers)
        binavg1(a,b) = toHz(b)*(mean(ripmat1{a}(binclude1{a}(:,b),b)));
        binsem1(a,b) = toHz(b)*(std(ripmat1{a}(binclude1{a}(:,b),b))/sqrt(sum(binclude1{a}(:,b))));
        if any(type~=1)
            binavg2(a,b) = toHz(b)*(mean(ripmat2{a}(binclude2{a}(:,b),b)));
            binsem2(a,b) = toHz(b)*(std(ripmat2{a}(binclude2{a}(:,b),b))/sqrt(sum(binclude2{a}(:,b))));
        end
    end
    valbins1(a,:) = sum(binclude1{a})>100;
    valbins2(a,:) = sum(binclude2{a})>100; 
    subplot(1,2,1); title('rw riprates by rat');xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins1(a,:)); centers(valbins1(a,:))], [binavg1(a,valbins1(a,:))-binsem1(a,valbins1(a,:)); binavg1(a,valbins1(a,:))+binsem1(a,valbins1(a,:))],'Color',ripcols(a,:),'Linewidth',.5);
    plot(centers(valbins1(a,:)),binavg1(a,valbins1(a,:)),'Color',ripcols(a,:),'Linewidth',1)
    plot([centers(valbins2(a,:)); centers(valbins2(a,:))], [binavg2(a,valbins2(a,:))-binsem2(a,valbins2(a,:)); binavg2(a,valbins2(a,:))+binsem2(a,valbins2(a,:))],'Color',waitcols(a,:),'Linewidth',.5);
    plot(centers(valbins2(a,:)),binavg2(a,valbins2(a,:)),'Color',waitcols(a,:),'Linewidth',1)
    
    subplot(1,2,2); hold on;
    ratiovalbins(a,:) = valbins1(a,:) & valbins2(a,:);
    ratio = binavg1(a,ratiovalbins(a,:))./binavg2(a,ratiovalbins(a,:));   
    plot(centers(ratiovalbins(a,:)),ratio,'Color',ripcols(a,:),'Linewidth',1)
    title('NF/control');
end

% in future, switch to shaded SEM zone instead of vertical bars
% could also consider smoothing by using an overlapping window?
%h = fill([valctrs'; flipud(valctrs')], [mean(postRprev(:,postvalbins))'-std(postRprev(:,postvalbins))'/sqrt(length(animals)); flipud(mean(postRprev(:,postvalbins))'+std(postRprev(:,postvalbins))'/sqrt(length(animals)))],'g','FaceAlpha',.3);%
%set(h,'EdgeColor','none'); plot(valctrs,mean(postRprev(:,postvalbins)),'g','LineWidth',2); %set(gca,'XScale','log','YScale','log'); grid on;

%% amount of time spent at R vs W, epochwise and trialwise 
clearvars -except f animals ripcols waitcols
cols = [1 0 0; 0 0 0];
epwise = figure(); set(gcf,'Position',[187 1 1374 973]);
trialwise = figure(); set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,rwdata{e});
        ripduration_ep{a}(e) = mean(cellfun(@(x) x.duration,rwdata{e}(type==1)));
        waitduration_ep{a}(e) = mean(cellfun(@(x) x.duration,rwdata{e}(type==2)));
    end
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,rwdata);
    ripduration{a} = cellfun(@(x) x.duration,rwdata(type==1));
    waitduration{a} = cellfun(@(x) x.duration,rwdata(type==2));
    
    figure(trialwise); subplot(1,2,1); hold on;
    boxplot(ripduration{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitduration{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]);
    p = ranksum(ripduration{a},waitduration{a});
    text(a,25+a/5,sprintf('p=%.04f\nn=%d,%d trials',p,length(ripduration{a}),length(waitduration{a})))
    
    subplot(1,2,2); hold on;%figure(epwise);
    boxplot(ripduration_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitduration_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]);
    [h,p] = ttest(ripduration_ep{a},waitduration_ep{a});
    text(a,25+a/5,sprintf('tp=%.04f\nn=%deps',p,length(ripduration_ep{a})));
    
end

title('plateau, epwise'); ylim([0 30]); ylabel('Duration (s)')
subplot(1,2,1); title('plateau, trialwise'); ylim([0 30]); ylabel('Duration (s)')

%% rate  & count of rips in postrw period, post-NF
clearvars -except f animals ripcols waitcols
figure;  set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = horzcat(postrwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,postrwdata);
    riprates{a} = cellfun(@(x) length(x.size),postrwdata(type==1))./cellfun(@(x) x.duration,postrwdata(type==1));
    waitrates{a} = cellfun(@(x) length(x.size),postrwdata(type==2))./cellfun(@(x) x.duration,postrwdata(type==2));
    subplot(1,2,1); hold on;
    boxplot(riprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    title('post-reward Riprate, plateau') ; xlim([.5 4.5]); ylim([0 2]);
    p = ranksum(riprates{a},waitrates{a});
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(riprates{a}),length(waitrates{a})))
    
    subplot(1,2,2); hold on; title('post-reward Rip count, plateau')
    ripnums{a} = cellfun(@(x) length(x.size),postrwdata(type==1));
    waitnums{a} = cellfun(@(x) length(x.size),postrwdata(type==2));
    boxplot(ripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]);
    p = ranksum(ripnums{a},waitnums{a});
    text(a,10+a/5,sprintf('p=%d\nn=%d,%d trials',p,length(ripnums{a}),length(waitnums{a})))
    %title('post-NF, incl trigger'); ylim([0 20]); ylabel('SWR count')
end
ylabel('SWR count'); subplot(1,2,1);  ylabel('SWR rate (Hz)');

%% mean ripple size per trial at R vs W, epochwise and trialwise 
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
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
    subplot(1,2,1); hold on; title('plateau, incltrig, trialwise')
    boxplot(ripsizes{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    p = ranksum(ripsizes{a},waitsizes{a});
    text(a,1.3+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(ripsizes{a}),length(waitsizes{a})))
   subplot(1,2,2); hold on;
    boxplot(ripsizes_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    [h,p] = ttest(ripsizes_ep{a},waitsizes_ep{a});
    text(a,1.3+a/10,sprintf('tp=%.04f\nn=%deps',p,length(waitsizes_ep{a})))
end
title('plateau, including trigger, epwise'); ylabel('Rip size (sd)')

%% mean ripple length per trial at R vs W, epochwise and trialwise 
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;

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
    subplot(1,2,1); hold on; title('plateau, including trigger, trialwise');
    boxplot(ripsizes{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 .5]); 
    p = ranksum(ripsizes{a},waitsizes{a});
    text(a,.1+a/20,sprintf('p=%d\nn=%d,%d trials',p,length(ripsizes{a}),length(waitsizes{a})))
   subplot(1,2,2); hold on;
    boxplot(ripsizes_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]);  ylim([0 .5]);
    [h,p] = ttest(ripsizes_ep{a},waitsizes_ep{a});
    text(a,.1+a/20,sprintf('tp=%.04f\nn=%deps',p,length(waitsizes_ep{a})))
end
title('plateau, including trigger, epwise'); ylabel('Rip length (s)')
%% rate  & count of rips in rw+postrw combined period, post-NF, trialwise
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = horzcat(rwdata{:})'; %all trials in this stage
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = horzcat(postrwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,postrwdata);
    ripnums{a} = cellfun(@(x,y) length(x.size)+length(y.size),rwdata(type==1),postrwdata(type==1));
    waitnums{a} = cellfun(@(x,y) length(x.size)+length(y.size),rwdata(type==2),postrwdata(type==2));
    riprates{a} = ripnums{a}./cellfun(@(x,y) x.duration+y.duration,rwdata(type==1),postrwdata(type==1));
    waitrates{a} = waitnums{a}./cellfun(@(x,y) x.duration+y.duration,rwdata(type==2),postrwdata(type==2));
    
    subplot(1,2,1); hold on;
    boxplot(riprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    title('Combined rw+postrw Riprate, plateau') ; xlim([.5 4.5]); ylim([0 2]);
    p = ranksum(riprates{a},waitrates{a});
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(riprates{a}),length(waitrates{a})))
    
    subplot(1,2,2); hold on; title('Combined rw+postrw Rip count, plateau')
    boxplot(ripnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 30]);
    p = ranksum(ripnums{a},waitnums{a});
    text(a,15+a,sprintf('p=%d\nn=%d,%d trials',p,length(ripnums{a}),length(waitnums{a})))
end
ylabel('SWR count'); subplot(1,2,1);  ylabel('SWR rate (Hz)');

%% amount of time spent POST R vs W, epochwise and trialwise 
clearvars -except f animals ripcols waitcols
trialwise = figure(); set(gcf,'Position',[187 1 1374 973]);
    for a = 1:length(animals)
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
        for e = 1:length(postrwdata)
            type = cellfun(@(x) x.type,postrwdata{e});
            ripduration_ep{a}(e) = mean(cellfun(@(x) x.duration,postrwdata{e}(type==1)));
            waitduration_ep{a}(e) = mean(cellfun(@(x) x.duration,postrwdata{e}(type==2)));
        end
        postrwdata = horzcat(postrwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,postrwdata);
        ripduration{a} = cellfun(@(x) x.duration,postrwdata(type==1));
        waitduration{a} = cellfun(@(x) x.duration,postrwdata(type==2)); 
        
        figure(trialwise); subplot(1,2,1); hold on;
        boxplot(ripduration{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
        boxplot(waitduration{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
        xlim([.5 4.5]); 
        p = ranksum(ripduration{a},waitduration{a});
        text(a,10+a/5,sprintf('p=%.04f\nn=%d,%d trials',p,length(ripduration{a}),length(waitduration{a})))
        
         subplot(1,2,2); hold on;
        boxplot(ripduration_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
        boxplot(waitduration_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
        xlim([.5 4.5]); 
        [h,p] = ttest(ripduration_ep{a},waitduration_ep{a});
        text(a,10+a/5,sprintf('tp=%.04f\nn=%deps',p,length(ripduration_ep{a})));

    end
title('post rw duration, plateau, epwise'); ylim([0 15]); ylabel('Duration (s)')
subplot(1,2,1); title('postrw duration, plateau, trialwise'); ylim([0 15]); ylabel('Duration (s)')

%% mean ripple size % length at POST R vs W, epochwise and trialwise 
%slightly bigger and longer post wait
clearvars -except f animals ripcols waitcols
siz = figure(); set(gcf,'Position',[187 1 1374 973]); hold on;
len = figure(); set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(postrwdata)
        type = cellfun(@(x) x.type,postrwdata{e});
        ripsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.size),postrwdata{e}(type==1)));
        waitsizes_ep{a}(e) = nanmean(cellfun(@(x) mean(x.size),postrwdata{e}(type==2)));
        riplengths_ep{a}(e) = nanmean(cellfun(@(x) mean(x.riplengths),postrwdata{e}(type==1)));
        waitlengths_ep{a}(e) = nanmean(cellfun(@(x) mean(x.riplengths),postrwdata{e}(type==2)));
    end
    postrwdata = horzcat(postrwdata{:})'; %all trials in this stage
    type = cellfun(@(x) x.type,postrwdata);
    ripsizes{a} = cellfun(@(x) mean(x.size),postrwdata(type==1));
    waitsizes{a} = cellfun(@(x) mean(x.size),postrwdata(type==2));
    riplengths{a} = cellfun(@(x) mean(x.riplengths),postrwdata(type==1));
    waitlengths{a} = cellfun(@(x) mean(x.riplengths),postrwdata(type==2));
    figure(siz)
    subplot(1,2,1); hold on; title('POSTRW ripsize, plateau, trialwise')
    boxplot(ripsizes{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    p = ranksum(ripsizes{a},waitsizes{a});
    text(a,1.3+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(ripsizes{a}),length(waitsizes{a})))
   subplot(1,2,2); hold on;
    boxplot(ripsizes_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitsizes_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 15]); 
    [h,p] = ttest(ripsizes_ep{a},waitsizes_ep{a});
    text(a,1.3+a/10,sprintf('tp=%.04f\nn=%deps',p,length(waitsizes_ep{a})))
    figure(len)
    subplot(1,2,1); hold on; title('POSTRW riplength, plateau, trialwise')
    boxplot(riplengths{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitlengths{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 .5]); 
    p = ranksum(riplengths{a},waitlengths{a});
    text(a,.1+a/20,sprintf('p=%d\nn=%d,%d trials',p,length(riplengths{a}),length(waitlengths{a})))
   subplot(1,2,2); hold on;
    boxplot(riplengths_ep{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(waitlengths_ep{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    xlim([.5 4.5]); ylim([0 .5]); 
    [h,p] = ttest(riplengths_ep{a},waitlengths_ep{a});
    text(a,.1+a/20,sprintf('tp=%.04f\nn=%deps',p,length(waitlengths_ep{a})))
end
title('POSTRW plateau, epwise'); ylabel('Rip length (s)')

%% plot median rate at outer rewarded and unrewarded, TRIALWISE comparisons
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    outerdata = arrayfun(@(x) x.outer,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        clear rwtype outertype outerrates
        rwtype(cellfun(@(x) x.trialnum,rwdata{e})) = cellfun(@(x) x.type,rwdata{e});
        outertype = nan(1,length(rwtype));
        outertype(cellfun(@(x) x.trialnum,outerdata{e})) = cellfun(@(x) x.type,outerdata{e}); % successful or not
        outerrates(cellfun(@(x) x.trialnum,outerdata{e})) = cellfun(@(x) length(x.size),outerdata{e})./cellfun(@(x) x.duration,outerdata{e});
        outerrates_rip_rew{a}{e} = outerrates(rwtype==1 & outertype==1);
        outerrates_rip_unrew{a}{e} = outerrates(rwtype==1 & outertype==0);
        outerrates_wait_rew{a}{e} = outerrates(rwtype==2 & outertype==1);
        outerrates_wait_unrew{a}{e} = outerrates(rwtype==2 & outertype==0);
    end
end
subplot(1,2,1); hold on;
for a = 1:length(animals)
    boxplot(horzcat(outerrates_rip_rew{a}{:}),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(horzcat(outerrates_wait_rew{a}{:}),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    p = ranksum(horzcat(outerrates_rip_rew{a}{:}),horzcat(outerrates_wait_rew{a}{:}));
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(horzcat(outerrates_rip_rew{a}{:})),length(horzcat(outerrates_wait_rew{a}{:}))));
end;  title('Outer riprate, rewarded, plateau'); xlim([.5 4.5]); ylim([0 1.5]);
subplot(1,2,2); hold on;
for a = 1:length(animals)
    boxplot(horzcat(outerrates_rip_unrew{a}{:}),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(horzcat(outerrates_wait_unrew{a}{:}),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    p = ranksum(horzcat(outerrates_rip_unrew{a}{:}),horzcat(outerrates_wait_unrew{a}{:}));
    text(a,1+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(horzcat(outerrates_rip_unrew{a}{:})),length(horzcat(outerrates_wait_unrew{a}{:}))));
end;  title('Outer riprate, UNrewarded, plateau'); xlim([.5 4.5]); ylim([0 1.5]);

%% plot rip rate at rw in .5s windows from start, at rewarded outer wells
clearvars -except f animals ripcols waitcols
timeedges = [0:.5:20]; %22:2:60
centers = timeedges(2:end);
toHz = 1./diff(timeedges);
figure; set(gcf,'Position',[0 0 800 950]); hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    outerdata = arrayfun(@(x) x.outer,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        clear rwtype outertype outerripmat outerbinclude
        rwtype(cellfun(@(x) x.trialnum,rwdata{e})) = cellfun(@(x) x.type,rwdata{e});
        outertype = nan(1,length(rwtype));
        outertype(cellfun(@(x) x.trialnum,outerdata{e})) = cellfun(@(x) x.type,outerdata{e}); % successful or not
        outerripmat(cellfun(@(x) x.trialnum,outerdata{e}),:) = cell2mat(cellfun(@(x) histcounts(x.times,timeedges)',outerdata{e},'un',0))';
        outerbinclude(cellfun(@(x) x.trialnum,outerdata{e}),:) = cell2mat(cellfun(@(x) x.duration'>timeedges(1:end-1)',outerdata{e},'un',0))';
        ripmat_rip{a}{e} = outerripmat(rwtype==1 & outertype==1,:);
        binclude_rip{a}{e} = outerbinclude(rwtype==1 & outertype==1,:);
        ripmat_wait{a}{e} = outerripmat(rwtype==2 & outertype==1,:);
        binclude_wait{a}{e} = outerbinclude(rwtype==2 & outertype==1,:);
    end
    ripmat1{a,1} = vertcat(ripmat_rip{a}{:});  %rip
    binclude1{a,1} = vertcat(binclude_rip{a}{:});
    ripmat2{a,1} = vertcat(ripmat_wait{a}{:});;  % wait
    binclude2{a,1} = vertcat(binclude_wait{a}{:});
    for b = 1:length(centers)
        binavg1(a,b) = toHz(b)*(mean(ripmat1{a}(binclude1{a}(:,b),b)));
        binsem1(a,b) = toHz(b)*(std(ripmat1{a}(binclude1{a}(:,b),b))/sqrt(sum(binclude1{a}(:,b))));
        binavg2(a,b) = toHz(b)*(mean(ripmat2{a}(binclude2{a}(:,b),b)));
        binsem2(a,b) = toHz(b)*(std(ripmat2{a}(binclude2{a}(:,b),b))/sqrt(sum(binclude2{a}(:,b))));
    end
    valbins1(a,:) = sum(binclude1{a})>100;
    valbins2(a,:) = sum(binclude2{a})>100;
    subplot(2,2,a); title('rewarded outer riprates by rat');xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins1(a,:)); centers(valbins1(a,:))], [binavg1(a,valbins1(a,:))-binsem1(a,valbins1(a,:)); binavg1(a,valbins1(a,:))+binsem1(a,valbins1(a,:))],'Color',ripcols(a,:),'Linewidth',.5);
    plot(centers(valbins1(a,:)),binavg1(a,valbins1(a,:)),'Color',ripcols(a,:),'Linewidth',1)
    plot([centers(valbins2(a,:)); centers(valbins2(a,:))], [binavg2(a,valbins2(a,:))-binsem2(a,valbins2(a,:)); binavg2(a,valbins2(a,:))+binsem2(a,valbins2(a,:))],'Color',waitcols(a,:),'Linewidth',.5);
    plot(centers(valbins2(a,:)),binavg2(a,valbins2(a,:)),'Color',waitcols(a,:),'Linewidth',1)
    xlim([0 20]); ylim([0 1]);
end

%% Why do wait trials have higher postrw rates? rw-postrw correlations: rate and number and duration etc, epochwise
clearvars -except f animals ripcols waitcols
%ratecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%numcorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%timecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
%     % only use the second half of trials from each epoch
%     rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
%     postrwdata = cellfun(@(x) x(ceil(length(x)/2):end),postrwdata,'un',0);
    for e = 1:length(postrwdata)
        type = cellfun(@(x) x.type,postrwdata{e});
        rwrates{a}{e} = cellfun(@(x) length(x.size),rwdata{e})./cellfun(@(x) x.duration,rwdata{e});
        postrwrates{a}{e} = cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e});
        rwnums{a}{e} = cellfun(@(x) length(x.size),rwdata{e});
        postrwnums{a}{e} = cellfun(@(x) length(x.size),postrwdata{e});
        rwduration{a}{e} = cellfun(@(x) x.duration,rwdata{e});
        postrwduration{a}{e} = cellfun(@(x) x.duration,postrwdata{e});
        if sum(type==1)>10 & sum(type==2)>10
            valep{a}(e) = 1;
            %             figure(ratecorr); subplot(2,2,a); hold on
                        nonans = ~isnan(rwrates{a}{e}) & ~isnan(postrwrates{a}{e});
            %             plot(rwrates{a}{e}(type==1),postrwrates{a}{e}(type==1),'r.'); lsline
            %             plot(rwrates{a}{e}(type==2),postrwrates{a}{e}(type==2),'k.'); lsline
            [rates_rip_r{a}(:,:,e),rates_rip_p{a}(:,:,e)] = corrcoef(rwrates{a}{e}(type==1 & nonans),postrwrates{a}{e}(type==1 & nonans));
            [rates_wait_r{a}(:,:,e),rates_wait_p{a}(:,:,e)] = corrcoef(rwrates{a}{e}(type==2 & nonans),postrwrates{a}{e}(type==2 & nonans));
            [rates_both_r{a}(:,:,e),rates_both_p{a}(:,:,e)] = corrcoef(rwrates{a}{e}(nonans),postrwrates{a}{e}(nonans));    
            %             figure(numcorr); subplot(2,2,a); hold on
                         nonans = ~isnan(rwnums{a}{e}) & ~isnan(postrwnums{a}{e});
            %             plot(rwnums{a}{e}(type==1),postrwnums{a}{e}(type==1),'r.'); lsline
            %             plot(rwnums{a}{e}(type==2),postrwnums{a}{e}(type==2),'k.'); lsline
            [nums_rip_r{a}(:,:,e),nums_rip_p{a}(:,:,e)] = corrcoef(rwnums{a}{e}(type==1 & nonans),postrwnums{a}{e}(type==1 & nonans));
            [nums_wait_r{a}(:,:,e),nums_wait_p{a}(:,:,e)] = corrcoef(rwnums{a}{e}(type==2 & nonans),postrwnums{a}{e}(type==2 & nonans));
            [nums_both_r{a}(:,:,e),nums_both_p{a}(:,:,e)] = corrcoef(rwnums{a}{e}(nonans),postrwnums{a}{e}(nonans));       
            %             figure(timecorr); subplot(2,2,a); hold on
                         nonans = ~isnan(rwduration{a}{e}) & ~isnan(postrwduration{a}{e});
            %             plot(rwduration{a}{e}(type==1),postrwduration{a}{e}(type==1),'r.'); lsline
            %             plot(rwduration{a}{e}(type==2),postrwduration{a}{e}(type==2),'k.'); lsline
            [durs_rip_r{a}(:,:,e),durs_rip_p{a}(:,:,e)] = corrcoef(rwduration{a}{e}(type==1 & nonans),postrwduration{a}{e}(type==1 & nonans));
            [durs_wait_r{a}(:,:,e),durs_wait_p{a}(:,:,e)] = corrcoef(rwduration{a}{e}(type==2 & nonans),postrwduration{a}{e}(type==2 & nonans));
            [durs_both_r{a}(:,:,e),durs_both_p{a}(:,:,e)] = corrcoef(rwduration{a}{e}(nonans),postrwduration{a}{e}(nonans));   
        end
    end
end
figure; subplot(2,3,1); hold on;
for a = 1:length(animals)
    boxplot(squeeze(rates_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(rates_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    boxplot(squeeze(rates_both_r{a}(1,2,logical(valep{a}))),'Positions',a-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end;
xlim([.5 4.5]); ylim([-1 1]);title('rates, pre x post r, epwise'); plot([.5 4.5],[0 0],'k:')

subplot(2,3,4); hold on; title('rates p')
for a = 1:length(animals); boxplot(squeeze(rates_rip_p{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(rates_wait_p{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:));
end
xlim([.5 4.5]); ylim([0 1]);title('rates p');

subplot(2,3,2); hold on; title('nums, pre x post r')
for a = 1:length(animals); boxplot(squeeze(nums_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(nums_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    boxplot(squeeze(nums_both_r{a}(1,2,logical(valep{a}))),'Positions',a-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end; xlim([.5 4.5]); ylim([-1 1]); plot([.5 4.5],[0 0],'k:')

subplot(2,3,5); hold on; title('nums p')
for a = 1:length(animals); boxplot(squeeze(nums_rip_p{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(nums_wait_p{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end ; xlim([.5 4.5]); ylim([0 1]);

subplot(2,3,3); hold on; title('duration, pre x post r')
for a = 1:length(animals); boxplot(squeeze(durs_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(durs_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    boxplot(squeeze(durs_both_r{a}(1,2,logical(valep{a}))),'Positions',a-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end; xlim([.5 4.5]); ylim([-1 1]);title('duration r'); plot([.5 4.5],[0 0],'k:')

subplot(2,3,6); hold on; title('duration p')
for a = 1:length(animals); boxplot(squeeze(durs_rip_p{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(durs_wait_p{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end; xlim([.5 4.5]); ylim([0 1]);

%% Why do wait trials have higher postrw rates? part2, rw-postrw correlations: cumulative size/length, trigger size, cross-modality
clearvars -except f animals ripcols waitcols
%ratecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%numcorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%timecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(postrwdata)
        type = cellfun(@(x) x.type,postrwdata{e});
        rwtrigsize{a}{e}(cellfun(@(x) ~isempty(x.size),rwdata{e})) = cellfun(@(x) x.size(end),rwdata{e}(cellfun(@(x) ~isempty(x.size),rwdata{e})));
        rwcumsize{a}{e} = cellfun(@(x) sum(x.size),rwdata{e});
        rwcumlength{a}{e} = cellfun(@(x) sum(x.riplengths),rwdata{e});
        %postrwrates{a}{e} = cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e});
        rwnums{a}{e} = cellfun(@(x) length(x.size),rwdata{e});
        postrwcumlength{a}{e} = cellfun(@(x) sum(x.riplengths),postrwdata{e});
        postrwcumsize{a}{e} = cellfun(@(x) sum(x.size),postrwdata{e});
        postrwnums{a}{e} = cellfun(@(x) length(x.size),postrwdata{e});
        rwduration{a}{e} = cellfun(@(x) x.duration,rwdata{e});
        postrwduration{a}{e} = cellfun(@(x) x.duration,postrwdata{e});
        if sum(type==1)>10 & sum(type==2)>10
            valep{a}(e) = 1; %            
            [numsXdur_rip_r{a}(:,:,e),numsXdur_rip_p{a}(:,:,e)] = corrcoef(rwnums{a}{e}(type==1),postrwduration{a}{e}(type==1));
            [numsXdur_wait_r{a}(:,:,e),numsXdur_wait_p{a}(:,:,e)] = corrcoef(rwnums{a}{e}(type==2),postrwduration{a}{e}(type==2));
            [numsXdur_both_r{a}(:,:,e),numsXdur_both_p{a}(:,:,e)] = corrcoef(rwnums{a}{e},postrwduration{a}{e});
            [trigsizeXdur_rip_r{a}(:,:,e),trigsizeXdur_rip_p{a}(:,:,e)] = corrcoef(rwtrigsize{a}{e}(type==1),postrwduration{a}{e}(type==1));
            [cumsizeXdur_rip_r{a}(:,:,e),cumsizeXdur_rip_p{a}(:,:,e)] = corrcoef(rwcumsize{a}{e}(type==1),postrwduration{a}{e}(type==1));
            [cumsizeXdur_wait_r{a}(:,:,e),cumsizeXdur_wait_p{a}(:,:,e)] = corrcoef(rwcumsize{a}{e}(type==2),postrwduration{a}{e}(type==2));
            [cumlengthXdur_rip_r{a}(:,:,e),cumlengthXdur_rip_p{a}(:,:,e)] = corrcoef(rwcumlength{a}{e}(type==1),postrwduration{a}{e}(type==1));
            [cumlengthXdur_wait_r{a}(:,:,e),cumlengthXdur_wait_p{a}(:,:,e)] = corrcoef(rwcumlength{a}{e}(type==2),postrwduration{a}{e}(type==2));        end
            [cumsize_rip_r{a}(:,:,e),cumsize_rip_p{a}(:,:,e)] = corrcoef(rwcumsize{a}{e}(type==1),postrwcumsize{a}{e}(type==1));
            [cumsize_wait_r{a}(:,:,e),cumsize_wait_p{a}(:,:,e)] = corrcoef(rwcumsize{a}{e}(type==2),postrwcumsize{a}{e}(type==2));   
            [cumsize_both_r{a}(:,:,e),cumsize_both_p{a}(:,:,e)] = corrcoef(rwcumsize{a}{e},postrwcumsize{a}{e});   
    end
end
figure; subplot(2,3,1); hold on;
for a = 1:length(animals)
    boxplot(squeeze(numsXdur_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(numsXdur_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    boxplot(squeeze(numsXdur_both_r{a}(1,2,logical(valep{a}))),'Positions',a-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end;
xlim([.5 4.5]); ylim([-1 1]);title('numsXdur r, epwise'); plot([.5 4.5],[0 0],'k:')

subplot(2,3,2); hold on; title('trigsizeXdur (rip only) r')
for a = 1:length(animals); boxplot(squeeze(trigsizeXdur_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
end; xlim([.5 4.5]); ylim([-1 1]); plot([.5 4.5],[0 0],'k:')

subplot(2,3,3); hold on; title('cumulativesizeXdur r')
for a = 1:length(animals); boxplot(squeeze(cumsizeXdur_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(cumsizeXdur_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end; xlim([.5 4.5]); ylim([-1 1]);plot([.5 4.5],[0 0],'k:')
subplot(2,3,4); hold on; title('cumulativesizeXdur r')
for a = 1:length(animals); boxplot(squeeze(cumlengthXdur_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(cumlengthXdur_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end; xlim([.5 4.5]); ylim([-1 1]);plot([.5 4.5],[0 0],'k:')
subplot(2,3,5); hold on; title('cumulativesize r')
for a = 1:length(animals); boxplot(squeeze(cumsize_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(cumsize_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
    boxplot(squeeze(cumsize_both_r{a}(1,2,logical(valep{a}))),'Positions',a-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end; xlim([.5 4.5]); ylim([-1 1]);plot([.5 4.5],[0 0],'k:')

%% correlation between rip size and subsequent interrip interval  (no clear correlation)
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,postrwdata{e});
    rwstack{a}{e} = []; postrwstack{a}{e} = [];
    if sum(type==1)>10 & sum(type==2)>10
            valep{a}(e) = 1; % 
    for t = 1:length(type)  % for each trial, determine IRIs for each rip that we can (separate r and w, pre and post reward
        if length(rwdata{e}{t}.size)>1  % can only do this for periods with multiple rips
            iri = rwdata{e}{t}.times(2:end)-(rwdata{e}{t}.times(1:end-1)+rwdata{e}{t}.riplengths(1:end-1));
            rwstack{a}{e} = [rwstack{a}{e}; rwdata{e}{t}.size(1:end-1), iri, repmat(type(t),length(iri),1)];
        end
        if length(postrwdata{e}{t}.size)>1  % can only do this for periods with multiple rips
            iri = postrwdata{e}{t}.times(2:end)-(postrwdata{e}{t}.times(1:end-1)+postrwdata{e}{t}.riplengths(1:end-1));
            postrwstack{a}{e} = [postrwstack{a}{e}; postrwdata{e}{t}.size(1:end-1), iri, repmat(type(t),length(iri),1)];
        end
    end
    
    subplot(4,2,a); hold on
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2),'.','Color',ripcols(a,:)); lsline
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2),'.','Color',waitcols(a,:)); lsline
    [rw_rip_r{a}(:,:,e),rw_rip_p{a}(:,:,e)] = corrcoef(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2));   
    [rw_wait_r{a}(:,:,e),rw_wait_p{a}(:,:,e)] = corrcoef(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2));   
   
    subplot(4,2,a+4); hold on;
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2),'.','Color',ripcols(a,:)); lsline
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2),'.','Color',waitcols(a,:)); lsline
    [postrw_rip_r{a}(:,:,e),postrw_rip_p{a}(:,:,e)] = corrcoef(postrwstack{a}{e}(postrwstack{a}{e}(:,3)==1,1),postrwstack{a}{e}(postrwstack{a}{e}(:,3)==1,2));   
    [postrw_wait_r{a}(:,:,e),postrw_wait_p{a}(:,:,e)] = corrcoef(postrwstack{a}{e}(postrwstack{a}{e}(:,3)==2,1),postrwstack{a}{e}(postrwstack{a}{e}(:,3)==2,2));   
    end
    end
end
figure; subplot(1,2,1); hold on;
for a = 1:length(animals)
    boxplot(squeeze(rw_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(rw_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end;
xlim([.5 4.5]); ylim([-1 1]);title('RW ripsize x iri after, epwise'); plot([.5 4.5],[0 0],'k:')
subplot(1,2,2); hold on;
for a = 1:length(animals)
    boxplot(squeeze(postrw_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(postrw_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end;
xlim([.5 4.5]); ylim([-1 1]);title('POSTRW ripsize x iri after, epwise'); plot([.5 4.5],[0 0],'k:')

%% characterize the refractory period BEFORE a rip as a function of its size
clearvars -except f animals ripcols waitcols
figure; set(gcf,'Position',[187 1 1374 973]);
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw,f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,postrwdata{e});
    rwstack{a}{e} = []; postrwstack{a}{e} = [];
    if sum(type==1)>10 & sum(type==2)>10
            valep{a}(e) = 1; % 
    for t = 1:length(type)  % for each trial, determine IRIs for each rip that we can (separate r and w, pre and post reward
        if length(rwdata{e}{t}.size)>1  % can only do this for periods with multiple rips
            iri = rwdata{e}{t}.times(2:end)-(rwdata{e}{t}.times(1:end-1)+rwdata{e}{t}.riplengths(1:end-1));
            rwstack{a}{e} = [rwstack{a}{e}; rwdata{e}{t}.size(2:end), iri, repmat(type(t),length(iri),1)];
        end
        if length(postrwdata{e}{t}.size)>1  % can only do this for periods with multiple rips
            iri = postrwdata{e}{t}.times(2:end)-(postrwdata{e}{t}.times(1:end-1)+postrwdata{e}{t}.riplengths(1:end-1));
            postrwstack{a}{e} = [postrwstack{a}{e}; postrwdata{e}{t}.size(2:end), iri, repmat(type(t),length(iri),1)];
        end
    end
    
    subplot(4,2,a); hold on
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2),'.','Color',ripcols(a,:)); lsline
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2),'.','Color',waitcols(a,:)); lsline
    [rw_rip_r{a}(:,:,e),rw_rip_p{a}(:,:,e)] = corrcoef(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2));   
    [rw_wait_r{a}(:,:,e),rw_wait_p{a}(:,:,e)] = corrcoef(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2));   
   
    subplot(4,2,a+4); hold on;
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==1,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==1,2),'.','Color',ripcols(a,:)); lsline
%    plot(rwstack{a}{e}(rwstack{a}{e}(:,3)==2,1),rwstack{a}{e}(rwstack{a}{e}(:,3)==2,2),'.','Color',waitcols(a,:)); lsline
    [postrw_rip_r{a}(:,:,e),postrw_rip_p{a}(:,:,e)] = corrcoef(postrwstack{a}{e}(postrwstack{a}{e}(:,3)==1,1),postrwstack{a}{e}(postrwstack{a}{e}(:,3)==1,2));   
    [postrw_wait_r{a}(:,:,e),postrw_wait_p{a}(:,:,e)] = corrcoef(postrwstack{a}{e}(postrwstack{a}{e}(:,3)==2,1),postrwstack{a}{e}(postrwstack{a}{e}(:,3)==2,2));   
    end
    end
end
figure; subplot(1,2,1); hold on;
for a = 1:length(animals)
    boxplot(squeeze(rw_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(rw_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end;
xlim([.5 4.5]); ylim([-1 1]);title('RW ripsize x iri BEFORE, epwise'); plot([.5 4.5],[0 0],'k:')
subplot(1,2,2); hold on;
for a = 1:length(animals)
    boxplot(squeeze(postrw_rip_r{a}(1,2,logical(valep{a}))),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(squeeze(postrw_wait_r{a}(1,2,logical(valep{a}))),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
end;
xlim([.5 4.5]); ylim([-1 1]);title('POSTRW ripsize x iri BEFORE, epwise'); plot([.5 4.5],[0 0],'k:')

%% rw+postrw riprate curves by timebin centered at trig/rwend  
clearvars -except f animals ripcols waitcols
timebin = .5;
timeedges = [-20:timebin:20]; %22:2:60
centers = timeedges(2:end);
toHz = 1/timebin;
indivs = figure(); set(gcf,'Position',[72 391 1815 443]); hold on;
for a = 1:length(animals)
        rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials  
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
        % only use the second half of trials from each epoch
        %rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
        %postrwdata = cellfun(@(x) x(ceil(length(x)/2):end),postrwdata,'un',0);
        
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        type{a} = cellfun(@(x) x.type,postrwdata);
        %recalc rw rip times relative to trigger/end, combine rw + postrw
        combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata,postrwdata,'un',0);
        ripmat{a,1} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
        binclude{a,1} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata,postrwdata,'UniformOutput',0)); 
        
    for b = 1:length(centers)
        rip(a,b) = toHz*(mean(ripmat{a}(type{a}==1 & binclude{a}(:,b),b)));
        rip_sem(a,b) = toHz*(std(ripmat{a}(type{a}==1 & binclude{a}(:,b),b))/sqrt(sum(type{a}==1 & binclude{a}(:,b))));
        wait(a,b) = toHz*(mean(ripmat{a}(type{a}==2 & binclude{a}(:,b),b)));
        wait_sem(a,b) = toHz*(std(ripmat{a}(type{a}==2 & binclude{a}(:,b),b))/sqrt(sum(type{a}==2 & binclude{a}(:,b))));
     end
    valbins_rip(a,:) = sum(binclude{a}(type{a}==1,:))>100;
    valbins_wait(a,:) = sum(binclude{a}(type{a}==2,:))>100;
      figure(indivs)  
    subplot(2,2,a); title(['riprates, plateau ' animals{a}]); hold on
    plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',ripcols(a,:),'Linewidth',.5);
    plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',ripcols(a,:),'Linewidth',1)
    plot([centers(valbins_wait(a,:)); centers(valbins_wait(a,:))], [wait(a,valbins_wait(a,:))-wait_sem(a,valbins_wait(a,:)); wait(a,valbins_wait(a,:))+wait_sem(a,valbins_wait(a,:))],'Color',waitcols(a,:),'Linewidth',.5);
    plot(centers(valbins_wait(a,:)),wait(a,valbins_wait(a,:)),'Color',waitcols(a,:),'Linewidth',1)
    xlabel('Time relative to trigger (s)'); ylabel('SWR rate (Hz)'); 
end
%% bars showing breakdown of where rips happen per trial
clearvars -except f animals ripcols waitcols
for a = 1:length(animals)
        %figure(); set(gcf,'Position',[72 391 1815 443]); hold on;
        homedata = arrayfun(@(x) x.home',f(a).output{1},'UniformOutput',0);
        rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials  
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
        outerdata = arrayfun(@(x) x.outer',f(a).output{1},'UniformOutput',0);
        lockdata = arrayfun(@(x) x.lock',f(a).output{1},'UniformOutput',0);
        for e = 1:length(homedata)
            type{a}{e} = nan(length(homedata{e}),1);
            type{a}{e}(cellfun(@(x) x.trialnum,rwdata{e})) = cellfun(@(x) x.type,rwdata{e});
            countstack{a}{e} = nan(length(homedata{e}),5);
            countstack{a}{e}(cellfun(@(x) x.trialnum,homedata{e}),1) = cellfun(@(x) length(x.size),homedata{e});
            countstack{a}{e}(cellfun(@(x) x.trialnum,rwdata{e}),2) = cellfun(@(x) length(x.size),rwdata{e});
            countstack{a}{e}(cellfun(@(x) x.trialnum,postrwdata{e}),3) = cellfun(@(x) length(x.size),postrwdata{e});
            countstack{a}{e}(cellfun(@(x) x.trialnum,outerdata{e}),4) = cellfun(@(x) length(x.size),outerdata{e});
            countstack{a}{e}(cellfun(@(x) x.trialnum,lockdata{e}),5) = cellfun(@(x) length(x.size),lockdata{e});
            sizestack{a}{e} = nan(length(homedata{e}),5);
            sizestack{a}{e}(cellfun(@(x) x.trialnum,homedata{e}),1) = cellfun(@(x) length(x.size)/x.duration,homedata{e});
            sizestack{a}{e}(cellfun(@(x) x.trialnum,rwdata{e}),2) = cellfun(@(x) length(x.size)/x.duration,rwdata{e});
            sizestack{a}{e}(cellfun(@(x) x.trialnum,postrwdata{e}),3) = cellfun(@(x) length(x.size)/x.duration,postrwdata{e});
            sizestack{a}{e}(cellfun(@(x) x.trialnum,outerdata{e}),4) = cellfun(@(x) length(x.size)/x.duration,outerdata{e});
            sizestack{a}{e}(cellfun(@(x) x.trialnum,lockdata{e}),5) = cellfun(@(x) length(x.size)/x.duration,lockdata{e});
%             figure; 
%         bounds = prctile(countstack{a}{e}(:,2),[10 90]);
%         highs = countstack{a}{e}(:,2)>=bounds(2);
%         lows = countstack{a}{e}(:,2)<=bounds(1);
%         subplot(3,2,1); hold on;
%         boxplot(countstack{a}{e}(lows,2),'Position',1)
%         boxplot(countstack{a}{e}(~highs & ~lows,2),'Position',2);
%         boxplot(countstack{a}{e}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, all trials, low-mid-high'); ylim([0 40]);
%          subplot(3,2,2); hold on;
%         boxplot(countstack{a}{e}(lows,3),'Position',1);
%         boxplot(countstack{a}{e}(~highs & ~lows,3),'Position',2)
%         boxplot(countstack{a}{e}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, all trials, low-mid-high'); ylim([0 15]);
%         bounds = prctile(countstack{a}{e}(type==1,2),[10 90]);
%         highs = type==1 & countstack{a}{e}(:,2)>=bounds(2);
%         lows = type==1 & countstack{a}{e}(:,2)<=bounds(1);
%         subplot(3,2,3); hold on;
%         boxplot(countstack{a}{e}(lows,2),'Position',1)
%         boxplot(countstack{a}{e}(~highs & ~lows & type==1,2),'Position',2);
%         boxplot(countstack{a}{e}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, rip trials only, low-mid-high'); ylim([0 40]);
%          subplot(3,2,4); hold on;
%         boxplot(countstack{a}{e}(lows,3),'Position',1);
%         %p= ranksum(countstack{a}{e}(~highs,3),countstack{a}{e}(highs,3))
%         boxplot(countstack{a}{e}(~highs & ~lows& type==1,3),'Position',2)
%         boxplot(countstack{a}{e}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, rip trials only, low-mid-high'); ylim([0 15]);
%         bounds = prctile(countstack{a}{e}(type==2,2),[10 90]);
%         highs = type==2 & countstack{a}{e}(:,2)>=bounds(2);
%         lows = type==2 & countstack{a}{e}(:,2)<=bounds(1);
%         subplot(3,2,5); hold on;
%         boxplot(countstack{a}{e}(lows,2),'Position',1)
%         boxplot(countstack{a}{e}(~highs & ~lows & type==2,2),'Position',2);
%         boxplot(countstack{a}{e}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, wait trials only, low-mid-high'); ylim([0 40]);
%          subplot(3,2,6); hold on;
%         boxplot(countstack{a}{e}(lows,3),'Position',1);
%         %p= ranksum(countstack{a}{e}(~highs,3),countstack{a}{e}(highs,3))
%         boxplot(countstack{a}{e}(~highs & ~lows & type==2,3),'Position',2)
%         boxplot(countstack{a}{e}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, wait trials only, low-mid-high'); ylim([0 15]);
        end
         allcountstack{a} = vertcat(countstack{a}{:});
         allsizestack{a} = vertcat(sizestack{a}{:});
         alltype{a} = vertcat(type{a}{:});
%         ax1 = subplot(3,1,1); hold on; bar(allcountstack{a},'stacked'); title(animals{a})
%         ax2 = subplot(3,1,2); hold on; plot(sum(allcountstack{a}(:,2:3),2))
%         ax3 = subplot(3,1,3); hold on; plot(sum(allsizestack{a}(:,2:3),2))
%         linkaxes([ax1,ax2,ax3],'x')
%         stack{a} = allsizestack{a};
%         figure; 
%         bounds = prctile(stack{a}(:,2),[10 90]);
%         highs = stack{a}(:,2)>=bounds(2);
%         lows = stack{a}(:,2)<=bounds(1);
%         subplot(3,2,1); hold on;
%         boxplot(stack{a}(lows,2),'Position',1)
%         boxplot(stack{a}(~highs & ~lows,2),'Position',2);
%         boxplot(stack{a}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, all trials, low-mid-high'); ylim([0 40]);
%          subplot(3,2,2); hold on;
%         boxplot(stack{a}(lows,3),'Position',1);
%         boxplot(stack{a}(~highs & ~lows,3),'Position',2)
%         boxplot(stack{a}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, all trials, low-mid-high'); ylim([0 40]);
%         bounds = prctile(stack{a}(alltype{a}==1,2),[10 90]);
%         highs = alltype{a}==1 & stack{a}(:,2)>=bounds(2);
%         lows = alltype{a}==1 & stack{a}(:,2)<=bounds(1);
%         subplot(3,2,3); hold on;
%         boxplot(stack{a}(lows,2),'Position',1)
%         boxplot(stack{a}(~highs & ~lows & alltype{a}==1,2),'Position',2);
%         boxplot(stack{a}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, rip trials only, low-mid-high'); ylim([0 40]);
%          subplot(3,2,4); hold on;
%         boxplot(stack{a}(lows,3),'Position',1);
%         %p= ranksum(countstack{a}{e}(~highs,3),countstack{a}{e}(highs,3))
%         boxplot(stack{a}(~highs & ~lows& alltype{a}==1,3),'Position',2)
%         boxplot(stack{a}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, rip trials only, low-mid-high'); ylim([0 40]);
%         bounds = prctile(stack{a}(alltype{a}==2,2),[10 90]);
%         highs = alltype{a}==2 & stack{a}(:,2)>=bounds(2);
%         lows = alltype{a}==2 & stack{a}(:,2)<=bounds(1);
%         subplot(3,2,5); hold on;
%         boxplot(stack{a}(lows,2),'Position',1)
%         boxplot(stack{a}(~highs & ~lows & alltype{a}==2,2),'Position',2);
%         boxplot(stack{a}(highs,2),'Position',3)
%          xlim([0 4]); title('pre-reward, wait trials only, low-mid-high'); ylim([0 40]);
%          subplot(3,2,6); hold on;
%         boxplot(stack{a}(lows,3),'Position',1);
%         %p= ranksum(countstack{a}{e}(~highs,3),countstack{a}{e}(highs,3))
%         boxplot(stack{a}(~highs & ~lows & alltype{a}==2,3),'Position',2)
%         boxplot(stack{a}(highs,3),'Position',3);
%         xlim([0 4]); title('post-reward, wait trials only, low-mid-high'); ylim([0 40]);
        
        figure; plot(mean(allsizestack{a}(:,2:3),2))
end

%% are r and w trials truly evenly distributed?
clearvars -except f animals ripcols waitcols
rf = figure(); set(gcf,'Position',[72 391 1815 443]); hold on;
rfl = figure(); set(gcf,'Position',[72 391 1815 443]); hold on;
rfe = figure(); set(gcf,'Position',[72 391 1815 443]); hold on;

for a = 1:length(animals)
    homedata = arrayfun(@(x) x.home',f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    lockdata = arrayfun(@(x) x.lock',f(a).output{1},'UniformOutput',0); % stack data from all trials
    for e = 1:length(homedata)
    hometrialnum = cellfun(@(x) x.trialnum,homedata{e});
    rwtype = cellfun(@(x) x.type,rwdata{e});
    rwtrialnum = cellfun(@(x) x.trialnum,rwdata{e});
    locktype = cellfun(@(x) x.type,lockdata{e});
    ripfrac{a}(e) = sum(rwtype==1)/length(rwtype);
    ripfrac_lock{a}(e) = sum(locktype==1)/length(locktype);
    ripfrac_earlylate{a}(e,:) = [sum(rwtype==1 & rwtrialnum<ceil(length(hometrialnum)/2))/sum(rwtrialnum<ceil(length(hometrialnum)/2)), ...
        sum(rwtype==1 & rwtrialnum>=ceil(length(hometrialnum)/2))/sum(rwtrialnum>=ceil(length(hometrialnum)/2))];
    end
    figure(rf)%subplot(1,3,1); hold on;
    boxplot(ripfrac{a},'Positions',a);ylim([0 1]); xlim([0 4.5])
    figure(rfl) %subplot(1,3,2); hold on;
    boxplot(ripfrac_lock{a},'Positions',a); ylim([0 1]); xlim([0 4.5])
    figure(rfe) %subplot(1,3,3); hold on;
    boxplot(ripfrac_earlylate{a}(:,1),'Positions',a);
    boxplot(ripfrac_earlylate{a}(:,2),'Positions',a+.25);ylim([0 1]); xlim([0 4.5])
end

%% rw+postrw riprate curves by timebin, centered at trig/rwend,  split by size of trigger
clearvars -except f animals ripcols waitcols
timebin = .5;
timeedges = [-20:timebin:20]; %22:2:60
centers = timeedges(2:end);
toHz = 1/timebin;
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[72 391 1815 443]); hold on;
for a = 1:length(animals)
        rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials  
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
        % only use the second half of trials from each epoch
        %rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
        %postrwdata = cellfun(@(x) x(ceil(length(x)/2):end),postrwdata,'un',0);
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        type = cellfun(@(x) x.type,postrwdata);
        postrwnums = cellfun(@(x) length(x.size),postrwdata);
        postrwrates = cellfun(@(x) length(x.size)/x.duration,postrwdata);

        trigsizes = zeros(length(type),1);
        trigsizes(type==1 & cellfun(@(x) ~isempty(x.size),rwdata)) = cellfun(@(x) x.size(end),rwdata(type==1 & cellfun(@(x) ~isempty(x.size),rwdata)));
        bounds = prctile(trigsizes(trigsizes>0),[25 75]);
        hightrigtrials = type==1 & trigsizes>bounds(end);
        lowtrigtrials = type==1 & trigsizes>0 & trigsizes<bounds(1);
        %postrwnum = zeros(length(type),1);
        %postrwnum(type==1 ) = cellfun(@(x) length(x.size),postrwdata(type==1));
        %bounds = prctile(postrwnum(type==1),[15 85]);
        %hightrigtrials = type==1 & postrwnum>bounds(end);
        %lowtrigtrials = type==1 & postrwnum<=bounds(1);
        %recalc rw rip times relative to trigger/end, combine rw + postrw
        combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata,postrwdata,'un',0);
        ripmat{a,1} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
        binclude{a,1} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata,postrwdata,'UniformOutput',0)); 
    for b = 1:length(centers)
        hightrig_rip(a,b) = toHz*(mean(ripmat{a}(hightrigtrials & binclude{a}(:,b),b)));
        hightrig_rip_sem(a,b) = toHz*(std(ripmat{a}(hightrigtrials& binclude{a}(:,b),b))/sqrt(sum(hightrigtrials & binclude{a}(:,b))));
        lowtrig_rip(a,b) = toHz*(mean(ripmat{a}(lowtrigtrials & binclude{a}(:,b),b)));
        lowtrig_rip_sem(a,b) = toHz*(std(ripmat{a}(lowtrigtrials & binclude{a}(:,b),b))/sqrt(sum(lowtrigtrials & binclude{a}(:,b))));
        wait(a,b) = toHz*(mean(ripmat{a}(type==2 & binclude{a}(:,b),b)));
        wait_sem(a,b) = toHz*(std(ripmat{a}(type==2 & binclude{a}(:,b),b))/sqrt(sum(type==2 & binclude{a}(:,b))));
     end
    valbins_high(a,:) = sum(binclude{a}(hightrigtrials,:))>10;
    valbins_low(a,:) = sum(binclude{a}(lowtrigtrials,:))>10;
    valbins_wait(a,:) = sum(binclude{a}(type==2,:))>100;
        
    subplot(2,2,a); title(['Riprates, split by trig size, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins_high(a,:)); centers(valbins_high(a,:))], [hightrig_rip(a,valbins_high(a,:))-hightrig_rip_sem(a,valbins_high(a,:)); hightrig_rip(a,valbins_high(a,:))+hightrig_rip_sem(a,valbins_high(a,:))],'Color',[.5 0 0],'Linewidth',.5);
    plot(centers(valbins_high(a,:)),hightrig_rip(a,valbins_high(a,:)),'Color',[.5 0 0],'Linewidth',1)
    plot([centers(valbins_low(a,:)); centers(valbins_low(a,:))], [lowtrig_rip(a,valbins_low(a,:))-lowtrig_rip_sem(a,valbins_low(a,:)); lowtrig_rip(a,valbins_low(a,:))+lowtrig_rip_sem(a,valbins_low(a,:))],'Color',[1 0 .5],'Linewidth',.5);
    plot(centers(valbins_low(a,:)),lowtrig_rip(a,valbins_low(a,:)),'Color',[1 0 .5],'Linewidth',1)
    plot([centers(valbins_wait(a,:)); centers(valbins_wait(a,:))], [wait(a,valbins_wait(a,:))-wait_sem(a,valbins_wait(a,:)); wait(a,valbins_wait(a,:))+wait_sem(a,valbins_wait(a,:))],'Color',cols(2,:),'Linewidth',.5);
    plot(centers(valbins_wait(a,:)),wait(a,valbins_wait(a,:)),'Color',cols(2,:),'Linewidth',1)
    
    hightrig_postrwrates{a} = postrwrates(hightrigtrials);
    lowtrig_postrwrates{a} = postrwrates(lowtrigtrials);
    hightrig_postrwnums{a} = postrwnums(hightrigtrials);
    lowtrig_postrwnums{a} = postrwnums(lowtrigtrials);
end
figure;
subplot(1,2,1); hold on;
for a = 1:length(animals)
    boxplot(hightrig_postrwrates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(lowtrig_postrwrates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',ripcols(a,:))
    p = ranksum(hightrig_postrwrates{a},lowtrig_postrwrates{a}); text(a,.5,sprintf('p=%.03f',p));
end;
xlim([.5 4.5]); ylim([0 2]);title('postRW riprate split by trig size'); 
subplot(1,2,2); hold on;
for a = 1:length(animals)
    boxplot(hightrig_postrwnums{a},'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
    boxplot(lowtrig_postrwnums{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',ripcols(a,:))
    p = ranksum(hightrig_postrwnums{a},lowtrig_postrwnums{a}); text(a,.5,sprintf('p=%.03f',p));
end;
xlim([.5 4.5]); ylim([0 10]);title('postRW ripcount split by trig size(high-low)'); 
%% raster of rips across rw-postrw
clearvars -except f animals ripcols waitcols
cols = [1 0 0; 0 0 0];
for a = 1:length(animals)
    figure; set(gcf,'Position',[219 70 1657 829]); hold on;
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
    type = cellfun(@(x) x.type,rwdata);
    subplot(2,2,1); ylabel('Trials'); title([animals{a} ' rip trials, plateau'])
    agplotripraster(rwdata(type==1), postrwdata(type==1),'sortorder','rw'); xlim([-20 5]); %,'fulllength',0
    subplot(2,2,3);xlabel('Time (s)'); title('wait trials');  ylabel('Trials');
    agplotripraster(rwdata(type==2), postrwdata(type==2),'sortorder','rw'); xlim([-20 5])
    subplot(2,2,2); ylabel('Trials'); xlabel('Time (s)'); title([animals{a} ' rip trials, plateau'])
    agplotripraster(rwdata(type==1), postrwdata(type==1),'sortorder','postrw'); xlim([-5 10])
    subplot(2,2,4);xlabel('Time (s)'); title('wait trials'); ylabel('Trials');
    agplotripraster(rwdata(type==2), postrwdata(type==2),'sortorder','postrw'); xlim([-5 10])

end


