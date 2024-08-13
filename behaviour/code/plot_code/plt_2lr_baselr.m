
%% plot bargarph
alphas_baselr=inv_logit([R_vol_adpt_othervol_model.winalphas(:,3),R_vol_adpt_othervol_model.winalphas(:,4),...
    R_vol_adpt_othervol_model.lossalphas(:,2),R_vol_adpt_othervol_model.lossalphas(:,4)]);
mean_inv_alpha=reshape(mean(alphas_baselr),2,2);
mean_alpha=inv_logit(mean_inv_alpha,1);
ste_inv_alpha=reshape(std(alphas_baselr)./sqrt(length(alphas_baselr)),2,2);
up_alpha_2lr1b=inv_logit(mean_inv_alpha+ste_inv_alpha,1);
low_alpha_2lr1b=inv_logit(mean_inv_alpha-ste_inv_alpha,1);
cond={'alpha_win','alpha_loss'};
f=figure('Position',[71,424,785,475]);
H=bar(mean_alpha);
H(1).FaceColor = [0.702 0.847, 0.38];
H(2).FaceColor = [0.945,0.419,0.435];
H(1).EdgeColor = 'none';
H(2).EdgeColor = 'none';
set(gca,'XTickLabel',{'other volatile','other stable'},'FontSize',13);
ylabel('base learning rates','FontSize',16);
ylim([0 0.4])
legend('Win α ','Loss α ','Location','NorthEast','AutoUpdate','off');
hold on

pos=1;
for ii=1:length(cond)
for iii=1:2
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_alpha_2lr1b(iii,ii),up_alpha_2lr1b(iii,ii)],'-k','LineWidth',1)
end
end


% alphas_2lr_1b=[win_lrs,loss_lrs];
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

saveas(f,[figdir,'alphas_4betas_othervol_model_baselr.png'])
