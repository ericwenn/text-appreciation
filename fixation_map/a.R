library("emov")
library("ggplot2")
file=P01_4504
#P01_4504 <- read.table("C:/Users/User/Desktop/aggr/P01_4504.txt", header=TRUE, sep=",")
#low pass filter
file$x = filter(file$L_POR_X, rep(1/15, 15))
file$y = filter(file$L_POR_Y, rep(1/15, 15))
fixations_2 = emov.idt(file$Time, file$L_POR_X, file$L_POR_Y, 100,4)
ggplot(fixations_2, aes(x = x, y = y)) +geom_path(color = 'darkred') +geom_point(size = 2)

for (i in 1:10) {
}
