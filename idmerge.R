library(dplyr)
finalFrame <- read.csv(input_files[[1]])

summary(finalFrame)
summary(bubbleScores)

finalScore <- (finalFrame
	%>% transmute(Username=User.ID, idnum=Student.Number) 
	%>% mutate(Username=sub("@.*", "", Username))
	%>% full_join(bubbleScores)
	%>% rename(final=score)
)

summary(finalScore)

# rdsave(finalScore)
