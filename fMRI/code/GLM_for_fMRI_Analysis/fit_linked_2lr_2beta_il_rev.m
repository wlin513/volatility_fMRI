function [out]=fit_linked_2lr_2beta_il_rev(information,choice, start,abandontn,resp_made,alphabins,betabins, fig_yes)


% Bayesian model fit for 2 option vol training task in which outcomes are linked.
% (i.e. if one option wins, the other doesn't).
% Information contains left_win, left_loss (values for right are 1-these)
% choice is the participant choice, start [rew_start loss_start]
% alphabins sets number of points to
% estimate lr, betabins same for beta, resp_made is trials on which a
% response was made.
% in this version different betas independently multiply win and loss values 
if(nargin<8) fig_yes=0; end
if(nargin<7) betabins=30; end
if(nargin<6) alphabins=30; end
if(nargin<5) resp_made=(isnan(choice)==0); end  %exclude the trials on which no response is made

out=struct;

% NB calculations (of mean and variance) of both learning rate and decision
% temperature are performed in log space.

%This creates a vector of length alphabins in inv_logit space
i=inv_logit(0.01):(inv_logit(0.99)-inv_logit(0.01))/(alphabins-1):inv_logit(0.99);

% this creates a vector of length betabins the value of which changes
% linearly from log(1)=0 to log(100)=4.6. It will be used to create a
% logorythmic distribution of inverse temperatures.
b_label=log(0.1):(log(100)-log(0.1))/(betabins-1):log(100);


% this runs a modified Rescorla-Wagner model which uses separate learning
% rates for wins and losses. Output is the relative value of left-right

for k=1:length(i)
for j=1:length(i)
    learn_left=rescorla_wagner_2lr(information(:,1:2),[inv_logit(i(k),1) inv_logit(i(j),1)],start); % calculates separate value for wins and losses 
    val_l_win(k,j,:)=learn_left(:,1); 
    val_l_loss(k,j,:)=learn_left(:,2);
end
end

% replicate the value matrice to account for betas

mmdl_win=repmat(val_l_win,[1,1,1,length(b_label),length(b_label)]);
mmdl_loss=repmat(val_l_loss,[1,1,1,length(b_label),length(b_label)]);

clear val_l_win val_l_loss

beta_win=repmat(permute(exp(b_label),[1 3 4 2 5]),[length(i) length(i) length(information) 1 length(b_label)]);
beta_loss=repmat(permute(exp(b_label),[1 3 4 5 2]),[length(i) length(i) length(information) length(b_label) 1]);

probleft=1./(1+exp(-((beta_win.*mmdl_win)-(beta_loss.*mmdl_loss))));

clear beta_win beta_loss
% looks like choices can be a matrix with each column representing the
% choice of a given participant


  
  % create a 5D matrix of the same dimensions as before with the choices
  % arranged along the second dimension
  ch=repmat(permute(choice,[2 3 1 4 5]),[length(i) length(i)  1 length(b_label) length(b_label)]);
  % This calculates the likelihood of the choices made given the model
  % parameters
  probch=((ch.*probleft)+((1-ch).*(1-probleft)));
  clear probleft

  %this bit removes data from trials in which the participant made no
  %response
  includeTri=[false(abandontn,1);resp_made((abandontn+1):end)];
  probch=probch(:,:,includeTri,:,:);


  % This calculates the overall liklihood of the parameters by taking the
  % product of the individual trials. I presume the final term which
  % multiples the number by a large amount just makes the numbers
  % manageable (otherwise they are very small). Note that this is now a
  % four dimensional matrix which contains the likelihood of the data
  % given the three parameters which are coded on the dimensions (learning
  % rate, temperature, a). The final dimension separates the data from each
  % indvidiual participant
  out.posterior_prob(:,:,:,:)=squeeze(prod(probch,3))*10^(size(probch,3)/5);  
  %renormalise
  out.posterior_prob=out.posterior_prob./(sum(sum(sum(sum(out.posterior_prob)))));
  
  clear probch

% this returns the actual values of the parameters used (I guess for
% graphing)
alphalabel=inv_logit(i,1);
betalabel=exp(b_label);


% This produces a marginal distribution of the learning rate by summing
% across the other dimensions and then renormalising.
% The numerator sums over dimensions 2 and 3 leaving a 2D matrix which contains
% the marginal likelihood for each of the different value of learning rate, for each
% participant. The denominator calcualtes the total likelihood for each of the subjects
% and then produces a matrix which reproduces these totals in each column
% with alphabins (length(i)) number of rows.
out.marg_alpha_rew=squeeze(sum(sum(sum(out.posterior_prob,3),2),4));

% This generates the expected value of the learning rate using a weighted
% sum-- marginal probabilities multiplied by learning rate values. Note
% for both the learning rate and temperature mean and variance are
% caculated in log space
out.mean_alpha_rew=inv_logit(i*out.marg_alpha_rew,1);

% this calculates the variance of the distribution of learning rates

out.var_alpha_rew=inv_logit(((i-inv_logit(out.mean_alpha_rew)).^2)*out.marg_alpha_rew,1);


out.marg_alpha_loss=squeeze(sum(sum(sum(out.posterior_prob,1),3),4))';

% This generates the expected value of the learning rate using a weighted
% sum-- marginal probabilities multiplied by learning rate values. Note
% for both the learning rate and temperature mean and variance are
% caculated in log space
out.mean_alpha_loss=inv_logit(i*out.marg_alpha_loss,1);

% this calculates the variance of the distribution of learning rates

out.var_alpha_loss=inv_logit(((i-inv_logit(out.mean_alpha_loss)).^2)*out.marg_alpha_loss,1);


%beta reward

    out.marg_beta_rew=squeeze(sum(sum(sum(out.posterior_prob,1),2),4));
    out.mean_beta_rew=exp(b_label*out.marg_beta_rew);
    out.var_beta_rew=exp(((b_label-log(out.mean_beta_rew)).^2)*out.marg_beta_rew);
    
% beta loss
    out.marg_beta_loss=squeeze(sum(sum(sum(out.posterior_prob,1),2),3));
    out.mean_beta_loss=exp(b_label*out.marg_beta_loss);
    out.var_beta_loss=exp(((b_label-log(out.mean_beta_loss)).^2)*out.marg_beta_loss);

out.beta_label=betalabel;
out.lr_label=alphalabel;
out.lr_points=i;
out.beta_points=b_label;



if fig_yes==1 
   figure
   subplot(2,2,1);
   plot(alphalabel,out.marg_alpha_rew);
   title('Learning Rate Reward');
   subplot(2,2,2);
   plot(alphalabel,out.marg_alpha_loss);
   title('Learning Rate Loss');
   subplot(2,2,3);
   plot(betalabel,out.marg_beta_rew);
    title('Reward Beta');
    subplot(2,2,4);
    plot(betalabel,out.marg_beta_loss);
    title('Loss Beta');

   
   
end
% get LL from estimated parameters
bel=rescorla_wagner_2lr(information(:,1:2),[out.mean_alpha_rew out.mean_alpha_loss],start);
out.bel_corr=corr(bel(:,1),bel(:,2));
prob_ch_left=1./(1+exp(-((out.mean_beta_rew.*bel(:,1))-out.mean_beta_loss.*bel(:,2))));
likelihood=prob_ch_left;
likelihood(choice==0)=1-likelihood(choice==0);
out.neg_log_like=-sum(log(likelihood(resp_made)+1e-16));
out.BIC=(2.*out.neg_log_like)+4*(log(sum(resp_made))-log(2*pi)); % BIC given 4 free parameters
out.AIC=(2.*out.neg_log_like)+8;
   