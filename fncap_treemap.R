# Check out TreeMap for a quick demo.

# Get packages.

library(terra)
library(tidyverse)
library(viridis)
library(tidyterra)
library(magrittr)

# Get data and demo some basic manipulations.

#  Get a raster.

dat_raster = "data/TreeMap/TreeMap2016.tif" %>% rast

#  Get a table.

dat_table = "data/TreeMap/Treemap2016_tree_table.csv" %>% read_csv

# Get raster attribute table for reference.

dat_raster_categories = cats(dat_raster)[[1]] %>% as_tibble

# Get administrative boundaries to reduce to CA, OR, WA.
dat_boundaries = 
  "data/Admin/S_USA.ALPGeopoliticalUnit.gdb" %>% 
  vect %>% 
  subset(STATENAME == "Washington" & NAME == "Clallam", NSE = TRUE) %>% # STATENAME == "California" | STATENAME == "Oregon" | 
  aggregate %>% 
  project(dat_raster %>% crs) %>% 
  rasterize(crop(dat_raster, .))

# Crop TreeMap.
dat_crop = 
  dat_raster %>% 
  crop(dat_boundaries) %>% 
  mask(dat_boundaries) %>% 
  trim

# Get a cell attribute onto a plot.

dat_carbon_live = dat_crop

activeCat(dat_carbon_live) = 23

dat_carbon_live = dat_carbon_live %>% as.numeric

# dat_carbon_live %>% plot

vis_carbon_live =  
  ggplot() + 
  geom_spatraster(data = dat_carbon_live,
                  maxcell = Inf) +
  scale_fill_viridis(na.value = NA) +
  labs(title = "Live Standing Carbon (Tons/Acre), Clallam County, WA") +
  theme(legend.title = element_blank())

ggsave("out/vis_carbon_live.png",
       vis_carbon_live,
       dpi = 300,
       width = 6,
       height = 4,
       bg = "transparent")

# Get two cell attributes into a raster arithmetic operation, then onto a plot.

dat_carbon_dead = dat_crop

activeCat(dat_carbon_dead) = 24

dat_carbon_dead = dat_carbon_dead %>% as.numeric %>% subst(-99, 0) %>% subst(NA, 0) # Assume NAs are zeros, just for fun.

# dat_carbon_dead %>% plot

dat_carbon_standing = dat_carbon_live + dat_carbon_dead

# dat_carbon_standing %>% plot

vis_carbon_standing = 
  ggplot() + 
  geom_spatraster(data = dat_carbon_standing,
                  maxcell = Inf) +
  scale_fill_viridis(na.value = NA) +
  labs(title = "Standing Carbon (Tons/Acre), Clallam County, WA") +
  theme(legend.title = element_blank())

ggsave("out/vis_carbon_standing.png",
       vis_carbon_standing,
       dpi = 300,
       width = 6.5,
       bg = "transparent")

# Get a fire raster onto the TreeMap raster and into a plot. 

dat_burn = 
  "data/FSIM/WA/BP_WA.tif" %>% 
  rast %>% 
  project(dat_raster %>% crs) %>% 
  crop(dat_boundaries) %>% 
  mask(dat_boundaries) %>% 
  trim %>% 
  resample(dat_carbon_standing)

vis_burn = 
  ggplot() + 
  geom_spatraster(data = dat_burn,
                  maxcell = Inf) +
  scale_fill_viridis(option = "magma",
                     na.value = NA) +
  labs(title = "Burn Probability, Clallam County, WA") +
  theme(legend.title = element_blank())

ggsave("out/vis_burn.png",
       vis_burn,
       dpi = 300,
       width = 6.5,
       bg = "transparent")

# Get a fire raster and a TreeMap cell attribute into a raster statistical operation (try covariance and correlation).

dat_carbon_burn = c(dat_carbon_standing, dat_burn)

dat_carbon_burn_cov = dat_carbon_burn %>% layerCor("cov", asSample = FALSE, use = "complete.obs")
dat_carbon_burn_cor = dat_carbon_burn %>% layerCor("cor", asSample = FALSE, use = "complete.obs")

dat_carbon_burn_cov$covariance[2, 1] # Covariance of tons of standing carbon per acre (c.2016) with annual burn probability (c.2020).
dat_carbon_burn_cor$correlation[2, 1] # Correlation of tons of standing carbon per acre (c.2016) with annual burn probability (c.2020).

# Unfinished steps:
# Get FIA data from outside of TreeMap, crosswalk it to TreeMap ID by CN, and get it onto a plot. 
# Get data out of raster format to demo simpler manipulation once geospatial steps are sorted.
# Extend prior steps to a panel of FIA data.

