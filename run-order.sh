#!/bin/bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi

SRC_REPOSITORY="$1"
ORDERED_REPOSITORY="$2"
shift 2

if [[ ! -d "${SRC_REPOSITORY}" ]]; then
  echo "Invalid argument. ${SRC_REPOSITORY} has to be a directory."
  exit 1
fi

if [[ -e "${ORDERED_REPOSITORY}" ]]; then
  echo "Invalid argument. ${ORDERED_REPOSITORY} may not exist."
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
HGRCPATH= HGPLAIN= \
hg clone "http://hg.fast-downward.org" "${ORDERED_REPOSITORY}"
set +e  # hg incoming has an non-zero exit code if nothing is incoming
CHANGESETS="$(hg -R "${SRC_REPOSITORY}" incoming --template "{node} " --quiet "${ORDERED_REPOSITORY}")"
set -e
if [[ ! -z "${CHANGESETS}" ]]; then
  echo stripping
  HGRCPATH= HGPLAIN= \
  hg -R "${ORDERED_REPOSITORY}" --config extensions.strip= strip ${CHANGESETS} --nobackup
fi
HGRCPATH=  HGPLAIN= \
hg -R "${ORDERED_REPOSITORY}" pull "${SRC_REPOSITORY}"
