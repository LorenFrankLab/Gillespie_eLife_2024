%% visualize raw data

animal = 'despereaux'; %d8_2_t27
%animal = 'roquefort'; %d15_e2_t25
%animal = 'remy'; %d23 e2 t26
%animal = 'bernard';

destdir = '/cumulus/anna/despereaux/filterframework/';
Fs = 1500;
fps = 30;
day = 8;
ep = 2;
%tets = [24]; %20
task = loaddatastruct(destdir,animal,'task');
tetinfo = loaddatastruct(destdir,animal,'tetinfo');
tets = evaluatefilter(tetinfo{day}{ep},'isequal($area,''ca1'')'); %   $session~=33 & $session~=34 ?
rips = loaddatastruct(destdir,animal,'ca1rippleskons',[day ep]);
%pos = loaddatastruct(destdir,animal,'pos',day);
%posstartind = lookup(starttime,pos{day}{ep}.data(:,1));
%posendind = lookup(endtime,pos{day}{ep}.data(:,1));
%postimevec = pos{day}{ep}.data(posstartind:posendind,1);  %linspace(starttime,endtime,posendind-posstartind+1);
immobilefilter = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
immoperiods = kk_evaluatetimefilter(destdir,animal, {immobilefilter}, [day ep]);
immoevents = isExcluded(rips{day}{ep}{1}.starttime, immoperiods{day}{ep}) & isExcluded(rips{day}{ep}{1}.endtime, immoperiods{day}{ep});    
%riptimes = rips{day}{ep}{1}.starttime(rips{day}{ep}{1}.starttime>starttime & rips{day}{ep}{1}.starttime<endtime & immoevents);
ripfilt = loadeegstruct(destdir,animal,'ripple',day,ep,tets);
trials = loaddatastruct(destdir,animal,'trials');
eeg = loadeegstruct(destdir,animal,'eeg',day,ep,tets);
eegtimes = geteegtimes(eeg{day}{ep}{tets(1)});

