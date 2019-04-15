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
## mkdir /home/dushoff/Dropbox/courses/3SS/2019/midterm2_disk ##
## /bin/cp -r /media/dushoff/*/2* dropdir/midterm2_disk/

Sources += $(wildcard *.R *.pl)

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2019
dropdir:
	$(linkdirname)
dropdir/%: dropdir ;

######################################################################

## merge notes
## I mostly merge on idnum. Strategy is to make it numeric as often 
## as seems necessary while merging. Then pad it right before avenue
## or mosaic. Current code in avenueMerge.R

## Spreadsheets with TA marks from HWs and SAs
## How did we make original spreadsheet from Avenue?

## Import TA marks (manual) and change empties to zeroes
## Use named versions of marks.tsv (no revision control in Dropbox)
## downcall dropdir/marks3.tsv  ##
Ignore += marks.tsv
marks.tsv: dropdir/marks3.tsv zero.pl ##
	$(PUSH)

## Parse out TAmarks, drop students we think have dropped
## Used Avenue import info; this could be improved by starting from that
## Pull a subset of just student info

Sources += nodrops.csv
dropdir/drops.csv: 
	$(CP) nodrops.csv $@
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

##	downcall dropdir/polls.csv ## ## ## ## ##

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

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=273939
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

## Sort out dropdir
## 

## Student itemized responses
## Script reads manual version first, ignores repeats
## Necessitated by Daniel Park!
Ignore += *.responses.tsv
## midterm2.responses.tsv: rmerge.pl
%.responses.tsv: dropdir/%.manual.tsv dropdir/%_disk/BIOLOGY*.dlm rmerge.pl
	$(PUSH)

## Scantron-office scores
Ignore += *.office.csv
## midterm2.office.csv: 
%.office.csv: dropdir/%_disk/StudentScoresWebCT.csv
	perl -ne 'print if /^[a-z0-9]*@/' $< > $@

## Our scores
Ignore += $(wildcard *.scoring.csv)
### Formatted key sheet (made from scantron.csv)
## make Tests/midterm2.scantron.csv ## to stop making forever ##
## midterm2.scoring.csv:
%.scoring.csv: Tests/%.scantron.csv scoring.pl
	$(PUSH)

## Score the students
## How many have weird bubble versions? How many have best ≠ bubble?
## midterm1.scores.Rout:  midterm1.responses.tsv midterm1.scoring.csv scores.R
## midterm2.scores.Rout:  midterm2.responses.tsv midterm2.scoring.csv scores.R
%.scores.Rout: %.responses.tsv %.scoring.csv scores.R
	$(run-R)

## Compare
## Now fewer people have score ≠ best score. Don't worry?
## midterm1.scorecomp.Rout: midterm1.office.csv midterm1.scores.Rout scorecomp.R
## midterm2.scorecomp.Rout: midterm2.office.csv midterm2.scores.Rout scorecomp.R
%.scorecomp.Rout: %.office.csv %.scores.Rout scorecomp.R
	$(run-R)

######################################################################

## Merging test with scoresheet
## Patch IDs if necessary, 
## then make them numeric (for robust matching with TAs)
## Later: pad them for Avenue/mosaic
Sources += idpatch.csv
%.patch.Rout: %.scores.Rout idpatch.csv idpatch.R
	$(run-R)
## midterm1.patch.Rout: idpatch.R
## midterm2.patch.Rout: idpatch.R

## Merge SAs (from TA sheet) with patched scores (calculated from scantrons)
## Set numeric to merge here. Pad somewhere downstream
## Check anomalies from print out; three kids wrote part of the test?? All dropped
## midterm2.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

######################################################################

## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

## Put the final marking thing in a form that avenueMerge will understand
## FRAGILE (need to check quality checks)
## midterm2.grade.Rout: midterm1.merge.Rout finalscore.R
## midterm2.grade.avenue.csv:
%.grade.Rout: %.merge.Rout finalscore.R
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

## Combined course grading
## Score merging
## Read stuff from different sources into a complete table

tests.Rout: TAmarks.Rout midterm1.merge.Rout.envir midterm2.merge.Rout.envir final.patch.Rout.envir tests.R

## course.Rout.csv: course.R
course.Rout: gradeFuns.Rout tests.Rout pollScorePlus.Rout TAmarks.Rout course.R

## Mosaic

## Go to course through faculty center
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre
## downcall dropdir/mosaic.csv

Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)

## mosaic_grade.Rout.csv: mosaic_grade.R
mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## Upload this .csv to mosaic
## Faculty center, online grading tab
## ~/Downloads/grade_guide.pdf
## There is no guidance about students with incomplete marks; let's see what happens

######################################################################

## Older stuff, currently unsuppressing
## Analysis stuff may still be suppressed here

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
-include $(ms)/hotcold.mk
