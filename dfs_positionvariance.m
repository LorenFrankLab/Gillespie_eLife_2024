%% Neurofeedback: variance in tracked position while at center ports
% control and manipulation cohorts

animals = {'jaq','roquefort','despereaux','montague','remy','gus','bernard','fievel'}; 

epochfilter{1} = ['isequal($cond_phase,''plateau'') & isequal($environment,''goal'') '];  %cond rats
epochfilter{2} = ['$ripthresh==0 & (isequal($environment,''goal'')) & $forageassist==0 '];  % for control rats

% resultant excludeperiods will define times when velocity is high
timefilter{1} = {'ag_get2dstate', '($immobility == 1)','immobility_velocity',4,'immobility_buffer',0};
iterator = 'epochbehaveanal';
f = createfilter('animal',animals,'epochs',epochfilter,'excludetime', timefilter, 'iterator', iterator);

f = setfilterfunction(f, 'dfa_positionvariance', {'pos','trials'});
f = runfilter(f);

animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols


%% Plot mean x and y std during pre-reward
clearvars -except f animals animcol
for a = 1:length(animals)
     if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        rwdata = vertcat(rwdata{:}); 
        type = cellfun(@(x) x.type,rwdata);
        meanvel_rip{a} = cellfun(@(x) x.meanvel,rwdata(type>=1));
        meanvel_wait{a} = meanvel_rip{a};
        stdvel_rip{a} = cellfun(@(x) x.stdvel,rwdata(type>=1));
        stdvel_wait{a} = stdvel_rip{a};
        std_x_rip{a} = cellfun(@(x) x.std_x,rwdata(type>=1));
        std_x_wait{a} = std_x_rip{a};
        std_y_rip{a} = cellfun(@(x) x.std_y,rwdata(type>=1));
        std_y_wait{a} = std_y_rip{a};
        labels_rip{a} = [zeros(length(meanvel_rip{a}),1),a+zeros(length(meanvel_rip{a}),1)];
        labels_wait{a} = labels_rip{a};
else
        when=1;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        rwdata = vertcat(rwdata{:}); 
        type = cellfun(@(x) x.type,rwdata);
        meanvel_rip{a} = cellfun(@(x) x.meanvel,rwdata(type==1));
        meanvel_wait{a} = cellfun(@(x) x.meanvel,rwdata(type==2));
        stdvel_rip{a} = cellfun(@(x) x.stdvel,rwdata(type==1));
        stdvel_wait{a} = cellfun(@(x) x.stdvel,rwdata(type==2));
        std_x_rip{a} = cellfun(@(x) x.std_x,rwdata(type==1));
        std_x_wait{a} = cellfun(@(x) x.std_x,rwdata(type==2));
        std_y_rip{a} = cellfun(@(x) x.std_y,rwdata(type==1));
        std_y_wait{a} = cellfun(@(x) x.std_y,rwdata(type==2));
        labels_rip{a} = [ones(length(meanvel_rip{a}),1),a+zeros(length(meanvel_rip{a}),1)];
        labels_wait{a} = [ones(length(meanvel_wait{a}),1),a+zeros(length(meanvel_wait{a}),1)];
     end
end
figure;
subplot(2,2,1); hold on
allrat_lmeplot(meanvel_rip,meanvel_wait,labels_rip,labels_wait,'spacer',[2 10])
ylabel('Vel (cm/s)');title('meanvel pre-rew');  ylim([0 4]);
subplot(2,2,2); hold on
allrat_lmeplot(stdvel_rip,stdvel_wait,labels_rip,labels_wait,'spacer',[2 10])
ylabel('std vel (cm/s)');title('std vel pre-rew');  ylim([0 4]);
subplot(2,2,3); hold on
allrat_lmeplot(std_x_rip,std_x_wait,labels_rip,labels_wait,'spacer',[1 10])
ylabel('Std of pos (cm)');title('Std of x pos (front to back)'); xlim([.5 9.5]); ylim([0 2]);
subplot(2,2,4); hold on
allrat_lmeplot(std_y_rip,std_y_wait,labels_rip,labels_wait,'spacer',[1 10])
ylabel('Std of pos (cm)');title('Std of Y pos (side to side)'); xlim([.5 9.5]); ylim([0 2]);


