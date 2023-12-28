function [outs] = agplotripraster(rwtrials,postrwtrials,varargin)

fulllength = 1;
colortrig = 0;
sortorder = 'off'; % 'rw' or 'postrw'
cols = [.8 .8 .8; 1 1 1; 0 0 0; 1 0 0];

if (~isempty(varargin))
    assign(varargin{:});
end

hold on;
maxtime = 80; % in sec, must be even
center = maxtime/2;
timebin = .01;  % 10ms resolution
timevec = timebin:timebin:maxtime;
timeinds = 1:length(timevec)-1;
grid = zeros(length(rwtrials),length(timeinds));
for t = 1:length(rwtrials)
    % define areas inside of the trial
    if rwtrials{t}.duration<center
        intrial = timevec >= (center - rwtrials{t}.duration);
    else
        intrial = ones(size(timevec));
    end
    if postrwtrials{t}.duration<center
        intrial(timevec >= (center + postrwtrials{t}.duration))= 0;
    end
    grid(t,logical(intrial)) = 1;
    % identify all ripple times
    starttimes = [(center - rwtrials{t}.duration) + rwtrials{t}.times; center + postrwtrials{t}.times];
    riplengths = [rwtrials{t}.riplengths; postrwtrials{t}.riplengths];
    if fulllength
        ripintervals = [starttimes,starttimes+riplengths];
    else
        ripintervals = [starttimes,starttimes+3*timebin];
    end
    ripinds = logical(isExcluded(timevec,ripintervals));
    grid(t,ripinds) = 2;
    % identify trigger as last event
    if colortrig & any(rwtrials{t}.times)
        starttimes = [(center - rwtrials{t}.duration) + rwtrials{t}.times(end)];
        riplengths = [rwtrials{t}.riplengths(end)];
        ripintervals = [starttimes,starttimes+riplengths];
        ripinds = logical(isExcluded(timevec,ripintervals));
        grid(t,ripinds) = 3;
    end         
end
% sort by:
switch sortorder
    case 'rw'
        durs = cellfun(@(x) x.duration,rwtrials);
        [newdurs,newinds] = sort(durs);
        newgrid = grid(newinds,:);
    case 'postrw'
        durs = cellfun(@(x) x.duration,postrwtrials);
        [newdurs,newinds] = sort(durs);
        newgrid = grid(newinds,:);
    otherwise
        newgrid=grid;
end
realtime = [-1*center+timebin:timebin:center];
imagesc('XData',realtime,'CData',newgrid)
this = gca;
if colortrig
    colormap(this,cols)
else
    colormap(this,cols(1:3,:))
end
axis tight

%compute outputs for plotting summary
grid(grid==0) = NaN;
grid(grid==1) = 0;
grid(grid>1) = 1;
outs.means = nanmean(grid);
outs.sds = nanstd(grid);
outs.binclude = sum(~isnan(grid));
outs.sems = outs.sds./sqrt(outs.binclude);
outs.timevec = realtime;

end