#' Simulated Data Generator and Inferential Comparison
#'
#'Function runs a number of Monte Carlo data sets from one of the models
#'provided by the function dfba_sim_data. For each sample, there is a
#'frequentist t-test as well as a Bayesian test to compute the probability that
#'the population parameter is greater than .5. The proportion of all the samples
#'that detect an effect better than the the stipulated effect_crit value is the
#'power. For the Bayesian analysis, this would be the proportion of samples
#'where the posterior probability that the parameter is greater than .5 is
#'larger than the stipulated effect_crit value. A flat prior is used for all the
#'Bayesian analyses. If the design is equal to "independent", then the Bayesian
#'probability is based on the omega parameter for the Mann-Whitney U statistic.
#'The corresponding t power is based on the two-sample or independent t-test
#'p-value. The t power is the proportion of samples where the p-value is less
#'than 1-effect_crit. The default value for effect_crit is .95, but the user
#'can vary that criterion. If design="paired", then the Bayesian analysis is
#'based on the Bayesian posterior probability that the parameter phi_w for the
#'Wilcoxon signed-rank statistic is greater than .5. The corresponding t power
#'is based on the independent (two-group) t test. See documentation and remarks
#'for the dfba_sim data function for the probability models that can be
#'examined. In each case the delta parameter is an offset value between the E
#'and C variates. If delta is zero, then the Bayesian power should be
#'approximately the value for 1-effect_crit. However, for the t power case, the
#'t-test is a misspecified procedure for the actual data generating model when
#'model is not equal to "normal". Hence is some cases such as with the, Cauchy
#'and Pareto distributions, the t power is less that 1-effect_crit when delta
#'equals zero. The function computes power for 11 different n values that vary
#'from n_min in steps of 5. The power values can be useful in planning an actual
#'experiment. The user can explore any of the nine models for the probability
#'distribution for the two variates to see what sample size is suitable for a
#'stipulated delta value. The nine models are:"normal","weibull", "cauchy",
#'"lognormal", "chisquare", "logistic", "exponential", "gumbel", "pareto".
#'Details about the shape and offset parameters for these distributions are in
#'the remarks for the dfba_sim_data function. The function will generally show
#'that the sample size for normally distributed data for the Bayesian
#'distribution-free procedure is close to the sample size used for the
#'conventional t-test. However,for alternative distributions, the Bayesian
#'nonparametric procedure generally requires a smaller sample size than a
#'parametric t-test.
#'
#' @param n_min smallest desired value of sample size for power calculations
#' @param delta offset variable between variates
#' @param model hypothesized probability density function of data distributions
#' @param design one of "independent" or "paired" to indicate data structure
#' @param effect_crit stipulated critical value for reliable/significant differences
#' @param shape1 First shape parameter for the distribution indicated by `model` input (default is `1`)
#' @param shape2 First shape parameter for the distribution indicated by `model` input (default is `1`)
#' @param samples desired number of Monte Carlo samples
#'
#' @return A list containing the following components:
#' @return \item{outputdf}{A dataframe of possible sample sizes and corresponding Bayesian and Frequentist power values}
#'
#' @references Chechile, R.A. (2020). Bayesian Statistics for Experimental Scientists. Cambridge: MIT Press.
#' @references Chechile, R.A., & Barch, D.H. (2021). Distribution-free, Bayesian goodness-of-fit method for assessing similar scientific prediction equations. Journal of Mathematical Psychology.


#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'


#' @export
#'
dfba_bayes_vs_t_power<-function(n_min=20,
                                delta,
                                model,
                                design,
                                effect_crit=.95,
                                #shape_vec=c(1,1),
                                shape1 = 1,
                                shape2 = 1,
                                samples=1000){

    deltav=delta
    if (delta<0){
      stop("The function requires a nonnegative value for delta.")
    }
    #else {}
#    n=round(n_min)
    if (n_min < 20 | n_min%%1 != 0){
      stop("The function requires n_min to be an integer that is 20 or larger")
    }
    #else {}


    mlist<-c("normal",
             "weibull",
             "cauchy",
             "lognormal",
             "chisquare",
             "logistic",
             "exponential",
             "gumbel",
             "pareto")

    if (!model %in% mlist){
      cat("The set of distributions for model are:"," ","\n")
      print(mlist)
      stop("The stipulated model is not on the list")
      }

    designlist<-c("paired",
                  "independent")
    if (!design %in% designlist){
      cat("The options for experimental design are:"," ","\n")
      print(designlist)
      stop("The stipulated design is not on the list")
      }

    if ((effect_crit<0)|(effect_crit>1)){
      stop("The effect_crit value must be a number nonzero number less than 1.")
      }
#    else {}

#    shape_values<-c(shape_vec[1],shape_vec[2])
    shape_values<-c(shape1,
                    shape2)

    nsims = round(samples)

    mup = n_min + 50
    m = seq(n_min, mup, 5)
#    detect_bayes=seq(1, 11, 1)*0.0
    detect_bayes<-rep(NA, 11)
#    detect_t=seq(1,11,1)*0.0
    detect_t<-rep(NA, 11)
#    outputsim=seq(1,2,1)*0.0
    outputsim<-rep(NA, 2)

#    tpvalue=seq(1,nsims,1)*0.0
    tpvalue<-rep(NA, nsims)
#    bayesprH1=seq(1,nsims,1)*0.0
    bayesprH1<-rep(NA, nsims)

    for (i in 1:11){
      n=m[i]
      for (j in 1:nsims){
        outputsim<-dfba_sim_data(n = n,
                                 model = model,
                                 design = design,
                                 delta = deltav,
                                 shape1 = shape1,
                                 shape2 = shape2)
        bayesprH1[j]=outputsim$prH1
        tpvalue[j]=outputsim$pvalue
        }
      detect_bayes[i]=(sum(bayesprH1>effect_crit))/nsims
      detect_t[i]=(sum(tpvalue<1-effect_crit))/nsims
    }
#    cat("Power results for the proportion of samples detecting effects"," ","\n")
#    cat("where the variates are distributed as a",model,"random variable","\n")
#    cat("and where the design is",design,"\n")
#    cat("The number of Monte Carlo samples are:"," ","\n")
#    cat(nsims," ","\n")
#    cat("Criterion for detecting an effect is"," ","\n")
#    cat(effect_crit," ","\n")
#    cat("The delta offset parameter is:"," ","\n")
#    cat(deltav," ","\n")
#    cat(" ","  ","\n")
    dfba_t_power_list<-list(nsims = nsims,
                            model = model,
                            design = design,
                            effect_crit = effect_crit,
                            deltav = deltav,
                            outputdf=data.frame(sample_size = m,
                                              Bayes_power = detect_bayes,
                                              t_power = detect_t)
    )
    new("dfba_t_power_out", dfba_t_power_list)

  }
