switchprob_PNs=[1-switchprob_win-switchprob_nowin,1-switchprob_noloss-switchprob_loss];
mean_switchprob=mean(switchprob_PNs);
sem_switchprob=std(switchprob_PNs)./sqrt(size(switchprob_PNs,1));
mean_switchprob=reshape(mean_switchprob,5,2);
sem_switchprob=reshape(sem_switchprob,5,2);
cond1={'win','loss'};
f1=figure('units','inch','position',[0,0,8,6]);
H=bar(mean_switchprob);
H(1).FaceColor = 'green';
H(2).FaceColor = 'red';
H(1).EdgeColor = 'green';
H(2).EdgeColor ='red';
set(gca,'XTickLabel',blkname,'FontSize',10);
ylabel('positve stay vs. negative switch probability','FontSize',12);
legend('win positive bias','loss positive bias','AutoUpdate','off','Location','NorthWest');
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
% for i=1:size(switchprob_PNs,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=switchprob_PNs(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
% hold off

saveas(f1,[figdir,'Group__switchprob_PNs_result.png'])