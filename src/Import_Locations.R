

# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This script is used to import Coral and Ladbrokes store location data from the regulator

######
# Setup
library(tidyr)
library(tidyverse)

# Information has been extracted from: https://secure.gamblingcommission.gov.uk/PublicRegister

raw_store_locations = read.csv("./data/raw/premises_licence_database.csv",header = TRUE, stringsAsFactors = FALSE)

# Extract only Ladbrokes or Coral stores
store_locations = raw_store_locations %>% 
                  dplyr::filter(stringr::str_detect(Account_Name, 'Ladbrokes|Coral'))


