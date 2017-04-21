library(dplyr)
finalFrame <- read.csv(input_files[[1]])

summary(finalFrame)
summary(bubbleScores)

finalScore <- (finalFrame
	%>% transmute(Username=User.ID, idnum=Student.Number) 
	%>% full_join(bubbleScores)
)

summary(finalScore)

# rdsave(finalScore)
