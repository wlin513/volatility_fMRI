
data {
  int ntr;                    // number of trials per participant "int" means that the values are integers
  int nsub;                 // number of subjects
  int nblk;
  int opt1Chosen[ntr,nblk,nsub];   // whether option 1 was chosen on each trial, "[ntr,nblk,nblk,nsub]" defines the size of the arrya
  int opt1winout[ntr,nblk,nsub]; // whether win was associate with opt1 on the trial or not
  int opt1lossout[ntr,nblk,nsub]; // whether loss was associate with opt1 on the trial or not
  int includeTrial[ntr,nblk,nsub];      // whether the data from this trial should be fitted (we exclude the first 10 trials per block)
}

// The 'parameters' block defines the parameter that we want to fit
parameters {
  // Single subject parameters (transformed)
  real alpha_sta_loss_neg_tr[nsub]; // learning rate for loss stable; one per participant shared between similiar schedules
  real beta_tr[nblk,nsub];    // inverse temperature - ; one for each block per participant 
  real VS_bias_tr[nsub]; //difference of alphas for volatile vs. stable schedules; one for each participant
  real WL_bias_tr[nsub]; //difference of alphas for win  vs. loss schedules; one for each participant
  real PN_bias_tr[nsub]; //difference of alphas for positive  vs. negtive prediction errors; one for each participant
  real invx_tr[nsub]; //interaction term parameter in the difference of volatile - semi volatile alpha and semi-stable - stable

}

//
transformed parameters{
  real<lower=0,upper=1> alpha[4,nblk,nsub];// the 4 alphas are win_positive, win_negative, loss_positive, loss_negative;
  real<lower=0> beta[nblk,nsub];
  real alpha_tr[4,nblk,nsub];
  // transform the single-subject parameters
  for (is in 1:nsub){
    
    alpha_tr[4,4,is] = alpha_sta_loss_neg_tr[is];
    alpha_tr[4,3,is] = alpha_tr[4,4,is]+VS_bias_tr[is] - invx_tr[is];
    alpha_tr[4,2,is] = alpha_tr[4,4,is]+invx_tr[is];
    alpha_tr[4,1,is] = alpha_tr[4,4,is]+VS_bias_tr[is];
    
    alpha_tr[2,4,is] = alpha_tr[4,4,is]+WL_bias_tr[is];
    alpha_tr[2,3,is] = alpha_tr[2,4,is]+invx_tr[is];
    alpha_tr[2,2,is] = alpha_tr[2,4,is]+VS_bias_tr[is] - invx_tr[is];
    alpha_tr[2,1,is] = alpha_tr[2,4,is]+VS_bias_tr[is];
    
    for (iblk in 1:nblk){
    alpha_tr[3,iblk,is] = alpha_tr[4,iblk,is]+PN_bias_tr[is];
    alpha_tr[1,iblk,is] = alpha_tr[2,iblk,is]+PN_bias_tr[is];

    beta[iblk,is] = exp(beta_tr[iblk,is]);
    }
    for (nalpha in 1:4){
      for (iblk in 1:nblk){
        alpha[nalpha,iblk,is]=inv_logit(alpha_tr[nalpha,iblk,is]);
      }
    }
  }
}

// This block runs the actual model
model {
  // temporary variables that we will compute for each person and each trial
  real winpredictionOpt1[ntr,nblk,nsub];  //prediction how likely option 1 is associated with a win
  real losspredictionOpt1[ntr,nblk,nsub];  //prediction how likely option 1 is associated with a loss
  real winpredictionError[ntr,nblk,nsub];// prediction error
  real losspredictionError[ntr,nblk,nsub];// prediction error
  real WinEstProb1[ntr,nblk,nsub];        // utility of option 1
  real LossEstProb1[ntr,nblk,nsub];        // utility of option 2

  // Priors for the individual subjects are the group:
  for (is in 1:nsub){
   alpha_sta_loss_neg_tr[is] ~ normal(0,1);
   VS_bias_tr[is] ~ normal(0,1);
   WL_bias_tr[is] ~ normal(0,1);
   PN_bias_tr[is] ~ normal(0,1);
   invx_tr[is] ~ normal(0,1);
    for (iblk in 1:nblk){
    beta_tr[iblk,is]  ~ normal(0,1.5);
    }
  }

 // running the model is as before:
  for (is in 1:nsub){ // run the model for each subject
   for (iblk in 1:nblk){
    // Learning
    winpredictionOpt1[1,iblk,is] = 0.5; // on the first trial, 50-50 is the best guess
    losspredictionOpt1[1,iblk,is] = 0.5; // on the first trial, 50-50 is the best guess
    for (it in 1:(ntr-1)){
           if (opt1winout[it,iblk,is] == opt1Chosen[it,iblk,is]){
      winpredictionError[it,iblk,is]  = opt1winout[it,iblk,is]-winpredictionOpt1[it,iblk,is];
      winpredictionOpt1[it+1,iblk,is] = winpredictionOpt1[it,iblk,is] + alpha[1,iblk,is]*(winpredictionError[it,iblk,is]);
           }
           else {
      winpredictionError[it,iblk,is]  = opt1winout[it,iblk,is]-winpredictionOpt1[it,iblk,is];
      winpredictionOpt1[it+1,iblk,is] = winpredictionOpt1[it,iblk,is] + alpha[2,iblk,is]*(winpredictionError[it,iblk,is]); 
           }

           if (opt1lossout[it,iblk,is] == opt1Chosen[it,iblk,is]){
      losspredictionError[it,iblk,is]  = opt1lossout[it,iblk,is]-losspredictionOpt1[it,iblk,is];
      losspredictionOpt1[it+1,iblk,is] = losspredictionOpt1[it,iblk,is] + alpha[4,iblk,is]*(losspredictionError[it,iblk,is]);
           }
           else {
      losspredictionError[it,iblk,is]  = opt1lossout[it,iblk,is]-losspredictionOpt1[it,iblk,is];
      losspredictionOpt1[it+1,iblk,is] = losspredictionOpt1[it,iblk,is] + alpha[3,iblk,is]*(losspredictionError[it,iblk,is]);
           }
    }
    // Decision - combine predictions of reward probability with magnitudes
    for (it in 2:ntr){
      if (includeTrial[it,iblk,is]==1){ // if there is no missing response
        // Utility
        WinEstProb1[it,iblk,is] = winpredictionOpt1[it,iblk,is]*beta[iblk,is];     // option 1: probability x magnitude
        LossEstProb1[it,iblk,is] = losspredictionOpt1[it,iblk,is]*beta[iblk,is]; // option 2: probability x magnitude

        // Compare the choice probability (based on the utility) to the actual choice
        // See the handout for the syntax of the bernoulli_logit function
        // equivalently we could have written (as we have done previously in Matlab; but this runs a bit less well in Stan).:
        // ChoiceProbability1[it,iblk,is] = 1/(1+exp(beta[is]*(util2[it,iblk,is]-util1[it,iblk,is]))); // the softmax is an 'inv_logit'
        // opt1Chosen[it,iblk,is] ~ bernoulli(ChoiceProbability1[it,iblk,is]);
        opt1Chosen[it,iblk,is] ~ bernoulli_logit(WinEstProb1[it,iblk,is]-LossEstProb1[it,iblk,is]); // bernoulli is a distribution in the way as e.g. the 'normal distribution'
       }
      }
    }
  }
}
