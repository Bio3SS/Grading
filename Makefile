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

$(ms)/%.mk: $(ms)/Makefile 
	touch $@

$(ms)/Makefile:
	git submodule update -i

-include $(ms)/os.mk
-include $(ms)/perl.def

##################################################################

## Content

## dropdir has "disk" subdirectories, for disks, and sensitive products in the main directory

## It would be fun to have a rule that does mkdir when appropriate, but we don't
## mkdir /home/dushoff/Dropbox/courses/3SS/2019/final_disk ##
## /bin/cp -r /media/dushoff/*/*/* dropdir/final_disk/ ##

Sources += $(wildcard *.R *.pl)

Ignore += dropdir
dropdir: dir = /home/dushoff/Dropbox/courses/3SS/2019
dropdir:
	$(linkdirname)
dropdir/%: 
	$(MAKE) dropdir

######################################################################

## merge notes
## I mostly merge on idnum. Strategy is to make it numeric as often 
## as seems necessary while merging. Then pad it right before avenue
## or mosaic. Current code in avenueMerge.R

## Spreadsheets with TA marks from HWs and SAs
## How did we make original spreadsheet from Avenue?

## Import TA marks (manual) and change empties to zeroes
## Use named versions of marks.tsv (no revision control in Dropbox)
## Need to update in Apr 2019
## downcall dropdir/marks5.tsv  ##
Ignore += marks.tsv
marks.tsv: dropdir/marks5.tsv zero.pl ##
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

##	downcall dropdir/polls.csv ##

######################################################################

# Read the polls into a big csv without most of the useless information

polls.Rout: dropdir/polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the question that matches "macid" as a fake (if present)
# and use it to help with ID
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
# The csv is where to look for orphan lines and try to figure out if people are missing points they should get
# Then loop back to the manual part of the .ssv
pollScore.Rout: dropdir/extraPolls.ssv parsePolls.Rout pollScore.R
pollScore.Rout.csv: 

# Ask people to answer a fake question with "macid" in it
# in all the ways that they answered the polls
# Then save people manually in column 3 of .ssv

# Merge to save people who repeatedly use student number
## Why not working? 2019 Apr 29 (Mon)
## Patched, but not doing anything. Because people know what macid is now? remove?
pollScorePlus.Rout: pollScore.Rout TAmarks.Rout pollScorePlus.R

## Make an avenue file; should work with any number of fields ending in _score (in a variable called scores)
## along with a field for macid, idnum or both
## No, scores for input should have only macid, I guess

## https://avenue.cllmcmaster.ca/d2l/lms/grades/admin/enter/user_list_view.d2l?ou=273939
## import

pollScorePlus.avenue.Rout: avenueMerge.R
pollScorePlus.avenue.Rout.csv: avenueMerge.R

pollScorePlus.avenue.csv: avenueNA.pl

######################################################################

pardirs += Tests

Ignore += $(pardirs)

## Chaining (works now? 2019 Feb 23 (Sat))
## Problem: $(MAKE) can lead to looping
## Dependencies can lead to make never being finished
## This works fine if Tests exists
## A broader pardirs rule might just work!
Tests/%:
	$(MAKE) Tests
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
## Check anomalies from print out
## Empty scores will be set to 0. Add MSAF to sheet (as NA?) 
## midterm2.merge.Rout: midMerge.R
midterm%.merge.Rout: midterm%.patch.Rout TAmarks.Rout midMerge.R
	$(run-R)

######################################################################

## avenueMerge
## Still developing
## Code that takes a whole spreadsheet to Avenue still in Tests/

## Put the final marking thing in a form that avenueMerge will understand
## FRAGILE (need to check quality checks)
## midterm2.grade.Rout: midterm2.merge.Rout finalscore.R
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

## Check weightings, number of assignments, components, etc.
## course.Rout.csv: course.R
course.Rout: gradeFuns.Rout tests.Rout pollScorePlus.Rout TAmarks.Rout course.R

## Mosaic

## Go to course through faculty center
## You can download as EXCEL (upper right of roster display)
## and upload as CSV

## downcall dropdir/mosaic.xls ## Insanity! This is an html file that cannot be read by R AFAICT, even though it opens fine in Libre ##
## downcall dropdir/mosaic.csv

## Check class number 
## Check dropCandidates in Rout
## mosaic_grade.Rout.csv: mosaic_grade.R
mosaic_grade.Rout: dropdir/mosaic.csv course.Rout mosaic_grade.R
## Upload this .csv to mosaic
## Faculty center, online grading tab
## ~/Downloads/grade_guide.pdf
## There is no guidance about students with incomplete marks; let's see what happens

## Copy grades to dropdir for diffing:
#### cp mosaic_grade.Rout.csv dropdir
Ignore += grade.diff
grade.diff: mosaic_grade.Rout.csv dropdir/mosaic_grade.Rout.csv
	$(diff)

######################################################################

## Older stuff, currently unsuppressing
## Analysis stuff may still be suppressed here

Sources += grades.mk

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
-include $(ms)/hotcold.mk
