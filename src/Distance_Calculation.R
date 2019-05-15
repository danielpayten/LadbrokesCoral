
# This script compleates spatial processing on all of the points

# Compute the matrix of distances (Outputs distances in Km.)
distance_matrix  = sp::spDists(spatial_store_locations,spatial_store_locations,longlat = TRUE)

# Label the matrix

  # Create names
store_names =   paste(spatial_store_locations@data$premises_Address1,
                      spatial_store_locations@data$premises_Address2,
                      sep = " ")
  # Assign names
  colnames(distance_matrix) = store_names
  rownames(distance_matrix) = store_names

  # Remove the names, now that they have been assigned
  remove(store_names)


# Compute a polygon surrounding each point in a 1km radius.
a = rgeos::gBuffer(spatial_store_locations,FALSE,width = 0.5)



distGeo
