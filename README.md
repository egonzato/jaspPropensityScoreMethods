# jaspPropensityScoreMethods

A JASP module for causal inference with propensity score methods: **propensity score matching (PSM)** and **inverse probability of treatment weighting (IPTW)**.

The module was developed during the first JASP hackathon, in February 2026.

## Introduction

Observational data, such as data collected during daily clinical practice, are often used to compare a treated and an untreated group. Unlike in a randomized trial, the two groups usually differ in characteristics that affect both who receives the treatment and the outcome. These characteristics are called confounders. Causal inference methods try to make the two groups comparable, so that the data resemble those of a clinical trial. Propensity score matching and inverse probability of treatment weighting are two widely used approaches, both known as propensity score methods.

## What are propensity score methods?

The propensity score is the probability that a unit receives the treatment, given its confounders. It is usually estimated with a logistic regression of the treatment on the confounders (the treatment model). Once each unit's propensity score is estimated, it can be used to:

* **Match** treated and untreated units with similar propensity scores (PSM), creating a matched dataset in which the confounders are balanced between the two groups.
* **Weight** each unit by the inverse of the probability of the treatment it actually received (IPTW), creating a weighted dataset in which the confounders are balanced.

Both analyses report balance diagnostics, so you can check whether the confounders are balanced after matching or weighting.

## Using the module

1. Install the module from the JASP Module Library (listed under *Community*) and open it from the *Propensity Score Methods* ribbon.
2. Choose *Propensity Score Matching* or *Inverse Probability of Treatment Weighting*.
3. Assign the **treatment** variable and the **confounders**.

**The treatment variable must be coded 0 (untreated) and 1 (treated).** The analyses stop with an error message if the treatment has any other values.

Confounders can be continuous, nominal or ordinal. Instead of listing the confounders, you can also write the treatment model as an R formula, for example `treat ~ age + I(age^2) + educ + race`. A formula overrides the confounders listed in the variables box.

## Options and output

### Propensity score matching

Matching is performed with the [MatchIt](https://kosukeimai.github.io/MatchIt/) R package.

Options:

* **Treatment model:** the confounders, or a custom formula with non-linear terms.
* **Distance:** the propensity score (*Probability*), its logit (*Logit*), or the *Mahalanobis* distance computed on the confounders.
* **Method:** *Nearest* matches each treated unit in turn to the closest available untreated unit(s). With a propensity score distance, it starts from the treated units with the highest propensity score. *Optimal* finds the matching that minimizes the total distance across all pairs.
* **Ratio:** the number of untreated units matched to each treated unit.
* **Replacement:** with replacement, an untreated unit can be matched to more than one treated unit. Without replacement, each untreated unit is used at most once.
* **Caliper:** available only when the method is *Nearest*. It sets the maximum allowed distance between matched units, in standard deviations of the propensity score. When the Mahalanobis distance is selected, a propensity score is estimated only to apply the caliper.
* **Export:** saves the matched units, with all columns of the dataset plus the matching weights, subclass and distance, to a CSV file.

Output:

* Covariate balance tables before and after matching (means, standardized mean differences, variance ratios and eCDF statistics).
* Sample sizes of the original, matched, unmatched and discarded units.
* A love plot of the standardized mean differences before and after matching.
* Density and bar plots of each confounder in the treated and untreated groups, before and after matching.

### Inverse probability of treatment weighting

The propensity score is estimated with a logistic regression, and the weights are 1 / propensity score for treated units and 1 / (1 − propensity score) for untreated units. Balance statistics are computed with the [cobalt](https://ngreifer.github.io/cobalt/) R package.

Options:

* **Treatment model:** the confounders, or a custom formula with non-linear terms.
* **Stabilize weights:** uses the proportion of units in the group a unit belongs to (treated or untreated), instead of 1, as the numerator of its weight. Stabilized weights have a mean close to 1 and a lower variance.
* **Truncate weights:** sets weights below the given percentile, and above the matching upper percentile, to those percentile values. For example, 0.01 truncates the weights at the 1st and 99th percentiles.
* **Export:** saves the dataset, with the weights added as a column, to a CSV file.

Output:

* A summary of the weights in each group.
* Standardized mean differences of each confounder before and after weighting.
* The effective sample size of each group.
* A love plot, the distribution of the weights, and the overlap of the propensity scores in the two groups.

## Future work

* Bootstrapped standard errors for IPTW estimates.

## References

* Rosenbaum, P. R., & Rubin, D. B. (1983). The central role of the propensity score in observational studies for causal effects. *Biometrika, 70*(1), 41–55.
* Austin, P. C. (2011). An introduction to propensity score methods for reducing the effects of confounding in observational studies. *Multivariate Behavioral Research, 46*(3), 399–424.
* Robins, J. M., Hernán, M. A., & Brumback, B. (2000). Marginal structural models and causal inference in epidemiology. *Epidemiology, 11*(5), 550–560.
* Ho, D. E., Imai, K., King, G., & Stuart, E. A. (2011). MatchIt: Nonparametric preprocessing for parametric causal inference. *Journal of Statistical Software, 42*(8), 1–28.
* Hansen, B. B., & Klopfer, S. O. (2006). Optimal full matching and related designs via network flows. *Journal of Computational and Graphical Statistics, 15*(3), 609–627.
* Greifer, N. cobalt: Covariate balance tables and plots. R package. https://ngreifer.github.io/cobalt/
