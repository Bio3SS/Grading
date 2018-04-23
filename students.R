library(readr)
library(dplyr)

students <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.numeric(idnum))
	)
	%>% mutate(idnum=(
			sprintf("%9d", idnum) 
			%>% gsub(pattern=" ", replacement="0")
	))
	%>% select(macid, idnum)
)

summary(students)

