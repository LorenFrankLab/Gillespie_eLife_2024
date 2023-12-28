%% Neurofeedback: main ripple quantifications; timecourse
% not currently used 
animals = {'remy','gus','bernard','fievel','jaq','roquefort','despereaux','montague'}; %,'gerald'};

epochfilter{1} = [' $ripthresh>=0 & (isequal($environment,''goal'') | isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];
epochfilter{2} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 & $gooddecode==1'];  % for control rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

%args: appendindex (0/1), trialphase ('rw'/'home'/'rw'/'postrw'/'outer'), ripthresh (default 2),
% includelockouts (1/0/-1 include trials with lockouts after rw success/-2 lockouts only/2 outersuccess only) 
% trigwin: amount to remove from RWend to exclude trigger event
% removetrigWtrials (1/0)
f = setfilterfunction(f, 'dfa_ripquantpertrial_allphase', {'ca1rippleskons','trials'}, 'trigwin',0);
f = runfilter(f);

%save('/media/anna/whirlwindtemp2/ffresults/NFtimecourse_allrats.mat','f','-v7.3')
load('/media/anna/whirlwindtemp2/ffresults/NFtimecourse_allrats.mat','f')

%% style
set(0,'defaultAxesFontSize',14)
set(0,'defaultLineLineWidth',1)

animcol = [27 92 41; 25 123 100; 33 159 169; 123 225 191; 83 69 172; 115 101 199; 150 139 222; 190 182 240]./255;  %ctrlcols

%% plot comb riprate per epoch for all animals
clearvars -except f animals animcol
figure
for a = 1:length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    valeps = ~cellfun(@isempty,rwdata); rwdata = rwdata(valeps); postrwdata = postrwdata(valeps);
    for e = 1:length(rwdata)
        combriprates{a}{e} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata{e},postrwdata{e})./cellfun(@(x,y) (x.duration+y.duration),rwdata{e},postrwdata{e});
    end
    subplot(2,1,1); hold on;
    plot(vertcat(combriprates{a}{:}),'Color',animcol(a,:));
    subplot(2,1,2); hold on;
    plot(cellfun(@mean,combriprates{a}),'Color',animcol(a,:));
end


