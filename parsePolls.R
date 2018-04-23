
## Transfer the fake question from question world to id world

fq <-(which(grepl("macid", names(report))))
if(length(fq)==1){
	id$ques <- report[[fq]]
	report <- report[-fq]
	fqgroup <- fq:(fq+2)
	# rec <- rec[-fqgroup]
	rec <- rec[-fq]
} else {id$ques <- "UNKNOWN"}

## What does the id frame look like?
print(summary(id))

emails <- with(id, {sapply(1:nrow(id), function(i){
	if(grepl("mcmaster", Email[[i]], ignore.case=TRUE)){
		return(as.character(Email[[i]]))
	}
	if(grepl("mcmaster", Custom.Report.ID[[i]], ignore.case=TRUE)){
		return(as.character(Custom.Report.ID[[i]]))
	}
	if(grepl("\\w", ques[[i]])){
		return(as.character(ques[[i]]))
	}
	return(paste(
		"UNKNOWN"
		, Participant.First.Name[[i]]
		, Participant.Last.Name[[i]]
		, Email[[i]]
		, Custom.Report.ID[[i]]
		, Screen.Name[[i]]
		, Public.ID[[i]]
		, sep="_"
	))
})})
id <- sub("@m.*", "", emails, ignore.case=TRUE)

print(class(rec))
## Get rid of time info, but keep date info (poll Everywhere has not been reliable about syntax)
rec <- as.data.frame(sapply(rec, function(r){
	return(sub(" +.*", "", r))
}))

qdates <- sapply(rec, function(r){
	return(levels(r)[[2]])
})

qq <- sapply(qdates, function(q){
	return(sum(q==qdates))
})

data.frame(
	qdates, qq
)

# rdsave(id, report, qq)
