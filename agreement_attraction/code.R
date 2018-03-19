library(ggplot2)
library(reshape2)
library(gridExtra)

# assume the files are in the current working directory
SE_file <- "se_dat.csv"
mean_rts_file <- "meanrts.csv"

# PREPARE DATA FOR ERROR BARS PLOTTING ------

# Some of the data comes from SPSS ouptut, so we need to clean them
means_raw <- read.csv(SE_file)
means <- means_raw[means_raw$err != "Total",]

# select the correct values
selector <- means$gender %in% c("FF","FM", "MF", "MM(F)", "MM(N)", "MN","NN","NM")
selector.char <- paste0(as.character(selector), collapse=" ")
selector.char <- gsub("TRUE FALSE", "TRUE TRUE", selector.char)
selector.char <- unlist(strsplit(selector.char," "))
selector <- as.logical(selector.char)

means <- means[selector,]
means$gender <- as.character(means$gender)

# make the names of conditions
tmp <- means[means$gender!="","gender"]
tmp <- rep(tmp,each=2)
means$gender <- tmp

# replace err = 0/1 with genders
means$err <- c("F","M","F","M","M","F","M","F","M","N","M","N","N","M","N","M")

means$se <- means$sd/sqrt(means$n)

means$cond <- paste0(means$gender, means$err)

# ADD ERROR INFO IN THE DATA.FRAME for plotting -------
dat <- read.csv(mean_rts_file, header=TRUE)

dat1 <- melt(dat,id.vars=c("X","np","pred"), value.name = "rt", variable.name = "reg")
dat1$reg <- as.numeric(gsub("reg", "", dat1$reg))
colnames(dat1)[5] <- "rt"
dat1$cond <- paste0(dat1$np, dat1$pred)

dat1$merger <- paste0(dat1$reg,dat1$cond)
means$merger <- paste0(means$reg, means$cond)

dat1$reg <- as.factor(dat1$reg)

dat.plot <- merge(means[,c("merger","se")],dat1,by="merger")
dat.plot$cond <- gsub("MM\\(F\\)F","MMF",dat.plot$cond)
dat.plot$cond <- gsub("MM\\(F\\)M","MMM(F)",dat.plot$cond)
dat.plot$cond <- gsub("MM\\(N\\)N","MMN",dat.plot$cond)
dat.plot$cond <- gsub("MM\\(N\\)M","MMM(N)",dat.plot$cond)

# --------------\\ define our experimental conditions
# IMPORTANT: the order of conditions inside a group:
#  grammatical no interference, grammatical interf,
# ungrammatical no interf, ungrammatical interf
ff <- c("FMF","FFF", "FFM", "FMM")
nn <- c("NMN", "NNN", "NNM", "NMM")
mf <- c("MFM", "MMM(F)", "MMF", "MFF")
mn <- c("MNM","MMM(N)", "MMN", "MNN")

# subset data

dat.ff <- dat.plot[dat.plot$cond %in% ff,]
dat.ff$cond <- factor(dat.ff$cond, ff) # order genders in the needed order
dat.nn <- dat.plot[dat.plot$cond %in% nn,]
dat.nn$cond <- factor(dat.nn$cond, nn)
dat.mf <- dat.plot[dat.plot$cond %in% mf,]
dat.mn <- dat.plot[dat.plot$cond %in% mn,]


# Important: we are not displaying conditions such as MMM(F), but
# they were needed for subsetting. Now I will change them to just
# MMM

mf <- c("MFM", "MMM", "MMF", "MFF")
mn <- c("MNM","MMM", "MMN", "MNN")
dat.mf$cond <- gsub("MMM\\(F\\)", "MMM",dat.mf$cond )
dat.mn$cond <- gsub("MMM\\(N\\)", "MMM",dat.mn$cond )
dat.mf$cond <- factor(dat.mf$cond, mf)
dat.mn$cond <- factor(dat.mn$cond, mn)

# set colors
colors <- c("blue","cadetblue3","red3","salmon")

# PLOTS -----

# set the theme
mytheme <- theme_grey()
mytheme <- mytheme + theme(panel.background = element_rect(fill='white',
                                                 colour='black'),
                 panel.grid.major = element_line(colour="lightgrey"),
                 legend.key=element_rect(fill="white", color="black"),
                 text = element_text(size=7),
                 legend.key.width = unit(0.5, "cm"),
                 legend.key.height = unit(0.5, "cm"),
                 plot.margin= unit(c(0.5,0,0,0), "cm"))
theme_set(mytheme)

# ff
names(colors) <- ff
plot.ff <- ggplot(data = dat.ff, aes(x=reg, y=rt)) +
  geom_line(aes(group=cond, colour=cond),size=0.5)+
  geom_errorbar(aes(ymin = rt-se, ymax = rt+se, width=0.2), size = 0.3)+
  scale_colour_manual("Genders", values= colors)+
  xlab("Region")+
  ylab("RTs")+
  ggtitle("a) Feminine head, masculine and feminine attractors")+
  coord_cartesian(ylim=c(270,430))+
  theme(plot.title = element_text(hjust = 0))
plot(plot.ff)# for some reasons, if I don't call it here, all the plots
# (except for the last one) are saved to the file with no lines


# mf
names(colors) <- mf
plot.mf <- ggplot(data = dat.mf, aes(x=reg, y=rt)) +
  geom_line(aes(group=cond, colour=cond),size=0.5)+
  geom_errorbar(aes(ymin = rt-se, ymax = rt+se, width=0.2), size = 0.3)+
  scale_colour_manual("Genders", values= colors)+
  xlab("Region")+
  ylab("RTs")+
  ggtitle("b) Masculine head, feminine and masculine attractors")+
  coord_cartesian(ylim=c(270,430))+
  theme(plot.title = element_text(hjust = 0))
plot(plot.mf)


# nn
names(colors) <- nn
plot.nn <- ggplot(data = dat.nn, aes(x=reg, y=rt)) +
  geom_line(aes(group=cond, colour=cond),size=0.5)+
  geom_errorbar(aes(ymin = rt-se, ymax = rt+se, width=0.2), size = 0.3)+
  scale_colour_manual("Genders", values= colors)+
  xlab("Region")+
  ylab("RTs")+
  ggtitle("c) Neuter head, masculine and neuter attractors")+
  coord_cartesian(ylim=c(270,430))+
  theme(plot.title = element_text(hjust = 0))
plot(plot.nn)


# mn
names(colors) <- mn
plot.mn <- ggplot(data = dat.mn, aes(x=reg, y=rt)) +
  geom_line(aes(group=cond, colour=cond),size=0.5)+
  geom_errorbar(aes(ymin = rt-se, ymax = rt+se, width=0.2), size = 0.3)+
  scale_colour_manual("Genders", values= colors)+
  xlab("Region")+
  ylab("RTs")+
  ggtitle("d) Masculine head, neuter and masculine attractors")+
  coord_cartesian(ylim=c(270,430))+
  theme(plot.title = element_text(hjust = 0))
plot(plot.mn)

# EXPORT -------
exp.plot <- arrangeGrob(plot.ff,
                        plot.mf,
                        plot.nn,
                        plot.mn,
                        ncol=2,
                        top = "Experiment 2a: reading times (in ms) by conditions")
exp.plot
ggsave(filename = "output.png", plot = exp.plot, dpi=900, units="mm", width = 180, height = 100)
