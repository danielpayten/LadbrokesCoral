# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This script is used to match each of the stores to a postcode and attach that postcode coordinates to the dataframe
# Method: Load in both the locations and postcode information and join the postcode centeroids onto the store information
# Note: This script manually overwrites the postcode of one coral store which was listed incorrectly on the government register.

############# Setup
# clear all data in environment
rm(list=ls())

# attach libraries
library(tidyr)
library(tidyverse)
library(sp)


############# Declare Inputs / Outputs
# Input file specifying the names and addresses of all relevent premises
location_input_file = "./data/processed/premises_name_address.csv"

# Input file specifying the centeroids of all postcodes in the UK
# Source: https://geoportal.statistics.gov.uk/datasets/ons-postcode-directory-latest-centroids
postcode_input_file = "./data/raw/ONS_postcode_centroids.csv"

# Output file, with geotagged stores
store_locations_all_output_file = "./data/processed/store_locations.RDS"



############# Load in data
# Load the postcode centeroid data
raw_postcode_centeroids = read.csv(postcode_input_file,header = TRUE,stringsAsFactors = FALSE)

# Select only the relevent colums (latitude, longitude and postcode ID)
postcode_centeroids = raw_postcode_centeroids %>%
                      dplyr::select(X,
                                    Y,
                                    pcd)
# Remove the raw data from memory
remove(raw_postcode_centeroids)

# Load in the store locations, which was prepered earlier
store_locations = read.csv(location_input_file,header = TRUE,stringsAsFactors = FALSE)


############# Clean data in preperation to join postcodes to stores
# For consistency, we remove spaces in postcodes of the centeroid file and so that we can join them to stores
postcode_centeroids = postcode_centeroids %>%
                  mutate(pcd = gsub(" ", "", pcd))

# Rename the postcode variable to 'pcd' so that we can link the two (matching name)
store_locations = store_locations  %>%
                  rename(pcd = premises_Postcode)

# For consistency, we remove spaces in postcodes of the store file
store_locations = store_locations %>%
  mutate(pcd = gsub(" ", "", pcd))


############# Manual change to correct an error in the national register

# One of the Coral stores has had the incorrect postcode listed on the registry.
    # Coral
    # 30 Bush Lane
    # LONDON
    # EC4R 0AN

    # 30 Bush Lane is actually in EC4R 0AN
    # Source: https://www.royalmail.com/find-a-postcode

store_locations[(is.na(store_locations$X))==TRUE,]

# Manual change to overwrite incorrect data.
store_locations[ (store_locations$premises_Address2 == "30 Bush Lane" &
                  store_locations$pcd == "EC4N0AN")==TRUE
                    ,]$pcd = "EC4R0AN"


############# Join postcode centeroids to the store locations file & check

store_locations = left_join(store_locations ,postcode_centeroids, by = "pcd")

# check to make sure that each of the stores has been joined successfully

if (sum(is.na(store_locations$X)==TRUE) ==0) {
  print("All stores have been geotaged")
  remove(postcode_centeroids)
} else {
  print("Geotagging incomplete")
}

############# Create a spatial dataframe
# A spatial dataframe contains, the coordinate points, and the data associated with those points.
# However, it also requires the spaial coordinate system to be set.
# ONS specifies their spatial reference as WGS84


spatial_store_locations_all = sp::SpatialPointsDataFrame(
                                coords = select(store_locations, "X", "Y") ,     #select coordinates from dataframe
                                data = select(store_locations, -c("X","Y")),   #select all but coordinates (everything else)
                                proj4string = sp::CRS("+init=epsg:4326"))

# save the spatial dataframe
saveRDS(spatial_store_locations_all,file = store_locations_all_output_file)


############# Cleanup
remove(store_locations)
remove(location_input_file)
remove(postcode_input_file)
remove(store_locations_all_output_file)

