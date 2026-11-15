# stop the analysis with a clear message unless the treatment variable is coded
# 0 (untreated) / 1 (treated), which both analyses rely on
.checkTreatmentCoding=function(dataset, treatment) {
  values=unique(as.character(dataset[[treatment]]))
  values=sort(values[!is.na(values)])
  if (!identical(values, c("0", "1")))
    .quitAnalysis(gettextf(
      "The treatment variable '%1$s' must be coded 0 (untreated) and 1 (treated), but it contains: %2$s.",
      jaspBase::decodeColNames(treatment), paste(values, collapse = ", ")))
}
