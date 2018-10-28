library("emov")
library("ggplot2")
file=P01_13165
file$x = filter(file$L.POR.X..px., rep(1/15, 15))
file$y = filter(file$L.POR.Y..px., rep(1/15, 15))
fixations_2 = emov.idt(file$Time, file$L.POR.X..px., file$L.POR.Y..px., 100,4)
ggplot(fixations_2, aes(x = x, y = y)) +geom_path(color = 'darkred') +geom_point(size = 2)
