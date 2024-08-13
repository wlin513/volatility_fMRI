%%for s19 only

clear
getfolders


datadir=[datadir,'physio/'];
subs=dir([datadir,'s19*']);%(s19: bothvol & winvol & lossvol blocks have too many double peaks in Cardiac data)
subject_name=subs.name;
txtlist=dir([datadir,subject_name,'/','*.txt']);
    
for i=2:length(txtlist)%(s19: bothvol & winvol & lossvol blocks have too many double peaks in Cardiac data)

    fid=fopen([datadir,subject_name,'/',txtlist(i).name]);
    A=textscan(fid,'%f %f %f');
    fclose(fid);
     
        
        %fix the doublepeaks
        
        y=fft(A{1,2}(:,1));%pulse/cardiac
        f = (0:length(y)-1)*500/length(y);
        plot(f,abs(y))
        xlim([0,50])
        
        samplerate=500;% for cardiac data
        
        [z,p,k] = butter(1,7/(samplerate/2),'low');  % first order filter? why?
        [sos,g] = zp2sos(z,p,k);
        Hd = dfilt.df2tsos(sos,g);
        
        xx=filter(Hd,A{1,2}(:,1));
        yy=fft(xx);%pulse/cardiac
        ff = (0:length(yy)-1)*500/length(yy);
        plot(ff,abs(yy))
        xlim([0,50])
%         %plot to compare
%         range=3000:5000;
%         subplot(2,1,1)
%         plot(A{1,2}(range,1));
%         subplot(2,1,2)
%         plot(xx(range));
        %write new trigger data to txt
        tmp=[A{1,1}(:,1),xx,A{1,3}(:,1)];
        save([datadir,subject_name,'/',txtlist(i).name],'tmp','-ascii');
        %load the new txt
       fid=fopen([datadir,subject_name,'/',txtlist(i).name]);
       B=textscan(fid,'%f %f %f');
       fclose(fid);
        
end
