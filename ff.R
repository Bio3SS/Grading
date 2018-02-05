finalMarks <- envir_list[[1]]$finalMarks
corr <- envir_list[[2]]$finalMarks
finalMarks$score <- finalMarks$score + corr$score

# rdsave(finalMarks)
