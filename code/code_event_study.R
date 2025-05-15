
library(haven)
library(dplyr)
library(ggplot2)
library(tidyr)
library(fixest)
library(broom)
library(stringr)
library(modelsummary)

base1 <- read.csv("C:/Users/Public/Documents/Leroux_Mayans/Data/base_finale2_2.csv")

base <- base1


# creation of the dataframes for the analysis

# deleting firms with only one employee

base <- base %>%
  filter(NBR_COMPLET>1) 

# creating pre and post reform indicators around 2016

base <- base %>%
  mutate(pre_reform = ANNEE %in% 2013:2015,
         post_reform = ANNEE > 2015)

# creating the variables about the share of employees doing more 
# than n weeks of overtime

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

# firm-level average share of overtime before the reform

firm_pre_means <-base %>%
  filter(pre_reform) %>%
  group_by(SIREN) %>%
  summarise(
    mean_share_hsup = mean(SHARE_HSUP, na.rm=TRUE),
    mean_share_hsup_1sem = mean(SHARE_HSUP_1SEM, na.rm=TRUE),
    mean_share_hsup_2sem = mean(SHARE_HSUP_2SEM, na.rm=TRUE),
    mean_share_hsup_3sem = mean(SHARE_HSUP_3SEM, na.rm=TRUE),
    mean_share_hsup_4sem = mean(SHARE_HSUP_4SEM, na.rm=TRUE),
    mean_share_hsup_5sem = mean(SHARE_HSUP_5SEM, na.rm=TRUE),
    mean_share_hsup_6sem = mean(SHARE_HSUP_6SEM, na.rm=TRUE)
  )


firm_pre_means = firm_pre_means %>%
  mutate(quint_MOY_SHARE_1SEM = ntile(mean_share_hsup_1sem, 5),
         quint_MOY_SHARE_2SEM = ntile(mean_share_hsup_2sem, 5),
         quint_MOY_SHARE_3SEM = ntile(mean_share_hsup_3sem, 5),
         quint_MOY_SHARE_4SEM = ntile(mean_share_hsup_4sem, 5),
         quint_MOY_SHARE_5SEM = ntile(mean_share_hsup_5sem, 5),
         quint_MOY_SHARE_6SEM = ntile(mean_share_hsup_6sem, 5)
  )

base = base %>%
  left_join(firm_pre_means, by="SIREN")

# outcome variables

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

base = base %>%
  mutate(DIFF_SALAIRE_HOR = S_BRUT_HOR_H - S_BRUT_HOR_F,
         DIFF_CROISS_SAL_HOR = CROISS_S_BRUT_HOR_H - CROISS_S_BRUT_HOR_F,
         DIFF_NBHEUR_DAY = NBHEUR_DAY_MOY360_H -NBHEUR_DAY_MOY360_F,
         DIFF_SALAIRE_MOY = S_BRUT_MOY_H - S_BRUT_MOY_F
  )



base <- base %>%
  mutate(
    quint_MOY_SHARE_5SEM = ifelse(
      quint_MOY_SHARE_5SEM %in% c(4,5) & quint_MOY_SHARE_6SEM == 5,
      NA,
      quint_MOY_SHARE_5SEM
    )
  )

base <- base %>%
  mutate(NBR_F = ifelse(is.na(NBR_F), 0, NBR_F))



# creating dataframes for event study analysis by treatment definition

# treatment = using a lot of overtime hours

base <- base %>%
  mutate(
    treatment = ifelse(quint_MOY_SHARE_5SEM %in% c(4,5),1,0),
    control = ifelse(quint_MOY_SHARE_5SEM %in% c(1,2),1,0)
  )



base_treat= base %>% 
  filter(treatment==1) 


base_contr= base %>% 
  filter(control==1)

base_did = bind_rows(base_treat, base_contr)


base_did$event_time <- base_did$ANNEE - 2016
base_did$event_time_factor <- factor(base_did$event_time)

base_did$DID <- base_did$post_reform * base_did$treatment


# treatment = having less than 50 employees



base = base %>%
  mutate(treatment50 = ifelse(NBR_COMPLET>10 & NBR_COMPLET<50, 1, 0),
         control50 = ifelse(NBR_COMPLET>50 & NBR_COMPLET<300, 1, 0))


