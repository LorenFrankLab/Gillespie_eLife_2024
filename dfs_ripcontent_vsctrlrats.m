%% rip conditioning: main content analyses
% focus on post-conditioning, since that's when we have good quality decoding
% relationship between behavior and rips/replay goes here, since we have behavior outputs 

animals = {'jaq','roquefort','despereaux','montague','remy','gus','bernard','fievel'}; 

epochfilter{1} = ['(isequal($cond_phase,''plateau'')) & $ripthresh>=0 & $gooddecode==1'];  % for conditioning rats
epochfilter{2} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 & $gooddecode==1 '];  % for control rats
epochfilter{3} = ['$ripthresh==0 & (isequal($environment,''goal_nodelay'')) & $forageassist==0  & $gooddecode==1'];  % for control rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';

f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);
f = setfilterfunction(f, 'dfa_ripcontent_nf', {'ripdecodesv3','trials','pos'});
f = runfilter(f);

%ripcols = [254 123 123; 255 82 82; 255 0 0; 168 1 0]./255; 
%waitcols = [148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;
%ctrlcols = [123 159 242; 66 89 195; 33 42 165; 6 1 140]./255;

%% Plot fraction of RW events that are coherent(not fragmented), fracremote, rate & # of remote replay
clearvars -except f animals 
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
contentthresh = .3;
for a = 1:length(animals)
    if a<=4
        when=2;
    else
        when=1;
    end
    tripdata = arrayfun(@(x) x.trips,f(a).output{when},'UniformOutput',0); % stack data from all trials
    tripdata = tripdata(~cellfun(@isempty,tripdata));
    for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = tripdata{e}.RWripcontent(valtrials);
        rwtypes = tripdata{e}.RWripmaxtypes(valtrials); %
        durations = tripdata{e}.RWwaitlength(valtrials);
        clear rwreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype salient local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1,repmat(tphasenum(t,:),sum(valid),1)];  %[arm represented, tphase, tnum,trialtype]
            else rwreplays{t} = []; end
        end
        allrw{a}{e} = vertcat(rwreplays{:});
        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        replaycounts = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replaycounts(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))';
        %separate rip and wait trials
        if a<=4
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)>=1,:);
            allw{a}{e} = allr{a}{e};
            ripfraccoh{a}(e,1) = size(allrw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)>=1)));
            waitfraccoh{a}(e,1) = ripfraccoh{a}(e);
            ripfracremote{a}(e,1) = sum(allrw{a}{e}(:,1)>0)/length(allrw{a}{e}); % out of ALL detected replay
            waitfracremote{a}(e,1) = ripfracremote{a}(e);
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)>=1);
            waitreplayrates{a}{e} = ripreplayrates{a}{e};
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)>=1);
            waitreplaycounts{a}{e} = ripreplaycounts{a}{e};
            labels_rip{a}{e} = [zeros(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = labels_rip{a}{e};
        else
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==1,:);
            allw{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==2,:);
            ripfraccoh{a}(e,1) = size(allr{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==1)));
            waitfraccoh{a}(e,1) = size(allw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==2))) ;
            ripfracremote{a}(e,1) = sum(allr{a}{e}(:,1)>0)/size(allr{a}{e},1);
            waitfracremote{a}(e,1) = sum(allw{a}{e}(:,1)>0)/size(allw{a}{e},1); % out of ALL replay
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)==1);
            waitreplayrates{a}{e} = replayrates(tphasenum(:,3)==2);
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==1);
            waitreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==2);
            labels_rip{a}{e} = [ones(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = [ones(length(waitreplayrates{a}{e}),1),a+zeros(length(waitreplayrates{a}{e}),1)];
        end
    end
    eplabels{a} = repmat([double(a>4),a],length(ripfraccoh{a}),1);
     allripreplayrates{a} = vertcat(ripreplayrates{a}{:}); allwaitreplayrates{a} = vertcat(waitreplayrates{a}{:});
    allripreplaycounts{a} = vertcat(ripreplaycounts{a}{:}); allwaitreplaycounts{a} = vertcat(waitreplaycounts{a}{:});
    allriplabels{a} = vertcat(labels_rip{a}{:}); allwaitlabels{a} = vertcat(labels_wait{a}{:}); 
end
figure; subplot(2,2,1); hold on;
allrat_lmeplot(ripfraccoh,waitfraccoh,eplabels,eplabels,'spacer',[0 20],'grouped',1)
ylabel('Fraction coherent');title('pre-rew frac coh/allswrs'); ylim([0 1]);
subplot(2,2,2); hold on;
allrat_lmeplot(ripfracremote,waitfracremote,eplabels,eplabels,'spacer',[.1 20],'grouped',1)
ylabel('Fraction remote');title('pre-rew frac remote/allcoh');  ylim([0 1]);
subplot(2,2,3); hold on;
allrat_lmeplot(allripreplayrates,allwaitreplayrates,allriplabels,allwaitlabels,'spacer',[.2 15],'grouped',1)
ylabel('Remote replay rate (hz)');title('pre-rew remote replay rate');  ylim([0 1]);
subplot(2,2,4); hold on;
allrat_lmeplot(allripreplaycounts,allwaitreplaycounts,allriplabels,allwaitlabels,'spacer',[0 1],'grouped',1,'lme_dist','poisson')
ylabel('Remote replay count');title('pre-rew remote replay count'); ylim([0 10]);

%% Plot fraction of post RW events that are coherent(not fragmented), fracremote, rate & # of remote replay
clearvars -except f animals 
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
contentthresh = .3;
for a = 1:length(animals)
    if a<=4
        when=2;
    else
        when=1;
    end
    tripdata = arrayfun(@(x) x.trips,f(a).output{when},'UniformOutput',0); % stack data from all trials
    tripdata = tripdata(~cellfun(@isempty,tripdata));
    for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = tripdata{e}.postRWripcontent(valtrials);
        rwtypes = tripdata{e}.postRWripmaxtypes(valtrials); %
        durations = tripdata{e}.postRWwaitlength(valtrials);
        clear rwreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype salient local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1,repmat(tphasenum(t,:),sum(valid),1)];  %[arm represented, tphase, tnum,trialtype]
            else rwreplays{t} = []; end
        end
        allrw{a}{e} = vertcat(rwreplays{:});
        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        replaycounts = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replaycounts(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))';
        %separate rip and wait trials
        if a<=4
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)>=1,:);
            allw{a}{e} = allr{a}{e};
            ripfraccoh{a}(e,1) = size(allrw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)>=1)));
            waitfraccoh{a}(e,1) = ripfraccoh{a}(e);
            ripfracremote{a}(e,1) = sum(allrw{a}{e}(:,1)>0)/length(allrw{a}{e}); % out of ALL detected replay
            waitfracremote{a}(e,1) = ripfracremote{a}(e);
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)>=1);
            waitreplayrates{a}{e} = ripreplayrates{a}{e};
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)>=1);
            waitreplaycounts{a}{e} = ripreplaycounts{a}{e};
            labels_rip{a}{e} = [zeros(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = labels_rip{a}{e};
        else
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==1,:);
            allw{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==2,:);
            ripfraccoh{a}(e,1) = size(allr{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==1)));
            waitfraccoh{a}(e,1) = size(allw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==2))) ;
            ripfracremote{a}(e,1) = sum(allr{a}{e}(:,1)>0)/size(allr{a}{e},1);
            waitfracremote{a}(e,1) = sum(allw{a}{e}(:,1)>0)/size(allw{a}{e},1); % out of ALL replay
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)==1);
            waitreplayrates{a}{e} = replayrates(tphasenum(:,3)==2);
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==1);
            waitreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==2);
            labels_rip{a}{e} = [ones(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = [ones(length(waitreplayrates{a}{e}),1),a+zeros(length(waitreplayrates{a}{e}),1)];
        end
    end
    eplabels{a} = repmat([double(a>4),a],length(ripfraccoh{a}),1);
     allripreplayrates{a} = vertcat(ripreplayrates{a}{:}); allwaitreplayrates{a} = vertcat(waitreplayrates{a}{:});
    allripreplaycounts{a} = vertcat(ripreplaycounts{a}{:}); allwaitreplaycounts{a} = vertcat(waitreplaycounts{a}{:});
    allriplabels{a} = vertcat(labels_rip{a}{:}); allwaitlabels{a} = vertcat(labels_wait{a}{:}); 
end
figure; subplot(2,2,1); hold on;
allrat_lmeplot(ripfraccoh,waitfraccoh,eplabels,eplabels,'spacer',[0 20],'grouped',1)
ylabel('Fraction coherent');title('post-rew frac coh/allswrs'); ylim([0 1]);
subplot(2,2,2); hold on;
allrat_lmeplot(ripfracremote,waitfracremote,eplabels,eplabels,'spacer',[.1 20],'grouped',1)
ylabel('Fraction remote');title('post-rew frac remote/allcoh');  ylim([0 1]);
subplot(2,2,3); hold on;
allrat_lmeplot(allripreplayrates,allwaitreplayrates,allriplabels,allwaitlabels,'spacer',[.2 15],'grouped',1)
ylabel('Remote replay rate (hz)');title('post-rew remote replay rate');  ylim([0 1]);
subplot(2,2,4); hold on;
allrat_lmeplot(allripreplaycounts,allwaitreplaycounts,allriplabels,allwaitlabels,'spacer',[0 1],'grouped',1,'lme_dist','poisson')
ylabel('Remote replay count');title('post-rew remote replay count'); ylim([0 10]);

%% Plot fraction of RW+postrw combined events that are coherent(not fragmented), local, rate & # of remote replay
clearvars -except f animals 
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
contentthresh = .3;
for a = 1:length(animals)
    if a<=4
        when=2;
    else
        when=1;
    end
    tripdata = arrayfun(@(x) x.trips,f(a).output{when},'UniformOutput',0); % stack data from all trials
    tripdata = tripdata(~cellfun(@isempty,tripdata));
    for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = cellfun(@(x,y) ([x;y]),tripdata{e}.RWripcontent(valtrials),tripdata{e}.postRWripcontent(valtrials),'un',0);
        rwtypes = cellfun(@(x,y) ([x,y]),tripdata{e}.RWripmaxtypes(valtrials),tripdata{e}.postRWripmaxtypes(valtrials),'un',0); %
        durations = tripdata{e}.RWwaitlength(valtrials)+tripdata{e}.postRWwaitlength(valtrials);
         clear rwreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype salient local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1,repmat(tphasenum(t,:),sum(valid),1)];  %[arm represented, tphase, tnum,trialtype]
            else rwreplays{t} = []; end
        end
        allrw{a}{e} = vertcat(rwreplays{:});
        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        replaycounts = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replaycounts(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))';
        %separate rip and wait trials
        if a<=4
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)>=1,:);
            allw{a}{e} = allr{a}{e};
            ripfraccoh{a}(e,1) = size(allrw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)>=1)));
            waitfraccoh{a}(e,1) = ripfraccoh{a}(e);
            ripfracremote{a}(e,1) = sum(allrw{a}{e}(:,1)>0)/size(allrw{a}{e},1); % out of ALL detected replay
            waitfracremote{a}(e,1) = ripfracremote{a}(e);
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)>=1);
            waitreplayrates{a}{e} = ripreplayrates{a}{e};
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)>=1);
            waitreplaycounts{a}{e} = ripreplaycounts{a}{e};
            labels_rip{a}{e} = [zeros(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = labels_rip{a}{e};
        else
            allr{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==1,:);
            allw{a}{e} = allrw{a}{e}(allrw{a}{e}(:,4)==2,:);
            ripfraccoh{a}(e,1) = size(allr{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==1)));
            waitfraccoh{a}(e,1) = size(allw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)==2))) ;
            ripfracremote{a}(e,1) = sum(allr{a}{e}(:,1)>0)/size(allr{a}{e},1);
            waitfracremote{a}(e,1) = sum(allw{a}{e}(:,1)>0)/size(allw{a}{e},1); % out of ALL replay
            ripreplayrates{a}{e} = replayrates(tphasenum(:,3)==1);
            waitreplayrates{a}{e} = replayrates(tphasenum(:,3)==2);
            ripreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==1);
            waitreplaycounts{a}{e} = replaycounts(tphasenum(:,3)==2);
            labels_rip{a}{e} = [ones(length(ripreplayrates{a}{e}),1),a+zeros(length(ripreplayrates{a}{e}),1)];
            labels_wait{a}{e} = [ones(length(waitreplayrates{a}{e}),1),a+zeros(length(waitreplayrates{a}{e}),1)];
        end
    end
    eplabels{a} = repmat([double(a>4),a],length(ripfraccoh{a}),1);
     allripreplayrates{a} = vertcat(ripreplayrates{a}{:}); allwaitreplayrates{a} = vertcat(waitreplayrates{a}{:});
    allripreplaycounts{a} = vertcat(ripreplaycounts{a}{:}); allwaitreplaycounts{a} = vertcat(waitreplaycounts{a}{:});
    allriplabels{a} = vertcat(labels_rip{a}{:}); allwaitlabels{a} = vertcat(labels_wait{a}{:}); 