%% choose 5 random RW success trials
% for saving, only do one trial at a time otherwise too big and exports as image
plottet = 27;
figure; set(gcf,'Position',[66 1 1855 1001])
centerlength = trials{day}{ep}.leaveRW - trials{day}{ep}.RWstart;
valtrials = find(trials{day}{ep}.RWsuccess==1 & trials{day}{ep}.outertime>0 & centerlength<20 & centerlength>15 );
trialinds = [11 0 0 0 0]; %randi([1 length(valtrials)],5,1); % [1,2]; 
for t = 1:length(trialinds)
    axh = subplot(length(trialinds),1,t); hold on;
    tind = valtrials(trialinds(t));
    plotwin = [trials{day}{ep}.RWstart(tind) trials{day}{ep}.leaveRW(tind)];
    trips = find(immoevents & isExcluded(rips{day}{ep}{1}.starttime,plotwin) & isExcluded(rips{day}{ep}{1}.endtime, plotwin));    
    x = [rips{day}{ep}{1}.starttime(trips)';rips{day}{ep}{1}.endtime(trips)'; rips{day}{ep}{1}.endtime(trips)'; rips{day}{ep}{1}.starttime(trips)']-plotwin(1);
    y = repmat([-3000 -3000 1000 1000]',1,length(trips));
    patch(x,y,'r','FaceAlpha',.3,'EdgeColor','none')
    eeginds = lookup(plotwin,eegtimes);
    % plot every OTHER point so that objects aren't as big and bulky (doesn't affect shape)
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),eeg{day}{ep}{plottet}.data([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),-1000+2*ripfilt{day}{ep}{plottet}.data([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),-2200+10*rips{day}{ep}{1}.powertrace([eeginds(1):2:eeginds(2)]),'r','LineWidth',.5)
    if trials{day}{ep}.trialtype(tind) == 1
        plot([trials{day}{ep}.RWstart(tind)-plotwin(1), trials{day}{ep}.RWend(tind)-plotwin(1)],[-2500 -2500],'g','LineWidth',2)
        plot([trials{day}{ep}.RWend(tind)-plotwin(1), trials{day}{ep}.leaveRW(tind)-plotwin(1)],[-2500 -2500],'g--','LineWidth',2)
    elseif trials{day}{ep}.trialtype(tind) == 2
        plot([trials{day}{ep}.RWstart(tind)-plotwin(1), trials{day}{ep}.RWend(tind)-plotwin(1)],[-2500 -2500],'b','LineWidth',2)    
        plot([trials{day}{ep}.RWend(tind)-plotwin(1), trials{day}{ep}.leaveRW(tind)-plotwin(1)],[-2500 -2500],'b--','LineWidth',2)
    end
    
    xlim([0 20]); ylim([-3000 1000]); xlabel('time (s)') ;
    title(sprintf('%s d%de%dt%d trial%d ripsizes %s',animal,day,ep,plottet,tind,num2str(floor(rips{day}{ep}{1}.maxthresh(trips)'))))
    pan(axh, 'xon'); % horizontal pan
    zoom(axh, 'xon'); % horizontal zoom
end


%% plot traces for ripple detection schematic
figure; set(gcf,'Position',[66 1 1855 1001])

%select from complete trials with pre-rew delay 15s +/- 5s and only 1 trig event
prerewtime = trials{day}{ep}.RWend - trials{day}{ep}.RWstart;
valtrials = find(trials{day}{ep}.RWsuccess==1 & trials{day}{ep}.trialtype==1 & trials{day}{ep}.outertime>0 & prerewtime>=5 );
tind = valtrials(randi(length(valtrials))); % [1,2]; 

plotwin = [trials{day}{ep}.RWend(tind)-5 trials{day}{ep}.RWend(tind)+1];
trips = find(immoevents & isExcluded(rips{day}{ep}{1}.starttime,plotwin) & isExcluded(rips{day}{ep}{1}.endtime, plotwin));    
eeginds = lookup(plotwin,eegtimes);
moveinds = ~isExcluded(eegtimes,immoperiods{day}{ep});
% raw traces     
% plot every OTHER point so that objects aren't as big and bulky (doesn't affect shape)
ax1 = subplot(2,2,1); hold on;
for t = 1:length(tets)
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),1000*t+eeg{day}{ep}{tets(t)}.data([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
end
ylim([0 1000*t+500])

% filter for ripple band
ax2 = subplot(2,2,2); hold on;
for t = 1:length(tets)
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),400*t+ripfilt{day}{ep}{tets(t)}.data([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
end
ylim([0 400*t+200])


% online asymmetrical envelope calculation
ax3 = subplot(2,2,3); hold on;
detectthresh = 16;
for t = 1:length(tets)
    onlineenv = onlineripenvelope(ripfilt{day}{ep}{tets(t)}.data);
    plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),250*t+onlineenv([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
    tetmean = mean(abs(ripfilt{day}{ep}{tets(t)}.data(moveinds)));
    tetsd = std(double(abs(ripfilt{day}{ep}{tets(t)}.data(moveinds))));
    thresh = tetmean + detectthresh*tetsd;
    plot([0 eegtimes(eeginds(2))-eegtimes(eeginds(1))], 250*t+[thresh thresh],'r')
end
plot([trials{day}{ep}.t22times{tind} trials{day}{ep}.t22times{tind}]'-eegtimes(eeginds(1)),repmat([0; 250],1,length(trials{day}{ep}.t22times{tind})),'r')
ylim([0 250*t+125])

% offline konsensus trace
ax4 = subplot(2,2,4); hold on;
detectthresh = 2;
plot(eegtimes([eeginds(1):2:eeginds(2)])-eegtimes(eeginds(1)),rips{day}{ep}{1}.powertrace([eeginds(1):2:eeginds(2)]),'k','LineWidth',.5)
thresh = rips{day}{ep}{1}.baseline + detectthresh*rips{day}{ep}{1}.std;
plot([0 eegtimes(eeginds(2))-eegtimes(eeginds(1))], [thresh thresh],'r')
x = [rips{day}{ep}{1}.starttime(trips)';rips{day}{ep}{1}.endtime(trips)'; rips{day}{ep}{1}.endtime(trips)'; rips{day}{ep}{1}.starttime(trips)']-plotwin(1);
y = repmat([0 0 250 250]',1,length(trips));
patch(x,y,'r','FaceAlpha',.3,'EdgeColor','none')
text(1,400,sprintf('%s d%de%d trial%d ripsizes %s',animal,day,ep,tind,num2str(floor(rips{day}{ep}{1}.maxthresh(trips)'))))
ylim([0 500])
xlim([0 6])
linkaxes([ax1,ax2,ax3,ax4],'x');
pan(ax1, 'xon'); % horizontal pan
zoom(ax1, 'xon'); % horizontal zoom

% Save via commandline otherwise large size causes it to default to bmp
%exportgraphics(gcf,'test.pdf','BackgroundColor','none','ContentType','vector')

