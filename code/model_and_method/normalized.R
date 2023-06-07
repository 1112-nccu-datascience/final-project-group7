library(magrittr)
library(stringr)
library(dplyr)
library(readr)

df <- read_csv("data/output_name.csv")

df.nor <- mutate(df,
                 across(.col = 8:276, 
                        .fns = ~ .x / max(.x),
                        .names = "{.col}"))

df.log <- mutate(df,
                 across(.col = 8:276, 
                        .fns = ~ log(.x + exp(1)),
                        .names = "{.col}"))

write_csv(df.nor, file = "output_name_nor_max.csv")
write_csv(df.log, file = "output_name_nor_log.csv")
