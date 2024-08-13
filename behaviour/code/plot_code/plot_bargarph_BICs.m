meanBIC_PNPE_2lr_2b=mean(BIC_PNPE_2lr_2b,2);
meanBIC_PNPE_2lr_1b=mean(BIC_PNPE_2lr_1b,2);
meanBIC_1lr_1b=mean(BIC_1lr_1b,2);
meanBIC_PNPE_2lr_1b_opt1=mean(BIC_PNPE_2lr_1b_opt1,2);
meanBIC_2lr_2b=mean(BIC_2lr_2b,2);
meanBIC_2lr_1b=mean(BIC_2lr_1b,2);
meanBIC_2lr_1b_choice_stickness=mean(BIC_2lr_1b_choice_stickness,2);
meanBIC_4lr_1b=mean(BIC_4lr_1b,2);
meanBIC_R_2lr_2b=mean(BIC_R_2lr_2b,2);
%meanBIC_4lr_1b=mean(result_4lr_1b.BIC,2);
%meanBIC_4lr_1b_chosen=mean(result_4lr_1b_chosen.BIC,2);
%meanBIC_4lr_1b_choice_stickness=mean(result_4lr_1b_choice_stickness.BIC,2);

semBIC_PNPE_2lr_2b=std(meanBIC_PNPE_2lr_2b)./sqrt(size(BIC_PNPE_2lr_2b,1));
semBIC_PNPE_2lr_1b=std(meanBIC_PNPE_2lr_1b)./sqrt(size(BIC_PNPE_2lr_1b,1));
semBIC_1lr_1b=std(meanBIC_1lr_1b)./sqrt(size(BIC_1lr_1b,1));
semBIC_PNPE_2lr_1b_opt1=std(meanBIC_PNPE_2lr_1b_opt1)./sqrt(size(BIC_PNPE_2lr_1b_opt1,1));
semBIC_2lr_2b=std(meanBIC_2lr_2b)./sqrt(size(BIC_2lr_2b,1));
semBIC_2lr_1b=std(meanBIC_2lr_1b)./sqrt(size(BIC_2lr_1b,1));
semBIC_2lr_1b_choice_stickness=std(meanBIC_2lr_1b_choice_stickness)./sqrt(size(BIC_2lr_1b_choice_stickness,1));
semBIC_4lr_1b=std(meanBIC_4lr_1b)./sqrt(size(BIC_4lr_1b,1));
semBIC_R_2lr_2b=std(meanBIC_R_2lr_2b)./sqrt(size(BIC_R_2lr_2b,1));
%semBIC_4lr_1b=std(meanBIC_4lr_1b)./sqrt(size(result_4lr_1b.BIC,1));
%semBIC_4lr_1b_chosen=std(meanBIC_4lr_1b_chosen)./sqrt(size(result_4lr_1b_chosen.BIC,1));
%semBIC_4lr_1b_choice_stickness=std(meanBIC_4lr_1b_choice_stickness)./sqrt(size(result_4lr_1b_choice_stickness.BIC,1));

meanBICs=[mean(meanBIC_2lr_2b) mean(meanBIC_2lr_1b) mean(meanBIC_1lr_1b) mean(meanBIC_PNPE_2lr_2b)...
    mean(meanBIC_PNPE_2lr_1b) mean(meanBIC_PNPE_2lr_1b_opt1) mean(meanBIC_2lr_1b_choice_stickness) mean(meanBIC_4lr_1b) mean(meanBIC_R_2lr_2b)]; 
BICs=[meanBIC_2lr_2b meanBIC_2lr_1b meanBIC_1lr_1b meanBIC_PNPE_2lr_2b...
    meanBIC_PNPE_2lr_1b meanBIC_PNPE_2lr_1b_opt1 meanBIC_2lr_1b_choice_stickness meanBIC_4lr_1b meanBIC_R_2lr_2b]; 
semBICs=[semBIC_2lr_2b semBIC_2lr_1b semBIC_1lr_1b semBIC_PNPE_2lr_2b...
    semBIC_PNPE_2lr_1b semBIC_PNPE_2lr_1b_opt1 semBIC_2lr_1b_choice_stickness semBIC_4lr_1b semBIC_R_2lr_2b];
up_BICs=meanBICs+semBICs;
low_BICs=meanBICs-semBICs;

f=figure;
modelnames={'2lr2b','2lr1b','1lr1b','2lr2b-PNPE','2lr1b-PNPE','2lr1b-opt1-PNPE','2lr1b+stickness','4lr1b','R-2lr2b'}
barh(meanBICs);
set(gca,'YTickLabel',modelnames,'FontSize',13);
xlabel('BIC estimates','FontSize',16);
hold on
pos=0;
for ii=1:length(modelnames)
  plot([up_BICs(ii),low_BICs(ii)],[pos+ii,pos+ii],'-k','LineWidth',1)
end

% hold on
% for i=1:length(filelist)
% for ii=1:length(meanBICs)
%   tmp=BICs(i,ii);
%   pos=ii;
%   plot(tmp,pos,'xb')
% end
% end
hold off

saveas(f,[figdir,'mean_BIC_in_allmodels.png'])