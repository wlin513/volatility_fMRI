function plt_2pct(win_pct,loss_pct,ylab,varname1,varname2,picname,figdir)
blkname={'both volatile','win volatile','loss volatile','both stable'};

sem_win_pct=std(win_pct,0,1)./sqrt(size(win_pct,1));
mean_win_pct=mean(win_pct);
up_win_pct=mean_win_pct+sem_win_pct;
low_win_pct=mean_win_pct-sem_win_pct;



sem_loss_pct=std(loss_pct,0,1)./sqrt(size(loss_pct,1));
mean_loss_pct=mean(loss_pct);
up_loss_pct=mean_loss_pct+sem_loss_pct;
low_loss_pct=mean_loss_pct-sem_loss_pct;
    

%% plot bargarph
mean_pct=[mean_win_pct',mean_loss_pct'];
up_pcts=[up_win_pct',up_loss_pct'];
low_pcts=[low_win_pct',low_loss_pct'];
cond={'win','loss'};
f=figure('Position',[71,424,785,475]);
H=bar(mean_pct);
H(1).FaceColor = [0.702 0.847, 0.38];
H(2).FaceColor = [0.945,0.419,0.435];
H(1).EdgeColor = 'none';
H(2).EdgeColor = 'none';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel(ylab,'FontSize',16);
legend(varname1,varname2,'Location','NorthEastOutside','AutoUpdate','off');
hold on

pos=1;
for ii=1:length(cond)
for iii=1:length(blkname)
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_pcts(iii,ii),up_pcts(iii,ii)],'-k','LineWidth',1)
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

saveas(f,[figdir,'pct_barplot_',picname,'.png'])
