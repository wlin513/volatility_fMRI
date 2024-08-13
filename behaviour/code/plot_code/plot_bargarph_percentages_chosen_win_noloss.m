pct_win_notloss_chosen=[pct_winchosen,pct_lossnotchosen,pct_winvsloss_chosen];
mean_pct_win_notloss_chosen=mean(pct_win_notloss_chosen);
sem_pct_win_notloss_chosen=std(pct_win_notloss_chosen)./sqrt(size(pct_win_notloss_chosen,1));
mean_pct_win_notloss_chosen=reshape(mean_pct_win_notloss_chosen,5,3);
sem_pct_win_notloss_chosen=reshape(sem_pct_win_notloss_chosen,5,3);
cond1={'win','noloss','win-loss'};
f1=figure('units','inch','position',[0,0,10,2*10/3]);
H=bar(mean_pct_win_notloss_chosen);
H(1).FaceColor = 'black';
H(2).FaceColor = 'white';
H(3).FaceColor =[0.5 0.5 0.5]';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('percentages chosen','FontSize',16);
legend('win','noloss','win-loss','AutoUpdate','off','Location','NorthEastOutside');
hold on
pos=1;
for ii=1:length(cond1)
for iii=1:length(blkname)
  pos=iii+0.22*(ii-2);
  plot([pos,pos],[mean_pct_win_notloss_chosen(iii,ii)-sem_pct_win_notloss_chosen(iii,ii),mean_pct_win_notloss_chosen(iii,ii)+sem_pct_win_notloss_chosen(iii,ii)],'-k','LineWidth',1)
end
end
hold off

% hold on
% for i=1:size(pct_win_notloss_chosen,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=pct_win_notloss_chosen(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
% hold off

saveas(f1,[figdir,'Group__pct_win_notloss_chosen_result.png'])