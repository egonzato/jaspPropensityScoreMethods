# jaspPropensityScoreMethods

This module was developed during the first JASP hackathon, in February 2026.

## Introduction

To make use of observational data, causal inference methods are often employed to make two groups comparable. Several approaches are used to recreate clinical-trial like settings from data gathered during daily clinical practice. Among these, propensity score matching (psm) and inverse probability of treatment weighting (iptw), which can both be labelled under the same umbrella as propensity score methods.

## What are Propensity Score Methods

Propensity score methods like psm and iptw aim to predict how likely a unit is to receive the treatment, based on a certain set of characteristics, also called confounders. Once the probability of receiving the treatment is predicted for each unit, this can be used to:

* Pair treated and untreated units that are closest in probability of treatment, for psm, in order to recreate a dataset in which confounders are balanced between the two arms.
* Use the inverse of this probability of treatment as weights in the analysis of interest, to regulate the impact that units have on parameter estimation.

## Options currently available

For psm, the following options are available:

* Treatment model specification: linear and/or non-linear form for confounders.
* Distance measure: Probability, Logit, Mahalanobis distance
* Method: matching can be performed starting from treated units with the highest probability of treatment ('nearest') or by minimizing the total distance across all pairs ('optimal').
* Ratio: number of untreated units to look for each treated unit.
* Caliper: available only when the method is "Nearest". Specifies the maximum distance (in standard deviations of the propensity score) between matched treated and untreated units. When the Mahalanobis distance is selected, a propensity score is estimated only to apply the caliper.
* Replacement: untreated units can be used multiple times in matching with replacement, or only once if without replacement.
* Export: the matched dataset (all columns, plus weights, subclass and distance) can be saved as a CSV file.

For inverse probability of treatment weighting, the following options are available:

* Treatment model specification: linear and/or non-linear form for confounders.
* Stabilize weights: whether weights should be stabilized by using the mean probability of treatment as numerator of the treatment weights, or 1 (unstabilized weights).
* Truncate weights: whether the tails of the distribution of weights should be truncated at given percentiles.
* Export: the dataset with the IPTW weights added as a column can be saved as a CSV file.

## Future work

* Bootstrapped standard errors for IPTW estimates.
