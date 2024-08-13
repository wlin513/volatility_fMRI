
%% plot bargarph
alphas_adpts=[R_vol_adpt_othervol_model.win_vol_adpt_tr,R_vol_adpt_othervol_model.win_sta_adpt_tr,...
    R_vol_adpt_othervol_model.loss_vol_adpt_tr,R_vol_adpt_othervol_model.loss_sta_adpt_tr];
mean_alpha=reshape(mean(alphas_adpts),2,2);
ste_alpha=reshape(std(alphas_adpts)./sqrt(length(alphas_adpts)),2,2);
up_alpha_2lr1b=mean_alpha+ste_alpha;
low_alpha_2lr1b=mean_alpha-ste_alpha;
cond={'alpha_win','alpha_loss'};
f=figure('Position',[71,424,785,475]);
H=bar(mean_alpha);
H(1).FaceColor = [0.702 0.847, 0.38];
H(2).FaceColor = [0.945,0.419,0.435];
H(1).EdgeColor = 'none';
H(2).EdgeColor = 'none';
set(gca,'XTickLabel',{'other volatile','other stable'},'FontSize',13);
ylabel('learning rate volatile vs stable','FontSize',16);
legend('Win α adaptation','Loss α adaptation','Location','SouthEast','AutoUpdate','off');
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

saveas(f,[figdir,'alphas_4betas_othervol_model_lr_adaptation.png'])