base_treat50= base %>%
  filter(treatment50==1)


base_contr50= base %>%
  filter(control50==1)



base_did50 = bind_rows(base_treat50, base_contr50)

base_did50 <- base_did50 %>%
  select(-treatment) %>%
  select(-control)

base_did50 <- base_did50 %>%
  rename(treatment = treatment50,
         control = control50)


base_did50$event_time <- base_did50$ANNEE - 2016
base_did50$event_time_factor <- factor(base_did50$event_time)
base_did50$DID <- base_did50$post_reform * base_did50$treatment



# treatment depending on NAF categories:
# 55/56: hébergement, restauration
# 46: commerce de gros, 47: commerce de détail 


base <- base %>%
  mutate(
    treatmentNAF = ifelse(grepl("^55|^56", APEN),1 , 0),
    controlNAF = ifelse(grepl("^46|^47", APEN),1 , 0)
  )



base_treatNAF= base %>% 
  filter(treatmentNAF==1) 


base_contrNAF= base %>% 
  filter(controlNAF==1)

base_didNAF = bind_rows(base_treatNAF, base_contrNAF)

base_didNAF <-  base_didNAF %>%
  select(-treatment) %>%
  select(-control)

base_didNAF <- base_didNAF %>%
  rename(treatment = treatmentNAF,
         control = controlNAF)


base_didNAF$event_time <- base_didNAF$ANNEE - 2016
base_didNAF$event_time_factor <- factor(base_didNAF$event_time)

base_didNAF$DID <- base_didNAF$post_reform * base_didNAF$treatment



# ANALYSIS


## treatment = sensitivity to overtime work

#outcome 1: overtime 6 weeks


