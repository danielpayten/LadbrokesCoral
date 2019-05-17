
# This script compleates spatial processing on all of the points

# Compute the matrix of distances (Outputs distances in Km.)

# We want the distances between all points, so we find distances
# between between a vector of all points and the vector of all
# points (ie, all combinations)


# matrix with distances between all shops
distance_matrix_full  = sp::spDists(spatial_store_locations_all,
                               spatial_store_locations_all,
                               longlat = TRUE)

# matrix with distance to coral shops from ladbrokes
distance_matrix_ladbrokes_coral  = sp::spDists(spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Ladbrokes Betting & Gaming Limited",],
                                               spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Coral Racing Limited",],
                                      longlat = TRUE)


# Label the matrix
  # Assign store IDs
  colnames(distance_matrix_full) = spatial_store_locations_all@data$id
  rownames(distance_matrix_full) = spatial_store_locations_all@data$id

  colnames(distance_matrix_ladbrokes_coral) = spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Coral Racing Limited",]@data$id
  rownames(distance_matrix_ladbrokes_coral) = spatial_store_locations_all[spatial_store_locations_all@data$Account_Name =="Ladbrokes Betting & Gaming Limited",]@data$id



# Proportion of Ladbrokes stores which have a Coral store within 500m

  raw_distance = data.frame(distance_to_coral_min = apply(distance_matrix_ladbrokes_coral,1, FUN=min))
  raw_distance$id = as.numeric(row.names(raw_distance))
  raw_distance = raw_distance %>% mutate(within_500m = ifelse(distance_to_coral_min <= 0.5, TRUE, FALSE))


  ladbrokes_distance = spatial_store_locations_all@data %>%
                        dplyr::filter(Account_Name=="Ladbrokes Betting & Gaming Limited") %>%
                        dplyr::left_join(raw_distance,by="id")

  remove(raw_distance)


  ladbrokes_distance %>%
    group_by(within_500m) %>%
    summarise (n = n()) %>%
    mutate(freq = n / sum(n))



