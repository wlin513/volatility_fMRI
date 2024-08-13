clear
getfolders


datadir=[datadir,'physio/'];
subs=dir([datadir,'s26*']);%s04, s14 s26 (those with trigger dropout)
subject_name=subs.name;
txtlist=dir([datadir,subject_name,'/','*.txt']);
    
for i=1:length(txtlist)

    fid=fopen([datadir,subject_name,'/',txtlist(i).name]);
    A=textscan(fid,'%f %f %f');
    fclose(fid);
     
    dropposition=[];
    triggerindex=find(A{1,3}(:,1)==1);
    indexdiff=(triggerindex(2:end)-triggerindex(1:end-1));
    dropposition=find(indexdiff>40);
    if dropposition
        %plot the data before amendment
        f1=figure;
        subplot(3,1,1);plot(A{1,1}(:,1));
        subplot(3,1,2);plot(A{1,2}(:,1));
        subplot(3,1,3);plot(A{1,3}(:,1));
        title('before amendment');
        %fix the dropout
        for d=1:length(dropposition)
            A{1,3}(triggerindex(dropposition(d)+1)-40,1)=1;%mark the middle one 
        end
        %write new trigger data to txt
        tmp=[A{1,1}(:,1),A{1,2}(:,1),A{1,3}(:,1)];
        save([datadir,subject_name,'/',txtlist(i).name],'tmp','-ascii');
        %load the new txt
       fid=fopen([datadir,subject_name,'/',txtlist(i).name]);
       B=textscan(fid,'%f %f %f');
       fclose(fid);
       %plot and save figure
        f2=figure;
        subplot(3,1,1);plot(B{1,1}(:,1));
        subplot(3,1,2);plot(B{1,2}(:,1));
        subplot(3,1,3);plot(B{1,3}(:,1));
        title('after amendment');
        saveas(f2,[datadir,subject_name,'/',extractBefore(txtlist(i).name,'.txt'),'_afterfix.png'])
        
    end
end
