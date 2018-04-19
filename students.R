library(readr)
library(dplyr)

students <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.numeric(idnum))
	)
	%>% select(macid, idnum)
)

summary(students)

