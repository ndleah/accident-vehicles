##################################################
## This script prepares the training and test
## datasets for both EDA and Modelling
##################################################

# Load Libraries
library(sqldf)
library(lme4)
library(tidyverse)

#screet screen output options
options("scipen"=100, "digits"=4)

# read data from source
accident <- read.csv("Datasets/Road Crashes/ACCIDENT.csv")

vehicles <- read.csv("Datasets/Road Crashes/VEHICLE.csv")

person <- read.csv("Datasets/Road Crashes/PERSON.csv")

# Temporary variable to store vehicle's types and descriptions
vehicle_type <- sqldf("select distinct VEHICLE_TYPE, \"Vehicle.Type.Desc\" from vehicles")

# Join accident, vehicles and people datasets
avp_df1 <- sqldf("select a.ACCIDENT_NO, a.ACCIDENTDATE, a.SPEED_ZONE, v.VEHICLE_ID, v.VEHICLE_TYPE,
            v.VEHICLE_MAKE, v.VEHICLE_MODEL,
            v.\"Vehicle.Type.Desc\" as Vehicle_Type_Desc,
            v.VEHICLE_YEAR_MANUF, v.LEVEL_OF_DAMAGE,
            p.PERSON_ID,
            p.INJ_LEVEL, p.\"Inj.Level.Desc\" as Inj_Level_Desc
            from vehicles v
            inner join accident a on
            a.ACCIDENT_NO = v.ACCIDENT_NO
            inner join person p on
            p.ACCIDENT_NO = a.ACCIDENT_NO
            and p.VEHICLE_ID = v.VEHICLE_ID
            where v.VEHICLE_TYPE in (1, 2, 4)")

# Join vehicle's model
vehicle_model <- sqldf("select VEHICLE_MAKE || VEHICLE_MODEL AS VEHICLE_MODEL, count(*) as my_Count
                      from vehicles where
                      VEHICLE_TYPE in (1, 2, 4) and VEHICLE_MODEL > 0
                      group by VEHICLE_MAKE || VEHICLE_MODEL
                      having my_Count >= 100")

# Filter vehicles by model and remove unneeded ones
df <- sqldf("select ACCIDENT_NO, ACCIDENTDATE, VEHICLE_MAKE, VEHICLE_MODEL, 
            Vehicle_Type_Desc, min(INJ_LEVEL) as SEVERITY,
            VEHICLE_YEAR_MANUF, LEVEL_OF_DAMAGE, SPEED_ZONE
            from avp_df1
            where VEHICLE_MAKE || VEHICLE_MODEL IN (select VEHICLE_MODEL from vehicle_model)
            AND VEHICLE_MAKE NOT LIKE '%UNKN%'
            group by ACCIDENT_NO, ACCIDENTDATE, VEHICLE_MAKE, VEHICLE_MODEL, Vehicle_Type_Desc,
            VEHICLE_YEAR_MANUF, LEVEL_OF_DAMAGE")

# Format date, years and number of years
df$ACCIDENTDATE <- as.Date(df$ACCIDENTDATE, "%d/%m/%Y")

df$ACCIDENT_YEAR <- as.numeric(format(df$ACCIDENTDATE, "%Y"))

df$NUM_OF_YEARS <- df$ACCIDENT_YEAR - df$VEHICLE_YEAR_MANUF

# Create a training dataset
train <- df

# Fix the categorical dependent variable- Severity- Yes and No
# If Severety is 1 or 2, put "Yes" else "No"
train$SEVERITY[train$SEVERITY == "2"] <- "1"
train$SEVERITY[train$SEVERITY == "3"] <- "2"
train$SEVERITY[train$SEVERITY == "4"] <- "2"

train$SEVERITY[train$SEVERITY == "1"] <- "0"
train$SEVERITY[train$SEVERITY == "2"] <- "1"

train$SEVERE[train$SEVERITY == "0"] <- "Yes"
train$SEVERE[train$SEVERITY == "1"] <- "No"


# Fix vehicle's make typos
train$VEHICLE_MAKE <- as.character(train$VEHICLE_MAKE)

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "AUD   "] <- "AUDI"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "AUDI  "] <- "AUDI"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "B.M.  "] <- "B M W "
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "L RO  "] <- "L ROV "

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "FOR   "] <- "FORD"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "FOR"] <- "FORD"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "FORD  "] <- "FORD"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "LANDRO"] <- "LAND R"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "ROVER "] <- "ROVER"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "L ROV "] <- "LAND R"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "NIS   "] <- "NISSAN"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "SUB   "] <- "SUBARU"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "HYND  "] <- "HYUNDAI"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "HYNDAI"] <- "HYUNDAI"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "HYU   "] <- "HYUNDAI"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "HYUNDA"] <- "HYUNDAI"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "HYUNDI"] <- "HYUNDAI"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "MISTUB"] <- "MITSUB"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "R ROV "] <- "ROVER"

