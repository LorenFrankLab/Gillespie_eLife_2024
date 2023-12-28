function allrat_lmeplot(variable_rip, variable_wait, labels_rip, labels_wait,varargin)
% assumes 8 animals, first 4 no-manipulation (1 set of bars) second 4
% manipulation (2 sets of bars

animcol = [123 159 242; 66 89 195; 33 42 165; 6 1 140; 254 123 123; 255 82 82; 255 0 0; 168 1 0; 148 148 148; 115 115 115; 82 82 82; 49 49 49]./255;  %ctrlcols
spacer = [0 10];
style = 'box';
grouped = 0;
lme_dist = 'linear';

if (~isempty(varargin))
    assign(varargin{:});
end
switch style
    case 'box'
        for a = 1:8
            if a<=4
                boxplot(variable_rip{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
                text(a,spacer(1)+a/spacer(2),sprintf('n=%d trials',length(variable_rip{a})));
            else
                boxplot(variable_rip{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
                boxplot(variable_wait{a},'Positions',a+.25,'Symbol','', 'Width',.2,'Color',animcol(a+4,:))
                p(a) = ranksum(variable_rip{a},variable_wait{a});
                text(a,spacer(1)+a/spacer(2),sprintf('p=%d\nn=%d,%d trials',p(a),length(variable_rip{a}),length(variable_wait{a})))
            end
        end
    case 'violin'
        violin(variable_rip(1:4),'x',1:4,'facecolor',animcol(3,:),'medc','k','mc',[]);
        violin(variable_rip(5:8),'x',5:8,'facecolor',animcol(5,:),'medc','k','mc',[]);
        violin(variable_wait(5:8),'x',[5:8]+.25,'facecolor',animcol(10,:),'medc','k','mc',[]);
        
        for a = 1:8
            
            if a<=4
                text(a,spacer(1)+a/spacer(2),sprintf('n=%d trials',length(variable_rip{a})));
            else
                %  boxplot(variable_rip{a},'Positions',a,'Symbol','', 'Width',.2,'Color',animcol(a,:))
                %  boxplot(variable_wait{a},'Positions',a+.25,'Symbol','', 'Width',.2,'Color',animcol(a+4,:))
                p(a) = ranksum(variable_rip{a},variable_wait{a});
                text(a,spacer(1)+a/spacer(2),sprintf('p=%d\nn=%d,%d trials',p(a),length(variable_rip{a}),length(variable_wait{a})))
            end
        end
end
%correct for multiple comparisons
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(p(5:8));
for a = 5:8
        text(a,spacer(1)+2*a/spacer(2),sprintf('Corrp=%d',adj_p(a-4)));
end

xlim([.5 9.5]);
switch lme_dist
    case 'linear'
tmp = [vertcat(labels_rip{:}),vertcat(variable_rip{:})];
tbl = table(tmp(:,1),tmp(:,2),tmp(:,3),'VariableNames',{'Cohort','Indiv','Variable'});
lme_rips = fitglme(tbl,'Variable~Cohort+(1|Indiv)');%
tmp = [vertcat(labels_wait{:}),vertcat(variable_wait{:})];
tbl = table(tmp(:,1),tmp(:,2),tmp(:,3),'VariableNames',{'Cohort','Indiv','Variable'});
lme_waits = fitlme(tbl,'Variable~Cohort+(1|Indiv)');
xlabel(sprintf('LME Cohort fixed effects vsrip,p=%d vswait,p=%d',lme_rips.Coefficients.pValue(2),lme_waits.Coefficients.pValue(2)));
case 'poisson'
    tmp = [vertcat(labels_rip{:}),vertcat(variable_rip{:})];
tbl = table(tmp(:,1),tmp(:,2),tmp(:,3),'VariableNames',{'Cohort','Indiv','Variable'});
lme_rips = fitglme(tbl,'Variable~Cohort+(1|Indiv)','Distribution','Poisson');%,'Distribution','Poisson'
tmp = [vertcat(labels_wait{:}),vertcat(variable_wait{:})];
tbl = table(tmp(:,1),tmp(:,2),tmp(:,3),'VariableNames',{'Cohort','Indiv','Variable'});
lme_waits = fitglme(tbl,'Variable~Cohort+(1|Indiv)','Distribution','Poisson');
xlabel(sprintf('PLME Cohort fixed effects vsrip,p=%d vswait,p=%d',lme_rips.Coefficients.pValue(2),lme_waits.Coefficients.pValue(2)));
end

if grouped
    means = [cellfun(@nanmedian,variable_rip(1:4))',cellfun(@nanmedian,variable_rip(5:8))',cellfun(@nanmedian,variable_wait(5:8))'];
    bar([-3, -2, -1],mean(means),.5,'FaceColor',[1 1 1])
    plot(repmat([-2 -1],4,1)',means(:,[2:3])','Color',[.5 .5 .5])
    x_pos = [-3 -3 -3 -3 -2 -2 -2 -2 -1 -1 -1 -1];
    for p = 1:12
        plot(x_pos(p),means(p),'.','Color',animcol(p,:),'MarkerSize',15)
    end
    xlim([-3.5 9.5]);
    text(-3,.5,sprintf('CvsNF:%.2f\nCvsD:%.2f\nNFvsD:%.2f',mean(means(:,1))/mean(means(:,2)),mean(means(:,1))/mean(means(:,3)),mean(means(:,2))/mean(means(:,3))))
end

end
