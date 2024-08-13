beta_2lr_1b_choice_stickness_log=log(beta_2lr_1b_choice_stickness);
mean_beta_2lr_1b_choice_stickness_log=mean(beta_2lr_1b_choice_stickness_log,1);
sem_beta_2lr_1b_choice_stickness_log=std(beta_2lr_1b_choice_stickness_log,1)./sqrt(size(beta_2lr_1b_choice_stickness_log,1));
mean_beta_2lr_1b_choice_stickness=exp(mean_beta_2lr_1b_choice_stickness_log);
up_beta_2lr_1b_choice_stickness=exp(mean_beta_2lr_1b_choice_stickness_log+sem_beta_2lr_1b_choice_stickness_log);
low_beta_2lr_1b_choice_stickness=exp(mean_beta_2lr_1b_choice_stickness_log-sem_beta_2lr_1b_choice_stickness_log);

mean_beta=[mean_beta_2lr_1b_choice_stickness'];
up_beta_2lr1b_choice_stickness=[up_beta_2lr_1b_choice_stickness'];
low_beta_2lr1b_choice_stickness=[low_beta_2lr_1b_choice_stickness'];
f=figure;
H=bar(mean_beta);
H.FaceColor = 'blue';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Beta','FontSize',16);
hold on

pos=1;
for iii=1:length(blkname)
  pos=iii;
  plot([pos,pos],[low_beta_2lr1b_choice_stickness(iii),up_beta_2lr1b_choice_stickness(iii)],'-k','LineWidth',1)
end

% hold on
% for i=1:size(beta_2lr_1b_choice_stickness,1)
% for iii=1:length(blkname)
%   tmp=beta_2lr_1b_choice_stickness(i,iii);
%   pos=iii;
%   plot(pos,tmp,'xb')
% end
% end
hold off
saveas(f,[figdir,'Group__beta_result_2lr1b_choice_stickness.png'])