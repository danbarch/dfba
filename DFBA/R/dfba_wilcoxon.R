#' Repeated-Measures Test (Wilcoxon Signed-Ranks Test)
#'
#' Wilcoxon signed rank statistic is based on paired continuous measures Y1 and
#' Y2. prior_vec has two components that are the shape parameters of the prior
#' beta distribution. The default prior is the uniform prior, but the user can
#' stipulate with the components of prior_vec, the desired prior distribution.
#' The prob_interval is value for the probability interval estimates. Samples
#' is the number of Monte Carlo samples used for the small n analysis. The
#' method option is either "small" or "large". The "small" algorithm is based
#' on a discrete Monte Carlo solution for cases where n is typically less than
#' 25. The "large" algorithm is based on beta approximation model for the
#' posterior distribution for the phi_w parameter. This approximation is
#' reasonable when n > 24. Regardless of n, the user can stipulate which method
#' that they desire. When the method option, is omitted the program selects the
#' appropriate procedure.
#'
#' @param Y1 Numeric vector of data values representing one repeated measure
#' @param Y2 Numeric vector of data values representing a repeated measure additional to `Y1`
#' @param a0 shape parameter alpha of the prior beta distribution
#' @param b0 shape parameter beta of the prior beta distribution
#' @param prob_interval Desired width of the highest density interval (HDI) of the posterior distribution (default is 95\%)
#' @param samples The number of desired Markov-Chain samples (default is 30000)
#' @param method (Optional) The method option is either "small" or "large". The "small" algorithm is based on a discrete Monte Carlo solution for cases where n is typically less than 20. The "large" algorithm is based on beta approximation model for the posterior distribution for the omega_E parameter. This approximation is reasonable when n > 19. Regardless of n the user can stipulate which method that they desire. When the method option is  omitted the program selects the appropriate procedure.
#'
#' @return A list containing the following components:
#' @return \item{T_plus}{Sum of the positive ranks in the pairwise comparisons}
#' @return \item{T_negative}{Sum of the negative ranks in the pairwise comparisons}

#'
#' @references Chechile, R.A. (2020). Bayesian Statistics for Experimental Scientists. Cambridge: MIT Press.
#'

