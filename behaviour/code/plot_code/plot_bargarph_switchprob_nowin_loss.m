switchprob_nowin_loss=[switchprob_nowin,switchprob_loss];
mean_switchprob=mean(switchprob_nowin_loss);
sem_switchprob=std(switchprob_nowin_loss)./sqrt(size(switchprob_nowin_loss,1));
mean_switchprob=reshape(mean_switchprob,5,2);
sem_switchprob=reshape(sem_switchprob,5,2);
cond1={'nowin','loss'};
f1=figure('units','inch','position',[0,0,8,6]);
H=bar(mean_switchprob);
H(1).FaceColor = 'green';
H(2).FaceColor = 'red';
H(1).EdgeColor = 'green';
H(2).EdgeColor ='red';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Switch probability','FontSize',16);
legend('nowin','loss','AutoUpdate','off');
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
% for i=1:size(switchprob_nowin_loss,1)
% for ii=1:length(cond1)
% for iii=1:length(blkname)
%   tmp=switchprob_nowin_loss(i,4*(ii-1)+iii);
%   pos=iii+0.14*(-1)^ii;
%   plot(pos,tmp,'xb')
% end
% end
% end
% hold off

saveas(f1,[figdir,'Group__switchprob_nowin_loss_result.png'])