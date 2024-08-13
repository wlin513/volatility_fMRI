%calculate the mean of alpha in logit space and inverse it back to the
%original space
alpha_rew_2lr_1b_inv=inv_logit(alpha_rew_2lr_1b);
mean_alpha_rew_2lr1b_inv=mean(alpha_rew_2lr_1b_inv,1);
sem_alpha_rew_2lr1b_inv=std(alpha_rew_2lr_1b_inv,1)./sqrt(size(alpha_rew_2lr_1b,1));
mean_alpha_rew_2lr1b=inv_logit(mean_alpha_rew_2lr1b_inv,1);
up_alpha_rew_2lr1b=inv_logit(mean_alpha_rew_2lr1b_inv+sem_alpha_rew_2lr1b_inv,1);
low_alpha_rew_2lr1b=inv_logit(mean_alpha_rew_2lr1b_inv-sem_alpha_rew_2lr1b_inv,1);

alpha_loss_2lr_1b_inv=inv_logit(alpha_loss_2lr_1b);
mean_alpha_loss_2lr1b_inv=mean(alpha_loss_2lr_1b_inv,1);
sem_alpha_loss_2lr1b_inv=std(alpha_loss_2lr_1b_inv,1)./sqrt(size(alpha_loss_2lr_1b,1));
mean_alpha_loss_2lr1b=inv_logit(mean_alpha_loss_2lr1b_inv,1);
up_alpha_loss_2lr1b=inv_logit(mean_alpha_loss_2lr1b_inv+sem_alpha_loss_2lr1b_inv,1);
low_alpha_loss_2lr1b=inv_logit(mean_alpha_loss_2lr1b_inv-sem_alpha_loss_2lr1b_inv,1);
    

%% plot bargarph
mean_alpha=[mean_alpha_rew_2lr1b',mean_alpha_loss_2lr1b'];
up_alpha_2lr1b=[up_alpha_rew_2lr1b',up_alpha_loss_2lr1b'];
low_alpha_2lr1b=[low_alpha_rew_2lr1b',low_alpha_loss_2lr1b'];
cond={'alpha_rew','alpha_loss'};
f=figure;
H=bar(mean_alpha);
H(1).FaceColor = 'green';
H(2).FaceColor = 'red';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Learning Rate','FontSize',16);
legend('Win \alpha','Loss \alpha','AutoUpdate','off');
hold on

pos=1;
for ii=1:length(cond)
for iii=1:length(blkname)
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_alpha_2lr1b(iii,ii),up_alpha_2lr1b(iii,ii)],'-k','LineWidth',1)
end
end


% alphas_2lr_1b=[alpha_rew_2lr_1b,alpha_loss_2lr_1b];
% hold on
% for i=1:size(alphas_2lr_1b,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=alphas_2lr_1b(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
hold off

saveas(f,[figdir,'Group__alpha_result_2lr1b.png'])


