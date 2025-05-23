#' Exact observation weights for the Kalman filter and smoother.
#'
#' This function computes the exact observation weights for the Kalman filter and smoother,
#' as described by Koopman and Harvey (2003). The implementation of \code{wex} builds upon the
#' existing \code{FKF} package (see: https://CRAN.R-project.org/package=FKF).
#'
#' @param a0 A \code{vector} giving the initial value/estimation of the state variable. By default is set to zero.
#' @param P0 A \code{matrix} giving the variance of a0. By default is a diagonal matrix of 10^6.
#' @param Tt An \code{array} giving the factor of the transition equation (see \bold{Details}).
#' @param Zt An \code{array} giving the factor of the measurement equation (see \bold{Details}).
#' @param HHt An \code{array} giving the variance of the innovations of the transition equation (see \bold{Details}).
#' @param GGt An \code{array} giving the variance of the disturbances of the measurement equation (see \bold{Details}).
#' @param yt An \eqn{n \times d}{n * d} matrix, where d is the dimension and n is the number of observations. \code{matrix} containing the observations. “NA”-values are allowed (see \bold{Details}).
#' @param t An observation index for which the weights are returned.
#'
#' @import FKF
#'
#' @returns Weight matrices for filtering (Wt) and smoothing (WtT).
#'
#'
#' @references Koopman, S. J., & Harvey, A. (2003). Computing observation weights for
#'  signal extraction and filtering. \emph{Journal of Economic Dynamics and Control}, \bold{27}(7), 1317-1333.
#'
#'
#'
#' @export
#'
#' @details
#'
#' \strong{State space form}
#'
#' \deqn{\alpha_{t+1} = T_t \alpha_t + H_t \eta_t,}
#' \deqn{y_t = Z_t \alpha_t + G_t \epsilon_t,}
#'
#' where \eqn{y_t} represents the observed data (possibly with NA's),
#' and \eqn{\alpha_t} is the state vector.
#'
#' @examples
#'
#' # Decompose a local level model (Nile data set)
#' data(Nile)
#' y <- Nile
#' wts <- wex(Tt=matrix(1),
#' Zt=matrix(1),
#' HHt = matrix(1385.066),
#' GGt = matrix(15124.13),
#' yt = t(y),
#' t=50)
#'
#'
#'
#'
#'
wex<-function(a0=NULL,
              P0=NULL,
              Tt,
              Zt,
              HHt,
              GGt,
              yt,
              t){

  if(is.null(dim(yt))){
    dim_y=1
    n_y=length(yt)
  }else{
    dim_y=dim(yt)[1]
    n_y=dim(yt)[2]
  }

  # empty weights container for filtering
  Wt<-array(matrix(0,nrow=dim(Tt)[1],
                  ncol=dim_y),
           dim=c(dim(Tt)[1],
                 dim_y,
                 n_y))

  # empty weights container for smoothing
  WtT<-array(matrix(0,nrow=dim(Tt)[1],
                   ncol=dim_y),
            dim=c(dim(Tt)[1],
                  dim_y,
                  n_y))
  # Set a0 and P0

  if(is.null(a0)){

    a0=rep(0,dim(Tt)[1])
  }

  if(is.null(P0)){

    P0=diag(10^6,dim(Tt)[1])
  }

  # computing observation weights for a given period

  # loop over dimensions of yt
  for (col in 1:dim_y) {
    # loop over time
    for (s in n_y:1){

      data1<-matrix(0,
                    nrow=n_y,
                    ncol=dim_y)

      data1[s,col]<-1
      # restoring NAs
      data1[is.na(t(yt))]<-NA

      # Kalman Filter
      kfw<-FKF::fkf(a0,
              P0,
              rep(0,dim(Tt)[1]),
              rep(0,dim_y),
              Tt,
              Zt,
              HHt,
              GGt,
              yt=t(data1))
      # Kalman Smoother
      kfws<-FKF::fks(kfw)


      # Storing results
      WtT[,col,s]=kfws$ahatt[,t]
      Wt[,col,s]=kfw$att[,t]

    }


  }

  return(list(Wt=Wt,
              WtT=WtT))


}
