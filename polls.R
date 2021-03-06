report <- read.csv(input_files[[1]])
print(names(report))

## Spin out different kinds of fields (id, time received, modality)
idfields <- c(1:6)
id <- report[idfields]
report <- report[-idfields]

recfields <- grep("Received.At", names(report))
rec <- report[recfields]
report <- report[-recfields]

modfields <- grep("Modality", names(report))
report <- report[-modfields]

stopifnot(
	(length(modfields) == length(rec))
	&& (length(report) == length(rec))
)

numResp <- sapply(rec, function(t){
	sum(!is.na(t) & t != "")
})

res <- numResp>1

rec <- rec[res]
report <- report[res]

# rdsave(id, report, rec)
