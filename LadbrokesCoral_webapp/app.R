# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This shiny app creates a web app to visualise the locations of Ladbrokes and Coral stores.

# Method: This script loads in the spatial dataframe and distances to Coral from each Ladbrokes store
#         It then plots these points on a leaflet map.
#         Additionally, a radius is drawn around each location.
#         Also, a table is displayed with the proportion of Ladbrokes stores with a coral within their radius.

############# Setup
# clear all data in environment
rm(list=ls())


# attach libraries
library(shiny)
library(leaflet)
library(sp)
library(dplyr)

############# Declare Inputs
store_locations_input_file = "store_locations.RDS"
ladbrokes_distance_input_file = "ladbrokes_distance.RDS"
ladbrokes_icon_input_file = "ladbrokes.png"
coral_icon_input_file = "coral.png"


############# Load in data
spatial_store_locations_all = readRDS(store_locations_input_file)
ladbrokes_distance = readRDS(ladbrokes_distance_input_file)

############# Create icons
# create ladbrokes and coral icons for inclusion on the map.
store_icons = iconList(
  ladbrokes = makeIcon(
            iconUrl = ladbrokes_icon_input_file,
            iconWidth = 33, iconHeight =45,
            iconAnchorX = 16.5, iconAnchorY = 45
                   ),
  coral    = makeIcon(
            iconUrl = coral_icon_input_file,
            iconWidth = 33, iconHeight =45,
            iconAnchorX = 16.5, iconAnchorY = 45
  )
)

############ Assign each store to a marker type
spatial_store_locations_all@data$marker_type = factor(
  dplyr::case_when(
    spatial_store_locations_all@data$Account_Name == "Coral Racing Limited" ~ "coral",
    spatial_store_locations_all@data$Account_Name == "Ladbrokes Betting & Gaming Limited" ~ "ladbrokes"
  ),
  c("coral", "ladbrokes")
)



############ Setup user interface for the web app
ui =  basicPage(

  # Title block
  titlePanel("Ladbrokes Coral merger analysis"),

  # Horizontal line
  hr(),
  sidebarPanel(#p(strong("About")),
               p("The map on the right shows all licenced Coral and Ladbrokes betting shops throughout the UK."),
               p("Clicking any of these locations will show the name and street address of the shop. It will also draw a circle around the location to represent the catchment area or local market of the shop."),
               p("This catchment area has initially been set at a 500m radius. However, this can be changed using the slider below."),

  # This slider is an input for our server block later
               sliderInput("radius", "Catchment radius (m)",
                           min = 0, max = 1000,
                           value = 500),
               hr(),
               p(strong("Ladbrokes shops, with a coral shop in catchment radius")),
               p("If a merger were to occur, Ladbrokes and Coral would likely no longer compete directly."),
               p("We can get an indication of the number local markets in which competition is lessened by looking at the number (and proportion) of Ladbrokes stores which have a Coral store nearby (which would likely result in reduced local competition) as shown in the table below."),
               tableOutput('table')
               ),
  # This shows the output generated from the server block
  mainPanel(leafletOutput("location_map_interactive",height = 600))
)

server <- function(input, output, session) {


########## Render the frequency table

  # Render the table showing the proportion of Ladbrokes stores which have a coral store within their radius
  output$table = renderTable({

    # Generate a True False flag, is a coral store within the radius of the ladbrokes store?
    ladbrokes_distance = ladbrokes_distance %>% dplyr::mutate(within_x = ifelse(distance_to_coral_min <= (input$radius/1000), "Coral within catchment", "No coral within catchment"))

    # Output the count and frequency of the true false flag
    ladbrokes_distance = ladbrokes_distance %>%
      dplyr::group_by(within_x) %>%
      dplyr::summarise (n = n()) %>%
      dplyr::mutate(freq = (n / sum(n))*100)

    # Rename the columns of the frequency table, so that it is pretty for the user interface
    colnames(ladbrokes_distance) = c("Ladbrokes stores","Count","Proportion")

    # Correct the display to a percentage
    ladbrokes_distance$Proportion = paste(as.character(round(ladbrokes_distance$Proportion,1)),"%")

    # Actually display the table, so that it is stored as an output and can be put on the web app page.
    ladbrokes_distance

  })

########## Render the map
  output$location_map_interactive <- renderLeaflet({

    # Load data into a map
        leaflet::leaflet(spatial_store_locations_all) %>%
    # Add a base map (underlying street map)
        leaflet::addProviderTiles("CartoDB.Positron") %>%
    # Set focus positon to Glasgow
      leaflet::setView(-4.2720184,55.8629824, zoom = 12) %>%
    # Add markers for each shop
      leaflet::addMarkers(lng = spatial_store_locations_all@coords[,1],
                          lat = spatial_store_locations_all@coords[,2],
                          # Add shop name and address
                          popup =  paste(spatial_store_locations_all@data$premises_Address1,
                                         spatial_store_locations_all@data$premises_Address2,
                                         sep = " "),
                          # Divide ladbrokes and coral into groups, so that we can turn off and on the layer
                          group =spatial_store_locations_all@data$Account_Name,
                          # Set the layer id to the store ID so that we can match mouse clicks to the relevent store
                          layerId = spatial_store_locations_all@data$id,
                          # Set the marker to the correct type for each point
                          icon= ~store_icons[marker_type]
                          ) %>%
      # Add a control, to enable us to select/ deselect all coral and ladbrokes stores
      addLayersControl(
        overlayGroups = c("Coral Racing Limited", "Ladbrokes Betting & Gaming Limited"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })


######### Identify the clicked store and add a radius if clicked

observeEvent(input$location_map_interactive_marker_click, {
      # We first identify the point that was clicked, print it to console and assign to 'id'
      print(input$location_map_interactive_marker_click$id)
      id = input$location_map_interactive_marker_click$id

      # Rather than redrawing, this code block updates the existing map render

      # set proxy to the existing map
      proxy = leaflet::leafletProxy("location_map_interactive")

      # remove all existing circles (from the last one that was clicked)
      proxy = proxy %>% leaflet::removeMarker( layerId="circle")

      # add a circle to the new point that was just clicked
      proxy %>%  leaflet::addCircles(lng = spatial_store_locations_all@coords[id,1],
                                    lat = spatial_store_locations_all@coords[id,2],

                                    # Radius is defined dynamically by the slider input
                                    radius = input$radius,
                                    opacity = 0.25,
                                    color = "blue",
                                    group = spatial_store_locations_all@data$Account_Name[id],
                                    layerId = "circle")
    })



}

# Run the app (use the UI and server to run the shiny app)
shinyApp(ui, server)
