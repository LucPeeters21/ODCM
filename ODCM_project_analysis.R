## The collected data is accompanied by meaningful summary statistics 
##(e.g., the number of units per entity, means/SD for continuous variables, 
## and frequency distributions per variable, for each entity). 
## Missingness has been investigated (e.g., for individual entities, but also for the collected variables). 
## Any redundancies, errors, or sources of noise have been clearly described. 
## Identified subpopulations are labeled, so that users of the data can more easily get started using the data.

install.packages("data.table")
install.packages("rjson")
library(haven)
library(dplyr)
library(ggplot2)
library(car)
library(rjson)
library(data.table)
library(stringr)
library(googledrive)

# Import data
data_id <-"1S2Ec1A2RFnRdZAG2Hae3FwWISxkUM0FS" #the id of the dataset
drive_download(as_id(data_id), path = "mediamarkt_scraper_output.csv", overwrite = TRUE) #download the data from the drive
df <-read.csv("mediamarkt_scraper_output.csv") #save the data in a dataframe
View(df)

                                                  ####################
                                                  ##data-preparation##
                                                  ####################

# Remove inconvenient text 
df$price <- (gsub(",-", "", df$price))                                                # ',-' from 'price' variable
df$Beeldschermdiagonaal..cm.. <- (gsub("cm", "", df$Beeldschermdiagonaal..cm..))      # 'cm' from 'Beeldschermdiagonaal..cm..' variable
df$Beeldschermdiagonaal..inch.. <- (gsub("inch", "", df$Beeldschermdiagonaal..inch..))  # 'inch' from 'Beeldschermdiagonaal..inch..' variable

# Assure numeric datatypes
column_list_numeric <- grep('price|rating|nr_reviews', colnames(df,), value=T)
for (column in column_list_numeric){
  df[,column] <- as.numeric(df[,column])
}

# Assure factor datatypes
df$device_type <- as.factor(df$device_type)
df$instock <- as.factor(df$instock)


# Remove 'Beamers & projectie' value of 'device_type'
df <- subset(df, device_type != "Beamers & projectie")

# Replace incorrect value names by 'Mobiele telefoons'
df$device_type <- (gsub("XIAOMI 12 256GB - Grijs|XIAOMI POCO X4 Pro 5G 256GB - Zwart|XIAOMI Xiaomi 12 Pro 256GB - Blauw|XIAOMI Xiaomi 12 Pro 256GB - Grijs", 
                                          "Mobiele telefoons", df$device_type))

# Add column consisting of brand names
df$brand <-word(unlist(df$name[1:1580]))

                                                ####################
                                                ###data-analysis####
                                                ####################

ggplot(df, 
       aes(x = brand,   
           fill = device_type)) +               # total distribution for device type per brand
  geom_bar(position = "stack") + coord_flip()

# number of units per categorical variables
count(df, vars = device_type)                   # for device_type
ggplot(df, aes(x = device_type)) + 
  geom_bar()

total_brand <- count(df, vars = brand)          # for brand
View(total_brand)
ggplot(df, aes(x = brand)) + 
  geom_bar() + coord_flip()

# distribution of device types 
plotdata_devices <- df %>%
  count(device_type)                                                            
View(plotdata_devices)                                                      
                                        
ggplot(plotdata_devices, 
       aes(x = reorder(device_type, n),                                     
           y = n)) + 
  geom_bar(stat = "identity", fill = "indianred3", color = "black") +                    # total units per device type                     
  geom_text(aes(label = n), vjust = 2, size = 4) +
  labs(x = "Device type", 
       y = "Frequency", 
       title  = "Distribution of device types")

# means and standard deviations per device type
mean_prices <- df %>% group_by(device_type) %>%         
  summarise(mean_price = mean(price, na.rm = TRUE))                                      # mean price
View(mean_prices)
sd_prices <- df %>% group_by(device_type) %>% 
  summarise(sd_prices = sd(price, na.rm = TRUE))                                         # standard deviation price
View(sd_prices)

mean_rating <- df %>% group_by(device_type) %>%         
  summarise(mean_rating = mean(rating, na.rm = TRUE))                                    # mean rating
View(mean_rating)
sd_rating <- df %>% group_by(device_type) %>% 
  summarise(sd_rating = sd(rating, na.rm = TRUE))                                        # standard deviation rating
View(sd_rating)

mean_nr_reviews <- df %>% group_by(device_type) %>%         
  summarise(mean_nr_reviews = mean(nr_reviews, na.rm = TRUE))                            # mean nr reviews
View(mean_nr_reviews)
sd_nr_reviews <- df %>% group_by(device_type) %>% 
  summarise(sd_nr_reviews = sd(nr_reviews, na.rm = TRUE))                                # standard deviation nr reviews
View(sd_nr_reviews)
                                                                                       