%% plot velocity traces aligned to start 
clearvars -except f animals animcol
figure;
for a = 1:length(animals)
    if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
        rwdata = vertcat(rwdata{:});
        type = cellfun(@(x) x.type,rwdata);
        veltrace_rip{a} = cellfun(@(x) x.veltrace,rwdata(type>=1),'un',0);
        eval(['ax',num2str(a),'=subplot(12,1,',num2str(a),');']); hold on;
        cellfun(@(x) plot(x,'b'),veltrace_rip{a}(1:10));
        xlim([0 500]); ylim([0 15]);
    else a>4
            when=1;
            rwdata = arrayfun(@(x) x.rw',f(a).output{when},'UniformOutput',0); % stack data from all trials
            rwdata = vertcat(rwdata{:});
            type = cellfun(@(x) x.type,rwdata);
            veltrace_rip{a} = cellfun(@(x) x.veltrace,rwdata(type==1),'un',0);
            eval(['ax',num2str(a),'=subplot(12,1,',num2str(a),');']); hold on;
            cellfun(@(x) plot(x,'r'),veltrace_rip{a}(1:10));  xlim([0 500]); ylim([0 15]);
            veltrace_wait{a} = cellfun(@(x) x.veltrace,rwdata(type==2),'un',0);
            eval(['ax',num2str(a+4),'=subplot(12,1,',num2str(a+4),');']); hold on;
            cellfun(@(x) plot(x,'k'),veltrace_wait{a}(1:10));  xlim([0 500]); ylim([0 15]);
    end
end
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10,ax11,ax12],'xy')

%% Plot mean x and y std during post-reward
clearvars -except f animals animcol
for a = 1:length(animals)
     if a<=4
        when=2;
        rwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        rwdata = vertcat(rwdata{:}); 
        type = cellfun(@(x) x.type,rwdata);
        meanvel_rip{a} = cellfun(@(x) x.meanvel,rwdata(type>=1));
        meanvel_wait{a} = meanvel_rip{a};
        stdvel_rip{a} = cellfun(@(x) x.stdvel,rwdata(type>=1));
        stdvel_wait{a} = stdvel_rip{a};
        std_x_rip{a} = cellfun(@(x) x.std_x,rwdata(type>=1));
        std_x_wait{a} = std_x_rip{a};
        std_y_rip{a} = cellfun(@(x) x.std_y,rwdata(type>=1));
        std_y_wait{a} = std_y_rip{a};
        labels_rip{a} = [zeros(length(meanvel_rip{a}),1),a+zeros(length(meanvel_rip{a}),1)];
        labels_wait{a} = labels_rip{a};
else
        when=1;
        rwdata = arrayfun(@(x) x.postrw',f(a).output{when},'UniformOutput',0); % stack data from all trials  
        rwdata = vertcat(rwdata{:}); 
        type = cellfun(@(x) x.type,rwdata);
        meanvel_rip{a} = cellfun(@(x) x.meanvel,rwdata(type==1));
        meanvel_wait{a} = cellfun(@(x) x.meanvel,rwdata(type==2));
        stdvel_rip{a} = cellfun(@(x) x.stdvel,rwdata(type==1));
        stdvel_wait{a} = cellfun(@(x) x.stdvel,rwdata(type==2));
        std_x_rip{a} = cellfun(@(x) x.std_x,rwdata(type==1));
        std_x_wait{a} = cellfun(@(x) x.std_x,rwdata(type==2));
        std_y_rip{a} = cellfun(@(x) x.std_y,rwdata(type==1));
        std_y_wait{a} = cellfun(@(x) x.std_y,rwdata(type==2));
        labels_rip{a} = [ones(length(meanvel_rip{a}),1),a+zeros(length(meanvel_rip{a}),1)];
        labels_wait{a} = [ones(length(meanvel_wait{a}),1),a+zeros(length(meanvel_wait{a}),1)];
     end
end
figure;
subplot(2,2,1); hold on
allrat_lmeplot(meanvel_rip,meanvel_wait,labels_rip,labels_wait,'spacer',[2 10])
ylabel('Vel (cm/s)');title('meanvel post-rew');  ylim([0 4]);
subplot(2,2,2); hold on
allrat_lmeplot(stdvel_rip,stdvel_wait,labels_rip,labels_wait,'spacer',[2 10])
ylabel('std vel (cm/s)');title('std vel post-rew');  ylim([0 4]);
subplot(2,2,3); hold on
allrat_lmeplot(std_x_rip,std_x_wait,labels_rip,labels_wait,'spacer',[1 10])
ylabel('Std of pos (cm)');title('Std of x pos (front to back)'); xlim([.5 9.5]); ylim([0 2]);
subplot(2,2,4); hold on
allrat_lmeplot(std_y_rip,std_y_wait,labels_rip,labels_wait,'spacer',[1 10])
ylabel('Std of pos (cm)');title('Std of Y pos (side to side)'); xlim([.5 9.5]); ylim([0 2]);

