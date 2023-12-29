%% Simulate trials with matched duration & large trigger event from pooled wait data

animals = {'remy','gus','bernard','fievel'};
%epochfilter{1} = ['$ripthresh>0 & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3''))'];
%epochfilter{1} = ['$ripthresh>=16 & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3''))'];
epochfilter{1} = ['isequal($cond_phase,''early'') & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3''))'];
epochfilter{2} = ['(isequal($cond_phase,''early'') | isequal($cond_phase,''late'')) & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3''))'];


% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

%args: timeexclusion: 1 if you want to subtract 200ms from end of each trial. eventexclusion 1 if you want to remove the last specific rip of each trial
f = setfilterfunction(f, 'dfa_RWsimulation', {'ca1rippleskons','trials'},'timeexclusion',0, 'eventexclusion',0);
f = runfilter(f);

%save('/media/anna/whirlwindtemp2/ffresults/NFripsimulation.mat','f','-v7.3')
%load('/media/anna/whirlwindtemp2/ffresults/NFripsimulation.mat','f')


%% style
set(0,'defaultAxesFontSize',14)
set(0,'defaultLineLineWidth',2)


%% PART 1 simulate expected time of trial given prevalence curves and size of trigger 
% makes negligible difference whether you build preprevalence based on just earlycond or pre+earlycond

figure; set(gcf,'Position',[0 0 800 950]); hold on;
smoothingwin = 100;
edges = [0:1:25];
%animcol = [0 .45 .74; .85 .33 .1; .93 .7 .13; .5 .18 .56];
animcol = [115 67 193; 214 83 174; 255 96 135; 255 194 81]./255;

