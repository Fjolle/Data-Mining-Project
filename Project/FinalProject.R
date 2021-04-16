happiness <- na.omit(world_happiness_report_2021)

library(tidyverse)


#Healthy life expectancy explained by perceptions of corruption

happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Perceptions_of_corruption,
  color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 1: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by social support


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Social_support, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 2:Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by freedom to make life choices


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Freedom_to_make_life_choices, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 3: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()


#Healthy life expectancy explained by generosity


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Generosity, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 4: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by log GDP per capita


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Log_GDP_per_capita, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 5: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()


