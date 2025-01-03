##### BVerfG
##### Referee
##### Provisional Analysis
##### 240129

##### HOUSEKEEPING ----
##### clean
rm(list = ls())

##### load libraries
library(stringr)
library(dplyr)
library(tidyr)
library(ggplot2)
theme_update(plot.title = element_text(hjust = 0.5))

##### set working directory
setwd("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/")

##### load prepared data
load("bverfg240129.RData")

##### drop (very few datapoints) from plenary and complaint chambers
  # for cleaner graphs
bverfg %>% 
  filter(body != "complaint",
         body != "plenary") -> bverfg

##### KEYWORD RESULTS ----
  ##### senate 1 ----
bverfg %>% 
  filter(senate == 1) -> bverfg1

freq_table <- table(bverfg1$sumref,
                    bverfg1$body)

# Convert table to data frame
df_freq <- as.data.frame(freq_table)
df_freq <- rename(df_freq, candidates = Var1,
                  freq = Freq, body = Var2)

# Create plot
ggplot(df_freq, aes(x = factor(candidates), y = freq,
       fill = body, color = body, label = freq)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(vjust = ifelse(df_freq$freq == 0, 1, -1),
            hjust = .5,
            position = position_dodge(width = .9)) +
  labs(x = "candidates", y = "frequency") +
  ylim(-50, 2400) +
  ggtitle("senate 1") +
  theme(legend.position = "bottom",
        legend.title = element_blank())

  ##### senate 2 ----
bverfg %>% 
  filter(senate == 2) -> bverfg2

freq_table <- table(bverfg2$sumref2,
                    bverfg2$body)

# Convert table to data frame
df_freq <- as.data.frame(freq_table)
df_freq <- rename(df_freq, candidates = Var1,
                  freq = Freq, body = Var2)

# Create plot
ggplot(df_freq, aes(x = factor(candidates), y = freq,
       fill = body, color = body, label = freq)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(vjust = ifelse(df_freq$freq == 0, 1, -1),
            hjust = .5,
            position = position_dodge(width = .9)) +
  labs(x = "candidates", y = "frequency") +
  ylim(-50, 1500) +
  ggtitle("senate 2") +
  theme(legend.position = "bottom",
        legend.title = element_blank())



