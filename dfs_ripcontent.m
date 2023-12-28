%% rip conditioning: main content analyses
% focus on post-conditioning, since that's when we have good quality decoding
% relationship between behavior and rips/replay goes here, since we have behavior outputs 

animals = {'remy','gus','bernard','fievel'}; %,'jaq','roquefort','despereaux','montague','gerald'

epochfilter{1} = ['(isequal($cond_phase,''plateau'')) & $ripthresh>=0 & $gooddecode==1'];  % for conditioning rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';

f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);
f = setfilterfunction(f, 'dfa_ripcontent_nf', {'ripdecodesv3','trials','pos'});
f = runfilter(f);

%animcol = [83 69 172; 115 101 199; 150 139 222; 190 182 240; 27 92 41; 25 123 100; 33 159 169; 123 225 191]./255;  %ctrlcols
ripcols = [254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
waitcols = [148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;
%% Plot fraction of RW events that are coherent(not fragmented), local, rate & # of remote replay, fractions for trig events 
clearvars -except f animals 
cols = [1 0 0; 0 0 0];
trigs = figure(); set(gcf,'Position',[46 71 1108 861]); coh = figure(); set(gcf,'Position',[46 71 1108 861]); 
rrates = figure(); set(gcf,'Position',[46 71 1108 861]); nums = figure(); set(gcf,'Position',[46 71 1108 861]); 
contentthresh = .3;
for a = 1:length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{1},'UniformOutput',0); % stack data from all trials
     for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = tripdata{e}.RWripcontent(valtrials);
        rwtypes = tripdata{e}.RWripmaxtypes(valtrials); %
        durations = tripdata{e}.RWwaitlength(valtrials);
        goals = tripdata{e}.goalarm(valtrials,:);
        goals(tphasenum(:,1)<=1,1) = nan; % turn currgoals during search trials into nans
        goals(goals(:,1)==0,1) = nan;
        outers = tripdata{e}.outerarm(valtrials);
        pastwlock = tripdata{e}.prevarm(valtrials,2);  % only consider the including lockout option
        trialstack  = [outers', pastwlock, goals,tphasenum(:,[1,3])];
        clear rwreplays
        % salient - can be past, future, or any previously rewarded arm OR just any previously rewarded arm (p/f not salient)(as for FIG7A)
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype salient local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                %rwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1), ismember(ind(valid)-1,[trialstack(t,1:2),unique(goals(1:t,1))']),ind(valid)-1==0];
                rwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1), ismember(ind(valid)-1,[unique(goals(1:t,1))']),ind(valid)-1==0];
            else rwreplays{t} = []; end
        end
        allrw{a}{e} = vertcat(rwreplays{:});
        %separate rip and wait trials
        allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,8)==1,:);
        allw{a}{e} = allrw{a}{e}(allrw{a}{e}(:,8)==2,:);
        fraccohrw{a}(e,:) = [size(allr{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==1))), ...
            size(allw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==2)))] ;
        fracremoterw{a}(e,:) = [sum(allr{a}{e}(:,10)==0)/size(allr{a}{e},1),sum(allw{a}{e}(:,10)==0)/size(allw{a}{e},1)]; % out of ALL detected SWRSsize(allreplay,1)
        
        %separate trigger events on rip trials
        alltrigs = cell2mat(cellfun(@(x) x(end,:)',rwreplays(tphasenum(:,3)'==1 & ~cellfun(@isempty,rwreplays)),'un',0))';
        nontrigs = cell2mat(cellfun(@(x) x(1:end-1,:)',rwreplays(tphasenum(:,3)'==1 & ~cellfun(@isempty,rwreplays)),'un',0))';
        fraccoh_trigs{a}(e) = size(alltrigs,1)/sum(tphasenum(:,3)==1);
        fracremote_trigs{a}(e) = sum(alltrigs(:,10)==0)/size(alltrigs,1);
        fraccoh_nontrigs{a}(e) = size(nontrigs,1)/(size(vertcat(rwrips{tphasenum(:,3)==1}),1)-sum(tphasenum(:,3)==1));
        fracremote_nontrigs{a}(e) = sum(nontrigs(:,10)==0)/size(nontrigs,1);

        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        ripreplayrates{a}{e} = replayrates(tphasenum(:,3)==1);
        waitreplayrates{a}{e} = replayrates(tphasenum(:,3)==2);
        
        replaynums = zeros(length(rwreplays),1);  % initialize to preserve zero-count trials
        replaynums(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)));
        ripreplaynums{a}{e} = replaynums(tphasenum(:,3)==1);
        waitreplaynums{a}{e} = replaynums(tphasenum(:,3)==2);
     end
     figure(coh); hold on;     
     plot(repmat([a,a+.25],size(fraccohrw{a},1),1)',fraccohrw{a}','Color',[.8 .8 .8])
     boxplot(fraccohrw{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(fraccohrw{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Fraction ');
     [h,p] = ttest(fraccohrw{a}(:,1),fraccohrw{a}(:,2));
     text(a,.7,sprintf('tp=%.05f\nn=%deps',p,size(fraccohrw{a},1))); ylim([0 1])
     
     plot(repmat([a,a+.25],size(fracremoterw{a},1),1)',fracremoterw{a}','Color',[.8 .8 .8])
     boxplot(fracremoterw{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:)); 
     boxplot(fracremoterw{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Fraction remote/allcoherent');
     [h,p] = ttest(fracremoterw{a}(:,1),fracremoterw{a}(:,2));
     text(a,.05,sprintf('tp=%.05f\nn=%deps',p,size(fracremoterw{a},1))); ylim([0 1])
     title('upper:fraction coherent/allSWRs; lower:frac remote/allcoh')

     figure(trigs); hold on     
     plot(repmat([a,a+.25],size(fraccohrw{a},1),1)',[fraccoh_nontrigs{a};fraccoh_trigs{a}],'Color',[.8 .8 .8])
     boxplot(fraccoh_nontrigs{a},'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(fraccoh_trigs{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',[.5 0 .5])
     xlim([.5 4.5]); ylabel('Fraction');
     [h,p] = ttest(fraccoh_nontrigs{a},fraccoh_trigs{a});
     text(a,.7,sprintf('tp=%.05f\nn=%deps',p,size(fraccohrw{a},1))); ylim([0 1])
     
     plot(repmat([a,a+.25],size(fracremote_nontrigs{a},1),1)',[fracremote_nontrigs{a};fracremote_trigs{a}],'Color',[.8 .8 .8])
     boxplot(fracremote_nontrigs{a},'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:)); 
     boxplot(fracremote_trigs{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',[.5 0 .5])
     xlim([.5 4.5]); ylabel('Fraction remote/allcoherent');
     [h,p] = ttest(fracremote_nontrigs{a},fracremote_trigs{a});
     text(a,.05,sprintf('tp=%.05f\nn=%deps',p,size(fracremoterw{a},1))); ylim([0 1])
     title('nontrigs vs trigs(purple) upper:frac coh/allSWRs; lower:frac remote/allcoh')

     figure(rrates);  hold on;
     %boxplot(vertcat(ripreplayrates{a}{:}),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))   %trialwise!
     %boxplot(vertcat(waitreplayrates{a}{:}),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     plot(repmat([a,a+.25],length(ripreplayrates{a}),1)',[cellfun(@mean,ripreplayrates{a});cellfun(@mean,waitreplayrates{a})],'Color',[.8 .8 .8])
     boxplot(cellfun(@mean,ripreplayrates{a}),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))    % epwise
     boxplot(cellfun(@mean,waitreplayrates{a}),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Replay rate (Hz)'); ylim([0 .5])
     [h,p] = ttest(cellfun(@mean,ripreplayrates{a}),cellfun(@mean,waitreplayrates{a})); 
     text(a,.2+a/10,sprintf('tp=%.04f\nn=%deps',p,length(ripreplayrates{a})));
     %p = ranksum(vertcat(ripreplayrates{a}{:}),vertcat(waitreplayrates{a}{:})); 
     %text(a,.5+a/10,sprintf('p=%d\nn=%d,%d trials',p,length(vertcat(ripreplayrates{a}{:})),length(vertcat(waitreplayrates{a}{:}))));
    title('remote replay rate (including trigger events)')
     
     figure(nums); hold on     
     plot(repmat([a,a+.25],length(ripreplaynums{a}),1)',[cellfun(@mean,ripreplaynums{a});cellfun(@mean,waitreplaynums{a})],'Color',[.8 .8 .8])
     boxplot(cellfun(@mean,ripreplaynums{a}),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))    % epwise
     boxplot(cellfun(@mean,waitreplaynums{a}),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Replay Count'); ylim([0 5])
     [h,p] = ttest(cellfun(@mean,ripreplaynums{a}),cellfun(@mean,waitreplaynums{a})); 
     text(a,2+a/5,sprintf('tp=%.04f\nn=%deps',p,length(ripreplaynums{a})));
   title('remote replay count (including trigger events)')
 end

%%  fit glm for arm categories, r vs w
clearvars -except f animals animcol
contentthresh = .3;
figure;  set(gcf,'Position',[90 262 1822 697]); 
cols = [1 0 0; 0 0 0];
for a = 1:length(animals)
    eps = find(arrayfun(@(x) ~isempty(x.trips),f(a).output{1}));
    for e = 1:length(eps)
        tphasenum = f(a).output{1}(eps(e)).trips.taskphase;
        goals = f(a).output{1}(eps(e)).trips.goalarm;
        valtrials = ~isnan(tphasenum) & ~isnan(goals(:,2));
        goals = goals(valtrials,:);
        trialtype = f(a).output{1}(eps(e)).trips.trialtype(valtrials);     
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]'];   % add trial numbers
        rwrips = f(a).output{1}(eps(e)).trips.RWripcontent(valtrials);
        rwtypes = f(a).output{1}(eps(e)).trips.RWripmaxtypes(valtrials); %
        clear replays 
        for t=1:length(rwrips)
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                replays{t} = ind(valid)'-1; %
            else replays{t} = []; end
        end
        if any(valtrials) & ~isempty(rwrips)
        outers = f(a).output{1}(eps(e)).trips.outerarm(valtrials);
        pastwlock = f(a).output{1}(eps(e)).trips.prevarm(valtrials,2);  % only consider the including lockout option
        countspertrial = zeros(8,length(outers));
        countspertrial(:,~cellfun(@isempty,replays)) = cell2mat(cellfun(@(x) histcounts(x,[1:9])',replays(~cellfun(@isempty,replays)),'un',0));
        future = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(outers),'un',0));
        past = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(pastwlock'),'un',0));
        prevgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,2)'),'un',0));
        currgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,1)'),'un',0));

            allsearch_rip{a,1}{e} = [reshape(future(:,tphasenum(:,1)<=1 & trialtype==1),[],1),reshape(past(:,tphasenum(:,1)<=1 & trialtype==1),[],1),reshape(prevgoal(:,tphasenum(:,1)<=1 & trialtype==1),[],1) ...
                    reshape(countspertrial(:,tphasenum(:,1)<=1 & trialtype==1),[],1)]; % [future past prevgoal #replays];
            allrepeat_rip{a,1}{e} = [reshape(future(:,tphasenum(:,1)>1 & trialtype==1),[],1),reshape(past(:,tphasenum(:,1)>1 & trialtype==1),[],1),reshape(currgoal(:,tphasenum(:,1)>1 & trialtype==1),[],1) ...
                    ,reshape(prevgoal(:,tphasenum(:,1)>1 & trialtype==1),[],1), reshape(countspertrial(:,tphasenum(:,1)>1 & trialtype==1),[],1)]; % [future past currgoal prevgoal #replays];
            allsearch_wait{a,1}{e} = [reshape(future(:,tphasenum(:,1)<=1 & trialtype==2),[],1),reshape(past(:,tphasenum(:,1)<=1 & trialtype==2),[],1),reshape(prevgoal(:,tphasenum(:,1)<=1 & trialtype==2),[],1) ...
                    reshape(countspertrial(:,tphasenum(:,1)<=1 & trialtype==2),[],1)]; % [future past prevgoal #replays];
            allrepeat_wait{a,1}{e} = [reshape(future(:,tphasenum(:,1)>1 & trialtype==2),[],1),reshape(past(:,tphasenum(:,1)>1 & trialtype==2),[],1),reshape(currgoal(:,tphasenum(:,1)>1 & trialtype==2),[],1) ...
                    ,reshape(prevgoal(:,tphasenum(:,1)>1 & trialtype==2),[],1), reshape(countspertrial(:,tphasenum(:,1)>1 & trialtype==2),[],1)]; % [future past currgoal prevgoal #replays];
        end
    end
    searchcat_rip{a} = vertcat(allsearch_rip{a}{:});
    searchtbl_rip = table(searchcat_rip{a}(:,2),searchcat_rip{a}(:,1),searchcat_rip{a}(:,3),searchcat_rip{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    s_mdl_rip = fitglm(searchtbl_rip,'linear','Distribution','poisson');
    CI_rip = coefCI(s_mdl_rip,.01);
    subplot(3,1,1); hold on; title('allsearch')
    plot(a+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(s_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([a+[0:length(animals)+8:3*(length(animals)+8)];a+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_rip)','Color',cols(1,:));
    text(5,2+.2*a,['Rtrial n=',num2str(size(searchcat_rip{a},1)/8)],'Color',cols(1,:));
    searchcat_wait{a} = vertcat(allsearch_wait{a}{:});
    searchtbl_wait = table(searchcat_wait{a}(:,2),searchcat_wait{a}(:,1),searchcat_wait{a}(:,3),searchcat_wait{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    s_mdl_wait = fitglm(searchtbl_wait,'linear','Distribution','poisson');
    CI_wait = coefCI(s_mdl_wait,.01);
    plot(a+4+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(s_mdl_wait.Coefficients(:,1))),'o','MarkerSize',5,'Color',cols(2,:));
    plot([a+4+[0:length(animals)+8:3*(length(animals)+8)];a+4+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_wait)','Color',cols(2,:));
    text(15,2+.2*a,['Wtrial n=',num2str(size(searchcat_wait{a},1)/8)],'Color',cols(2,:));
    
    subplot(3,1,2); hold on; title('allrepeat')
    repeatcat_rip{a} = vertcat(allrepeat_rip{a}{:});
    reptbl_rip = table(repeatcat_rip{a}(:,2),repeatcat_rip{a}(:,1),repeatcat_rip{a}(:,3),repeatcat_rip{a}(:,4),repeatcat_rip{a}(:,5),'VariableNames',{'past','future','currgoal','prevgoal','replaynum'});
    r_mdl_rip = fitglm(reptbl_rip,'linear','Distribution','poisson'); 
    CI_rip = coefCI(r_mdl_rip,.01);
    plot(a+[0:length(animals)+8:4*(length(animals)+8)],exp(table2array(r_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([a+[0:length(animals)+8:4*(length(animals)+8)];a+[0:length(animals)+8:4*(length(animals)+8)]],exp(CI_rip)','Color',cols(1,:));
    text(5,2+.2*a,['Rtrial n=',num2str(size(repeatcat_rip{a},1)/8)],'Color',cols(1,:));
    repeatcat_wait{a} = vertcat(allrepeat_wait{a}{:});
    reptbl_wait = table(repeatcat_wait{a}(:,2),repeatcat_wait{a}(:,1),repeatcat_wait{a}(:,3),repeatcat_wait{a}(:,4),repeatcat_wait{a}(:,5),'VariableNames',{'past','future','currgoal','prevgoal','replaynum'});
    r_mdl_wait = fitglm(reptbl_wait,'linear','Distribution','poisson'); 
    CI_wait = coefCI(r_mdl_wait,.01);
    plot(a+4+[0:length(animals)+8:4*(length(animals)+8)],exp(table2array(r_mdl_wait.Coefficients(:,1))),'o','MarkerSize',5,'Color',cols(2,:));
    plot([a+4+[0:length(animals)+8:4*(length(animals)+8)];a+4+[0:length(animals)+8:4*(length(animals)+8)]],exp(CI_wait)','Color',cols(2,:));
    text(18,2+.2*a,['Wtrial n=',num2str(size(repeatcat_wait{a},1)/8)],'Color',cols(2,:));
    
    subplot(3,1,3); hold on; title('search+repeat')
    %just use past future prevgoal only
    bothtbl_rip = table([searchcat_rip{a}(:,2); repeatcat_rip{a}(:,2)],[searchcat_rip{a}(:,1);repeatcat_rip{a}(:,1)],[searchcat_rip{a}(:,3);repeatcat_rip{a}(:,4)],[searchcat_rip{a}(:,4);repeatcat_rip{a}(:,5)],'VariableNames',{'past','future','prevgoal','replaynum'});
    r_mdl_rip = fitglm(bothtbl_rip,'linear','Distribution','poisson'); 
    CI_rip = coefCI(r_mdl_rip,.01);
    plot(15*(a-1)+[1 4 7 10],exp(table2array(r_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([15*(a-1)+[1 4 7 10];15*(a-1)+[1 4 7 10]],exp(CI_rip)','Color',cols(1,:));
    text(1+15*(a-1),2,['Rtrial n=',num2str(length([searchcat_rip{a}(:,1);repeatcat_rip{a}(:,1)])/8)],'Color',cols(1,:));
    bothtbl_wait = table([searchcat_wait{a}(:,2); repeatcat_wait{a}(:,2)],[searchcat_wait{a}(:,1);repeatcat_wait{a}(:,1)],[searchcat_wait{a}(:,3);repeatcat_wait{a}(:,4)],[searchcat_wait{a}(:,4);repeatcat_wait{a}(:,5)],'VariableNames',{'past','future','prevgoal','replaynum'});
    r_mdl_wait = fitglm(bothtbl_wait,'linear','Distribution','poisson'); 
    CI_wait = coefCI(r_mdl_wait,.01);
    plot(15*(a-1)+[2 5 8 11],exp(table2array(r_mdl_wait.Coefficients(:,1))),'o','MarkerSize',5,'Color',cols(2,:));
    plot([15*(a-1)+[2 5 8 11];15*(a-1)+[2 5 8 11]],exp(CI_wait)','Color',cols(2,:));
    text(1+15*(a-1),2.5,['Wtrial n=',num2str(length([searchcat_wait{a}(:,1);repeatcat_wait{a}(:,1)])/8)],'Color',cols(2,:));

end
subplot(3,1,1); ylabel('exp(beta)'); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:3*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','prevgoal'})
plot([0 50],[1 1],'k:'); set(gca,'YScale','log'); ylim([.01 5]); xlim([0 50]);
subplot(3,1,2); set(gca,'YScale','log'); ylim([.01 5]); xlim([0 60]); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:4*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','curgoal','prevgoal'})
plot([0 60],[1 1],'k:');
subplot(3,1,3); set(gca,'YScale','log'); ylim([.2 4]); xlim([0 60]); ylabel('axis .2-4')
plot([0 60],[1 1],'k:');


%% GLM for only trigger events on R trials  
clearvars -except f animals animcol
contentthresh = .3;
figure;  set(gcf,'Position',[90 262 1822 697]); 
cols = [1 0 0; 0 0 0];
for a = 1:length(animals)
    eps = find(arrayfun(@(x) ~isempty(x.trips),f(a).output{1}));
    for e = 1:length(eps)
        tphasenum = f(a).output{1}(eps(e)).trips.taskphase;
        goals = f(a).output{1}(eps(e)).trips.goalarm;
        valtrials = ~isnan(tphasenum) & ~isnan(goals(:,2)); 
        goals = goals(valtrials,:);
        trialtype = f(a).output{1}(eps(e)).trips.trialtype(valtrials);     
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]'];   % add trial numbers
        rwrips = f(a).output{1}(eps(e)).trips.RWripcontent(valtrials);
        rwtypes = f(a).output{1}(eps(e)).trips.RWripmaxtypes(valtrials); %
        clear replays 
        for t=1:length(rwrips)
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                replays{t} = ind(valid)'-1; %
                %keep only the last event of each trial
                if ~isempty(replays{t})
                replays{t} = replays{t}(end);
                end
            else replays{t} = []; end
        end
        if any(valtrials) & ~isempty(rwrips)
        outers = f(a).output{1}(eps(e)).trips.outerarm(valtrials);
        pastwlock = f(a).output{1}(eps(e)).trips.prevarm(valtrials,2);  % only consider the including lockout option
        countspertrial = zeros(8,length(outers));
        countspertrial(:,~cellfun(@isempty,replays)) = cell2mat(cellfun(@(x) histcounts(x,[1:9])',replays(~cellfun(@isempty,replays)),'un',0));
        future = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(outers),'un',0));
        past = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(pastwlock'),'un',0));
        prevgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,2)'),'un',0));
        currgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,1)'),'un',0));
            allsearch_rip{a,1}{e} = [reshape(future(:,tphasenum(:,1)<=1 & trialtype==1),[],1),reshape(past(:,tphasenum(:,1)<=1 & trialtype==1),[],1),reshape(prevgoal(:,tphasenum(:,1)<=1 & trialtype==1),[],1) ...
                    reshape(countspertrial(:,tphasenum(:,1)<=1 & trialtype==1),[],1)]; % [future past prevgoal #replays];
            allrepeat_rip{a,1}{e} = [reshape(future(:,tphasenum(:,1)>1 & trialtype==1),[],1),reshape(past(:,tphasenum(:,1)>1 & trialtype==1),[],1),reshape(currgoal(:,tphasenum(:,1)>1 & trialtype==1),[],1) ...
                    ,reshape(prevgoal(:,tphasenum(:,1)>1 & trialtype==1),[],1), reshape(countspertrial(:,tphasenum(:,1)>1 & trialtype==1),[],1)]; % [future past currgoal prevgoal #replays];
        end
    end
    searchcat_rip{a} = vertcat(allsearch_rip{a}{:});
    searchtbl_rip = table(searchcat_rip{a}(:,2),searchcat_rip{a}(:,1),searchcat_rip{a}(:,3),searchcat_rip{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    s_mdl_rip = fitglm(searchtbl_rip,'linear','Distribution','poisson');
    CI_rip = coefCI(s_mdl_rip,.01);
    subplot(3,1,1); hold on; title('search r trial triggers only')
    plot(a+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(s_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([a+[0:length(animals)+8:3*(length(animals)+8)];a+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_rip)','Color',cols(1,:));
    text(5,2+.2*a,['Rtrial n=',num2str(size(searchcat_rip{a},1)/8)],'Color',cols(1,:));
        
    subplot(3,1,2); hold on; title('repeat, r trial triggers only')
    repeatcat_rip{a} = vertcat(allrepeat_rip{a}{:});
    reptbl_rip = table(repeatcat_rip{a}(:,2),repeatcat_rip{a}(:,1),repeatcat_rip{a}(:,3),repeatcat_rip{a}(:,4),repeatcat_rip{a}(:,5),'VariableNames',{'past','future','currgoal','prevgoal','replaynum'});
    r_mdl_rip = fitglm(reptbl_rip,'linear','Distribution','poisson'); 
    CI_rip = coefCI(r_mdl_rip,.01);
    plot(a+[0:length(animals)+8:4*(length(animals)+8)],exp(table2array(r_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([a+[0:length(animals)+8:4*(length(animals)+8)];a+[0:length(animals)+8:4*(length(animals)+8)]],exp(CI_rip)','Color',cols(1,:));
    text(5,2+.2*a,['Rtrial n=',num2str(size(repeatcat_rip{a},1)/8)],'Color',cols(1,:));
    
    subplot(3,1,3); hold on; title('search+repeat, r trial triggers only')
    bothtbl_rip = table([searchcat_rip{a}(:,2); repeatcat_rip{a}(:,2)],[searchcat_rip{a}(:,1);repeatcat_rip{a}(:,1)],[searchcat_rip{a}(:,3);repeatcat_rip{a}(:,4)],[searchcat_rip{a}(:,4);repeatcat_rip{a}(:,5)],'VariableNames',{'past','future','prevgoal','replaynum'});
    r_mdl_rip = fitglm(bothtbl_rip,'linear','Distribution','poisson'); 
    CI_rip = coefCI(r_mdl_rip,.01);
    plot(15*(a-1)+[1 4 7 10],exp(table2array(r_mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
    plot([15*(a-1)+[1 4 7 10];15*(a-1)+[1 4 7 10]],exp(CI_rip)','Color',cols(1,:));
    text(1+15*(a-1),2,['Rtrial n=',num2str(length([searchcat_rip{a}(:,1);repeatcat_rip{a}(:,1)])/8)],'Color',cols(1,:));
    end
subplot(3,1,1); ylabel('exp(beta)'); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:3*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','prevgoal'})
plot([0 50],[1 1],'k:'); set(gca,'YScale','log'); ylim([.2 4]); xlim([0 50]);
subplot(3,1,2); set(gca,'YScale','log'); ylim([.2 4]); xlim([0 60]); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:4*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','curgoal','prevgoal'})
plot([0 60],[1 1],'k:');
subplot(3,1,3); set(gca,'YScale','log'); ylim([.2 4]); xlim([0 60]); ylabel('axis .2-4')
plot([0 60],[1 1],'k:');


%% characterize performance on rip vs wait trials  (epwise) 
% fraction correct on repeat, fraction redundant during search, reaction times, 
clearvars -except f animals ripcols waitcols
reptrials = figure(); set(gcf,'Position',[46 71 1108 861]); searchtrials = figure(); set(gcf,'Position',[46 71 1108 861]);
reactimes = figure(); set(gcf,'Position',[46 71 1108 861]);
contentthresh = .3;
for a = 1:length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{1},'UniformOutput',0); % stack data from all trials
     for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        reactiontime = tripdata{e}.timetoouter(valtrials);
        repeatcorr = tphasenum(:,1)>1 & (mod(tphasenum(:,1),1)==0 | mod(tphasenum(:,1),1)>.85);
        allrepeat = tphasenum(:,1)>1; 
        repeat_fraccor{a}(e,:) = [sum(tphasenum(repeatcorr,3)==1)/sum(tphasenum(allrepeat,3)==1),sum(tphasenum(repeatcorr,3)==2)/sum(tphasenum(allrepeat,3)==2)];
        searchnew = tphasenum(:,1)==0 | tphasenum(:,1)==1;
        allsearch = tphasenum(:,1)<=1; 
        search_fracnew{a}(e,:) = [sum(tphasenum(searchnew,3)==1)/sum(tphasenum(allsearch,3)==1),sum(tphasenum(searchnew,3)==2)/sum(tphasenum(allsearch,3)==2)];
        reactime_repeat{a}(e,:) = [mean(reactiontime(allrepeat & tphasenum(:,3)==1)), mean(reactiontime(allrepeat & tphasenum(:,3)==2))];
     end
     figure(reptrials); hold on
     boxplot(repeat_fraccor{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
     boxplot(repeat_fraccor{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
     [h,p_t] = ttest(repeat_fraccor{a}(:,1),repeat_fraccor{a}(:,2)); text(a,a/10,sprintf('ttestp=%.03f\nn=%deps',p_t,length(tripdata)))
     xlim([.5 4.5]); title('Fraction correct during repeat'); ylim([0 1])
     figure(searchtrials); hold on
     boxplot(search_fracnew{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
     boxplot(search_fracnew{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
     [h,p_t] = ttest(search_fracnew{a}(:,1),search_fracnew{a}(:,2)); text(a,a/10,sprintf('ttestp=%.03f\nn=%deps',p_t,length(tripdata)))
     xlim([.5 4.5]); title('Fraction new during search'); ylim([0 1])
     figure(reactimes); hold on
     boxplot(reactime_repeat{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',ripcols(a,:))
     boxplot(reactime_repeat{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',waitcols(a,:))
     [h,p_t] = ttest(reactime_repeat{a}(:,1),reactime_repeat{a}(:,2)); text(a,a/10,sprintf('ttestp=%.03f\nn=%deps',p_t,length(tripdata)))
     xlim([.5 4.5]); title('reactiontimes during repeat'); ylim([0 10])
end

%% characterize error vs correct trials, overall and rip vs wait separately
% could suggest that the manipulation drives increased variability in rip amounts to show clearer relationship w/behavior
clearvars -except f animals 
cols = [0 1 0; .4 .4 .4];
repnums = figure(); set(gcf,'Position',[46 71 1108 861]); other = figure(); set(gcf,'Position',[46 71 1108 861]); 
rrates = figure(); set(gcf,'Position',[46 71 1108 861]); nums = figure(); set(gcf,'Position',[46 71 1108 861]); 
contentthresh = .3;
for a = 1:length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{1},'UniformOutput',0); % stack data from all trials
     for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = tripdata{e}.RWripcontent(valtrials);
        rwtypes = tripdata{e}.RWripmaxtypes(valtrials); %
        durations = tripdata{e}.RWwaitlength(valtrials);
        postrwrips = tripdata{e}.postRWripcontent(valtrials);
        postrwtypes = tripdata{e}.postRWripmaxtypes(valtrials); %
        postdurations = tripdata{e}.postRWwaitlength(valtrials);
        goals = tripdata{e}.goalarm(valtrials,:);
        goals(tphasenum(:,1)<=1,1) = nan; % turn currgoals during search trials into nans
        goals(goals(:,1)==0,1) = nan;
        outers = tripdata{e}.outerarm(valtrials);
        pastwlock = tripdata{e}.prevarm(valtrials,2);  % only consider the including lockout option
        trialstack  = [outers', pastwlock, goals,tphasenum(:,[1,3])];
        clear rwreplays postrwreplays combreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); 
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1),ind(valid)-1==0];
            else rwreplays{t} = []; end
            if ~isempty(postrwrips{t})
                [maxval,ind] = max(postrwrips{t},[],2); 
                valid = postrwtypes{t}'==1 & maxval>contentthresh;
                postrwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1), ind(valid)-1==0];
            else postrwreplays{t} = []; end
            combreplays{t} = [rwreplays{t};postrwreplays{t}];
        end
        riprates = cellfun(@(x) size(x,1),rwrips)./durations';
        ripnums = cellfun(@(x) size(x,1),rwrips);
        postriprates = cellfun(@(x) size(x,1),postrwrips)./postdurations';
        postripnums = cellfun(@(x) size(x,1),postrwrips);
        combriprates = cellfun(@(x,y) size(x,1)+size(y,1),rwrips,postrwrips)./(durations+postdurations)';
        combripnums = cellfun(@(x,y) size(x,1)+size(y,1),rwrips,postrwrips);
        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        replaynums = zeros(length(rwreplays),1);  % initialize to preserve zero-count trials
        replaynums(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)));
        %calc means on [allcorr , allerr, ripcorr , riperr, waitcorr , waiterr]
        repeatcorr = tphasenum(:,1)>1 & (mod(tphasenum(:,1),1)==0 | mod(tphasenum(:,1),1)>.85);
        repeaterr = tphasenum(:,1)>1 & (mod(tphasenum(:,1),1)>0 | mod(tphasenum(:,1),1)<.85);
        meanriprate{a}(e,:) = [mean(riprates(repeatcorr)),mean(riprates(repeaterr)), ...
            mean(riprates(repeatcorr & tphasenum(:,3)==1)),mean(riprates(repeaterr & tphasenum(:,3)==1)), ...
            mean(riprates(repeatcorr & tphasenum(:,3)==2)),mean(riprates(repeaterr & tphasenum(:,3)==2))];
        meancombnum{a}(e,:) = [mean(combripnums(repeatcorr)),mean(combripnums(repeaterr)), ...
            mean(combripnums(repeatcorr & tphasenum(:,3)==1)),mean(combripnums(repeaterr & tphasenum(:,3)==1)), ...
            mean(combripnums(repeatcorr & tphasenum(:,3)==2)),mean(combripnums(repeaterr & tphasenum(:,3)==2))];
        meanreplaynum{a}(e,:) = [mean(replaynums(repeatcorr)),mean(replaynums(repeaterr)), ...
            mean(replaynums(repeatcorr & tphasenum(:,3)==1)),mean(replaynums(repeaterr & tphasenum(:,3)==1)), ...
            mean(replaynums(repeatcorr & tphasenum(:,3)==2)),mean(replaynums(repeaterr & tphasenum(:,3)==2))];
     end
     figure(rrates); hold on
     boxplot(meanriprate{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(meanriprate{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Riprate rw corr vs err'); ylim([0 2])
     figure(nums); hold on
     boxplot(meancombnum{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(meancombnum{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('Rip num rw+post corr vs err'); ylim([0 20])
     figure(repnums); hold on
     boxplot(meanreplaynum{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(meanreplaynum{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     xlim([.5 4.5]); ylabel('remote Replay num rw corr vs err'); ylim([0 10])
end
               
%% control: relate wait duration to behavior - duration of long trials vs short trials
clearvars -except f animals 
cols = [0 1 0; .4 .4 .4];
durs = figure(); set(gcf,'Position',[46 71 1108 861]); 
for a = 1:length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{1},'UniformOutput',0); % stack data from all trials
     for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        durations = tripdata{e}.RWwaitlength(valtrials);
        repeaterr = tphasenum(:,1)>1 & (mod(tphasenum(:,1),1)>0 | mod(tphasenum(:,1),1)<.85);
        repeatcorr = tphasenum(:,1)>1 & (mod(tphasenum(:,1),1)==0 | mod(tphasenum(:,1),1)>.85);
        meandurs{a}(e,:) = [mean(durations(repeatcorr)),mean(durations(repeaterr))];
     end
     figure(durs); hold on
     boxplot(meandurs{a}(:,1),'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
     boxplot(meandurs{a}(:,2),'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
     [h,p_t] = ttest(meandurs{a}(:,1),meandurs{a}(:,2)); text(a,1+a/10,sprintf('ttestp=%.03f\nn=%deps',p_t,length(tripdata)))
     xlim([.5 4.5]); title('mean rw duration of corr vs err repeat trials'); ylim([0 20])
end

%% effects across trials : error rate on blocks with more or less rips (#rips on blocks with 1 error, 2 errors, etc)
clearvars -except f animals ripcols waitcols
durs = figure(); set(gcf,'Position',[46 71 1108 861]); 
contentthresh = .3;
for a = 1:length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{1},'UniformOutput',0); % stack data from all trials
        c=1;
     for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        conts = tripdata{e}.contingency(valtrials);
        rwrips = tripdata{e}.RWripcontent(valtrials);
        rwtypes = tripdata{e}.RWripmaxtypes(valtrials); %
        durations = tripdata{e}.RWwaitlength(valtrials);
        postrwrips = tripdata{e}.postRWripcontent(valtrials);
        postrwtypes = tripdata{e}.postRWripmaxtypes(valtrials); %
        postdurations = tripdata{e}.postRWwaitlength(valtrials);
        goals = tripdata{e}.goalarm(valtrials,:);
        goals(tphasenum(:,1)<=1,1) = nan; % turn currgoals during search trials into nans
        goals(goals(:,1)==0,1) = nan;
        outers = tripdata{e}.outerarm(valtrials);
        pastwlock = tripdata{e}.prevarm(valtrials,2);  % only consider the including lockout option
        trialstack  = [outers', pastwlock, goals,tphasenum(:,[1,3])];
        clear rwreplays postrwreplays combreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); 
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1),ind(valid)-1==0];
            else rwreplays{t} = []; end
            if ~isempty(postrwrips{t})
                [maxval,ind] = max(postrwrips{t},[],2); 
                valid = postrwtypes{t}'==1 & maxval>contentthresh;
                postrwreplays{t} = [ind(valid)-1,repmat(trialstack(t,:),sum(valid),1), ind(valid)-1==0];
            else postrwreplays{t} = []; end
            combreplays{t} = [rwreplays{t};postrwreplays{t}];
        end
        combriprates = cellfun(@(x,y) size(x,1)+size(y,1),rwrips,postrwrips)./(durations+postdurations)';
        combripnums = cellfun(@(x,y) size(x,1)+size(y,1),rwrips,postrwrips);
        combreplayrates = zeros(length(combreplays),1);  % initialize to preserve zero-rate trials
        combreplayrates(~cellfun(@isempty,combreplays)) = cellfun(@(x) sum(x(:,1)>0),combreplays(~cellfun(@isempty,combreplays)))'./(durations(~cellfun(@isempty,combreplays))+postdurations(~cellfun(@isempty,combreplays)));
        combreplaynums = zeros(length(combreplays),1);  % initialize to preserve zero-count trials
        combreplaynums(~cellfun(@isempty,combreplays)) = cellfun(@(x) sum(x(:,1)>0),combreplays(~cellfun(@isempty,combreplays)));
        
        for cont=1:length(unique(conts))
            reptrials = conts==cont & tphasenum(:,1)>1;
            searchtrials = conts==cont & tphasenum(:,1)<1;
            numreperrs{a}(c) = sum(mod(tphasenum(reptrials ,1),1)>0 & mod(tphasenum(reptrials ,1),1)<.85);
            meansearchriprate{a}(c) = nanmean(combriprates(searchtrials));
            meanrepeatriprate{a}(c) = nanmean(combriprates(reptrials));
            meansearchreplayrate{a}(c) = nanmean(combreplayrates(searchtrials));
            meanrepeatreplayrate{a}(c) = nanmean(combreplayrates(reptrials));
            meansearchripnum{a}(c) = mean(combripnums(searchtrials));
            meanrepeatripnum{a}(c) = mean(combripnums(reptrials));
            meansearchreplaynum{a}(c) = mean(combreplaynums(searchtrials));
            meanrepeatreplaynum{a}(c) = mean(combreplaynums(reptrials));
            c = c+1;
        end
     end %
     subplot(1,3,1); hold on; plot(meanrepeatripnum{a},numreperrs{a},'.','Color',ripcols(a,:)); lsline; xlabel('ripnum/reptrial'); ylabel('# repeat errs')
     subplot(1,3,2); hold on; plot(meanrepeatreplaynum{a},numreperrs{a},'.','Color',ripcols(a,:)); lsline; xlabel('replaynum/reptrial'); ylabel('# repeat errs')
     subplot(1,3,3); hold on; plot(meanrepeatriprate{a},numreperrs{a},'.','Color',ripcols(a,:)); lsline; xlabel('riprate/reptrial'); ylabel('# repeat errs')

%      tbl = table(meansearchriprate{a}',meanrepeatriprate{a}',meansearchreplayrate{a}',meanrepeatreplayrate{a}', ...
%         meansearchripnum{a}',meanrepeatripnum{a}',meansearchreplaynum{a}',meanrepeatreplaynum{a}',numreperrs{a}');
% mdl = fitglm(tbl,'linear','Distribution','poisson');
% CI_rip = coefCI(mdl,.01);
% subplot(2,2,a); hold on; title([animals{a} ' predict # repeat errs'])
% plot(a+[0:length(animals)+8:8*(length(animals)+8)],exp(table2array(mdl.Coefficients(:,1))),'.','MarkerSize',20,'Color',cols(1,:));
% plot([a+[0:length(animals)+8:8*(length(animals)+8)];a+[0:length(animals)+8:8*(length(animals)+8)]],exp(CI_rip)','Color',cols(1,:));
% text(5,2+.2*a,['cont n=',num2str(size(tbl,1))],'Color',cols(1,:));
% ylabel('exp(beta)'); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:8*(length(animals)+8)],'XTickLabel',{'int','Sriprate','Rriprate','Sreplayrate','Rreplayrate','Sripnum','Rripnum','Sreplaynum','Rreplaynum'})
% plot([0 100],[1 1],'k:'); set(gca,'YScale','log'); ylim([.0001 100]); xlim([0 100]);
end
