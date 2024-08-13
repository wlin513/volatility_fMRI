switchprob_both_nothing=[switchprob_both,switchprob_nothing];
mean_switchprob=mean(switchprob_both_nothing);
sem_switchprob=std(switchprob_both_nothing)./sqrt(size(switchprob_both_nothing,1));
mean_switchprob=reshape(mean_switchprob,5,2);
sem_switchprob=reshape(sem_switchprob,5,2);
cond1={'Both','Nothing'};
f1=figure;
H=bar(mean_switchprob);
H(1).FaceColor = 'black';
H(2).FaceColor = 'white';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Switch probability','FontSize',16);
legend('Both','Nothing','AutoUpdate','off');
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
% for i=1:size(switchprob_both_nothing,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=switchprob_both_nothing(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
% hold off

saveas(f1,[figdir,'Group__switchprob_result.png'])