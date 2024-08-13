// 'Simplified': we pretend that the bounded parameters are normally distributed at the group level to make the code easier to understand for now
// we also ignore that we should test for effects within-subject than between-subjects
// and the code is not optimized for running well

// The 'data' block list all input variables that are given to Stan from Matlab. You need to specify the size of the arryas
data {
  int ntr;                    // number of trials per participant "int" means that the values are integers
  int nsub;                 // number of subjects
  int opt1Chosen[ntr,nsub];   // whether option 1 was chosen on each trial, "[ntr,nblk,nsub]" defines the size of the arrya
  int opt1winout[ntr,nsub]; // whether win was associate with opt1 on the trial or not
  int opt1lossout[ntr,nsub]; // whether loss was associate with opt1 on the trial or not
  int includeTrial[ntr,nsub];      // whether the data from this trial should be fitted (we exclude the first 10 trials per block)
}

// The 'parameters' block defines the parameter that we want to fit
parameters {
  // Single subject parameters (transformed)
  real alpha_tr[4,nsub]; // learning rate - separate learning rates for wins and losses; two per participant
  real beta_tr[nsub];    // inverse temperature - ; two per participant
}

// We can also compute the difference between the two learning rates directly in Stan:
transformed parameters{
  real<lower=0,upper=1> alpha[4,nsub];
  real<lower=0> beta[nsub];
  // transform the single-subject parameters
  for (is in 1:nsub){
    alpha[1,is] = inv_logit(alpha_tr[1,is]);
    alpha[2,is] = inv_logit(alpha_tr[2,is]);
    alpha[3,is] = inv_logit(alpha_tr[3,is]);
    alpha[4,is] = inv_logit(alpha_tr[4,is]);
    beta[is] = exp(beta_tr[is]);
  }
}

// This block runs the actual model
model {
  // temporary variables that we will compute for each person and each trial
  real winpredictionOpt1[ntr,nsub];  //prediction how likely option 1 is associated with a win
  real losspredictionOpt1[ntr,nsub];  //prediction how likely option 1 is associated with a loss
  real winpredictionError[ntr,nsub];// prediction error
  real losspredictionError[ntr,nsub];// prediction error
  real WinEstProb1[ntr,nsub];        // utility of option 1
  real LossEstProb1[ntr,nsub];        // utility of option 2

  // Priors for the individual subjects are the group:
  for (is in 1:nsub){
    alpha_tr[1,is] ~ normal(0,1);
    alpha_tr[2,is] ~ normal(0,1);
    alpha_tr[3,is] ~ normal(0,1);
    alpha_tr[4,is] ~ normal(0,1);
    beta_tr[is]  ~ normal(0,1.5);
  }

 // running the model is as before:
  for (is in 1:nsub){ // run the model for each subject
    // Learning
    winpredictionOpt1[1,is] = 0.5; // on the first trial, 50-50 is the best guess
    losspredictionOpt1[1,is] = 0.5; // on the first trial, 50-50 is the best guess
    for (it in 1:(ntr-1)){
     if (opt1winout[it,is] == opt1Chosen[it,is]){
      winpredictionError[it,is]  = opt1winout[it,is]-winpredictionOpt1[it,is];
      winpredictionOpt1[it+1,is] = winpredictionOpt1[it,is] + alpha[1,is]*(winpredictionError[it,is]);
     }
     else
     {
      winpredictionError[it,is]  = opt1winout[it,is]-winpredictionOpt1[it,is];
      winpredictionOpt1[it+1,is] = winpredictionOpt1[it,is] + alpha[2,is]*(winpredictionError[it,is]);
     }
     
     if (opt1lossout[it,is] == opt1Chosen[it,is]){
      losspredictionError[it,is]  = opt1lossout[it,is]-losspredictionOpt1[it,is];
      losspredictionOpt1[it+1,is] = losspredictionOpt1[it,is] + alpha[4,is]*(losspredictionError[it,is]);
      }
      else
      {
      losspredictionError[it,is]  = opt1lossout[it,is]-losspredictionOpt1[it,is];
      losspredictionOpt1[it+1,is] = losspredictionOpt1[it,is] + alpha[3,is]*(losspredictionError[it,is]);
      }
    }
    // Decision - combine predictions of reward probability with magnitudes
    for (it in 1:ntr){
      if (includeTrial[it,is]==1){ // if there is no missing response
        // Utility
        WinEstProb1[it,is] = winpredictionOpt1[it,is]*beta[is];     // option 1: probability x magnitude
        LossEstProb1[it,is] = losspredictionOpt1[it,is]*beta[is]; // option 2: probability x magnitude

        // Compare the choice probability (based on the utility) to the actual choice
        // See the handout for the syntax of the bernoulli_logit function
        // equivalently we could have written (as we have done previously in Matlab; but this runs a bit less well in Stan).:
        // ChoiceProbability1[it,is] = 1/(1+exp(beta[is]*(util2[it,is]-util1[it,is]))); // the softmax is an 'inv_logit'
        // opt1Chosen[it,is] ~ bernoulli(ChoiceProbability1[it,is]);
        opt1Chosen[it,is] ~ bernoulli_logit(WinEstProb1[it,is]-LossEstProb1[it,is]); // bernoulli is a distribution in the way as e.g. the 'normal distribution'
      }
    }
  }
}
