function sigcorrplot(avin,ques,xlab,ylab,tit,type,figdir)
f1=figure;
scatter(ques,avin,70,'filled','MarkerFaceColor',[0.945,0.419,0.435]);%loss color
[r,p]=corr(ques,avin,'type',type)
l=lsline;
%l.Color=[0.702 0.847, 0.38]/1.5;%win
l.Color=[0.945,0.419,0.435]/1.5;%loss
l.LineWidth=3;
star=[];
    if p<0.001
        star='***';
    else
        if p<0.01
            star='**';
        else
            if p<0.05
                star='*';
            end
        end
    end
ypos=(max(avin)-min(avin))*0.7+min(avin);
xpos=(max(ques)-min(ques))*0.75+min(ques);
title(tit)
xlabel(xlab,'FontSize',18)
ylabel(ylab,'FontSize',18)
text(xpos,ypos,['r=',num2str(round(r,2),'%.2f'),star],'FontSize',16)
print(f1,[figdir,xlab,ylab,tit,'.png'],'-dpng','-r300')