library(readr)
library(dplyr)

sheet <- (read_tsv(input_files[[1]])
	%>% anti_join(
		read_csv(input_files[[2]])
		%>% mutate(idnum=as.numeric(idnum))
	)
	%>% mutate(idnum=(
			sprintf("%9d", idnum) 
			%>% gsub(pattern=" ", replacement="0")
	))
)

## Dropped some Avenue-ish stuff. Can be found in avenueMerge, and maybe in the old (Tests/) version of this file

sa <- (sheet 
	%>% transmute(idnum=idnum, macid=macid
		, sa1=`Exam 1 SA`, manVer1 = `Exam 1 Version`
		, sa2=`Exam 2 SA`, manVer2 = `Exam 2 Version`
	)
)

summary(sa)

assign <- (sheet %>% 
	transmute(idnum, macid
		, attendance = (
			select(sheet, contains("Tutorial ")) %>% rowMeans(na.rm=TRUE)
		)
	) %>% bind_cols(
		select(sheet, contains("Assignment "))
		%>% setNames(make.names(names(.)))
	)
)
summary(assign)

students <- assign %>% select(idnum, macid)

# rdsave(sa, assign, students)

