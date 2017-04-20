## Sheets means scantron sheets
sheets <- read.csv(input_files[[1]], header=FALSE, row.names=1)
versionOrder <- read.table(input_files[[2]], header=FALSE, row.names=1)
key <- as.character(read.table(input_files[[3]], header=FALSE, row.names=1)[[1]])

answers <- as.matrix(sheets[-1])
allScores <- apply(answers, 1, function(a){
	vs <- sapply(versionOrder, function(v){
		return(sum(a[order(v)]==key))
	})
	return((vs))
})

bestScore <- apply(allScores, 2, max)
bestVer <- apply(allScores, 2, which.max)

scoreVersion <- data.frame(
	idnum = as.numeric(as.character(rownames(sheets))),
	bubble=sheets[[1]],
	bestVer, bestScore
)

print(subset(scoreVersion, bubble<1))

# Temporarily patch missing version
scoreVersion <- within(scoreVersion, {
	bubble[bubble<1] <- 1
})

vprob <- subset(scoreVersion, bubble != bestVer)
print(vprob)
print(allScores[ , rownames(vprob)])

bubbleSel <- sapply(1:nrow(sheets), function(n){
	return(allScores[[scoreVersion$bubble[[n]], n]])
	return(c(scoreVersion$bubble[[n]], n))
})

bubbleScores <- data.frame(
	idnum = as.numeric(as.character(rownames(sheets))),
	score = bubbleSel
)

write.csv(bubbleScores, csvname)

# rdsave(key, answers, versionOrder, scoreVersion, bubbleScores)
