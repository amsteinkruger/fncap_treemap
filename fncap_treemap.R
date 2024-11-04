# Check out Treemap for a quick demo.

# Get packages.

library(terra)
library(tidyverse)
library(tidyterra)
library(magrittr)

# Get dasta.

#  Get a raster.

dat_raster = "data/TreeMap/TreeMap2016.tif" %>% rast

#  Get a table.

dat_table = "data/TreeMap/Treemap2016_tree_table.csv" %>% read_csv

# Mess around.

dat_raster_categories = cats(dat_raster)[[1]] %>% as_tibble

# dat_raster_cat = dat_raster
# activeCat(dat_raster_cat) = 10 # STANDHT
# dat_raster_cats = dat_raster %>% catalyze # Categorical layer into multiple continuous layers; incredibly slow, do not use

# Comparing dat_table and dat_raster_categories suggests two things:
#  Value is raster cell ID is tm_id.
#  The geotiff metadata associated with TreeMap2016.tif is richer, somehow, than the database in Treemap2016_tree_table.csv.
#   - this is untrue; the "geotiff metadata" which is actually just data is cell-level, the table is tree (?) level
#  All of this is for 2016.
#  Uniqueness of observations is not clear from a close look at the data and requires a pass through documentation.

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

# next: figure out what to do about attributes (cats(dat_crop)[[1]]) for dropped cells for quicker manipulation
#  - actually don't do that, just figure out more about how terra handles raster attribute tables and don't break anything

# Get a cell/tm_id attribute (like CARBON_L) onto a plot to show it can be manipulated.

activeCat(dat_crop) = 18

dat_crop = dat_crop %>% as.numeric

dat_crop %>% plot

vis_crop =  
  ggplot() + 
  geom_spatraster(data = dat_crop,
                  maxcell = Inf) +
  scale_fill_viridis(option = "mako",
                     na.value = NA) +
  labs(title = "Live Cubic Feet per Acre for Clallam County, WA in TreeMap 2016") +
  theme(legend.title = element_blank())

ggsave("out/vis_crop.png",
       vis_crop,
       dpi = 300,
       width = 6.5,
       bg = "transparent")

# Bring in a fire raster to show some sort of fire data manipulation with TreeMap.
# Get a tree attribute onto a plot to show it can be manipulated.
# Get a tree/condition/plot attribute onto a plot from another year's as-is FIA data to show we can get data a la carte.
# Once raster shenanigans are a little more resolved, figure out how to neatly pull data out of raster format for easier handling

