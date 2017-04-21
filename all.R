library(dplyr)

TA <- read.csv(input_files[[1]])
polls <- read.csv(input_files[[2]])

print(summary(TA))
print(summary(polls))

tab <- (TA
	%>% left_join(finalScore)
	%>% left_join(polls)
)

print(summary(tab))
