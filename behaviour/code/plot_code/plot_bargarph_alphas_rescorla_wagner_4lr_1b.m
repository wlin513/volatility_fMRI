%calculate the mean of alpha in logit space and inverse it back to the
%original space

alpha_rew_4lr_1b_inv=inv_logit([biasmodel.winposalphas,biasmodel.winnegalphas]);
mean_alpha_rew_4lr1b_inv=mean(alpha_rew_4lr_1b_inv,1);
sem_alpha_rew_4lr1b_inv=std(alpha_rew_4lr_1b_inv,1)./sqrt(size(alpha_rew_4lr_1b_inv,1));
mean_alpha_rew_4lr1b=inv_logit(mean_alpha_rew_4lr1b_inv,1);
up_alpha_rew_4lr1b=inv_logit(mean_alpha_rew_4lr1b_inv+sem_alpha_rew_4lr1b_inv,1);
low_alpha_rew_4lr1b=inv_logit(mean_alpha_rew_4lr1b_inv-sem_alpha_rew_4lr1b_inv,1);
mean_alpha_rew_4lr1b=reshape(mean_alpha_rew_4lr1b,4,2);
up_alpha_rew_4lr1b=reshape(up_alpha_rew_4lr1b,4,2);
low_alpha_rew_4lr1b=reshape(low_alpha_rew_4lr1b,4,2);

alpha_loss_4lr_1b_inv=inv_logit([biasmodel.lossposalphas,biasmodel.lossnegalphas]);
mean_alpha_loss_4lr1b_inv=mean(alpha_loss_4lr_1b_inv,1);
sem_alpha_loss_4lr1b_inv=std(alpha_loss_4lr_1b_inv,1)./sqrt(size(alpha_loss_4lr_1b_inv,1));
mean_alpha_loss_4lr1b=inv_logit(mean_alpha_loss_4lr1b_inv,1);
up_alpha_loss_4lr1b=inv_logit(mean_alpha_loss_4lr1b_inv+sem_alpha_loss_4lr1b_inv,1);
low_alpha_loss_4lr1b=inv_logit(mean_alpha_loss_4lr1b_inv-sem_alpha_loss_4lr1b_inv,1);
 mean_alpha_loss_4lr1b=reshape(mean_alpha_loss_4lr1b,4,2);
up_alpha_loss_4lr1b=reshape(up_alpha_loss_4lr1b,4,2);
low_alpha_loss_4lr1b=reshape(low_alpha_loss_4lr1b,4,2);
%% plot bargarph
mean_alpha=[mean_alpha_rew_4lr1b,mean_alpha_loss_4lr1b];
up_alpha_4lr1b=[up_alpha_rew_4lr1b,up_alpha_loss_4lr1b];
low_alpha_4lr1b=[low_alpha_rew_4lr1b,low_alpha_loss_4lr1b];
cond={'alpha_rew','alpha_loss','alpha_rew_pos','alpha_loss_neg'};
f=figure('Position',[10 10 900 600]);
H=bar(mean_alpha);
H(1).FaceColor = 'green';
H(2).FaceColor = 'green';
H(3).FaceColor = 'red';
H(4).FaceColor = 'red';
H(1).EdgeColor = 'green';
H(2).EdgeColor ='green';
H(3).EdgeColor = 'red';
H(4).EdgeColor = 'red';
ylim([0 0.8])
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Learning Rate','FontSize',16);
legend('reward \alpha+','reward \alpha-','punishment \alpha+','punishment \alpha-','AutoUpdate','off','location','northeast');
box off
legend box off
hold on

pos=1;
for ii=1:length(cond)
for iii=1:length(blkname)-1
  pos=iii+(ii-2.5)*0.18;
  plot([pos,pos],[low_alpha_4lr1b(iii,ii),up_alpha_4lr1b(iii,ii)],'-k','LineWidth',1)
end
end


% alphas_4lr_1b=[alpha_rew_4lr_1b,alpha_loss_4lr_1b];
% hold on
% for i=1:size(alphas_4lr_1b,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=alphas_4lr_1b(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
hold off

print(f,[figdir,'Group__alpha_result_4lr1b.png'],'-dpng','-r300')
saveas(f,[figdir,'Group__alpha_result_4lr1b'],'epsc')

