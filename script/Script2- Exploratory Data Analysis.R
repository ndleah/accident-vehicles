##################################################
## This script is used to do EDA on the data
##################################################

# Load Libraries
library(ggplot2)
library(GGally)
library(reshape2)
library(lme4)
library(compiler)
library(parallel)
library(boot)
library(lattice)
library(sqldf)

# Get the list of vehicle's models
# create variables to be used
vehicle_models <- sqldf("select distinct VEHICLE_MAKE, VEHICLE_MODEL from train limit 7")

vehicle_models$pathString <- paste("Vehicle", 
                       vehicle_models$VEHICLE_MAKE, 
                       vehicle_models$VEHICLE_MODEL, 
                       sep = "/")

vehicle_models_copy <- as.Node(vehicle_models)

print(vehicle_models_copy, limit = 20)

plot(vehicle_models_copy)


# plot using GGpairs
ggpairs(train[, c("NUM_OF_YEARS", "SPEED_ZONE")],
        cardinality_threshold = NULL)

# Join vehicle, accident and person data
vehicle_models <- sqldf("select a.ACCIDENT_NO, a.ACCIDENTDATE, a.SPEED_ZONE, v.VEHICLE_ID, v.VEHICLE_TYPE,
            v.VEHICLE_MAKE, v.VEHICLE_MODEL,
            substr(v.\"Vehicle.Type.Desc\", 0, 10) as Vehicle_Type_Desc,
            v.VEHICLE_YEAR_MANUF, v.LEVEL_OF_DAMAGE,
            p.PERSON_ID,
            p.INJ_LEVEL, p.\"Inj.Level.Desc\" as Inj_Level_Desc
            from vehicles v
            inner join accident a on
            a.ACCIDENT_NO = v.ACCIDENT_NO
            inner join person p on
            p.ACCIDENT_NO = a.ACCIDENT_NO
            and p.VEHICLE_ID = v.VEHICLE_ID")

# Plot a bar graph using the above dataset
ggplot(vehicle_models, aes(x=Vehicle_Type_Desc)) + geom_bar()+
  theme(axis.text.x = element_text(angle = 90))+
  xlab("Vehicle Type")+
  ylab("Count of Accidents")

# plot data using the current tataset and see how it looks
ggplot(train, aes(x = Vehicle_Type_Desc, y = NUM_OF_YEARS)) +
  stat_sum(aes(size = ..n.., group = 1)) +
  scale_size_area(max_size=8)+
  xlab("Vehicle Type")+
  ylab("Age of Vehicle")


# Third Plot
tmp <- melt(train[, c("SEVERE", "Vehicle_Type_Desc", "NUM_OF_YEARS", "SPEED_ZONE")])
ggplot(tmp, aes(x = SEVERE, y = value)) +
  geom_jitter(alpha = .1) +
  geom_violin(alpha = .75) +
  facet_grid(variable ~ .) +
  scale_y_sqrt()

# Fourth plot
ggplot(tmp, aes(factor(SEVERE), y = value, fill=factor(SEVERE))) +
  geom_boxplot() +
  facet_wrap(~variable, scales="free_y")


# check data and results
vehicle_models <- table(train$VEHICLE_MAKE, train$SEVERE)

vehicle_models_copy <- as.data.frame.matrix(vehicle_models) 

vehicle_models_copy <- cbind(vehicle_models_copy, rownames(vehicle_models))

sqldf("select \"rownames(vehicle_models)\" as VEHICLE_MAKE, No, Yes, (100.0 * No )/(Yes+No) as No_Percentage,
        (100.0 * Yes )/(Yes+No) as Yes_Percentage
      from vehicle_models_copy")





