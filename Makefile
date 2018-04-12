# Grading

# Change codes UGRD/2171/02/BIOLOGY/101187
# Maybe

### Hooks for the editor to set the default target
current: target
-include target.mk

##################################################################

# make files

Sources = Makefile .gitignore README.md sub.mk LICENSE.md
include sub.mk
-include $(ms)/perl.def

##################################################################

## Content

Sources += $(wildcard *.R *.pl)

## /home/dushoff/Dropbox/courses/3SS/2017

dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2018
dropdir:
	$(linkdirname)
dropdir/%: dropdir

######################################################################

## Polls

# Read the polls into a big csv without most of the useless information
polls.Rout: dropdir/polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the last question as a fake, and use it to help with ID
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
pollScore.Rout.csv: pollScore.R
pollScore.Rout: extraPolls.ssv parsePolls.Rout pollScore.R

pollScore.students.csv: pollScore.Rout.csv
	perl -ne "print unless /UNKNOWN/" $< > $@

######################################################################

## Other stuff all suppressed for now!

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
