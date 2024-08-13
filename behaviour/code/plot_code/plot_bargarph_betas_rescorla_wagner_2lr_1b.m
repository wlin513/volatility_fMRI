beta_2lr_1b_log=log(beta_2lr_1b);
mean_beta_2lr_1b_log=mean(beta_2lr_1b_log,1);
sem_beta_2lr_1b_log=std(beta_2lr_1b_log,1)./sqrt(size(beta_2lr_1b_log,1));
mean_beta_2lr_1b=exp(mean_beta_2lr_1b_log);
up_beta_2lr_1b=exp(mean_beta_2lr_1b_log+sem_beta_2lr_1b_log);
low_beta_2lr_1b=exp(mean_beta_2lr_1b_log-sem_beta_2lr_1b_log);

mean_beta=[mean_beta_2lr_1b'];
up_beta_2lr1b=[up_beta_2lr_1b'];
low_beta_2lr1b=[low_beta_2lr_1b'];
f=figure;
H=bar(mean_beta);
H.FaceColor = 'blue';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Beta','FontSize',16);
hold on

pos=1;
for iii=1:length(blkname)
  pos=iii;
  plot([pos,pos],[low_beta_2lr1b(iii),up_beta_2lr1b(iii)],'-k','LineWidth',1)
end

% hold on
% for i=1:size(beta_2lr_1b,1)
% for iii=1:length(blkname)
%   tmp=beta_2lr_1b(i,iii);
%   pos=iii;
%   plot(pos,tmp,'xb')
% end
% end
hold off
saveas(f,[figdir,'Group__beta_result_2lr1b.png'])