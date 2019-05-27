
library(dplyr)

## Edit for exam name
scores <- (scores
	%>% transmute(idnum=as.numeric(idnum), final_score=bestScore)
)

summary(scores)
