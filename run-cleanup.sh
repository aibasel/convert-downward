#!/bin/bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi

SRC_REPOSITORY="$1"
CLEANED_REPOSITORY="$2"
shift 2

if [[ ! -d "${SRC_REPOSITORY}" ]]; then
  echo "Invalid argument. ${SRC_REPOSITORY} has to be a directory."
  exit 1
fi

if [[ -e "${CLEANED_REPOSITORY}" ]]; then
  echo "Invalid argument. ${CLEANED_REPOSITORY} may not exist."
  exit 1
fi

ORDERED_REPOSITORY="$(mktemp -d)"
echo "Storing intermediate reordered repository under ${ORDERED_REPOSITORY}"


BASE="$(dirname "$(readlink -f "$0")")"
SETUP_MERCURIAL="${BASE}/setup-mercurial.sh"
VIRTUALENV="${BASE}/data/py3-env"

if ! /bin/bash "${SETUP_MERCURIAL}"; then
  echo "Error during setup."
  exit 2
fi
source "${VIRTUALENV}/bin/activate"
# Disable all extensions.
# (https://stackoverflow.com/questions/46612210/mercurial-disable-all-the-extensions-from-the-command-line)
export HGRCPATH=
export HGPLAIN=

echo "Looking for missing commits"

if hg -R "${SRC_REPOSITORY}" incoming http://hg.fast-downward.org; then
    echo 1>&2 "Your repository is missing commits from http://hg.fast-downward.org."
    echo 1>&2 "You must pull from http://hg.fast-downward.org first."
    exit 3
fi

echo "Cloning official repository"
hg clone http://hg.fast-downward.org "${ORDERED_REPOSITORY}"

echo "Pulling own commits"
hg -R "${ORDERED_REPOSITORY}" pull "${SRC_REPOSITORY}"

echo "Creating cleaned-up repository"
hg \
 --config extensions.renaming_mercurial_source="${BASE}/renaming_mercurial_source.py" \
 --config extensions.hgext.convert= \
 --config format.sparse-revlog=0 \
 convert "${ORDERED_REPOSITORY}" "${CLEANED_REPOSITORY}" \
 --source-type renaming_mercurial_source \
 --authormap "${BASE}/data/downward_authormap.txt" \
 --filemap "${BASE}/data/downward_filemap.txt" \
 --splicemap "${BASE}/data/downward_splicemap.txt" \
 --branchmap "${BASE}/data/downward_branchmap.txt"

echo "Stripping extraneous branches"
hg -R "${CLEANED_REPOSITORY}" \
   --config extensions.strip= \
   strip "branch(issue323)" "branch(ipc-2011-fixes)" \
   --nobackup

echo "Removing intermediate reordered repository."
rm -r "${ORDERED_REPOSITORY}"
