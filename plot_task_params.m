%% plot task parameters  
% remy, gus, bernard, and fievel are neurofeedback animals; jaq, roquefort, despereaux, and montague are control (no feedback) animals
% (no filterframework required, just task struct)

animals = {'remy','gus','bernard','fievel'}; %,'jaq','roquefort','despereaux','montague' 
animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols


%% PART 1 plot ripthresh only, all animals on one plot
% ripthresh marker indicates pre/early/late/plateau stage of conditioning
figure; set(gcf,'Position',[66 104 1612 843]); 
clear reps ripthresh stage
stages = {'pre','early','late','plateau'}; %
stagemarks = {'o','^','x','*'}; %
%converter = [0 0 0 1 0 0 0 0 0 2 0 0 0 0 3]; 
for a = 1:length(animals)
    animalinfo = animaldef(animals{a});
    task = loaddatastruct(animalinfo{2},animals{a},'task');
    eps = evaluatefilter(task,'$ripthresh>=0 & isequal($type,''run'')'); % isequal($environment,''goal'') & $gooddecode==1
    for e = 1:size(eps,1)
        if isfield(task{eps(e,1)}{eps(e,2)},'cond_phase')  % only include eps that are a relevant stage
            ripthresh{a}(e) = task{eps(e,1)}{eps(e,2)}.ripthresh;
            stage{a}{e} = task{eps(e,1)}{eps(e,2)}.cond_phase;
        end
    end
    stagenums{a} = cellfun(@(x) find(strcmp(x,stages)),stage{a});
    hold on; %plot(converter(reps{a}),'.-','LineWidth',2,'Color',animcol(a,:),'MarkerSize',15)
    plot(ripthresh{a}(ripthresh{a}>0),'.-','LineWidth',1,'Color',animcol(a+4,:));
%     for i=1:length(stages)
%         plot(find(stagenums{a}==i),ripthresh{a}(stagenums{a}==i),'Marker',stagemarks{i},'Color',animcol(a+4,:),'LineStyle','none');
%     end
    ylim([0 25]);  xlabel('epoch'); ylabel('ripthresh'); %xlim([0 120]); set(gca,'ytick',[1 2 3],'yticklabel',{'4-12','10','15'});
end

%% PART 2 plot outerreps and ripthresh per animal 
% ripthresh marker indicates pre/early/late/plateau stage of conditioning
% outerreps marker filled indicates full goal task vs some other variant (multi arms rewarded, nodelay, bad, etc)
% black dot along top indicates good decode quality 

% switch variants at end of gus/bern/fiev are not decoded

figure; set(gcf,'Position',[66 104 1612 843]); 
clear reps ripthresh stage
stages = {'none','pre','early','late','plateau'};
stagemarks = {'.','o','^','x','*'};
%converter = [0 0 0 1 0 0 0 0 0 2 0 0 0 0 3]; 
for a = 1:length(animals)
    animalinfo = animaldef(animals{a});
    task = loaddatastruct(animalinfo{2},animals{a},'task');
    eps = evaluatefilter(task,'$ripthresh>=0 & isequal($type,''run'')'); % isequal($environment,''goal'') & $gooddecode==1
    for e = 1:size(eps,1)
        reps{a}(e) = task{eps(e,1)}{eps(e,2)}.outerreps;
        ripthresh{a}(e) = task{eps(e,1)}{eps(e,2)}.ripthresh;
        if isfield(task{eps(e,1)}{eps(e,2)},'cond_phase')
            stage{a}{e} = task{eps(e,1)}{eps(e,2)}.cond_phase;
        else
            stage{a}{e} = 'none';
        end
        if strcmp(task{eps(e,1)}{eps(e,2)}.environment,'goal')
            goal{a}(e) = 1;
        else
            goal{a}(e) = 0;
        end
        if isfield(task{eps(e,1)}{eps(e,2)},'gooddecode')
            gooddec{a}(e) = task{eps(e,1)}{eps(e,2)}.gooddecode;
        else
            gooddec{a}(e) = 0;
        end
    end
    stagenums{a} = cellfun(@(x) find(strcmp(x,stages)),stage{a});
    subplot(4,2,a); hold on; %plot(converter(reps{a}),'.-','LineWidth',2,'Color',animcol(a,:),'MarkerSize',15)
    plot(reps{a},'o-','LineWidth',1,'Color',animcol(a,:))
    plot(find(goal{a}==1),reps{a}(goal{a}==1),'.','LineWidth',1,'Color',animcol(a,:),'MarkerSize',15)    
    plot(ripthresh{a},'.-','LineWidth',1,'Color',animcol(a,:));
    for i=1:length(stages)
        plot(find(stagenums{a}==i),ripthresh{a}(stagenums{a}==i),'Marker',stagemarks{i},'Color',animcol(a,:),'LineStyle','none');
    end
    plot(find(gooddec{a}==1),23*ones(sum(gooddec{a}==1),1),'k.')
    ylim([0 25]); title(animals{a}); xlabel('epoch'); ylabel('outerreps'); %xlim([0 120]); set(gca,'ytick',[1 2 3],'yticklabel',{'4-12','10','15'});
end

%% PART 3 plot t22 delay (for conditioning animals only)

figure; set(gcf,'Position',[66 104 1612 843]); 
clear t22
for a = 1:4 %length(animals)
    animalinfo = animaldef(animals{a});
    task = loaddatastruct(animalinfo{2},animals{a},'task');
    eps = evaluatefilter(task,'$ripthresh>=0 & isequal($environment,''goal'') & $gooddecode==1'); %
    for e = 1:size(eps,1)
        t22{a}(e) = task{eps(e,1)}{eps(e,2)}.t22delay;
    end
    subplot(4,2,a); hold on; 
    plot(t22{a},'.-','LineWidth',2,'Color',animcol(a,:),'MarkerSize',15)
    ylim([0 150]); xlim([0 80]); title(animals{a}); xlabel('epoch'); ylabel('t22 delay');
end

%%