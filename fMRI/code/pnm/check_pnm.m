function check_pnm(dir,name,visit,r,task)

%function to graphically check performance of pnm output
% load data
name=num2str(name);
visit=num2str(visit);
r=num2str(r);


if isunix; delimit='/'; else delimit='\'; end

if ~strcmp(dir(end),delimit)
dir=[dir,delimit];
end


dir=[dir,name,delimit,'visit_',visit,delimit];
 
if ~isdir(dir)
    error(['Cant find directory ', dir]);
end


if strcmp(task,'reward')
    data=load([dir,name,'_',task,'_v',visit,'_r',r,'_physio_confound_matlab.txt']);
    run_string=[dir,name,'_', task, '_v',visit,'_r',r,'_physio_confound_pnm_stage2'];
elseif strcmp(task,'faces')
     data=load([dir,name,'_',task,'_v',visit,'_physio_confound_matlab.txt']);
    run_string=[dir,name,'_', task, '_v',visit,'_physio_confound_pnm_stage2'];
else
    error('Do not recognise task')
end
    
time=data(:,1);
cardiac=data(:,2);
car_pulse_marks=data(:,3);
resp=data(:,4);
resp_pulse_marks=data(:,5);


if sum(resp)==0
    resp_exist=0;
else
    resp_exist=1;
end

dx=30;


p=figure('units','normalized','outerposition',[0 0 1 1]);
hold on
%maximize;
gdata=guihandles(p);
gdata.max_resp=max(resp);
gdata.delimit=delimit;
gdata.name=name;

