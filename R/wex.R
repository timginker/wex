#' Exact observation weights for the Kalman filter and smoother
#'
#' Computes the exact observation weights for the Kalman filter and smoother,
#' following Koopman and Harvey (2003). The implementation in \code{wex}
#' builds on the functionality provided by the \code{FKF} and \code{KFAS}
#' packages. These packages rely on different computational approaches:
#' \code{FKF} uses routines from BLAS and LAPACK, whereas \code{KFAS} uses
#' sequential processing, which allows the prediction error variance matrices
#' to be singular.
#'
#' @param a0 A numeric vector specifying the initial state estimate. Defaults to a vector of zeros.
#' @param P0 A numeric matrix specifying the covariance matrix of the initial state. Defaults to a diagonal matrix with large values (e.g., 1e6) on the diagonal.
#' @param Tt An array specifying the transition matrix of the state equation (see \bold{Details}).
#' @param Zt An array specifying the observation matrix of the measurement equation (see \bold{Details}).
#' @param HHt An array specifying the covariance matrix of the state disturbances (see \bold{Details}).
#' @param GGt An array specifying the covariance matrix of the observation disturbances (see \bold{Details}).
#' @param yt An \eqn{d \times n}{d * n} matrix of observations, where rows correspond to variables and columns to time points. Missing values (\code{NA}) are allowed.
#' @param t An integer specifying the time index for which the observation weights are evaluated.
#' @param package A character string indicating which backend to use (\code{"FKF"} or \code{"KFAS"}). Defaults to \code{"FKF"}.
#'
#' @importFrom FKF fkf fks
#' @importFrom KFAS KFS SSModel SSMcustom
#'
#' @return A list with two components:
#' \itemize{
#'   \item \code{Wt}: An array of filtering weights with dimensions \eqn{m \times d \times n}, , where \eqn{m} is the state
#'   dimension, \eqn{d} is the observation dimension, and \eqn{n} is the number of time points.
#'   \item \code{WtT}: An array of smoothing weights with the same dimensions as \code{Wt}.
#' }
#'
#'
#' @references
#' Koopman, S. J., and Harvey, A. (2003). Computing observation weights for
#' signal extraction and filtering. \emph{Journal of Economic Dynamics and Control},
#' \bold{27}(7), 1317-1333.
#'
#' Helske, J. (2017). KFAS: Exponential family state space models in R.
#' \emph{Journal of Statistical Software}, \bold{78}, 1-39.
#'
#' @author Tim Ginker
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
wex<-function(a0=NULL,
              P0=NULL,
              Tt,
              Zt,
              HHt,
              GGt,
              yt,
              t,
              package = "FKF"){


  package <- match.arg(package, choices = c("FKF", "KFAS"))

  # Matching dimensions

  if (is.null(dim(yt))) {
    yt <- matrix(yt, nrow = 1)
  }

  dim_y <- nrow(yt)
  n_y   <- ncol(yt)
  m     <- dim(Tt)[1]

  # Setting a0 and P0

  if (is.null(a0)) {
    a0 <- rep(0, m)
  }

  if (is.null(P0)) {
    P0 <- diag(1e6, m)
  }

  # Integrity checks

  if (!is.numeric(a0) || length(a0) != m) {
    stop("`a0` must be a numeric vector of length equal to the state dimension.")
  }

  if (!is.matrix(P0) || any(dim(P0) != c(m, m))) {
    stop("`P0` must be an m x m numeric matrix, where m is the state dimension.")
  }

  if (!is.numeric(t) || length(t) != 1 || t < 1 || t > n_y || t %% 1 != 0) {
    stop("`t` must be a single integer between 1 and the number of observations.")
  }


  # empty weights container for filtering and Smoothing

  Wt  <- array(0, dim = c(m, dim_y, n_y))
  WtT <- array(0, dim = c(m, dim_y, n_y))

  # computing observation weights for a given period

  na_index <- is.na(t(yt))
  data1 <- matrix(0, nrow = n_y, ncol = dim_y)

  # loop over dimensions of yt
  if(package == "FKF"){

    dt0 <- rep(0, m)
    ct0 <- rep(0, dim_y)
    data1 <- t(data1)
    na_index <- is.na(yt)

    for (col in 1:dim_y) {
      # loop over time
      for (s in n_y:1){

        data1[col,s]<-1
        # restoring NAs
        data1[na_index] <- NA

        # Kalman Filter
        kfw <- FKF::fkf(
            a0 = a0,
            P0 = P0,
            dt = dt0,
            ct = ct0,
            Tt = Tt,
            Zt = Zt,
            HHt = HHt,
            GGt = GGt,
            yt = data1
          )

          # Kalman Smoother
          kfws<-FKF::fks(kfw)

          # Storing results
          WtT[,col,s]=kfws$ahatt[,t]
          Wt[,col,s]=kfw$att[,t]
          data1[col,s]<-0



      }


    }


  } else if( package == "KFAS"){


    R0 <- diag(m)
    P1inf0 <- matrix(0, nrow = m, ncol = m)

    for (col in 1:dim_y) {
      # loop over time
      for (s in n_y:1){

        data1[s,col]<-1
        # restoring NAs
        data1[na_index] <- NA

        fit_kfas <- SSModel(
            data1 ~ -1 +SSMcustom(
              Z = Zt,
              T = Tt,
              R = R0,
              Q = HHt,
              a1 =a0,
              P1 =P0,
              P1inf = P1inf0
            ),
            H = GGt
          )

          out <- KFAS::KFS(
            fit_kfas,
            filtering = "state",
            smoothing = "state"
          )

          WtT[, col, s] <- out$alphahat[t, ]
          Wt[, col, s]  <- out$att[t, ]

          data1[s,col]<-0

      }

    }

  }

  return(list(Wt=Wt,
              WtT=WtT))

}