end
figure; subplot(2,2,1); hold on;
allrat_lmeplot(ripfraccoh,waitfraccoh,eplabels,eplabels,'spacer',[0 20],'grouped',1)
ylabel('Fraction coherent');title('pre+post frac coh/allswrs'); ylim([0 1]); %xlim([.5 9.5]);
subplot(2,2,2); hold on;
allrat_lmeplot(ripfracremote,waitfracremote,eplabels,eplabels,'spacer',[.1 20],'grouped',1)
ylabel('Fraction remote');title('pre+post frac remote/allcoh'); ylim([0 1]); %xlim([.5 9.5]); 
subplot(2,2,3); hold on;
allrat_lmeplot(allripreplayrates,allwaitreplayrates,allriplabels,allwaitlabels,'spacer',[.2 15],'grouped',1)
ylabel('Remote replay rate (hz)');title('pre+post remote replay rate');  ylim([0 1]); %xlim([.5 9.5]);
subplot(2,2,4); hold on;
allrat_lmeplot(allripreplaycounts,allwaitreplaycounts,allriplabels,allwaitlabels,'spacer',[0 1],'grouped',1,'lme_dist','poisson')
ylabel('Remote replay count');title('pre+post remote replay count');ylim([0 10]);% xlim([.5 9.5]); 

