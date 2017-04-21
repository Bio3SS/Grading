# Grading
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: final.merge.Rout 

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

Crib = ~/git/Bio3SS_content

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

polls.csv extraPolls.ssv:
	/bin/cp -f $(files)/$@ .

# Read the polls into a big csv without most of the useless information
polls.Rout: polls.csv polls.R

# Parse the big csv in some way. Tags things that couldn't be matched to Mac address with UNKNOWN
parsePolls.Rout: polls.Rout parsePolls.R

# Calculate a pollScore and combine with the extraScore made by hand
pollScore.Rout.csv: pollScore.R
pollScore.Rout: extraPolls.ssv parsePolls.Rout pollScore.R

pollScore.students.csv: pollScore.Rout.csv
	perl -ne "print unless /UNKNOWN/" $< > $@

######################################################################

## Final marks

## Not handled by TAs because of scantron glitch. Need to merge with TA spreadsheet

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

# Also makes this currently unused file
final.scores.Rout.csv: 

# Merge the final results with IDs, since we use them everywhere else (not numbers)
final.merge.Rout: scoreTable.csv final.scores.Rout idmerge.R
	$(run-R)

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
