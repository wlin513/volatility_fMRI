%calculate the mean of beta in logit space and logerse it back to the
%original space
beta_rew_2lr_2b_log=log(beta_rew_2lr_2b);
mean_beta_rew_2lr2b_log=mean(beta_rew_2lr_2b_log,1);
sem_beta_rew_2lr2b_log=std(beta_rew_2lr_2b_log,1)./sqrt(size(beta_rew_2lr_2b,1));
mean_beta_rew_2lr2b=exp(mean_beta_rew_2lr2b_log);
up_beta_rew_2lr2b=exp(mean_beta_rew_2lr2b_log+sem_beta_rew_2lr2b_log);
low_beta_rew_2lr2b=exp(mean_beta_rew_2lr2b_log-sem_beta_rew_2lr2b_log);

beta_loss_2lr_2b_log=log(beta_loss_2lr_2b);
mean_beta_loss_2lr2b_log=mean(beta_loss_2lr_2b_log,1);
sem_beta_loss_2lr2b_log=std(beta_loss_2lr_2b_log,1)./sqrt(size(beta_loss_2lr_2b,1));
mean_beta_loss_2lr2b=exp(mean_beta_loss_2lr2b_log);
up_beta_loss_2lr2b=exp(mean_beta_loss_2lr2b_log+sem_beta_loss_2lr2b_log);
low_beta_loss_2lr2b=exp(mean_beta_loss_2lr2b_log-sem_beta_loss_2lr2b_log);
    

%% plot bargarph
mean_beta=[mean_beta_rew_2lr2b',mean_beta_loss_2lr2b'];
up_beta_2lr2b=[up_beta_rew_2lr2b',up_beta_loss_2lr2b'];
low_beta_2lr2b=[low_beta_rew_2lr2b',low_beta_loss_2lr2b'];
cond={'beta_rew','beta_loss'};
f=figure;
H=bar(mean_beta);
H(1).FaceColor = 'green';
H(2).FaceColor = 'red';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Beta','FontSize',16);
legend('Win \beta','Loss \beta','AutoUpdate','off');
hold on

pos=1;
for ii=1:length(cond)
for iii=1:length(blkname)
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_beta_2lr2b(iii,ii),up_beta_2lr2b(iii,ii)],'-k','LineWidth',1)
end
end

% betas_2lr_2b=[beta_rew_2lr_2b,beta_loss_2lr_2b];
% hold on
% for i=1:size(betas_2lr_2b,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=betas_2lr_2b(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
hold off

saveas(f,[figdir,'Group__beta_result_2lr2b.png'])


