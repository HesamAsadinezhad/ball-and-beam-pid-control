function varargout = optimpid(varargin)
% OPTIMPID Optimal PID controller design interface.
% MATLAB code for optimpid.figf
% Last Modified by GUIDE v2.5 05-Nov-2011 01:00:59

% Designed by Professor Dingyu Xue
%             Northeastern University, Shenyang 110004, China
%             Email: xuedingyu@mail.neu.edu.cn
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @optimpid_OpeningFcn, ...
                   'gui_OutputFcn',  @optimpid_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function optimpid_OpeningFcn(hObject, eventdata, handles, varargin)
v=version; i=findstr(v,'R'); s1=v(i:i+5); pause(0.0001)
if eval(v(i+1:i+4))>2011, s1='R2011a'; end
try
   str=which(['pidctrl_model' s1 '.mdl']);
   i=findstr(str,'pidctrl_model'); fpath=[str(1:i-1),'models\']; 
   if length(str)==0
      errordlg({'Sorry, the current version is NOT supported,';
                'please try a later one'},'Error in MATLAB version')
   else
      copyfile(str,'pidctrl_model.mdl','f');
      copyfile([fpath,'mod_1' s1 '.mdl'],'mod_1.mdl','f')
      copyfile([fpath,'mod_2' s1 '.mdl'],'mod_2.mdl','f')
      copyfile([fpath,'mod_3' s1 '.mdl'],'mod_3.mdl','f')
      copyfile([fpath,'mod_lti' s1 '.mdl'],'mod_lti.mdl','f')
   end
catch
   errordlg({'Sorry, the current folder is a read-only one,';
             'please try another one'},'Error in working folder')
end
handles.output = hObject;
guidata(hObject, handles);
assignin('base','t_seq',0); assignin('base','y_seq',1); 
assignin('base','keyCriterion',1); assignin('base','Kp',1); 
assignin('base','Ki',1); assignin('base','Kd',1);
set(handles.hEdtConPars,'String','');
str='pidctrl_model.mdl.autosave'; h=dir; 
for i=3:length(h)
   if strcmp(str,h(i).name), delete(str); break; end
end
load_system('pidctrl_model')
mod_name=get_param('pidctrl_model/Plant Model','ModelNameDialog');
set(handles.hEdtPlant,'String',mod_name);

% --- Outputs from this function are returned to the command line.
function varargout = optimpid_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function hEdtPlant_Callback(hObject, eventdata, handles)
mod_name=get(handles.hEdtPlant,'String');
set_param('pidctrl_model/Plant Model','ModelNameDialog',mod_name);
load_system(mod_name);
set_param(mod_name,'InlineParams','on');

% --- Executes on selection change in hListCriterion.
function hListCriterion_Callback(hObject, eventdata, handles)
assignin('base','keyCriterion',get(handles.hListCriterion,'Value'));

function hBtnShowModel_Callback(hObject, eventdata, handles)
open_system(get(handles.hEdtPlant,'String'));

function hBtnFile_Callback(hObject, eventdata, handles)
[FileN,PathN]=uigetfile('*.mdl','Select a plant model');
set(handles.hEdtPlant,'String',FileN);
hEdtPlant_Callback(hObject, eventdata, handles);

function hBtnShow_Callback(hObject, eventdata, handles)
str=get(handles.hBtnCreate,'UserData'); edit(str)

function hBtnOptim_Callback(hObject, eventdata, handles)
set_param('pidctrl_model/Scope','Open','on');
str=get(handles.hBtnCreate,'UserData');
if length(str)==0 | exist(str)~=2
    errordlg({'Error: No objective function file existing. Click ''Create ';
              'File'' button to create it first.'},'Error in objective function file');
    return
end
ff=msgbox({'Optimization process is going on.   Go back to the Command Window';
           'for optimalization results.  Please wait ...'},'Optimizing ...');
options=optimset(...%'Display','iter',
    'Jacobian','off','LargeScale','off','MaxIter',20);
str=get(handles.hBtnCreate,'UserData'); 
kTool=get(handles.hLstAlgorithm,'Value'); 
n=get(handles.hLstPIDType,'UserData');  X1=ones(n,1);
if get(handles.hChkHold,'Value')==1
    set(handles.hEdtTerm,'String',get(handles.hEdtEnd,'String'))
    hBtnCreate_Callback(hObject, eventdata, handles)
    assignin('base','t_seq',eval(get(handles.hEdtTSeq,'String'))); 
    assignin('base','y_seq',eval(get(handles.hEdtYSeq,'String')));
else
    assignin('base','t_seq',0); assignin('base','y_seq',1);
end
x0s=get(handles.hEdtConPars,'String'); y0=1e10; yy=1e5;
if length(x0s)==0, x0=rand(n,1); else, x0=eval(x0s); end
xa=get(handles.hEdtConLow,'String'); kLBounds=0;
if length(xa)==0, 
    if kTool==3, xm=0.01*X1; else, xm=-inf*X1; end
else, xm=eval(xa); kLBounds=1;
    if prod(size(xm))==1, xm=xm*X1; end  
end
xa=get(handles.hEdtConUp,'String');
if length(xa)==0, 
    if kTool==3, xM=10*X1; else, xM=inf*X1; end
else, xM=eval(xa); kLBounds=1;
    if prod(size(xM))==1, xM=xM*X1; end  
end
x0=[x0(:); rand(2,1)]; x0=x0(1:n);
switch kTool
    case 1
        tol=eval(get(handles.edtTol,'String'));
        while abs(y0-yy)>tol, y0=yy; 
            if kLBounds==0
               eval(['[x0,yy]=fminsearch(@',str,',x0,options)'])
            else 
               eval(['[x0,yy]=fmincon(@',str,',x0,[],[],[],[],xm,xM,[],options)'])
            end
            set(handles.hTxtCrit,'String',num2str(yy));
            if get(handles.chkLoop,'Value')==0, break; end
        end
    case 2
        if kLBounds==0
           eval(['[x0,yy]=ga(@' str ',n)']);
        else 
           eval(['[x0,yy]=ga(@' str ',n,[],[],[],[],xm,xM)']);
        end
        eval([str '(x0)'])
    case 3
        if kLBounds==0, xm=-xM; end
        x0=gaopt([xm xM],str), eval([str '(x0(1:end-1))']), yy=-x0(end);
    case 4
        if kLBounds==0
           eval(['x0=pso_Trelea_vectorized(''' str ''',n)']);
        else 
           eval(['x0=pso_Trelea_vectorized(''' str ''',n,4,[xm xM])']);
        end
        eval(['yy=' str '(x0)'])
    case 5
        if kLBounds==0
           eval(['[x0,yy]=simulannealbnd(@',str,',x0)'])
        else 
           eval(['[x0,yy]=simulannealbnd(@',str,',x0,[xm xM])'])
        end
        eval([str '(x0)'])
    case 6
        if kLBounds==0
           eval(['[x0,yy]=patternsearch(@',str,',x0)'])
        else 
           eval(['[x0,yy]=patternsearch(@',str,',x0,[],[],[],[],[xm xM])'])
        end
        eval([str '(x0)'])
end
set(handles.hEdtConPars,'String',['[' num2str(x0(:).') ']']);
set(handles.hTxtCrit,'String',num2str(yy));
pause(0.0001); delete(ff);

function hBtnRefresh_Callback(hObject, eventdata, handles)
set(handles.hEdtConPars,'String','');
for i=0:1000
    try
       str=['optpidfun_' int2str(i)];    
       if exist(str)==2, delete([str '.m']); end
    catch
        errordlg({'Error deleting files ';lasterr},'Error');
    end
end

function hBtnSimulation_Callback(hObject, eventdata, handles)
try
    t_seq=eval(get(handles.hEdtTSeq,'String'));
    y_seq=eval(get(handles.hEdtYSeq,'String'));
    t_end=eval(get(handles.hEdtEnd,'String'))
catch
    errordlg('Syntax errors in the multi-stairs vectors','Error...')
end
if length(t_seq)~=length(y_seq)
    errordlg('Lengths mismatch in the multi-stairs vectors','Error...')
end
assignin('base','t_seq',t_seq);
assignin('base','y_seq',y_seq);
set_param('pidctrl_model/Scope','Open','on');
[tt,xx,yy]=sim('pidctrl_model',[0,t_end]);
set(handles.hTxtCrit,'String',num2str(yy(end,1)))

function hEdtLower_Callback(hObject, eventdata, handles)
set_saturation(handles)

function hEdtUpper_Callback(hObject, eventdata, handles)
set_saturation(handles)

function hRadioCon_Callback(hObject, eventdata, handles)
set(handles.hRadioDis,'Value',0)
set(handles.hRadioCon,'Value',1)
set([handles.hTxtSamp,handles.hEdtSamp],'Visible','off');
set_param('pidctrl_model/PID Controller','TimeDomain','Continuous-time');

function hRadioDis_Callback(hObject, eventdata, handles)
set(handles.hRadioCon,'Value',0)
set(handles.hRadioDis,'Value',1)
set([handles.hTxtSamp,handles.hEdtSamp],'Visible','on');
T=get(handles.hEdtSamp,'String');
set_param('pidctrl_model/PID Controller','TimeDomain','Discrete-time');
set_param('pidctrl_model/PID Controller','SampleTime',T);

function hEdtSamp_Callback(hObject, eventdata, handles)
set_param('pidctrl_model/PID Controller','SampleTime',get(handles.hEdtSamp,'String'));

function hBtnInfty_Callback(hObject, eventdata, handles)
set(handles.hEdtUpper,'String','inf');
set_saturation(handles)

function hBtnNInfty_Callback(hObject, eventdata, handles)
set(handles.hEdtLower,'String','-inf');
set_saturation(handles)

function hBtnCreate_Callback(hObject, eventdata, handles)
k=0;
while 1
    str=['optpidfun_' int2str(k)];
    if ~any([2 3 5 6]==exist(str)), break; end
    k=k+1;
end
try
    fid=fopen([str,'.m'],'w');
    kTool=get(handles.hLstAlgorithm,'Value');
    if kTool==3 % if GAOT is used, rewrite the objective function
        fprintf(fid,'function [x,y]=%s(x,opts)\r\n',str);
    else
        fprintf(fid,'function y=%s(x)\r\n',str);
    end
    t_end=eval(get(handles.hEdtTerm,'String'));
    fprintf(fid,'%% %s   An objective function for optimal PID controller tuning\r\n',upper(str));
    fprintf(fid,'%%   It describes the relationship between the PID controller parameters\r\n');
    fprintf(fid,'%%   and the chosen performance index.\r\n\r\n');
    fprintf(fid,'%%   The function is automatically created by PID Controller Optimizer.\r\n');
    fprintf(fid,'%%   Date of creation %s\r\n',date);
    strP=['Kp';'Ki';'Kd'];
    fprintf(fid,'opt=simset(''OutputVariables'',''y'');\r\n');
    switch get(handles.hLstPIDType,'Value')
        case 1, vv=1; n=1;
        case {2,6}, vv=[1,2]; n=2;
        case 3, vv=[1,3]; n=2;
        case {4,7}, vv=[1,2,3]; n=3;
        case 5, vv=[2]; n=1;
    end
    set(handles.hLstPIDType,'UserData',n); ss='';
    if kTool==4
        fprintf(fid,'for i=1:size(x,1)\r\n'); ss='    ';
    end
    for i=1: length(vv)
        if kTool==4
            fprintf(fid,'    assignin(''base'',''%s'',x(i,%d));\r\n',strP(vv(i),:), i);
        else
            fprintf(fid,'assignin(''base'',''%s'',x(%d));\r\n',strP(vv(i),:), i);
        end
    end
    fprintf(fid,[ss,'try\r\n']);
    fprintf(fid,[ss,'   [~,~,y_out]=sim(''pidctrl_model'',[0,%f],opt);\r\n'],t_end);
    fprintf(fid,[ss,'catch, y_out=1e10; end\r\n']);
    switch kTool
        case {1,2,5,6}, 
            fprintf(fid,'y=y_out(end,1);\r\n');
            if get(handles.chkOvershoot,'Value')==1
                ss=eval(get(handles.edtOvershoot,'String'))*0.01+1;
                fprintf(fid,'if any(y_out(:,2)>%5.2f*y_out(:,4)), ',ss)
                fprintf(fid,'y=1.5*y; end\r\n')
            end
        case 3,     fprintf(fid,'y=-y_out(end,1);\r\n');
        case 4,
            fprintf(fid,'    y(i,1)=y_out(end,1);\r\n');
            fprintf(fid,'end\r\n');
    end
    fclose(fid);
    set(handles.hBtnCreate,'UserData',str);
    edit(str); figure(handles.hMainPID)
catch
    errordlg('The current working folder is read-only, try another one','Error...')
end

function hBtnHelp_Callback(hObject, eventdata, handles)
web(['file:' which('pid_optimizer.htm')])

function hBtnExit_Callback(hObject, eventdata, handles)
close_system('pidctrl_model',0); delete(gcf)

function hMainPID_CloseRequestFcn(hObject, eventdata, handles)
close_system('pidctrl_model',0); delete(gcf)

function hLstPIDType_Callback(hObject, eventdata, handles)
key=get(handles.hLstPIDType,'Value'); contype={'P','PI','PD','PID','I','PI','PID'};
set_param('pidctrl_model/PID Controller','Controller',contype{key});
if key<=5
    set_param('pidctrl_model/PID Controller','AntiWindupMode','none');
else
    set_param('pidctrl_model/PID Controller','AntiWindupMode','clamping');
end

function set_saturation(handles)
v1s=get(handles.hEdtLower,'String'); v1=isfinite(eval(v1s));
v2s=get(handles.hEdtUpper,'String'); v2=isfinite(eval(v2s)); v1v2=v1|v2;
set_param('pidctrl_model/PID Controller','LimitOutput',onoff(v1v2));
set_param('pidctrl_model/PID Controller','UpperSaturationLimit',v2s)
set_param('pidctrl_model/PID Controller','LowerSaturationLimit',v1s)

function hLstAlgorithm_Callback(hObject, eventdata, handles)
kAlgorithm=get(hObject,'Value'); key=0; 
str={'Global Optimization'; 'GAOT'; 'PSOt'};
switch kAlgorithm
    case {2,5,6}
       if exist('ga')~=2, key=1; end
    case 3
       if exist('gaopt')~=2, key=1; end
    case 4
       if exist('pso_Trelea_vectorized')~=2, key=1; end
end
if key==1
    set(hObject,'Value',1);
    errordlg({['Warning: The ' str{kAlgorithm-1} ' Toolbox is not available on your path.'];
               'The default toolbox is selected instead.'},'Warning')
end

function hChkHold_Callback(hObject, eventdata, handles)
set(handles.hEdtTerm,'String',get(handles.hEdtEnd,'String'))

function hEdtYSeq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hLstPIDType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtTerm_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtTSeq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtSamp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hListCriterion_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hLstAlgorithm_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtUpper_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtLower_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtPlant_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtConLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtConUp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function hEdtConPars_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function chkLoop_Callback(hObject, eventdata, handles)
function edtTol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function chkOvershoot_Callback(hObject, eventdata, handles)
function edtOvershoot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hEdtYSeq_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtTSeq_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtEnd_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtTerm_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtConLow_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtConUp_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function hEdtConPars_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function edtOvershoot_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function edtTol_Callback(hObject, eventdata, handles)
evaluation_check(hObject, eventdata, handles)

function evaluation_check(hObject, eventdata, handles)
try
    vs=get(hObject,'String');
    if length(vs)>0, v=eval(vs); end
catch
    errordlg('Error in the Edit Box, try again','Error...')
end
function str=onoff(val)
if val==0, str='off'; else, str='on'; end
