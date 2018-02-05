library(dplyr)
scoreTable <- read.csv(input_files[[1]])

summary(scoreTable)
summary(finalMarks)

finalScore <- (scoreTable
	%>% transmute(Username=Username, idnum=OrgDefinedId) 
	%>% mutate(Username=sub("@.*", "", Username))
	%>% full_join(finalMarks)
	%>% rename(final=score)
)

summary(finalScore)

# rdsave(finalScore)
