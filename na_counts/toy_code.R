# install the package if not already installed
#
# devtools::install_github("antonmalko/ettools")


library(ettools)

# Assume that the dat is in the current working directory
dat <- read.csv("toy_data.csv")
report <- report_NAs_count(dat,
                           plot.name = "NAs count for the toy data")

# print the resulting plot. There will be many gaps since the toy data contains
# a random sample of participants, and it turned out to sample non-adjacent
# participants
report$plot

ggplot2::ggsave(filename = "toy_plot.png", plot = report$plot, units="mm", width = 240, height = 240)

# the output also contains a data.frame with NA counts
report$counts



