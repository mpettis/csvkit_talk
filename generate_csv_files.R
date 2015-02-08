#!/usr/bin/env Rscript

    # Libraries
library(plyr)
library(dplyr)
library(tidyr)
library(nycflights13)

    # Setup
dir_dat <- file.path(getwd(), "dat")


    ## 1. Make mtcars csv files
    # Make dat as copy of mtcars
dat <- mtcars

    # move rownames to actual column name and remove rowname
dat$name <- rownames(mtcars)
rownames(dat) <- NULL

    # Make into datatable, rearrange so colnames is first column
dat <- dat %>% tbl_df %>% select(name, mpg:carb)


    # Output files
a_ply(1:55, 1, function(e) {
      csv_out <- file.path(dir_dat, sprintf("mtcars_%03d.csv", e))
      write.csv(dat, csv_out, row.names=FALSE)
})





    ## 2. Make transposed file of mtcars csv file
datt <- dat %>% t %>% as.data.frame(stringsAsFactors=FALSE) %>% tbl_df
names(datt) <- datt[1,]
datt <- datt[2:nrow(datt),]
datt$metric <- names(dat)[2:length(names(dat))]

datt <- datt %>% select(metric, 2:length(names(datt)))

write.csv(datt, file.path(dir_dat, "wide_mtcars.csv"), row.names=FALSE)

    ## 3. Make a long dataset
write.csv(flights %>% head(333), file.path(dir_dat, "long_flights.csv"), row.names=FALSE)


    ## 4. Make a wide dataset of some subset of flights
write.csv(flights %>% group_by(dest, month) %>% tally %>% spread(dest, n), file.path(dir_dat, "wide_flights_dest_month.csv"), row.names=FALSE)

