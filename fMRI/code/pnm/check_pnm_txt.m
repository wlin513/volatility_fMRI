%check pnm txt files
clear
getfolders


datadir=[datadir,'physio/'];
subs=dir([datadir,'s26*']);% !!! change this to run a single participant or all participants
for ss=1:size(subs,1)
    subject_name=subs(ss).name;
    txtlist=dir([datadir,subject_name,'/','*.txt']);
    
    for i=1:length(txtlist)

        fid=fopen([datadir,subject_name,'/',txtlist(i).name]);
        A=textscan(fid,'%f %f %f');
        fclose(fid);

        f1=figure;
        subplot(3,1,1);plot(A{1,1}(:,1));
        subplot(3,1,2);plot(A{1,2}(:,1));
        subplot(3,1,3);plot(A{1,3}(:,1));
        saveas(f1,[datadir,subject_name,'/',extractBefore(txtlist(i).name,'.txt'),'.png'])
    end
end
