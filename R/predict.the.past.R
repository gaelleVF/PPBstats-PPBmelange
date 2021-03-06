# 0. help ----------
#' Estimate value of a germplasm in an environment based on the FWH model.
#'
#' @description
#' \code{predict.the.past} estimates value of a germplasm in an environment based on the FWH model.
#' 
#' @param out.analyse.outputs object from \code{analyse.outputs}
#' 
#' @param output.format Format of the output: "summary" or "raw". See details.
#' 
#' 
#' @return The function returns a list with for each environment, the estimated value of the germplasms that were not grown in this environment.
#' 
#' @details
#' The estimations of the values are based on the MCMC outputs.
#' More informations can be found in the vignette (type vignette("PPBstats")).
#' 
#' Due to memory issues, it may be better to choose output.format = "summary".
#' This allows caterpillar plots, barplots and interaction plots but no mean comparisons that are based on the whole MCMC.
#' 
#' @author Pierre Riviere
#' 
#' @seealso \code{\link{FWH}}, \code{\link{analyse.outputs}}
#' 
#' 
predict.the.past = function(
  out.analyse.outputs,
  output.format = "summary"
)
  # let's go !!! ----------
{
  # 1. Error message ----------  
  if( !is.element(output.format, c("summary", "raw")) ) {  stop("output.format must be either \"summary\" or \"raw\".") }
  
  mess = "out.analyse.outputs must come from PPBstats::analyse.outputs."
  MCMC = out.analyse.outputs$MCMC
  if(is.null(MCMC)) { stop(mess) }
  if(is.null(attributes(MCMC)$model)) { mess }
    
  # 3. Get the estimation based on MCMC outputs ----------
  
  w = out.analyse.outputs$model2.presence.abscence.matrix
  if(is.null(w)) { stop(paste(mess, "Argument analysis in analyse.outputs must be NULL or \"experimental.design\".")) }
  
  pb <- txtProgressBar(min = 0, max = ncol(w), style = 3)
  
  if( output.format == "summary") { OUT = c(1:7) } else { OUT = c(1, nrow(MCMC)) }
  n = NULL
  
  for(j in 1:ncol(w)) { 
    env = colnames(w)[j]
    germ = rownames(w)[which(w[,j] == 0)]
    
    if(length(germ) > 0) { # if length(geno) == 0, it means no germplasms must be estimated
      for (i in 1:length(germ)) {
        if (is.element(paste("alpha","[",germ[i],"]",sep=""), colnames(MCMC)) & is.element(paste("theta","[",env,"]",sep=""), colnames(MCMC)))  {
          estimated.value = MCMC[,paste("alpha[",germ[i],"]",sep="")] + MCMC[,paste("beta[",germ[i],"]",sep="")] * MCMC[,paste("theta[",env,"]",sep="")]
          if( output.format == "summary") { estimated.value = quantile(estimated.value, probs=c(0, 0.05, 0.10, 0.50, 0.90, 0.95, 1)) }
          
          OUT = rbind.data.frame(OUT, estimated.value)
          n = c(n, paste("[", germ[i], ",", env,"]", sep = ""))
        } else { warning("Estimated value for germplasm ", germ, " in environment ", env, " is not possible. This is because the estimation of germplasm and or environment effects did not converge and therefore were not in the MCMC.") 
        }
      }
    }
    setTxtProgressBar(pb, j)
  }
  
  OUT = OUT[-1,]
  colnames(OUT) = c("0", "0.05", "0.10", "0.50", "0.90", "0.95", "1")
  OUT$parameter = n
  
  attributes(OUT)$PPBstats.object = "predict.the.past"  
  return(OUT)
}
