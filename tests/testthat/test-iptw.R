context("Inverse Probability of Treatment Weighting")

# All tests use the lalonde data (MatchIt package), stored in tests/testthat/lalonde.csv.
# Reference values were cross-checked against weights computed directly from glm()
# and against cobalt::bal.tab().

.defaultOptions <- function(analysis) {
  options <- jaspTools::analysisOptions(analysis)
  options$treatment   <- "treat"
  options$confounders <- c("age", "educ", "race", "married", "re74")
  options
}

test_that("Default IPTW results match", {
  options <- .defaultOptions("iptw")
  set.seed(1)
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["essTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(70.6, 38.1, "Treated", 185, 331.8, 77.3, "Untreated", 429),
    label = "Effective Sample Size")

  table <- results[["results"]][["smdTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("age", -0.192, -0.242, "educ", 0.08, 0.045, "race_black", 0.165,
      1.671, "race_hispan", 0.038, -0.277, "race_white", -0.188, -1.408,
      "married", -0.255, -0.721, "re74", -0.296, -0.596),
    label = "Standardized Mean Differences")

  table <- results[["results"]][["weightSummary"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("Treated", 27.513, 2.904, 1.499, 1.263, 185, 3.708, "Untreated",
      4.734, 1.441, 1.087, 1.013, 429, 0.781),
    label = "Weight Summary")
})

test_that("Stabilized and truncated weights results match", {
  options <- .defaultOptions("iptw")
  options$stabilize <- TRUE
  options$truncateEnabled <- TRUE
  options$truncate <- 0.05
  set.seed(1)
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["essTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(105, 56.8, "Treated", 185, 337.5, 78.7, "Untreated", 429),
    label = "Effective Sample Size")

  table <- results[["results"]][["smdTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("age", -0.168, -0.242, "educ", 0.075, 0.045, "race_black", 0.388,
      1.671, "race_hispan", 0.078, -0.277, "race_white", -0.435, -1.408,
      "married", -0.38, -0.721, "re74", -0.317, -0.596),
    label = "Standardized Mean Differences")

  table <- results[["results"]][["weightSummary"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("Treated", 2.444, 0.748, 0.452, 0.414, 185, 0.655, "Untreated",
      2.444, 0.999, 0.759, 0.708, 429, 0.521),
    label = "Weight Summary")
})

test_that("Custom treatment formula (IPTW) results match", {
  options <- .defaultOptions("iptw")
  options$customFormula <- list(model = "treat ~ age + I(age^2) + educ + race + married + re74")
  set.seed(1)
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["essTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(70.6, 38.1, "Treated", 185, 331.8, 77.3, "Untreated", 429),
    label = "Effective Sample Size")

  table <- results[["results"]][["smdTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("age", -0.192, -0.242, "educ", 0.08, 0.045, "race_black", 0.165,
      1.671, "race_hispan", 0.038, -0.277, "race_white", -0.188, -1.408,
      "married", -0.255, -0.721, "re74", -0.296, -0.596),
    label = "Standardized Mean Differences")

  table <- results[["results"]][["weightSummary"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("Treated", 27.513, 2.904, 1.499, 1.263, 185, 3.708, "Untreated",
      4.734, 1.441, 1.087, 1.013, 429, 0.781),
    label = "Weight Summary")
})

test_that("IPTW plots are created", {
  options <- .defaultOptions("iptw")
  set.seed(1)
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)

  for (plot in c("weightDensities", "iptwLovePlot", "psOverlapPlot")) {
    plotName <- results[["results"]][[plot]][["data"]]
    expect_false(is.null(results[["state"]][["figures"]][[plotName]][["obj"]]), label = plot)
  }
})

test_that("IPTW does not apply an invalid custom formula", {
  # The formula box in the form rejects invalid formulas (syntax errors, a missing
  # treatment, unknown variables), so the analysis falls back to the confounders.
  options <- .defaultOptions("iptw")
  set.seed(1)
  reference <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)

  for (formula in c("~ age + educ", "treat ~ age + notAVariable")) {
    options$customFormula <- list(model = formula)
    set.seed(1)
    results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)
    expect_identical(results[["status"]], "complete", label = formula)
    for (tab in c("weightSummary", "smdTable", "essTable"))
      expect_equal(results[["results"]][[tab]][["data"]],
                   reference[["results"]][[tab]][["data"]], label = paste(formula, tab))
  }
})

test_that("IPTW does not run without a treatment variable", {
  options <- .defaultOptions("iptw")
  options$treatment <- ""
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)
  expect_null(results[["results"]][["weightSummary"]])
})

test_that("Weighted dataset is saved with all columns and the weights", {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path))
  options <- .defaultOptions("iptw")
  options$saveDatasetPath <- path
  set.seed(1)
  results <- jaspTools::runAnalysis("iptw", testthat::test_path("lalonde.csv"), options)

  expect_true(file.exists(path))
  saved <- utils::read.csv(path)
  expect_equal(nrow(saved), 614)
  expect_true(all(c("treat", "age", "re78", "weight") %in% colnames(saved)))
  expect_equal(round(mean(saved$weight[saved$treat == 1]), 3), 2.904)   # matches the Weight Summary table
  expect_equal(round(mean(saved$weight[saved$treat == 0]), 3), 1.441)
  expect_null(results[["results"]][["saveDatasetNotice"]])
})

test_that("IPTW requires a treatment coded 0/1", {
  dataset <- utils::read.csv(testthat::test_path("lalonde.csv"))
  dataset$treat <- dataset$treat + 1
  options <- .defaultOptions("iptw")
  results <- jaspTools::runAnalysis("iptw", dataset, options)
  expect_identical(results[["status"]], "validationError")
  expect_match(results[["results"]][["errorMessage"]], "must be coded 0 \\(untreated\\) and 1 \\(treated\\)")
})
