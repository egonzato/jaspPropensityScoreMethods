context("Propensity Score Matching")

# All tests use the lalonde data (MatchIt package), stored in tests/testthat/lalonde.csv.
# Reference values were cross-checked against direct calls to MatchIt::matchit().

.defaultOptions <- function(analysis) {
  options <- jaspTools::analysisOptions(analysis)
  options$treatment   <- "treat"
  options$confounders <- c("age", "educ", "race", "married", "re74")
  options
}

test_that("Default nearest neighbour matching results match", {
  options <- .defaultOptions("matching")
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["SampleSizes"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(429, "All (ESS)", 185, 429, "All", 185, 185, "Matched (ESS)",
      185, 185, "Matched", 185, 244, "Unmatched", 0, 0, "Discarded",
      0),
    label = "Sample sizes")

  table <- results[["results"]][["balanceTableAfter"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.365754109179916, 0.571048509763504, 0.949947617577756,
      0.94998466138958, 0.712558756935222, 0.405405405405405, 0.128656525377837,
      "age", 25.572972972973, 25.8162162162162, 0.0339961688294, 1.35153657857327,
      0.464226918040089, 0.243243243243243, 0.0798648648648649, "educ",
      10.7405405405405, 10.3459459459459, -0.19625222901769, 1.23396949478246,
      0.524012246016998, 0.162162162162162, 0.0372688477951636, "raceblack",
      0.47027027027027, 0.843243243243243, 1.02585928270134, 1.02585928270134,
      "", 0.372972972972973, 0.372972972972973, "racehispan", 0.221621621621622,
      0.0594594594594595, -0.685725481323742, 1.14287580220624, "",
      0.162162162162162, 0.162162162162162, "racewhite", 0.308108108108108,
      0.0972972972972973, -0.711328351713958, 0.711328351713957, "",
      0.210810810810811, 0.210810810810811, "married0", 0.794594594594595,
      0.810810810810811, 0.0414039335605414, 0.75907211527659, "",
      0.0162162162162163, 0.0162162162162163, "married1", 0.205405405405405,
      0.189189189189189, -0.0414039335605413, 0.75907211527659, "",
      0.0162162162162162, 0.0162162162162162, "re74", 2329.00692681081,
      2095.57368864865, -0.0477698739194329, 0.731938727714281, 1.40235137489863,
      0.318918918918919, 0.0547033066586139),
    label = "Confounders balance after matching")

  table <- results[["results"]][["balanceTableBefore"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.184979081059826, 0.571048509763504, 1.78643807611956,
      0.87602319369465, 0.641932841932842, 0.37623605492458, "age",
      28.030303030303, 25.8162162162162, -0.309445261997982, 0.439995463435061,
      0.157726957726958, 0.0813390663390664, "educ", 10.2354312354312,
      10.3459459459459, 0.0549646613888354, 0.495893371429209, 0.111371511371511,
      0.0347223189328453, "raceblack", 0.202797202797203, 0.843243243243243,
      1.76154188981543, "", 0.64044604044604, 0.64044604044604, "racehispan",
      0.142191142191142, 0.0594594594594595, -0.349842541598422, "",
      0.0827316827316827, 0.0827316827316827, "racewhite", 0.655011655011655,
      0.0972972972972973, -1.88186760097513, "", 0.557714357714358,
      0.557714357714358, "married0", 0.487179487179487, 0.810810810810811,
      0.826309272340717, "", 0.323631323631324, 0.323631323631324,
      "married1", 0.512820512820513, 0.189189189189189, -0.826309272340716,
      "", 0.323631323631324, 0.323631323631324, "re74", 5619.23650638695,
      2095.57368864865, -0.721083809071869, 0.518128480856177, 0.447035847035847,
      0.224794889040699),
    label = "Confounders balance before matching")
})

