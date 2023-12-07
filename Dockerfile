# Base image davidedge/lipdwebapps:lipdBase
FROM davidedge/lipd_webapps:lipdbase2

## copy files
COPY regional_composites.R regional_composites.R
COPY params.json params.json

## run Recon
CMD Rscript /regional_composites.R

COPY output/ output/

#run from temp12k directory (must include an 'output' folder)
#docker run -it --rm -v ~/"R-Script in Docker"/output:/output davidedge/lipd_webapps:temp12k
