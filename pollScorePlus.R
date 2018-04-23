library(dplyr)

names(students)
names(scores)

new <- (
	inner_join(students, scores, by = c("idnum" = "macid"))
	%>% select(macid, Polls_score)
) 

scores <- (scores
	%>% bind_rows(new)
	%>% group_by(macid)
	%>% summarise(Polls_score=sum(Polls_score))
)

# rdsave (scores)