test_that("Logit distance with caliper and 2:1 ratio results match", {
  options <- .defaultOptions("matching")
  options$distance_dropdown <- "Logit"
  options$caliperEnabled <- TRUE
  options$caliper <- 0.1
  options$ratio <- 2L
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["SampleSizes"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(429, "All (ESS)", 185, 429, "All", 185, 127.069518716578, "Matched (ESS)",
      109, 140, "Matched", 109, 289, "Unmatched", 76, 0, "Discarded",
      0),
    label = "Sample sizes")

  table <- results[["results"]][["balanceTableAfter"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.5003937659857, 0.517446301874826, 0.0789062721413026,
      0.0653418207919725, 1.09145689827781, 0.192660550458716, 0.0266288999181163,
      "age", 25.6697247706422, 26.4311926605505, 0.106424296101007,
      1.34770526430836, 0.397846919393609, 0.325688073394495, 0.0977064220183486,
      "educ", 10.5045871559633, 10.6330275229358, 0.0638800142209153,
      0.984045545597996, 0.502732784553283, 0.0688073394495413, 0.0280057943022694,
      "raceblack", 0.724770642201835, 0.73394495412844, 0.0252338741257475,
      0.0392927468529499, "", 0.00917431192660545, 0.00917431192660545,
      "racehispan", 0.0871559633027523, 0.100917431192661, 0.0581923000205928,
      0.392659472043714, "", 0.0137614678899083, 0.0137614678899083,
      "racewhite", 0.188073394495413, 0.165137614678899, -0.0773910521448378,
      0.26511963291903, "", 0.0229357798165138, 0.0229357798165138,
      "married0", 0.793577981651376, 0.834862385321101, 0.105409096908717,
      0.382986385435007, "", 0.0412844036697247, 0.0412844036697247,
      "married1", 0.206422018348624, 0.165137614678899, -0.105409096908717,
      0.382986385435006, "", 0.0412844036697248, 0.0412844036697248,
      "re74", 2316.80609431193, 2486.21268348624, 0.0346674341224548,
      0.57218150106192, 1.38009271054649, 0.247706422018349, 0.0487545487161089
      ),
    label = "Confounders balance after matching")

  table <- results[["results"]][["balanceTableBefore"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.184979081059826, 0.571048509763504, 1.78643807611956,
      0.87602319369465, 0.641932841932842, 0.37623605492458, "age",
      28.030303030303, 25.8162162162162, -0.309445261997982, 0.439995463435061,
      0.157726957726958, 0.0813390663390664, "educ", 10.2354312354312,
      10.3459459459459, 0.0549646613888354, 0.495893371429209, 0.111371511371511,
      0.0347223189328453, "raceblack", 0.202797202797203, 0.843243243243243,
      1.76154188981543, "", 0.64044604044604, 0.64044604044604, "racehispan",
      0.142191142191142, 0.0594594594594595, -0.349842541598422, "",
      0.0827316827316827, 0.0827316827316827, "racewhite", 0.655011655011655,
      0.0972972972972973, -1.88186760097513, "", 0.557714357714358,
      0.557714357714358, "married0", 0.487179487179487, 0.810810810810811,
      0.826309272340717, "", 0.323631323631324, 0.323631323631324,
      "married1", 0.512820512820513, 0.189189189189189, -0.826309272340716,
      "", 0.323631323631324, 0.323631323631324, "re74", 5619.23650638695,
      2095.57368864865, -0.721083809071869, 0.518128480856177, 0.447035847035847,
      0.224794889040699),
    label = "Confounders balance before matching")
})

