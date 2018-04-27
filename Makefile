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

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2018
dropdir:
	$(linkdirname)
dropdir/%: dropdir ;

######################################################################

## Spreadsheets with TA marks from HWs and SAs
## How did we make original spreadsheet from Avenue?

## To do:
##   move calc-y stuff from Tests to here

## We keep track with named versions, so that we don't have to git the spreadsheets

## Could make a fun (auto-sort) version of this rule some day

Ignore += marks.tsv
## Change empties to zeroes
marks.tsv: dropdir/marks4.tsv zero.pl
	$(PUSH)

## Parse out TAmarks, drop students we think have dropped
## Used Avenue import info; this could be improved by starting from that
## Pull a subset of just student info

TAmarks.Rout: marks.tsv dropdir/drops.csv TAmarks.R

######################################################################

## Polls

## Get PollEverywhere data:
## 	https://www.polleverywhere.com/reports / Create reports
## 	Participant response history
## 	Select groups for this year
## 	Download csv (lower right)

## To repeat:
##		Reports / select report you want / Update reports (next to Current Run)

##		downcall dropdir/polls.csv ## ## ## ##

## Mosaic:
## downcall dropdir/roster.xls

######################################################################

# Read the polls into a big csv without most of the useless information
# 2018 Apr 20 (Fri) Manually changed an idnum to a macid

polls.Rout: dropdir/polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the question that matches "macid" as a fake (if present)
# and use it to help with ID
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
# This is where to look for orphan lines and try to figure out if people are missing points they should get
pollScore.Rout: dropdir/extraPolls.ssv parsePolls.Rout pollScore.R
pollScore.Rout.csv: 

# Merge to save people who repeatedly use student number
pollScorePlus.Rout: pollScore.Rout TAmarks.Rout pollScorePlus.R

## Make an avenue file; should work with any number of fields ending in _score
## along with a field for macid, idnum or both

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=235353
## import

pollScorePlus.avenue.Rout: avenueMerge.R
pollScorePlus.avenue.Rout.csv: avenueMerge.R

pollScorePlus.avenue.csv: avenueNA.pl

######################################################################

mdirs += Tests

Tests:
	git submodule add -b master https://github.com/Bio3SS/$@

Sources += Tests

Tests/Makefile: %/Makefile:
	git submodule init $*
	git submodule update $*
	-cp local.mk $*/

.PRECIOUS: Tests/%
Tests/%: Tests/Makefile
	cd Tests && $(MAKE) $*

######################################################################

## Files from media office
## Redo next time with testname_disk pathnames

## Sometimes sheets really don't scan!
dropdir/%.manual.tsv:
	$(touch)

Ignore += *.responses.tsv
midterm1.responses.tsv: 
%.responses.tsv:  dropdir/%_disk/BIOLOGY*.dlm dropdir/%.manual.tsv
	$(CAT) $(filter %.dlm %.tsv, $^) > $@

Ignore += *.office.csv
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Scoring

Ignore += $(wildcard *.scoring.csv)
### scoring is just a key sheet formatted for local scoring
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

midterm1.scores.Rout: scores.R
midterm1.scores.Rout:  midterm1.responses.tsv midterm1.scoring.csv scores.R
%.scores.Rout: %.responses.tsv %.scoring.csv scores.R
	$(run-R)

## Compare
midterm1.scorecomp.Rout:
midterm1.scorecomp.Rout: midterm1.office.csv midterm1.scores.Rout scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

## Patch
## Need to patch IDs
## then make them numeric (for robust matching with TAs)
## Later: pad them for Avenue/mosaic
Sources += idpatch.csv
## final.patch.Rout: idpatch.R
%.patch.Rout: %.scores.Rout idpatch.csv idpatch.R
	$(run-R)

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Check anomalies from print out; three kids wrote part of the test?? All dropped
## midterm2.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

######################################################################

## Score merging
## Read stuff from different sources into a complete table
## Use to make final grade

tests.Rout: TAmarks.Rout midterm1.merge.Rout.envir midterm2.merge.Rout.envir final.patch.Rout.envir tests.R

## course.Rout.csv: course.R
course.Rout: gradeFuns.Rout tests.Rout pollScorePlus.Rout TAmarks.Rout course.R

######################################################################

## Mosaic

## Go to course through faculty center
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre
## downcall dropdir/mosaic.csv

mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## Upload this .csv to mosaic
## mosaic_grade.Rout.csv: mosaic_grade.R

######################################################################

## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

Ignore += *.avenue.Rout.csv
%.avenue.Rout: %.Rout TAmarks.Rout avenueMerge.R
	$(run-R)

## avenueNA takes NA -> -. avenue treats these incorrectly as zeroes
Ignore += *.avenue.csv
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

######################################################################

## Older stuff, currently unsuppressing

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