%%  fit glm for arm categories, search+repeat combined, pre-reward
clearvars -except f animals animcol
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
contentthresh = .3;
figure;  set(gcf,'Position',[90 262 1822 697]); 
for a = 1:length(animals)
    if a<=4
    when = 2;
    else
        when=1;
end
    eps = find(arrayfun(@(x) ~isempty(x.trips),f(a).output{when}));
    for e = 1:length(eps)
        tphasenum = f(a).output{when}(eps(e)).trips.taskphase;
        goals = f(a).output{when}(eps(e)).trips.goalarm;
        valtrials = ~isnan(tphasenum) & ~isnan(goals(:,2));
        goals = goals(valtrials,:);
        trialtype = f(a).output{when}(eps(e)).trips.trialtype(valtrials);     
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]'];   % add trial numbers
        rwrips = f(a).output{when}(eps(e)).trips.RWripcontent(valtrials);
        rwtypes = f(a).output{when}(eps(e)).trips.RWripmaxtypes(valtrials); %
        clear replays 
        for t=1:length(rwrips)
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                replays{t} = ind(valid)'-1; %
            else replays{t} = []; end
        end
        if any(valtrials) & ~isempty(rwrips)
        outers = f(a).output{when}(eps(e)).trips.outerarm(valtrials);
        pastwlock = f(a).output{when}(eps(e)).trips.prevarm(valtrials,2);  % only consider the including lockout option
        countspertrial = zeros(8,length(outers));
        countspertrial(:,~cellfun(@isempty,replays)) = cell2mat(cellfun(@(x) histcounts(x,[1:9])',replays(~cellfun(@isempty,replays)),'un',0));
        future = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(outers),'un',0));
        past = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(pastwlock'),'un',0));
        prevgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,2)'),'un',0));
        currgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,1)'),'un',0));
 if a<=4 
     all_rip{a,1}{e} = [reshape(future(:,trialtype>=1),[],1),reshape(past(:,trialtype>=1),[],1),reshape(prevgoal(:,trialtype>=1),[],1) ...
                    reshape(countspertrial(:,trialtype>=1),[],1)]; % [future past prevgoal #replays];
 else
            all_rip{a,1}{e} = [reshape(future(:,trialtype==1),[],1),reshape(past(:,trialtype==1),[],1),reshape(prevgoal(:,trialtype==1),[],1) ...
                    reshape(countspertrial(:,trialtype==1),[],1)]; % [future past prevgoal #replays];
         
              all_wait{a,1}{e} = [reshape(future(:,trialtype==2),[],1),reshape(past(:,trialtype==2),[],1),reshape(prevgoal(:,trialtype==2),[],1) ...
                    reshape(countspertrial(:,trialtype==2),[],1)]; % [future past prevgoal #replays];
          end
        end
    end
    cat_rip{a} = vertcat(all_rip{a}{:});
    tbl_rip = table(cat_rip{a}(:,2),cat_rip{a}(:,1),cat_rip{a}(:,3),cat_rip{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    mdl_rip = fitglm(tbl_rip,'linear','Distribution','poisson');
    CI_rip = coefCI(mdl_rip,.01);
    hold on; title('alltrials, pre-reward ')
    plot(a+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',animcol(a,:));
    plot([a+[0:length(animals)+8:3*(length(animals)+8)];a+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_rip)','Color',animcol(a,:));
    text(5,2+.2*a,['trial n=',num2str(size(cat_rip{a},1)/8)],'Color',animcol(a,:));
    if a>4
        cat_wait{a} = vertcat(all_wait{a}{:});
    tbl_wait = table(cat_wait{a}(:,2),cat_wait{a}(:,1),cat_wait{a}(:,3),cat_wait{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    mdl_wait = fitglm(tbl_wait,'linear','Distribution','poisson');
    CI_wait = coefCI(mdl_wait,.01);
    plot(a+4+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(mdl_wait.Coefficients(:,1))),'.','MarkerSize',20,'Color',animcol(a+4,:));
    plot([a+4+[0:length(animals)+8:3*(length(animals)+8)];a+4+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_wait)','Color',animcol(a+4,:));
    text(15,2+.2*a,['Wtrial n=',num2str(size(cat_wait{a},1)/8)],'Color',animcol(a+4,:));
    
    end
end
ylabel('exp(beta)'); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:3*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','prevgoal'})
plot([0 70],[1 1],'k:'); set(gca,'YScale','log'); ylim([.1 5]); xlim([0 70]);

%%  fit glm for arm categories, search+repeat combined, pre- + post-reward combined
clearvars -except f animals animcol
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
contentthresh = .3;
figure;  set(gcf,'Position',[90 262 1822 697]); 
for a = 1:length(animals)
    if a<=4
    when = 2;
    else
        when=1;
end
    eps = find(arrayfun(@(x) ~isempty(x.trips),f(a).output{when}));
    for e = 1:length(eps)
        tphasenum = f(a).output{when}(eps(e)).trips.taskphase;
        goals = f(a).output{when}(eps(e)).trips.goalarm;
        valtrials = ~isnan(tphasenum) & ~isnan(goals(:,2));
        goals = goals(valtrials,:);
        trialtype = f(a).output{when}(eps(e)).trips.trialtype(valtrials);     
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]'];   % add trial numbers
        rwrips = cellfun(@(x,y) ([x;y]),f(a).output{when}(eps(e)).trips.RWripcontent(valtrials),f(a).output{when}(eps(e)).trips.postRWripcontent(valtrials),'un',0);
        rwtypes = cellfun(@(x,y) ([x,y]),f(a).output{when}(eps(e)).trips.RWripmaxtypes(valtrials),f(a).output{when}(eps(e)).trips.postRWripmaxtypes(valtrials),'un',0); %
        clear replays 
        for t=1:length(rwrips)
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                replays{t} = ind(valid)'-1; %
            else replays{t} = []; end
        end
        if any(valtrials) & ~isempty(rwrips)
        outers = f(a).output{when}(eps(e)).trips.outerarm(valtrials);
        pastwlock = f(a).output{when}(eps(e)).trips.prevarm(valtrials,2);  % only consider the including lockout option
        countspertrial = zeros(8,length(outers));
        countspertrial(:,~cellfun(@isempty,replays)) = cell2mat(cellfun(@(x) histcounts(x,[1:9])',replays(~cellfun(@isempty,replays)),'un',0));
        future = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(outers),'un',0));
        past = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(pastwlock'),'un',0));
        prevgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,2)'),'un',0));
        currgoal = cell2mat(cellfun(@(x) histcounts(x,[1:9])',num2cell(goals(:,1)'),'un',0));
 if a<=4 
     all_rip{a,1}{e} = [reshape(future(:,trialtype>=1),[],1),reshape(past(:,trialtype>=1),[],1),reshape(prevgoal(:,trialtype>=1),[],1) ...
                    reshape(countspertrial(:,trialtype>=1),[],1)]; % [future past prevgoal #replays];
 else
            all_rip{a,1}{e} = [reshape(future(:,trialtype==1),[],1),reshape(past(:,trialtype==1),[],1),reshape(prevgoal(:,trialtype==1),[],1) ...
                    reshape(countspertrial(:,trialtype==1),[],1)]; % [future past prevgoal #replays];
         
              all_wait{a,1}{e} = [reshape(future(:,trialtype==2),[],1),reshape(past(:,trialtype==2),[],1),reshape(prevgoal(:,trialtype==2),[],1) ...
                    reshape(countspertrial(:,trialtype==2),[],1)]; % [future past prevgoal #replays];
 end
        end
    end
    cat_rip{a} = vertcat(all_rip{a}{:});
    tbl_rip = table(cat_rip{a}(:,2),cat_rip{a}(:,1),cat_rip{a}(:,3),cat_rip{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    mdl_rip = fitglm(tbl_rip,'linear','Distribution','poisson');
    CI_rip = coefCI(mdl_rip,.01);
    hold on; title('alltrials, pre-+post-reward combined')
    plot(a++[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(mdl_rip.Coefficients(:,1))),'.','MarkerSize',20,'Color',animcol(a,:));
    plot([a+[0:length(animals)+8:3*(length(animals)+8)];a+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_rip)','Color',animcol(a,:));
    text(5,2+.2*a,['trial n=',num2str(size(cat_rip{a},1)/8)],'Color',animcol(a,:));
    if a>4
        cat_wait{a} = vertcat(all_wait{a}{:});
    tbl_wait = table(cat_wait{a}(:,2),cat_wait{a}(:,1),cat_wait{a}(:,3),cat_wait{a}(:,4),'VariableNames',{'past','future','prevgoal','replaynum'});
    mdl_wait = fitglm(tbl_wait,'linear','Distribution','poisson');
    CI_wait = coefCI(mdl_wait,.01);
    plot(a+4+[0:length(animals)+8:3*(length(animals)+8)],exp(table2array(mdl_wait.Coefficients(:,1))),'.','MarkerSize',20,'Color',animcol(a+4,:));
    plot([a+4+[0:length(animals)+8:3*(length(animals)+8)];a+4+[0:length(animals)+8:3*(length(animals)+8)]],exp(CI_wait)','Color',animcol(a+4,:));
    text(15,2+.2*a,['Wtrial n=',num2str(size(cat_wait{a},1)/8)],'Color',animcol(a+4,:));
    
    end
end
ylabel('exp(beta)'); set(gca,'XTick',length(animals)/2+[0:length(animals)+8:3*(length(animals)+8)],'XTickLabel',{'intrcpt','past','future','prevgoal'})
plot([0 70],[1 1],'k:'); set(gca,'YScale','log'); ylim([.1 5]); xlim([0 70]);

%% behavior comparisons: search redundancy, repeat accuracy, reaction time (trialwise)
clearvars -except f animals 
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
sfn=figure; re = figure(); so = figure(); fc = figure();  
for a = 1:length(animals)
    if a<=4
        when = 2;
    else
        when = 1;
    end
    tripdata = arrayfun(@(x) x.trips,f(a).output{when},'UniformOutput',0); % stack data from all trials
    tripdata = tripdata(~cellfun(@isempty,tripdata));
    for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        reactiontime = tripdata{e}.timetoouter(valtrials);
        if a<=4
            riptrials = tphasenum(:,3)>=1;
            waittrials = riptrials;
        else
            riptrials = tphasenum(:,3)==1;
            waittrials = tphasenum(:,3)==2;
        end
        reptrials = tphasenum(:,1)>1;
        errtrials = mod(tphasenum(:,1),1)>0 & mod(tphasenum(:,1),1)<.85;
        
        search_fracnew_rip{a}(e,1) = sum(riptrials & ~reptrials & ~errtrials)/sum(riptrials & ~reptrials);
        search_fracnew_wait{a}(e,1) = sum(waittrials & ~reptrials & ~errtrials)/sum(waittrials & ~reptrials); 
        repeat_fraccorr_rip{a}(e,1) = sum(riptrials & reptrials & ~errtrials)/sum(riptrials & reptrials);
        repeat_fraccorr_wait{a}(e,1) = sum(waittrials & reptrials & ~errtrials)/sum(waittrials & reptrials);
        reperrs_fracrip{a}(e) = sum(reptrials & riptrials & errtrials)/sum(reptrials & errtrials);
        searchold_fracrip{a}(e) = sum(~reptrials & riptrials & errtrials)/sum(~reptrials & errtrials);
    end
    eplabels{a} = repmat([double(a>4),a],length(search_fracnew_rip{a}),1);

    if a<=4
        figure(fc); hold on;
        plot(search_fracnew_rip{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(search_fracnew_rip{a},[1:length(search_fracnew_rip{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('fraction non-redundant'); ylabel('fraction'); xlabel('eps'); ylim([0 1]);
    else
        figure(re); hold on;
        boxplot(reperrs_fracrip{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
        p = signtest(reperrs_fracrip{a},.5);
        text(a,a/20,sprintf('p=%d\nn=%d eps',p,length(reperrs_fracrip{a})))
        plot([4, 9.5],[.5, .5],'k:');
        xlim([4 9.5]); ylabel('Fraction rip'); title('repeat errors'); ylim([0 1])
        figure(so); hold on;
        boxplot(searchold_fracrip{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
        p = signtest(searchold_fracrip{a},.5);
        text(a,a/20,sprintf('p=%d\nn=%d eps',p,length(searchold_fracrip{a})))
        plot([4, 9.5],[.5, .5],'k:');
        xlim([4.5 9.5]); ylabel('Fraction rip'); title('redundant search trials'); ylim([0 1])
    end
end
figure(sfn); subplot(1,2,1); hold on;
allrat_lmeplot(search_fracnew_rip,search_fracnew_wait,eplabels,eplabels,'spacer',[0 20],'grouped',1)
ylabel('fraction');title('search frac non-redundant'); ylim([0 1]);
subplot(1,2,2); hold on;
allrat_lmeplot(repeat_fraccorr_rip,repeat_fraccorr_wait,eplabels,eplabels,'spacer',[0 20],'grouped',1)
ylabel('fraction');title('repeat frac correct');  ylim([0 1]);


%% Assess change in remote contentfrac and remote contentcount in Ctrl cohort over epochs (pre+post combined)
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
clearvars -except f animals animcol
figure;
contentthresh=.3;
when=2;
    for a = 1:4 %length(animals)
        tripdata = arrayfun(@(x) x.trips,f(a).output{when},'UniformOutput',0); % stack data from all trials
    tripdata = tripdata(~cellfun(@isempty,tripdata));
    for e = 1:length(tripdata)
        tphasenum = tripdata{e}.taskphase;
        valtrials = ~isnan(tphasenum);
        tphasenum = [tphasenum(valtrials), [1:sum(valtrials)]',tripdata{e}.trialtype(valtrials) ];   % add trial numbers
        rwrips = cellfun(@(x,y) ([x;y]),tripdata{e}.RWripcontent(valtrials),tripdata{e}.postRWripcontent(valtrials),'un',0);
        rwtypes = cellfun(@(x,y) ([x,y]),tripdata{e}.RWripmaxtypes(valtrials),tripdata{e}.postRWripmaxtypes(valtrials),'un',0); %
        durations = tripdata{e}.RWwaitlength(valtrials)+tripdata{e}.postRWwaitlength(valtrials);
        clear rwreplays
        for t=1:length(rwrips)  % extract valid rips and tack on trial info: [replay future past currgoal prevgoal ppgoal tphase trialtype salient local]
            if ~isempty(rwrips{t})
                [maxval,ind] = max(rwrips{t},[],2); %(:,2:end)
                valid = rwtypes{t}'==1 & maxval>contentthresh;
                rwreplays{t} = [ind(valid)-1]; % [armrepresented]
            else rwreplays{t} = []; end
        end
        allrw{a}{e} = vertcat(rwreplays{:});
        replayrates = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replayrates(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))'./durations(~cellfun(@isempty,rwreplays));
        replaycounts = zeros(length(rwreplays),1);  % initialize to preserve zero-rate trials
        replaycounts(~cellfun(@isempty,rwreplays)) = cellfun(@(x) sum(x(:,1)>0),rwreplays(~cellfun(@isempty,rwreplays)))';
        fraccohrw{a}(e) = size(allrw{a}{e},1)/sum(cellfun(@(x) size(x,1),rwrips(tphasenum(:,3)>=1)));
        fracremoterw{a}(e) = sum(allrw{a}{e}>0)/length(allrw{a}{e}); % out of ALL detected SWRSs
        meanreplayrates{a}(e) = mean(replayrates(tphasenum(:,3)>=1));
        meanreplaycounts{a}(e) = mean(replaycounts(tphasenum(:,3)>=1));
   end
        
    subplot(2,2,1); hold on;
        plot(fraccohrw{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(fraccohrw{a},[1:length(fraccohrw{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('fraction coherent'); ylabel('fraction'); xlabel('eps'); ylim([0 1]);
        subplot(2,2,2); hold on;
        plot(fracremoterw{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(fracremoterw{a},[1:length(fracremoterw{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('fraction remote'); ylabel('fraction'); xlabel('eps'); ylim([0 1])
        subplot(2,2,3); hold on;
        plot(meanreplayrates{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(meanreplayrates{a},[1:length(meanreplayrates{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('remote replay rate'); ylabel('rate (Hz)'); xlabel('eps'); ylim([0 1])
        subplot(2,2,4); hold on;
        plot(meanreplaycounts{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(meanreplaycounts{a},[1:length(meanreplaycounts{a})]);
        text(2,a,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('remote replay counts'); ylabel('count'); xlabel('eps'); ylim([0 10])
     end
    