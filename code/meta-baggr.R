#install.packages("baggr")
#install.packages("rstan", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))

library(rstan)
library(baggr)
library(tidyverse)

root <- "C:/Users/gschinaia/Dropbox/Chicago/DIL/icccfsa"
path <- "/weather-meta/"
 dt <- read.csv(paste0(root,path,"data/meta-weather-prep.csv"))

 #dt <- read_csv("weather/meta-weather-prep.csv")

bg <- dt %>% 
  filter(variable_group == "yields") %>% 
  transmute(
    trial = dcode,
    tau = yields_effectsize/1000,
    se = yields_sterror/1000,
    control_mean_prep = control_mean_prep/1000) %>% 
  mutate(tau = tau/control_mean_prep,
         se = se/control_mean_prep) %>% 
  baggr(refresh = 0, 
        group = "trial",
        prior_hypermean = normal(0, 5),
        prior_hypersd = cauchy(0, 2.5))
# control = list(adapt_delta = 0.99))

print(bg)
plot(bg)

png(paste0(root,path,"graphs/bg-yields.png"))
forest_plot(bg)
dev.off()

dt$variable_group[dt$variable_group == "costs"] <- "profits" 

bg_p <- dt %>% 
  filter(variable_group == "profits") %>% 
  transmute(
    trial = dcode,
    tau = profitcosts_effectsize,
    se = profitcosts_sterror,
    control_mean_prep = control_mean_prep) %>% 
  mutate(tau = tau,
         se = se) %>% 
  baggr(refresh = 0, 
        group = "trial",
        prior_hypermean = normal(0, 10),
        prior_hypersd = cauchy(0, 5))
# control = list(adapt_delta = 0.99))

print(bg_p)
plot(bg_p)
png(paste0(root,path,"graphs/bg-profcost.png"))
forest_plot(bg_p)
dev.off()

bg_p0 <- dt %>% 
  filter(variable_group == "profits") %>% 
  transmute(
    trial = dcode,
    tau = profitcosts_effectsize,
    se = profitcosts_sterror,
    control_mean_prep = control_mean_prep) %>% 
  mutate(tau = tau,
         se = se) %>% 
  baggr(refresh = 0, 
        group = "trial",
        prior_hypermean = normal(0, 5),
        prior_hypersd = cauchy(0, 2.5))

baggr_compare("Normal prior wt SD 5" = bg_p0,
              "Normal prior wt SD 10" = bg_p,
              compare = "effects", plot = TRUE)

png(paste0(root,path,"graphs/bg-profcosts-compare_sd5vsd10.png"))

cov <- c(dt$takeup_effectsize)

bg_p1 <- dt %>% 
  filter(variable_group == "profits") %>% 
  transmute(
    trial = dcode,
    tau = profitcosts_effectsize,
    se = profitcosts_sterror,
    cov = takeup_effectsize-0.5,
    control_mean_prep = control_mean_prep) %>% 
  mutate(tau = tau,
         se = se) %>% 
  baggr(refresh = 0, 
        group = "trial",
        prior_hypermean = normal(0, 10),
        prior_hypersd = cauchy(0, 5),
        covariates = "cov")

print(bg_p1)
