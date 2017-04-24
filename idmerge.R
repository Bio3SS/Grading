library(dplyr)
scoreTable <- read.csv(input_files[[1]])

summary(scoreTable)
summary(finalMarks)

finalScore <- (scoreTable
	%>% transmute(Username=User.ID, idnum=Student.Number) 
	%>% mutate(Username=sub("@.*", "", Username))
	%>% full_join(finalMarks)
	%>% rename(final=score)
)

summary(finalScore)

# rdsave(finalScore)
