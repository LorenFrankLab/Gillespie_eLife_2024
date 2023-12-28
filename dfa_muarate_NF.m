function out = dfa_muarate_NF(index, excludeperiods, marks, tetinfo, rippleskons, trials, varargin)

% define defaults
appendindex = 1;
ripthresh = 2;   % exclude events based on size (thresh of 2 includes all)
excltrigger = 0;  % if 1, exclude trigger events & provide log of excluded events
excludeRWstart = 0;
% process varargin if present and overwrite default values
if (~isempty(varargin))
    assign(varargin{:});
end

d = index(1);
e = index(2);
phases = {'rw','postrw'}; %'home','outer','lock'
sprintf('d%d e%d',d,e)

if isempty(trials{d}) || isempty(trials{d}{e}) || isempty(rippleskons{d}) 
    out = [];
else
    
    tets = evaluatefilter(tetinfo{d}{e},'isequal($area,''ca1'')');
    spiketimes = cellfun(@(x) x.times,marks{d}{e}(tets),'UniformOutput',0);
    % concatenate times from all tetrodes, then reorder
    spiketimes = sort(vertcat(spiketimes{:}));
    immoinds = ~isExcluded(spiketimes,excludeperiods);
 
    immoevents = ~isExcluded(rippleskons{d}{e}{1}.starttime, excludeperiods) & ~isExcluded(rippleskons{d}{e}{1}.endtime, excludeperiods);
    overthresh = rippleskons{d}{e}{1}.maxthresh>ripthresh;
    ripstarttimes = rippleskons{d}{e}{1}.starttime(immoevents & overthresh);
    ripsizes = rippleskons{d}{e}{1}.maxthresh(immoevents & overthresh);
    ripendtimes = rippleskons{d}{e}{1}.endtime(immoevents & overthresh);
    
    % if specified, find and remove all trigger events and their spikes 
    if excltrigger & any(~cellfun(@isempty,trials{d}{e}.t22times))
        t22s = vertcat(trials{d}{e}.t22times{:});
        t22_trialnums=cellfun(@(i,x) repmat(i,length(x),1),num2cell([1:length(trials{d}{e}.starttime)])',trials{d}{e}.t22times,'un',0);
        for i=1:length(t22s)
            tmp = find(ripstarttimes<t22s(i) & ripendtimes>t22s(i));
            if isempty(tmp)
                ind(i) = nan;
            elseif length(tmp)>1
                ind(i) = -1; %multiple matches found
                disp('multip matches found')
            else
                ind(i) = tmp;
                spikecount(i) = sum(spiketimes>=ripstarttimes(tmp) & spiketimes<=ripendtimes(tmp)); 
            end
        end
        triggersizes = ripsizes(ind(ind>0));
        trigspikes = isExcluded(spiketimes, [ripstarttimes(ind(ind>0)),ripendtimes(ind(ind>0))]);
        out.removedrips =[t22s,vertcat(t22_trialnums{:})]; %[t22time, trialnum ripsize(if matched,nan if not), muarate]
        out.removedrips(ind>0,3) = triggersizes;
        out.removedrips(ind>0,4) = (spikecount(ind>0)'./(ripendtimes(ind(ind>0))-ripstarttimes(ind(ind>0))))/length(tets);

        keepers = ones(1,length(ripstarttimes));
        keepers(ind(ind>0)) = 0;
        ripstarttimes = ripstarttimes(find(keepers));
        ripsizes = ripsizes(find(keepers));
        ripendtimes = ripendtimes(find(keepers));
    else
        out.removedrips = [];
        trigspikes = zeros(length(spiketimes),1);
    end
    
    
    for p = 1:length(phases)
        tphase = phases{p};
        switch tphase
            case 'home'
                validtrials = trials{d}{e}.starttime > 0 & trials{d}{e}.leavehome>0; %all!
                timebins = [trials{d}{e}.starttime(validtrials), trials{d}{e}.leavehome(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = ones(sum(validtrials),1);   % no classifier here
                hometimes = timebins;
            case 'rw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                notimeleft = trials{d}{e}.RWend-(trials{d}{e}.RWstart+excludeRWstart) <= 0;  % remove trials that have less than excludeRWstart duration
                validtrials = validtrials & ~notimeleft;
                timebins = [trials{d}{e}.RWstart(validtrials)+excludeRWstart, trials{d}{e}.RWend(validtrials)];  % +trigwin (no more trigwin )
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);
                rwtimes = [timebins, classifier];
            case 'postrw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                timebins = [trials{d}{e}.RWend(validtrials), trials{d}{e}.leaveRW(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);
            case 'outer'
                validtrials = trials{d}{e}.outertime>0;
                timebins = [trials{d}{e}.outertime(validtrials), trials{d}{e}.leaveouter(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.outersuccess(validtrials);
            case 'lock'
                validtrials = ~cellfun(@isempty,trials{d}{e}.lockstarts);
                timebins = [cellfun(@(x) x(1),trials{d}{e}.lockstarts(validtrials)), trials{d}{e}.endtime(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = ones(sum(validtrials),1);  % no subtypes
                locktimes = timebins;
            otherwise
                disp('trialphase not recognized')
        end
        
        if size(timebins, 1) > 0    % there are valid trials to analyze and rips detected on this day
            
%             % label task phases of each trial (forage, goal, error...)
%             valtrials = trials{d}{e}.leavehome>0;   % since lockouts are included, set xlim to exclude the zeros that come with lock trials
%             nonlocktrials = valtrials & cellfun(@isempty,trials{d}{e}.lockstarts);
%             taskphase = nan(length(trials{d}{e}.starttime),1);
%             if any(nonlocktrials)
%                 taskphase(find(nonlocktrials)) = label_trial_interval(trials{d}{e},(nonlocktrials));
%             end
%             %errortrials = mod(taskphase,1)>0;
%             trips.taskphase = taskphase; % these don't actually get saved out
%             trips.trialtype = trials{d}{e}.trialtype;
           
            for t = 1:size(timebins,1)  %iterate through valid trials
                rips{t}.startend = timebins(t,:);
                rips{t}.duration = timebins(t,2)-timebins(t,1);
                rips{t}.immobile = sum(~isExcluded([timebins(t,1):.001:timebins(t,2)],excludeperiods))/1000; % ms time bins, convert back to ms
                valrips = find(isExcluded(ripstarttimes,timebins(t,:)));
                if ~isempty(valrips)
                    rips{t}.size = ripsizes(valrips);
                    rips{t}.times = ripstarttimes(valrips)-timebins(t,1);  %time relative to start of timebin
                    rips{t}.riplengths = ripendtimes(valrips)-ripstarttimes(valrips);
                    rips{t}.riprate = length(rips{t}.size)/rips{t}.immobile;
                    rips{t}.cumsize = sum(rips{t}.size);
                    for r = 1:length(valrips)
                        ripinds(r,:) = isExcluded(spiketimes,[ripstarttimes(r),ripendtimes(r)])';
                        rips{t}.ripmua(r,1) = sum(ripinds(r,:))/(rips{t}.riplengths(r)*length(tets));
                    end
                else
                    rips{t}.size = [];
                    rips{t}.riplengths = [];
                    rips{t}.times = [];
                    rips{t}.riprate = 0;
                    rips{t}.cumsize = 0;
                    ripinds = zeros(1,length(spiketimes));
                    rips{t}.ripmua = [];
                end
                trialinds = isExcluded(spiketimes,rips{t}.startend);
                rips{t}.immomua_norips = sum(immoinds & trialinds & ~logical(trigspikes) & ~sum(ripinds,1)')/(rips{t}.immobile*length(tets));
                rips{t}.type = classifier(t); 
                clear ripinds
            end
            eval(['out.' tphase ' = rips;']);
            clear rips;
        else
            eval(['out.' tphase ' = [];']);
        end       
    end

if appendindex
        out.index = index;
    end
end

    
end