meanAIC_PNPE_2lr_2b=mean(AIC_PNPE_2lr_2b,2);
meanAIC_PNPE_2lr_1b=mean(AIC_PNPE_2lr_1b,2);
meanAIC_1lr_1b=mean(AIC_1lr_1b,2);
meanAIC_PNPE_2lr_1b_opt1=mean(AIC_PNPE_2lr_1b_opt1,2);
meanAIC_2lr_2b=mean(AIC_2lr_2b,2);
meanAIC_2lr_1b=mean(AIC_2lr_1b,2);
meanAIC_2lr_1b_choice_stickness=mean(AIC_2lr_1b_choice_stickness,2);
meanAIC_4lr_1b=mean(AIC_4lr_1b,2);
%meanAIC_4lr_1b=mean(result_4lr_1b.AIC,2);
%meanAIC_4lr_1b_chosen=mean(result_4lr_1b_chosen.AIC,2);
%meanAIC_4lr_1b_choice_stickness=mean(result_4lr_1b_choice_stickness.AIC,2);

semAIC_PNPE_2lr_2b=std(meanAIC_PNPE_2lr_2b)./sqrt(size(AIC_PNPE_2lr_2b,1));
semAIC_PNPE_2lr_1b=std(meanAIC_PNPE_2lr_1b)./sqrt(size(AIC_PNPE_2lr_1b,1));
semAIC_1lr_1b=std(meanAIC_1lr_1b)./sqrt(size(AIC_1lr_1b,1));
semAIC_PNPE_2lr_1b_opt1=std(meanAIC_PNPE_2lr_1b_opt1)./sqrt(size(AIC_PNPE_2lr_1b_opt1,1));
semAIC_2lr_2b=std(meanAIC_2lr_2b)./sqrt(size(AIC_2lr_2b,1));
semAIC_2lr_1b=std(meanAIC_2lr_1b)./sqrt(size(AIC_2lr_1b,1));
semAIC_2lr_1b_choice_stickness=std(meanAIC_2lr_1b_choice_stickness)./sqrt(size(AIC_2lr_1b_choice_stickness,1));
semAIC_4lr_1b=std(meanAIC_4lr_1b)./sqrt(size(AIC_4lr_1b,1));
%semAIC_4lr_1b=std(meanAIC_4lr_1b)./sqrt(size(result_4lr_1b.AIC,1));
%semAIC_4lr_1b_chosen=std(meanAIC_4lr_1b_chosen)./sqrt(size(result_4lr_1b_chosen.AIC,1));
%semAIC_4lr_1b_choice_stickness=std(meanAIC_4lr_1b_choice_stickness)./sqrt(size(result_4lr_1b_choice_stickness.AIC,1));

meanAICs=[mean(meanAIC_2lr_2b) mean(meanAIC_2lr_1b) mean(meanAIC_1lr_1b) mean(meanAIC_PNPE_2lr_2b)...
    mean(meanAIC_PNPE_2lr_1b) mean(meanAIC_PNPE_2lr_1b_opt1) mean(meanAIC_2lr_1b_choice_stickness) mean(meanAIC_4lr_1b)]; 
AICs=[meanAIC_2lr_2b meanAIC_2lr_1b meanAIC_1lr_1b meanAIC_PNPE_2lr_2b...
    meanAIC_PNPE_2lr_1b meanAIC_PNPE_2lr_1b_opt1 meanAIC_2lr_1b_choice_stickness meanAIC_4lr_1b]; 
semAICs=[semAIC_2lr_2b semAIC_2lr_1b semAIC_1lr_1b semAIC_PNPE_2lr_2b...
    semAIC_PNPE_2lr_1b semAIC_PNPE_2lr_1b_opt1 semAIC_2lr_1b_choice_stickness semAIC_4lr_1b];
up_AICs=meanAICs+semAICs;
low_AICs=meanAICs-semAICs;

f=figure;
modelnames={'2lr2b','2lr1b','1lr1b','2lr2b-PNPE','2lr1b-PNPE','2lr1b-opt1-PNPE','2lr1b+stickness','4lr1b'}
barh(meanAICs);
set(gca,'YTickLabel',modelnames,'FontSize',13);
xlabel('AIC estimates','FontSize',16);
hold on
pos=0;
for ii=1:length(modelnames)
  plot([up_AICs(ii),low_AICs(ii)],[pos+ii,pos+ii],'-k','LineWidth',1)
end

% hold on
% for i=1:length(filelist)
% for ii=1:length(meanAICs)
%   tmp=AICs(i,ii);
%   pos=ii;
%   plot(tmp,pos,'xb')
% end
% end
hold off

saveas(f,[figdir,'mean_AIC_in_allmodels.png'])