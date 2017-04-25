library(dplyr)
library(readr)

roster <- read_csv(input_files[[1]])
n <- names(roster)

names(roster) <- gsub(" ", "_", n)

print(n)

summary(tab)
summary(roster)

merge <- (roster
	%>% rename(idnum=Student_Nbr)
	%>% left_join(tab)
)

roster <- (roster
	%>% mutate(Roster_Grade=merge$mark)
	%>% mutate(Student_Nbr=sprintf("%09d", as.numeric(Student_Nbr)))
)

names(roster) <- n

write_csv(roster, csvname)
