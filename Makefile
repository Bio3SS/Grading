# Grading
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: evaluation_module 

##################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
# include $(ms)/perl.def

##################################################################

## Crib

Crib = ~/git/Grading_scripts

%.R:
	$(CP) $(Crib)/$@ .

##################################################################

## Content

Sources += $(wildcard *.R *.pl)

files = $(Drop)/courses/3SS/2017

######################################################################

## Polls

## Don't push these because of privacy!
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

## Final

## Not handled by TAs because of scantron glitch. Need to merge with TA spreadsheet

## Assignments as a submodule? Bold.
evaluation_module:
	git submodule add git@github.com:Bio3SS/Evaluation_materials.git

assignments_module:
	git submodule deinit Assignments
	git rm Assignments

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
-include $(ms)/wrapR.mk
