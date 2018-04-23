library(dplyr)
library(readr)

(left_join(students, scores)
	%>% setNames(gsub(pattern="_score", replacement=" Points Grade" , names(.)))
	%>% mutate(`End-of-Line Indicator` = "#")
	%>% rename(OrgDefinedId=idnum , Username=macid)
) %>% write_csv(csvname)

# rdnosave

