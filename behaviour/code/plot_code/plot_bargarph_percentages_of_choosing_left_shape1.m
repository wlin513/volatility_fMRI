pct_leftchoice_shape1choice=[pct_leftchoice,pct_shape1choice];
mean_pct=mean(pct_leftchoice_shape1choice);
sem_pct=std(pct_leftchoice_shape1choice)./sqrt(size(pct_leftchoice_shape1choice,1));
mean_pct=reshape(mean_pct,5,2);
sem_pct=reshape(sem_pct,5,2);
cond1={'leftchoice','shape1choice'};
f1=figure('units','inch','position',[0,0,10,2*10/3]);
H=bar(mean_pct);
H(1).FaceColor = 'black';
H(2).FaceColor = 'white';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('Switch probability','FontSize',16);
legend('leftchoice','shape1choice','AutoUpdate','off','Location','NorthEastOutside');
hold on
pos=1;
for ii=1:length(cond1)
for iii=1:length(blkname)
  pos=iii+0.14*(-1)^ii;
  plot([pos,pos],[mean_pct(iii,ii)-sem_pct(iii,ii),mean_pct(iii,ii)+sem_pct(iii,ii)],'-k','LineWidth',1)
end
end
%hold off

hold on
for i=1:size(pct_leftchoice_shape1choice,1)
for ii=1:length(cond1)
for iii=1:length(blkname)
  tmp=pct_leftchoice_shape1choice(i,length(blkname)*(ii-1)+iii);
  pos=iii+0.14*(-1)^ii;
  plot(pos,tmp,'or')
end
end
end
%hold off

hold on
lgi_shape1=inv_logit(pct_shape1choice);
mean_shape1=mean(lgi_shape1);
std_shape1=std(lgi_shape1);
uplim=inv_logit(mean_shape1+3*std_shape1,1);
lowlim=inv_logit(mean_shape1-3*std_shape1,1);
pos=1;
for iii=1:length(blkname)
  plot([iii-0.29,iii+0.29],[uplim(iii),uplim(iii)],'-r','LineWidth',2)
   plot([iii-0.29,iii+0.29],[lowlim(iii),lowlim(iii)],'-r','LineWidth',2)
end

saveas(f1,[figdir,'Group__pct_leftchoice_shape1choice_result.png'])