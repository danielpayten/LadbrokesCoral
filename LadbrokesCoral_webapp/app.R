rm(list=ls())
library(shiny)
library(leaflet)
library(sp)
library(dplyr)

# inputs
store_locations_input_file = "store_locations.RDS"
ladbrokes_distance_input_file = "ladbrokes_distance.RDS"
ladbrokes_icon_input_file = "ladbrokes.png"
coral_icon_input_file = "coral.png"


# read in inputs
spatial_store_locations_all = readRDS(store_locations_input_file)
ladbrokes_distance = readRDS(ladbrokes_distance_input_file)

# create ladbrokes and coral icons
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

# assign each store to a marker typr
spatial_store_locations_all@data$marker_type = factor(
  dplyr::case_when(
    spatial_store_locations_all@data$Account_Name == "Coral Racing Limited" ~ "coral",
    spatial_store_locations_all@data$Account_Name == "Ladbrokes Betting & Gaming Limited" ~ "ladbrokes"
  ),
  c("coral", "ladbrokes")
)


ui =  basicPage(
  titlePanel("Ladbrokes Coral merger analysis"),
  hr(),
  sidebarPanel(p(strong("About")),
               p("The map on the right shows all licenced Coral and Ladbrokes betting shops throughout the UK."),
               p("Clicking any of these locations will show the name and street address of the shop. It will also draw a circle around the location to represent the catchment area or local market of the shop."),
               p("This catchment area has initially been set at a 500m radius. However, this can be changed using the slider below."),
               sliderInput("radius", "Catchment radius (m)",
                           min = 0, max = 1000,
                           value = 500),
               hr(),
               p(strong("Ladbrokes shops, with a coral shop in catchment radius")),
               p("If a merger were to occur, Ladbrokes and Coral would likely no longer compete directly."),
               p("We can get an indication of the number local markets in which competition is lessened by looking at the number (and proportion) of Ladbrokes stores which have a Coral store nearby (which would likely result in reduced local competiton) as shown in the table below."),
               tableOutput('table')
               ),
  mainPanel(leafletOutput("location_map_interactive",height = 600))
)

server <- function(input, output, session) {

  output$table = renderTable({

    ladbrokes_distance = ladbrokes_distance %>% dplyr::mutate(within_x = ifelse(distance_to_coral_min <= (input$radius/1000), "Coral within catchment", "No coral within catchment"))

    ladbrokes_distance = ladbrokes_distance %>%
      dplyr::group_by(within_x) %>%
      dplyr::summarise (n = n()) %>%
      dplyr::mutate(freq = n / sum(n))

    colnames(ladbrokes_distance) = c("Ladbrokes stores","Count","Proportion")

    ladbrokes_distance

  })

  output$location_map_interactive <- renderLeaflet({
      leaflet::leaflet(spatial_store_locations_all) %>%
        leaflet::addProviderTiles("CartoDB.Positron") %>%
        leaflet::setView(-4.2720184,55.8629824, zoom = 12) %>%
        leaflet::addMarkers(lng = spatial_store_locations_all@coords[,1],
                            lat = spatial_store_locations_all@coords[,2],
                            popup =  paste(spatial_store_locations_all@data$premises_Address1,
                                         spatial_store_locations_all@data$premises_Address2,
                                         sep = " "),
                            group =spatial_store_locations_all@data$Account_Name,
                            layerId = spatial_store_locations_all@data$id,
                            icon= ~store_icons[marker_type]

                            ) %>%
      addLayersControl(
        overlayGroups = c("Coral Racing Limited", "Ladbrokes Betting & Gaming Limited"),
        options = layersControlOptions(collapsed = FALSE)
      )

  })

    observeEvent(input$location_map_interactive_marker_click, {
      # We first identify the point that was clicked, print it to console and assign to 'id'
      print(input$location_map_interactive_marker_click$id)
      id = input$location_map_interactive_marker_click$id

      # Rather than redrawing
      proxy = leaflet::leafletProxy("location_map_interactive")
      proxy = proxy %>% leaflet::removeMarker( layerId="circle")
      proxy %>%  leaflet::addCircles(lng = spatial_store_locations_all@coords[id,1],
                                    lat = spatial_store_locations_all@coords[id,2],
                                    radius = input$radius,
                                    opacity = 0.25,
                                    color = "blue",
                                    group = spatial_store_locations_all@data$Account_Name[id],
                                    layerId = "circle")
    })



}

shinyApp(ui, server)
