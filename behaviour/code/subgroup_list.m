function [sublist,figname] = subgroup_list(subgroupnum,currentgroupnum,grouptype)
%input: subgroupnum is to define how many subgroups you would like to have
%       currentgroupnum is the group in interest
%       grouptype: 1 for depression(QIDS scores) on scan day
%                  2 for prescreen depression(QIDS scores)
    if nargin<3
        grouptype=1;
    end

    if grouptype==1
        if subgroupnum==2
         sublist_high={'s11','s15','s07','s09','s04','s08','s16','s17','s18','s19','s20','s21','s22','s23','s24','s26'};
         sublist_low={'s10','s06','s13','s01','s05','s03','s12','s14','s02','s25'};
        end

        if subgroupnum==3
         sublist_high={'s4','s8','s17','s18','s19','s20','s22','s24'};
         sublist_mild={'s7','s9','s11','s15','s16','s21','s23','s26'};
         sublist_low={'s10','s06','s13','s01','s05','s03','s12','s14','s02','s25'}; 
        end
        
    end
    
    if currentgroupnum==subgroupnum
       sublist=sublist_low;
    end
    if currentgroupnum==1
        sublist=sublist_high;
    end
    if subgroupnum==3 & currentgroupnum==2
                sublist=sublist_hig;
    end
end

