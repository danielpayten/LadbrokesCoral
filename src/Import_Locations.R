# Author: Daniel Payten
# Email: daniel@danielpayten.com

# Date: 14/5/19
# Purpose: This script is used to import Coral and Ladbrokes store location data from the regulator


### Inputs / Outputs
location_input_file = "./data/raw/premises_licence_database.csv"
location_output_file = "./data/processed/premises_name_address.csv"


######
# Setup
library(tidyr)
library(tidyverse)

# Information has been extracted from: https://secure.gamblingcommission.gov.uk/PublicRegister
raw_store_locations = read.csv(location_input_file,header = TRUE, stringsAsFactors = FALSE)

# Extract only Ladbrokes or Coral stores
store_locations = raw_store_locations %>%
                  dplyr::filter(stringr::str_detect(Account_Name, 'Ladbrokes|Coral'))

remove(raw_store_locations)

# Keep only the Store Type, Location, Postcode, Licence Status,
# Sort the locations by betting company and postcode
# Assign an ID to each for ease of processing
store_locations = store_locations %>%
                  dplyr::select(Account_Name,
                                premises_Address1,
                                premises_Address2,
                                premises_City,
                                premises_Postcode,
                                LicenceStatus,
                                StatusDate) %>%
                  dplyr::arrange(Account_Name,premises_Postcode) %>%
                  dplyr::mutate(id = row_number())

write.csv(store_locations,file = location_output_file,row.names = FALSE)

# remove unneeded variables
remove(location_input_file)
remove(location_output_file)