gdata.fullname=[name];
gdata.fullpath=[dir,name,'_', task, '_v',visit,'_r',r];
gdata.run_string=run_string;
gdata.run_string_base=run_string;
gdata.dir=dir;
gdata.max_card=max(cardiac);
gdata.min_card=min(cardiac);
gdata.min_resp=min(resp);
gdata.resp_pulse_times=time(resp_pulse_marks==1);
gdata.card_pulse_times=time(car_pulse_marks==1);
gdata.cp=plot(time,cardiac,'b','linewidth',2);
gdata.cl=line([gdata.card_pulse_times' ;gdata.card_pulse_times'],repmat([0 gdata.max_card]',1,length(gdata.card_pulse_times)),'color','r');
gdata.rp=plot(time,resp,'b','linewidth',2);
gdata.rl=line([gdata.resp_pulse_times' ;gdata.resp_pulse_times'],repmat([0 gdata.max_resp]',1,length(gdata.resp_pulse_times)),'color','r');

gdata.pos=0;
gdata.dx=dx;
gdata.card_x_add=[];
gdata.card_x_del=[];
gdata.resp_x_add=[];
gdata.resp_x_del=[];
gdata.x_add_but=1;
gdata.x_del_but=0;
gdata.plot_card_but=1;
gdata.plot_resp_but=0;
gdata.card_add_lines=[];
gdata.card_del_lines=[];
gdata.resp_add_lines=[];
gdata.resp_del_lines=[];


set(gdata.rp,'visible','off');
set(gdata.rl,'visible','off');


% capture clicks
set(p,'units','normalized','WindowButtonDownFcn',@clickcallback)





%% dx is the width of the axis 'window'
a=gca;

% Set appropriate axis limits and settings
set(gcf,'doublebuffer','on');


%% This avoids flickering when updating the axis
set(a,'xlim',[0 dx]);
set(a,'ylim',[min(cardiac) max(cardiac)]);
set(a,'position',[0.15 0.2 0.80 0.75]);
%set(a,'position',[0.15 0.2 0.80 0.75],'drawmode','fast');
gdata.xlim=get(a,'xlim');

% Generate constants for use in uicontrol initialization
pos=get(a,'position');
Newpos=[pos(1) pos(2)-0.075 pos(3) 0.05];
%% This will create a slider which is just underneath the axis
%% but still leaves room for the axis labels above the slider
gdata.xmax=max(time);

%% Setting up callback string to modify XLim of axis (gca)
%% based on the position of the slider (gcbo)

% Creating Uicontrol
gdata.slider=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',@slider_pos,'min',0,'max',gdata.xmax-dx,'sliderstep',[1/gdata.xmax dx./(gdata.xmax)]);

if resp_exist
 %Create the cardiac/resp button group.
cardresp = uibuttongroup('visible','off','Position',[0 0.85 .1 0.15]);
% Create three radio buttons in the button group.
c0 = uicontrol('Style','Radio','String','Cardiac','units','normalized',...
    'pos',[0.05 0.5 0.9 0.3],'parent',cardresp,'HandleVisibility','off');
c1 = uicontrol('Style','Radio','String','Respiratory','units','normalized',...
    'pos',[0.05 0.2 0.9 0.3],'parent',cardresp,'HandleVisibility','off');
% Initialize some button group properties. 
set(cardresp,'SelectionChangeFcn',@selplot);
set(cardresp,'SelectedObject',[]);  % No selection
set(cardresp,'Visible','on');
set(c0,'value',gdata.plot_card_but);
end

 %Create the resize buttons
resizebut = uibuttongroup('visible','off','Position',[0 0.65 .1 0.2]);
% Create three radio buttons in the button group.
r0 = uicontrol('Style','push','String','zoom in x','units','normalized',...
    'pos',[0.1 0.75 0.8 0.2],'parent',resizebut,'HandleVisibility','off','callback',@zoominbut);
r1 = uicontrol('Style','push','String','zoom out x','units','normalized',...
    'pos',[0.1 0.4 0.8 0.2],'parent',resizebut,'HandleVisibility','off','callback',@zoomoutbut);
r2 = uicontrol('Style','push','String','Reset','units','normalized',...
    'pos',[0.1 0.05 0.8 0.2],'parent',resizebut,'HandleVisibility','off','callback',@resetbut);
% Initialize some button group properties. 
set(resizebut,'Visible','on');

finbut=uicontrol('style','push','string','End and write','units','normalized','pos',[0 0.5 0.1 0.1],'callback',@finishbut,'visible','on');
finbut2=uicontrol('style','push','string','End','units','normalized','pos',[0 0.4 0.1 0.1],'callback',@finishbut2,'visible','on');
gdata.rtext=uicontrol('style','edit','string',run_string,'units','normalized','position',[ 0.1 0.02 0.8 0.08],'fontsize',12,'visible','on','enable','inactive','max',10);


guidata(p,gdata);

end


function finishbut2(hobject,eventdata)
gdata=guidata(gcbo);

mainfig=get(hobject,'parent');
close(mainfig);


end

function finishbut(hobject,eventdata)
 gdata=guidata(gcbo);
 
 filename = [gdata.fullpath,'_card_del.txt'];
 crdtext=sprintf('%g,',gdata.card_x_del);
fid = fopen(filename, 'w');
    fprintf(fid, '%s', crdtext(1:end-2));
 fclose(fid);
 
  filename = [gdata.fullpath,'_card_add.txt'];
 crdtext=sprintf('%g,',gdata.card_x_add);
fid = fopen(filename, 'w');
    fprintf(fid, '%s', crdtext(1:end-2));
 fclose(fid);
 
  filename = [gdata.fullpath,'_resp_add.txt'];
 crdtext=sprintf('%g,',gdata.resp_x_add);
fid = fopen(filename,'w');
    fprintf(fid, '%s', crdtext(1:end-2));
 fclose(fid);
 
  filename = [gdata.fullpath,'_resp_del.txt'];
 crdtext=sprintf('%g,',gdata.resp_x_del);
fid = fopen(filename, 'w');
    fprintf(fid, '%s', crdtext(1:end-2));
 fclose(fid);
 

filename = [gdata.fullpath,'_run_second_lev.txt'];
fid = fopen(filename, 'w');
    fprintf(fid, '%s', gdata.run_string);
 fclose(fid);
 
 system(['chmod a+x ',filename]);


system([filename,' &']);

mainfig=get(hobject,'parent');
close(mainfig);



end



function resetbut(hobject,eventdata)
gdata=guidata(gcbo);
gdata.dx=30;
set(gca,'xlim',gdata.pos+[0 gdata.dx]);
set(gdata.slider,'sliderstep',[1/gdata.xmax gdata.dx/(gdata.xmax)]);

guidata(gcbo,gdata);
end

function zoominbut(hobject,eventdata)
gdata=guidata(gcbo);

gdata.dx=gdata.dx/2;
set(gca,'xlim',gdata.pos+[0 gdata.dx]);

set(gdata.slider,'sliderstep',[1/gdata.xmax gdata.dx/(gdata.xmax)]);
guidata(gcbo,gdata);
end

function zoomoutbut(hobject,eventdata)
gdata=guidata(gcbo);
gdata.dx=gdata.dx*2;
set(gca,'xlim',gdata.pos+[0 gdata.dx]);
set(gdata.slider,'sliderstep',[1/gdata.xmax gdata.dx/(gdata.xmax)]);

guidata(gcbo,gdata);
end

function slider_pos(hobject,eventdata)
gdata=guidata(gcbo);
gdata.pos=get(hobject,'value');
set(gca,'xlim',gdata.pos+[0 gdata.dx]);
gdata.xlim=get(gca,'xlim');

guidata(gcbo,gdata);

end

function clickcallback(hobject,eventdata)

gdata=guidata(gcbo);
ca=get(hobject,'currentaxes');
clickcord=get(ca,'CurrentPoint');
presstype=get(hobject,'SelectionType');


if strcmp(presstype,'normal')  % left mouse button
    
    if gdata.plot_card_but ==1
gdata.card_x_add=[gdata.card_x_add; clickcord(1)];
gdata.card_pulse_times=[gdata.card_pulse_times;clickcord(1)];
set(gdata.card_add_lines,'visible','off');
gdata.card_add_lines=line([gdata.card_x_add' ;gdata.card_x_add'],repmat([0 gdata.max_card]',1,length(gdata.card_x_add)),'color','g','linewidth',3);
    else
        gdata.resp_x_add=[gdata.resp_x_add; clickcord(1)];
gdata.resp_pulse_times=[gdata.resp_pulse_times;clickcord(1)];
set(gdata.resp_add_lines,'visible','off');
gdata.resp_add_lines=line([gdata.resp_x_add' ;gdata.resp_x_add'],repmat([0 gdata.max_resp]',1,length(gdata.resp_x_add)),'color','g','linewidth',3);
        
    end

elseif strcmp(presstype,'alt')  % right mouse button
    
    if gdata.plot_card_but ==1
    nearest_line=gdata.card_pulse_times(abs(gdata.card_pulse_times-clickcord(1))==min(abs(gdata.card_pulse_times-clickcord(1))));
    gdata.card_x_del=[gdata.card_x_del; nearest_line];
    if sum(nearest_line==gdata.card_x_add)
    gdata.card_x_add(gdata.card_x_add==nearest_line)=[];
    gdata.card_x_del(gdata.card_x_del==nearest_line)=[];
    end
    delete(gdata.card_del_lines);
    delete(gdata.card_add_lines);
    gdata.card_del_lines=line([gdata.card_x_del' ;gdata.card_x_del'],repmat([0 gdata.max_card]',1,length(gdata.card_x_del)),'color','k','linestyle','--','linewidth',3);
    gdata.card_add_lines=line([gdata.card_x_add' ;gdata.card_x_add'],repmat([0 gdata.max_card]',1,length(gdata.card_x_add)),'color','g','linewidth',3);
    else
         nearest_line=gdata.resp_pulse_times(abs(gdata.resp_pulse_times-clickcord(1))==min(abs(gdata.resp_pulse_times-clickcord(1))));
    gdata.resp_x_del=[gdata.resp_x_del; nearest_line];
     if sum(nearest_line==gdata.resp_x_add)
    gdata.resp_x_add(gdata.resp_x_add==nearest_line)=[];
    gdata.resp_x_del(gdata.resp_x_del==nearest_line)=[];
     end
    delete(gdata.resp_add_lines);
    delete(gdata.resp_del_lines);
    gdata.resp_del_lines=line([gdata.resp_x_del' ;gdata.resp_x_del'],repmat([0 gdata.max_resp]',1,length(gdata.resp_x_del)),'color','k','linestyle','--','linewidth',3);
    gdata.resp_add_lines=line([gdata.resp_x_add' ;gdata.resp_x_add'],repmat([0 gdata.max_resp]',1,length(gdata.resp_x_add)),'color','g','linewidth',3);
   
    end
end

guidata(gcbo,gdata);
update_string
end

function update_string
gdata=guidata(gcbo);

run_string=gdata.run_string_base;

if ~isempty(gdata.card_x_add)
    crdtext=sprintf('%g,',gdata.card_x_add);
run_string=[run_string,' --cardadd=',crdtext(1:end-2)];
end

if ~isempty(gdata.card_x_del)
    crdtext=sprintf('%g,',gdata.card_x_del);
run_string=[run_string,' --carddel=',crdtext(1:end-2)];
end

if ~isempty(gdata.resp_x_add)
    crdtext=sprintf('%g,',gdata.resp_x_add);
run_string=[run_string,' --respadd=',crdtext(1:end-2)];
end

if ~isempty(gdata.resp_x_del)
    crdtext=sprintf('%g,',gdata.resp_x_del);
run_string=[run_string,' --respdel=',crdtext(1:end-2)];
end


set(gdata.rtext,'string',run_string);

gdata.run_string=run_string;
guidata(gcbo,gdata);
end



function selplot(hobject,eventdata)

gdata=guidata(gcbo);
 but_sel=get(eventdata.NewValue,'String');

 if strcmp(but_sel,'Cardiac')
     gdata.plot_card_but=1;
     gdata.plot_resp_but=0;
   set(gdata.rp,'visible','off');
set(gdata.rl,'visible','off');
set(gdata.resp_add_lines,'visible','off');
set(gdata.resp_del_lines,'visible','off');
  set(gdata.cp,'visible','on');
set(gdata.cl,'visible','on');
set(gdata.card_add_lines,'visible','on');
set(gdata.card_del_lines,'visible','on');
set(gca,'xlim',gdata.pos+[0 gdata.dx]);
set(gca,'ylim',[gdata.min_card gdata.max_card]);
     
 elseif strcmp(but_sel,'Respiratory')
     gdata.plot_card_but=0;
     gdata.plot_resp_but=1;
       set(gdata.cp,'visible','off');
set(gdata.cl,'visible','off');
set(gdata.card_add_lines,'visible','off');
set(gdata.card_del_lines,'visible','off');
      set(gdata.rp,'visible','on');
set(gdata.rl,'visible','on');
set(gdata.resp_add_lines,'visible','on');
set(gdata.resp_del_lines,'visible','on');
set(gca,'xlim',gdata.pos+[0 gdata.dx]);
set(gca,'ylim',[gdata.min_resp gdata.max_resp]);
 end
 guidata(gcbo,gdata);


end


