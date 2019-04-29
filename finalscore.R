
library(dplyr)

## Edit for exam name
scores <- (scores
	%>% select(idnum=idnum, midterm2_score=bestScore)
)

summary(scores)
