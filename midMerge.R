library(readr)
library(dplyr)

objects()

num <- gsub("[[:alpha:].]", "", rtargetname)
summary(sa)

sa <- (sa
	%>% setNames(sub(num, "_curr", names(.)))
	%>% transmute(idnum, sa=sa_curr, manVer=manVer_curr)
)

## sa is from TAmarks; so use left to drop students dropped there
## keep paying attention to others (do they have MSAF NAs?)
scores <- (left_join(sa, scores)
	%>% mutate(version = ifelse(version==-1, NA, version)
		, version = ifelse(is.na(version), manVer, version)
	)
)
head(scores)
summary(scores)

## This code is cumbersome, but I'm trying to remember to use NAs 
## in a principled fashion

## Old comment, still relevant?
## Need to check bestVer again, because we've supplemented
mismatch <- filter(scores, 
	(!is.na(manVer) && manVer != version)
	|| (!is.na(version) && bestVer != version)
	|| (!is.na(verScore)) && (verScore>0) && (verScore != bestScore)
)

print(mismatch)
## stopifnot(nrow(mismatch)==0)

print(filter(scores, is.na(bestScore)))
print(filter(scores, is.na(sa)))

scores <- (scores 
	%>% filter(!is.na(version))
	%>% mutate(bestScore = bestScore+sa)
	%>% filter(!is.na(bestScore))
)

