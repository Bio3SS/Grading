emails <- with(id, {sapply(1:nrow(id), function(i){
	if(grepl("mcmaster", Email[[i]], ignore.case=TRUE)){
		return(as.character(Email[[i]]))
	}
	if(grepl("mcmaster", Responding.As[[i]], ignore.case=TRUE)){
		return(as.character(Responding.As[[i]]))
	}
	return(paste(
		"UNKNOWN"
		, Participant.First.Name[[i]]
		, Participant.Last.Name[[i]]
		, Email[[i]]
		, Responding.As[[i]]
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