ggplot(base_did, aes(x= ANNEE, y = DIFF_SHARE_6S, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_6sem_diff.png")


ggplot(base_did, aes(x= ANNEE, y = SHARE_HSUP_6S_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Men working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_6sem_men.png")

ggplot(base_did, aes(x= ANNEE, y = SHARE_HSUP_6S_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Women working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_6sem_women.png")



# estimation of the corresponding event study

#simple event study

model_event <- feols(
  DIFF_SHARE_6S ~ i(event_time, treatment, ref=-1 ) | SIREN + ANNEE,
  data= base_did
)

summary(model_event)

iplot(model_event, 
      main="Event Study",
      xlab="Time relative to the treatment",
      ylab = "Estimated effect",
      ref.line=0)


#same model but with control variables

model_event2 <- feols(
  DIFF_SHARE_6S ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did
)


iplot(model_event2, 
      main="Event Study",
      xlab="Time relative to the treatment",
      ylab = "Estimated effect",
      ref.line=-0.5)



#plot event study with ggplot


event_results <- tidy(model_event2) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
    )

event_results <- bind_rows(
  event_results,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results <- event_results %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )
  
ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_eventstudy_6sem.png")



#estimation of the corresponding DID  



didreg_T1_6weeks = feols(DIFF_SHARE_6S ~ treatment + post_reform  + DID + 
                           AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                         + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                         data= base_did )

summary(didreg_T1_6weeks)

etable(didreg_T1_6weeks, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T1_DID_6sem.tex")





# outcome 2: hours of work



ggplot(base_did, aes(x= ANNEE, y = DIFF_NBHEUR_DAY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average hours worked", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_hoursavg_diff.png")

ggplot(base_did, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_hoursavg_men.png")

ggplot(base_did, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_hoursavg_women.png")


# event study

model_event_hmoy <- feols(
  DIFF_NBHEUR_DAY ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did
)

#plot event study with ggplot


event_results_hmoy <- tidy(model_event_hmoy) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_hmoy <- bind_rows(
  event_results_hmoy,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_hmoy <- event_results_hmoy %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_hmoy %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_eventstudy_avghours.png")


#estimation of the corresponding DID  


didreg_T1_avghours = feols(DIFF_NBHEUR_DAY ~ treatment + post_reform  + DID + 
                           AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                         + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                         data= base_did )


etable(didreg_T1_avghours, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T1_DID_avghours.tex")





# outcome 3: average wage 

ggplot(base_did, aes(x= ANNEE, y = DIFF_SALAIRE_MOY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average Wage", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_avgwage_diff.png")

ggplot(base_did, aes(x= ANNEE, y = S_BRUT_MOY_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_avgwage_men.png")


ggplot(base_did, aes(x= ANNEE, y = S_BRUT_MOY_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_avgwage_women.png")


#event study

model_event_wagemoy <- feols(
  DIFF_SALAIRE_MOY ~ i(event_time, treatment, ref=-1 )  + 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did
)



event_results_wagemoy <- tidy(model_event_wagemoy) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagemoy <- bind_rows(
  event_results_wagemoy,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagemoy <- event_results_wagemoy %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagemoy %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_eventstudy_avgwage.png")


# did 



didreg_T1_avgwage = feols(DIFF_SALAIRE_MOY ~ treatment + post_reform  + DID + 
                             AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                           + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                           data= base_did )


etable(didreg_T1_avgwage, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T1_DID_avgwage.tex")








# outcome 4: hourly wages



ggplot(base_did, aes(x= ANNEE, y = DIFF_SALAIRE_HOR, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in hourly wages", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_wagehour_diff.png")


ggplot(base_did, aes(x= ANNEE, y = S_BRUT_HOR_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_wagehour_men.png")

ggplot(base_did, aes(x= ANNEE, y = S_BRUT_HOR_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_wagehour_women.png")


#event study

model_event_wagehour <- feols(
  DIFF_SALAIRE_HOR ~ i(event_time, treatment, ref=-1 )+ 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did
)




event_results_wagehour <- tidy(model_event_wagehour) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagehour <- bind_rows(
  event_results_wagehour,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagehour <- event_results_wagehour %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagehour %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T1_eventstudy_wagehour.png")


# did 



didreg_T1_wagehour = feols(DIFF_SALAIRE_HOR ~ treatment + post_reform  + DID + 
                            AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                          + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                          data= base_did )


etable(didreg_T1_wagehour, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T1_DID_wagehour.tex")





















## treatment = 50 employees 












#outcome 1: overtime 6 weeks


ggplot(base_did50, aes(x= ANNEE, y = DIFF_SHARE_6S, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_6sem_diff.png")


ggplot(base_did50, aes(x= ANNEE, y = SHARE_HSUP_6S_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Men working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_6sem_men.png")

ggplot(base_did50, aes(x= ANNEE, y = SHARE_HSUP_6S_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Women working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_6sem_women.png")



# estimation of the corresponding event study 


model_event50 <- feols(
  DIFF_SHARE_6S ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did50
)



event_results50 <- tidy(model_event50) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results50 <- bind_rows(
  event_results50,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results50 <- event_results50 %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results50 %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_eventstudy_6sem.png")



#estimation of the DID 



didreg_T50_6weeks = feols(DIFF_SHARE_6S ~ treatment + post_reform  + DID + 
                            AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                          + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                          data= base_did50 )


etable(didreg_T50_6weeks, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T50_DID_6sem.tex")





# outcome 2: hours of work



ggplot(base_did50, aes(x= ANNEE, y = DIFF_NBHEUR_DAY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average hours worked", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_hoursavg_diff.png")

ggplot(base_did50, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_hoursavg_men.png")

ggplot(base_did50, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_hoursavg_women.png")


# event study

model_event_hmoy50 <- feols(
  DIFF_NBHEUR_DAY ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did50
)


event_results_hmoy50 <- tidy(model_event_hmoy50) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_hmoy50 <- bind_rows(
  event_results_hmoy50,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_hmoy50 <- event_results_hmoy50 %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_hmoy50 %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_eventstudy_avghours.png")


#estimation of the DID  


didreg_T50_avghours = feols(DIFF_NBHEUR_DAY ~ treatment + post_reform  + DID + 
                              AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                            + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                            data= base_did50 )


etable(didreg_T50_avghours, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T50_DID_avghours.tex")





# outcome 3: average wage 

ggplot(base_did50, aes(x= ANNEE, y = DIFF_SALAIRE_MOY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average Wage", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_avgwage_diff.png")

ggplot(base_did50, aes(x= ANNEE, y = S_BRUT_MOY_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_avgwage_men.png")


ggplot(base_did50, aes(x= ANNEE, y = S_BRUT_MOY_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_avgwage_women.png")


#event study

model_event_wagemoy50 <- feols(
  DIFF_SALAIRE_MOY ~ i(event_time, treatment, ref=-1 )  + 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did50
)



event_results_wagemoy50 <- tidy(model_event_wagemoy50) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagemoy50 <- bind_rows(
  event_results_wagemoy50,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagemoy50 <- event_results_wagemoy50 %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagemoy50 %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_eventstudy_avgwage.png")


# did 



didreg_T50_avgwage = feols(DIFF_SALAIRE_MOY ~ treatment + post_reform  + DID + 
                             AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                           + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                           data= base_did50 )


etable(didreg_T50_avgwage, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T50_DID_avgwage.tex")








# outcome 4: hourly wages



ggplot(base_did50, aes(x= ANNEE, y = DIFF_SALAIRE_HOR, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in hourly wages", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_wagehour_diff.png")


ggplot(base_did50, aes(x= ANNEE, y = S_BRUT_HOR_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_wagehour_men.png")

ggplot(base_did50, aes(x= ANNEE, y = S_BRUT_HOR_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_wagehour_women.png")


#event study

model_event_wagehour50 <- feols(
  DIFF_SALAIRE_HOR ~ i(event_time, treatment, ref=-1 )+ 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_did50
)




event_results_wagehour50 <- tidy(model_event_wagehour50) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagehour50 <- bind_rows(
  event_results_wagehour50,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagehour50 <- event_results_wagehour50 %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagehour50 %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/T50_eventstudy_wagehour.png")


# did 



didreg_T50_wagehour = feols(DIFF_SALAIRE_HOR ~ treatment + post_reform  + DID + 
                              AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                            + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                            data= base_did50 )


etable(didreg_T50_wagehour, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/T50_DID_wagehour.tex")









## treatment = NAF 





#outcome 1: overtime 6 weeks


ggplot(base_didNAF, aes(x= ANNEE, y = DIFF_SHARE_6S, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_6sem_diff.png")


ggplot(base_didNAF, aes(x= ANNEE, y = SHARE_HSUP_6S_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Men working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_6sem_men.png")

ggplot(base_didNAF, aes(x= ANNEE, y = SHARE_HSUP_6S_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Share of Women working >6 Weeks of Overtime", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_6sem_women.png")



# estimation of event study 



model_eventNAF <- feols(
  DIFF_SHARE_6S ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_didNAF
)




event_resultsNAF <- tidy(model_eventNAF) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_resultsNAF <- bind_rows(
  event_resultsNAF,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_resultsNAF <- event_resultsNAF %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_resultsNAF %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_eventstudy_6sem.png")



#estimation of the DID  



didreg_TNAF_6weeks = feols(DIFF_SHARE_6S ~ treatment + post_reform  + DID + 
                            AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                          + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                          data= base_didNAF )


etable(didreg_TNAF_6weeks, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/TNAF_DID_6sem.tex")





# outcome 2: hours of work



ggplot(base_didNAF, aes(x= ANNEE, y = DIFF_NBHEUR_DAY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average hours worked", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_hoursavg_diff.png")

ggplot(base_didNAF, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_hoursavg_men.png")

ggplot(base_didNAF, aes(x= ANNEE, y = NBHEUR_DAY_MOY360_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hours worked by Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_hoursavg_women.png")


# event study

model_event_hmoyNAF <- feols(
  DIFF_NBHEUR_DAY ~ i(event_time, treatment, ref=-1 ) + AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_didNAF
)




event_results_hmoyNAF <- tidy(model_event_hmoyNAF) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_hmoyNAF <- bind_rows(
  event_results_hmoyNAF,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_hmoyNAF <- event_results_hmoyNAF %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_hmoyNAF %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_eventstudy_avghours.png")


#estimation of the DID  


didreg_TNAF_avghours = feols(DIFF_NBHEUR_DAY ~ treatment + post_reform  + DID + 
                              AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                            + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                            data= base_didNAF )


etable(didreg_TNAF_avghours, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/TNAF_DID_avghours.tex")





# outcome 3: average wage 

ggplot(base_didNAF, aes(x= ANNEE, y = DIFF_SALAIRE_MOY, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in average Wage", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_avgwage_diff.png")

ggplot(base_didNAF, aes(x= ANNEE, y = S_BRUT_MOY_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_avgwage_men.png")


ggplot(base_didNAF, aes(x= ANNEE, y = S_BRUT_MOY_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_avgwage_women.png")


#event study

model_event_wagemoyNAF <- feols(
  DIFF_SALAIRE_MOY ~ i(event_time, treatment, ref=-1 )  + 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_didNAF
)



event_results_wagemoyNAF <- tidy(model_event_wagemoyNAF) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagemoyNAF <- bind_rows(
  event_results_wagemoyNAF,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagemoyNAF <- event_results_wagemoyNAF %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagemoyNAF %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_eventstudy_avgwage.png")


# did 



didreg_TNAF_avgwage = feols(DIFF_SALAIRE_MOY ~ treatment + post_reform  + DID + 
                             AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                           + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                           data= base_didNAF )


etable(didreg_TNAF_avgwage, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/TNAF_DID_avgwage.tex")








# outcome 4: hourly wages



ggplot(base_didNAF, aes(x= ANNEE, y = DIFF_SALAIRE_HOR, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Gender Gap in hourly wages", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_wagehour_diff.png")


ggplot(base_didNAF, aes(x= ANNEE, y = S_BRUT_HOR_H, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Men", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_wagehour_men.png")

ggplot(base_didNAF, aes(x= ANNEE, y = S_BRUT_HOR_F, color=as.factor(treatment), group=treatment))+
  stat_summary(fun=mean, geom = "line", size=1.2)+
  stat_summary(fun=mean, geom="point")+
  labs(x= "Year", y="Average hourly wage of Women", color="Treatment Group")+
  theme_minimal()

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_wagehour_women.png")


#event study

model_event_wagehourNAF <- feols(
  DIFF_SALAIRE_HOR ~ i(event_time, treatment, ref=-1 )+ 
    AGE_MOY + NBR_COMPLET + EFF_MOY_ET
  + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
  data= base_didNAF
)




event_results_wagehourNAF <- tidy(model_event_wagehourNAF) %>%
  filter(str_detect(term, "event_time::")) %>%
  mutate(
    period= as.numeric(str_extract(term, "-?\\d+")),
    ci_low = estimate - 1.96 * std.error,
    ci_high = estimate + 1.96 * std.error
  )

event_results_wagehourNAF <- bind_rows(
  event_results_wagehourNAF,
  data.frame(period=-1,
             estimate=0,
             std.error = NA,
             ci_low=NA,
             ci_high=NA)
)

event_results_wagehourNAF <- event_results_wagehourNAF %>%
  mutate(
    post = ifelse(period >=0, "Post-Treatment", "Pre-Treatment"),
    post = factor(post, levels = c("Post-Treatment", "Pre-Treatment"))
  )

event_results_wagehourNAF %>%
  ggplot(aes(x= period, y=estimate, color = post)) +
  geom_point(size = 2, color = 'black') +
  geom_errorbar(aes(ymin=ci_low, ymax=ci_high), width = 0.2) +
  geom_vline(xintercept = -0.5, linetype="dashed", color="gray40")+
  geom_hline(yintercept = 0)+
  scale_color_manual(
    values=  c("Post-Treatment" = "#4e79a7", "Pre-Treatment"="#e15759"),
    name = "Period" )+
  labs(
    title = "Event Study", 
    x = "Time relative to the treatment",
    y = "Estimated effect (95%)"
  )+
  theme_minimal(base_size = 14)+
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16, hjust=0.5),
    panel.border = element_rect(color="black", fill=NA, linewidth = 0.7)
  )

ggsave("C:/Users/Public/Documents/Leroux_Mayans/output/graph/TNAF_eventstudy_wagehour.png")


# did 



didreg_TNAF_wagehour = feols(DIFF_SALAIRE_HOR ~ treatment + post_reform  + DID + 
                              AGE_MOY + NBR_COMPLET + EFF_MOY_ET
                            + S_BRUT_HOR + NBR_F + APEN + DEPT | SIREN + ANNEE,
                            data= base_didNAF )


etable(didreg_TNAF_wagehour, keep="DID", tex= TRUE, file="C:/Users/Public/Documents/Leroux_Mayans/output/tables/TNAF_DID_wagehour.tex")



















