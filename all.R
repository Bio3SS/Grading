library(dplyr)

downgrade <- 10 ## 0 for no downgrade
avenueZero <- -99
avenueNA <- -95

testwt <- c(25, 25, 40)
asntot <- c(16, 12, 9, 10)

polls <- read.csv(input_files[[1]])

tab <- (TA
	%>% left_join(finalScore)
	%>% left_join(polls)
	%>% mutate(
		final = ifelse(is.na(final), 0, final) 
		, poll = ifelse(is.na(poll), 0, poll) 
	)
)

print(summary(tab))

# The 3SS power average is an L-mean where L is a function of the number of tests completed

powerAve <- function(scores, dens, weights){
	scores <- ifelse(scores==avenueZero, 0, scores)
	scores <- ifelse(scores==avenueNA, NA, scores)
	power <- sum(sign(1+scores), na.rm=TRUE)
	power <- (power+downgrade)/(1+downgrade) 
	weight <- sum(sign(1+scores)*weights, na.rm=TRUE)
	scores <- scores/dens
	tot <- sum(scores^power*weights, na.rm=TRUE)
	return((tot/weight)^(1/power))
}

tab <- (tab 
	%>% rowwise()
	%>% mutate(testAve = powerAve(
		scores=c(T1, T2, final)
		, dens=testwt, weights=testwt
	))
)

# Legacy code for dropping assignments (when one is optional). 

dropAve <- function(scores, dens){
	perc <- scores/dens
	drop <- which.min(perc)[[1]]
	scores[[drop]] <- NA
	return(powerAve(scores, dens, weights=1))
}

# We use powerAve (L=1), because it deals properly with NAs.

tab <- (tab 
	%>% mutate(asnAve = powerAve(
		scores=c(A1, A2, A3, A4)
		, dens=asntot
		, weights=1
	))
)

tab <- (tab
	%>% mutate(
		mark = floor(90.*testAve + 10.*asnAve + poll)
	)
)
print(mean(tab$mark>=89.5))

summary(tab)
