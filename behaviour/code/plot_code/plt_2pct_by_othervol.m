function plt_2pct_by_othervol(win_pct,loss_pct,picname,figdir)

sem_win_pct=std(win_pct,0,1)./sqrt(size(win_pct,1));
mean_win_pct=mean(win_pct);
up_win_pct=mean_win_pct+sem_win_pct;
low_win_pct=mean_win_pct-sem_win_pct;



sem_loss_pct=std(loss_pct,0,1)./sqrt(size(loss_pct,1));
mean_loss_pct=mean(loss_pct);
up_loss_pct=mean_loss_pct+sem_loss_pct;
low_loss_pct=mean_loss_pct-sem_loss_pct;
    

%% plot bargarph
f=figure('Position',[34.5,119.5,1502,475]);
subplot(1,2,1)
mean_pct=[mean_win_pct(1:2);mean_win_pct(3:4)]';
up_pcts=[up_win_pct(1:2);up_win_pct(3:4)]';
low_pcts=[low_win_pct(1:2);low_win_pct(3:4)]';
H=bar(mean_pct);
%ylim([0 0.6])
title('Win')
H(1).FaceColor = [0.702 0.847, 0.38]/1.5;
H(2).FaceColor = [0.702 0.847, 0.38];
H(1).EdgeColor = 'none';
H(2).EdgeColor = 'none';
set(gca,'XTickLabel',{'volatile','stable'},'FontSize',13);
xlabel('other(loss) volatility','FontSize',16)
ylabel( 'win postive stay negative switch','FontSize',16);
leg=legend('volatile','stable','Location','NorthEastOutside','AutoUpdate','off');
leg.Title.String='self(win) volatility';
leg.EdgeColor='none';
hold on
pos=1;
for ii=1:2
for iii=1:2
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_pcts(iii,ii),up_pcts(iii,ii)],'-k','LineWidth',1)
end
end
subplot(1,2,2)
mean_pct=[mean_loss_pct(1:2:3);mean_loss_pct(2:2:4)]';
up_pcts=[up_loss_pct(1:2:3);up_loss_pct(2:2:4)]';
low_pcts=[low_loss_pct(1:2:3);low_loss_pct(2:2:4)]';
H=bar(mean_pct);
%ylim([0 0.6])
title('Loss')
H(1).FaceColor = [0.945,0.419,0.435]/1.5;
H(2).FaceColor = [0.945,0.419,0.435];
H(1).EdgeColor = 'none';
H(2).EdgeColor = 'none';
set(gca,'XTickLabel',{'volatile','stable'},'FontSize',13);
xlabel('other(win) volatility','FontSize',16)
ylabel('loss postive stay negative switch','FontSize',16);
leg=legend('volatile','stable','Location','NorthEastOutside','AutoUpdate','off');
leg.Title.String='self(loss) volatility';
leg.EdgeColor='none';
hold on
pos=1;
for ii=1:2
for iii=1:2
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[low_pcts(iii,ii),up_pcts(iii,ii)],'-k','LineWidth',1)
end
end


saveas(f,[figdir,'pct_barplot_othervol',picname,'.png'])
