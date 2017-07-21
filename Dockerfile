#get the base image, this one has R, Rstudio and pandoc
FROM rocker/verse:3.4.1

MAINTAINER Sophie

COPY . /spatialdatatest

RUN . /etc/environment \

  && R --vanilla "devtools::install('/spatialdatatest', dep=TRUE)" \

  && R --vanilla "rmarkdown::render('spatialdatatest/analysis/spat_test.Rmd')" \

 && apt-get update -y \
 && apt-get install -y libudunits2-dev libgdal-dev libgsl0-dev gdal-bin libgeos-dev libpng-dev libproj-dev \

 && R -e "options(repos='https://mran.microsoft.com/snapshot/2017-07-20'); devtools::install('/spatialdata_test', dep = TRUE)" \
 
 && R --vanilla "rmarkdown::render('/spatialdatatest/analysis/spat_test.Rmd')"