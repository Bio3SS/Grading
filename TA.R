library(dplyr)
TA <- 

TA <- (read.csv(input_files[[1]])
	%>% rename(
		T1=Midterm1.Points.Grade..Numeric.MaxPoints.25.
		, A1=Assignment1.Points.Grade..Numeric.MaxPoints.16.
		, A2=Assignment2.Points.Grade..Numeric.MaxPoints.12.
		, A3=Assignment3.Points.Grade..Numeric.MaxPoints.9.
		, T2=Midterm2.Points.Grade..Numeric.MaxPoints.25.
		, A4=Assignment4.Points.Grade..Numeric.MaxPoints.10.
	)
)

summary(TA)
