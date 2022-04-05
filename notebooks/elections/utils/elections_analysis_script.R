library(tidyverse)

data <- read_csv('elections/data/spain_elections_subset_2011.csv')

## Select which municipalities had more invalidBallots than emptyBallots
## Version C --> Correct 
## Version B --> Incorrect evaluation but the select/unique correct
## Version A --> Incorrect evaluation and incorrect select/unique (probably unique directly)

data %>%
  filter(emptyBallots > invalidBallots) %>%
  distinct(municipality) %>%
  nrow()

## Select municipalities in which the ballotsLeader gained the majority of the votes
## Version C --> Correct
## Version B --> Doesn't calculate the majority
## Version A --> Doesn't calculate the majority and does the evaluation incorrectly

data %>%
  mutate(majority = registeredVoters/2) %>%
  filter(ballotsLeader > majority)

## Count the number of precincts by province
## Version C --> Correct
## Version B --> Doesn't use tally and uses count(precinct)
## Version A --> Doesn't group_by and uses count(precint)
data %>%
  group_by(province) %>%
  tally()

## Replace ñ with n to join with spatial data
## Version C --> Correct
## Version B --> Does the correct replacement, doesn't do assignment
## Version A --> Doesn't do the correct replacement (confuses order) and doesn't do assignment

data %>%
  mutate(municipality = str_replace_all(municipality, 'ñ', 'n'))

## Find the top 5 precints in each community with more support for the leader
## Version C --> Correct
## Version B --> Confuses the order of (mutate --> group_by --> mutate)
## Version A --> Same as B plus doesn't get the top_n

data %>%
  mutate(pct_leader = ballotsLeader/validBallots) %>%
  group_by(community) %>%
  mutate(mean_pct_leader = mean(pct_leader),
         sd_pct_leader = sd(pct_leader),
         up_pct_leader = mean_pct_leader+2*sd_pct_leader) %>%
  filter(pct_leader > up_pct_leader) %>%
  top_n(5, pct_leader)


## Visualize the total number of registered voters per community
## Version C --> Correct
## Version B --> Forgets the stat = identity argument
## Version A --> Uses geom_boxplot() instead of geom_bar()

data %>%
  ggplot(aes(x = community, y = registeredVoters)) +
    geom_bar(stat = 'identity')

## Visualize the distribution of the percentage of people that voted for the Leader in each communith
## Version C --> Correct
## Version B --> Visualizes ballotsLeader directly
## Version A --> Doesn't use geom_histogram, uses geom_line

data %>%
  mutate(pct_leader = ballotsLeader/validBallots) %>%
  ggplot(aes(x = pct_leader, y = community)) +
    geom_line()

## We want to explore if there is a linear relationship between the number
## of registered Voters in a precinct and the number of invalidBallots.
## Version C --> Correct
## Version B --> We don't filter by registeredVoters
## Version A --> We don't filter and we don't add method = 'lm'

data %>%
  filter(registeredVoters < 50000) %>%
  ggplot(aes(x = registeredVoters, y = invalidBallots)) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = 'lm')

## We want to see if there is an association between the province and the number of votes the Leader will receive. 
## Version C --> Correct, we can say that in Ourense and Pontevedra there is an effect on the number of votes
## Version B --> Incorrect, we can only say that in Lugo there was an association
## Version A --> Incorrect, there was no association at all

data %>%
  filter(community == 'GALICIA') %>%
  lm(ballotsLeader ~ province, data = .) %>% 
  summary()

## We want to see the relationship between the percentage of people that voted 
## for the leader and the percentage of people that voted in each precinct to see
## if in places with higher abstention is associated with lesser support for the Leader.
## Version C --> Correct
## Version B --> Doesn't do the data wrangling correctly
## Version A --> Let'd geom_smooth() choose the regression method, and uses validBallots as the predictor

data %>%
  mutate(pct_leader = ballotsLeader/validBallots,
         pct_voted = (validBallots + invalidBallots)/registeredVoters) %>%
  ggplot(aes(x = pct_voted, y = pct_leader)) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = 'lm')