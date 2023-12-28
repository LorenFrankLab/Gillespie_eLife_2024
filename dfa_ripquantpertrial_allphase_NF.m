function out = dfa_ripquantpertrial_allphase_NF(index, excludeperiods, rippleskons, trials, pos, varargin)

%  Parse through trials; note size and time of each ripple in each trial phase 
%   Also save whether or not wait trials contain a trigger event (t22) for later exclusion
% For each trial phase, include the trials with no lockout through that phase 
% note: always check that leavehome>0 in order to exclude bug trials

% phases: home, r/w, postr/w, outer(rew/unrew), lockout, other
%  Options:
%       appendindex-- Determines whether index is included in output vector
%           Default: 1
%       trialphase-- what part of the trial to select. options = 1:home, 2:rw, 3:postrw,4:outer
%           Default: 2 (rw)
%       ripthresh-- exclude events based on size (thresh of 2 includes all)
%           Default: 2
%       includelockouts-- 1=lockouts included; 0 = no lockout trials included -1 = include trials with lockouts after rw success -2 = lockout times only
%           Default: 1

% define defaults
appendindex = 1;
ripthresh = 2;   % exclude events based on size (thresh of 2 includes all)
excltrigger = 0;  % if 1, exclude trigger events & provide log of excluded events
excludeRWstart= 0;
excludepostRWstart = 0;
% process varargin if present and overwrite default values
if (~isempty(varargin))
    assign(varargin{:});
end

d = index(1);
e = index(2);
phases = {'home','rw','postrw','outer','lock'};

if isempty(trials{d}) || isempty(trials{d}{e}) || isempty(rippleskons{d}) 
    out = cell2struct(cell(5,1),phases,1);
    out.index = [];
    out.removedrips = [];
    out.hasexcluded = [];
else
    % initialize 
    out = cell2struct(cell(5,1),phases,1);
    out.index = [];
    out.removedrips = [];
    out.hasexcluded = [];
    
    immoevents = ~isExcluded(rippleskons{d}{e}{1}.starttime, excludeperiods) & ~isExcluded(rippleskons{d}{e}{1}.endtime, excludeperiods);
    overthresh = rippleskons{d}{e}{1}.maxthresh>ripthresh;
    ripstarttimes = rippleskons{d}{e}{1}.starttime(immoevents & overthresh);
    ripsizes = rippleskons{d}{e}{1}.maxthresh(immoevents & overthresh);
    ripendtimes = rippleskons{d}{e}{1}.endtime(immoevents & overthresh);
    
    % if specified, find and remove all trigger events
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
            end
        end
        triggersizes = ripsizes(ind(ind>0));
        out.removedrips =[t22s,vertcat(t22_trialnums{:})]; %[t22time, trialnum ripsize(if matched,nan if not), latency]
        out.removedrips(ind>0,3) = triggersizes;
        out.removedrips(ind>0,4) = t22s(ind>0)-ripstarttimes(ind(ind>0));

        keepers = ones(1,length(ripstarttimes));
        keepers(ind(ind>0)) = 0;
        ripstarttimes = ripstarttimes(find(keepers));
        ripsizes = ripsizes(find(keepers));
        ripendtimes = ripendtimes(find(keepers));
    else
        out.removedrips = [];
    end
    
    for p = 1:length(phases)
        tphase = phases{p};
        trialnumbers = [1:length(trials{d}{e}.starttime)];
        switch tphase
            case 'home'
                validtrials = trials{d}{e}.starttime > 0 & trials{d}{e}.leavehome>0; %all!
                timebins = [trials{d}{e}.starttime(validtrials), trials{d}{e}.leavehome(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = ones(sum(validtrials),1);   % no classifier here
                valtrialnums = trialnumbers(validtrials);
            case 'rw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                notimeleft = trials{d}{e}.RWend-(trials{d}{e}.RWstart+excludeRWstart) <= 0;  % remove trials that have less than trigwin duration
                validtrials = validtrials & ~notimeleft;
                timebins = [trials{d}{e}.RWstart(validtrials)+excludeRWstart, trials{d}{e}.RWend(validtrials)];  % +trigwin (no more trigwin )
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);
                % check fraction of timebins that contain a trigger
                if size(timebins,1)>0 & ~isempty(out.removedrips)
                    for i=1:size(timebins,1)
                        excluded(i) = any(isExcluded(out.removedrips(:,1),timebins(i,:)));
                    end
                    out.hasexcluded = [sum(excluded(classifier==1)),sum(classifier==1),sum(excluded(classifier==2)),sum(classifier==2)];
                else
                    out.hasexcluded = [];
                end
                valtrialnums = trialnumbers(validtrials);
            case 'postrw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                if excludepostRWstart
                    notimeleft = trials{d}{e}.leaveRW-(trials{d}{e}.RWend+excludepostRWstart) <= 0;  % remove trials that have less than trigwin duration
                    validtrials = validtrials & ~notimeleft;
                end
                timebins = [trials{d}{e}.RWend(validtrials)+excludepostRWstart, trials{d}{e}.leaveRW(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);
                valtrialnums = trialnumbers(validtrials);
            case 'outer'
                validtrials = trials{d}{e}.outertime>0;
                timebins = [trials{d}{e}.outertime(validtrials), trials{d}{e}.leaveouter(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.outersuccess(validtrials);
                valtrialnums = trialnumbers(validtrials);
            case 'lock'
                validtrials = ~cellfun(@isempty,trials{d}{e}.lockstarts);
                timebins = [cellfun(@(x) x(1),trials{d}{e}.lockstarts(validtrials)), trials{d}{e}.endtime(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);  % if it was rip or wait trial             
                valtrialnums = trialnumbers(validtrials);
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
                rips{t}.trialnum = valtrialnums(t);
                rips{t}.duration = timebins(t,2)-timebins(t,1);
                valrips = find(isExcluded(ripstarttimes,timebins(t,:)));
                if ~isempty(valrips)
                    rips{t}.size = ripsizes(valrips);
                    rips{t}.times = ripstarttimes(valrips)-timebins(t,1);  %time relative to start of timebin
                    rips{t}.riplengths = ripendtimes(valrips)-ripstarttimes(valrips);
                else
                    rips{t}.size = [];
                    rips{t}.riplengths = [];
                    rips{t}.times = [];
                end
                rips{t}.t22 = sum(isExcluded(t22info{t},[timebins(t,1) timebins(t,2)]));
                rips{t}.type = classifier(t);
                
                %calculate mean velocity during rw time
                posinds = logical(isExcluded(pos{d}{e}.data(:,1), [timebins(t,1) timebins(t,2)]));
                rips{t}.meanvel=mean(pos{d}{e}.data(posinds,9));
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