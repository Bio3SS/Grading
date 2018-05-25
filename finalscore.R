
library(dplyr)

scores <- (scores
	%>% select(idnum=idnum, Exam_score=bestScore)
)

## summary(scores)
