%% Neurofeedback: comparisons between conditioned and control animals

animals = {'jaq','roquefort','despereaux','montague','remy','gus','bernard','fievel'}; 

epochfilter{1} = ['(isequal($cond_phase,''pre'') | isequal($cond_phase,''early'') ) & (isequal($environment,''goal'')| isequal($environment,''hybrid2'') | isequal($environment,''hybrid3'')) '];  %cond rats
epochfilter{2} = ['isequal($cond_phase,''plateau'') & isequal($environment,''goal'') '];  %cond rats
epochfilter{3} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 '];  % for control rats
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
f = setfilterfunction(f, 'dfa_ripquantpertrial_allphase_NF', {'ca1rippleskons','trials','pos'}, 'excltrigger',0,'excludeRWstart',0,'excludepostRWstart',0);
f = runfilter(f);

%save('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats.mat','f','-v7.3')
load('/media/anna/whirlwindtemp2/ffresults/NFrips_vsctrlrats.mat','f')

%% PART 1 plot median rate at rw, TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type>=1))./cellfun(@(x) x.duration,rwdata(type>=1));
        waitrates{a} = riprates{a};
        ripcounts{a} = cellfun(@(x) length(x.size),rwdata(type>=1));
        waitcounts{a} = ripcounts{a};
        labels_rip{a} = [zeros(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1));
        waitrates{a} = cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2));
        ripcounts{a} = cellfun(@(x) length(x.size),rwdata(type==1));
        waitcounts{a} = cellfun(@(x) length(x.size),rwdata(type==2));
        labels_rip{a} = [ones(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = [ones(length(waitrates{a}),1),a+zeros(length(waitrates{a}),1)];
    end  
end
figure; set(gcf,'Position',[2 374 1915 449]); 
subplot(1,2,1); hold on;
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[0 20],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate pre-reward, incltrig, plateau');  ylim([0 2]);
subplot(1,2,2); hold on;
allrat_lmeplot(ripcounts,waitcounts,labels_rip,labels_wait,'spacer',[0 .5],'grouped',1,'lme_dist','poisson')
ylabel('SWR count');title('Ripcount pre-reward, incltrig, plateau');  ylim([0 30]);

%% PART 2 plot median rate & count at POSTrw, TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type>=1))./cellfun(@(x) x.duration,rwdata(type>=1));
        waitrates{a} = riprates{a};
        ripcounts{a} = cellfun(@(x) length(x.size),rwdata(type>=1));
        waitcounts{a} = ripcounts{a};
        labels_rip{a} = [zeros(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1));
        waitrates{a} = cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2));
        ripcounts{a} = cellfun(@(x) length(x.size),rwdata(type==1));
        waitcounts{a} = cellfun(@(x) length(x.size),rwdata(type==2));
        labels_rip{a} = [ones(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = [ones(length(waitrates{a}),1),a+zeros(length(waitrates{a}),1)];
    end
    
end
figure; set(gcf,'Position',[2 374 1915 449]); 
subplot(1,2,1); hold on; 
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[0 20],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate post-reward, incltrig, plateau'); ylim([0 2]);
subplot(1,2,2); hold on;
allrat_lmeplot(ripcounts,waitcounts,labels_rip,labels_wait,'spacer',[0 .5],'grouped',1,'lme_dist','poisson')
ylabel('SWR count');title('Ripcount post-reward, incltrig, plateau'); ylim([0 30]);

%% PART 3 plot median duration at POSTrw, TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripdur{a} = cellfun(@(x) x.duration,rwdata(type>=1));
        waitdur{a} = ripdur{a};
        labels_rip{a} = [zeros(length(ripdur{a}),1),a+zeros(length(ripdur{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripdur{a} = cellfun(@(x) x.duration,rwdata(type==1));
        waitdur{a} = cellfun(@(x) x.duration,rwdata(type==2));
        labels_rip{a} = [ones(length(ripdur{a}),1),a+zeros(length(ripdur{a}),1)];
        labels_wait{a} = [ones(length(waitdur{a}),1),a+zeros(length(waitdur{a}),1)];
    end  
end
allrat_lmeplot(ripdur,waitdur,labels_rip,labels_wait,'spacer',[1 1],'grouped',1)
ylabel('Dwell time post-reward (s)');title('post-reward dwell time');  ylim([0 25]);

%% PART 4 plot median rate and count at pre+POSTrw combined , TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = horzcat(postrwdata{:})';
        type = cellfun(@(x) x.type,rwdata);
        ripcount{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata(type>=1),postrwdata(type>=1));
        waitcount{a} = ripcount{a};
        riprates{a} = ripcount{a}./cellfun(@(x,y) (x.duration+y.duration),rwdata(type>=1),postrwdata(type>=1));
        waitrates{a} = riprates{a};
        labels_rip{a} = [zeros(length(ripcount{a}),1),a+zeros(length(ripcount{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = horzcat(postrwdata{:})';
        type = cellfun(@(x) x.type,rwdata);
        ripcount{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata(type==1),postrwdata(type==1));
        waitcount{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata(type==2),postrwdata(type==2));
        riprates{a} = ripcount{a}./cellfun(@(x,y) (x.duration+y.duration),rwdata(type==1),postrwdata(type==1));
        waitrates{a} = waitcount{a}./cellfun(@(x,y) (x.duration+y.duration),rwdata(type==2),postrwdata(type==2));
        labels_rip{a} = [ones(length(ripcount{a}),1),a+zeros(length(ripcount{a}),1)];
        labels_wait{a} = [ones(length(waitcount{a}),1),a+zeros(length(waitcount{a}),1)];
    end  
end
figure; set(gcf,'Position',[2 374 1915 449]);
subplot(1,2,1); hold on; 
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[0 20],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate pre+post'); ylim([0 2]);
subplot(1,2,2); hold on;
allrat_lmeplot(ripcount,waitcount,labels_rip,labels_wait,'spacer',[1 1],'grouped',1,'lme_dist','poisson')
ylabel('Rip count pre+post reward');  ylim([0 30]);

%% PART 5 rw+postrw riprate curves by timebin, centered at trig/rwend
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
        when=3;
    else
        when=2;
    end
    rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    % only use the second half of trials from each epoch
    %rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
    %postrwdata = cellfun(@(x) x(ceil(length(x)/2):end),postrwdata,'un',0);
    
    rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
    type = cellfun(@(x) x.type,postrwdata);
    %recalc rw rip times relative to trigger/end, combine rw + postrw
    combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata,postrwdata,'un',0);
    ripmat{a,1} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
    binclude{a,1} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata,postrwdata,'UniformOutput',0));
    if a<=4
        for b = 1:length(centers)
            rip(a,b) = toHz*(mean(ripmat{a}(type>=1 & binclude{a}(:,b),b)));
            rip_sem(a,b) = toHz*(std(ripmat{a}(type>=1 & binclude{a}(:,b),b))/sqrt(sum(type>=1 & binclude{a}(:,b))));
        end
        valbins_rip(a,:) = sum(binclude{a}(type>=1,:))>100;
        subplot(2,4,a); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
        plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
        plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1); ylim([0 3]); xlim([-20 20])
    else
        for b = 1:length(centers)
            rip(a,b) = toHz*(mean(ripmat{a}(type==1 & binclude{a}(:,b),b)));
            rip_sem(a,b) = toHz*(std(ripmat{a}(type==1 & binclude{a}(:,b),b))/sqrt(sum(type==1 & binclude{a}(:,b))));
            wait(a,b) = toHz*(mean(ripmat{a}(type==2 & binclude{a}(:,b),b)));
            wait_sem(a,b) = toHz*(std(ripmat{a}(type==2 & binclude{a}(:,b),b))/sqrt(sum(type==2 & binclude{a}(:,b))));
        end
        valbins_rip(a,:) = sum(binclude{a}(type==1,:))>100;
        valbins_wait(a,:) = sum(binclude{a}(type==2,:))>100;
        
        subplot(2,4,a); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)'); hold on;
        plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
        plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1)
        plot([centers(valbins_wait(a,:)); centers(valbins_wait(a,:))], [wait(a,valbins_wait(a,:))-wait_sem(a,valbins_wait(a,:)); wait(a,valbins_wait(a,:))+wait_sem(a,valbins_wait(a,:))],'Color',animcol(a+4,:),'Linewidth',.5);
        plot(centers(valbins_wait(a,:)),wait(a,valbins_wait(a,:)),'Color',animcol(a+4,:),'Linewidth',1)
        ylim([0 3]); xlim([-20 20])
    end
end

%% PART 6 plot median duration at rw, TRIALWISE comparison with lme
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripdur{a} = cellfun(@(x) x.duration,rwdata(type>=1));
        waitdur{a} = ripdur{a};
        labels_rip{a} = [zeros(length(ripdur{a}),1),a+zeros(length(ripdur{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        ripdur{a} = cellfun(@(x) x.duration,rwdata(type==1));
        waitdur{a} = cellfun(@(x) x.duration,rwdata(type==2));
        labels_rip{a} = [ones(length(ripdur{a}),1),a+zeros(length(ripdur{a}),1)];
        labels_wait{a} = [ones(length(waitdur{a}),1),a+zeros(length(waitdur{a}),1)];
    end  
end
allrat_lmeplot(ripdur,waitdur,labels_rip,labels_wait,'spacer',[1 1],'grouped',1)
ylabel('Dwell time pre-reward (s)');title('pre-reward dwell time'); ylim([0 30]);

%% PART 7 mean velocity pre-reward 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        vel = cellfun(@(x) x.meanvel,rwdata);
        ripvels{a} = vel(type>=1);
        waitvels{a} = ripvels{a};
        labels_rip{a} = [zeros(length(ripvels{a}),1),a+zeros(length(ripvels{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        vel = cellfun(@(x) x.meanvel,rwdata);
        ripvels{a} = vel(type==1);
        waitvels{a} =vel(type==2);
        labels_rip{a} = [ones(sum(type==1),1),a+zeros(sum(type==1),1)];
        labels_wait{a} = [ones(sum(type==2),1),a+zeros(sum(type==2),1)];
    end  
end
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
allrat_lmeplot(ripvels,waitvels,labels_rip,labels_wait,'spacer',[1 10],'grouped',1)
ylabel('vel(cm/s)');title('velocity pre-reward');  ylim([0 4]);

%% PART 8 pre-reward riprate with velocity-percentiled NF vs Delay trials 
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        % filter by velocity
        vel = cellfun(@(x) x.meanvel,rwdata);
        % drop high-velocity trials of each type
        rinds = type>=1 & vel<prctile(vel(type==1),25);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(rinds))./cellfun(@(x) x.duration,rwdata(rinds));
        waitrates{a} = riprates{a};
        ripvels{a} =  vel(rinds);
        waitvels{a} =ripvels{a};
        labels_rip{a} = [zeros(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        type = cellfun(@(x) x.type,rwdata);
        % filter by velocity
        vel = cellfun(@(x) x.meanvel,rwdata);
        % drop high-velocity trials of each type
        rinds = type==1 & vel>prctile(vel(type==1),75);
        winds = type==2 & vel<prctile(vel(type==2),25);
        ripvels{a} = vel(rinds);
        waitvels{a} =vel(winds);
        riprates{a} = cellfun(@(x) length(x.size),rwdata(rinds))./cellfun(@(x) x.duration,rwdata(rinds));
        waitrates{a} = cellfun(@(x) length(x.size),rwdata(winds))./cellfun(@(x) x.duration,rwdata(winds));
        labels_rip{a} = [ones(sum(rinds),1),a+zeros(sum(rinds),1)];
        labels_wait{a} = [ones(sum(winds),1),a+zeros(sum(winds),1)];
    end  
end
subplot(1,2,1); hold on;
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[1 10],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate pre-reward top25 fastest NF trials vs bottom 25% slowest ctrl&delay trials');  ylim([0 3]);
subplot(1,2,2); hold on;
allrat_lmeplot(ripvels,waitvels,labels_rip,labels_wait,'spacer',[1 5],'grouped',1)
ylabel('Vel (cm/s)');title('meanvel pre-rew');  ylim([0 4]);

%% PART 9 refractory period following trigger-sized rips on Delay trials  (NF rats only)
clearvars -except f animals animcol
ratetimebin = .5;
timeedges = [0:ratetimebin:10]; %22:2:60
centers = timeedges(2:end)-ratetimebin/2;
toHz = 1/ratetimebin;

maxtime = 5; %in sec
timebin = .01;  % 10ms resolution
timevec = timebin:timebin:maxtime;
cols = [.8 .8 .8; 1 1 1; 0 0 0;];
figure;
for a = 5:length(animals)
    when=2;
    rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    rwdata = vertcat(rwdata{:});
    type = cellfun(@(x) x.type,rwdata); 
    t22 = cellfun(@(x) x.t22,rwdata);
    valtrials = find(t22>0 & type==2);
    grid{a} = [];
    valtrig = 1;
    for t = 1:length(valtrials)
        [trig, tind] = max(rwdata{valtrials(t)}.size);
        if rwdata{valtrials(t)}.duration - rwdata{valtrials(t)}.times(tind) > 2
            valtrig = valtrig+1;
            tmp = timevec<= (rwdata{valtrials(t)}.duration - rwdata{valtrials(t)}.times(tind));
            % identify all ripple times
            starttimes = [rwdata{valtrials(t)}.times(tind:end)-rwdata{valtrials(t)}.times(tind)];
            riplengths = [rwdata{valtrials(t)}.riplengths(tind:end)];
            ripintervals = [starttimes,starttimes+riplengths];
            ripinds = logical(isExcluded(timevec,ripintervals))';
            grid{a} = [grid{a};tmp+ripinds];
            binclude{a}(valtrig,:) = timeedges(2:end-1)<= (rwdata{valtrials(t)}.duration - rwdata{valtrials(t)}.times(tind));
            ripmat{a}(valtrig,:) = histcounts(starttimes,timeedges);  %all    
        end
    end
for b = 1:length(centers)-1
        rip(a,b) = toHz*(mean(ripmat{a}(binclude{a}(:,b),b)));
        rip_sem(a,b) = toHz*(std(ripmat{a}(binclude{a}(:,b),b))/sqrt(sum(binclude{a}(:,b))));
      end
    valbins_rip(a,:) = sum(binclude{a})>10;       
    hold on; title('riprates post suprathreshold events from Delay trials');xlabel('Time since event (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1)
    
%     subplot(1,4,a-4);hold on;
%     imagesc('XData',timevec,'CData',grid{a})
%     colormap(gca,cols)
end
%% PART 10 Assess change in meanvel, dwelltime, etc in Ctrl cohort over epochs 
clearvars -except f animals animcol
figure;
    when=3;
    
    for a = 1:4 %length(animals)
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        for e = 1:length(rwdata)
            rwriprate{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e})./cellfun(@(x) x.duration,rwdata{e}));
            rwriplength{a}(e) = mean(cell2mat(cellfun(@(x) x.riplengths',rwdata{e},'un',0)));
            postrwriprate{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e}));
            postrwdur{a}(e) = mean(cellfun(@(x) x.duration,postrwdata{e}));
            meanvel{a}(e) = nanmean(cellfun(@(x) x.meanvel,rwdata{e}));
        end
        subplot(2,3,1); hold on;
        plot(rwriprate{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(rwriprate{a},[1:length(rwriprate{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('pre-reward riprate'); ylabel('Riprate (Hz)'); xlabel('epochs')
        subplot(2,3,2); hold on;
        plot(postrwriprate{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(postrwriprate{a},[1:length(postrwriprate{a})]);
        text(2,a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('riprate postreward'); ylabel('riprate (hz)'); xlabel('epochs')
        subplot(2,3,3); hold on;
        plot(postrwdur{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(postrwdur{a},[1:length(postrwdur{a})]);
        text(2,12+a,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('dwell time post-reward'); ylabel('time (s)'); xlabel('epochs')
        subplot(2,3,4); hold on;
        plot(meanvel{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(meanvel{a},[1:length(meanvel{a})]);
        text(2,1+a/10,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('meanvel pre-reward'); ylabel('velocity (cm/s)'); xlabel('epochs')
        subplot(2,3,5); hold on;
        plot(rwriplength{a},'.','Color',animcol(a,:)); lsline
        [r,p] = corrcoef(rwriplength{a},[1:length(rwriplength{a})]);
        text(2,a/20,sprintf('r2=%.03f,p=%.03f',r(2)^2,p(2)));
        title('riplengths pre-reward'); ylabel('length (s)'); xlabel('epochs')
    end
    
 
    
    
    
    
%% plot difference bwtn  rate RW and POSTrw, TRIALWISE comparison with lme 
% reviewer request for interaction term; this is a different way of
% comparing the two times (POST-PRE)
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
figure; set(gcf,'Position',[187 1 1374 973]); hold on;
for a = 1:length(animals)
    if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = horzcat(postrwdata{:})';
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = (cellfun(@(x) length(x.size),postrwdata(type==1))./cellfun(@(x) x.duration,postrwdata(type==1))) - (cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1)));
        waitrates{a} = riprates{a};
        labels_rip{a} = [zeros(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = labels_rip{a};
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = horzcat(rwdata{:})'; %all trials in this stage
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = horzcat(postrwdata{:})';
        type = cellfun(@(x) x.type,rwdata);
        riprates{a} = (cellfun(@(x) length(x.size),postrwdata(type==1))./cellfun(@(x) x.duration,postrwdata(type==1))) -(cellfun(@(x) length(x.size),rwdata(type==1))./cellfun(@(x) x.duration,rwdata(type==1)));
        waitrates{a} = (cellfun(@(x) length(x.size),postrwdata(type==2))./cellfun(@(x) x.duration,postrwdata(type==2))) - (cellfun(@(x) length(x.size),rwdata(type==2))./cellfun(@(x) x.duration,rwdata(type==2)));
        labels_rip{a} = [ones(length(riprates{a}),1),a+zeros(length(riprates{a}),1)];
        labels_wait{a} = [ones(length(waitrates{a}),1),a+zeros(length(waitrates{a}),1)];
    end  
end
figure; set(gcf,'Position',[2 374 1915 449]);
hold on; 
allrat_lmeplot(riprates,waitrates,labels_rip,labels_wait,'spacer',[0 20],'grouped',1)
ylabel('SWR rate (Hz)');title('Riprate post-pre'); ylim([-2 2]);
    
%% plot rip rate at rw in .5s windows from start, post-NF
clearvars -except f animals
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255; 
timeedges = [0:.5:40]; %22:2:60
centers = timeedges(2:end);
toHz = 1./diff(timeedges);
figure; set(gcf,'Position',[0 0 800 950]); hold on;
for a = 1:length(animals)
         if a<=4
        when=3;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:});
        type = cellfun(@(x) x.type,rwdata);
        ripmat1{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type>=1),'UniformOutput',0));  %rip
        binclude1{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type>=1),'UniformOutput',0));
        ripmat2{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type>=1),'UniformOutput',0));  % wait
        binclude2{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type>=1),'UniformOutput',0));
    else
        when=2;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:});
        type = cellfun(@(x) x.type,rwdata);
        ripmat1{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type==1),'UniformOutput',0));  %rip
        binclude1{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type==1),'UniformOutput',0));
        ripmat2{a,1} = cell2mat(cellfun(@(x) histcounts(x.times,timeedges),rwdata(type==2),'UniformOutput',0));  % wait
        binclude2{a,1} = cell2mat(cellfun(@(x) x.duration>timeedges(1:end-1),rwdata(type==2),'UniformOutput',0));

    end
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
    title('rw riprates by rat');xlabel('Time (s)'); ylabel('SWR rate (Hz)');  
    plot([centers(valbins1(a,:)); centers(valbins1(a,:))], [binavg1(a,valbins1(a,:))-binsem1(a,valbins1(a,:)); binavg1(a,valbins1(a,:))+binsem1(a,valbins1(a,:))],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins1(a,:)),binavg1(a,valbins1(a,:)),'Color',animcol(a,:),'Linewidth',2)
    if a>4
        plot([centers(valbins2(a,:)); centers(valbins2(a,:))], [binavg2(a,valbins2(a,:))-binsem2(a,valbins2(a,:)); binavg2(a,valbins2(a,:))+binsem2(a,valbins2(a,:))],'Color',animcol(a+4,:),'Linewidth',.5);
    plot(centers(valbins2(a,:)),binavg2(a,valbins2(a,:)),'Color',animcol(a+4,:),'Linewidth',2)
    end
    
%     subplot(1,2,2); hold on;
%     ratiovalbins(a,:) = valbins1(a,:) & valbins2(a,:);
%     ratio = binavg1(a,ratiovalbins(a,:))./binavg2(a,ratiovalbins(a,:));   
%     plot(centers(ratiovalbins(a,:)),ratio,'Color',ripcols(a,:),'Linewidth',1)
%     title('NF/control');
end

%% rw+postrw riprate curves by timebin, centered at trig/rwend - ctrl only, full vs nodelay
clearvars -except f animals animcol
timebin = .5;
timeedges = [-20:timebin:20]; %22:2:60
centers = timeedges(2:end);
toHz = 1/timebin;
cols = [1 0 0; 0 0 0];
figure; set(gcf,'Position',[72 391 1815 443]); hold on;
for a = 5:length(animals)
        when=3;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        type = cellfun(@(x) x.type,postrwdata);
        %recalc rw rip times relative to trigger/end, combine rw + postrw
        combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata,postrwdata,'un',0);
        ripmat{a,1} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
        binclude{a,1} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata,postrwdata,'UniformOutput',0)); 
        
    for b = 1:length(centers)
        rip(a,b) = toHz*(mean(ripmat{a}(type==1 & binclude{a}(:,b),b)));
        rip_sem(a,b) = toHz*(std(ripmat{a}(type==1 & binclude{a}(:,b),b))/sqrt(sum(type>=1 & binclude{a}(:,b))));
      end
    valbins_rip(a,:) = sum(binclude{a}(type==1,:))>100;       
    subplot(1,4,a-4); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),'Color',animcol(a,:),'Linewidth',1)
    
           when=4;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        type = cellfun(@(x) x.type,postrwdata);
        %recalc rw rip times relative to trigger/end, combine rw + postrw
        combined = cellfun(@(x,y) [-1*(x.duration-x.times); y.times],rwdata,postrwdata,'un',0);
        ripmat{a,1} = cell2mat(cellfun(@(x) histcounts(x,timeedges),combined,'UniformOutput',0));  %all
        binclude{a,1} = cell2mat(cellfun(@(x,y) timeedges(2:end)>(-1*x.duration) & timeedges(1:end-1)<y.duration,rwdata,postrwdata,'UniformOutput',0)); 
        
    for b = 1:length(centers)
        rip(a,b) = toHz*(mean(ripmat{a}(type==1 & binclude{a}(:,b),b)));
        rip_sem(a,b) = toHz*(std(ripmat{a}(type==1 & binclude{a}(:,b),b))/sqrt(sum(type>=1 & binclude{a}(:,b))));
      end
    valbins_rip(a,:) = sum(binclude{a}(type==1,:))>100;       
    subplot(1,4,a-4); title(['riprates, ' animals{a}]);xlabel('Time (s)'); ylabel('SWR rate (Hz)');  hold on
    plot([centers(valbins_rip(a,:)); centers(valbins_rip(a,:))], [rip(a,valbins_rip(a,:))-rip_sem(a,valbins_rip(a,:)); rip(a,valbins_rip(a,:))+rip_sem(a,valbins_rip(a,:))],'Color',animcol(a,:),'Linewidth',.5);
    plot(centers(valbins_rip(a,:)),rip(a,valbins_rip(a,:)),':','Color',animcol(a,:),'Linewidth',1)
    
     ylim([0 3]); xlim([-20 20])
end

%% raster of rips across rw-postrw
clearvars -except f animals animcol
cols = [1 0 0; 0 0 0];
for a = 1:length(animals)
    if a<=4
        when=3;
    else
        when=2;
    end
    figure; set(gcf,'Position',[219 70 1657 829]); hold on;
    rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
    rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
    type = cellfun(@(x) x.type,rwdata);
    subplot(2,2,1); ylabel('Trials');  title([animals{a} ' rip trials, post-NF'])
    agplotripraster(rwdata(type==1), postrwdata(type==1),'sortorder','rw'); xlim([-20 5])
    subplot(2,2,3);xlabel('Time (s)'); title('wait trials, post-NF'); ylabel('Trials');
    agplotripraster(rwdata(type==2), postrwdata(type==2),'sortorder','rw'); xlim([-20 5])
    subplot(2,2,2); ylabel('Trials'); xlabel('Time (s)'); title([animals{a} ' rip trials, post-NF'])
    agplotripraster(rwdata(type==1), postrwdata(type==1),'sortorder','postrw'); xlim([-5 10])
    subplot(2,2,4);xlabel('Time (s)'); title('wait trials, post-NF'); ylabel('Trials');
    agplotripraster(rwdata(type==2), postrwdata(type==2),'sortorder','postrw'); xlim([-5 10])

end

%% rates&counts of rips at rw,postrw, control only, comparing delay vs no_delay EPOCHWISE; OBSOLETE
clearvars -except f animals animcol
cols = [1 0 0; 0 0 1; 0 1 0];
rwr = figure(); hold on; postr = figure(); hold on; combr = figure(); hold on;
rwc = figure(); hold on; postc = figure(); hold on; combc = figure(); hold on;
for a = 5:length(animals)
    for when = [3 4]
        offset = (when-2)/4;
        rwdata = arrayfun(@(x) x.rw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = arrayfun(@(x) x.postrw,f(a).output{when},'UniformOutput',0); % stack data from all trials
        for e = 1:length(rwdata)
            ripnums{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e}));
            riprates{a}(e) = mean(cellfun(@(x) length(x.size),rwdata{e})./cellfun(@(x) x.duration,rwdata{e}));
            postripnums{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e}));
            postriprates{a}(e) = mean(cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e}));
            combripnums{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e},postrwdata{e}));
            combriprates{a}(e) = mean(cellfun(@(x,y) length(x.size)+length(y.size),rwdata{e},postrwdata{e})./cellfun(@(x,y) x.duration+y.duration,rwdata{e},postrwdata{e}));
        end
        figure(rwr);
        boxplot(riprates{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(riprates{a},waitrates{a}); text(a,.6+a/10,sprintf('tp=%.04f\nn=%deps',p_t,length(rwdata)))
        title('rw rates'); xlim([.5 9.5]); ylim([0 1.5]);
        
        figure(postr);
        boxplot(postriprates{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(postriprates{a},postwaitrates{a}); text(a,.6+a/10,sprintf('tp=%.04f\nn=%deps',p_t,length(postrwdata)))
        title('postrw rates'); xlim([.5 9.5]); ylim([0 1.5]);
        
        figure(combr); hold on;
        boxplot(combriprates{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(combriprates{a},combwaitrates{a}); text(a,.6+a/10,sprintf('tp=%.03f\nn=%deps',p_t,length(postrwdata)))
        title('combined rates'); xlim([.5 9.5]); ylim([0 1.5]);
        
        figure(rwc); hold on;
        boxplot(ripnums{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(ripnums{a},waitnums{a}); text(a,7+a,sprintf('tp=%.03f\nn=%deps',p_t,length(rwdata)))
        xlim([.5 9.5]); ylim([0 15]); title('rw nums');
        
        figure(postc); hold on;
        boxplot(postripnums{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(postripnums{a},postwaitnums{a}); text(a,7+a,sprintf('tp=%.03f\nn=%deps',p_t,length(postrwdata)))
        title('postrw nums'); xlim([.5 9.5]); ylim([0 15]);
        
        figure(combc); hold on;
        boxplot(combripnums{a},'Positions',a+offset,'Symbol','', 'Width',.2,'Color',cols(when,:))
        %[h,p_t] = ttest(combripnums{a},combwaitnums{a}); text(a,7+a,sprintf('tp=%.03f\nn=%deps',p_t,length(postrwdata)))
        title('combined nums'); xlim([.5 9.5]); ylim([0 15]);
    end
end

%% compare combined pre-post-reward riprate over all trials before and after NF training and early/late for control rats
clearvars -except f animals animcol
figure;
cols = [1 1 0;1 0 0];
for a = 1:length(animals)
    if a<=4
        when=1;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        pre_combriprates{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata,postrwdata)./cellfun(@(x,y) (x.duration+y.duration),rwdata,postrwdata);
        
        when=2;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:}); postrwdata = vertcat(postrwdata{:});
        post_combriprates{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),rwdata,postrwdata)./cellfun(@(x,y) (x.duration+y.duration),rwdata,postrwdata);
        
    else
        when=3;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        postrwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        earlyrwdata = vertcat(rwdata{1:5}); earlypostrwdata = vertcat(postrwdata{1:5});
        pre_combriprates{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),earlyrwdata,earlypostrwdata)./cellfun(@(x,y) (x.duration+y.duration),earlyrwdata,earlypostrwdata);
        
        laterwdata = vertcat(rwdata{end-5:end}); latepostrwdata = vertcat(postrwdata{end-5:end});
        post_combriprates{a} = cellfun(@(x,y) (length(x.size)+length(y.size)),laterwdata,latepostrwdata)./cellfun(@(x,y) (x.duration+y.duration),laterwdata,latepostrwdata);
    end
    hold on;
    boxplot(pre_combriprates{a},'Positions',a,'Symbol','', 'Width',.2,'Color',cols(1,:))
    boxplot(post_combriprates{a},'Positions',a+.25,'Symbol','','Width',.2,'Color',cols(2,:))
    p = ranksum(pre_combriprates{a},post_combriprates{a}); text(a,1+a/20,sprintf('p=%.04f\nn=%d,%d trials',p,length(pre_combriprates{a}),length(post_combriprates{a})))
end
title('combined rates before vs after NF (early/late for ctrl)'); xlim([.5 9.5]); ylim([0 2]);


%% Why do wait trials have higher postrw rates? rw-postrw correlations: rate and number and duration etc, epochwise
% manipulation cohort only
clearvars -except f animals animcol
%ratecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%numcorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
%timecorr = figure(); set(gcf,'Position',[72 65 1736 769]); hold on;
for a = 5:length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{2},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{2},'UniformOutput',0); % stack data from all trials
%     % only use the second half of trials from each epoch
%     rwdata = cellfun(@(x) x(ceil(length(x)/2):end),rwdata,'un',0);
%     postrwdata = cellfun(@(x) x(ceil(length(x)/2):end),postrwdata,'un',0);
    for e = 1:length(postrwdata)
        rwtrialnum = cellfun(@(x) x.trialnum,rwdata{e});
        clear type
        type(rwtrialnum,1) = cellfun(@(x) x.type,rwdata{e})';
        postrwtrialnum = cellfun(@(x) x.trialnum,postrwdata{e});
        rates{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        rates{a}{e}(rwtrialnum,1) = cellfun(@(x) length(x.size),rwdata{e})./cellfun(@(x) x.duration,rwdata{e});
        rates{a}{e}(postrwtrialnum,2) = cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e});
        nums{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        nums{a}{e}(rwtrialnum,1) = cellfun(@(x) length(x.size),rwdata{e});
        nums{a}{e}(postrwtrialnum,2) = cellfun(@(x) length(x.size),postrwdata{e});
        duration{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        duration{a}{e}(rwtrialnum,1) = cellfun(@(x) x.duration,rwdata{e});
        duration{a}{e}(postrwtrialnum,2) = cellfun(@(x) x.duration,postrwdata{e});
        if sum(type==1)>10 & sum(type==2)>10
            valep{a}(e) = 1;
            %             figure(ratecorr); subplot(2,2,a); hold on
                        nonans = ~isnan(rates{a}{e}(:,1)) & ~isnan(rates{a}{e}(:,2));
            %             plot(rwrates{a}{e}(type==1),postrwrates{a}{e}(type==1),'r.'); lsline
            %             plot(rwrates{a}{e}(type==2),postrwrates{a}{e}(type==2),'k.'); lsline
            [rates_rip_r{a}(:,:,e),rates_rip_p{a}(:,:,e)] = corrcoef(rates{a}{e}(type==1 & nonans,1),rates{a}{e}(type==1 & nonans,2));
            [rates_wait_r{a}(:,:,e),rates_wait_p{a}(:,:,e)] = corrcoef(rates{a}{e}(type==2 & nonans,1),rates{a}{e}(type==2 & nonans,2));
            [rates_both_r{a}(:,:,e),rates_both_p{a}(:,:,e)] = corrcoef(rates{a}{e}(nonans,1),rates{a}{e}(nonans,2));    
            %             figure(numcorr); subplot(2,2,a); hold on
                         nonans = ~isnan(nums{a}{e}(:,1)) & ~isnan(nums{a}{e}(:,2));
            %             plot(rwnums{a}{e}(type==1),postrwnums{a}{e}(type==1),'r.'); lsline
            %             plot(rwnums{a}{e}(type==2),postrwnums{a}{e}(type==2),'k.'); lsline
            [nums_rip_r{a}(:,:,e),nums_rip_p{a}(:,:,e)] = corrcoef(nums{a}{e}(type==1 & nonans,1),nums{a}{e}(type==1 & nonans,2));
            [nums_wait_r{a}(:,:,e),nums_wait_p{a}(:,:,e)] = corrcoef(nums{a}{e}(type==2 & nonans,1),nums{a}{e}(type==2 & nonans,2));
            [nums_both_r{a}(:,:,e),nums_both_p{a}(:,:,e)] = corrcoef(nums{a}{e}(nonans,1),nums{a}{e}(nonans,2));       
            %             figure(timecorr); subplot(2,2,a); hold on
                         nonans = ~isnan(duration{a}{e}(:,1)) & ~isnan(duration{a}{e}(:,2));
            %             plot(rwduration{a}{e}(type==1),postrwduration{a}{e}(type==1),'r.'); lsline
            %             plot(rwduration{a}{e}(type==2),postrwduration{a}{e}(type==2),'k.'); lsline
            [durs_rip_r{a}(:,:,e),durs_rip_p{a}(:,:,e)] = corrcoef(duration{a}{e}(type==1 & nonans,1),duration{a}{e}(type==1 & nonans,2));
            [durs_wait_r{a}(:,:,e),durs_wait_p{a}(:,:,e)] = corrcoef(duration{a}{e}(type==2 & nonans,1),duration{a}{e}(type==2 & nonans,2));
            [durs_both_r{a}(:,:,e),durs_both_p{a}(:,:,e)] = corrcoef(duration{a}{e}(nonans,1),duration{a}{e}(nonans,2));   
        end
    end
end
figure; subplot(2,3,1); hold on;
for a = 5:length(animals)
    boxplot(squeeze(rates_rip_r{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(rates_wait_r{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:))
    boxplot(squeeze(rates_both_r{a}(1,2,logical(valep{a}))),'Positions',a-4-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end;
xlim([.5 4.5]); ylim([-1 1]);title('rates, pre x post r, epwise'); plot([.5 4.5],[0 0],'k:')

subplot(2,3,4); hold on; title('rates p')
for a = 5:length(animals); boxplot(squeeze(rates_rip_p{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(rates_wait_p{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:));
end
xlim([.5 4.5]); ylim([0 1]);title('rates p');

subplot(2,3,2); hold on; title('nums, pre x post r')
for a = 5:length(animals); boxplot(squeeze(nums_rip_r{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(nums_wait_r{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:))
    boxplot(squeeze(nums_both_r{a}(1,2,logical(valep{a}))),'Positions',a-4-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end; xlim([.5 4.5]); ylim([-1 1]); plot([.5 4.5],[0 0],'k:')

subplot(2,3,5); hold on; title('nums p')
for a = 5:length(animals); boxplot(squeeze(nums_rip_p{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(nums_wait_p{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:))
end ; xlim([.5 4.5]); ylim([0 1]);

subplot(2,3,3); hold on; title('duration, pre x post r')
for a = 5:length(animals); boxplot(squeeze(durs_rip_r{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(durs_wait_r{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:))
    boxplot(squeeze(durs_both_r{a}(1,2,logical(valep{a}))),'Positions',a-4-.25,'Symbol','','Width',.2,'Color',[1 0 1])
end; xlim([.5 4.5]); ylim([-1 1]);title('duration r'); plot([.5 4.5],[0 0],'k:')

subplot(2,3,6); hold on; title('duration p')
for a = 5:length(animals); boxplot(squeeze(durs_rip_p{a}(1,2,logical(valep{a}))),'Positions',a-4,'Symbol','', 'Width',.2,'Color',animcol(a,:))
    boxplot(squeeze(durs_wait_p{a}(1,2,logical(valep{a}))),'Positions',a-4+.25,'Symbol','','Width',.2,'Color',animcol(a+4,:))
end; xlim([.5 4.5]); ylim([0 1]);

%% Why do wait trials have higher postrw rates? rw-postrw correlations: rate and number and duration etc, trialwise
% manipulation cohort only
clearvars -except f animals animcol
for a = 5:length(animals)
    rwdata = arrayfun(@(x) x.rw',f(a).output{2},'UniformOutput',0); % stack data from all trials
    postrwdata = arrayfun(@(x) x.postrw',f(a).output{2},'UniformOutput',0); % stack data from all trials
    for e = 1:length(postrwdata)
        rwtrialnum = cellfun(@(x) x.trialnum,rwdata{e});
        type{a}{e}(rwtrialnum,1) = cellfun(@(x) x.type,rwdata{e})';
        if sum(type{a}{e}==1)>10 & sum(type{a}{e}==2)>10
            postrwtrialnum = cellfun(@(x) x.trialnum,postrwdata{e});
        rates{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        rates{a}{e}(rwtrialnum,1) = cellfun(@(x) length(x.size),rwdata{e})./cellfun(@(x) x.duration,rwdata{e});
        rates{a}{e}(postrwtrialnum,2) = cellfun(@(x) length(x.size),postrwdata{e})./cellfun(@(x) x.duration,postrwdata{e});
        nums{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        nums{a}{e}(rwtrialnum,1) = cellfun(@(x) length(x.size),rwdata{e});
        nums{a}{e}(postrwtrialnum,2) = cellfun(@(x) length(x.size),postrwdata{e});
        duration{a}{e} = nan(max([rwtrialnum;postrwtrialnum]),2);
        duration{a}{e}(rwtrialnum,1) = cellfun(@(x) x.duration,rwdata{e});
        duration{a}{e}(postrwtrialnum,2) = cellfun(@(x) x.duration,postrwdata{e});
        else
            type{a}{e} = [];
        end
    end
    allrates{a} = vertcat(rates{a}{:}); alltypes{a} = vertcat(type{a}{:});
    alldurs{a} = vertcat(duration{a}{:}); allnums{a} = vertcat(nums{a}{:});
    nonans = ~isnan(allrates{a}(:,1)) & ~isnan(allrates{a}(:,2));
    [rates_rip_r{a},rates_rip_p{a}] = corrcoef(allrates{a}(alltypes{a}==1 & nonans,1),allrates{a}(alltypes{a}==1 & nonans,2));
    [rates_wait_r{a},rates_wait_p{a}] = corrcoef(allrates{a}(alltypes{a}==2 & nonans,1),allrates{a}(alltypes{a}==2 & nonans,2));
    [rates_both_r{a},rates_both_p{a}] = corrcoef(allrates{a}(nonans,1),allrates{a}(nonans,2));
    [nums_rip_r{a},nums_rip_p{a}] = corrcoef(allnums{a}(alltypes{a}==1 & nonans,1),allnums{a}(alltypes{a}==1 & nonans,2));
    [nums_wait_r{a},nums_wait_p{a}] = corrcoef(allnums{a}(alltypes{a}==2 & nonans,1),allnums{a}(alltypes{a}==2 & nonans,2));
    [nums_both_r{a},nums_both_p{a}] = corrcoef(allnums{a}(nonans,1),allnums{a}(nonans,2));
    [durs_rip_r{a},durs_rip_p{a}] = corrcoef(alldurs{a}(alltypes{a}==1 & nonans,1),alldurs{a}(alltypes{a}==1 & nonans,2));
    [durs_wait_r{a},durs_wait_p{a}] = corrcoef(alldurs{a}(alltypes{a}==2 & nonans,1),alldurs{a}(alltypes{a}==2 & nonans,2));
    [durs_both_r{a},durs_both_p{a}] = corrcoef(alldurs{a}(nonans,1),allrates{a}(nonans,2));
    sprintf('Rat%d: rate r2=%.05f,p=%d. count: r2=%.05f,p=%d. duration r2=%.05f,p=%d',a, ...
     rates_both_r{a}(2),rates_both_p{a}(2), nums_both_r{a}(2),nums_both_p{a}(2),durs_both_r{a}(2),durs_both_p{a}(2))
end























