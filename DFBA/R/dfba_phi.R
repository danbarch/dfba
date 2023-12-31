#' Concordance Parameter Phi
#'
#' This function takes two vectors and shape parameters (a and b) for the prior
#' beta distribution (defaults are [1,1])
#' @param x vector of x variable values
#' @param y vector of y variable values
#' @param a.prior shape parameter a of the prior beta distribution
#' @param b.prior shape parameter b of the prior beta distribution
#' @param interval.width Desired width of the highest density interval (HDI) of the posterior distribution (default is 95\%)
#' @param fitting.parameters (Optional) If either x or y values are generated by a predictive model, the number of free parameters in the model
#'
#' @return A list containing the following components:
#' @return \item{Tau}{Nonparametric Tau-a correlation}
#' @return \item{sample_p}{Sample concordance proportion}
#' @return \item{nc}{Number of concordant (x, y) pairs}
#' @return \item{nd}{Number of discordant (x, y) pairs}
#' @return \item{post.median}{Median of posterior distribution on phi}
#' @return \item{post.eti.lower}{lower limit of the equal-tail interval with width specified by interval.width}
#' @return \item{post.eti.upper}{upper limit of the equal-tail interval with width specified by interval.width}
#'
#' @references Chechile, R.A. (2020). Bayesian Statistics for Experimental Scientists. Cambridge: MIT Press.
#' @references Chechile, R.A., & Barch, D.H. (2021). Distribution-free, Bayesian goodness-of-fit method for assessing similar scientific prediction equations. Journal of Mathematical Psychology.

#' @importFrom stats qbeta
#' @importFrom stats complete.cases
#'
#' @export
dfba_phi<-function(x,
                   y,
                   a.prior=1,
                   b.prior=1,
                   interval.width=0.95,
                   fitting.parameters=NULL){
  xy_input<-data.frame(x,y)                         #append x and y vectors
  xy<-xy_input[complete.cases(xy_input),]           #keep only rows with valid x and y values
  removed_rows<-nrow(xy_input)-nrow(xy)             #count removed rows
  if (removed_rows>0){                              #warning message if rows are removed
    warning(paste0(removed_rows, " row(s) removed due to missing data"))
  }

  #Replace x and y vectors with complete-case-restricted data

  x1<-xy$x
  y1<-xy$y

  t_xi<-unname(table(x1)[table(x1)>1])                #Counting T_x sizes of ties
  t_yi<-unname(table(y1)[table(y1)>1])                #Counting T_y sizes of ties
  Tx<-sum((t_xi*(t_xi-1))/2)                        #Calculating Tx
  Ty<-sum((t_yi*(t_yi-1))/2)                        #Calculating Ty
  t_xyi<-unname(table(xy)[table(xy)>1])             #Calculating txyi
  Txy<-sum(t_xyi*(t_xyi-1)/2)                       #Calculating Txy
  n<-length(x1)
  n_max<-n*(n-1)/2-Tx-Ty+Txy
  xy_ranks<-data.frame(xrank=rank(x1, ties.method="average"),
                       yrank=rank(y1, ties.method="average"))
  xy_c<-xy_ranks[order(x1, -y1),]       # for n_c, sort on ascending x then descending y
  xy$concordant<-rep(NA, nrow(xy))
  for (i in 1:nrow(xy-1)){
    xy$concordant[i]<-sum(xy_c$yrank[(i+1):length(xy_c$yrank)]>xy_c$yrank[i])
  }
  nc<-sum(xy$concordant, na.rm=TRUE)
  nd<-n_max-nc
  Tau<-(nc-nd)/n_max
  pc<-(Tau+1)/2
  a.post<-a.prior+nc
  b.post<-b.prior+nd
  post.median<-qbeta(0.5, a.post, b.post)
  post.eti.lower<-qbeta((1-interval.width)/2, a.post, b.post)
  post.eti.upper<-qbeta(1-(1-interval.width)/2, a.post, b.post)


  dfba_phi_list<-list(tau=Tau,
                      nc=nc,
                      nd=nd,
                      sample.p=pc,
                      a.prior=a.prior,
                      b.prior=b.prior,
                      alpha=a.post,
                      beta=b.post,
                      post.median=post.median,
                      interval.width=interval.width,
                      post.eti.lower=post.eti.lower,
                      post.eti.upper=post.eti.upper)

   if (is.null(fitting.parameters) == FALSE){      #Calculate phi_star if fitting.parameters are present
    Lc<-n*fitting.parameters-(fitting.parameters*(fitting.parameters+1)/2)
    nc_star<-nc-Lc
    Tau_star<-(nc_star-nd)/n_max
    pc_star<-(Tau_star+1)/2
    a.post_star<-a.prior+nc_star
    post.median_star<-qbeta(0.5, a.post_star, b.post)
    post.eti.lower_star<-qbeta(1-(1-interval.width)/2, a.post_star, b.post)
    post.eti.upper_star<-qbeta(1-(1-interval.width)/2, a.post_star, b.post)

    dfba_phi_star_list<-append(dfba_phi_list,
                               list(tau_star=Tau_star,
                                    nc_star=nc_star,
                                    nd_star=nd,
                                    sample.p_star=pc_star,
                                    alpha_star=a.post_star,
                                    beta_star=b.post,
                                    post.median_star=post.median_star,
                                    interval.width=interval.width,
                                    post.eti.lower_star=post.eti.lower_star,
                                    post.eti.upper_star=post.eti.upper_star))
  }

  if(is.null(fitting.parameters)==TRUE){
    new("dfba_phi_out", dfba_phi_list)
  } else {
    new("dfba_phi_star_out", dfba_phi_star_list)
  }

}


