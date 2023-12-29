function out = dfa_RWsimulation(index, excludeperiods, rippleskons, trials, varargin)

% For each ep:
%  1. Concatenate all time spent at the wait well; create pool of rips and triggers
%  2. For each rip trial, identify the trigger size and duration
%  3. Identify a matching sized rip in the wait pool and pull a chunk of data out with matching preceeding duration

%  Options:
%       appendindex-- Determines whether index is included in output vector
%           Default: 1


%  out is a structure with the following fields
%       index-- Only if appendindex is set to 1 (default)

% define defaults
appendindex = 0;
sdtol = .5;  % tolerance of window to identify matching rips
ripthresh = 2;
timeexclusion = 0; % 1 subtracts .2 from end time of all trials
eventexclusion = 0; % 1 removes the final ripple from end of each trial

% process varargin if present and overwrite default values
if (~isempty(varargin))
    assign(varargin{:});
end

% todo:
% add way to specify first half, second half, last n trials

d = index(1);
e = index(2);
trialdayep = []; %initialize

if isempty(trials{d}) || isempty(trials{d}{e}) || isempty(rippleskons{d})
    out.rips = [];
    out.trialdayep = [];
    out.simrips = [];
else
    
    %valid trials are any RWsuccess trials (lockouts after are ok)
    validtrials = cellfun(@isempty,trials{d}{e}.lockstarts) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
    timebins = [trials{d}{e}.RWstart(validtrials), trials{d}{e}.RWend(validtrials)];
    valt22s = trials{d}{e}.t22times(validtrials);
    
    if size(timebins, 1) > 0    % there are valid trials to analyze and rips detected on this day
        
        trialdayep = [trialdayep; repmat(index,sum(validtrials),1), trials{d}{e}.trialtype(validtrials)]; % [d e trialtype]
        % exclude events during mobility
        immoevents = ~isExcluded(rippleskons{d}{e}{1}.starttime, excludeperiods) & ~isExcluded(rippleskons{d}{e}{1}.endtime, excludeperiods);
        overthresh = rippleskons{d}{e}{1}.maxthresh>ripthresh;
        ripstarttimes = rippleskons{d}{e}{1}.starttime(immoevents & overthresh);
        ripsizes = rippleskons{d}{e}{1}.maxthresh(immoevents & overthresh);
        ripendtimes = rippleskons{d}{e}{1}.endtime(immoevents & overthresh);
        
        %initialize pool parameters
        waitpoolendtime = 0;
        waitpoolriptimes = [];
        waitpoolripsizes = [];
        waitpooltriggers = [];
        duration = [];
        for t = 1:size(timebins,1)  %iterate through valid trials
            
            rips{t}.waitlength = timebins(t,2)-timebins(t,1);
            valrips = find(isExcluded(ripstarttimes,timebins(t,:)));
            valtriggers = find(isExcluded(valt22s{t},timebins(t,:)));
            if ~isempty(valrips)
                rips{t}.size = ripsizes(valrips);
                rips{t}.times = ripstarttimes(valrips)-timebins(t,1);  %time relative to start of timebin
            else
                rips{t}.size = [];
                rips{t}.times = [];
            end
            
            if trialdayep(t,3) == 2 % if wait trial, add to concatenated timeseries
                waitpoolriptimes = [waitpoolriptimes; rips{t}.times + waitpoolendtime]; %reassign times based on prev pool endtime
                waitpoolripsizes = [waitpoolripsizes; rips{t}.size];
                if ~isempty(valtriggers)
                    waitpooltriggers = [waitpooltriggers; (valt22s{t}(valtriggers)-timebins(t,1))+waitpoolendtime];
                end
                waitpoolendtime = waitpoolendtime + rips{t}.waitlength;  % update endtime
            end
        end
        
        % now generate new simulated wait trials
        if ~isempty(waitpooltriggers)
            ripdurs = cellfun(@(x) x.waitlength,rips(trialdayep(:,3)==1));
            for t = 1:length(ripdurs)
                % search through randomized triggers to find one with no preceeding trigs in window
                randtriggers = randperm(length(waitpooltriggers));
                r = 1;
                while r<=length(randtriggers)
                    trigtime = waitpooltriggers(randtriggers(r));
                    if any(isExcluded(waitpooltriggers,[trigtime-ripdurs(t) trigtime-.001]))  % -1ms from simbin to exclude the matched trig rip from size checking
                        %disp('this chunk contains a too big rip, skip')
                        if r==length(randtriggers) % run out of options, give up
                            disp('tried all candidates but no matches')
                            simrips{t}.times = [];
                            simrips{t}.size = [];
                            simrips{t}.waitlength = duration(t);
                        end
                        r = r + 1;
                    else
                        simripinds = find(isExcluded(waitpoolriptimes,[trigtime-ripdurs(t) trigtime+.1]));
                        simrips{t}.times = waitpoolriptimes(simripinds)-(trigtime-ripdurs(t));
                        simrips{t}.size = waitpoolripsizes(simripinds);
                        simrips{t}.waitlength = ripdurs(t);
                        r = length(randtriggers)+1;  % exit while loop
                    end
                end
            end
        else
            simrips = [];
        end
        % Exclude trigger rip
        % Time exclusion method: cut off anything within 200ms of end
        % Event exclusion method: cut off final rip event if within 1s of end (should catch the biggest ones better)
        
        if timeexclusion
            for t = 1:length(rips)
                if ~isempty(rips{t}.times)
                    if rips{t}.waitlength-rips{t}.times(end) < .5
                        rips{t}.times = rips{t}.times(1:end-1);
                        rips{t}.size = rips{t}.size(1:end-1);
                    end
                end
                rips{t}.waitlength = rips{t}.waitlength - .5;
            end
            for t = 1:length(simrips)
                if ~isempty(simrips{t}.times)
                    if simrips{t}.waitlength-simrips{t}.times(end) <.5
                        simrips{t}.times = simrips{t}.times(1:end-1);
                        simrips{t}.size = simrips{t}.size(1:end-1);
                    end
                end
                simrips{t}.waitlength = simrips{t}.waitlength - .5;
            end
        
        elseif eventexclusion
            for t = 1:length(rips)
                if ~isempty(rips{t}.times)
                    if rips{t}.waitlength-rips{t}.times(end) < 1
                        rips{t}.times = rips{t}.times(1:end-1);
                        rips{t}.size = rips{t}.size(1:end-1);
                    end
                end
            end
            for t = 1:length(simrips)
                if ~isempty(rips{t}.times)
                    if simrips{t}.waitlength-simrips{t}.times(end) < 1
                        simrips{t}.times = simrips{t}.times(1:end-1);
                        simrips{t}.size = simrips{t}.size(1:end-1);
                    end
                end
            end
        end
        
        out.rips = rips;
        out.trialdayep = trialdayep;
        out.simrips = simrips;
    else
        out.rips = [];
        out.trialdayep = [];
        out.simrips = [];
    end
    
    if appendindex
        out.index = index;
    end
    
end