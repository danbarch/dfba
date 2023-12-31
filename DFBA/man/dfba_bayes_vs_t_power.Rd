% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dfba_bayes_vs_t_power.R
\name{dfba_bayes_vs_t_power}
\alias{dfba_bayes_vs_t_power}
\title{Simulated Data Generator and Inferential Comparison}
\usage{
dfba_bayes_vs_t_power(
  n_min = 20,
  delta,
  model,
  design,
  effect_crit = 0.95,
  shape1 = 1,
  shape2 = 1,
  samples = 1000
)
}
\arguments{
\item{n_min}{smallest desired value of sample size for power calculations}

\item{delta}{offset variable between variates}

\item{model}{hypothesized probability density function of data distributions}

\item{design}{one of "independent" or "paired" to indicate data structure}

\item{effect_crit}{stipulated critical value for reliable/significant differences}

\item{shape1}{First shape parameter for the distribution indicated by `model` input (default is `1`)}

\item{shape2}{First shape parameter for the distribution indicated by `model` input (default is `1`)}

\item{samples}{desired number of Monte Carlo samples}
}
\value{
A list containing the following components:

\item{outputdf}{A dataframe of possible sample sizes and corresponding Bayesian and Frequentist power values}
}
\description{
Function runs a number of Monte Carlo data sets from one of the models
provided by the function dfba_sim_data. For each sample, there is a
frequentist t-test as well as a Bayesian test to compute the probability that
the population parameter is greater than .5. The proportion of all the samples
that detect an effect better than the the stipulated effect_crit value is the
power. For the Bayesian analysis, this would be the proportion of samples
where the posterior probability that the parameter is greater than .5 is
larger than the stipulated effect_crit value. A flat prior is used for all the
Bayesian analyses. If the design is equal to "independent", then the Bayesian
probability is based on the omega parameter for the Mann-Whitney U statistic.
The corresponding t power is based on the two-sample or independent t-test
p-value. The t power is the proportion of samples where the p-value is less
than 1-effect_crit. The default value for effect_crit is .95, but the user
can vary that criterion. If design="paired", then the Bayesian analysis is
based on the Bayesian posterior probability that the parameter phi_w for the
Wilcoxon signed-rank statistic is greater than .5. The corresponding t power
is based on the independent (two-group) t test. See documentation and remarks
for the dfba_sim data function for the probability models that can be
examined. In each case the delta parameter is an offset value between the E
and C variates. If delta is zero, then the Bayesian power should be
approximately the value for 1-effect_crit. However, for the t power case, the
t-test is a misspecified procedure for the actual data generating model when
model is not equal to "normal". Hence is some cases such as with the, Cauchy
and Pareto distributions, the t power is less that 1-effect_crit when delta
equals zero. The function computes power for 11 different n values that vary
from n_min in steps of 5. The power values can be useful in planning an actual
experiment. The user can explore any of the nine models for the probability
distribution for the two variates to see what sample size is suitable for a
stipulated delta value. The nine models are:"normal","weibull", "cauchy",
"lognormal", "chisquare", "logistic", "exponential", "gumbel", "pareto".
Details about the shape and offset parameters for these distributions are in
the remarks for the dfba_sim_data function. The function will generally show
that the sample size for normally distributed data for the Bayesian
distribution-free procedure is close to the sample size used for the
conventional t-test. However,for alternative distributions, the Bayesian
nonparametric procedure generally requires a smaller sample size than a
parametric t-test.
}
\references{
Chechile, R.A. (2020). Bayesian Statistics for Experimental Scientists. Cambridge: MIT Press.

Chechile, R.A., & Barch, D.H. (2021). Distribution-free, Bayesian goodness-of-fit method for assessing similar scientific prediction equations. Journal of Mathematical Psychology.
}
