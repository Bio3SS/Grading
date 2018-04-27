library(dplyr)
library(readr)

course <- (tests
	%>% full_join(marks)
	%>% full_join(polls)
) 

summary(course)