for a = 1:length(animals)
    % calculate pre prevalence (R and W trials together) from early conditioning days (first 5) 
    predata = arrayfun(@(x) x.rips',f(a).output{1},'UniformOutput',0);
    predata = vertcat(predata{:});
    presizes = cell2mat(cellfun(@(x) x.size,predata,'UniformOutput',0));
    totprelength = sum(cellfun(@(x) x.waitlength,predata));
    precounts(a,:) = histcounts(presizes,edges);
    valprevs = find(precounts(a,:)>10);
    preprev(a,:) = precounts(a,:)./totprelength;
    cumprev(a,:) = cumsum(preprev(a,:),'reverse');
    % calculate realdur and sim dur for early and late conditioning
    tde = arrayfun(@(x) x.trialdayep,f(a).output{2},'UniformOutput',0);% stack data from all trials
    tde = vertcat(tde{:});
    trialdata = arrayfun(@(x) x.rips',f(a).output{2},'UniformOutput',0);
    trialdata = vertcat(trialdata{:});
    days = unique(tde(:,1));
    
    for d = 1:length(days)
        ripsizes = cellfun(@(x) x.size,trialdata(tde(:,3)==1 & tde(:,1)==days(d)),'un',0);
        waitlengths = cellfun(@(x) x.waitlength,trialdata(tde(:,3)==1 & tde(:,1)==days(d)),'un',0);
        notempty = ~cellfun(@isempty,ripsizes);
        trigsize = cellfun(@(x) x(end),ripsizes(notempty));
        realdur =cell2mat(waitlengths(notempty));
        trigsize = [trigsize,discretize(trigsize,edges)]; % define which prevalence bin
        valsize = ismember(trigsize(:,2),valprevs);
        realdur = realdur(valsize);
        simdur = 1./cumprev(a,trigsize(valsize,2));
        realmeansem{a}(d,:) =[ mean(realdur),std(realdur)/sqrt(length(realdur))];
        simmeansem{a}(d,:) = [mean(simdur), std(simdur)/sqrt(length(simdur))];
    end
    subplot(1,2,1); hold on;
    h = fill([days; flipud(days)], [realmeansem{a}(:,1)-realmeansem{a}(:,2); flipud(realmeansem{a}(:,1)+realmeansem{a}(:,2))],animcol(a,:),'FaceAlpha',.3);%
    set(h,'EdgeColor','none'); plot(days,realmeansem{a}(:,1),'Color',animcol(a,:),'LineWidth',2); %set(gca,'XScale','log','YScale','log'); grid on;
    h = fill([days; flipud(days)], [simmeansem{a}(:,1)-simmeansem{a}(:,2); flipud(simmeansem{a}(:,1)+simmeansem{a}(:,2))],'k','FaceAlpha',.3);%
    set(h,'EdgeColor','none'); plot(days,simmeansem{a}(:,1),'Color',animcol(a,:),'LineWidth',2); %set(gca,'XScale','log','YScale','log'); grid on;

    % trial by trial alternative plot
    %get size of trigger (final rip) for each rip trial
    subplot(1,2,2); hold on;
    ripsizes = cellfun(@(x) x.size,trialdata(tde(:,3)==1),'un',0);
    waitlengths = cellfun(@(x) x.waitlength,trialdata(tde(:,3)==1),'un',0);
    notempty = ~cellfun(@isempty,ripsizes);
    trigsizes{a} = cellfun(@(x) x(end),ripsizes(notempty));
    realdur = cell2mat(waitlengths(notempty));
    trigsizes{a} = [trigsizes{a},discretize(trigsizes{a},edges)]; % define which prevalence bin
    valsizes = ismember(trigsizes{a}(:,2),valprevs);
    simsizesnonan = trigsizes{a}(valsizes,2);   % get rid of nans (a rip bigger than any oberved in pre period)
    realdurnonan = realdur(valsizes); %   (get rid of those too big rips in the real data set too)
    simdur = 1./cumprev(a,simsizesnonan);
    realsmooth = smooth(padarray(realdurnonan, smoothingwin, 'replicate'),smoothingwin);
    simsmooth = smooth(padarray(simdur', smoothingwin, 'replicate'),smoothingwin);
    plot(realsmooth(smoothingwin:end-smoothingwin),'Color',animcol(a,:),'LineWidth',2); %subplot(1,2,1); hold on; 
    plot(simsmooth(smoothingwin:end-smoothingwin),':','Color',animcol(a,:),'LineWidth',2); %subplot(1,2,2); hold on; 
end
legend({'remy','remysim','gus','gussim','bernard','bernsim','fievel','fievsim'})
title('sim based on earlycond; plot early&latecond; 100trialsmooth' )


%% plot distribution of duration of R/W/S
binedges = [0:.5:60];

figure; hold on;
for a = 1:length(animals)
    tde = arrayfun(@(x) x.trialdayep,f(a).output{1},'UniformOutput',0);% stack data from all trials
    tde = vertcat(tde{:});
    riptmp = arrayfun(@(x) x.rips',f(a).output{1},'UniformOutput',0);  % stack data from all trials
    riptmp = vertcat(riptmp{:});
    ripduration = cellfun(@(x) x.waitlength,riptmp(tde(:,3)==1));
    waitduration = cellfun(@(x) x.waitlength,riptmp(tde(:,3)==2));
    simriptmp = arrayfun(@(x) x.simrips',f(a).output{1},'UniformOutput',0);  % stack data from all trials
    simriptmp = vertcat(simriptmp{:});
    simduration = cellfun(@(x) x.waitlength,simriptmp);
    
    subplot(2,2,a); hold on;
    vdist= histcounts(ripduration,binedges,'Normalization','probability');
    stairs(binedges(1:end-1),vdist,'g','Linewidth',2)
    vdist= histcounts(waitduration,binedges,'Normalization','probability');
    stairs(binedges(1:end-1),vdist,'b','Linewidth',2)
    vdist= histcounts(simduration,binedges,'Normalization','probability');
    stairs(binedges(1:end-1),vdist,'r','Linewidth',2)
    xlabel('home waitlength'); title(animals{a}); ylabel('frac trials')
end

%% plot avg rip size per trial, R/W/S, and prevalence
% problematic because it doensn't include the trials with 0 rips (which are many)
% why is avg size higher?  perhaps a) fewer trials have 0 rips or b) rips during 2s ramp up period are present (related)

edges = [0:.5:20];
avgsize = figure; set(gcf,'Position',[0 0 1800 420])
prev = figure; set(gcf,'Position',[0 0 1800 420])

for a = 1:length(animals)
    tde = arrayfun(@(x) x.trialdayep,f(a).output{1},'UniformOutput',0);% stack data from all trials
    tde = vertcat(tde{:});
    rips = arrayfun(@(x) x.rips',f(a).output{1},'UniformOutput',0);  
    rips = vertcat(rips{:});
    rsizes = cell2mat(cellfun(@(x) mean(x.size),rips(tde(:,3)==1),'UniformOutput',0));
    wsizes = cell2mat(cellfun(@(x) mean(x.size),rips(tde(:,3)==2),'UniformOutput',0));
    totripdur = sum(cellfun(@(x) x.waitlength,rips(tde(:,3)==1)));
    totwaitdur = sum(cellfun(@(x) x.waitlength,rips(tde(:,3)==2)));
    simrips = arrayfun(@(x) x.simrips',f(a).output{1},'UniformOutput',0);  % stack data from all trials
    simrips = vertcat(simrips{:});
    simsizes = cellfun(@(x) mean(x.size),simrips);
    totsimdur = sum(cellfun(@(x) x.waitlength,simrips));
    
    figure(avgsize); subplot(1,5,a); hold on; title(animals{a})   
    rdist= histcounts(rsizes,edges,'Normalization','probability');
    wdist= histcounts(wsizes,edges,'Normalization','probability');
    simdist= histcounts(simsizes,edges,'Normalization','probability');
    stairs(edges(1:end-1),rdist,'g','Linewidth',2); stairs(edges(1:end-1),wdist,'b','Linewidth',2);  stairs(edges(1:end-1),simdist,'r','Linewidth',2);
    plot(nanmedian(rsizes),max(rdist),'gv'); plot(nanmedian(wsizes),max(wdist),'bv'); plot(nanmedian(simsizes),max(simdist),'rv')
    % store data in a big list for boxplots
    alldata{a} = [rsizes,repmat(a,length(rsizes),1),repmat(1,length(rsizes),1); ...
                  wsizes,repmat(a,length(wsizes),1),repmat(2,length(wsizes),1);  ...
                  simsizes,repmat(a,length(simsizes),1),repmat(3,length(simsizes),1);  ];
              
    figure(prev); subplot(1,5,a); hold on; title(animals{a});
    rsizes = cell2mat(cellfun(@(x) x.size,rips(tde(:,3)==1),'UniformOutput',0));
    wsizes = cell2mat(cellfun(@(x) x.size,rips(tde(:,3)==2),'UniformOutput',0));
    rdist= histcounts(rsizes,edges)/totripdur;
    wdist= histcounts(wsizes,edges)/totwaitdur;
    simsizes = cell2mat(cellfun(@(x) x.size,simrips,'UniformOutput',0));
    simdist= histcounts(simsizes,edges)/totsimdur;
    stairs(edges(1:end-1),rdist,'g','Linewidth',2); stairs(edges(1:end-1),wdist,'b','Linewidth',2);  stairs(edges(1:end-1),simdist,'r','Linewidth',2);
    set(gca,'YScale','log');
end
figure(avgsize);
allconcat = vertcat(alldata{:});
subplot(1,5,5); boxplot(allconcat(:,1),allconcat(:,2:3),'Symbol','','Colors','gbr','FactorGap',5);
ylim([0 15]); set(gca,'XTick',[3:4.5:20]); set(gca,'XTickLabel',animals); ylabel('avg rip size/trial'); 

%% plot frac trials with 0 rips 
edges = [0 1 2 50];
figure;
for a = 1:length(animals)
    tde = arrayfun(@(x) x.trialdayep,f(a).output{1},'UniformOutput',0);% stack data from all trials
    tde = vertcat(tde{:});
    rips = arrayfun(@(x) x.rips',f(a).output{1},'UniformOutput',0);  
    rips = vertcat(rips{:});
    simrips = arrayfun(@(x) x.simrips',f(a).output{1},'UniformOutput',0);  % stack data from all trials
    simrips = vertcat(simrips{:});
    fracs(a,:,1) = histcounts(cell2mat(cellfun(@(x) length(x.size),rips(tde(:,3)==1),'UniformOutput',0)),edges,'Normalization','probability');
    fracs(a,:,2) = histcounts(cell2mat(cellfun(@(x) length(x.size),rips(tde(:,3)==2),'UniformOutput',0)),edges,'Normalization','probability');
    fracs(a,:,3) = histcounts(cell2mat(cellfun(@(x) length(x.size),simrips,'UniformOutput',0)),edges,'Normalization','probability');
    subplot(1,3,1); hold on; title('frac 0');
    bar(1+4*(a-1),fracs(a,1,1),'g'); bar(2+4*(a-1),fracs(a,1,2),'b'); bar(3+4*(a-1),fracs(a,1,3),'r');
    subplot(1,3,2); hold on; title('frac 1');
    bar(1+4*(a-1),fracs(a,2,1),'g'); bar(2+4*(a-1),fracs(a,2,2),'b'); bar(3+4*(a-1),fracs(a,2,3),'r');
    subplot(1,3,3); hold on; title('frac >1');
    bar(1+4*(a-1),fracs(a,3,1),'g'); bar(2+4*(a-1),fracs(a,3,2),'b'); bar(3+4*(a-1),fracs(a,3,3),'r');
end

%% plot rip rate across all trials in .5s windows from start
timeedges = [0:.5:20, 22:2:60];
centers = mean([timeedges(1:end-1); timeedges(2:end)]);
toHz = 1./diff(timeedges);
figure; set(gcf,'Position',[0 0 800 950])

for a = 1:length(animals)
    tde = arrayfun(@(x) x.trialdayep,f(a).output{1},'UniformOutput',0);% stack data from all trials
    tde = vertcat(tde{:});
    trialdata = arrayfun(@(x) x.rips',f(a).output{1},'UniformOutput',0);  
    trialdata = vertcat(trialdata{:});
    simrips = arrayfun(@(x) x.simrips',f(a).output{1},'UniformOutput',0);  % stack data from all trials
    simrips = vertcat(simrips{:});
    rripmat = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),trialdata(tde(:,3)==1),'UniformOutput',0));
    rbininclude = cell2mat(cellfun(@(x) x.waitlength>timeedges(1:end-1),trialdata(tde(:,3)==1),'UniformOutput',0));
    wripmat = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),trialdata(tde(:,3)==2),'UniformOutput',0));
    wbininclude = cell2mat(cellfun(@(x) x.waitlength>timeedges(1:end-1),trialdata(tde(:,3)==2),'UniformOutput',0));
    simripmat = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),simrips,'UniformOutput',0));
    simbininclude = cell2mat(cellfun(@(x) x.waitlength>timeedges(1:end-1),simrips,'UniformOutput',0));
    
    for b = 1:length(centers)
        rbinavg(a,b) = toHz(b)*(mean(rripmat(rbininclude(:,b),b)));
        rbinsem(a,b) = toHz(b)*(std(rripmat(rbininclude(:,b),b))/sqrt(sum(rbininclude(:,b))));
        wbinavg(a,b) = toHz(b)*(mean(wripmat(wbininclude(:,b),b)));
        wbinsem(a,b) = toHz(b)*(std(wripmat(wbininclude(:,b),b))/sqrt(sum(wbininclude(:,b))));
        simbinavg(a,b) = toHz(b)*(mean(simripmat(simbininclude(:,b),b)));
        simbinsem(a,b) = toHz(b)*(std(simripmat(simbininclude(:,b),b))/sqrt(sum(simbininclude(:,b))));
    end
    rvalbins(a,:) = sum(rbininclude)>10;
    wvalbins(a,:) = sum(wbininclude)>10;
    simvalbins(a,:) = sum(simbininclude)>10;
       
    subplot(5,1,a); title(sprintf('%s riprate',animals{a})); hold on
    plot([centers(rvalbins(a,:)); centers(rvalbins(a,:))], [rbinavg(a,rvalbins(a,:))-rbinsem(a,rvalbins(a,:)); rbinavg(a,rvalbins(a,:))+rbinsem(a,rvalbins(a,:))],'g','Linewidth',.5);
    plot(centers(rvalbins(a,:)),rbinavg(a,rvalbins(a,:)),'g.')
    plot([centers(wvalbins(a,:)); centers(wvalbins(a,:))], [wbinavg(a,wvalbins(a,:))-wbinsem(a,wvalbins(a,:)); wbinavg(a,wvalbins(a,:))+wbinsem(a,wvalbins(a,:))],'b','Linewidth',.5);
    plot(centers(wvalbins(a,:)),wbinavg(a,wvalbins(a,:)),'b.')
    plot([centers(simvalbins(a,:)); centers(simvalbins(a,:))], [simbinavg(a,simvalbins(a,:))-simbinsem(a,simvalbins(a,:)); simbinavg(a,simvalbins(a,:))+simbinsem(a,simvalbins(a,:))],'r','Linewidth',.5);
    plot(centers(simvalbins(a,:)),simbinavg(a,simvalbins(a,:)),'r.')

end
subplot(5,1,5); hold on; title('mean and sem across rats')
stdev = std(rbinavg)/sqrt(length(animals));
plot([centers(sum(rvalbins)==4); centers(sum(rvalbins)==4)], [mean(rbinavg(:,sum(rvalbins)==4))-stdev(sum(rvalbins)==4); mean(rbinavg(:,sum(rvalbins)==4))+stdev(sum(rvalbins)==4)],'g','Linewidth',.5);
plot(centers(sum(rvalbins)==4),mean(rbinavg(:,sum(rvalbins)==4)),'g.')
stdev = std(wbinavg)/sqrt(length(animals));
plot([centers(sum(wvalbins)==4); centers(sum(wvalbins)==4)], [mean(wbinavg(:,sum(wvalbins)==4))-stdev(sum(wvalbins)==4); mean(wbinavg(:,sum(wvalbins)==4))+stdev(sum(wvalbins)==4)],'b','Linewidth',.5);
plot(centers(sum(wvalbins)==4),mean(wbinavg(:,sum(wvalbins)==4)),'b.')
stdev = std(simbinavg)/sqrt(length(animals));
plot([centers(sum(simvalbins)==4); centers(sum(simvalbins)==4)], [mean(simbinavg(:,sum(simvalbins)==4))-stdev(sum(simvalbins)==4); mean(simbinavg(:,sum(simvalbins)==4))+stdev(sum(simvalbins)==4)],'r','Linewidth',.5);
plot(centers(sum(simvalbins)==4),mean(simbinavg(:,sum(simvalbins)==4)),'r.')

