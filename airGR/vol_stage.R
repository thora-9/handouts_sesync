vol_stage <- function(vol) {
  stage = log(vol/9.8e-5)/0.056
  
  return(stage)
}