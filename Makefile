# Grading

# Change codes UGRD/SCI/2171/02/BIOLOGY/101187
# Maybe

### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: mosaic.diff 

##################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
-include $(ms)/perl.def

Makefile: makestuff/Makefile
Sources += makestuff
makestuff/Makefile: %/Makefile:
	git submodule init $*
	git submodule update $*

##################################################################

## Crib

# Crib = ~/git/Bio3SS_content

%.R:
	$(CP) $(Crib)/$@ .

##################################################################

## Content

Sources += $(wildcard *.R *.pl)

files = $(Drop)/courses/3SS/2017

files:
	$(LNF) $(files) $@

######################################################################

## Polls

polls.csv extraPolls.ssv: %: $(files)/%
	$(copy)

# Read the polls into a big csv without most of the useless information
polls.Rout: polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
# Treat the last question as a fake, and use it to help with ID
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
pollScore.Rout.csv: pollScore.R
pollScore.Rout: extraPolls.ssv parsePolls.Rout pollScore.R

pollScore.students.csv: pollScore.Rout.csv
	perl -ne "print unless /UNKNOWN/" $< > $@

######################################################################

## Haven't really thought about whether to analyze tests here, or in Tests, or to make an analysis directory... right now just focused on calculating grades.

Sources += Tests

Tests/Makefile: %/Makefile:
	git submodule init $*
	git submodule update $*
	cp local.mk $*/

.PRECIOUS: Tests/%
Tests/%: Tests/Makefile
	cd Tests && $(MAKE) $*

######################################################################

## Scantron raw response table
%.responses.csv: $(files)/%.responses.csv
	perl -ne 'print if /^[0-9]{3}/' $< > $@

## Table decoding and marks table. Marks are broken in 2017, so we're marking with scripts here.
## Ideally, we should mark here and then compare: QC and help kids who might have versioned wrong; or catch kids who versioned wrong on purpose (to copy)
## scoreTable should not be used for decoding, since it's missing kids we need but who didn't take the exam
## In 2017, it's not part of the final pipeline at all
scoreTable.csv: $(files)/scoreTable.csv
	$(copy)

## Test answers and scrambling order
%.ssv: Tests/%.ssv
	$(copy)
%.orders: Tests/%.orders
	$(copy)

## Calculate final scores in all combinations
## Prints out "vprob" info – are there people who would have a higher score with a different version number?
final.scores.Rout: %.scores.Rout: %.responses.csv %.orders %.ssv scores.R
	$(run-R)

## One question now has two legal answers; fix with this awkward method
## Score only the extra answer
Sources += fix.ssv
fix.scores.Rout: %.scores.Rout: final.responses.csv final.orders %.ssv scores.R
	$(run-R)
# Add results from two scoring methods
ff.scores.Rout: fix.scores.Rout.envir final.scores.Rout.envir ff.R
	$(run-R)

# Merge the final results with IDs, since we use them everywhere else (not numbers)
# furman_final is used only for ID matching
final.merge.Rout: files/furman_final.csv ff.scores.Rout idmerge.R
	$(run-R)

######################################################################

## Merge final and poll marks into TA spreadsheet

# Read and name
TA.csv: files/furman.csv
	$(copy)
TA.Rout: TA.csv TA.R

# Calculate final and merge; carry StudentNo and ID. Need consistent names
all.Rout: TA.Rout pollScore.students.csv final.merge.Rout all.R

## Current: whatever I'm currently outputting for Avenue or Mosaic
current.Rout: all.Rout current.R
current.Rout.csv: current.R

######################################################################

## Merge grade into mosaic spreadsheet
## List DNWs manually (just for confirmation)

mosaic.Rout: files/roster.csv all.Rout mosaic.R
mosaic.Rout.csv: mosaic.Rout ;

## Note: furman_final is a different kind of file (merged by Furman after I started here); others are upstream with corrections
furman.%.csv:
	$(CP) files/furman.csv $@
	$(CP) $@ files/

## Next time, record what all of these mean!
## Or -- don't use files, use the secret repo
mosaic.%.csv:
	$(CP) mosaic.Rout.csv $@
	$(CP) $@ files/

mosaic.diff: mosaic.Rout.csv
	-diff `ls mosaic.?.csv | tail -1` $< | perl -nE "print if s/^> //" > $@

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
