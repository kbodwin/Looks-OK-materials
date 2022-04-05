library(tidyverse)

spain_data <- read_delim('elections/data/spain2011.txt', delim  ='\t')

spain_data %>%
  filter(communidad %in% c('MADRID', 'GALICIA')) %>%
  rename(community = communidad ) %>%
  write_csv('elections/data/spain_elections_subset_2011.csv')