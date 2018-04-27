library(dplyr)
objects()

tests <- students

for (n in names(envir_list)){
	short <- sub(".patch", "", n)
	tests <- (left_join(tests,
		(envir_list[[n]]$scores
			%>% select(idnum, bestScore)
			%>% setNames(c("idnum", short))
		)
	))
}

summary(tests)

# rdsave(tests)
