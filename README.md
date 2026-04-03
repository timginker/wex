
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wex

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/wex?color=green)](https://cran.r-project.org/package=wex)
[![](https://img.shields.io/github/last-commit/timginker/wex.svg)](https://github.com/timginker/wex/commits/master)
[![](http://cranlogs.r-pkg.org/badges/grand-total/wex)](https://cran.r-project.org/package=wex)
<!-- badges: end -->

`wex` is an R package for computing exact observation weights for the
Kalman filter and smoother, following Koopman and Harvey (2003). The
package provides tools for analyzing linear Gaussian state-space models
by quantifying how individual observations contribute to filtered and
smoothed state estimates.

These weights are particularly useful in applications such as dynamic
factor models, where they can be used to decompose latent factors into
contributions from observed variables (see Example 2 below).

## Installation

The stable version of `wex` can be installed from CRAN:

``` r
install.packages("wex")
```

The development version of `wex` can be installed from
[GitHub](https://github.com/):

``` r
# install.packages("devtools")
devtools::install_github("timginker/wex")
```

## Example 1: Local level model

In this illustrative example, we fit a local level model to the `Nile`
data and compute the corresponding filtered and smoothed state
estimates. We then extract the observation weights and use them to
reconstruct these estimates from the observed data.

The resulting estimates are shown in the plot below.

<img src="man/figures/README-unnamed-chunk-3-1.png" alt="" width="100%" />

To illustrate the weight decomposition, consider the estimate of the
local level at time $t = 50$. Koopman and Harvey (2003) showed that the
smoothed estimate can be written as

$$
\alpha _{t|T}=\sum_{j=1}^{T}w_{j}(\alpha _{t|T})y_{j}.
$$

Similarly, the filtered estimate can be written as

$$
\alpha _{t|t}=\sum_{j=1}^{t}w_{j}(\alpha _{t|t})y_{j}.
$$

We can compute the weight assigned to each observation using the `wex`
function and compare the resulting weighted averages with the
corresponding estimates obtained from the Kalman filter and smoother.

``` r
wts <- wex(Tt=matrix(1),
        Zt=matrix(1),
        HHt = matrix(1385.066),
        GGt = matrix(15124.13),
        yt = t(y),
        t=50)
```

We can also visualize the weights assigned to each observation.

``` r
par(mfrow = c(2, 1),
    mar = c(2.2, 2.2, 1, 1),
    cex = 0.8)
plot(
  wts$Wt,
  col = "darkgrey",
  xlab = "",
  ylab = "",
  lwd = 1.5,
  type="l",
  main="Filtering weights"
)
plot(
  wts$WtT,
  col = "blue",
  xlab = "",
  ylab = " ",
  lwd = 1.5,
  type="l",
  main="Smoothing weights"
)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />

Finally, we verify that the filtered and smoothed estimates obtained
from the Kalman filter coincide with those computed using the
observation weights.

``` r
cat(
  "\nSmoothed level computed using the weights = ",
  sum(y * as.numeric(wts$WtT), na.rm = TRUE),
  "\nSmoothed level from the Kalman smoother = ",
  fit_ks$ahatt[50]
)
#> 
#> Smoothed level computed using the weights =  834.9828 
#> Smoothed level from the Kalman smoother =  834.9828
```

``` r
cat(
  "\nFiltered level computed using the weights = ",
  sum(y * as.numeric(wts$Wt), na.rm = TRUE),
  "\nFiltered level from the Kalman filter = ",
  fit_kf$att[50]
)
#> 
#> Filtered level computed using the weights =  849.307 
#> Filtered level from the Kalman filter =  849.307
```

## Example 2: Decomposing Variable Contributions in a Dynamic Factor Model

In this example, we show how to compute observation weights in a dynamic
factor model (DFM) and use them to decompose the latent factor into
contributions from individual variables.

More formally, let $x_t = (x_{1,t}, x_{2,t}, \dots, x_{n,t})^{\prime}$,
for $t = 1, 2, \dots, T$, denote a vector of $n$ monthly series that
have been transformed to achieve stationarity and standardized. A
dynamic factor model assumes that $x_t$ can be decomposed into two
unobserved orthogonal components representing common and idiosyncratic
factors. The model is given by

$$
x_t = \Lambda F_t + \varepsilon_t, \hspace{2pt} \varepsilon_t \sim N(0, R),
$$

where $F_t$ is an $(r \times 1)$ vector of unobserved common factors,
$\Lambda$ is an $(n \times r)$ matrix of factor loadings, and
$\varepsilon_t$ is an $(n \times 1)$ vector of idiosyncratic components.
The common factors are assumed to follow the stationary VAR($p$) process

$$
F_t = \sum_{s=1}^{p} \Phi_s F_{t-s} + u_t, \hspace{2pt} u_t \sim N(0, Q),
$$

where $\Phi_s$ are $(r \times r)$ matrices of autoregressive
coefficients. Estimation and signal extraction can then be carried out
using standard Kalman filtering and smoothing methods.

In this illustrative example, we use a dataset containing 10 monthly
economic indicators spanning January 2000 to November 2021. All
variables have been log-differenced, when necessary, to achieve
stationarity. We assume a single latent factor following an AR(1)
process.

The standardized data series are shown in the plot below.

<img src="man/figures/README-unnamed-chunk-8-1.png" alt="" width="100%" />

We now use the `wex` function to decompose the final estimate of the
latent factor into contributions from each observed variable.

``` r
# Define the state-space matrices
Zt <- matrix(c(0.37873307, 0.37438154, 0.37767322,
                 0.02433999, 0.36020426, 0.23031769,
                 0.36584474, 0.35066644, 0.33420247,
                 0.01379571),
          ncol=1
)

Tt <- matrix(-0.3676422)

HHt <- matrix(1)

GGt <- matrix(c(
  0.7891011, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0.3235747, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0.7673983, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0.01704776, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0.9979156, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0.8496217, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0.8132641, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0.9084006, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0.7601053, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1789897
), nrow = 10, ncol = 10, byrow = TRUE)

# Extract weights for the final observation
wts <- wex(Tt=Tt,
        Zt=Zt,
        HHt = HHt,
        GGt = GGt,
        yt = t(df),
        t=nrow(df))
# Compute contributions

# Extract smoothing weights corresponding to the target state
sweights <- t(wts$WtT[1, , ])
colnames(sweights) <- colnames(df)

# Compute variable contributions as weighted sums of the observed data
contributions <- colSums(sweights * df, na.rm = TRUE)
```

The contributions are summarized in the Table below:

<table class=" lightable-classic" style="font-family: Cambria; width: auto !important; margin-left: auto; margin-right: auto;">

<caption>

Varibale Contributions
</caption>

<thead>

<tr>

<th style="text-align:left;">

Variable
</th>

<th style="text-align:right;">

Contribution
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Total industrial production in Israel
</td>

<td style="text-align:right;">

0.044
</td>

</tr>

<tr>

<td style="text-align:left;">

Trade revenue
</td>

<td style="text-align:right;">

0.065
</td>

</tr>

<tr>

<td style="text-align:left;">

Service revenue
</td>

<td style="text-align:right;">

-0.023
</td>

</tr>

<tr>

<td style="text-align:left;">

Employment (excluding absent workers)
</td>

<td style="text-align:right;">

0.060
</td>

</tr>

<tr>

<td style="text-align:left;">

Exports of services
</td>

<td style="text-align:right;">

0.010
</td>

</tr>

<tr>

<td style="text-align:left;">

Building starts
</td>

<td style="text-align:right;">

0.001
</td>

</tr>

<tr>

<td style="text-align:left;">

Imports of consumer goods
</td>

<td style="text-align:right;">

0.019
</td>

</tr>

<tr>

<td style="text-align:left;">

Imports of production inputs
</td>

<td style="text-align:right;">

0.010
</td>

</tr>

<tr>

<td style="text-align:left;">

Exports of goods
</td>

<td style="text-align:right;">

0.003
</td>

</tr>

<tr>

<td style="text-align:left;">

Job openings
</td>

<td style="text-align:right;">

-0.002
</td>

</tr>

<tr>

<td style="text-align:left;">

Total
</td>

<td style="text-align:right;">

0.188
</td>

</tr>

</tbody>

</table>

## Implementation

The package supports two computational backends:

- **FKF**: fast and efficient, but requires non-singular prediction
  error covariance matrices.
- **KFAS**: more flexible, allowing for singular prediction error
  covariance matrices.

# References

- Koopman, S. J., and Harvey, A. C. (2003). Computing observation
  weights for signal extraction and filtering. *Journal of Economic
  Dynamics and Control*, 27(7), 1317–1333.
  <https://doi.org/10.1016/S0165-1889(02)00061-1>

- Helske, J. (2017). KFAS: Exponential Family State Space Models in R.
  *Journal of Statistical Software*, 78(10), 1–39.
  <https://doi.org/10.18637/jss.v078.i10>

# Disclaimer

The views expressed here are solely of the author and do not necessarily
represent the views of the Bank of Israel.

Please note that `wex` is still under development and may contain bugs
or other issues that have not yet been resolved. While we have made
every effort to ensure that the package is functional and reliable, we
cannot guarantee its performance in all situations.

We strongly advise that you regularly check for updates and install any
new versions that become available, as these may contain important bug
fixes and other improvements. By using this package, you acknowledge and
accept that it is provided on an “as is” basis, and that we make no
warranties or representations regarding its suitability for your
specific needs or purposes.
