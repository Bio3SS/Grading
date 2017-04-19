report <- read.csv(input_files[[1]])
names(report) <- sub("Reponding", "Responding", names(report))
print(names(report))

idfields <- 1:5

id <- report[idfields]
report <- report[-idfields]

recfields <- grep("Received.At", names(report))
rec <- report[recfields]
report <- report[-recfields]

modfields <- grep("Modality", names(report))
report <- report[-modfields]

numResp <- sapply(rec, function(t){
	sum(!is.na(t) & t != "")
})

res <- numResp>1

rec <- rec[res]
report <- report[res]

# rdsave(id, report, rec)