test_that("Mahalanobis distance with caliper results match", {
  options <- .defaultOptions("matching")
  options$distance_dropdown <- "Mahalanobis"
  options$caliperEnabled <- TRUE
  options$caliper <- 0.2
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["SampleSizes"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(429, "All (ESS)", 185, 429, "All", 185, 113, "Matched (ESS)",
      113, 113, "Matched", 113, 316, "Unmatched", 72, 0, "Discarded",
      0),
    label = "Sample sizes")

  table <- results[["results"]][["balanceTableAfter"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.495456013792162, 0.526999799712778, 0.145960845495495,
      0.160232700566042, 1.13778477862643, 0.336283185840708, 0.047648983671035,
      "age", 25.0530973451327, 26.5752212389381, 0.212735121367062,
      0.979571023969265, 0.486242419740414, 0.300884955752212, 0.0823008849557522,
      "educ", 10.2035398230088, 10.8672566371681, 0.330100579175712,
      0.752629320520624, 0.50372823267877, 0.141592920353982, 0.0405216581276199,
      "raceblack", 0.734513274336283, 0.743362831858407, 0.0243406396434203,
      0.0243406396434203, "", 0.00884955752212391, 0.00884955752212391,
      "racehispan", 0.106194690265487, 0.0973451327433628, -0.03742159706339,
      0.03742159706339, "", 0.00884955752212389, 0.00884955752212389,
      "racewhite", 0.15929203539823, 0.15929203539823, 0, 0, "", 0,
      0, "married0", 0.761061946902655, 0.831858407079646, 0.180760535898528,
      0.271140803847792, "", 0.0707964601769911, 0.0707964601769911,
      "married1", 0.238938053097345, 0.168141592920354, -0.180760535898528,
      0.271140803847792, "", 0.0707964601769911, 0.0707964601769911,
      "re74", 2641.64650070796, 2343.55814070796, -0.0610009246590605,
      0.458352981136414, 1.44334378586274, 0.327433628318584, 0.0639244574084145
      ),
    label = "Confounders balance after matching")

  table <- results[["results"]][["balanceTableBefore"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.184979081059826, 0.571048509763504, 1.78643807611956,
      0.87602319369465, 0.641932841932842, 0.37623605492458, "age",
      28.030303030303, 25.8162162162162, -0.309445261997982, 0.439995463435061,
      0.157726957726958, 0.0813390663390664, "educ", 10.2354312354312,
      10.3459459459459, 0.0549646613888354, 0.495893371429209, 0.111371511371511,
      0.0347223189328453, "raceblack", 0.202797202797203, 0.843243243243243,
      1.76154188981543, "", 0.64044604044604, 0.64044604044604, "racehispan",
      0.142191142191142, 0.0594594594594595, -0.349842541598422, "",
      0.0827316827316827, 0.0827316827316827, "racewhite", 0.655011655011655,
      0.0972972972972973, -1.88186760097513, "", 0.557714357714358,
      0.557714357714358, "married0", 0.487179487179487, 0.810810810810811,
      0.826309272340717, "", 0.323631323631324, 0.323631323631324,
      "married1", 0.512820512820513, 0.189189189189189, -0.826309272340716,
      "", 0.323631323631324, 0.323631323631324, "re74", 5619.23650638695,
      2095.57368864865, -0.721083809071869, 0.518128480856177, 0.447035847035847,
      0.224794889040699),
    label = "Confounders balance before matching")
})

