offset <- 0
library(dplyr)
library(readr)

roster <- read_csv(input_files[[1]])
names(roster) <- gsub(" ", "_", names(roster))

summary(roster)

roster <- (roster
	%>% mutate(idnum=sprintf("%09d", as.numeric(Student_Nbr))
	) 
	%>% left_join(course)
	%>% transmute(Class, idnum, mark=round(courseGrade+offset))
) %>% write_csv(csvname, col_names=FALSE)

summary(roster)