ggplot(mean_prices, aes(x = device_type, y= mean_price)) + 
  geom_bar(stat = "identity", fill = "indianred3", color = "black") +                    # mean prices per device type
  geom_text(aes(label = mean_price), vjust = 2, size = 4) +
  labs(x = "Device type", y = "Mean price", title  = "Mean prices per device type") 

# statistics of device specifications per device type
Mobiele_telefoons <- filter(df, device_type == "Mobiele telefoons")                      # subset 'Mobiele telefoons'

best_systeem <- Mobiele_telefoons %>% group_by(brand) %>%  count(Besturingssysteem.)     # distribution of 'Besturingssysteem' in 'Mobiele telefoons' by brand
View(best_systeem)

geh_cap <- Mobiele_telefoons %>% group_by(brand) %>%  count(Geheugencapaciteit.)         # distribution of 'Geheugencapaciteit' in 'Mobiele telefoons' by brand
View(geh_cap)

sim_format <- Mobiele_telefoons %>% group_by(brand) %>%  count(Simkaartformaat.)         # distribution of 'Simkaartformaat' in 'Mobiele telefoons' by brand
View(sim_format)




Laptops <- filter(df, device_type == "Laptops")                                          # subset 'Laptops'

laptop_touch <- Laptops %>% group_by(brand) %>%  count(Touchscreen.)                     # distribution of 'Touchscreen' for laptops by brand
View(laptop_touch)

laptop_scr_res <- Laptops %>% group_by(brand) %>%  count(Beeldresolutie.)                # distribution of 'Beeldresolutie' for laptops by brand
View(laptop_scr_res)

laptop_scr_mean <- Laptops %>% group_by(brand) %>%         
  summarise(mean_scr_cm = mean(as.numeric(Beeldschermdiagonaal..cm..), na.rm = TRUE))    # mean screensize in cm for laptops by brand
View(laptop_scr_mean)




Tablets <- filter(df, device_type == "Tablets")                                          # subset 'Tablets' 

tablet_scr_res <- Laptops %>% group_by(brand) %>%  count(Beeldresolutie.)                # distribution of 'Beeldresolutie' for tablets by brand
View(tablet_scr_res)

tablet_scr_mean <- Tablets %>% group_by(brand) %>%         
  summarise(mean_scr_cm = mean(as.numeric(Beeldschermdiagonaal..cm..), na.rm = TRUE))    # mean screensize in cm for tablets by brand
View(tablet_scr_mean)




Televisions <- filter(df, device_type == "Televisies")                                   # subset 'Televisies'

tv_scr_mean <- Televisions %>% group_by(brand) %>%         
  summarise(mean_scr_cm = mean(as.numeric(Beeldschermdiagonaal..cm..), na.rm = TRUE))    # mean screensize in cm for televisions by brand
View(tv_scr_mean)

tv_scr_res <- Televisions %>% group_by(brand) %>%  count(Beeldresolutie.)                # distribution of 'Beeldresolutie' for televisions by brand
View(tv_scr_res)



                                              #####################
                                              #######Top  15#######
                                              #####################

# Filter 15 most common brands for valuable price analysis
tab <- table(df$brand)                        # calculate frequencies
tab_s <- sort(tab)                            # sort
top15 <- tail(names(tab_s), 15)               # extract 15 most frequent brands
df_common <- subset(df, brand %in% top15)     # subset of data frame based on common brands

# price distributions per brand
boxplot(df_common$price~df_common$brand,main="General price distribution by brand", 
        ylab="", xlab="price", ylim=c(100, 4000), horizontal = TRUE, las = 2)

# Price distribution per brand for 'Mobiele telefoons' 
boxplot(df_common$price[df_common$device_type=="Mobiele telefoons"]~df_common$brand[df_common$device_type=="Mobiele telefoons"]
        ,main="Smartphone price distribution by brand", ylab="", xlab="price", ylim=c(100, 2000), col="red", horizontal = TRUE, las = 2)

# Price distribution per brand for 'Laptops' 
boxplot(df_common$price[df_common$device_type=="Tablets"]~df_common$brand[df_common$device_type=="Tablets"]
        ,main="Tablets price distribution by brand", ylab="", xlab="price", ylim=c(100, 2700), col="lightgreen", horizontal = TRUE, las = 2)

# Price distribution per brand for 'Televisies' 
boxplot(df_common$price[df_common$device_type=="Televisies"]~df_common$brand[df_common$device_type=="Televisies"]
        ,main="Televisions price distribution by brand", ylab="", xlab="price", ylim=c(100, 5000), col="yellow", horizontal = TRUE, las = 2)

# Price distribution per brand for 'Tablets' 
boxplot(df_common$price[df_common$device_type=="Laptops"]~df_common$brand[df_common$device_type=="Laptops"]
        ,main="Laptops price distribution by brand", ylab="", xlab="price", ylim=c(100, 4000), col="purple", horizontal = TRUE, las = 2) 





















