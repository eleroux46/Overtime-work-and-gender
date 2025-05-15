library(haven)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)

### This code outputs all the graphs required for descriptive statistics

base1 <- read.csv("C:/Users/Public/Documents/Leroux_Mayans/Data/base_finale2_2.csv")

base <- base1

base <- base %>% filter(NBR_COMPLET !=1)

base <- base %>%
  mutate(
    SHARE_HSUP = NBR_HSUP / NBR_COMPLET,
    SHARE_HSUP_1SEM = NBR_HSUP_1SEM / NBR_COMPLET,
    SHARE_HSUP_2SEM = NBR_HSUP_2SEM / NBR_COMPLET,
    SHARE_HSUP_3SEM = NBR_HSUP_3SEM / NBR_COMPLET,
    SHARE_HSUP_4SEM = NBR_HSUP_4SEM / NBR_COMPLET,
    SHARE_HSUP_5SEM = NBR_HSUP_5SEM / NBR_COMPLET,
    SHARE_HSUP_6SEM = NBR_HSUP_6SEM / NBR_COMPLET
  )

base = base %>%
  mutate(DIFF_SHARE_6S= NBR_HSUP_6SEM_H/NBR_H - NBR_HSUP_6SEM_F/NBR_F,
         DIFF_SHARE_5S= NBR_HSUP_5SEM_H/NBR_H - NBR_HSUP_5SEM_F/NBR_F,
         DIFF_SHARE_4S= NBR_HSUP_4SEM_H/NBR_H - NBR_HSUP_4SEM_F/NBR_F,
         DIFF_SHARE_3S= NBR_HSUP_3SEM_H/NBR_H - NBR_HSUP_3SEM_F/NBR_F,
         DIFF_SHARE_2S= NBR_HSUP_2SEM_H/NBR_H - NBR_HSUP_2SEM_F/NBR_F,
         DIFF_SHARE_1S= NBR_HSUP_1SEM_H/NBR_H - NBR_HSUP_1SEM_F/NBR_F,
         SHARE_HSUP_6S_H = NBR_HSUP_6SEM_H/NBR_H ,
         SHARE_HSUP_6S_F = NBR_HSUP_6SEM_F/NBR_F,
         SHARE_HSUP_5S_H = NBR_HSUP_5SEM_H/NBR_H ,
         SHARE_HSUP_5S_F = NBR_HSUP_5SEM_F/NBR_F,
         SHARE_HSUP_4S_H = NBR_HSUP_4SEM_H/NBR_H ,
         SHARE_HSUP_4S_F = NBR_HSUP_4SEM_F/NBR_F,
         SHARE_HSUP_3S_H = NBR_HSUP_3SEM_H/NBR_H ,
         SHARE_HSUP_3S_F = NBR_HSUP_3SEM_F/NBR_F,
         SHARE_HSUP_2S_H = NBR_HSUP_2SEM_H/NBR_H ,
         SHARE_HSUP_2S_F = NBR_HSUP_2SEM_F/NBR_F,
         SHARE_HSUP_1S_H = NBR_HSUP_1SEM_H/NBR_H ,
         SHARE_HSUP_1S_F = NBR_HSUP_1SEM_F/NBR_F
  )



## GLOBAL

# PLOT - Trends in The Average Share of Employees Working Overtime (SHARE_HSUP)

base_mean <- base %>%
  group_by(ANNEE) %>%
  summarise(mean_share_hsup = mean(SHARE_HSUP, na.rm = TRUE))

