function [f1]=corrplot(var,ques,yname,xname,ttype,ifylim)
if nargin < 6
    ifylim=1;
end
f1=figure('units','inch','position',[0,0,20,20/(size(var,2)+1)]);
y1=round(min(min(var)),2);y2=round(max(max(var)),2);
y1=floor(y1*10)/10;y2=ceil(y2*10)/10;
xpos=(max(ques)-min(ques))*0.6+min(ques);
subplot(1,size(var,2)+1,1)
    scatter(ques,mean(var,2),'filled');
    lsline
    [r,p]=corr(ques,mean(var,2),'type',ttype);
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
    text(xpos,y1+0.05,['r=',num2str(round(r,2),'%.2f'),star])
    if ifylim==1
    ylim([y1,y2])
    end
    xlabel(xname)
    ylabel(yname)
for i=1:size(var,2)
    subplot(1,size(var,2)+1,i+1)
    scatter(ques,var(:,i));
    lsline
    [r,p]=corr(ques,var(:,i),'type',ttype);
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
    text(xpos,y1+0.05,['r=',num2str(round(r,2),'%.2f'),star])
    if ifylim==1
    ylim([y1,y2])
    end
    xlabel(xname)
    ylabel(yname)
end
