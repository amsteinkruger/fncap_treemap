# Check out Treemap for a quick demo.

# Get packages.

library(terra)
library(tidyverse)
library(magrittr)

# Get dasta.

#  Get a raster.

dat_raster = "data/TreeMap2016.tif" %>% rast

#  Get a table.

dat_table = "data/Treemap2016_tree_table.csv" %>% read_csv

# Mess around.

dat_raster_categories = cats(dat_raster)[[1]] %>% as_tibble

# Comparing dat_table and dat_raster_categories suggests two things:
#  Value is raster cell ID is tm_id.
#  The geotiff metadata associated with TreeMap2016.tif is richer, somehow, than the database in Treemap2016_tree_table.csv.
#  All of this is for 2016.
#  Uniqueness of observations is not clear from a close look at the data and requires a pass through documentation.
