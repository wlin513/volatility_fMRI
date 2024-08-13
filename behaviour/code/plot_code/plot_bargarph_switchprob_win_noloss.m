switchprob_win_noloss=[1-switchprob_win,1-switchprob_noloss];
mean_switchprob=mean(switchprob_win_noloss);
sem_switchprob=std(switchprob_win_noloss)./sqrt(size(switchprob_win_noloss,1));
mean_switchprob=reshape(mean_switchprob,5,2);
sem_switchprob=reshape(sem_switchprob,5,2);
cond1={'win','noloss'};
f1=figure('units','inch','position',[0,0,8,6]);
H=bar(mean_switchprob);
H(1).FaceColor = 'green';
H(2).FaceColor = 'red';
H(1).EdgeColor = 'green';
H(2).EdgeColor ='red';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Stay probability','FontSize',16);
ylim([0.7 1]);
legend('win','noloss','AutoUpdate','off');
hold on
pos=1;
for ii=1:length(cond1)
for iii=1:length(blkname)
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[mean_switchprob(iii,ii)-sem_switchprob(iii,ii),mean_switchprob(iii,ii)+sem_switchprob(iii,ii)],'-k','LineWidth',1)
end
end
hold off

% hold on
% for i=1:size(switchprob_win_noloss,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=switchprob_win_noloss(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
% hold off

saveas(f1,[figdir,'Group__switchprob_win_noloss_result.png'])