%% plot numrips, duration, rate per trial at each phase per day; 1 figure per animal
phases = {'home','rw','postrw','outer'}; %,'lock'
for a = 1:length(animals)
    tde = arrayfun(@(x) x.index,f(a).output{1},'UniformOutput',0);% stack data from all trials
    newtde = zeros(length(tde),2);
    newtde(~cellfun(@isempty,tde),:) = vertcat(tde{:});
    days{a} = unique(newtde(newtde(:,1)>0,1));
    for d = 1:length(days{a})
        for p = 1:length(phases)
        eval(['phasedata = arrayfun(@(x) x.' phases{p},''',f(a).output{1}(newtde(:,1)==days{a}(d)),''UniformOutput'',0);']);% stack data from all trials
        phasedata = vertcat(phasedata{:});
        if isempty(phasedata)
            continue
        end
        type = cellfun(@(x) x.type,phasedata);
        %type 1
        nummean{a}(p,d,1) = mean(cellfun(@(x) length(x.size),phasedata(type==1)));
        numstd{a}(p,d,1) = std(cellfun(@(x) length(x.size),phasedata(type==1)));
        durmean{a}(p,d,1) = mean(cellfun(@(x) x.duration,phasedata(type==1)));
        durstd{a}(p,d,1) = std(cellfun(@(x) x.duration,phasedata(type==1)));
        ratemean{a}(p,d,1) = nanmean(cellfun(@(x) length(x.size),phasedata(type==1))./cellfun(@(x) x.duration,phasedata(type==1)));
        ratestd{a}(p,d,1) = nanstd(cellfun(@(x) length(x.size),phasedata(type==1))./cellfun(@(x) x.duration,phasedata(type==1)));
        %type 2
        if any(type~=1) % if the classifier is relevant
            nummean{a}(p,d,2) = mean(cellfun(@(x) length(x.size),phasedata(type~=1)));
            numstd{a}(p,d,2) = std(cellfun(@(x) length(x.size),phasedata(type~=1)));
            durmean{a}(p,d,2) = mean(cellfun(@(x) x.duration,phasedata(type~=1)));
            durstd{a}(p,d,2) = std(cellfun(@(x) x.duration,phasedata(type~=1)));
            ratemean{a}(p,d,2) = nanmean(cellfun(@(x) length(x.size),phasedata(type~=1))./cellfun(@(x) x.duration,phasedata(type~=1)));
            ratestd{a}(p,d,2) = nanstd(cellfun(@(x) length(x.size),phasedata(type~=1))./cellfun(@(x) x.duration,phasedata(type~=1)));
        end
        end
    end
    %figure; set(gcf,'Position',[0 0 900 950])
    for p = 1:length(phases)
        if p==1 | p==5
        subplot(4,3,1+3*(p-1)); hold on; title('num rips'); ylabel(phases{p}); ylim([0 inf])
        %errorbar(days{a}, nummean{a}(p,:,1),numstd{a}(p,:,1),'k.')
        plot(days{a}, nummean{a}(p,:,1),'Color',animcol(a,:));
        subplot(4,3,2+3*(p-1)); hold on; title('duration'); ylim([0 inf])
        %errorbar(days{a}, durmean{a}(p,:,1),durstd{a}(p,:,1),'k.')
        plot(days{a}, durmean{a}(p,:,1),'Color',animcol(a,:));
        subplot(4,3,3+3*(p-1)); hold on; title('riprate'); ylim([0 1])
        %errorbar(days{a}, ratemean{a}(p,:,1),ratestd{a}(p,:,1),'k.')
        plot(days{a}, ratemean{a}(p,:,1),'Color',animcol(a,:));
        elseif p==4
            subplot(4,3,1+3*(p-1)); hold on; title('num rips'); ylabel([animals{a} phases{p}]); ylim([0 inf])
            %errorbar(days{a}, nummean{a}(p,:,1),numstd{a}(p,:,1),'k.'); errorbar(days{a}, nummean{a}(p,:,2),numstd{a}(p,:,2),'k.')
            plot(days{a}, nummean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); plot(days{a}, nummean{a}(p,:,2),'Color',animcol(a,:));
            subplot(4,3,2+3*(p-1)); hold on; title('duration'); ylim([0 inf])
            %errorbar(days{a}, durmean{a}(p,:,1),durstd{a}(p,:,1),'k.'); errorbar(days{a}, durmean{a}(p,:,2),durstd{a}(p,:,2),'k.')
            plot(days{a}, durmean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); plot(days{a}, durmean{a}(p,:,2),'Color',animcol(a,:));
            subplot(4,3,3+3*(p-1)); hold on; title('riprate'); ylim([0 1])
            %errorbar(days{a}, ratemean{a}(p,:,1),ratestd{a}(p,:,1),'k.'); errorbar(days{a}, ratemean{a}(p,:,2),ratestd{a}(p,:,2),'k.')
            plot(days{a}, ratemean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); plot(days{a}, ratemean{a}(p,:,2),'Color',animcol(a,:));
        else 
            subplot(4,3,1+3*(p-1)); hold on; title('num rips'); ylabel([animals{a} phases{p}]); ylim([0 inf])
            %errorbar(days{a}, nummean{a}(p,:,1),numstd{a}(p,:,1),'k.'); errorbar(days{a}, nummean{a}(p,:,2),numstd{a}(p,:,2),'k.')
            plot(days{a}, nummean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); 
            plot(days{a}, nummean{a}(p,:,2),'Color',animcol(a,:));
            subplot(4,3,2+3*(p-1)); hold on; title('duration'); ylim([0 inf])
            %errorbar(days{a}, durmean{a}(p,:,1),durstd{a}(p,:,1),'k.'); errorbar(days{a}, durmean{a}(p,:,2),durstd{a}(p,:,2),'k.')
            plot(days{a}, durmean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); 
            plot(days{a}, durmean{a}(p,:,2),'Color',animcol(a,:));
            subplot(4,3,3+3*(p-1)); hold on; title('riprate'); ylim([0 1])
            %errorbar(days{a}, ratemean{a}(p,:,1),ratestd{a}(p,:,1),'k.'); errorbar(days{a}, ratemean{a}(p,:,2),ratestd{a}(p,:,2),'k.')
            plot(days{a}, ratemean{a}(p,:,1),'Color',animcol(a,:),'Marker','.'); 
            plot(days{a}, ratemean{a}(p,:,2),'Color',animcol(a,:));
        end
    end
end
  
%% plot ratio of riprate at rip vs wait
clearvars -except f animals animcol
figure; hold on;
for a = 1:4%length(animals)
    tde = arrayfun(@(x) x.index,f(a).output{1},'UniformOutput',0);% stack data from all trials
    newtde = zeros(length(tde),2);
    newtde(~cellfun(@isempty,tde),:) = vertcat(tde{:});
    days{a} = unique(newtde(newtde(:,1)>0,1));
    for d = 1:length(days{a})
        
        homedata = arrayfun(@(x) x.home',f(a).output{1}(newtde(:,1)==days{a}(d)),'UniformOutput',0); % stack data from all epochs
        homedata = vertcat(homedata{:});
        rwdata = arrayfun(@(x) x.rw',f(a).output{1}(newtde(:,1)==days{a}(d)),'UniformOutput',0); % stack data from all epochs
        rwdata = vertcat(rwdata{:});
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{1}(newtde(:,1)==days{a}(d)),'UniformOutput',0); % stack data from all epochs
        postrwdata = vertcat(postrwdata{:});
        if isempty(rwdata)
            continue
        end
        type = cellfun(@(x) x.type,rwdata);
        %type 1
        rwratemean{a}(d,1) = nanmean(cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1)));
        postrwratemean{a}(d,1) = nanmean(cellfun(@(x) length(x.size),postrwdata(type==1))./cellfun(@(x) x.duration,postrwdata(type==1)));
        boxratemean{a}(d,1) = nanmean(cellfun(@(x,y,z) length([x.size;y.size;z.size]),homedata(type==1),rwdata(type==1),postrwdata(type==1))./cellfun(@(x,y,z) sum([x.duration,y.duration,z.duration]),homedata(type==1),rwdata(type==1),postrwdata(type==1)));
        %type 2
        if any(type~=1) % if the classifier is relevant
         rwratemean{a}(d,2) = nanmean(cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2)));
        postrwratemean{a}(d,2) = nanmean(cellfun(@(x) length(x.size),postrwdata(type==2))./cellfun(@(x) x.duration,postrwdata(type==2)));
        boxratemean{a}(d,2) = nanmean(cellfun(@(x,y,z) length([x.size;y.size;z.size]),homedata(type==2),rwdata(type==2),postrwdata(type==2))./cellfun(@(x,y,z) sum([x.duration,y.duration,z.duration]),homedata(type==2),rwdata(type==2),postrwdata(type==2)));
        end
    end
    rwratio{a} = rwratemean{a}(:,1)./rwratemean{a}(:,2);
    postrwratio{a} = postrwratemean{a}(:,1)./postrwratemean{a}(:,2);
    boxratio{a} = boxratemean{a}(:,1)./boxratemean{a}(:,2);
   subplot(3,1,1); hold on; xlabel('day'); ylabel('rip:wait rate ratio (RWonly)')
   plot(rwratio{a},'Color',animcol(a,:),'LineWidth',2)
   subplot(3,1,2); hold on; xlabel('day'); ylabel('rip:wait rate ratio (post)')
   plot(postrwratio{a},'Color',animcol(a,:),'LineWidth',2)
   subplot(3,1,3); hold on; xlabel('day'); ylabel('rip:wait rate ratio (box)')
   plot(boxratio{a},'Color',animcol(a,:),'LineWidth',2)

end
subplot(3,1,1); plot([0 32],[1 1],':'); 
subplot(3,1,2); plot([0 32],[1 1],':'); 
subplot(3,1,3); plot([0 32],[1 1],':'); 

%% plot size of trigger rip (last event) over training

clearvars -except f animals
animcol = [254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  
smoothingwin = 100;
figure; hold on;
for a = 1:4%length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{1},'UniformOutput',0); % stack data from all trials
    rwdata = rwdata(~cellfun(@isempty,rwdata));
             %     % only use the second half of trials from each epoch
rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
for e = 1:length(rwdata)
        type = cellfun(@(x) x.type,rwdata{e});
        norips = cellfun(@(x) isempty(x.size),rwdata{e});
        trigsizes{a}{e} = cellfun(@(x) x.size(end),rwdata{e}(type==1 & ~norips));
        meantrigsize{a}(e) = median(trigsizes{a}{e});
end
    subplot(1,2,1); hold on; plot(meantrigsize{a},'Color',animcol(a,:))
    smoothedtrigsize = smooth(padarray(vertcat(trigsizes{a}{:}), smoothingwin, 'replicate'),smoothingwin);
    subplot(1,2,2); hold on; plot(smoothedtrigsize,'Color',animcol(a,:)); 


    %subplot(4,2,2*(a-1)+1); hold on; plot(vertcat(trigsizes{a}{:}),'.'); 
    %plot(repmat(cumsum(cellfun(@length,trigsizes{a})),2,1),repmat([0;30],1,d),'k:'); ylabel({animals{a},'trig size'})
end

%% plot performance over timecourse


%% plot numrips, duration, rate per trial at each phase; 1 figure per animal; smoothed across trials, not by day BROKEN

phases = {'home','rw','postrw','outer'}; %,'lock'
smoothingwin = 200; % #trials
kernel = repmat(1/smoothingwin,1,smoothingwin);
figure; set(gcf,'Position',[0 0 900 950]);
for a = 1:length(animals)
    tde = arrayfun(@(x) x.index,f(a).output{1},'UniformOutput',0);% stack data from all trials
    newtde = zeros(length(tde),2);
    newtde(~cellfun(@isempty,tde),:) = vertcat(tde{:});
        for p = 1:length(phases)
        eval(['phasedata = arrayfun(@(x) x.' phases{p},''',f(a).output{1},''UniformOutput'',0);']);% stack data from all trials
        phasedata = vertcat(phasedata{:});
        type = cellfun(@(x) x.type,phasedata);
        %type 1
        nummean1 = filter(kernel, 1, cellfun(@(x) length(x.size),phasedata(type==1)));
        durmean1 = filter(kernel, 1, cellfun(@(x) x.duration,phasedata(type==1)));
        ratemean1 = filter(kernel, 1, cellfun(@(x) length(x.size),phasedata(type==1))./cellfun(@(x) x.duration,phasedata(type==1)));
        subplot(5,3,1+3*(p-1)); hold on; h1 = plot(nummean1); title('numrips'); ylabel(phases{p});
        subplot(5,3,2+3*(p-1)); hold on; h2 = plot(durmean1); title('duration'); 
        subplot(5,3,3+3*(p-1)); hold on; h3 = plot(ratemean1); title('rate');
        if p==2 | p==3
            set([h1 h2 h3],'Color','g'); 
        elseif p==4
            set([h1 h2 h3],'Color','y'); 
        end
        %type 2
        if any(type~=1) % if the classifier is relevant
            nummean2 = filter(kernel, 1, cellfun(@(x) length(x.size),phasedata(type~=1)));
            durmean2 = filter(kernel, 1, cellfun(@(x) x.duration,phasedata(type~=1)));
            ratemean2 = filter(kernel, 1, cellfun(@(x) length(x.size),phasedata(type~=1))./cellfun(@(x) x.duration,phasedata(type~=1)));
            subplot(5,3,1+3*(p-1)); hold on; h1 = plot(nummean2);
            subplot(5,3,2+3*(p-1)); hold on; h2 = plot(durmean2);
            subplot(5,3,3+3*(p-1)); hold on; h3 = plot(ratemean2);
            if p==2 | p==3
                set([h1 h2 h3],'Color','b');
            elseif p==4
                set([h1 h2 h3],'Color','k');
            end
        end
        end
    end