train$VEHICLE_MAKE[train$VEHICLE_MAKE == "VLK   "] <- "VOLKSW"
train$VEHICLE_MAKE[train$VEHICLE_MAKE == "VOLKS "] <- "VOLKSW"

train$VEHICLE_MAKE <- as.factor(train$VEHICLE_MAKE)

# Fix vehicle's Model typos
train$VEHICLE_MODEL <- as.character(train$VEHICLE_MODEL)

names(train$VEHICLE_MODEL) <- gsub("\\s+", "", names(train$VEHICLE_MODEL))

train$VEHICLE_MODEL[train$VEHICLE_MODEL == "LANDCR"] <- "LANCER"

train$VEHICLE_MODEL[train$VEHICLE_MODEL == "COROLL"] <- "COROLA"

train$VEHICLE_MODEL[train$VEHICLE_MODEL == "C/DORE"] <- "C'DORE"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "COMMO "] <- "COMM"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "COMM  "] <- "COMM"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "COMMOD"] <- "COMM"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "EXEC  "] <- "EXECUT"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "ELANTR"] <- "ELNTRA"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "LANTRA"] <- "ELNTRA"

train$VEHICLE_MODEL[train$VEHICLE_MODEL == "CR-V  "] <- "CRV"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "CRV   "] <- "CRV"

train$VEHICLE_MODEL[train$VEHICLE_MODEL == "FALCO "] <- "FALCON"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "MAZDA3"] <- "3"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "3     "] <- "3"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "RAV4  "] <- "RAV4 "
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "RAV 4 "] <- "RAV4 "
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "SANTA "] <- "SANTAF"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "SKYLNE  	"] <- "SKYLIN"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "SPORTA"] <- "SPTAGE"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "SKYLNE"] <- "SKYLIN"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "SKYLNE"] <- "SKYLIN"
train$VEHICLE_MODEL[train$VEHICLE_MODEL == "CX-5  "] <- "CX5   "

train$VEHICLE_MODEL <- as.factor(train$VEHICLE_MODEL)

# Change type of variable of Number of years from factor to numeric
train$NUM_OF_YEARS <- as.numeric(train$NUM_OF_YEARS)

# Put NAs for not needed values, i.e. have years of vehicle from 0 to 30 years
train$NUM_OF_YEARS[train$NUM_OF_YEARS < 0 ] <- NA
train$NUM_OF_YEARS[train$NUM_OF_YEARS > 30 ] <- NA

train$LEVEL_OF_DAMAGE <- as.factor(train$LEVEL_OF_DAMAGE)
train$LEVEL_OF_DAMAGE [train$LEVEL_OF_DAMAGE == '9']<- NA

# set Severe's type as factor
train$SEVERE <- factor(train$SEVERE,
                       levels=c("No", "Yes"),
                       labels=c("No", "Yes"))

# Once again,
# Change type of variable of Number of years from factor to numeric
train$NUM_OF_YEARS <- as.numeric(train$NUM_OF_YEARS)

# If speeds are greater than 100 or less than 0 then put NA
train$SPEED_ZONE[train$SPEED_ZONE >110 ] <- NA
train$NUM_OF_YEARS[train$NUM_OF_YEARS <0  ] <- NA



