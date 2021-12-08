##################################################
## This script is used to model do Multilevel
## Modelling of the trianing dataset
##################################################

#load libraries
library(lme4)


#MLM Step 1- Fixed Effects

m1 <- glm(SEVERE ~ 1,
          family= binomial(link= "logit"),
          data= train)

summary(m1)
m1$aic

#MLM Step 2- Random intercept
m2 <- glmer(SEVERE ~ 1 + (1 | VEHICLE_MAKE), 
            data = train,
            family = binomial(link= "logit"),
            control = glmerControl(optimizer = "bobyqa"),
            nAGQ = 0
)

summary(m2)
AIC(logLik(m2))

#MLM Step 2.1- Random intercept
m2.1 <- glmer(SEVERE ~ 1 + (1 | VEHICLE_MAKE) + (1 | VEHICLE_MODEL),
              data = train,
              family = binomial(link= "logit"),
              control = glmerControl(optimizer = "bobyqa"),
              nAGQ = 0
)

summary(m2.1)
AIC(logLik(m2.1))


#MLM Step 3

#MLM Step 3- Random Intercept
m3 <- glmer(SEVERE ~ NUM_OF_YEARS + SPEED_ZONE + (1 | VEHICLE_MAKE) + (1 | VEHICLE_MODEL),
            data = train,
            family = binomial(link= "logit"),
            control = glmerControl(optimizer = "bobyqa"),
            nAGQ = 0
)
summary(m3)
AIC(logLik(m3))

#MLM Step 4 Random Slope Random Intercept
m4 <- glmer(SEVERE ~ NUM_OF_YEARS + SPEED_ZONE + 
              (NUM_OF_YEARS | VEHICLE_MAKE) + (1 | VEHICLE_MODEL),
            data = train.sub,
            family = binomial(link= "logit"),
            control = glmerControl(optimizer = "bobyqa"),
            nAGQ = 0
)

summary(m4)
AIC(logLik(m4))

#Test for dispersion for the best model, which is m3
sm3 <- summary(m3)
sdest <- sqrt(sm3$dispersion)
dnorm(7, mean = coef(m1), sd = sdest)



