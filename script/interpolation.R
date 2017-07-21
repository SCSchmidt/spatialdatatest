# interpolation
library(sp)
library(rgdal)
#library(mapview) das bräuchte ein Paket namens sf, das ist ein Prob mit GIS und Linux
library(leaflet)
library(raster)
library(gstat)
library(automap)

load("../data/Precipitation.RData")
test <- as.data.frame(test)
coordinates(test)=~lon+lat

proj4string(test)<-CRS("+init=epsg:4326") # die daten sind WGS84
test2 <- spTransform(test, CRSobj = CRS("+init=epsg:32634")) # UTM 34 projezieren

#mapview(test2)

srtm <- getData('SRTM', lon=mean(coordinates(test)[,1]), lat=mean(coordinates(test)[,2]))
# erste Spalte der coordinates -> deren Mittelwert, zweite Spalte und deren Mittelwerte
# der speichert es im Arbeitsverzeichnis, aber muss noch reingeladen werden

srtm <-raster("srtm_41_05.tif")
str(srtm)
srtm2 <- raster::aggregate(srtm, fact=10)
srtm_crop <- crop(srtm2, extent(test)+1) 
# crops das raster srtm mit der bounding-box-werten von test + 1
# aus irgend nem grund geht das nicht mit test2 (extents do not overlap - srtm ist noch in WGS84)
# first crop, then project
#srtm_proj <- projectRaster(srtm_crop, crs=CRS("+init=epsg:32634")) auch ein resampled raster ist zu groß dafür

#autokrige <- automap::autoKrige(mean_r~1, test2,
 #                             as(srtm3,"SpatialGridDataFrame"))
# mean_r~1 -> nimm den Mittelwert regen, test 2 -> spatially transformated test,
# as srtm3 -> projezierte srtm als SpatialGridDataFrame behandeln

#rain_krige_brick<-brick(rain_krige)
# brick macht dinge kleiner und performanter weil ein RasterBrick ein mehrlagiges raster-objekt ist
# aber nur mit einem einzelnen file

# tell the srtm that it has the same name as table$altitude
names(srtm_crop)="altitude"
test3 = test2[!is.na(test2$altitude),]

autoked <- autoKrige(mean_r~altitude, test3,
                    as(srtm_crop, "SpatialGridDataFrame"))