ggplot(base_mean, aes(x = ANNEE, y=mean_share_hsup)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "steelblue", size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red")+
  labs(
    tile = "Trends in The Average Share of Employees Working Overtime",
    x = "Year",
    y = "Average Share"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/GLOBAL_sharehsup_evol.png")

# same but with SHARE_HSUP_6SEM

base_mean <- base %>%
  group_by(ANNEE) %>%
  summarise(mean_share_hsup = mean(SHARE_HSUP_6SEM, na.rm = TRUE))

ggplot(base_mean, aes(x = ANNEE, y=mean_share_hsup)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "steelblue", size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red")+
  labs(
    tile = "Trends in The Average Share of Employees Working Overtime",
    x = "Year",
    y = "Average Share"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/GLOBAL_sharehsup6sem_evol.png")


# Trends in The Average Share of Employees Working Overtime by Gender

base_mean_gender <- base %>%
  group_by(ANNEE) %>%
  summarise(men = mean(SHARE_HSUP_H, na.rm = TRUE),
            women = mean(SHARE_HSUP_F, na.rm = TRUE)
  ) %>%
  pivot_longer(cols = c("men","women"), names_to = "gender", values_to = "mean_share")

ggplot(base_mean_gender, aes(x = ANNEE, y=mean_share, color = gender)) +
  geom_line(size = 1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red")+
  labs(
    tile = "Trends in The Average Share of Employees Working Overtime by Gender",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/GLOBAL_sharehsup_evol_HvsF.png")


# same with SHARE_HSUP_6SEM

base_mean_gender <- base %>%
  group_by(ANNEE) %>%
  summarise(men = mean(SHARE_HSUP_6S_H, na.rm = TRUE),
            women = mean(SHARE_HSUP_6S_F, na.rm = TRUE)
  ) %>%
  pivot_longer(cols = c("men","women"), names_to = "gender", values_to = "mean_share")

ggplot(base_mean_gender, aes(x = ANNEE, y=mean_share, color = gender)) +
  geom_line(size = 1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red")+
  labs(
    tile = "Trends in The Average Share of Employees Working Overtime by Gender",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/GLOBAL_sharehsup6sem_evol_HvsF.png")



## GROUP SIZE - threshold 50

# Trends in the Average Share of Employees Working Overtime by Firm Size - SHARE_HSUP

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))

base_grouped <- base_grouped %>%
  filter(!is.na(size_group) & size_group != "")

base_mean_size <- base_grouped %>%
  group_by(ANNEE, size_group) %>%
  summarise(mean_share_hsup = mean(SHARE_HSUP, na.rm = TRUE), .groups = "drop")

ggplot(base_mean_size, aes(x = ANNEE, y=mean_share_hsup, color=size_group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  scale_color_manual(values = c("11-49 employees" = "darkgreen", "51-299 employees"="steelblue")) +
  labs(
    title="Trends in the Average Share of Employees Working Overtime by Firm Size",
    x = "Year",
    y = "Average Share",
    color = "Firm Size"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/50_sharehsup_evol.png")


# same with SHARE_HSUP_6S

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))

base_grouped <- base_grouped %>%
  filter(!is.na(size_group) & size_group != "")

base_mean_size <- base_grouped %>%
  group_by(ANNEE, size_group) %>%
  summarise(mean_share_hsup = mean(SHARE_HSUP_6SEM, na.rm = TRUE), .groups = "drop")

ggplot(base_mean_size, aes(x = ANNEE, y=mean_share_hsup, color=size_group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  scale_color_manual(values = c("11-49 employees" = "darkgreen", "51-299 employees"="steelblue")) +
  labs(
    title="Trends in the Average Share of Employees Working Overtime by Firm Size",
    x = "Year",
    y = "Average Share",
    color = "Firm Size"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/50_sharehsup6sem_evol.png")


# Overtime Share by Gender and Firm Size - SHARE_HSUP

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))


base_grouped <- base_grouped %>%
  filter(!is.na(size_group) & size_group != "")

base_grouped_mean <- base_grouped %>%
  group_by(ANNEE, size_group) %>%
  summarise(
    men = mean(SHARE_HSUP_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share") %>%
  mutate(group = paste (gender, size_group, sep = " - "))


ggplot(base_grouped_mean, aes(x=ANNEE, y=mean_share, color=group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  scale_color_manual(
    values = c(
      "men - 11-49 employees" = "darkblue",
      "women - 11-49 employees" = "deeppink4",
      "men - 51-299 employees" = "lightblue",
      "women - 51-299 employees" = "lightpink"
    )
  ) +
  labs(
    title="Overtime Share by Gender and Firm Size",
    x = "Year",
    y= "Average Share",
    color="Group"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/50_sharehsup_evol_HvsF.png")



# same with SHARE_HSUP_6S

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))


base_grouped <- base_grouped %>%
  filter(!is.na(size_group) & size_group != "")

base_grouped_mean <- base_grouped %>%
  group_by(ANNEE, size_group) %>%
  summarise(
    men = mean(SHARE_HSUP_6S_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_6S_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share") %>%
  mutate(group = paste (gender, size_group, sep = " - "))


ggplot(base_grouped_mean, aes(x=ANNEE, y=mean_share, color=group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  scale_color_manual(
    values = c(
      "men - 11-49 employees" = "darkblue",
      "women - 11-49 employees" = "deeppink4",
      "men - 51-299 employees" = "lightblue",
      "women - 51-299 employees" = "lightpink"
    )
  ) +
  labs(
    title="Overtime Share by Gender and Firm Size",
    x = "Year",
    y= "Average Share",
    color="Group"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/50_sharehsup6sem_evol_HvsF.png")


#  < 50 - W vs. M - SHARE_HSUP

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))

base_small <- base_grouped %>%
  filter(size_group == "11-49 employees")

base_small_mean <- base_small %>%
  group_by(ANNEE) %>%
  summarise(
    men = mean(SHARE_HSUP_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share")


ggplot(base_small_mean, aes(x = ANNEE, y=mean_share, color=gender)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  labs(
    title="Average Share of Employees Working Overtime (11-49 Employees)",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()

#  same with SHARE_HSUP_6S

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))


base_small <- base_grouped %>%
  filter(size_group == "11-49 employees")

base_small_mean <- base_small %>%
  group_by(ANNEE) %>%
  summarise(
    men = mean(SHARE_HSUP_6S_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_6S_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share")


ggplot(base_small_mean, aes(x = ANNEE, y=mean_share, color=gender)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  labs(
    title="Average Share of Employees Working Overtime (11-49 Employees)",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()


#  > 50 W vs. M - SHARE_HSUP

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))


base_large <- base_grouped %>%
  filter(size_group == "51-299 employees")

base_large_mean <- base_large %>%
  group_by(ANNEE) %>%
  summarise(
    men = mean(SHARE_HSUP_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share")


ggplot(base_large_mean, aes(x = ANNEE, y=mean_share, color=gender)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  labs(
    title="Average Share of Employees Working Overtime (51-299 Employees)",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()

# same with SHARE_HSUP_6S

base_grouped <- base %>%
  filter(NBR_COMPLET > 10 & NBR_COMPLET <300) %>%
  mutate(size_group = case_when(
    NBR_COMPLET < 50 ~ "11-49 employees",
    NBR_COMPLET > 50 ~ "51-299 employees"
  ))

base_large <- base_grouped %>%
  filter(size_group == "51-299 employees")

base_large_mean <- base_large %>%
  group_by(ANNEE) %>%
  summarise(
    men = mean(SHARE_HSUP_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols=c("men", "women"), names_to = "gender", values_to = "mean_share")


ggplot(base_large_mean, aes(x = ANNEE, y=mean_share, color=gender)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color="red") +
  labs(
    title="Average Share of Employees Working Overtime (51-299 Employees)",
    x = "Year",
    y = "Average Share",
    color = "Gender"
  ) +
  theme_minimal()

# Number of firms <50 or >50

table(base_grouped$size_group)



## APEN

# Trends in the Average Share of Employees Working Overtime by NAF - SHARE_HSUP

df_sector <- base %>%
  filter(substr(APEN, 1, 2) %in% c("46","47","55","56")) %>%
  mutate(sector_group = case_when(
    substr(APEN, 1, 2) %in% c("46","47") ~ "NAF 46-47",
    substr(APEN, 1, 2) %in% c("55","56") ~ "NAF 55-56",
  ))

df_sector_mean <- df_sector %>%
  group_by(ANNEE, sector_group) %>%
  summarise(mean_share = mean(SHARE_HSUP, na.rm=TRUE), .groups = "drop")

ggplot(df_sector_mean, aes(x=ANNEE, y=mean_share, color=sector_group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  labs(
    title="Trends in the Average Share of Employees Working Overtime by NAF",
    x = "Year",
    y= "Average Share",
    color="Sector"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/NAF_sharehsup_evol.png")


# same with SHARE_HSUP_6S

df_sector <- base %>%
  filter(substr(APEN, 1, 2) %in% c("46","47","55","56")) %>%
  mutate(sector_group = case_when(
    substr(APEN, 1, 2) %in% c("46","47") ~ "NAF 46-47",
    substr(APEN, 1, 2) %in% c("55","56") ~ "NAF 55-56",
  ))

df_sector_mean <- df_sector %>%
  group_by(ANNEE, sector_group) %>%
  summarise(mean_share = mean(SHARE_HSUP_6SEM, na.rm=TRUE), .groups = "drop")

ggplot(df_sector_mean, aes(x=ANNEE, y=mean_share, color=sector_group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  labs(
    title="Trends in the Average Share of Employees Working Overtime by NAF",
    x = "Year",
    y= "Average Share",
    color="Sector"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/NAF_sharehsup6sem_evol.png")


# Number of firms in APEN groups

table(df_sector$sector_group)


# Overtime Share by Gender and Sector - SHARE_HSUP

df_sector <- base %>%
  filter(substr(APEN, 1, 2) %in% c("46","47","55","56")) %>%
  mutate(sector_group = case_when(
    substr(APEN, 1, 2) %in% c("46","47") ~ "NAF 46-47",
    substr(APEN, 1, 2) %in% c("55","56") ~ "NAF 55-56",
  ))

df_sector_mean <- df_sector %>%
  group_by(ANNEE, sector_group) %>%
  summarise(
    men = mean(SHARE_HSUP_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c("men", "women"), names_to = "gender", values_to = "mean_share")

df_sector_mean <- df_sector_mean %>%
  mutate(group = paste(gender, sector_group, sep = " - "))

ggplot(df_sector_mean, aes(x=ANNEE, y=mean_share, color=group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  scale_color_manual(
    values = c(
      "men - NAF 46-47" = "darkblue",
      "women - NAF 46-47" = "deeppink4",
      "men - NAF 55-56" = "lightblue",
      "women - NAF 55-56" = "lightpink"
    )
  ) +
  labs(
    title="Overtime Share by Gender and Sector",
    x = "Year",
    y= "Average Share",
    color="Group"
  ) +
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/NAF_sharehsup_evol_HvsF.png")

# same with SHARE_HSUP_6S

df_sector <- base %>%
  filter(substr(APEN, 1, 2) %in% c("46","47","55","56")) %>%
  mutate(sector_group = case_when(
    substr(APEN, 1, 2) %in% c("46","47") ~ "NAF 46-47",
    substr(APEN, 1, 2) %in% c("55","56") ~ "NAF 55-56",
  ))

df_sector_mean <- df_sector %>%
  group_by(ANNEE, sector_group) %>%
  summarise(
    men = mean(SHARE_HSUP_6S_H, na.rm = TRUE),
    women = mean(SHARE_HSUP_6S_F, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c("men", "women"), names_to = "gender", values_to = "mean_share")

df_sector_mean <- df_sector_mean %>%
  mutate(group = paste(gender, sector_group, sep = " - "))

ggplot(df_sector_mean, aes(x=ANNEE, y=mean_share, color=group)) +
  geom_line(size=1.2) +
  geom_point(size=2) +
  geom_vline(xintercept=2016, linetype="dashed", color="red") +
  scale_color_manual(
    values = c(
      "men - NAF 46-47" = "darkblue",
      "women - NAF 46-47" = "deeppink4",
      "men - NAF 55-56" = "lightblue",
      "women - NAF 55-56" = "lightpink"
    )
  ) +
  labs(
    title="Overtime Share by Gender and Sector",
    x = "Year",
    y= "Average Share",
    color="Group"
  ) +
  theme_minimal()


ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph stat desc/NAF_sharehsup6sem_evol_HvsF.png")





