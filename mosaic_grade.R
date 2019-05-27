library(dplyr)
library(readr)

Class <- 10699

roster <- read_csv(input_files[[1]])
names(roster) <- gsub(" ", "_", names(roster))

summary(roster)

roster <- (roster
	%>% mutate(idnum=sprintf("%09d", as.numeric(ID))) 
	%>% left_join(course)
	%>% transmute(Class=Class, idnum, mark=round(courseGrade))
) %>% write_csv(csvname, col_names=FALSE)

summary(roster)

dropCandidates <- roster %>% filter(is.na(mark))

(roster
	%>% filter(!is.na(mark))
) %>% write_csv(csvname, col_names=FALSE)
