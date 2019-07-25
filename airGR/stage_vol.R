stage_vol <- function(stage) {
  vol = 9.8e-05*exp(stage*0.056)
  
  return(vol)
}