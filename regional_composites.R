print("Initiating environment...")

suppressWarnings(suppressPackageStartupMessages(library(lipdR))) #to read and interact with LiPD data
suppressWarnings(suppressPackageStartupMessages(library(geoChronR))) #for plotting mostly
suppressWarnings(suppressPackageStartupMessages(library(magrittr))) #we'll be using the magrittr pipe ( %>% ) for simplicity
suppressWarnings(suppressPackageStartupMessages(library(dplyr))) #and dplyr for data.frame manipulation
suppressWarnings(suppressPackageStartupMessages(library(ggplot2))) #for plotting
suppressWarnings(suppressPackageStartupMessages(library(compositeR))) #remotes::install_github("nickmckay/compositeR")
#suppressWarnings(suppressPackageStartupMessages(library(foreach))) #for parallel processing
#suppressWarnings(suppressPackageStartupMessages(library(doParallel)))#for parallel processing
suppressWarnings(suppressPackageStartupMessages(library(jsonlite))) # to read in parameters
suppressWarnings(suppressPackageStartupMessages(library(purrr)))
suppressWarnings(suppressPackageStartupMessages(library(readr)))



print("Script starting...")

print(getwd())

#get parameters
params <- jsonlite::read_json("params.json")

print("reconsturction parameters:")
print(params)

#D <- readLipd("https://lipdverse.org/Temp12k/1_0_2/Temp12k1_0_2.zip")
D <- readRDS("lipd.rds")

print("Filtering data")
TS <- as.lipdTsTibble(D) %>% # and the then to lipd-ts-tibble for filtering
  filter(between(geo_longitude,params$lonRange[[1]],params$lonRange[[2]])) %>%
  filter(between(geo_latitude,params$latRange[[1]],params$latRange[[2]])) %>%
  filter(interpretation1_variable == params$interpVariable) %>% #only variables sensitive temperature
  filter(paleoData_medianRes12k < params$maxResolution) %>% #only time series at highres
  filter(interpretation1_seasonalityGeneral == params$seasonalityGeneral) %>% #only summer proxies
  as.lipdTs() #back to TS for compositeR


#bin the TS
binvec <-  seq(from = params$binstart, to = params$binend,by = params$binstep)
binYears <- rowMeans(cbind(binvec[-1],binvec[-length(binvec)]))


#setup ensemble
nens <- params$nens

print("Building Ensembles")
if(params$ncores > 1){

registerDoParallel(params$ncores)

ensOut <- foreach(i = 1:nens) %dopar% {
  tc <- compositeR::compositeEnsembles(TS,
                           binvec,
                           stanFun = compositeR::standardizeMeanIteratively,
                           binFun = compositeR::simpleBinTs,
                           ageVar = params$ageVar,
                           alignInterpDirection = params$alignInterpDirection,
                           spread = params$spread,
                           duration = params$duration,
                           searchRange = c(params$searchRange[[1]],params$searchRange[[2]]),
                           normalizeVariance = params$normalizeVariance)

  return(list(composite = tc$composite,count = tc$count, timeCount = tc$timeCount))
}

}else{
  ensOut <- purrr::rerun(nens,compositeR::compositeEnsembles(fTS = TS,
                           binvec = binvec,
                           stanFun = compositeR::standardizeMeanIteratively,
                           binFun = compositeR::simpleBinTs,
                           ageVar = params$ageVar,
                           alignInterpDirection = params$alignInterpDirection,
                           spread = params$spread,
                           duration = params$duration,
                           searchRange = c(params$searchRange[[1]],params$searchRange[[2]]),
                           normalizeVariance = params$normalizeVariance))
}

#extract ensemble
thisComposite <-  as.matrix(purrr::map_dfc(ensOut,extract,"composite"))

outComposite <- cbind(binYears,thisComposite) %>%
  as.data.frame() %>%
  setNames(c(params$ageVar,paste0("ens",seq_len(params$nens))))


print("Creating Plot")
compPlot <- plotTimeseriesEnsRibbons(X = binYears,Y = thisComposite,limit.outliers.x = 0)+
  scale_x_reverse(params$ageVar,oob = scales::squish)+
  scale_y_continuous("Composite",oob = scales::squish)+
  theme_bw()

recEns <- purrr::map_dfc(ensOut,extract,"count")

rnames <- pullTsVariable(TS,"dataSetName")
outRecs <- bind_cols(rnames,recEns) %>%
  setNames(c("DataSetName",paste0("ens",seq_len(params$nens))))

densEns <- purrr::map_dfc(ensOut,extract,"timeCount")

outDens <- bind_cols(binYears,densEns) %>%
setNames(c(params$ageVar,paste0("ens",seq_len(params$nens))))

meanDensity <- rowMeans(as.matrix(densEns))
 densPlot <- ggplot() + geom_area(aes(x = binYears, y = meanDensity),alpha = 0.7) +
   scale_x_reverse(params$ageVar,oob = scales::squish,expand = c(0,0))+
   scale_y_continuous("Number of records",oob = scales::squish)+
   theme_bw()

outPlot <- egg::ggarrange(plots = list(compPlot,densPlot),nrow = 2,heights = c(.8,.2))



if(!dir.exists(params$outDir)){
  dir.create(params$outDir)
}

print(paste0("Saving Output to: ", params$outDir))

ggsave(outPlot,filename = file.path(params$outDir,"compositePlot.pdf"))

readr::write_csv(outComposite,file.path(params$outDir,"compositeEnsemble.csv"))
readr::write_csv(outDens,file.path(params$outDir,"densityEnsemble.csv"))
readr::write_csv(outRecs,file.path(params$outDir,"recEnsemble.csv"))

print("Complete!")
