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


REGEX_BRANCHES="^$(hg branches --template "{branch}|" | \
    sed "s/|$//g" | sed "s/\-/\\\-/g" | sed "s/\./\\\./g")$"
if [[ ! "issue323" =~ ${REGEX_BRANCHES} ]] || \
   [[ ! "ipc-2011-fixes" =~ ${REGEX_BRANCHES} ]]; then
    echo "Your repository is missing the branches 'issue323' and 'ipc-2011-fixes' for the conversion."
    exit 3
fi

hg \
 --config extensions.renaming_mercurial_source="${BASE}/renaming_mercurial_source.py" \
 --config extensions.hgext.convert= \
 --config format.sparse-revlog=0 \
 convert "${SRC_REPOSITORY}" "${CLEANED_REPOSITORY}" \
 --source-type renaming_mercurial_source \
 --authormap "${BASE}/data/downward_authormap.txt" \
 --filemap "${BASE}/data/downward_filemap.txt" \
 --splicemap "${BASE}/data/downward_splicemap.txt" \
 --branchmap "${BASE}/data/downward_branchmap.txt"

cd "${CLEANED_REPOSITORY}"
hg --config extensions.strip= strip "branch(issue323)" --nobackup
hg --config extensions.strip= strip "branch(ipc-2011-fixes)" --nobackup
