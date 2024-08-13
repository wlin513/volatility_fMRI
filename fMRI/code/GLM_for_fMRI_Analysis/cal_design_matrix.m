%% Make the hrf and plot the corr matrix
function out=cal_design_matrix(endtime,varargin)
%%
nregressors=nargin-1;
%%
window = 14; % how much time (in s) to display
TR     = 0.8;  % what the time between FMRI volumes was
sigma1 = 3;  % parameter for the shape of the hrf
my1    = 7;  % parameter for hrf shape 
alpha1=my1^2/sigma1^2;
beta1=my1/sigma1^2;
% Code the HRF
t=0:(TR):(window); % create the time window (from 0 s to 14s) for which to show the hrf
hrf = gammapdf(alpha1,beta1,t); % create the hrf 

% % Plot the hrf shape
% figure('name','Convolution','color',[1 1 1]);
% subplot(3,1,1);hold on;
% plot(hrf,'Linewidth',3);set(gca,'Fontsize',16);title('HRF function')

nT=ceil((endtime+3)/TR); %total number of timepoints in our fake FMRI data
% Create a vector that has for every time point whether there is an event
% or not (and the size and direction of the event)

%regressor vectors to be filled
regressors= zeros(nT,nregressors);  
for k=1:nregressors
     for j=1:length(varargin{1,k}.onset)
         regressors(round(varargin{1,k}.onset(j)/TR):round((varargin{1,k}.onset(j)+varargin{1,k}.dur(j))/TR),k)=varargin{1,k}.value(j);
     end
end

% Convolve the vector with the hrf
for k=1:nregressors
convolved_regressors(:,k) = conv(regressors(:,k),hrf);
end
% % Plot the resulting vector
% 
% plot(resp_regressor,'k','Linewidth',3);hold on;plot(resp_convolved_regressor,'Linewidth',3)
% legend('unconvolved regressor','convolved regressor');set(gca,'Fontsize',16);title('Convolved and unconvolved regressors')
out=corrcoef(convolved_regressors);
