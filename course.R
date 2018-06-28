
downgrade <- 1000 ## 0 for no downgrade (power = number completed)
offset <- 0 ## increase to round up instead of down
testwt <- c(25, 25, 40)
asntot <- c(16, 12, 9, 10)

## it would be nice to get these back... why could Marvin upload negatives?
## avenueMissing <- -95
## avenueMSAF <- -99

library(dplyr)
library(readr)

## This is wrong: need to change Missing finals to zeroes!
## Accidentally gave a bunch of people with no finals grades in 2018

course <- (students
	%>% full_join(tests)
	%>% full_join(assign)
	%>% full_join(polls)

	%>% rowwise()
	%>% mutate(testAve = powerAve(
		scores=c(midterm1.test, midterm2.test, final.test)
		, dens=testwt, weights=testwt, downgrade=downgrade
	))

	%>% mutate(asnAve = powerAve(
		scores=c(Assignment.1, Assignment.2, Assignment.3, Assignment.4)
		, dens=asntot, weights=1, downgrade=downgrade
	))

	%>% mutate(
		Polls_score = naZero(Polls_score)
		, attendance = naZero(attendance) 
	)

	%>% mutate(
		courseGrade = 90*testAve + 8*asnAve + 2*attendance + Polls_score
		# , courseGrade = floor(courseGrade+offset)
	)
)

summary(course)

(course
	%>% transmute(macid, idnum
		, attendance=round(attendance, 3)
		, Polls_score=round(Polls_score, 3)
		, testAve=round(testAve, 3)
		, asnAve=round(asnAve, 3)
		, courseGrade=round(courseGrade, 3)
	)
) %>% write_csv(csvname)

# rdsave(course)
