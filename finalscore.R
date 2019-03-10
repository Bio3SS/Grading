
library(dplyr)

## Edit for exam name
scores <- (scores
	%>% select(idnum=idnum, midterm1_score=bestScore)
)

## summary(scores)
