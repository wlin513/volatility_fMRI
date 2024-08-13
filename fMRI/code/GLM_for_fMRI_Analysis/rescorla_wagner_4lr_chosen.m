function [r]=rescorla_wagner_4lr_chosen(Y,alpha,start,choice)
%[r]=rescorla_wagner(Y,alpha,start)
% Y is column of wins and losses
% alpha is [reward_lr loss_lr], start is [start_reward start_loss]
%[r]=rescorla_wagner(Y,alpha)  (start is assumed to be 0.5
% Output is probability estimate

if (nargin<3) 
    start=[0.5 0.5];end
if (nargin<4)
    choice=ones(size(Y,1),1); end

r=zeros(size(Y));
r(1,:)=start;

out_rept=Y;
out_rept(choice==0,:)=1-out_rept(choice==0,:);

for i=2:size(r,1)

  if out_rept(i-1,1)==1 
        r(i,1)=r(i-1,1)+alpha(1)*(Y(i-1,1)-r(i-1,1));
      else
            r(i,1)=r(i-1,1)+alpha(2)*(Y(i-1,1)-r(i-1,1));
  end
  
   if out_rept(i-1,2)==1 
       r(i,2)=r(i-1,2)+alpha(4)*(Y(i-1,2)-r(i-1,2));
       else
           r(i,2)=r(i-1,2)+alpha(3)*(Y(i-1,2)-r(i-1,2));
   end
   
end