
clear
load('covert_physio.mat');

for i=1:length(a)
    if a(i,2)>0
check_pnm(['/home/michaelb/data/es_study/physio/',num2str(a(i,1)),'/1/'],'1','covert');
uiwait;
    end
    if a(i,3)>0
check_pnm(['/home/michaelb/data/es_study/physio/',num2str(a(i,1)),'/2/'],'2','covert');
uiwait;
    end
     if a(i,4)>0
check_pnm(['/home/michaelb/data/es_study/physio/',num2str(a(i,1)),'/3/'],'3','covert');
uiwait;
    end
    
end
