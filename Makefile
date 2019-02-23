# Grading

# Change codes UGRD/2171/02/BIOLOGY/101187
# Maybe

# 2019 Feb 22 (Fri) REJECT current submodule structure
# This seems to have no cost (except a flabby history I guess)

### Hooks for the editor to set the default target
current: target
-include target.mk

##################################################################

# make files

Sources = Makefile README.md LICENSE.md
ms = makestuff

Sources += $(ms)
Makefile: $(ms)/Makefile

$(ms)/%.mk: $(ms)/Makefile ;
$(ms)/Makefile:
	git submodule update -i

-include $(ms)/os.mk
-include $(ms)/perl.def

##################################################################

## Content

## dropdir has "disk" subdirectories, for disks, and sensitive products in the main directory

## It would be fun to have a rule that does mkdir when appropriate, but we don't
## mkdir /home/dushoff/Dropbox/courses/3SS/2019
## /bin/cp -r /media/dushoff/*/2* dropdir/midterm1_disk/

Sources += $(wildcard *.R *.pl)

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2019
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

## Import TA marks (manual) and change empties to zeroes
## downcall dropdir/marks1.tsv  ##
Ignore += marks.tsv
marks.tsv: dropdir/marks1.tsv zero.pl
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
##		Reports / select report you want / Update reports (next to Current Run at top)

##		downcall dropdir/polls.csv ## ## ## ## ##

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

pardirs += Tests

Ignore += $(pardirs)

## Chaining (works now? 2019 Feb 23 (Sat))
Tests/%: Tests
hotdirs += $(pardirs)

## Files from media office
Sources += media.md

######################################################################

## Pipeline to mark and validate a set of scantrons

## Sometimes sheets really don't scan!
## So we need to be able to add manual rows to the .tsv file
## Also use this for deferred finals if you don't want to bother with 
## scanning
dropdir/%.manual.tsv:
	$(touch)

## Student itemized responses
## Script reads manual version first, ignores repeats
## Necessitated by Daniel Park!
Ignore += *.responses.tsv
## midterm1.responses.tsv: rmerge.pl
%.responses.tsv: dropdir/%.manual.tsv dropdir/%_disk/BIOLOGY*.dlm rmerge.pl
	$(PUSH)

## Scantron-office scores
Ignore += *.office.csv
## midterm1.office.csv: 
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Our scores
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## midterm1.scoring.csv:
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students
## midterm1.scores.Rout:  midterm1.responses.tsv midterm1.scoring.csv scores.R
%.scores.Rout: %.responses.tsv %.scoring.csv scores.R
	$(run-R)

## Compare
## midterm1.scorecomp.Rout: midterm1.office.csv midterm1.scores.Rout scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

######################################################################

## Merging; not clear how this has evolved across a semester

## Patch IDs if necessary, 
## then make them numeric (for robust matching with TAs)
## Later: pad them for Avenue/mosaic
Sources += idpatch.csv
## final.patch.Rout: idpatch.R
%.patch.Rout: %.scores.Rout idpatch.csv idpatch.R
	$(run-R)

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Check anomalies from print out; three kids wrote part of the test?? All dropped
## midterm1.merge.Rout: midMerge.R
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

Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)
## cp ~/hybrid/3SS/Grading/mosaic_grade.Rout.csv dropdir  ##

## mosaic_grade.Rout.csv: mosaic_grade.R
mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## Upload this .csv to mosaic
## Faculty center, online grading tab
## ~/Downloads/grade_guide.pdf
## There is no guidance about students with incomplete marks; let's see what happens

######################################################################

## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

## Put the final marking thing in a form that avenueMerge will understand
## FRAGILE (need to check quality checks)
final.grade.Rout: final.patch.Rout finalscore.R
	$(run-R)

## final.grade.avenue.csv: avenueMerge.R
Ignore += *.avenue.Rout.csv
%.avenue.Rout: %.Rout TAmarks.Rout avenueMerge.R
	$(run-R)

## avenueNA takes NA -> -. avenue treats these incorrectly as zeroes
Ignore += *.avenue.csv
%.avenue.csv: %.avenue.Rout.csv avenueNA.pl
	$(PUSH)

######################################################################

## Older stuff, currently unsuppressing
## I guess the analysis stuff may still be suppressed here

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
-include $(ms)/hotcold.mk
