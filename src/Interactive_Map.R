

location_map  =   leaflet::leaflet() %>%
                  leaflet::addProviderTiles("CartoDB.Positron") %>%
                  leaflet::setView(-4.2720184,55.8629824, zoom = 12) %>%
                  leaflet::addMarkers(lng = spatial_store_locations_all@coords[,1],
                                      lat = spatial_store_locations_all@coords[,2],
                                      popup =  paste(spatial_store_locations_all@data$premises_Address1,
                                                     spatial_store_locations_all@data$premises_Address2,
                                                     sep = " ")) %>%
                  leaflet::addCircles(lng = spatial_store_locations_all@coords[,1],
                                      lat = spatial_store_locations_all@coords[,2],
                                      radius = 500,
                                      opacity = 0.5)

location_map

