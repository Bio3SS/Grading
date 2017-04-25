library(dplyr)
library(readr)

roster <- read_csv(input_files[[1]])
names(roster) <- gsub(" ", "_", names(roster))

summary(tab)
summary(roster)

merge <- (roster
	%>% rename(idnum=Student_Nbr)
	%>% left_join(tab)
)

print(tab
	%>% filter(final==0)
	%>% select(idnum)
)

roster <- (roster
	%>% transmute(Class=Class
		,  Student_Nbr=sprintf("%09d", as.numeric(Student_Nbr))
		, Roster_Grade=as.integer(merge$mark)
	)
)

write_csv(roster, csvname, col_names=FALSE)