test_that("Optimal matching results match", {
  options <- .defaultOptions("matching")
  options$method_dropdown <- "Optimal"
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["SampleSizes"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(429, "All (ESS)", 185, 429, "All", 185, 185, "Matched (ESS)",
      185, 185, "Matched", 185, 244, "Unmatched", 0, 0, "Discarded",
      0),
    label = "Sample sizes")

  table <- results[["results"]][["balanceTableAfter"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.365760513779238, 0.571048509763504, 0.949917981923543,
      0.950002456385913, 0.71259761598345, 0.405405405405405, 0.128656525377837,
      "age", 25.5837837837838, 25.8162162162162, 0.0324852279925379,
      1.35153657857326, 0.464371404604025, 0.237837837837838, 0.0795945945945946,
      "educ", 10.7513513513514, 10.3459459459459, -0.201629002415435,
      1.22859272138472, 0.523637387558789, 0.167567567567568, 0.0378378378378378,
      "raceblack", 0.47027027027027, 0.843243243243243, 1.02585928270134,
      1.02585928270134, "", 0.372972972972973, 0.372972972972973,
      "racehispan", 0.221621621621622, 0.0594594594594595, -0.685725481323742,
      1.14287580220624, "", 0.162162162162162, 0.162162162162162,
      "racewhite", 0.308108108108108, 0.0972972972972973, -0.711328351713958,
      0.711328351713958, "", 0.210810810810811, 0.210810810810811,
      "married0", 0.794594594594595, 0.810810810810811, 0.0414039335605414,
      0.75907211527659, "", 0.0162162162162163, 0.0162162162162163,
      "married1", 0.205405405405405, 0.189189189189189, -0.0414039335605413,
      0.759072115276589, "", 0.0162162162162162, 0.0162162162162162,
      "re74", 2342.44643924324, 2095.57368864865, -0.0505201412742043,
      0.727824836654415, 1.40165686208246, 0.318918918918919, 0.0556696361165635
      ),
    label = "Confounders balance after matching")

  table <- results[["results"]][["balanceTableBefore"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.184979081059826, 0.571048509763504, 1.78643807611956,
      0.87602319369465, 0.641932841932842, 0.37623605492458, "age",
      28.030303030303, 25.8162162162162, -0.309445261997982, 0.439995463435061,
      0.157726957726958, 0.0813390663390664, "educ", 10.2354312354312,
      10.3459459459459, 0.0549646613888354, 0.495893371429209, 0.111371511371511,
      0.0347223189328453, "raceblack", 0.202797202797203, 0.843243243243243,
      1.76154188981543, "", 0.64044604044604, 0.64044604044604, "racehispan",
      0.142191142191142, 0.0594594594594595, -0.349842541598422, "",
      0.0827316827316827, 0.0827316827316827, "racewhite", 0.655011655011655,
      0.0972972972972973, -1.88186760097513, "", 0.557714357714358,
      0.557714357714358, "married0", 0.487179487179487, 0.810810810810811,
      0.826309272340717, "", 0.323631323631324, 0.323631323631324,
      "married1", 0.512820512820513, 0.189189189189189, -0.826309272340716,
      "", 0.323631323631324, 0.323631323631324, "re74", 5619.23650638695,
      2095.57368864865, -0.721083809071869, 0.518128480856177, 0.447035847035847,
      0.224794889040699),
    label = "Confounders balance before matching")
})

