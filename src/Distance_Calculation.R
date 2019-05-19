# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This script computes the distances between ladbrokes and coral stores (all pairs)
#          In addition to this, a full matrix of distances is generated (although not used)

# Method: This script loads in the spatial dataframe and creates a matrix of distances
#         between ladbrokes and coral stores. Output is given in km.

############# Setup
# clear all data in environment
rm(list=ls())

# attach libraries
library(tidyr)
library(tidyverse)
library(sp)

############# Declare Inputs / Outputs

# Location which the store locations spatial dataframe is loaded from
store_locations_all_input_file = "./data/processed/store_locations.RDS"

# Location which the distance matrix will be stored.
ladbrokes_distance_output_file = "./data/processed/ladbrokes_distance.RDS"

############# Load in data

# Load in the spatial dataframe of store locations
spatial_store_locations_all = readRDS(file = store_locations_all_input_file)


############# Compute the distance matrix

# We want the distances between all points, so we find distances
# between between a vector of all points and the vector of all
# points (ie, all combinations)

# matrix with distances between all shops
distance_matrix_full  = sp::spDists(spatial_store_locations_all,
                               spatial_store_locations_all,
                               longlat = TRUE)

# We want the distances between all Ladbrokes stores and coral stores
# so we find distances between between a vector of all ladbrokes stores
# and the vector of all coral stores.

# matrix with distance to coral shops from ladbrokes
distance_matrix_ladbrokes_coral  = sp::spDists(spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Ladbrokes Betting & Gaming Limited",],
                                               spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Coral Racing Limited",],
                                               longlat = TRUE)


############# Label the distance matrix for ease of interpretation
  # Assign store IDs
  colnames(distance_matrix_full) = spatial_store_locations_all@data$id
  rownames(distance_matrix_full) = spatial_store_locations_all@data$id

  colnames(distance_matrix_ladbrokes_coral) = spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Coral Racing Limited",]@data$id
  rownames(distance_matrix_ladbrokes_coral) = spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Ladbrokes Betting & Gaming Limited",]@data$id


############# Compute the proportion of Ladbrokes stores which have a Coral store within 500m

  # Find the distance to the closest coral store for each Ladbrokes store and store it in the dataframe
  raw_distance = data.frame(
                  distance_to_coral_min = apply(distance_matrix_ladbrokes_coral,1, FUN=min)
                  )

  # Attach the store ID variable to the dataframe
  raw_distance$id = as.numeric(row.names(raw_distance))
  raw_distance = raw_distance %>% mutate(within_500m = ifelse(distance_to_coral_min <= 0.5, TRUE, FALSE))

####### Store data

  # For conveniance, we also attach this distance data to the full set  of information about each ladbrokes store
  # Note: we source this information from the spatial dataframe
  ladbrokes_distance = spatial_store_locations_all@data %>%
                        dplyr::filter(Account_Name=="Ladbrokes Betting & Gaming Limited") %>%
                        dplyr::left_join(raw_distance,by="id")

  remove(raw_distance)


  # We now calculate the proportion of Ladbrokes stores which have a coral within 500m
  ladbrokes_distance %>%
    group_by(within_500m) %>%
    summarise (n = n()) %>%
    mutate(freq = n / sum(n))
  # output is in a table format, printed to the console.


############# Save output
  ### Save ladbrokes distance for use in the shiny app
  saveRDS(ladbrokes_distance,file = ladbrokes_distance_output_file)

############# Cleanup
  remove(store_locations_all_input_file)
  remove(ladbrokes_distance_output_file)
  remove(distance_matrix_ladbrokes_coral)

  # if we want the distance between all stores, we would keep this file and save it
  remove(distance_matrix_full)



