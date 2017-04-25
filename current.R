library(dplyr)

names(tab)

current <- (tab
	%>% transmute(Username=Username
		, final = ifelse(is.na(final), -95, final) 
		, poll = ifelse(is.na(poll), -95, poll) 
		, mark = mark 
		, idnum = idnum
		, End.of.Line.Indicator = End.of.Line.Indicator
	)
)

write.csv(current, csvname, row.names=FALSE)

