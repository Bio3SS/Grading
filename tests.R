library(dplyr)
library(stringr)
objects()

tests <- students

for (n in names(envir_list)){
	short <- (n
		%>% str_replace(".merge", "")
		%>% str_replace(".patch", "")
		%>% str_replace("$", ".test")
	)
	tests <- (left_join(tests,
		(envir_list[[n]]$scores
			%>% select(idnum, bestScore)
			%>% setNames(c("idnum", short))
		)
	))
}

summary(tests)

# rdsave(tests)
