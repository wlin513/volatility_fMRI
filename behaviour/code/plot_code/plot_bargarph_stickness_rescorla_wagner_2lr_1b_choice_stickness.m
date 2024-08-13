
mean_stk=mean(stk_2lr_1b_choice_stickness);
up_stk_2lr1b_choice_stickness=mean_stk+std(stk_2lr_1b_choice_stickness)./sqrt(length(stk_2lr_1b_choice_stickness));
low_stk_2lr1b_choice_stickness=mean_stk-std(stk_2lr_1b_choice_stickness)./sqrt(length(stk_2lr_1b_choice_stickness));
f=figure;
H=bar(mean_stk);
H.FaceColor = 'blue';
set(gca,'XTickLabel',blkname,'FontSize',13);
ylabel('stk','FontSize',16);
hold on

pos=1;
for iii=1:length(blkname)
  pos=iii;
  plot([pos,pos],[low_stk_2lr1b_choice_stickness(iii),up_stk_2lr1b_choice_stickness(iii)],'-k','LineWidth',1)
end

% hold on
% for i=1:size(stk_2lr_1b_choice_stickness,1)
% for iii=1:length(blkname)
%   tmp=stk_2lr_1b_choice_stickness(i,iii);
%   pos=iii;
%   plot(pos,tmp,'xb')
% end
% end
hold off
saveas(f,[figdir,'Group__stk_result_2lr1b_choice_stickness.png'])