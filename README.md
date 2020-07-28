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

To prepare your repository for the conversion pull all changes from
`http://hg.fast-downward.org`. Then run the script with the following
command where MERCURIAL_REPOSITORY is the path to the repository you
want to convert and CONVERTED_GIT_REPOSITORY is the location where the
resulting Git repository will be written to. The optional parameter
can be used to redirect the output of fast-export to a file.

  ./run-all-steps.sh MERCURIAL_REPOSITORY CONVERTED_GIT_REPOSITORY \
      [--redirect-fast-export-stderr FILE]

The conversion is done in two steps that can also be run individually.
CLEANED_MERCURIAL_REPOSITORY is the location for the cleaned-up
Mercurial repository, which is the output of the first step and the
input of the second step.

    ./run-cleanup.sh MERCURIAL_REPOSITORY CLEANED_MERCURIAL_REPOSITORY
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
  and "feature" is not yet merged into "main", you will receive:
  `error: The branch 'BRANCH' is not fully merged.`
  Don't worry. You might want to delete "subfeature" branch from the
  resulting Git repository by running `git branch -D subfeature`.

## Warnings

- The scripts generate a lot of output on stdout and stderr. If you
  want to analyze it, better redirect it into files.
- It is normal behavior that the cleanup script generates some
  warnings about missing or invalid tags.

## Troubleshooting

If you have problems with the `run-all-steps.sh` script, try to run the steps
individually and carefully inspect the output of each step.

## Details of the cleanup process

- clone the official (Mercurial) Fast Downward repository
- pull the changes from your repository into the clone
- strip the open branches `issue323` and `ipc-2011-fixes`
- fix and unify author names in commit message
- fix typos in branch names
- remove files from history that should not have been added
- change commit messages to follow the new convention which is to
  start with "`[BRANCH NAME] `"

## Details of the conversion process

- convert a Mercurial repository to Git with `fast-export`
- delete all Git branches that belong to Mercurial branches which have been
  merged and closed
- remove empty commits
- run garbage collection


Let's rewrite history!
