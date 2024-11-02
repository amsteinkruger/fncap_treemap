# Check out Treemap for a quick demo.

# Get packages.

library(terra)
library(magrittr)
library(readr)

# Get dasta.

#  Get a raster.

dat_raster = "data/TreeMap2016.tif" %>% rast

#  Get a table.

dat_table = "data/Treemap2016_tree_table.csv" %>% read_csv

