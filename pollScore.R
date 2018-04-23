
library(dplyr)

needMax <- 0.9
weight <- (sum(1/qq))
print(weight)

print(nrow(as.matrix(report)))
print(length(qq))

score <- apply(as.matrix(report), 1, function(s){
	return(sum(
		(nchar(as.character(s))>1)/qq
		, na.rm=TRUE
	))
})

sf <- data.frame(id=id, score=score)
sf <- (sf
	%>% mutate(id = sub(",.*", "", id))
	%>% group_by(id)
	%>% summarise(score = sum(score))
)

ef <- read.table(input_files[[1]], header=TRUE)
df <- merge(sf, ef, all.x=TRUE)
df <- within(df, {
	extra[is.na(extra)] <- 0
	score <- score+extra
	score <- 2*pmin(1, score/(needMax*weight))
	score <- round(100*score)/100
})

scores <- (df
	%>% filter(!is.na(score))
	%>% transmute(macid=id, Polls_score=score)
)

summary(scores)
write.csv(file=csvname, df, row.names=FALSE)

# rdsave(scores)
