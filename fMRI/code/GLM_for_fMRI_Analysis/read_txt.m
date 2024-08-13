function rawdata=read_txt(txt)
     fid=fopen(txt);
     A = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s');
     fclose(fid);
     
     rawdata=struct();
     rawdata.subnum=cellfun(@str2num,A{1,3}(1,1));
     rawdata.blktype=cellfun(@str2num,A{1,5}(1,1));
     rawdata.ifreverse=cellfun(@str2num,A{1,7}(1,1));
     for i=1:length(A)
         
              if strmatch('Trialnumber',A{1,i}(2,1),'exact')
                 rawdata.trialnum=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Winpos',A{1,i}(2,1),'exact')
                 rawdata.winpos=cellfun(@str2num,A{1,i}(3:end,1));
              end     
              if strmatch('Losspos',A{1,i}(2,1),'exact')
                 rawdata.losspos=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Side',A{1,i}(2,1),'exact')
                 rawdata.side=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('ISIjitter',A{1,i}(2,1),'exact')
                 rawdata.ISIjitter=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('ITIjitter',A{1,i}(2,1),'exact')
                 rawdata.ITIjitter=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Order',A{1,i}(2,1),'exact')
                 rawdata.order=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Choice',A{1,i}(2,1),'exact')
                 rawdata.choice=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('RT',A{1,i}(2,1),'exact')
                 rawdata.RT=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Choiceside',A{1,i}(2,1),'exact')
                 rawdata.choiceside=(A{1,i}(3:end,1));
              end
              if strmatch('Winchosen',A{1,i}(2,1),'exact')
                 rawdata.winchosen=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('LossChosen',A{1,i}(2,1),'exact')
                 rawdata.losschosen=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('TotalMoney',A{1,i}(2,1),'exact')
                 rawdata.totalmoney=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Fixonset',A{1,i}(2,1),'exact')
                 rawdata.fixonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Fixationonset',A{1,i}(2,1),'exact')
                 rawdata.fixationonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Choiceonset',A{1,i}(2,1),'exact')
                 rawdata.choiceonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Monitoronset',A{1,i}(2,1),'exact')
                 rawdata.monitoronset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Chosenoptiononset',A{1,i}(2,1),'exact')
                 rawdata.chosenoptiononset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Winresonset',A{1,i}(2,1),'exact')
                 rawdata.winresonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Lossresonset',A{1,i}(2,1),'exact')
                 rawdata.lossresonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              
              if strmatch('Outcomesonset',A{1,i}(2,1),'exact')
                 rawdata.outcomesonset=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Fixationonset_TR',A{1,i}(2,1),'exact')
                 rawdata.fixationonset_tr=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Fixationonset_Total',A{1,i}(2,1),'exact')
                 rawdata.fixationonset_total=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Choiceonset_TR',A{1,i}(2,1),'exact')
                 rawdata.choiceonset_tr=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Choiceonset_Total',A{1,i}(2,1),'exact')
                 rawdata.choiceonset_total=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Chosenoptiononset_TR',A{1,i}(2,1),'exact')
                 rawdata.chosenoptiononset_tr=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Chosenoptiononset_Total',A{1,i}(2,1),'exact')
                 rawdata.chosenoptiononset_toal=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Outcomesonset_TR',A{1,i}(2,1),'exact')
                 rawdata.outcomesonset_tr=cellfun(@str2num,A{1,i}(3:end,1));
              end
              if strmatch('Outcomesonset_Total',A{1,i}(2,1),'exact')
                 rawdata.outcomesonset_total=cellfun(@str2num,A{1,i}(3:end,1));
              end              
              if strmatch('stima',A{1,i}(2,1),'exact')
                 rawdata.stima=cell2mat(A{1,i}(3:end,1));
              end
              if strmatch('stimb',A{1,i}(2,1),'exact')
                 rawdata.stimb=cell2mat(A{1,i}(3:end,1));
              end
              
              
     end
        
