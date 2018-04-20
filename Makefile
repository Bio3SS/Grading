# Grading

# Change codes UGRD/2171/02/BIOLOGY/101187
# Maybe

### Hooks for the editor to set the default target
current: target
-include target.mk

##################################################################

# make files

Sources = Makefile .ignore README.md sub.mk LICENSE.md
include sub.mk
-include $(ms)/perl.def

##################################################################

## Content

Sources += $(wildcard *.R *.pl)

## sd /home/dushoff/Dropbox/courses/3SS/2017 ##

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2018
dropdir:
	$(linkdirname)
dropdir/%: dropdir ;

######################################################################

## Spreadsheets

## To do:
##   reverse the hierarchy of this directory and Tests
##   move calc-y stuff from Tests to here

## We keep track with named versions, so that we don't have to git the spreadsheets

## Could make a fun (auto-sort) version of this rule some day

Ignore += marks.tsv
marks.tsv: dropdir/marks3.tsv zero.pl
	$(PUSH)

students.Rout: marks.tsv dropdir/drops.csv students.R

######################################################################

## Polls

## Get PollEverywhere data:
## 	https://www.polleverywhere.com/reports / Create reports
## 	Participant response history
## 	Select groups for this year
## 	Download csv (lower right)

## To repeat:
##		Reports / select report you want / Update reports (next to Current Run)

##		downcall dropdir/polls.csv ## ## ##

## Mosaic:
## downcall dropdir/roster.xls

######################################################################

# Read the polls into a big csv without most of the useless information
# 2018 Apr 20 (Fri) Manually changed an idnum to a macid
# There is one perfect score with no identifiers, and two smallish orphan lines that could be identified if I wanted to bother
polls.Rout: dropdir/polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the last question as a fake, and use it to help with ID
# May or may not be implemented
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
pollScore.Rout: dropdir/extraPolls.ssv parsePolls.Rout pollScore.R

## Make an avenue file; should work with any number of fields ending in _score
## along with a field for macid, idnum or both

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=235353
## import

Ignore += pollScore.avenue.Rout.csv
pollScore.avenue.Rout.csv: avenueMerge.R
%.avenue.Rout: %.Rout students.Rout avenueMerge.R
	$(run-R)

Ignore += pollScore.avenue.csv
pollScore.avenue.csv: avenueNA.pl
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

######################################################################

## Other stuff all suppressed for now!

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
