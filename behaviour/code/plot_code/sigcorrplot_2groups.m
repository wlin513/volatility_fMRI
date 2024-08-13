function sigcorrplot_2groups(var2,var1,xlab,ylab,tit,type,group,figdir)
fcorr=figure;
[r,p]=corr(var1,var2,'Type',type);
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
scatter(var1,var2,60,group,'filled')
map=[0.5 0 0.8;1.0 0.6 0.2];
colormap(map);
l=lsline;
l.Color='r';
l.LineWidth=3;
xpos=(max(var1)-min(var1))*0.7+min(var1);
ypos=(max(var2)-min(var2))*0.75+min(var2);
set(gca,'FontSize',8);
xlabel(xlab,'FontSize',18)
ylabel(ylab,'FontSize',18)
text(xpos,ypos,['r=',num2str(round(r,2),'%.2f'),star],'FontSize',14)
print(fcorr,[figdir,xlab,ylab,tit,'.png'],'-dpng','-r300')