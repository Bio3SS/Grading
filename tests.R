library(dplyr)
objects()
names(students)
print(names(envir_list))
print(names(envir_list[[1]]))
print(names(envir_list[[1]]$scores))

for (n in names(envir_list)){
	short <- sub(".patch", "", n)
	students <- (full_join(students,
		(envir_list[[n]]$scores
			%>% select(idnum, bestScore)
			%>% setNames(c("idnum", short))
		)
	))
}

summary(students)
