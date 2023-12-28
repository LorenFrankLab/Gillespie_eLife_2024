%% Neurofeedback Manu: generate plot of decode + rips
% 
% run on 1 rat at a time; plateau eps: remy: gus:26-30 (worst decoding) bernard:20-28, fievel:18-29 (nice decodes d19)
animals = {'fievel'}; %{'remy','gus','bernard','fievel'}; %

%epochfilter{1} = ['(isequal($cond_phase,''plateau'')) & $ripthresh>=0 & $gooddecode==1'];  % for conditioning rats

epochfilter{1} = ['$session==20 & isequal($type,''run'')'];

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';

% manually specify the tetrode to add
%tet = [25 26 30]; % remy
%tet = [12,18,25]; % bernard
tet = [16,24,27]; % fievel
%tet = [13 15 18]; %monty 2 7 12

f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);
f = setfilterfunction(f, 'dfa_plotripcontent_nf', {'ripdecodesv3','trials','marks','tetinfo'},'animal',animals{1},'posterior',1,'v',3,'tet',tet,'span','full');
f = runfilter(f);

%% 
d=20; e=4;
pos = loaddatastruct('/cumulus/anna/fievel/filterframework/','fievel','pos',[d e])
trials = loaddatastruct('/cumulus/anna/fievel/filterframework/','fievel','trials',[d e])
ex = find(pos{d}{e}.data(:,1)>trials{d}{e}.starttime(145) & pos{d}{e}.data(:,1)<trials{d}{e}.endtime(145));
figure; hold on
plot(pos{d}{e}.data(:,6),pos{d}{e}.data(:,7),'Color',[.8 .8 .8]);
plot(pos{d}{e}.data(ex,6),pos{d}{e}.data(ex,7),'m'); axis square
title('fievel20_4 example trial 145 ~1.216-1.219s')