#' @export
dfba_wilcoxon<-function(Y1,
                        Y2,
                        a0 = 1,
                        b0 = 1,
#                        prior_vec=c(1,1),
                        prob_interval=.95,
                        samples=30000,
                        method=NULL){
  l1=length(Y1)
  l2=length(Y2)
  if (l1!=l2) {
    stop("Y1 and Y2 must have the same length. This function is for paired within-block data.")} else {}

#  if (length(prior_vec)!=2){
#    stop("an explicit stipulation of prior_vec must only have the two shape parameters for the prior beta distribution")} else {}

#  a0<-prior_vec[1]
#  b0<-prior_vec[2]

  if ((a0<=0)|(b0<=0)){
    stop("Both of the beta shape parameters must be >0.")}
#  else {}

  if ((prob_interval<0)|(prob_interval>1)){
    stop("The probability for the interval estimate of phi_w must be a proper proportion.")}
#  else {}

  if (samples<10000){
    stop("stipulating Monte Carlo samples < 10000 is too small")} else {}

  #Following code checks for NA values and cleans the difference scores
  Etemp=Y1
  Ctemp=Y2
  d=Y1-Y2
  dtemp=d
  jc=0
  for (j in 1:length(Y1)){
    if (is.na(dtemp[j])){} else {
      jc=jc+1
      Y1[jc]=Etemp[j]
      Y2[jc]=Ctemp[j]
      d[jc]=dtemp[j]}
  }
  Y1=Y1[1:jc]
  Y2=Y2[1:jc]
  d=d[1:jc]
  l1=jc

  if (l1<3){
    stop("There are not enough values in the Y1 and Y2 vectors for meaningful results.")}
  #else {}

  #The following code computes the within-block difference scores, and finds the
  #number of blocks where the difference scores are nonzero (within a trivial rounding error).
  sdd=sd(d)
  IC=0
  for (I in 1:l1){
    if (abs(d[I])<=sdd/30000){IC=IC} else {IC=IC+1}}
  n=IC
  #The following code deals with the case where all differences are trivially close to 0.
  if (n==0){stop("Y1 and Y2 differences are all trivial")}
  #else {}

  #The following finds the Tplus and Tminus stats and the number of nonzero blocks
  dt=(seq(1,n,1))*0
  IC=0
  for (I in 1:l1){
    if (abs(d[I])<=sdd/30000){IC=IC} else {
      IC=IC+1
      dt[IC]=d[I]}}
  dta=(seq(1,n,1))*0
  for (I in 1:n){
    dta[I]=abs(dt[I])}
  #The vector dtar is for the ranks of the absolute-value d scores; whereas
  #the dta vector is for the absolute-value of the d scores, and dtars is
  #the vector of signed rank scores.
  dtar=rank(dta)
  dtars=dtar*dt/dta
  #The following computes the Tplus and Tminus statistics
  tplus=0
  for (I in 1:n){
    if (dtars[I]>0){tplus=tplus+dtar[I]
    } else {tplus=tplus}
  }
  tplus=round(tplus)
  tneg=(n*(n+1)*.5)-tplus
#  cat("The Wilcoxon signed-rank statistics are:"," ","\n")
#  cat("n","  ","T_plus","  ","T_negative","\n")
#  cat(n,"  ",tplus,"      ",tneg,"\n")

  if (is.null(method)){
    if (n>24){method="large"} else {
      method="small"}
  }
  #else {}

  if (method=="small"){
 #   m1lable<-"Following is based on Monte Carlo samples"
 #   m2lable<-" with discrete prob. values."
 #   cat(m1lable,m2lable,"\n")
 #  cat("The number of Monte Carlo samples is:"," ","\n")
 #  cat(samples," ","\n")
 #  cat(" ","   ","\n")

    #Code for the discrete prior
    phiv=seq(1/400,.9975,.005)
    x=phiv+.0025
    priorvector=rep(0,200)
    priorvector[1]=pbeta(x[1],a0,b0)
    for (i in 2:200){
      priorvector[i]=pbeta(x[i],a0,b0)-pbeta(x[i-1],a0,b0)}



    fphi<-rep(0.0,200)
    for (j in 1:200){
      phi=1/(400)+(j-1)*(1/200)
      for (k in 1:samples){
        tz=sum((1:n)*rbinom(n, 1, phi))

        if(tz==tplus) {
          fphi[j]=fphi[j]+1.0
        } else{
          fphi[j]=fphi[j]
        }
      }
    }
    #The tot value below is the denominator of the discrete analysis,
    #phipost is the vector for the posterior distribution.
    tot=sum(priorvector*fphi)
    phipost=(priorvector*fphi)/tot
    phiv=rep(0.0,200)
    phibar=0.0
    for (j in 1:200){
      phiv[j]=(1/400)+(j-1)*(1/200)
      phibar=phibar+(phiv[j]*phipost[j])}

    plot(phiv,phipost,type="l",xlab="phi_w",ylab="posterior discrete probabilities",main="posterior-solid; prior-dashed")
    lines(phiv,priorvector,type="l",lty=2)

#    cat("mean for phi_w is:"," ","\n")
#    cat(phibar," ","\n")

    postdis<-data.frame(phiv,phipost)


    #The following finds the posterior cumulative distribution and outputs these values.
    cum_phi=cumsum(phipost)

    I=1
    while (cum_phi[I]<(1-prob_interval)/2){
      I=I+1}
    qLbelow=phiv[I]-.0025

    if (I!=1){
      extrap=(1-prob_interval)/2-cum_phi[I-1]
      probI=cum_phi[I]-cum_phi[I-1]} else {
        extrap=(1-prob_interval)/2
        probI=cum_phi[1]}
    qLv=qLbelow+(.005)*(extrap/probI)

    I=1
    while (cum_phi[I]<1-(1-prob_interval)/2){
      I=I+1}
    qHbelow=phiv[I]-.0025
    extrapup=1-((1-prob_interval)/2)-cum_phi[I-1]
    probIu=cum_phi[I]-cum_phi[I-1]
    qHv=qHbelow+(.005)*(extrapup/probIu)
#    cat(" ","  ","\n")
#    cat("equal-tail area interval"," ","\n")
#    probpercent=100*prob_interval
#    mi=as.character(probpercent)
#    cat(mi,"percent interval limits are:","\n")
#    cat(qLv," ",qHv,"\n")
#    cat(" ","  ","\n")

#    phi_w=phiv
#    cumdis<-data.frame(phi_w,cum_phi)
    #The prH1 is the probability that phi_w is greater than .5.


    prH1=1-cum_phi[round(100)]
    cum_prior=cumsum(priorvector)
    priorprH1=1-cum_prior[round(100)]
#    cat("probability that phi_w exceeds .5 is:"," ","\n")
#    cat("prior","  ","posterior","\n")
#    cat(priorprH1,"  ",prH1,"\n")
#    cat(" ","  ","\n")

    #Following finds the Bayes factor for phi_w being greater than .5.

    if ((prH1==1)|(priorprH1==0)){
      BF10=samples
#      cat("Bayes factor BF10 for phi_w >.5 is estimated to be greater than",":","\n")
#      cat(BF10," ","\n")
      }
      else {
        BF10=(prH1*(1-priorprH1))/(priorprH1*(1-prH1))
#        cat("Bayes factor BF10 for phi_w>.5 is",":","\n")
#        cat(BF10," ","\n")
        }
    #list(posterior_discrete_values=phipost,posterior_cum_distribution=cumdis)
#    return(cat(" ","  ","\n"))


  dfba_wilcoxon_small_list<-list(T_plus=tplus,
                                 T_negative=tneg,
                                 n = n,
                                 prob_interval = prob_interval,
                                 samples = samples,
                                 method = method,
                      #           phi_w = phi_w,
                                 a0 = a0,
                                 b0 = b0,
                                 phipost = phipost,
                      #           priorvector = priorvector,
                                 priorprH1 = priorprH1,
                                 phiv = phiv,
                                 phipost = phipost,
                                 prH1 = prH1,
                                 BF10 = ifelse((prH1==1)|(priorprH1==0),
                                               paste0("Bayes factor BF10 for omega_E >.5 is estimated to be greater than: ", samples),
                                               BF10),
                                 phibar = phibar,
                                 qLv = qLv,
                                 qHv = qHv)
  } else {
    # method="large"
#    m1L<-"Following is based on beta approximation for phi_w"
#    m2L<-"which is reasonable for n>24"
#    cat(m1L,m2L,"\n")
#    cat(" ","   ","\n")

    #The following code finds the shape parameters of a beta
    #distribution that approximates the posterior distribution
    #for the phi_w parameter
    na0=a0-1
    nb0=b0-1
    term=(3*tplus)/((2*n)+2)
    na=term-.25
    nb=(((3*n)-1)/4)-term
    apost=na+na0+1
    bpost=nb+nb0+1
#    x=seq(0,1,.005)
#    y=dbeta(x,a,b)
#    y0=dbeta(x,a0,b0)
#    plot(x,y,type="l",xlab="phi_w",ylab="probability density",main="posterior solid; prior dashed")
#    lines(x,y0,type="l",lty=2)

    postmean=apost/(apost+bpost)
    postmedian=qbeta(.5,apost,bpost)
#    ms1="posterior beta model shape parameters are:"
#    ms2=" "
#    cat(ms1,ms2,"\n")
#    cat(a,"  ",b,"\n")
#    cat("  ","   ","\n")
    ##ASK RICH:
    ## why not apost and bpost (like the M-W)?

#    mc1="posterior mean"
#    mc2="posterior median"
#    cat(mc1,"  ",mc2,"\n")
#    cat(postmean,"       ",postmedian,"\n")
#    cat(" ","  ","\n")

    qlequal=qbeta((1-prob_interval)*.5,apost,bpost)
    qhequal=qbeta(1-(1-prob_interval)*.5,apost,bpost)

#    met1="equal-tail limit values are"
#    met2=":"
#    cat(met1,met2,"\n")
#    cat(qlequal," ",qhequal,"\n")
#    cat(" ","  ","\n")

    alphaL=seq(0,(1-prob_interval),(1-prob_interval)/1000)
    qL=qbeta(alphaL,apost,bpost)
    qH=qbeta(prob_interval+alphaL,apost,bpost)
    diff=qH-qL
    I=1
    mindiff=min(diff)
    while (diff[I]>mindiff){
      I=I+1}
    qLmin=qL[I]
    qHmax=qH[I]
    probpercent=100*prob_interval
#    mi=as.character(probpercent)
#    cat(mi,"percent highest-density limits are:","\n")
#    cat(qLmin," ",qHmax,"\n")
#    cat(" ","  ","\n")

    prH1=1-pbeta(.5,apost,bpost)
    priorprH1=1-pbeta(.5,na0+1,nb0+1)
#    mH11="probability that phi_w > .5"
#    mH12=" "
#    cat(mH11,mH12,"\n")
#    mH1prior="prior"
#    mH1post="posterior"
#    cat(mH1prior,"  ",mH1post,"\n")
#    cat(priorprH1,"  ",prH1,"\n")
#    cat(" ","  ","\n")
    if ((prH1==1)|(priorprH1==0)){
      BF10 = Inf

#      minf1="Bayes factor BF10 for phi_w >.5 is approaching"
#      minf2="infinity"
#      cat(minf1,minf2,"\n")
      } else {
        BF10=(prH1*(1-priorprH1))/(priorprH1*(1-prH1))
#        mBF1="Bayes factor BF10 for phi_w > .5"
#        mBF2="is"
#        cat(mBF1,mBF2,"\n")
#        cat(BF10)
        }


#    cat(" ","   ","\n")
#    m1X=" "
#    m2X=" "
#    return(cat(m1X,m2X,"\n"))
  dfba_wilcoxon_large_list<-list(T_plus=tplus,
                                 T_negative=tneg,
                                 n = n,
                                 prob_interval = prob_interval,
                                 samples = samples,
                                 method = method,
                                 a0 = a0,
                                 b0 = b0,
                                 apost = apost,
                                 bpost = bpost,
                                 postmean = postmean,
                                 postmedian = postmedian,
         #                        phipost = phipost,
        #                         priorvector = priorvector,
         #                        priorprH1 = priorprH1,
        # Vector data is based on the beta: should we
        # report that in the output?
                                 priorprH1=priorprH1,
                                 prH1 = prH1,
                                 BF10 = ifelse((prH1==1)|(priorprH1==0),
                                               paste0("estimated to be greater than ", samples),
                                               BF10),
            #                     phibar = phibar,
                                 qlequal = qlequal,
                                 qhequal = qhequal,
                                 qLmin = qLmin,
                                 qHmax = qHmax)
    }
  #else {}

  if ((method!="large")&(method!="small")) {
    stop("An explicit method stipulation must be either the word large or small.")
  }
  #else {}
  if(method == "small"){
    new("dfba_wilcoxon_small_out", dfba_wilcoxon_small_list)
  } else {
    new("dfba_wilcoxon_large_out", dfba_wilcoxon_large_list)
  }
}

