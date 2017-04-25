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
	%>% transmute(Class=Class
		,  Student_Nbr=sprintf("%09d", as.numeric(Student_Nbr))
		, Roster_Grade=as.integer(merge$mark)
	)
)

write_csv(roster, csvname, col_names=FALSE)
