# Fast Downward Repository Converter

This repository contains scripts for cleaning up Fast Downward repositories
and for converting them from Mercurial to Git. If the repository history was
compatible with the official Fast Downward Mercurial repository, then the converted
repository is compatible with the official Fast Downward Git repository.

## Requirements
  - Python 3.6+ (on Debian/Ubuntu: sudo apt install python3)
  - Python 3 "ensurepip" module (on Debian/Ubuntu: sudo apt install python3-venv)
  - Git

## Usage
  Run the script with the following command where MERCURIAL_REPOSITORY is the path to the 
  repository you want to convert and CONVERTED_GIT_REPOSITORY is the location where the
  resulting Git repository will be written to. The optional parameter can be used to 
  redirect the output of fast-export to a file.

    ./run-all-steps.sh MERCURIAL_REPOSITORY CONVERTED_GIT_REPOSITORY \
        [--redirect-fast-export-stderr FILE]

  The conversion is done in three steps that can also be run individually. In this case
  ORDERED_REPOSITORY is an intermediate repository that ensures that the history
  contains all commits in the same order as the Fast Downward master repository.
  The CLEANED_MERCURIAL_REPOSITORY is a location where the intermediate cleaned
   up Mercurial repository will be written to:
  
    ./run-order.sh MERCURIAL_REPOSITORY ORDERED_REPOSITORY
    ./run-cleanup.sh ORDERED_REPOSITORY CLEANED_MERCURIAL_REPOSITORY
    ./run-conversion.sh CLEANED_MERCURIAL_REPOSITORY CONVERTED_GIT_REPOSITORY \
        [--redirect-fast-export-stderr FILE]

The scripts will automatically set up the required tools (a virtual
environment with compatible versions of Mercurial and the fast-export tool
https://github.com/frej/fast-export.git).

## Limitations
- Multiple Mercurial heads with the same branch name are not supported. If your
  repository has those, you will see
  `Error: repository has at least one unnamed head: hg rXXX`.
- If you have closed and merged a branch "subfeature" into a branch "feature"
  and "feature" is not yet merged into "main", you might want to delete "subfeature"
  branch from the resulting Git repository by running `git branch -D subfeature`.

## Warnings
- The `run-cleanup.sh` and `run-conversion.sh` scripts generate a lot of output 
  on stdout and stderr. If you want to analyze it, better redirect it into files.
- The cleanup script generates repeated warnings about missing or invalid tags.
  These are caused by moved or broken tags and can be ignored.

## Details of the order process
- clone the (Mercurial) Fast Downward master repository
- strip all commits from the master repository that would be new to your
  repository
- pull your repository in the master repository

## Details of the cleanup process
- fix and unify author names in commit message
- fix typos in branch names
- remove large files from history that should not have been added
- change commit message to follow the new convention which is to start with
"`[BRANCH NAME] `"

## Details of the conversion process
- convert a Mercurial repository to Git with `fast-export`
- delete all Git branches that belong to Mercurial branches which have been
  merged and closed
- remove empty commits
- run garbage collections


Let's rewrite history!
