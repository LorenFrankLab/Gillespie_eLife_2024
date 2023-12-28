function out = dfa_positionvariance(index, excludeperiods, pos, trials, varargin)

% define defaults
appendindex = 1;
% process varargin if present and overwrite default values
if (~isempty(varargin))
    assign(varargin{:});
end

d = index(1);
e = index(2);

if isempty(trials{d}) || isempty(trials{d}{e}) 
    out = [];
else
    phases = {'rw','postrw'};
    for p = 1:length(phases)
        tphase = phases{p};
        switch tphase
            case 'rw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                timebins = [trials{d}{e}.RWstart(validtrials), trials{d}{e}.RWend(validtrials)];  
                classifier = trials{d}{e}.trialtype(validtrials);
                rwtimes = [timebins, classifier];
            case 'postrw'
                validtrials = (cellfun(@isempty,trials{d}{e}.lockstarts) & trials{d}{e}.leavehome>0) | (trials{d}{e}.RWsuccess & ~cellfun(@isempty,trials{d}{e}.lockstarts));
                timebins = [trials{d}{e}.RWend(validtrials), trials{d}{e}.leaveRW(validtrials)];
                t22info = trials{d}{e}.t22times(validtrials);
                classifier = trials{d}{e}.trialtype(validtrials);
        end
        
        if size(timebins, 1) > 0    % there are valid trials to analyze
            for t = 1:size(timebins,1)  %iterate through valid trials
                posinds = logical(isExcluded(pos{d}{e}.data(:,1), [timebins(t,1) timebins(t,2)]));
                tdata{t}.meanvel=mean(pos{d}{e}.data(posinds,9));
                tdata{t}.stdvel=std(pos{d}{e}.data(posinds,9));
                tdata{t}.veltrace = pos{d}{e}.data(posinds,9);
                tdata{t}.std_x=std(pos{d}{e}.data(posinds,2));  % interpolated but NOT smoothed position
                tdata{t}.std_y=std(pos{d}{e}.data(posinds,3));
                tdata{t}.type = classifier(t);
            end
            eval(['out.' tphase ' = tdata;']);
            clear tdata;
        else
            eval(['out.' tphase ' = [];']);
        end       
    end

if appendindex
        out.index = index;
    end
end

    
end