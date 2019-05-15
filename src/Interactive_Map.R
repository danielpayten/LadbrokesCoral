

# It is important to use the same coordinate system as the underlying maps, as we will be using google maps


location_map  =   leaflet::leaflet(spatial_store_locations) %>%
                  leaflet::addProviderTiles("CartoDB.Positron") %>%
                  leaflet::fitBounds(0, 40, 10, 50) %>%
                  leaflet::setView(-93.65, 42.0285, zoom = 17) %>%
                  leaflet::addMarkers(lng = spatial_store_locations@coords[,1],
                                      lat = spatial_store_locations@coords[,2],
                                      popup =  paste(spatial_store_locations@data$premises_Address1,
                                                     spatial_store_locations@data$premises_Address2,sep = "\n")