test_that("Custom treatment formula (matching) results match", {
  options <- .defaultOptions("matching")
  options$customFormula <- list(model = "treat ~ age + I(age^2) + educ + race + married + re74")
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_identical(results[["status"]], "complete")

  table <- results[["results"]][["SampleSizes"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(429, "All (ESS)", 185, 429, "All", 185, 185, "Matched (ESS)",
      185, 185, "Matched", 185, 244, "Unmatched", 0, 0, "Discarded",
      0),
    label = "Sample sizes")

  table <- results[["results"]][["balanceTableAfter"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.365754109179916, 0.571048509763504, 0.949947617577756,
      0.94998466138958, 0.712558756935222, 0.405405405405405, 0.128656525377837,
      "age", 25.572972972973, 25.8162162162162, 0.0339961688294, 1.35153657857327,
      0.464226918040089, 0.243243243243243, 0.0798648648648649, "educ",
      10.7405405405405, 10.3459459459459, -0.19625222901769, 1.23396949478246,
      0.524012246016998, 0.162162162162162, 0.0372688477951636, "raceblack",
      0.47027027027027, 0.843243243243243, 1.02585928270134, 1.02585928270134,
      "", 0.372972972972973, 0.372972972972973, "racehispan", 0.221621621621622,
      0.0594594594594595, -0.685725481323742, 1.14287580220624, "",
      0.162162162162162, 0.162162162162162, "racewhite", 0.308108108108108,
      0.0972972972972973, -0.711328351713958, 0.711328351713957, "",
      0.210810810810811, 0.210810810810811, "married0", 0.794594594594595,
      0.810810810810811, 0.0414039335605414, 0.75907211527659, "",
      0.0162162162162163, 0.0162162162162163, "married1", 0.205405405405405,
      0.189189189189189, -0.0414039335605413, 0.75907211527659, "",
      0.0162162162162162, 0.0162162162162162, "re74", 2329.00692681081,
      2095.57368864865, -0.0477698739194329, 0.731938727714281, 1.40235137489863,
      0.318918918918919, 0.0547033066586139),
    label = "Confounders balance after matching")

  table <- results[["results"]][["balanceTableBefore"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list("distance", 0.184979081059826, 0.571048509763504, 1.78643807611956,
      0.87602319369465, 0.641932841932842, 0.37623605492458, "age",
      28.030303030303, 25.8162162162162, -0.309445261997982, 0.439995463435061,
      0.157726957726958, 0.0813390663390664, "educ", 10.2354312354312,
      10.3459459459459, 0.0549646613888354, 0.495893371429209, 0.111371511371511,
      0.0347223189328453, "raceblack", 0.202797202797203, 0.843243243243243,
      1.76154188981543, "", 0.64044604044604, 0.64044604044604, "racehispan",
      0.142191142191142, 0.0594594594594595, -0.349842541598422, "",
      0.0827316827316827, 0.0827316827316827, "racewhite", 0.655011655011655,
      0.0972972972972973, -1.88186760097513, "", 0.557714357714358,
      0.557714357714358, "married0", 0.487179487179487, 0.810810810810811,
      0.826309272340717, "", 0.323631323631324, 0.323631323631324,
      "married1", 0.512820512820513, 0.189189189189189, -0.826309272340716,
      "", 0.323631323631324, 0.323631323631324, "re74", 5619.23650638695,
      2095.57368864865, -0.721083809071869, 0.518128480856177, 0.447035847035847,
      0.224794889040699),
    label = "Confounders balance before matching")
})

test_that("Optimal matching gives the same tables with and without a caliper", {
  options <- .defaultOptions("matching")
  options$method_dropdown <- "Optimal"
  set.seed(1)
  withoutCaliper <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)

  options$caliperEnabled <- TRUE
  options$caliper <- 0.01
  set.seed(1)
  withCaliper <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)

  for (tab in c("SampleSizes", "balanceTableBefore", "balanceTableAfter"))
    expect_equal(withCaliper[["results"]][[tab]][["data"]],
                 withoutCaliper[["results"]][[tab]][["data"]], label = tab)
})

test_that("Matching plots are created and the love plot matches", {
  options <- .defaultOptions("matching")
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)

  plotName <- results[["results"]][["densityPlot"]][["data"]]
  expect_false(is.null(results[["state"]][["figures"]][[plotName]][["obj"]]), label = "density plot")

  plotName <- results[["results"]][["lovePlot"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "love-plot")
})

test_that("Matching does not apply an invalid custom formula", {
  # The formula box in the form rejects invalid formulas (syntax errors, a missing
  # treatment, unknown variables), so the analysis falls back to the confounders.
  options <- .defaultOptions("matching")
  set.seed(1)
  reference <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)

  for (formula in c("treat ~ age +", "treat ~ age + notAVariable")) {
    options$customFormula <- list(model = formula)
    set.seed(1)
    results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
    expect_identical(results[["status"]], "complete", label = formula)
    for (tab in c("SampleSizes", "balanceTableBefore", "balanceTableAfter"))
      expect_equal(results[["results"]][[tab]][["data"]],
                   reference[["results"]][[tab]][["data"]], label = paste(formula, tab))
  }
})

test_that("Matching does not run without a treatment variable", {
  options <- .defaultOptions("matching")
  options$treatment <- ""
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)
  expect_null(results[["results"]][["SampleSizes"]])
})

test_that("Matched dataset is saved with all columns and matching information", {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path))
  options <- .defaultOptions("matching")
  options$saveDatasetPath <- path
  set.seed(1)
  results <- jaspTools::runAnalysis("matching", testthat::test_path("lalonde.csv"), options)

  expect_true(file.exists(path))
  saved <- utils::read.csv(path)
  expect_equal(nrow(saved), 370)                         # 185 treated + 185 matched controls
  expect_true(all(c("treat", "age", "re78", "weights", "subclass", "distance") %in% colnames(saved)))
  expect_equal(sum(saved$treat == 1), 185)
  expect_null(results[["results"]][["saveDatasetNotice"]])
})
