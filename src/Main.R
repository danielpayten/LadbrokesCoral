# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This script is the main script, it calls three stages of analysis;
#           1) Import the locations of Coral and Ladbrokes licenced betting shops
#           2) Attach the latitude and longitude of each of these locations
#              and create a 'spatial data frame' (which is a way to store geographic points),
#              which can easily be plotted on a map
#           3) Calculate the distance between all ladbrokes and coral betting stores.

# It is not called here, but we have created a shiny app, which draws upon this analysis and creates an interactive data visualisation tool.


############# Setup
# Clear the environment (remove any data stored)
rm(list=ls())

############# Call the other scripts
source("./src/Import_Locations.R")
source("./src/Geotag_Locations.R")
source("./src/Distance_Calculation.R")
