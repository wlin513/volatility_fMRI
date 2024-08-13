
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
  real alpha_sta_win_tr[2,nsub]; // learning rate for win stable; one per participant shared between similiar schedules
  real alpha_sta_loss_tr[2,nsub]; // learning rate for loss stable; one per participant shared between similiar schedules
  real beta_tr[nsub];    // inverse temperature - ; one per participant 
  real win_vol_adpt_tr[2,nsub]; //difference of alphas for volatile vs. stable for win schedules; one for each participant
  real loss_vol_adpt_tr[2,nsub]; //difference of alphas for volatile vs. stable for loss schedules; one for each participant
}

//
transformed parameters{
  real<lower=0,upper=1> alpha[2,nblk,nsub];// win and loss alphas for each block;
  real<lower=0> beta[nsub];
  // transform the single-subject parameters
  for (is in 1:nsub){
    
    alpha[1,4,is] = Phi_approx(alpha_sta_win_tr[1,is]);
    alpha[1,3,is] = Phi_approx(alpha_sta_win_tr[2,is]);
    alpha[1,2,is] = Phi_approx(alpha_sta_win_tr[1,is]+win_vol_adpt_tr[1,is]);
    alpha[1,1,is] = Phi_approx(alpha_sta_win_tr[2,is]+win_vol_adpt_tr[2,is]);
    
    alpha[2,4,is] = Phi_approx(alpha_sta_loss_tr[1,is]);
    alpha[2,3,is] = Phi_approx(alpha_sta_loss_tr[1,is]+loss_vol_adpt_tr[1,is]);
    alpha[2,2,is] = Phi_approx(alpha_sta_loss_tr[2,is]);
    alpha[2,1,is] = Phi_approx(alpha_sta_loss_tr[2,is]+loss_vol_adpt_tr[2,is]);
    
    beta[is] = exp(beta_tr[is]);
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
   alpha_sta_win_tr[1,is] ~ normal(0,2);
   alpha_sta_loss_tr[1,is] ~ normal(0,2);
   alpha_sta_win_tr[2,is] ~ normal(0,2);
   alpha_sta_loss_tr[2,is] ~ normal(0,2);
   win_vol_adpt_tr[1,is] ~ normal(0,2);
   loss_vol_adpt_tr[1,is] ~ normal(0,2);
   win_vol_adpt_tr[2,is] ~ normal(0,2);
   loss_vol_adpt_tr[2,is] ~ normal(0,2);
   beta_tr[is]  ~ normal(0,5);
  }

 // running the model is as before:
  for (is in 1:nsub){ // run the model for each subject
   for (iblk in 1:nblk){
    // Learning
    winpredictionOpt1[1,iblk,is] = 0.5; // on the first trial, 50-50 is the best guess
    losspredictionOpt1[1,iblk,is] = 0.5; // on the first trial, 50-50 is the best guess
    for (it in 1:(ntr-1)){

      winpredictionError[it,iblk,is]  = opt1winout[it,iblk,is]-winpredictionOpt1[it,iblk,is];
      winpredictionOpt1[it+1,iblk,is] = winpredictionOpt1[it,iblk,is] + alpha[1,iblk,is]*(winpredictionError[it,iblk,is]); 

      losspredictionError[it,iblk,is]  = opt1lossout[it,iblk,is]-losspredictionOpt1[it,iblk,is];
      losspredictionOpt1[it+1,iblk,is] = losspredictionOpt1[it,iblk,is] + alpha[2,iblk,is]*(losspredictionError[it,iblk,is]);

    }
    // Decision - combine predictions of reward probability with magnitudes
    for (it in 2:ntr){
      if (includeTrial[it,iblk,is]==1){ // if there is no missing response
        // Utility
        WinEstProb1[it,iblk,is] = winpredictionOpt1[it,iblk,is]*beta[is];     // option 1: probability x magnitude
        LossEstProb1[it,iblk,is] = losspredictionOpt1[it,iblk,is]*beta[is]; // option 2: probability x magnitude

        // Compare the choice probability (based on the utility) to the actual choice
        // See the handout for the syntax of the bernoulli_logit function
        // equivalently we could have written (as we have done previously in Matlab; but this runs a bit less well in Stan).:
        // ChoiceProbability1[it,iblk,is] = 1/(1+exp(beta[is]*(util2[it,iblk,is]-util1[it,iblk,is]))); // the softmax is an 'Phi_approx'
        // opt1Chosen[it,iblk,is] ~ bernoulli(ChoiceProbability1[it,iblk,is]);
        opt1Chosen[it,iblk,is] ~ bernoulli_logit(WinEstProb1[it,iblk,is]-LossEstProb1[it,iblk,is]); // bernoulli is a distribution in the way as e.g. the 'normal distribution'
       }
      }
    }
  }
}
