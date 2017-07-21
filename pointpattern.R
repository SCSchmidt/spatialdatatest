#point pattern

sites <- read.csv("./data/Sites_HarranPlain.csv")
knitr::opts_chunk$set(echo = TRUE)
library(sp)
library(spatstat)
library(rgdal)
library(leaflet)
library(raster)

sites <- read.csv("./data/Sites_HarranPlain.csv", sep=",")
coordinates(sites)<-~X+Y
proj4string(sites) <-CRS("+init=epsg:4326")

sites <- spTransform(sites, CRSobj = CRS("+init=epsg:32637"))#utm 37

sites_ppp <- ppp(x = sites@coords[,1], 
                 y = sites@coords[,2],
                 window = owin(xrange=sites@bbox[1,], yrange=c(min(sites@coords[,2]), min(sites@coords[,2]+60000))))
# Windows definieren mit Bounding Box


sites_ppp <- unique.ppp(sites_ppp) # removes duplicates
anyDuplicated(sites_ppp) # check for duplicates
#sites_ppp <-sites_ppp[!duplicated(sites_ppp)] # gib mir das Gegenteil von den duplicated geht auch

#first order effects

sites_ppp_nn <- nndist(sites_ppp) # distance in m, because its transformed data
str(sites_ppp_nn) 
hist(sites_ppp_nn)
dens_nn <- density(sites_ppp_nn)
sites_ppp_kde<-density.ppp(sites_ppp, sigma=mean(sites_ppp_nn))

#Ways to get a bandwith for KDE:
  bw.ppl(sites_ppp) # first order effects? takes a lokal max :   plot(bw.ppl(sites_ppp))
bw.diggle(sites_ppp) # more clustered?

dem_harran<-raster("./data/dem.tif") # wird als raster geladen
oder
dem_harran <- readGDAL("./data/dem.tif") # wird als SptaialGridDataFrame geladen

hist(dem_harran@data$band1)

rhohat # density in Abähngigkeit zur Kovariaten?

im_dem <- as.im(as.image.SpatialGridDataFrame(dem_harran)) 
# as.image.SpatialGridDataFrame ist nicht das gleiche wie das, was as.im damit macht
# man könnte auch das als raster-geladene ding nehmen und dann sagen (dem, "SpatialGridDataFrame)


str(im_dem)
plot(dem_harran)

sites_rhohat <- rhohat(object = sites_ppp, covariate = im_dem) # Abhängigkeit der siet-density zu Kovariat
# das wird eine Funktion, mit der ich eine neue Dichte simulieren könnte (theoretisch modellieren)
# image muss das gleiche window haben wie unsere ppp
# density of the points is calculated in the background -> continues data -> wie auch beim srtm
#-> funktion bastelbar
plot(sites_rhohat, xlim=c(0,1000)) # Probleme mit dem dings
str(sites_rhohat)

sites_rhohat <- rhohat(object = sites_ppp, covariate = im_dem, bw = 200) 
#bandwith auf die dichteberechnung der sites
plot(sites_rhohat)

rho_dem <- predict(sites_rhohat)
plot(rho_dem)
# prediction des Einflusses der Höhe auf die Punktverteilung 
#first order effect density map

str(sites_ppp)

diff_rho <- sites_ppp_kde - rho_dem
# warning message: images e1 und e2 were not compatible
# egal, weil nur der bereich der punktstreuung benutzt wird
plot(diff_rho)

lambda <- (sites_ppp$n/area.owin(as.owin(sites_ppp)))

sites_rpoispp <-rpoispp(lambda, win=sites_ppp$window)
  # poisson point pattern - complete spatial randomness (no influence of first order, second order or window)
#lambda definiert oben nach anzahl punkte durch area des windows
# window sollte auch immer angegeben werden
plot(sites_rpoispp)

# geht auch einfacher:
set.seed(7)
sites_rpoispp <-rpoispp(ex=sites_ppp)
plot(sites_rpoispp)

#set.seed(zahl) # wenn ich reduzierbare Ergebnisse haben will, dann am Anfang den seed setzen
# damit kriegen andere das gleiche Punktmuster.



#second order effects

sites_g <- Gest(sites_ppp)
str(sites_g)
plot(sites_g)
sites_ge <- envelope(sites_ppp, fun="Gest", nsim=100) # 100 csr simulated
plot(sites_ge) # doch alles random


sites_f <-Fest(sites_ppp)
str(sites_f)
plot(sites_f)
sites_fe <- envelope(sites_ppp, fun="Fest",nsim=50)
plot(sites_fe)

sites_k <-Kest(sites_ppp)
plot(sites_k)
sites_ke <- envelope(sites_ppp, fun="Kest", nsim=500)
plot(sites_ke)


## possible to calculate the F,G and K against an inhomogenous poisson
# when i know, i have a bias because of elevation or something höhe zB
# Kinhom, Finhom, Ginhom -> inhomogenous possoin
# input ein image aus der prediction von rhohat

#Lit: Beverly

sites_ginhom <- Ginhom(sites_ppp, lambda=predict(sites_rhohat))
plot(sites_ginhom)

dev.new()
par(mfrow = c(1,2))
plot(sites_ginhom, xlim=c(0,7000))
plot(sites_g, xlim=c(0,7000))
dev.off()

## ppm-Function -> for putting different paramters and stuff. great stuff!



## backup
dem_harran <- readGDAL("../data/dem.tif")
im_dem <- as.im(as.image.SpatialGridDataFrame(dem_harran))
plot(dem_harran)

sites_rhohat <- rhohat(object = sites_ppp, covariate = im_dem)
plot(sites_rhohat, xlim=c(0,1000))

rho_dem <- predict(sites_rhohat)
plot(rho_dem)

diff_rho <- sites_ppp_kde - rho_dem
plot(diff_rho)

set.seed(5)
sites_rpoispp <-rpoispp(ex=sites_ppp)
plot(sites_rpoispp)